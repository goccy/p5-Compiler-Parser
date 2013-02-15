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

Parser::Parser(void)
{
	this->_prev_stmt = NULL;
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
	Node *node = pctx->nodes->lastNode();
	if (pctx->returnToken) {
		ReturnNode *ret = new ReturnNode(pctx->returnToken);
		ret->body = node;
		return ret;
	}
	return node;
}

void Parser::parseToken(ParseContext *pctx, Token *tk)
{
	using namespace TokenKind;
	using namespace TokenType;
	switch (tk->info.kind) {
	case TokenKind::Decl:
		DBG_PL("DECL");
		parseDecl(pctx, tk);
		break;
	case TokenKind::Term:
	case TokenKind::Modifier:
		DBG_PL("TERM");
		parseTerm(pctx, tk);
		break;
	case TokenKind::Operator:
	case TokenKind::Assign:
	case TokenKind::Comma:
		DBG_PL("BRANCH");
		parseBranchType(pctx, tk);
		break;
	case TokenKind::Function:
		DBG_PL("CALL");
		parseFunctionCall(pctx, tk);
		break;
	case TokenKind::Stmt:
		DBG_PL("STMT");
		parseSpecificStmt(pctx, tk);
		break;
	case TokenKind::Return:
		DBG_PL("RETURN");
		pctx->returnToken = tk;
		break;
	case TokenKind::SpecificKeyword:
		DBG_PL("KEYWORD");
		break;
	case TokenKind::Handle:
		DBG_PL("HANDLE");
		break;
	case TokenKind::StmtEnd:
		DBG_PL("STMT_END");
		break;
	case TokenKind::Symbol:
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
	Nodes *nodes = pctx->nodes;
	Node *prev_stmt = nodes->lastNode();
	if (!prev_stmt) {
		nodes->push(stmt);
		return;
	}
	prev_stmt->next = stmt;
	stmt->parent = prev_stmt;
	nodes->swapLastNode(stmt);
}

void Parser::parseExpr(ParseContext *pctx, Node *expr)
{
	Nodes *nodes = pctx->nodes;
	Node *node = nodes->lastNode();
	if (!node) {
		nodes->push_back(expr);
		return;
	}
	if (typeid(*node) == typeid(BranchNode)) {
		BranchNode *branch = dynamic_cast<BranchNode *>(node);
		branch->link(expr);
	} else if (typeid(*node) == typeid(FunctionCallNode)) {
		FunctionCallNode *func = dynamic_cast<FunctionCallNode *>(node);
		if (expr) func->setArgs(expr);
	} else if (typeid(*node) == typeid(ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(node);
		array->idx = expr;
	} else if (typeid(*node) == typeid(HashNode)) {
		HashNode *hash = dynamic_cast<HashNode *>(node);
		hash->key = expr;
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
	case TokenType::ElsifStmt:
	case TokenType::UnlessStmt: {
		IfStmtNode *if_stmt = new IfStmtNode(tk);
		if (tk->info.type == TokenType::ElsifStmt) {
			IfStmtNode *node = dynamic_cast<IfStmtNode *>(_prev_stmt);
			node->false_stmt = if_stmt->getRoot();
		} else {
			pctx->nodes->push(if_stmt);
		}
		_prev_stmt = if_stmt;
		Node *expr_node = _parse(pctx->token(tk, 1))->getRoot();
		Node *block_stmt_node = _parse(pctx->token(tk, 2));
		if_stmt->expr = expr_node;
		if_stmt->true_stmt = block_stmt_node->getRoot();
		pctx->next();
		pctx->next();
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
		pctx->nodes->push(for_stmt);
		pctx->next();
		pctx->next();
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
	/* right associativity */
	if ((type == IsNot || type == Ref || type == Add || type == Sub) ||
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
	} else if (type == Inc || type == Dec) {
		asm("int3");
		op_node = new SingleTermOperatorNode(tk);
	}
	assert(op_node && "syntax error!");
	Nodes *nodes = pctx->nodes;
	BranchNode *node = dynamic_cast<BranchNode *>(nodes->lastNode());
	if (!node) {
		nodes->push(op_node);
		return;
	}
	//node->link(op_node);//TODO swap from previous node to op_node
}

bool Parser::isSingleTermOperator(ParseContext *pctx, Token *tk)
{
	using namespace TokenType;
	TokenType::Type type = tk->info.type;
	if (type == IsNot || type == Ref || type == Inc || type == Dec) return true;
	if ((type == Add || type == Sub) && pctx->idx == 0) return true;
	return false;
}

void Parser::parseBranchType(ParseContext *pctx, Token *tk)
{
	Nodes *nodes = pctx->nodes;
	Node *node = nodes->lastNode();
	if (isSingleTermOperator(pctx, tk)) {
		parseSingleTermOperator(pctx, tk);
	} else {
		assert(node && "syntax error!: nothing value before xxx");
		BranchNode *branch = new BranchNode(tk);
		branch->left = node;
		node->parent = branch;
		nodes->swapLastNode(branch);
	}
}

void Parser::parseFunction(ParseContext *pctx, Token *tk)
{
	Nodes *nodes = pctx->nodes;
	FunctionNode *f = new FunctionNode(tk);
	Node *block_stmt_node = NULL;
	if (tk->stype == SyntaxType::BlockStmt) {
		/* Nameless Function */
		block_stmt_node = _parse(tk);
	} else {
		block_stmt_node = _parse(pctx->nextToken());
	}
	f->body = block_stmt_node->getRoot();
	pctx->next();
	BranchNode *node = dynamic_cast<BranchNode *>(nodes->lastNode());
	if (!node) {
		nodes->push(f);
		return;
	}
	node->link(f);
}

void Parser::parseFunctionCall(ParseContext *pctx, Token *tk)
{
	Nodes *nodes = pctx->nodes;
	FunctionCallNode *f = new FunctionCallNode(tk);
	BranchNode *node = dynamic_cast<BranchNode *>(nodes->lastNode());
	if (!node) {
		nodes->push(f);
		return;
	}
	node->link(f);
}

void Parser::parseTerm(ParseContext *pctx, Token *tk)
{
	using namespace SyntaxType;
	Nodes *nodes = pctx->nodes;
	Token *next_tk = pctx->nextToken();
	Node *term;
	if (next_tk && next_tk->stype == Expr) {
		if (next_tk->tks[0]->info.type == TokenType::LeftBracket) {
			term = new ArrayNode(tk);
		} else if (next_tk->tks[0]->info.type == TokenType::LeftBrace) {
			term = new HashNode(tk);
		}
	} else {
		term = new LeafNode(tk);
	}
	Node *node = nodes->lastNode();
	if (!node) {
		nodes->push(term);
		return;
	}
	if (typeid(*node) == typeid(BranchNode)) {
		BranchNode *branch = dynamic_cast<BranchNode *>(node);
		branch->link(term);
	} else if (typeid(*node) == typeid(FunctionCallNode)) {
		FunctionCallNode *func = dynamic_cast<FunctionCallNode *>(node);
		func->setArgs(term);
	} else if (typeid(*node) == typeid(ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(node);
		array->idx = term;
	} else if (typeid(*node) == typeid(HashNode)) {
		HashNode *hash = dynamic_cast<HashNode *>(node);
		hash->key = term;
	}
}
