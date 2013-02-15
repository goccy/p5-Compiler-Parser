#include <typeinfo>

class Node {
public:
	Token *tk;
	Node *parent;
	Node *next;
	Node(Token *tk);
	virtual void dump(size_t depth);
	Node *getRoot(void);
	virtual ~Node(void){};
};

class Nodes : public std::vector<Node *> {
public:
	Nodes(void);
	Node *pop(void);
	void push(Node *node);
	void swapLastNode(Node *node);
	Node *lastNode(void);
	void dump(size_t depth);
};

class BranchNode : public Node {
public:
	Node *left;
	Node *right;
	BranchNode(Token *tk);
	void link(Node *child);
	void dump(size_t depth);
};

class ArrayNode : public Node {
public:
	Node *idx;
	ArrayNode(Token *tk);
	void dump(size_t depth);
};

class HashNode : public Node {
public:
	Node *key;
	HashNode(Token *tk);
	void dump(size_t depth);
};

class FunctionNode : public Node {
public:
	Node *body;
	FunctionNode(Token *tk);
	void dump(size_t depth);
};

class FunctionCallNode : public Node {
public:
	Nodes *args;
	FunctionCallNode(Token *tk);
	void setArgs(Node *args);
	void dump(size_t depth);
};

class BlockNode : public Node {
public:
	Node *body;
	BlockNode(Token *tk);
	void dump(size_t depth);
};

class ReturnNode : public Node {
public:
	Node *body;
	ReturnNode(Token *tk);
	void dump(size_t depth);
};

class SingleTermOperatorNode : public Node {
public:
	Node *expr;
	SingleTermOperatorNode(Token *op);
	void dump(size_t depth);
};

class DoubleTermOperatorNode : public Node {
public:
	DoubleTermOperatorNode(Token *op);
};

class OtherTermOperatorNode : public Node {
public:
	OtherTermOperatorNode(Token *op);
};

class LeafNode : public Node {
public:
	LeafNode(Token *tk);
};

class IfStmtNode : public Node {
public:
	Node *expr;
	Node *true_stmt;
	Node *false_stmt;
	IfStmtNode(Token *tk);
	void dump(size_t depth);
};

class ElseStmtNode : public Node {
public:
	Node *stmt;
	ElseStmtNode(Token *tk);
	void dump(size_t depth);
};

class ForStmtNode : public Node {
public:
	Node *init;
	Node *cond;
	Node *progress;
	Node *true_stmt;
	ForStmtNode(Token *tk);
	void setExpr(Node *expr);
	void dump(size_t depth);
};

class AST {
public:
	Node *root;
	AST(Node *root);
	void dump(void);
};

class ParseContext {
public:
	Token *tk;
	Token **tks;
	size_t idx;
	Nodes *nodes;
	Token *returnToken;

	ParseContext(Token *tk);
	Token *token(void);
	Token *token(Token *base, int offset);
	Token *nextToken(void);
	bool end(void);
	void next(void);
};

class Parser {
public:
	Node *_prev_stmt;
	Parser(void);
	void completeExpr(Token *root);
	AST *parse(Token *root);
	Node *_parse(Token *root);
	bool isSingleTermOperator(ParseContext *pctx, Token *tk);
	void parseStmt(ParseContext *pctx, Node *stmt);
	void parseExpr(ParseContext *pctx, Node *expr);
	void parseToken(ParseContext *pctx, Token *tk);
	void parseTerm(ParseContext *pctx, Token *term);
	void parseSingleTermOperator(ParseContext *pctx, Token *op);
	void parseBranchType(ParseContext *pctx, Token *branch);
	void parseSpecificStmt(ParseContext *pctx, Token *stmt);
	void parseDecl(ParseContext *pctx, Token *comma);
	void parseFunction(ParseContext *pctx, Token *func);
	void parseFunctionCall(ParseContext *pctx, Token *func);
};

class Completer {
public:
	std::vector<std::string> *named_unary_keywords;

	Completer(void);
	bool isUnaryKeyword(std::string target);
	void complete(Token *root);
	void completeTerm(Token *root);
	void insertExpr(Token *syntax, int idx, size_t grouping_num);
	void insertTerm(Token *syntax, int idx, size_t grouping_num);
	void completeExprFromLeft(Token *root, Enum::Lexer::Token::Type type);
	void completeExprFromRight(Token *root, Enum::Lexer::Token::Type type);
	void completeExprFromRight(Token *root, Enum::Lexer::Kind kind);
	void completePointerExpr(Token *root);
	void completeIncDecExpr(Token *root);
	void completePowerExpr(Token *root);
	void completeSingleTermOperatorExpr(Token *root);
	void completeRegexpMatchExpr(Token *root);
	void completeHighPriorityDoubleOperatorExpr(Token *root);
	void completeLowPriorityDoubleOperatorExpr(Token *root);
	void completeShiftOperatorExpr(Token *root);
	void completeHighPriorityCompareOperatorExpr(Token *root);
	void completeLowPriorityCompareOperatorExpr(Token *root);
	void completeNamedUnaryOperators(Token *root);
	void completeBitOperatorExpr(Token *root);
	void completeAndOrOperatorExpr(Token *root);
	void completeAssignExpr(Token *root);
	void completeCommaArrowExpr(Token *root);
	void completeFunctionListExpr(Token *root);
	void completeAlphabetBitOperatorExpr(Token *root);
	void recoveryFunctionArgument(Token *root);
	void recoveryNamedUnaryOperatorsArgument(Token *root);
};

#define Node_dump(node, msg, depth) {									\
		if (node) {														\
			for (size_t i = 0; i < depth; i++) {						\
				fprintf(stdout, "----------------");					\
			}															\
			fprintf(stdout, "%s ", msg);									\
			Node *traverse_ptr = node;									\
			for (; traverse_ptr != NULL; traverse_ptr = traverse_ptr->next) { \
				traverse_ptr->dump(depth+1);							\
			}															\
		}																\
	} while(0)
