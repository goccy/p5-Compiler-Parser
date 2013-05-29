#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace TokenKind = Enum::Token::Kind;
namespace SyntaxType = Enum::Parser::Syntax;

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
				next_tk = ITER_CAST(Token *, pos);
			} while ((tk->info.type == NamespaceResolver &&
					 (next_tk && next_tk->info.kind != TokenKind::Symbol &&
					  next_tk->info.kind != TokenKind::StmtEnd)) ||
					 (next_tk && next_tk->info.type == NamespaceResolver));
			TokenPos end_pos = pos;
			pos -= move_count;
			ns_token->data = ns;
			ns_token->info.has_warnings = true;
			ns = "";
			tokens->erase(start_pos, end_pos);
			break;
		}
		case ArraySize: {
			Token *as_token = tk;
			Token *next_tk = ITER_CAST(Token *, pos+1);
			TokenType::Type type = next_tk->info.type;
			if (type == Key || type == Var || type == GlobalVar) {
				as_token->data += next_tk->data;
				tokens->erase(pos+1);
			}
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

void Parser::prepare(Tokens *tokens)
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
				fprintf(stderr, "ERROR!: nothing use HereDocumentTag\n");
				exit(EXIT_FAILURE);
			} else {
				Token *tag = ITER_CAST(Token *, tag_pos);
				switch (tag->info.type) {
				case TokenType::HereDocumentTag:
					tag->info = getTokenInfo(TokenType::RegDoubleQuote);
					tag->data = "qq{" + t->data + "}";
					break;
				case TokenType::HereDocumentRawTag:
					tag->info = getTokenInfo(TokenType::RegQuote);//RawString);
					tag->data = "q{" + t->data + "}";
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
	assert(tk->tks[0]->info.type == LeftBrace);
	if (tk->token_num > 3 &&
		(tk->tks[1]->info.type == Key   || tk->tks[1]->info.type == String) &&
		(tk->tks[2]->info.type == Arrow || tk->tks[2]->info.type == Comma)) {
		/* { [key|"key"] [,|=>] value ... */
		return true;
	} else if (type == Pointer || type == Mul || kind == TokenKind::Term || kind == TokenKind::Function ||/* type == FunctionDecl ||*/
			((prev_tk && prev_tk->stype == SyntaxType::Expr) && (type == RightBrace || type == RightBracket))) {
		/* ->{ or $hash{ or map { or {key}{ or [idx]{ */
		return true;
	}
	return false;
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
		case ArrayDereference: case HashDereference: case ScalarDereference:
		case ArraySizeDereference: {
			pos++;
			Token *syntax = parseSyntax(t, tokens);
			syntax->stype = SyntaxType::Expr;
			new_tokens->push_back(syntax);
			prev_syntax = syntax;
			break;
		}
		case LeftBrace: {
			Token *prev = ITER_CAST(Token *, pos-1);
			if (prev) prev_type = prev->info.type;
			pos++;
			Token *syntax = parseSyntax(t, tokens);
			if (isExpr(syntax, prev_syntax, prev_type, prev_kind)) {
				syntax->stype = SyntaxType::Expr;
			} else if (prev_type == FunctionDecl) {
				/* LeftBrace is Expr but assign stype of BlockStmt */
				syntax->stype = SyntaxType::BlockStmt;
			} else if (prev_kind == TokenKind::Do) {
				syntax->stype = SyntaxType::BlockStmt;
			} else {
				syntax->stype = SyntaxType::BlockStmt;
				if (pos+1 != tokens->end()) {
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
		case RightBrace: case RightBracket: case RightParenthesis:
			new_tokens->push_back(t);
			return new Token(new_tokens);
			break; /* not reached this stmt */
		case SemiColon: {
			size_t k = pos - intermediate_pos;
			if (start_pos == intermediate_pos) k++;
			Tokens *stmt = new Tokens();
			for (size_t j = 0; j < k - 1; j++) {
				Token *tk = new_tokens->back();
				j += (tk->total_token_num > 0) ? tk->total_token_num - 1 : 0;
				stmt->insert(stmt->begin(), tk);
				new_tokens->pop_back();
			}
			stmt->push_back(t);
			Token *stmt_ = new Token(stmt);
			stmt_->stype = SyntaxType::Stmt;
			new_tokens->push_back(stmt_);
			intermediate_pos = pos;
			prev_syntax = stmt_;
			break;
		}
		default:
			new_tokens->push_back(t);
			prev_syntax = NULL;
			break;
		}
		prev_kind = kind;
		prev_type = type;
		pos++;
	}
	return new Token(new_tokens);
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
				if (expr->token_num > 3 && tk->info.type == ForStmt &&
					expr->tks[1]->stype == SyntaxType::Stmt &&
					expr->tks[2]->stype == SyntaxType::Stmt &&
					expr->tks[3]->stype != SyntaxType::Stmt &&
					expr->tks[3]->info.type != RightParenthesis) {
					insertStmt(expr, 3, expr->token_num - 4);
				}
				insertStmt(syntax, i, 3);
				tk_n -= 2;
				parseSpecificStmt(tks[i]->tks[2]);
				//i += 2;
			} else if ((tk->info.type == ForStmt || tk->info.type == ForeachStmt) &&
					   tk_n > i+3 && tks[i+1]->stype != SyntaxType::Expr) {
				/* for(each) [decl] Term Expr BlockStmt */
				if (tk_n > i+3 &&
					tks[i+1]->info.kind == TokenKind::Term &&
					tks[i+2]->stype == SyntaxType::Expr &&
					tks[i+3]->stype == SyntaxType::BlockStmt) {
					insertStmt(syntax, i, 4);
					tk_n -= 3;
					parseSpecificStmt(tks[i]->tks[3]);
					//i += 3;
				} else if (tk_n > i+4 &&
					tks[i+1]->info.kind == TokenKind::Decl &&
					tks[i+2]->info.kind == TokenKind::Term &&
					tks[i+3]->stype == SyntaxType::Expr &&
					tks[i+4]->stype == SyntaxType::BlockStmt) {
					insertStmt(syntax, i, 5);
					tk_n -= 4;
					parseSpecificStmt(tks[i]->tks[4]);
					//i += 4;
				} else {
					//fprintf(stderr, "Syntax Error!: near by line[%lu]\n", tk->finfo.start_line_num);
					//exit(EXIT_FAILURE);
				}
			}
			break;
		}
		case ElseStmt: case Do: case Continue: case DefaultStmt:
			if (tk_n > i+1 &&
				tks[i+1]->stype == SyntaxType::BlockStmt) {
				/* else BlockStmt */
				insertStmt(syntax, i, 2);
				tk_n -= 1;
				parseSpecificStmt(tks[i]->tks[1]);
				//i += 1;
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
				tks[i+1]->info.type == Function &&
				tks[i+2]->stype == SyntaxType::BlockStmt) {
				/* sub func BlockStmt */
				insertStmt(syntax, i, 3);
				tk_n -= 2;
				parseSpecificStmt(tks[i]->tks[2]);
			} else if (tk_n > i+3 &&
				tks[i+1]->info.type == Function &&
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
				fprintf(stderr, "ERROR!!: syntax error near %s:%lu\n", tk->finfo.filename, tk->finfo.start_line_num);
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
			fprintf(stdout, "----------------");
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
	grouping(tokens);
	prepare(tokens);
	for (size_t i = 0; i < tokens->size(); i++) {
		Token *t = tokens->at(i);
		//fprintf(stdout, "[%-12s] : %12s \n", cstr(t->data), t->info.name);
	}
	Token *root = parseSyntax(NULL, tokens);//Level1
	parseSpecificStmt(root);//Level2
	setIndent(root, 0);
	size_t block_id = 0;
	setBlockIDWithDepthFirst(root, &block_id);
	//dumpSyntax(root, 0);
	Completer completer;
	completer.complete(root);
	//dumpSyntax(root, 0);
	Node *last_stmt = _parse(root);
	return new AST(last_stmt->getRoot());
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
				Node *stmt = _parse(tk);
				BlockNode *block = new BlockNode(tk);
				block->body = stmt->getRoot();
				parseStmt(pctx, block);
				break;
			}
			case Stmt: {
				Node *stmt = _parse(tk);
				parseStmt(pctx, stmt);
				break;
			}
			case Expr: {
				/* Nameless Expr */
				Node *expr = _parse(tk);
				//TODO: wrap expr node
				parseExpr(pctx, expr);
				break;
			}
			case Term: {
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
		extra_node = pctx->nodes->at(1);
	}
	return node;
}

void Parser::parseToken(ParseContext *pctx, Token *tk)
{
	using namespace TokenKind;
	switch (tk->info.kind) {
	case RegPrefix:
		//assert(0 && "TODO: RegPrefix parse");
		parseRegPrefix(pctx, tk);
		break;
	case Decl: case Package:
		DBG_PL("DECL");
		parseDecl(pctx, tk);
		break;
	case Term:
	case Modifier:
		DBG_PL("TERM");
		parseTerm(pctx, tk);
		break;
	case Operator:
	case Assign:
	case Comma:
		DBG_PL("BRANCH");
		parseBranchType(pctx, tk);
		break;
	case Function: case Namespace:
		DBG_PL("CALL");
		parseFunctionCall(pctx, tk);
		break;
	case Stmt:
		DBG_PL("STMT");
		parseSpecificStmt(pctx, tk);
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
		break;
	case StmtEnd:
		DBG_PL("STMT_END");
		break;
	case Symbol:
		DBG_PL("SYMBOL");
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
	if (TYPE_match(from_node, BranchNode)) {
		BranchNode *branch = dynamic_cast<BranchNode *>(from_node);
		if (branch->right) pctx->pushNode(to_node);
		else branch->link(to_node);
	} else if (TYPE_match(from_node, FunctionCallNode)) {
		FunctionCallNode *func = dynamic_cast<FunctionCallNode *>(from_node);
		if (to_node) func->setArgs(to_node);
	} else if (TYPE_match(from_node, ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(from_node);
		array->idx = to_node;
	} else if (TYPE_match(from_node, HashNode)) {
		HashNode *hash = dynamic_cast<HashNode *>(from_node);
		hash->key = to_node;
	} else {
		//assert(0 && "syntax error!\n");
		pctx->pushNode(to_node);
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
	BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
	return (!node) ? pctx->pushNode(reg) : node->link(reg);
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

void Parser::parseSpecificStmt(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	switch (tk->info.type) {
	case TokenType::IfStmt:
	case TokenType::UnlessStmt: {
		IfStmtNode *if_stmt = new IfStmtNode(tk);
		pctx->pushNode(if_stmt);
		_prev_stmt = if_stmt;
		Node *expr_node = _parse(pctx->token(tk, 1))->getRoot();
		Token *block_or_stmt_end_node = pctx->token(tk, 2);
		if (block_or_stmt_end_node->info.type != TokenType::SemiColon) {
			Node *block_node = _parse(pctx->token(tk, 2));
			if_stmt->true_stmt = (block_node) ? block_node->getRoot() : NULL;
		} else {
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
		if_stmt_node->false_stmt = else_stmt->getRoot();
		pctx->next();
		break;
	}
	case TokenType::ForStmt: {
		Token *next_tk = pctx->nextToken();
		if (next_tk &&
			(next_tk->info.type == TokenType::VarDecl ||
			 next_tk->info.type == TokenType::Var ||
			 next_tk->info.type == TokenType::GlobalVar)) {
			//fall through (foreach stmt)
		} else {
			ForStmtNode *for_stmt = new ForStmtNode(tk);
			Node *expr_node = _parse(pctx->token(tk, 1));
			for_stmt->setExpr(expr_node->getRoot());
			Node *block_stmt_node = _parse(pctx->token(tk, 2));
			for_stmt->true_stmt = block_stmt_node->getRoot();
			_prev_stmt = for_stmt;
			pctx->pushNode(for_stmt);
			pctx->next(2);
			break;
		}
	}
	case TokenType::ForeachStmt: {
		ForeachStmtNode *foreach_stmt = new ForeachStmtNode(tk);
		Token *next_tk = pctx->nextToken();
		size_t idx = 1;
		Node *itr = (next_tk->info.type == TokenType::VarDecl) ? new LeafNode(pctx->token(tk, ++idx)) : NULL;
		Node *expr_node = _parse(pctx->token(tk, ++idx));
		foreach_stmt->itr = itr;
		foreach_stmt->cond = expr_node->getRoot();
		Node *block_stmt_node = _parse(pctx->token(tk, ++idx));
		foreach_stmt->true_stmt = block_stmt_node->getRoot();
		_prev_stmt = foreach_stmt;
		pctx->pushNode(foreach_stmt);
		pctx->next(idx);
		break;
	}
	case TokenType::WhileStmt:
		break;
	default:
		break;
	}
}

void Parser::parseSingleTermOperator(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	Token *next_tk = pctx->token(tk, 1);
	TokenType::Type type = tk->info.type;
	SingleTermOperatorNode *op_node = NULL;
	if ((type == IsNot || type == Ref || type == Add ||
		 type == Sub   || type == BitNot) ||
		((type == Inc || type == Dec) && pctx->idx == 0)) {
		assert(next_tk && "syntax error near by single term operator");
		op_node = new SingleTermOperatorNode(tk);
		if (next_tk->info.kind == TokenKind::Function) {
			FunctionCallNode *func = new FunctionCallNode(next_tk);
			Token *next_after_tk = pctx->token(tk, 2);
			if (next_after_tk) {
				Node *expr = _parse(next_after_tk);
				if (expr) func->setArgs(expr);
				pctx->next();
			}
			op_node->expr = func;
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
	if (type == IsNot || type == Ref || type == Inc ||
		type == Dec   || type == BitNot) return true;
	if ((type == Add || type == Sub) && pctx->idx == 0) return true;
	return false;
}

void Parser::parseBranchType(ParseContext *pctx, Token *tk)
{
	if (isSingleTermOperator(pctx, tk)) {
		parseSingleTermOperator(pctx, tk);
	} else {
		Node *node = pctx->lastNode();
		assert(node && "syntax error!: nothing value before xxx");
		BranchNode *branch = new BranchNode(tk);
		branch->left = node;
		node->parent = branch;
		pctx->nodes->swapLastNode(branch);
	}
}

void Parser::parseFunction(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	FunctionNode *f = new FunctionNode(tk);
	Node *block_stmt_node = (tk->stype == BlockStmt) ? _parse(tk) : _parse(pctx->nextToken());
	f->body = block_stmt_node->getRoot();
	pctx->next();
	BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
	return (!node) ? pctx->pushNode(f) : node->link(f);
}

void Parser::parseModule(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	ModuleNode *m = new ModuleNode(tk);
	Token *next_tk = pctx->nextToken();
	if (next_tk->info.kind != TokenKind::StmtEnd) {
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
	Node *node = NULL;
	TokenType::Type type = tk->info.type;
	if (tk->stype == SyntaxType::Expr) {
		node = _parse(tk);
	} else if (type == TokenType::String || type == TokenType::RawString) {
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
		if (type == TokenType::Method ||
			type == TokenType::Namespace /* Static Method Invocation */
		) pctx->pushNode(f);
		return (!node) ? pctx->pushNode(f) : node->link(f);
	}
}

bool Parser::isIrregularFunction(ParseContext *, Token *tk)
{
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
	} else {
		term = new LeafNode(tk);
	}
	assert(term && "syntax error!: near by term");
	Node *node = pctx->lastNode();
	return (!node) ? pctx->pushNode(term) : link(pctx, node, term);
}
