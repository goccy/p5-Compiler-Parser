class Deparser {
public:
	Deparser(void);
	const char *deparse(AST *ast);
	std::string _deparse(Node *node);
	std::string deparseLeaf(LeafNode *node);
	std::string deparseBranch(BranchNode *node);
	std::string deparseHashRef(HashRefNode *node);
	std::string deparseArrayRef(ArrayRefNode *node);
	std::string deparseDereference(DereferenceNode *node);
	std::string deparseArray(ArrayNode *node);
	std::string deparseHash(HashNode *node);
	std::string deparseList(ListNode *node);
	std::string deparseLabel(LabelNode *node);
	std::string deparseModule(ModuleNode *node);
	std::string deparsePackage(PackageNode *node);
	std::string deparseRegPrefix(RegPrefixNode *node);
	std::string deparseRegReplace(RegReplaceNode *node);
	std::string deparseRegexp(RegexpNode *node);
	std::string deparseHandle(HandleNode *node);
	std::string deparseHandleRead(HandleReadNode *node);
	std::string deparseFunction(FunctionNode *node);
	std::string deparseFunctionCall(FunctionCallNode *node);
	std::string deparseBlock(BlockNode *node);
	std::string deparseIfStmt(IfStmtNode *node);
	std::string deparseReturn(ReturnNode *node);
	std::string deparseSingleTermOperator(SingleTermOperatorNode *node);
	std::string deparseThreeTermOperator(ThreeTermOperatorNode *node);
};

class BDeparser : public Deparser {
public:
	BDeparser(void);
	const char *deparse(AST *ast);
	std::string _deparse(Node *node);
	std::string deparseBranch(BranchNode *node);
};
