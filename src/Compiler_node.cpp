#include <lexer.hpp>
#include <parser.hpp>

using namespace std;
Node::Node(Token *tk_)
{
	this->tk = tk_;
	this->parent = NULL;
	this->next = NULL;
}

void Node::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	DBG_PL("[%s]", cstr(tk->data));
}

Node *Node::getRoot(void)
{
	Node *search_ptr = this;
	while (search_ptr->parent != NULL) {
		search_ptr = search_ptr->parent;
	}
	return search_ptr;
}

Nodes::Nodes() : vector<Node *>()
{
}

Node *Nodes::pop(void)
{
	Node *ret = lastNode();
	pop_back();
	return ret;
}

void Nodes::push(Node *node)
{
	push_back(node);
}

void Nodes::swapLastNode(Node *node)
{
	pop_back();
	push_back(node);
}

Node *Nodes::lastNode(void)
{
	if (empty()) return NULL;
	return back();
}

void Nodes::dump(size_t depth)
{
	size_t n = size();
	for (size_t i = 0; i < n; i++) {
		at(i)->dump(depth);
	}
}

LeafNode::LeafNode(Token *tk_) : Node(tk_)
{
}

BranchNode::BranchNode(Token *tk_) : Node(tk_)
{
	this->left = NULL;
	this->right = NULL;
}

void BranchNode::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	DBG_PL("[%s]", cstr(tk->data));
	if (right) {
		DBG_P("left  : ");
		left->dump(depth+1);
		DBG_P("right : ");
		right->dump(depth+1);
	} else {
		DBG_P("left  : ");
		left->dump(depth+1);
	}
}

ArrayNode::ArrayNode(Token *tk_) : Node(tk_)
{
	this->idx = NULL;
}

void ArrayNode::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	DBG_PL("array");
	if (idx) {
		DBG_P("idx  : ");
		idx->dump(depth+1);
	}
}

HashNode::HashNode(Token *tk_) : Node(tk_)
{
	this->key = NULL;
}

void HashNode::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	DBG_PL("hash");
	if (key) {
		DBG_P("key  : ");
		key->dump(depth+1);
	}
}

FunctionCallNode::FunctionCallNode(Token *tk_) : Node(tk_)
{
	this->args = new Nodes();
}

void FunctionCallNode::setArgs(Node *expr)
{
	args->push(expr);
}

void FunctionCallNode::dump(size_t depth)
{
	if (args->empty()) {
		DBG_PL("call  : %s", cstr(tk->data));
	} else {
		DBG_PL("call  : %s", cstr(tk->data));
		DBG_PL("args  : [");
		args->dump(depth+1);
		DBG_PL("]");
	}
}

FunctionNode::FunctionNode(Token *tk_) : Node(tk_)
{
	this->body = NULL;
}

void FunctionNode::dump(size_t depth)
{
	DBG_PL("func  : %s", cstr(tk->data));
	DBG_PL("body  : ");
	Node *traverse_ptr = body;
	for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) {
		traverse_ptr->dump(depth+1);
	}
}

BlockNode::BlockNode(Token *tk_) : Node(tk_)
{
	this->body = NULL;
}

void BlockNode::dump(size_t depth)
{
	DBG_PL("block  : %s", cstr(tk->data));
	DBG_PL("body  : ");
	Node *traverse_ptr = body;
	for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) {
		traverse_ptr->dump(depth+1);
	}
}

ReturnNode::ReturnNode(Token *tk_) : Node(tk_)
{
	this->body = NULL;
}

void ReturnNode::dump(size_t depth)
{
	DBG_PL("return  : %s", cstr(tk->data));
	DBG_PL("body  : ");
	Node *traverse_ptr = body;
	for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) {
		traverse_ptr->dump(depth+1);
	}
}

void BranchNode::link(Node *child)
{
	if (right) {
		if (typeid(*right) == typeid(ArrayNode)) {
			ArrayNode *array = dynamic_cast<ArrayNode *>(right);
			array->idx = child;
		} else if (typeid(*right) == typeid(HashNode)) {
			HashNode *hash = dynamic_cast<HashNode *>(right);
			hash->key = child;
		} else {
			assert(0 && "syntax error!\n");
		}
	} else if (left) {
		right = child;
	} else {
		left = child;
	}
	child->parent = this;
}

OperatorNode::OperatorNode(Token *tk) : BranchNode(tk)
{
}

IfStmtNode::IfStmtNode(Token *tk) : Node(tk)
{
	this->expr = NULL;
	this->true_stmt = NULL;
	this->false_stmt = NULL;
}

void IfStmtNode::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	DBG_PL("ifstmt  : %s", cstr(tk->data));
	if (expr) {
		DBG_P("expr  : ");
		expr->dump(depth+1);
	}
	if (true_stmt) {
		DBG_PL("true  : ");
		Node *traverse_ptr = true_stmt;
		for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) {
			traverse_ptr->dump(depth+1);
		}
	}
	if (false_stmt) {
		DBG_PL("false  : ");
		Node *traverse_ptr = false_stmt;
		for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) {
			traverse_ptr->dump(depth+1);
		}
	}
}

ElseStmtNode::ElseStmtNode(Token *tk) : Node(tk)
{
	this->stmt = NULL;
}

void ElseStmtNode::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	if (stmt) stmt->dump(depth+1);
}

ForStmtNode::ForStmtNode(Token *tk) : Node(tk)
{
	this->init = NULL;
	this->cond = NULL;
	this->progress = NULL;
	this->true_stmt = NULL;
}

void ForStmtNode::setExpr(Node *expr)
{
	init = expr;
	cond = expr->next;
	progress = expr->next->next;
}

void ForStmtNode::dump(size_t depth)
{
	string prefix = "";
	for (size_t i = 0; i < depth; i++) {
		prefix += "----";
	}
	DBG_P("%s", cstr(prefix));
	DBG_PL("forstmt  : %s", cstr(tk->data));
	if (init) {
		DBG_P("init  : ");
		init->dump(depth+1);
	}
	if (cond) {
		DBG_P("cond  : ");
		cond->dump(depth+1);
	}
	if (progress) {
		DBG_P("progress  : ");
		progress->dump(depth+1);
	}
	if (true_stmt) {
		DBG_PL("true  : ");
		Node *traverse_ptr = true_stmt;
		for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) {
			traverse_ptr->dump(depth+1);
		}
	}
}
