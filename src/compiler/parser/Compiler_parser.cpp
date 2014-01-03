#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace TokenKind = Enum::Token::Kind;
namespace SyntaxType = Enum::Parser::Syntax;

static jmp_buf jmp_point;
static void Parser_exception(const char *msg, size_t line)
{
	fprintf(stderr, "[ERROR]: syntax error : %s at %zd\n", msg, line);
	longjmp(jmp_point, 1);
}

Module::Module(const char *name_, const char *args_)
	: name(name_), args(args_) {}

AST::AST(Node *root)
{
	this->root = root;
}

void AST::dump(void)
{
	Node *traverse_ptr = root;
	for (; traverse_ptr->next != NULL; traverse_ptr = traverse_ptr->next) {
		traverse_ptr->dump(0);
	}
	traverse_ptr->dump(0);
}

ParseContext::ParseContext(Token *tk)
{
	this->tk = tk;
	this->tks = tk->tks;
	this->nodes = new Nodes();
	this->idx = 0;
	this->returnToken = NULL;
}

Token *ParseContext::token(void)
{
	return tks[idx];
}

void ParseContext::pushNode(Node *node)
{
	nodes->push(node);
}

Node *ParseContext::lastNode(void)
{
	return nodes->lastNode();
}

Token *ParseContext::token(Token *base, int offset)
{
	Token *ret = nullableToken(base, offset);
	if (!ret) Parser_exception("", base->finfo.start_line_num);
	return ret;
}

Token *ParseContext::nullableToken(Token *base, int offset)
{
	Token **tks = this->tks;
	int n = tk->token_num;
	int wanted_idx = -1;
	for (int i = 0; i < n; i++) {
		if (tks[i] == base) {
			wanted_idx = i + offset;
			break;
		}
	}
	return (0 <= wanted_idx && wanted_idx < n) ? tks[wanted_idx] : NULL;
}

Token *ParseContext::nextToken(void)
{
	return (idx + 1 < tk->token_num) ? tks[idx + 1] : NULL;
}

bool ParseContext::end(void)
{
	return idx >= tk->token_num;
}

void ParseContext::next(void)
{
	idx++;
}

void ParseContext::next(int progress)
{
	idx += progress;
}

Parser::Parser(void)
{
	this->_prev_stmt = NULL;
	this->extra_node = NULL;
}

bool Parser::canGrouping(Token *tk, Token *next_tk)
{
	using namespace TokenType;
	if (!next_tk) return false;
	TokenType::Type type = tk->info.type;
	TokenType::Type next_type = next_tk->info.type;
	TokenKind::Kind next_kind = next_tk->info.kind;
	if (type == NamespaceResolver &&
		(next_kind != TokenKind::Symbol && next_kind != TokenKind::StmtEnd)) return true;
	if (next_type  == NamespaceResolver) return true;
	return false;
}

void Parser::grouping(Tokens *tokens)
{
	using namespace TokenType;
	TokenPos pos = tokens->begin();
	string ns = "";
	Token *next_tk = NULL;
	while (pos != tokens->end()) {
		Token *tk = ITER_CAST(Token *, pos);
		if (!tk) break;
		switch (tk->info.type) {
		case Var: case GlobalVar: case GlobalHashVar:
		case Namespace: case Class: case CORE: {
			Token *ns_token = tk;
			TokenPos start_pos = pos+1;
			size_t move_count = 0;
			do {
				tk = ITER_CAST(Token *, pos);
				if (tk) ns += tk->data;
				else break;
				pos++;
				move_count++;
				next_tk = (pos != tokens->end()) ? ITER_CAST(Token *, pos) : NULL;
			} while (canGrouping(tk, next_tk));
			TokenPos end_pos = pos;
			pos -= move_count;
			ns_token->data = ns;
			ns_token->info.has_warnings = true;
			ns = "";
			tokens->erase(start_pos, end_pos);
			break;
		}
		case ShortScalarDereference: case ShortArrayDereference:
		case ShortHashDereference:   case ShortCodeDereference: {
			Token *next_tk = ITER_CAST(Token *, pos+1);
			if (!next_tk) break;
			Token *sp_token = tk;
			sp_token->data += next_tk->data;
			tokens->erase(pos+1);
			break;
		}
		default:
			break;
		}
		pos++;
	}
}

void Parser::replaceHereDocument(Tokens *tokens)
{
	pos = tokens->begin();
	start_pos = pos;
	TokenPos it = tokens->begin();
	TokenPos tag_pos = start_pos;
	while (it != tokens->end()) {
		Token *t = ITER_CAST(Token *, it);
		switch (t->info.type) {
		case TokenType::HereDocumentTag: case TokenType::HereDocumentRawTag:
			tag_pos = it;
			break;
		case TokenType::HereDocument:
			if (tag_pos == start_pos) {
				Parser_exception("nothing use HereDocumentTag", __LINE__);
			} else {
				Token *tag = ITER_CAST(Token *, tag_pos);
				switch (tag->info.type) {
				case TokenType::HereDocumentTag:
					tag->data = t->data;
					tag->info = getTokenInfo(TokenType::String);
					break;
				case TokenType::HereDocumentRawTag:
					tag->data = t->data;
					tag->info = getTokenInfo(TokenType::RawString);
					break;
				default:
					break;
				}
				tokens->erase(tag_pos-1);
				tokens->erase(it-1);
				it--;
				continue;
			}
			break;
		case TokenType::HereDocumentEnd:
			tokens->erase(it);
			continue;
			break;
		default:
			break;
		}
		it++;
	}
}

bool Parser::isExpr(Token *tk, Token *prev_tk, TokenType::Type type, TokenKind::Kind kind)
{
	using namespace TokenType;
	if (tk->tks[0]->info.type != LeftBrace) Parser_exception("", tk->finfo.start_line_num);
	Type next_type = (tk->token_num > 1) ? tk->tks[1]->info.type : Undefined;
	Type next_after_type = (tk->token_num > 2) ? tk->tks[2]->info.type : Undefined;
	if (tk->token_num > 3 && (next_type == Key || next_type == String) &&
		(next_after_type == Arrow || next_after_type == Comma)) {
		/* { [key|"key"] [,|=>] value ... */
		/* hash reference */
		return true;
	} else if (type == Pointer ||
			   type == Mul || type == Glob ||
			   kind == TokenKind::Term ||
			   kind == TokenKind::Modifier ||
			   kind == TokenKind::Function ||/* type == FunctionDecl ||*/
			   ((prev_tk && prev_tk->stype == SyntaxType::Expr) && (type == RightBrace || type == RightBracket))) {
		/* ->{ or $hash{ or map { or {key}{ or [idx]{ */
		return true;
	} else if (kind == TokenKind::Assign) {
		return true;
	}
	return false;
}

bool Parser::isMissingSemicolon(TokenType::Type prev_type, TokenType::Type type, Tokens *tokens)
{
	using namespace TokenType;
	if (type == RightBrace && prev_type != SemiColon) {
		size_t size = tokens->size();
		for (size_t i = 0; i < size; i++) {
			if (tokens->at(i)->stype == SyntaxType::Stmt) {
				return true;
			}
		}
	}
	return false;
}

bool Parser::isMissingSemicolon(Tokens *tokens)
{
	using namespace TokenType;
	Token *tk = tokens->back();
	if (tk->stype != SyntaxType::Stmt) {
		size_t size = tokens->size();
		for (size_t i = 0; i < size; i++) {
			if (tokens->at(i)->stype == SyntaxType::Stmt) {
				return true;
			}
		}
	}
	return false;
}

Token *Parser::replaceToStmt(Tokens *cur_tokens, Token *cur_tk, size_t offset)
{
	Tokens *stmt = new Tokens();
	for (size_t i = 0; i < offset - 1; i++) {
		Token *tk = cur_tokens->back();
		i += (tk->total_token_num > 0) ? tk->total_token_num - 1 : 0;
		stmt->insert(stmt->begin(), tk);
		cur_tokens->pop_back();
	}
	Token *semicolon = new Token(";", cur_tk->finfo);
	semicolon->info.type = TokenType::SemiColon;
	semicolon->info.name = "SemiColon";
	semicolon->info.kind = TokenKind::StmtEnd;
	stmt->push_back(semicolon);
	Token *stmt_ = new Token(stmt);
	stmt_->stype = SyntaxType::Stmt;
	cur_tokens->push_back(stmt_);
	return stmt_;
}

Token *Parser::parseSyntax(Token *start_token, Tokens *tokens)
{
	using namespace TokenType;
	Type prev_type = Undefined;
	TokenKind::Kind prev_kind = TokenKind::Undefined;
	TokenPos end_pos = tokens->end();
	Tokens *new_tokens = new Tokens();
	TokenPos intermediate_pos = pos;
	Token *prev_syntax = NULL;
	if (start_token) {
		new_tokens->push_back(start_token);
		intermediate_pos--;
	}
	while (pos != end_pos) {
		Token *t = ITER_CAST(Token *, pos);
		Type type = t->info.type;
		TokenKind::Kind kind = t->info.kind;
		switch (type) {
		case LeftBracket: case LeftParenthesis:
		case ArrayDereference: case HashDereference:
		case ScalarDereference: case ArraySizeDereference: {
			if (pos + 1 == end_pos) Parser_exception("nothing end flagment", t->finfo.start_line_num);
			pos++;
			Token *syntax = parseSyntax(t, tokens);
			syntax->stype = SyntaxType::Expr;
			new_tokens->push_back(syntax);
			prev_syntax = syntax;
			break;
		}
		case LeftBrace: {
			if ((pos + 1) == end_pos) Parser_exception("nothing end flagment", t->finfo.start_line_num);
			Token *prev = (pos != start_pos) ? ITER_CAST(Token *, pos-1) : NULL;
			prev_type = (prev) ? prev->info.type : Undefined;
			pos++;
			Token *syntax = parseSyntax(t, tokens);
			if (isExpr(syntax, prev_syntax, prev_type, prev_kind)) {
				syntax->stype = SyntaxType::Expr;
			} else if (prev_type == FunctionDecl || prev_kind == TokenKind::Do) {
				syntax->stype = SyntaxType::BlockStmt;
			} else {
				syntax->stype = SyntaxType::BlockStmt;
				if (pos == end_pos) Parser_exception("nothing end flagment", t->finfo.start_line_num);
				if ((pos+1) != tokens->end()) {
					Token *next_tk = ITER_CAST(Token *, pos+1);
					if (next_tk && next_tk->info.type != SemiColon) {
						intermediate_pos = pos;
					}
				}
			}
			new_tokens->push_back(syntax);
			prev_syntax = syntax;
			break;
		}
		case RightBrace: case RightBracket: case RightParenthesis: {
			if (isMissingSemicolon(prev_type, t->info.type, new_tokens)) {
				prev_syntax = replaceToStmt(new_tokens, t, pos - intermediate_pos);
			}
			new_tokens->push_back(t);
			return new Token(new_tokens);
			break; /* not reached this stmt */
		}
		case SemiColon: {
			size_t k = pos - intermediate_pos;
			if (start_pos == intermediate_pos) k++;
			prev_syntax = replaceToStmt(new_tokens, t, k);
			intermediate_pos = pos;
			break;
		}
		default:
			new_tokens->push_back(t);
			prev_syntax = NULL;
			break;
		}
		prev_kind = kind;
		prev_type = type;
		if (pos == end_pos) Parser_exception("nothing end flagment", t->finfo.start_line_num);
		pos++;
	}
	if (isMissingSemicolon(new_tokens)) {
		replaceToStmt(new_tokens, new_tokens->back(), pos - intermediate_pos);
	}
	return new Token(new_tokens);
}

void Parser::insertExpr(Token *syntax, int idx, size_t grouping_num)
{
	size_t tk_n = syntax->token_num;
	Token **tks = syntax->tks;
	Token *tk = tks[idx];
	Tokens *expr = new Tokens();
	expr->push_back(tk);
	for (size_t i = 1; i < grouping_num; i++) {
		expr->push_back(tks[idx+i]);
	}
	Token *expr_ = new Token(expr);
	expr_->stype = SyntaxType::Expr;
	tks[idx] = expr_;
	if (tk_n == idx+grouping_num) {
		for (size_t i = 1; i < grouping_num; i++) {
			syntax->tks[idx+i] = NULL;
		}
	} else {
		memmove(syntax->tks+(idx+1), syntax->tks+(idx+grouping_num),
				sizeof(Token *) * (tk_n - (idx+grouping_num)));
		for (size_t i = 1; i < grouping_num; i++) {
			syntax->tks[tk_n-i] = NULL;
		}
	}
	syntax->token_num -= (grouping_num - 1);
}

void Parser::insertStmt(Token *syntax, int idx, size_t grouping_num)
{
	size_t tk_n = syntax->token_num;
	Token **tks = syntax->tks;
	Token *tk = tks[idx];
	Tokens *stmt = new Tokens();
	stmt->push_back(tk);
	for (size_t i = 1; i < grouping_num; i++) {
		stmt->push_back(tks[idx+i]);
	}
	Token *stmt_ = new Token(stmt);
	stmt_->stype = SyntaxType::Stmt;
	tks[idx] = stmt_;
	if (tk_n == idx+grouping_num) {
		for (size_t i = 1; i < grouping_num; i++) {
			syntax->tks[idx+i] = NULL;
		}
	} else {
		memmove(syntax->tks+(idx+1), syntax->tks+(idx+grouping_num),
				sizeof(Token *) * (tk_n - (idx+grouping_num)));
		for (size_t i = 1; i < grouping_num; i++) {
			syntax->tks[tk_n-i] = NULL;
		}
	}
	syntax->token_num -= (grouping_num - 1);
}

bool Parser::isForStmtPattern(Token *tk, Token *expr)
{
	if (tk->info.type != TokenType::ForStmt) return false;
	if (expr->token_num > 3 &&
		expr->tks[1]->stype == SyntaxType::Stmt &&
		expr->tks[2]->stype == SyntaxType::Stmt &&
		expr->tks[3]->stype != SyntaxType::Stmt &&
		expr->tks[3]->info.type != TokenType::RightParenthesis) {
		/* for ( stmt stmt $v++) .. */
		return true;
	}
	return false;
}

void Parser::parseSpecificStmt(Token *syntax)
{
	using namespace TokenType;
	size_t tk_n = syntax->token_num;
	for (size_t i = 0; i < tk_n; i++) {
		Token **tks = syntax->tks;
		Token *tk = tks[i];
		switch (tk->info.type) {
		case IfStmt:    case ElsifStmt: case ForeachStmt:
		case ForStmt:   case WhileStmt: case UnlessStmt:
		case GivenStmt: case UntilStmt: case WhenStmt: {
			if (tk_n > i+2 &&
				tks[i+1]->stype == SyntaxType::Expr &&
				tks[i+2]->stype == SyntaxType::BlockStmt) {
				/* if Expr BlockStmt */
				Token *expr = tks[i+1];
				if (isForStmtPattern(tk, expr)) {
					size_t progress_section_idx = 3;
					size_t stmt_size = expr->token_num - (progress_section_idx + 1);
					insertStmt(expr, progress_section_idx, stmt_size);
					// expr is '(', 'Stmt', 'Stmt', 'Stmt', ')'
				}
				size_t pattern_size = 3; //ex) if + expr + blockstmt
				insertStmt(syntax, i, pattern_size);
				tk_n -= (pattern_size - 1);
				parseSpecificStmt(tks[i]->tks[2]);
			} else if ((tk->info.type == ForStmt || tk->info.type == ForeachStmt) &&
					   tk_n > i+3 && tks[i+1]->stype != SyntaxType::Expr) {
				/* for(each) [decl] Term Expr BlockStmt */
				if (tk_n > i+3 &&
					tks[i+1]->info.kind == TokenKind::Term &&
					tks[i+2]->stype == SyntaxType::Expr &&
					tks[i+3]->stype == SyntaxType::BlockStmt) {
					size_t pattern_size = 4;
					insertStmt(syntax, i, pattern_size);
					tk_n -= (pattern_size - 1);
					parseSpecificStmt(tks[i]->tks[3]);
				} else if (tk_n > i+4 &&
					tks[i+1]->info.kind == TokenKind::Decl &&
					tks[i+2]->info.kind == TokenKind::Term &&
					tks[i+3]->stype == SyntaxType::Expr &&
					tks[i+4]->stype == SyntaxType::BlockStmt) {
					size_t pattern_size = 5;
					insertStmt(syntax, i, pattern_size);
					tk_n -= (pattern_size - 1);
					parseSpecificStmt(tks[i]->tks[4]);
				} else {
					//fprintf(stderr, "Syntax Error!: near by line[%zu]\n", tk->finfo.start_line_num);
					//exit(EXIT_FAILURE);
				}
			}
			break;
		}
		case ElseStmt: case Continue: case DefaultStmt:
			if (tk_n > i+1 &&
				tks[i+1]->stype == SyntaxType::BlockStmt) {
				/* else BlockStmt */
				insertStmt(syntax, i, 2);
				tk_n -= 1;
				parseSpecificStmt(tks[i]->tks[1]);
			}
			break;
		case Do:
			if (tk_n > i+1 &&
				tks[i+1]->stype == SyntaxType::BlockStmt) {
				/* do BlockStmt */
				insertStmt(syntax, i, 2);
				tk_n -= 1;
				parseSpecificStmt(tks[i]->tks[1]);
			} else if (tk_n > i+3 &&
					   tks[i+1]->info.kind == TokenKind::Term &&
					   tks[i+2]->stype == SyntaxType::Expr) {
				size_t pattern_size = 4;
				insertExpr(syntax, i, pattern_size);
				tk_n -= (pattern_size - 1);
				parseSpecificStmt(tks[i]->tks[pattern_size-1]);
			}
			break;
		case FunctionDecl:
			if (tk_n > i+1 &&
				tks[i+1]->info.type == SyntaxType::BlockStmt) {
				/* sub BlockStmt */
				insertStmt(syntax, i, 2);
				tk_n -= 1;
				parseSpecificStmt(tks[i]->tks[1]);
			} else if (tk_n > i+2 &&
			    (tks[i+1]->info.type == Function || tks[i+1]->info.type == Namespace) &&
				tks[i+2]->stype == SyntaxType::BlockStmt) {
				/* sub func BlockStmt */
				insertStmt(syntax, i, 3);
				tk_n -= 2;
				parseSpecificStmt(tks[i]->tks[2]);
			} else if (tk_n > i+3 &&
			    (tks[i+1]->info.type == Function || tks[i+1]->info.type == Namespace) &&
				tks[i+2]->stype == SyntaxType::Expr &&
				tks[i+3]->stype == SyntaxType::BlockStmt) {
				/* sub func Expr BlockStmt */
				insertStmt(syntax, i, 4);
				tk_n -= 3;
				parseSpecificStmt(tks[i]->tks[3]);
			}
			break;
		default:
			if (tk->stype == SyntaxType::BlockStmt) {
				if (i > 0 &&
					(tks[i-1]->stype == SyntaxType::Stmt ||
					 tks[i-1]->stype == SyntaxType::BlockStmt)) {
					/* nameless block */
					insertStmt(syntax, i, 1);
				}
				parseSpecificStmt(tk);
			} else if (tk->stype == SyntaxType::Stmt || tk->stype == SyntaxType::Expr) {
				parseSpecificStmt(tk);
			}
			break;
		}
	}
}

void Parser::setIndent(Token *syntax, int indent)
{
	using namespace SyntaxType;
	size_t tk_n = syntax->token_num;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = syntax->tks[i];
		switch (tk->stype) {
		case BlockStmt:
			tk->finfo.indent = ++indent;
			setIndent(tk, indent);
			if (indent == 0) {
				fprintf(stderr, "ERROR!!: syntax error near %s:%zu\n", tk->finfo.filename, tk->finfo.start_line_num);
				exit(EXIT_FAILURE);
			}
			indent--;
			break;
		case Expr: case Stmt:
			tk->finfo.indent = indent;
			setIndent(tk, indent);
			break;
		default:
			syntax->tks[i]->finfo.indent = indent;
			break;
		}
	}
}

void Parser::setBlockIDWithBreadthFirst(Token *syntax, size_t base_id)
{
	using namespace SyntaxType;
	size_t tk_n = syntax->token_num;
	size_t block_num = 0;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = syntax->tks[i];
		if (tk->stype == BlockStmt) block_num++;
	}
	size_t total_block_num = block_num;
	block_num = 0;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = syntax->tks[i];
		switch (tk->stype) {
		case BlockStmt:
			setBlockIDWithBreadthFirst(tk, base_id + total_block_num + 1);
			block_num++;
			break;
		case Expr: case Stmt:
			setBlockIDWithBreadthFirst(tk, base_id + block_num);
			break;
		default:
			syntax->tks[i]->finfo.block_id = base_id + block_num;
			break;
		}
	}
}

void Parser::setBlockIDWithDepthFirst(Token *syntax, size_t *block_id)
{
	using namespace SyntaxType;
	size_t tk_n = syntax->token_num;
	size_t base_id = *block_id;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = syntax->tks[i];
		switch (tk->stype) {
		case BlockStmt:
			*block_id += 1;
			syntax->tks[i]->finfo.block_id = *block_id;
			setBlockIDWithDepthFirst(tk, block_id);
			break;
		case Expr: case Stmt:
			syntax->tks[i]->finfo.block_id = base_id;
			setBlockIDWithDepthFirst(tk, block_id);
			break;
		default:
			syntax->tks[i]->finfo.block_id = base_id;
			break;
		}
	}
}

void Parser::dumpSyntax(Token *syntax, int indent)
{
	using namespace SyntaxType;
	size_t tk_n = syntax->token_num;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = syntax->tks[i];
		for (int j = 0; j < indent; j++) {
			fprintf(stdout, "-----");
		}
		switch (tk->stype) {
		case Term:
			fprintf(stdout, "Term |\n");
			dumpSyntax(tk, ++indent);
			indent--;
			break;
		case Expr:
			fprintf(stdout, "Expr |\n");
			dumpSyntax(tk, ++indent);
			indent--;
			break;
		case Stmt:
			fprintf(stdout, "Stmt |\n");
			dumpSyntax(tk, ++indent);
			indent--;
			break;
		case BlockStmt:
			fprintf(stdout, "BlockStmt |\n");
			dumpSyntax(tk, ++indent);
			indent--;
			break;
		default:
			fprintf(stdout, "%-12s\n", syntax->tks[i]->info.name);
			break;
		}
	}
}

Tokens *Parser::getTokensBySyntaxLevel(Token *root, SyntaxType::Type type)
{
	Tokens *ret = new Tokens();
	for (size_t i = 0; i < root->token_num; i++) {
		Token **tks = root->tks;
		if (tks[i]->stype == type) {
			ret->push_back(tks[i]);
		}
		if (tks[i]->token_num > 0) {
			Tokens *new_tks = getTokensBySyntaxLevel(tks[i], type);
			ret->insert(ret->end(), new_tks->begin(), new_tks->end());
		}
	}
	return ret;
}

Modules *Parser::getUsedModules(Token *root)
{
	using namespace TokenType;
	Modules *ret = new Modules();
	for (size_t i = 0; i < root->token_num; i++) {
		Token **tks = root->tks;
		if (tks[i]->info.type == UseDecl && i + 1 < root->token_num) {
			const char *module_name = cstr(tks[i+1]->data);
			string args;
			for (i += 2; tks[i]->info.type != SemiColon; i++) {
				args += " " + string(tks[i]->deparse());
			}
			ret->push_back(new Module(module_name, (new string(args))->c_str()));
		}
		if (tks[i]->token_num > 0) {
			Modules *new_mds = getUsedModules(tks[i]);
			ret->insert(ret->end(), new_mds->begin(), new_mds->end());
		}
	}
	return ret;
}

AST *Parser::parse(Tokens *tokens)
{
	if (setjmp(jmp_point) == 0) {
		grouping(tokens);
		replaceHereDocument(tokens);
		Token *root = parseSyntax(NULL, tokens);//Level1
		parseSpecificStmt(root);//Level2
		setIndent(root, 0);
		size_t block_id = 0;
		setBlockIDWithDepthFirst(root, &block_id);
		dumpSyntax(root, 0);
		Completer completer;
		completer.complete(root);
		dumpSyntax(root, 0);
		Node *last_stmt = _parse(root);
		if (!last_stmt) Parser_exception("", 1);
		return new AST(last_stmt->getRoot());
	} else {
		//catched exception
		return new AST(NULL);
	}
}

const char *Parser::deparse(AST *ast)
{
	//TODO : can switch deparser engine
	Deparser deparser;
	return deparser.deparse(ast);
}

Node *Parser::_parse(Token *root)
{
	using namespace SyntaxType;
	ParseContext *pctx = new ParseContext(root);
	if (pctx->end()) {
		parseToken(pctx, root);
	} else {
		for (; !pctx->end(); pctx->next()) {
			Token *tk = pctx->token();
			switch (tk->stype) {
			case BlockStmt: {
				/* Nameless Block */
				cur_stype = BlockStmt;
				Node *stmt = _parse(tk);
				if (stmt && TYPE_match(stmt, HashRefNode)) {
					link(pctx, pctx->lastNode(), stmt);
				} else {
					BlockNode *block = new BlockNode(tk);
					block->body = (stmt) ? stmt->getRoot() : NULL;
					parseStmt(pctx, block);
				}
				break;
			}
			case Stmt: {
				cur_stype = Stmt;
				Node *stmt = _parse(tk);
				parseStmt(pctx, stmt);
				break;
			}
			case Expr: {
				/* Nameless Expr */
				cur_stype = Expr;
				Node *expr = _parse(tk);
				//TODO: wrap expr node
				parseExpr(pctx, expr);
				break;
			}
			case Term: {
				cur_stype = Term;
				Node *term = _parse(tk);
				parseExpr(pctx, term);
				break;
			}
			default:
				parseToken(pctx, tk);
				break;
			}
		}
	}
	Node *node = pctx->lastNode();
	if (pctx->returnToken) {
		ReturnNode *ret = new ReturnNode(pctx->returnToken);
		ret->body = node;
		return ret;
	}
	if (pctx->nodes->size() > 1) {
		assert(pctx->nodes->size() == 2 && "parse error!! nodes too large size");
		node = pctx->nodes->at(0);
		if (TYPE_match(node, LabelNode)) {
			Node *child = pctx->nodes->at(1);
			node->next = child;
			child->parent = node;
			return child;
			//return node->next;
		} else {
			extra_node = pctx->nodes->at(1);
		}
	} else if (node && TYPE_match(node, LabelNode)) {
		Node *child = node->next;
		child->parent = node;
	}
	return node;
}

void Parser::parseToken(ParseContext *pctx, Token *tk)
{
	using namespace TokenKind;
	switch (tk->info.kind) {
	case RegPrefix:
		parseRegPrefix(pctx, tk);
		break;
	case RegReplacePrefix:
		parseRegReplace(pctx, tk);
		break;
	case Decl: case Package:
		DBG_PL("DECL");
		parseDecl(pctx, tk);
		break;
	case Term: case Class:
		DBG_PL("TERM");
		parseTerm(pctx, tk);
		break;
	case Modifier:
		DBG_PL("MODIFIER");
		parseModifier(pctx, tk);
		break;
	case Operator:
	case Assign:
	case Comma:
		DBG_PL("BRANCH");
		parseBranchType(pctx, tk);
		break;
	case SingleTerm:
		parseSingleTermOperator(pctx, tk);
		break;
	case Function: case Namespace:
		DBG_PL("CALL");
		parseFunctionCall(pctx, tk);
		break;
	case Stmt: case Do:
		DBG_PL("STMT");
		parseSpecificStmt(pctx, tk);
		break;
	case Control:
		parseControlStmt(pctx, tk);
		break;
	case Return:
		DBG_PL("RETURN");
		pctx->returnToken = tk;
		break;
	case SpecificKeyword:
		DBG_PL("KEYWORD");
		parseSpecificKeyword(pctx, tk);
		break;
	case Handle:
		DBG_PL("HANDLE");
		parseHandle(pctx, tk);
		break;
	case StmtEnd:
		DBG_PL("STMT_END");
		break;
	case Symbol:
		DBG_PL("SYMBOL");
		parseSymbol(pctx, tk);
		break;
	default:
		DBG_PL("OTHER");
		break;
	}
	//DBG_PL("%s", cstr(tk->data));
}

void Parser::parseStmt(ParseContext *pctx, Node *stmt)
{
	if (!stmt) return;
	Node *prev_stmt = pctx->lastNode();
	if (!prev_stmt) {
		pctx->pushNode(stmt);
		return;
	}
	for (; prev_stmt->next; prev_stmt = prev_stmt->next) {}
	prev_stmt->next = stmt;
	stmt->parent = prev_stmt;
	pctx->nodes->swapLastNode(stmt);
}

void Parser::parseExpr(ParseContext *pctx, Node *expr)
{
	Node *node = pctx->lastNode();
	return (!node) ? pctx->pushNode(expr) : link(pctx, node, expr);
}

void Parser::link(ParseContext *pctx, Node *from_node, Node *to_node)
{
	assert((from_node || to_node) && "link target is NULL");
	if (!from_node) {
		pctx->pushNode(to_node);
	} else if (TYPE_match(from_node, BranchNode)) {
		BranchNode *branch = dynamic_cast<BranchNode *>(from_node);
		if (branch->right) {
			if (TYPE_match(branch->right, FunctionCallNode)) {
				branch->link(to_node);
			} else if (TYPE_match(branch->right, HashRefNode) ||
					   TYPE_match(branch->right, ArrayRefNode)) {
				/* hashref or arrayref chain */
				Token *pointer = new Token("->", pctx->tk->finfo);
				pointer->info.type = TokenType::Pointer;
				pointer->info.name = "Pointer";
				pointer->info.kind = TokenKind::Operator;
				BranchNode *parent = new BranchNode(pointer);
				parent->left = branch;
				parent->right = to_node;
				pctx->nodes->swapLastNode(parent);
			} else {
				pctx->pushNode(to_node);
			}
		} else {
			branch->link(to_node);
		}
	} else if (TYPE_match(from_node, FunctionCallNode)) {
		FunctionCallNode *func = dynamic_cast<FunctionCallNode *>(from_node);
		if (to_node) func->setArgs(to_node);
	} else if (TYPE_match(from_node, ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(from_node);
		if (array->idx) {
			Token *pointer = new Token("->", pctx->tk->finfo);
			pointer->info.type = TokenType::Pointer;
			pointer->info.name = "Pointer";
			pointer->info.kind = TokenKind::Operator;
			BranchNode *branch = new BranchNode(pointer);
			branch->left = from_node;
			branch->right = to_node;
			pctx->nodes->swapLastNode(branch);
		} else {
			array->idx = to_node;
		}
	} else if (TYPE_match(from_node, HashNode)) {
		HashNode *hash = dynamic_cast<HashNode *>(from_node);
		if (hash->key) {
			Token *pointer = new Token("->", pctx->tk->finfo);
			pointer->info.type = TokenType::Pointer;
			pointer->info.name = "Pointer";
			pointer->info.kind = TokenKind::Operator;
			BranchNode *branch = new BranchNode(pointer);
			branch->left = from_node;
			branch->right = to_node;
			pctx->nodes->swapLastNode(branch);
		} else {
			hash->key = to_node;
		}
	} else {
		//assert(0 && "syntax error!\n");
		pctx->pushNode(to_node);
	}
}

void Parser::parseHandle(ParseContext *pctx, Token *tk)
{
	HandleNode *handle = new HandleNode(tk);
	Token *target_tk = pctx->nextToken();
	assert(target_tk && "not declare handle's target");
	handle->expr = new LeafNode(target_tk);
	pctx->next();
	pctx->pushNode(handle);
}

void Parser::parseSymbol(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	if (tk->info.type == LeftParenthesis) {
		Token *next_tk = pctx->nextToken();
		if (next_tk && next_tk->info.kind == TokenKind::Decl) {
			pctx->next();
		}
		Node *node = _parse(pctx->nextToken());
		if (!node) {
			tk->data = "()";
			ListNode *list = new ListNode(tk);
			pctx->pushNode(list);
			for (; !pctx->end(); pctx->next()) {}
		} else if (node->tk->info.type == Comma ||
				   node->tk->info.type == Arrow ||
				   node->tk->info.type == GlobalVar ||
				   node->tk->info.type == Var) {
			tk->data = "()";
			ListNode *list = new ListNode(tk);
			list->data = node;
			pctx->pushNode(list);
			for (; !pctx->end(); pctx->next()) {}
		}
	} else if (tk->info.type == LeftBracket) {
		Node *node = _parse(pctx->nextToken());
		if (!node) {
			tk->data = "[]";
			ArrayRefNode *array = new ArrayRefNode(tk);
			pctx->pushNode(array);
			for (; !pctx->end(); pctx->next()) {}
		} else if (node->tk->info.type == Comma || node->tk->info.type == Arrow) {
			tk->data = "[]";
			ArrayRefNode *array = new ArrayRefNode(tk);
			array->data = node;
			pctx->pushNode(array);
			for (; !pctx->end(); pctx->next()) {}
		} else {
			tk->data = "[]";
			ArrayRefNode *array = new ArrayRefNode(tk);
			array->data = node;
			pctx->pushNode(array);
		}
	} else if (tk->info.type == LeftBrace) {
		SyntaxType::Type parent_stype = cur_stype;
		Node *node = _parse(pctx->nextToken());
		if (parent_stype == SyntaxType::BlockStmt) return;
		if (!node) {
			tk->data = "{}";
			HashRefNode *hash = new HashRefNode(tk);
			pctx->pushNode(hash);
			for (; !pctx->end(); pctx->next()) {}
		} else if (node->tk->info.type == Comma || node->tk->info.type == Arrow ||
				   node->tk->info.type == GlobalVar || node->tk->info.type == Var ||
				   node->tk->info.type == Key) {
			tk->data = "{}";
			HashRefNode *hash = new HashRefNode(tk);
			hash->data = node;
			pctx->pushNode(hash);
			for (; !pctx->end(); pctx->next()) {}
		} else if (parent_stype == SyntaxType::Expr) {
			tk->data = "{}";
			HashRefNode *hash = new HashRefNode(tk);
			hash->data = node;
			pctx->pushNode(hash);
			for (; !pctx->end(); pctx->next()) {
				if (pctx->token()->info.type == TokenType::RightBrace) break;
			}
			if (!pctx->end() && pctx->nextToken()) {
				extra_node = _parse(pctx->nextToken());
			}
		}
	}
}

void Parser::parseRegPrefix(ParseContext *pctx, Token *tk)
{
	RegPrefixNode *reg = new RegPrefixNode(tk);
	Token *start_delim = pctx->nextToken();
	assert(start_delim && start_delim->info.type == TokenType::RegDelim && "not regex like delimiter");
	pctx->next();
	Token *exp = pctx->nextToken();
	pctx->next();
	assert(exp && "not regex like expr");
	Token *end_delim = pctx->nextToken();
	assert(end_delim && end_delim->info.type == TokenType::RegDelim && "not regex like delimiter");
	pctx->next();
	LeafNode *leaf = new LeafNode(exp);
	reg->exp = leaf;
	Token *option = pctx->nextToken();
	if (option) {
		reg->option = new LeafNode(option);
		pctx->next();
	}
	BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
	return (!node) ? pctx->pushNode(reg) : node->link(reg);
}

void Parser::parseRegReplace(ParseContext *pctx, Token *tk)
{
	RegReplaceNode *replace = new RegReplaceNode(tk);
	Token *start_delim = pctx->nextToken();
	if (!(start_delim && start_delim->info.type == TokenType::RegDelim)) {
		Parser_exception("not start delimiter", tk->finfo.start_line_num);
	}
	pctx->next();
	Token *replace_from = pctx->nextToken();
	if (!(replace_from && replace_from->info.type == TokenType::RegReplaceFrom)) {
		Parser_exception("replace expression", tk->finfo.start_line_num);
	} else {
		replace->from = new LeafNode(replace_from);
	}
	pctx->next();
	Token *middle_delim = pctx->nextToken();
	if (!(middle_delim && middle_delim->info.type == TokenType::RegMiddleDelim)) {
		Parser_exception("replace expression", tk->finfo.start_line_num);
	}
	pctx->next();
	Token *replace_to = pctx->nextToken();
	if (!(replace_to && replace_to->info.type == TokenType::RegReplaceTo)) {
		Parser_exception("replace expression", tk->finfo.start_line_num);
	} else {
		replace->to = new LeafNode(replace_to);
	}
	pctx->next();
	Token *end_delim = pctx->nextToken();
	if (!(replace_to && replace_to->info.type == TokenType::RegReplaceTo)) {
		Parser_exception("not end delimiter", tk->finfo.start_line_num);
	}
	pctx->next();
	Token *option = pctx->nextToken();
	if (option) {
		replace->option = new LeafNode(option);
		pctx->next();
	}
	BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
	return (!node) ? pctx->pushNode(replace) : node->link(replace);
}

void Parser::parseDecl(ParseContext *pctx, Token *tk)
{
	switch (tk->info.type) {
	case TokenType::Package: {
		Token *next_tk = pctx->nextToken();
		assert(next_tk && "syntax error!: near by package decl\n");
		pctx->next();
		DBG_PL("PACKAGE");
		PackageNode *p = new PackageNode(next_tk);
		pctx->next();
		assert(!pctx->lastNode() && "parse error!: already exists node");
		pctx->pushNode(p);
		break;
	}
	case TokenType::UseDecl: case TokenType::RequireDecl: {
		Token *next_tk = pctx->nextToken();
		assert(next_tk && "syntax error!: near by require/use decl\n");
		pctx->next();
		DBG_PL("MODULE");
		parseModule(pctx, next_tk);
		break;
	}
	case TokenType::FunctionDecl: {
		cur_stype = SyntaxType::Value;
		Token *next_tk = pctx->nextToken();
		assert(next_tk && "syntax error!: near by function decl\n");
		pctx->next();
		DBG_PL("FUNCTION");
		parseFunction(pctx, next_tk);
		break;
	}
	default:
		break;
	}
}

void Parser::parseSpecificKeyword(ParseContext *pctx, Token *tk)
{
	if (tk->data == "__PACKAGE__") {
		/* like Namespace */
		return parseTerm(pctx, tk);
	}
}

bool Parser::isForeach(ParseContext *pctx, Token *tk)
{
	if (!tk) return false;
	if (tk->info.type == TokenType::VarDecl ||
		tk->info.type == TokenType::Var ||
		tk->info.type == TokenType::GlobalVar) return true;
	bool ret = true;
	for (size_t i = 0; i < tk->token_num; i++) {
		if (tk->tks[i]->stype == SyntaxType::Stmt) {
			ret = false;
			break;
		}
	}
	return ret;
}

void Parser::parseControlStmt(ParseContext *pctx, Token *tk)
{
	pctx->pushNode(new ControlStmtNode(tk));
}

void Parser::parseSpecificStmt(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	switch (tk->info.type) {
	case TokenType::Do: {
		DoStmtNode *do_stmt = new DoStmtNode(tk);
		Token *next_tk = pctx->nextToken();
		if (!next_tk) Parser_exception("near by do statement", tk->finfo.start_line_num);
		Node *stmt = _parse(next_tk);
		do_stmt->stmt = (stmt) ? stmt->getRoot() : NULL;
		pctx->pushNode(do_stmt);
		pctx->next();
		break;
	}
	case TokenType::IfStmt:
	case TokenType::UnlessStmt: {
		IfStmtNode *if_stmt = new IfStmtNode(tk);
		pctx->pushNode(if_stmt);
		_prev_stmt = if_stmt;
		Node *expr_node = _parse(pctx->token(tk, 1))->getRoot();
		cur_stype = SyntaxType::Value;
		Token *block_or_stmt_end_node = pctx->token(tk, 2);
		if (block_or_stmt_end_node->info.type != TokenType::SemiColon) {
			Node *block_node = _parse(pctx->token(tk, 2));
			if_stmt->true_stmt = (block_node) ? block_node->getRoot() : NULL;
		} else {
			if (pctx->nodes->size() == 1 && pctx->returnToken) {
				ReturnNode *ret = new ReturnNode(pctx->returnToken);
				Nodes *nodes = pctx->nodes;
				nodes->insert(nodes->begin(), ret);
				pctx->returnToken = NULL;
			}
			assert(pctx->nodes->size() == 2 && "syntax error! near by postposition if statement");
			Node *true_stmt_node = pctx->nodes->at(0);
			if_stmt->true_stmt = true_stmt_node;
			pctx->nodes->clear();
			pctx->pushNode(if_stmt);
		}
		if_stmt->expr = expr_node;
		pctx->next(2);
		break;
	}
	case TokenType::ElsifStmt: {
		IfStmtNode *if_stmt = new IfStmtNode(tk);
		IfStmtNode *node = dynamic_cast<IfStmtNode *>(_prev_stmt);
		node->false_stmt = if_stmt->getRoot();
		_prev_stmt = if_stmt;
		Node *expr_node = _parse(pctx->token(tk, 1))->getRoot();
		cur_stype = SyntaxType::Value;
		Node *block_node = _parse(pctx->token(tk, 2));
		if_stmt->expr = expr_node;
		if_stmt->true_stmt = (block_node) ? block_node->getRoot() : NULL;
		pctx->next(2);
		break;
	}
	case TokenType::ElseStmt: {
		IfStmtNode *if_stmt_node = dynamic_cast<IfStmtNode *>(_prev_stmt);
		Token *block_stmt_tk = pctx->token(tk, 1);
		Node *block_stmt_node = _parse(block_stmt_tk);
		ElseStmtNode *else_stmt = new ElseStmtNode(tk);
		else_stmt->stmt = block_stmt_node->getRoot();
		_prev_stmt = NULL;
		if_stmt_node->false_stmt = else_stmt->getRoot();
		pctx->next();
		break;
	}
	case TokenType::ForStmt: {
		Token *next_tk = pctx->nextToken();
		if (isForeach(pctx, next_tk)) {
			//fall through (foreach stmt)
		}  else {
			ForStmtNode *for_stmt = new ForStmtNode(tk);
			Node *expr_node = _parse(pctx->token(tk, 1));
			for_stmt->setExpr(expr_node->getRoot());
			cur_stype = SyntaxType::Value;
			Node *block_stmt_node = _parse(pctx->token(tk, 2));
			for_stmt->true_stmt = block_stmt_node->getRoot();
			pctx->pushNode(for_stmt);
			pctx->next(2);
			break;
		}
	}
	case TokenType::ForeachStmt: {
		ForeachStmtNode *foreach_stmt = new ForeachStmtNode(tk);
		Token *next_tk = pctx->nextToken();
		size_t idx = 1;
		Node *itr = (next_tk->info.type == TokenType::VarDecl) ?
			new LeafNode(pctx->token(tk, ++idx)) : (next_tk->info.type == TokenType::GlobalVar) ?
			new LeafNode(pctx->token(tk, idx)) : NULL;
		if (!itr) --idx;
		Node *expr_node = _parse(pctx->token(tk, ++idx));
		foreach_stmt->itr = itr;
		foreach_stmt->cond = expr_node->getRoot();
		cur_stype = SyntaxType::Value;
		Node *block_stmt_node = _parse(pctx->token(tk, ++idx));
		foreach_stmt->true_stmt = block_stmt_node->getRoot();
		pctx->pushNode(foreach_stmt);
		pctx->next(idx);
		break;
	}
	case TokenType::UntilStmt: case TokenType::WhileStmt: {
		WhileStmtNode *while_stmt = new WhileStmtNode(tk);
		Node *expr_node = _parse(pctx->token(tk, 1));
		while_stmt->expr = expr_node->getRoot();
		cur_stype = SyntaxType::Value;
		Token *block_or_stmt_end_node = pctx->token(tk, 2);
		if (block_or_stmt_end_node->info.type != TokenType::SemiColon) {
			Node *block_node = _parse(pctx->token(tk, 2));
			while_stmt->true_stmt = (block_node) ? block_node->getRoot() : NULL;
			pctx->pushNode(while_stmt);
		} else {
			Node *node = pctx->nodes->at(0);
			LabelNode *label = dynamic_cast<LabelNode *>(node);
			assert((pctx->nodes->size() == 1 || (label && pctx->nodes->size() == 2)) && "syntax error! near by postposition if statement");
			if (label) {
				Node *true_stmt_node = pctx->nodes->at(1);
				while_stmt->true_stmt = true_stmt_node;
				label->next = while_stmt;
				pctx->nodes->clear();
				pctx->pushNode(label);
			} else {
				Node *true_stmt_node = pctx->nodes->at(0);
				while_stmt->true_stmt = true_stmt_node;
				pctx->nodes->clear();
				pctx->pushNode(while_stmt);
			}
		}
		pctx->next(2);
		break;
	}
	default:
		break;
	}
}

void Parser::parseSingleTermOperator(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	TokenType::Type type = tk->info.type;
	SingleTermOperatorNode *op_node = NULL;
	if ((type == IsNot || type == Ref || type == Add || type == BitAnd ||
		 type == ArraySize || type == Sub || type == CodeRef ||
		 type == BitNot || type == Glob) ||
		((type == Inc || type == Dec) && pctx->idx == 0)) {
		Token *next_tk = pctx->token(tk, 1);
		assert(next_tk && "syntax error near by single term operator");
		op_node = new SingleTermOperatorNode(tk);
		if (next_tk->info.kind == TokenKind::Function) {
			FunctionCallNode *func = new FunctionCallNode(next_tk);
			Token *next_after_tk = pctx->nullableToken(tk, 2);
			if (next_after_tk) {
				Node *expr = _parse(next_after_tk);
				if (expr) func->setArgs(expr);
				pctx->next();
			}
			op_node->expr = func;
		} else if ((type == CodeRef || type == Ref) && next_tk->info.type == CallDecl) {
			Token *next_after_tk = pctx->token(tk, 2);
			assert(next_after_tk && "syntax error near by coderef");
			Node *sub = _parse(next_after_tk);
			op_node->tk->data = "\\&";
			op_node->tk->info.type = TokenType::CodeRef;
			op_node->expr = sub;
			pctx->next();
		} else {
			Node *node = _parse(next_tk);
			assert(node && "syntax error near by single term operator");
			op_node->expr = node->getRoot();
		}
		pctx->next();
		pctx->pushNode(op_node);
	} else if (type == Inc || type == Dec) {
		Node *node = pctx->lastNode();
		op_node = new SingleTermOperatorNode(tk);
		op_node->expr = node;
		pctx->nodes->swapLastNode(op_node);
	}
	assert(op_node && "syntax error!");
}

bool Parser::isSingleTermOperator(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	TokenType::Type type = tk->info.type;
	if (type == IsNot || type == Ref || type == CodeRef || type == Inc || type == ArraySize || type == Glob ||
		type == Dec   || type == BitNot) return true;
	if ((type == Add || type == Sub || type == BitAnd) && pctx->idx == 0) return true;
	return false;
}

void Parser::parseThreeTermOperator(ParseContext *pctx, Token *tk)
{
	ThreeTermOperatorNode *term = new ThreeTermOperatorNode(tk);
	Node *cond = pctx->nodes->lastNode();
	if (!cond) Parser_exception("nothing expr neary by ThreeTermOperator", tk->finfo.start_line_num);
	pctx->nodes->pop_back();
	Node *true_expr = _parse(pctx->nextToken());
	pctx->next();
	pctx->next();
	Node *false_expr = _parse(pctx->nextToken());
	pctx->next();
	term->cond = cond;
	term->true_expr = true_expr;
	term->false_expr = false_expr;
	Node *node = pctx->lastNode();
	return (!node) ? pctx->pushNode(term) : link(pctx, node, term);
}

void Parser::parseBranchType(ParseContext *pctx, Token *tk)
{
	if (isSingleTermOperator(pctx, tk)) {
		parseSingleTermOperator(pctx, tk);
	} else if (tk->info.type == TokenType::ThreeTermOperator) {
		parseThreeTermOperator(pctx, tk);
	} else {
		Node *node = pctx->lastNode();
		if (!node && tk->info.type == TokenType::PolymorphicCompare) {
			//~~term => [~] + [~] + [term] <=> [term]
			Token *next_tk = pctx->nextToken();
			if (!next_tk) return;
			Node *node = new LeafNode(next_tk);
			pctx->pushNode(node);
			pctx->next();
		} else {
			assert(node && "syntax error!: nothing value before xxx");
			BranchNode *branch = new BranchNode(tk);
			branch->left = node;
			node->parent = branch;
			pctx->nodes->swapLastNode(branch);
		}
	}
}

void Parser::parseFunction(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	FunctionNode *f = new FunctionNode(tk);
	Token *next_tk = pctx->nextToken();
	if ((tk->info.type == TokenType::Function || tk->info.type == TokenType::Namespace) &&
		next_tk && next_tk->stype == Expr) {
		/* sub name () {} */
		Token *after_next_tk = pctx->token(tk, 2);
		assert(after_next_tk && after_next_tk->stype == BlockStmt && "syntax error! near by prototype");
		Node *prototype_node = _parse(next_tk);
		Node *block_stmt_node = _parse(after_next_tk);
		f->prototype = (prototype_node) ? prototype_node->getRoot() : NULL;
		f->body = (block_stmt_node) ? block_stmt_node->getRoot() : NULL;
		pctx->next();
		pctx->next();
	} else if (tk->stype == BlockStmt) {
		/* sub {} */
		Node *block_stmt_node = _parse(tk);
		f->body = (block_stmt_node) ? block_stmt_node->getRoot() : NULL;
		tk->data = "sub";
		pctx->next();
	} else if ((tk->info.type == TokenType::Function || tk->info.type == TokenType::Namespace) &&
		next_tk && next_tk->stype == BlockStmt) {
		/* sub name {} */
		SyntaxType::Type stype = cur_stype;
		cur_stype = BlockStmt;
		Node *block_stmt_node = _parse(pctx->nextToken());
		cur_stype = stype;
		f->body = (block_stmt_node) ? block_stmt_node->getRoot() : NULL;
		pctx->next();
	} else {
		assert(0 && "syntax error! near by sub declare");
	}
	BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
	return (!node) ? pctx->pushNode(f) : node->link(f);
}

void Parser::parseModule(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	ModuleNode *m = new ModuleNode(tk);
	Token *next_tk = pctx->nextToken();
	if (next_tk && next_tk->info.kind != TokenKind::StmtEnd) {
		parseModuleArgument(pctx, next_tk);
		Node *args = pctx->lastNode();
		if (args) {
			m->args = args->getRoot();
			pctx->nodes->pop_back();
		}
	}
	pctx->next();
	assert(!pctx->lastNode() && "parse error!: already exists node");
	pctx->pushNode(m);
}

void Parser::parseModuleArgument(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	Node *node = NULL;
	TokenType::Type type = tk->info.type;
	if (tk->stype == SyntaxType::Expr) {
		node = _parse(tk);
	} else if (type == String || type == RawString || type == VersionString ||
			   type == Int || type == Double) {
		node = new LeafNode(tk);
	}
	if (node) pctx->pushNode(node);
	pctx->next();
}

void Parser::parseFunctionCall(ParseContext *pctx, Token *tk)
{
	Token *next_tk = pctx->nextToken();
	if (tk->info.type == TokenType::Namespace &&
		next_tk && next_tk->info.type == TokenType::Pointer) {
		/* Name::Space->method() */
		return parseTerm(pctx, tk);
	}
	if (isIrregularFunction(pctx, tk)) {
		parseIrregularFunction(pctx, tk);
	} else {
		FunctionCallNode *f = new FunctionCallNode(tk);
		BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
		TokenType::Type type = tk->info.type;
//		if (type == TokenType::Method ||
//			type == TokenType::Namespace /* Static Method Invocation */
//		) pctx->pushNode(f);
		return (!node) ? pctx->pushNode(f) : node->link(f);
	}
}

bool Parser::isIrregularFunction(ParseContext *, Token *tk)
{
	if (tk->info.type == TokenType::Method) return false;
	if (tk->data == "map" || tk->data == "grep") return true;
	return false;
}

void Parser::parseIrregularFunction(ParseContext *pctx, Token *tk)
{
	FunctionCallNode *f = new FunctionCallNode(tk);
	Token *next_tk = pctx->nextToken();
	Node *block_node = _parse(next_tk);
	pctx->next();
	assert(block_node && "syntax error near by irregular function");
	f->setArgs(block_node->getRoot());
	if (extra_node) f->setArgs(extra_node);
	extra_node = NULL;
	BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
	return (!node) ? pctx->pushNode(f) : node->link(f);
}

void Parser::parseModifier(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	Token *next_tk = pctx->nextToken();
	//assert(next_tk && "syntax error! near by dereference operator");
	DereferenceNode *dref = new DereferenceNode(tk);
	if (next_tk && (next_tk->stype == Expr || next_tk->stype == Term || next_tk->info.kind == TokenKind::Term)) {
		dref->expr = _parse(next_tk);
	} else {
		dref->expr = new LeafNode(tk);
	}
	Node *node = pctx->lastNode();
	return (!node) ? pctx->pushNode(dref) : link(pctx, node, dref);
}

void Parser::parseTerm(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	Token *next_tk = pctx->nextToken();
	Node *term = NULL;
	if (next_tk && next_tk->stype == Expr) {
		if (next_tk->tks[0]->info.type == TokenType::LeftBracket) {
			term = new ArrayNode(tk);
		} else if (next_tk->tks[0]->info.type == TokenType::LeftBrace) {
			term = new HashNode(tk);
		} else {
			term = _parse(next_tk);
		}
	} else if (next_tk && next_tk->info.type == TokenType::RegExp) {
		pctx->next();
		RegexpNode *reg = new RegexpNode(next_tk);
		if (pctx->nextToken()->info.type != TokenType::RegDelim) Parser_exception("near by regexp", tk->finfo.start_line_num);
		pctx->next();
		Token *option = pctx->nextToken();
		if (option) {
			reg->option = new LeafNode(option);
			pctx->next();
		}
		term = reg;
	} else if (next_tk && next_tk->info.type == TokenType::Colon) {
		//LABEL:
		pctx->next();
		term = new LabelNode(tk);
	} else if (tk->info.type == TokenType::HandleDelim) {
		//<$fh>
		Token *handle_name = pctx->nextToken();
		pctx->next();
		term = new HandleReadNode(handle_name);
		Token *handle_end_delimiter = pctx->nextToken();
		if (!handle_end_delimiter ||
			handle_end_delimiter->info.type != TokenType::HandleDelim) {
			Parser_exception("", handle_name->finfo.start_line_num);
		}
		pctx->next();
	} else {
		term = new LeafNode(tk);
	}
	assert(term && "syntax error!: near by term");
	Node *node = pctx->lastNode();
	return (!node) ? pctx->pushNode(term) : link(pctx, node, term);
}
