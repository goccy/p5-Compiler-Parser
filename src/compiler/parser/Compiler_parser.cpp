#include <lexer.hpp>
#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Lexer::Token;
namespace SyntaxType = Enum::Lexer::Syntax;
namespace TokenKind = Enum::Lexer;

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

AST *Parser::parse(Token *root)
{
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
	case Decl:
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
	case Function:
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

void Parser::parseDecl(ParseContext *pctx, Token *tk)
{
	switch (tk->info.type) {
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
		Node *block_node = _parse(pctx->token(tk, 2));
		if_stmt->expr = expr_node;
		if_stmt->true_stmt = (block_node) ? block_node->getRoot() : NULL;
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
	case TokenType::ForeachStmt:
		break;
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

void Parser::parseFunctionCall(ParseContext *pctx, Token *tk)
{
	if (isIrregularFunction(pctx, tk)) {
		parseIrregularFunction(pctx, tk);
	} else {
		FunctionCallNode *f = new FunctionCallNode(tk);
		BranchNode *node = dynamic_cast<BranchNode *>(pctx->lastNode());
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
		}
	} else {
		term = new LeafNode(tk);
	}
	assert(term && "syntax error!: near by term");
	Node *node = pctx->lastNode();
	return (!node) ? pctx->pushNode(term) : link(pctx, node, term);
}
