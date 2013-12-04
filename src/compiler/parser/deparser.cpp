#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace TokenKind = Enum::Token::Kind;
namespace SyntaxType = Enum::Parser::Syntax;

Deparser::Deparser(void)
{
	needs_semicolon = true;
}

const char *Deparser::deparse(AST *ast)
{
	string ret = "";
	Node *node = ast->root;
	for (; node != NULL; node = node->next) {
		ret += _deparse(node);
		if (needs_semicolon) ret += ";";
		if (node->next) ret += "\n";
	}
	return ret.c_str();
}

string Deparser::_deparse(Node *node)
{
	needs_semicolon = true;
	string ret = "";
	if (TYPE_match(node, BranchNode)) {
		ret = deparseBranch(dynamic_cast<BranchNode *>(node));
	} else if (TYPE_match(node, LeafNode)) {
		ret = deparseLeaf(dynamic_cast<LeafNode *>(node));
	} else if (TYPE_match(node, HashRefNode)) {
		ret = deparseHashRef(dynamic_cast<HashRefNode *>(node));
	} else if (TYPE_match(node, ArrayRefNode)) {
		ret = deparseArrayRef(dynamic_cast<ArrayRefNode *>(node));
	} else if (TYPE_match(node, DereferenceNode)) {
		ret = deparseDereference(dynamic_cast<DereferenceNode *>(node));
	} else if (TYPE_match(node, ArrayNode)) {
		ret = deparseArray(dynamic_cast<ArrayNode *>(node));
	} else if (TYPE_match(node, HashNode)) {
		ret = deparseHash(dynamic_cast<HashNode *>(node));
	} else if (TYPE_match(node, ListNode)) {
		ret = deparseList(dynamic_cast<ListNode *>(node));
	} else if (TYPE_match(node, FunctionNode)) {
		ret = deparseFunction(dynamic_cast<FunctionNode *>(node));
	} else if (TYPE_match(node, FunctionCallNode)) {
		ret = deparseFunctionCall(dynamic_cast<FunctionCallNode *>(node));
	} else if (TYPE_match(node, LabelNode)) {
		ret = deparseLabel(dynamic_cast<LabelNode *>(node));
	} else if (TYPE_match(node, ModuleNode)) {
		ret = deparseModule(dynamic_cast<ModuleNode *>(node));
	} else if (TYPE_match(node, PackageNode)) {
		ret = deparsePackage(dynamic_cast<PackageNode *>(node));
	} else if (TYPE_match(node, RegPrefixNode)) {
		ret = deparseRegPrefix(dynamic_cast<RegPrefixNode *>(node));
	} else if (TYPE_match(node, RegReplaceNode)) {
		ret = deparseRegReplace(dynamic_cast<RegReplaceNode *>(node));
	} else if (TYPE_match(node, RegexpNode)) {
		ret = deparseRegexp(dynamic_cast<RegexpNode *>(node));
	} else if (TYPE_match(node, HandleNode)) {
		ret = deparseHandle(dynamic_cast<HandleNode *>(node));
	} else if (TYPE_match(node, HandleReadNode)) {
		ret = deparseHandleRead(dynamic_cast<HandleReadNode *>(node));
	} else if (TYPE_match(node, BlockNode)) {
		ret = deparseBlock(dynamic_cast<BlockNode *>(node));
	} else if (TYPE_match(node, IfStmtNode)) {
		ret = deparseIfStmt(dynamic_cast<IfStmtNode *>(node));
	} else if (TYPE_match(node, ElseStmtNode)) {
		ret = deparseElseStmt(dynamic_cast<ElseStmtNode *>(node));
	} else if (TYPE_match(node, ReturnNode)) {
		ret = deparseReturn(dynamic_cast<ReturnNode *>(node));
	} else if (TYPE_match(node, SingleTermOperatorNode)) {
		ret = deparseSingleTermOperator(dynamic_cast<SingleTermOperatorNode *>(node));
	} else if (TYPE_match(node, ThreeTermOperatorNode)) {
		ret = deparseThreeTermOperator(dynamic_cast<ThreeTermOperatorNode *>(node));
	}
	return ret;
}

string Deparser::deparseLeaf(LeafNode *node)
{
	using namespace TokenType;
	string ret = "";
	switch (node->tk->info.type) {
	case String:
		ret = "\"" + node->tk->data + "\"";
		break;
	case RawString:
		ret = "'" + node->tk->data + "'";
		break;
	case ExecString:
		ret = "`" + node->tk->data + "`";
		break;
	default:
		ret = node->tk->data;
		break;
	}
	return ret;
}

string Deparser::deparseBranch(BranchNode *node)
{
	using namespace TokenType;
	string left = _deparse(node->left);
	string right = (node->right) ? _deparse(node->right) : "";
	Type type = node->tk->info.type;
	string ret = "";
	if (type == Pointer) {
		ret = left + node->tk->data + right;
	} else if (type == Comma) {
		ret = left + node->tk->data + " " + right;
	} else {
		ret = left + " " + node->tk->data + " " + right;
	}
	return ret;
}

string Deparser::deparseHashRef(HashRefNode *node)
{
	return "{" + _deparse(node->data) + "}";
}

string Deparser::deparseArrayRef(ArrayRefNode *node)
{
	return "[" + _deparse(node->data) + "]";
}

string Deparser::deparseDereference(DereferenceNode *node)
{
	using namespace TokenType;
	Type type = node->tk->info.type;
	string expr = _deparse(node->expr);
	string ret = "";
	switch (type) {
	case ScalarDereference:
		ret = "${" + expr + "}";
		break;
	case ArrayDereference:
		ret = "@{" + expr + "}";
		break;
	case HashDereference:
		ret = "%{" + expr + "}";
		break;
	case ShortScalarDereference:
	case ShortArrayDereference:
	case ShortHashDereference:
		ret = expr;
		break;
	default:
		break;
	}
	return ret;
}

string Deparser::deparseArray(ArrayNode *node)
{
	return node->tk->data + _deparse(node->idx);
}

string Deparser::deparseList(ListNode *node)
{
	return "(" + _deparse(node->data) + ")";
}

string Deparser::deparseHash(HashNode *node)
{
	return node->tk->data + _deparse(node->key);
}

string Deparser::deparseFunction(FunctionNode *node)
{
	string prototype = (node->prototype) ? "(" + _deparse(node->prototype) + ")" : "";
	string func_body = "";
	Node *body = node->body;
	for (; body != NULL; body = body->next) {
		func_body += "    " + _deparse(body) + ";\n";
	}
	needs_semicolon = false;
	return "sub " + node->tk->data + prototype + " {\n" + func_body + "}";
}

string Deparser::deparseModule(ModuleNode *node)
{
	return "use " + node->tk->data + " " + _deparse(node->args);
}

string Deparser::deparsePackage(PackageNode *node)
{
	return "package " + node->tk->data;
}

string Deparser::deparseRegPrefix(RegPrefixNode *node)
{
	string option = (node->option) ? _deparse(node->option) : "";
	return node->tk->data + "/" + _deparse(node->exp) + "/" + option;
}

string Deparser::deparseRegReplace(RegReplaceNode *node)
{
	string option = (node->option) ? _deparse(node->option) : "";
	return node->tk->data + "/" + _deparse(node->from) + "/" + _deparse(node->to) + "/" + option;
}

string Deparser::deparseRegexp(RegexpNode *node)
{
	string option = (node->option) ? _deparse(node->option) : "";
	return "/" + node->tk->data + "/" + option;
}

string Deparser::deparseLabel(LabelNode *node)
{
	return node->tk->data + ":";
}

string Deparser::deparseHandle(HandleNode *node)
{
	return node->tk->data + " " + _deparse(node->expr);
}

string Deparser::deparseHandleRead(HandleReadNode *node)
{
	return "<" + node->tk->data + ">";
}

string Deparser::deparseFunctionCall(FunctionCallNode *node)
{
	string ret = node->tk->data + "(";
	size_t size = node->args->size();
	for (size_t i = 0; i < size; i++) {
		Node *arg = node->args->at(i);
		ret += _deparse(arg);
		if (i + 1 < size) ret += ", ";
	}
	ret += ")";
	return ret;
}

string Deparser::deparseBlock(BlockNode *node)
{
	string block_body = "";
	Node *body = node->body;
	for (; body != NULL; body = body->next) {
		block_body += "    " + _deparse(body) + ";\n";
	}
	return "{\n" + block_body + "}";
}

string Deparser::deparseReturn(ReturnNode *node)
{
	return "return " + _deparse(node->body);
}

string Deparser::deparseSingleTermOperator(SingleTermOperatorNode *node)
{
	return node->tk->data + _deparse(node->expr);
}

string Deparser::deparseThreeTermOperator(ThreeTermOperatorNode *node)
{
	return "(" + _deparse(node->cond) + ") ? " + _deparse(node->true_expr) + " : " + _deparse(node->false_expr);
}

string Deparser::deparseIfStmt(IfStmtNode *node)
{
	string true_stmt = "";
	string false_stmt = (node->false_stmt) ? " else {\n" : "";
	Node *stmt = node->true_stmt;
	for (; stmt != NULL; stmt = stmt->next) {
		true_stmt += "    " + _deparse(stmt) + ";\n";
	}
	stmt = node->false_stmt;
	for (; stmt != NULL; stmt = stmt->next) {
		false_stmt += _deparse(stmt);
	}
	if (node->false_stmt) false_stmt += "}";
	string ret = node->tk->data + " (" + _deparse(node->expr) + ") {\n" + true_stmt + "}" + false_stmt;
	needs_semicolon = false;
	return ret;
}

string Deparser::deparseElseStmt(ElseStmtNode *node)
{
	string else_stmt = "";
	Node *stmt = node->stmt;
	for (; stmt != NULL; stmt = stmt->next) {
		else_stmt += "    " + _deparse(stmt) + ";\n";
	}
	return else_stmt;
}
