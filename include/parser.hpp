#include <common.hpp>
#include <setjmp.h>
#include <unistd.h>

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

class AST {
public:
	Node *root;
	AST(Node *root);
	void dump(void);
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

class DereferenceNode : public Node {
public:
	Node *expr;
	DereferenceNode(Token *tk);
	void dump(size_t depth);
};

class CodeDereferenceNode : public Node {
public:
	Node *name;
	Node *args;
	CodeDereferenceNode(Token *tk);
	void dump(size_t depth);
};

class ArrayNode : public Node {
public:
	Node *idx;
	ArrayNode(Token *tk);
	void dump(size_t depth);
};

class ArrayRefNode : public Node {
public:
	Node *data;
	ArrayRefNode(Token *tk);
	void dump(size_t depth);
};

class HashRefNode : public Node {
public:
	Node *data;
	HashRefNode(Token *tk);
	void dump(size_t depth);
};

class ListNode : public Node {
public:
	Node *data;
	ListNode(Token *tk);
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
	Node *prototype;
	FunctionNode(Token *tk);
	void dump(size_t depth);
};

class ModuleNode : public Node {
public:
	Node *args;
	AST *ast;
	ModuleNode(Token *tk);
	void dump(size_t depth);
};

class PackageNode : public Node {
public:
	PackageNode(Token *tk);
	void dump(size_t depth);
};

class RegPrefixNode : public Node {
public:
	Node *exp;
	Node *option;
	RegPrefixNode(Token *tk);
	void dump(size_t depth);
};

class RegReplaceNode : public Node {
public:
	Node *prefix;
	Node *from;
	Node *to;
	Node *option;
	RegReplaceNode(Token *tk);
	void dump(size_t depth);
};

class RegexpNode : public Node {
public:
	Node *option;
	RegexpNode(Token *tk);
	void dump(size_t depth);
};

class LabelNode : public Node {
public:
	LabelNode(Token *tk);
	void dump(size_t depth);
};

class HandleNode : public Node {
public:
	Node *expr;
	HandleNode(Token *tk);
	void dump(size_t depth);
};

class HandleReadNode : public Node {
public:
	HandleReadNode(Token *tk);
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

class ThreeTermOperatorNode : public Node {
public:
	Node *cond;
	Node *true_expr;
	Node *false_expr;
	ThreeTermOperatorNode(Token *op);
	void dump(size_t depth);
};

class OtherTermOperatorNode : public Node {
public:
	OtherTermOperatorNode(Token *op);
};

class LeafNode : public Node {
public:
	LeafNode(Token *tk);
};

class ControlStmtNode : public Node {
public:
	ControlStmtNode(Token *tk);
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

class DoStmtNode : public Node {
public:
	Node *stmt;
	DoStmtNode(Token *tk);
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

class ForeachStmtNode : public Node {
public:
	Node *itr;
	Node *cond;
	Node *true_stmt;
	ForeachStmtNode(Token *tk);
	void setExpr(Node *expr);
	void dump(size_t depth);
};

class WhileStmtNode : public Node {
public:
	Node *expr;
	Node *true_stmt;
	WhileStmtNode(Token *tk);
	void dump(size_t depth);
};

class Module {
public:
	const char *name;
	const char *args;
	Module(const char *name, const char *args);
};

#include <deparser.hpp>

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
	Token *nullableToken(Token *base, int offset);
	Token *nextToken(void);
	Node *lastNode(void);
	void pushNode(Node *node);
	bool end(void);
	void next(void);
	void next(int progress);
};

class TokenManager {
public:
	TokenManager(void);
	void insertToken(Token *tk, size_t idx, Token *target);
	void closeToken(Token *tk, size_t base_idx, size_t start_idx, size_t close_num);
};

class TokenFactory {
public:
	TokenFactory(void);
	Token *makeExprToken(Token **base, size_t start_idx, size_t end_idx);
	Token *makeTermToken(Token **base, size_t start_idx, size_t end_idx);
	Token *makeListToken(Token *base);
	Token *makePointerToken(Token *base);
};

class Parser {
public:
	TokenPos start_pos;
	TokenPos pos;
	Node *_prev_stmt;
	Node *extra_node;
	Enum::Parser::Syntax::Type cur_stype;

	Parser(void);
	const char *deparse(AST *ast);
	void grouping(Tokens *tokens);
	void replaceHereDocument(Tokens *tokens);
	Token *parseSyntax(Token *start_token, Tokens *tokens);
	void parseSpecificStmt(Token *root);
	void setIndent(Token *tk, int indent);
	void setBlockIDWithBreadthFirst(Token *tk, size_t base_id);
	void setBlockIDWithDepthFirst(Token *tk, size_t *block_id);
	void dumpSyntax(Token *tk, int indent);
	Tokens *getTokensBySyntaxLevel(Token *root, Enum::Parser::Syntax::Type type);
	Modules *getUsedModules(Token *root);
	AST *parse(Tokens *tks);
	Node *_parse(Token *root);
	void link(ParseContext *pctx, Node *from, Node *to);
	bool isForeach(ParseContext *pctx, Token *tk);
	bool isPostPositionCase(Token *tk);
	bool isForStmtPattern(Token *tk, Token *expr);
	bool isSingleTermOperator(ParseContext *pctx, Token *tk);
	bool isIrregularFunction(ParseContext *pctx, Token *tk);
	bool isMissingSemicolon(Enum::Token::Type::Type prev_type, Enum::Token::Type::Type type, Tokens *tokens);
	bool isMissingSemicolon(Tokens *tokens);
	bool canGrouping(Token *tk, Token *next_tk);
	bool needsCompleteListForArray(ParseContext *pctx, BranchNode *brancb, Node *node);
	bool needsCompleteListForExecutionCodeRef(ParseContext *pctx, BranchNode *brancb, Node *node);
	bool needsCompleteListForListDeclaration(ParseContext *pctx, BranchNode *brancb, Node *node);
	Token *replaceToStmt(Tokens *tokens, Token *cur_tk, size_t offset);
	void parseStmt(ParseContext *pctx, Node *stmt);
	void parseExpr(ParseContext *pctx, Node *expr);
	void parseToken(ParseContext *pctx, Token *tk);
	void parseModifier(ParseContext *pctx, Token *term);
	void parseTerm(ParseContext *pctx, Token *term);
	void parseHandle(ParseContext *pctx, Token *handle);
	void parseSymbol(ParseContext *pctx, Token *symbol);
	void parseSingleTermOperator(ParseContext *pctx, Token *op);
	void parseThreeTermOperator(ParseContext *pctx, Token *op);
	void parseBranchType(ParseContext *pctx, Token *branch);
	void parseSpecificKeyword(ParseContext *pctx, Token *stmt);
	void parseSpecificStmt(ParseContext *pctx, Token *stmt);
	void parseControlStmt(ParseContext *pctx, Token *stmt);
	void parseDecl(ParseContext *pctx, Token *comma);
	void parseModule(ParseContext *pctx, Token *mod);
	void parseModuleArgument(ParseContext *pctx, Token *args);
	void parseRegPrefix(ParseContext *pctx, Token *reg);
	void parseRegReplace(ParseContext *pctx, Token *reg);
	void parseFunction(ParseContext *pctx, Token *func);
	void parseFunctionCall(ParseContext *pctx, Token *func);
	void parseIrregularFunction(ParseContext *pctx, Token *func);
private:
	bool isExpr(Token *tk, Token *prev_tk, Enum::Token::Type::Type type, Enum::Token::Kind::Kind kind);
	void insertStmt(Token *tk, int idx, size_t grouping_num);
	void insertExpr(Token *syntax, int idx, size_t grouping_num);
	void insertParenthesis(Tokens *tokens);
};

class SyntaxCompleter {
public:
	SyntaxCompleter(void);
	void insertTerm(Token *tk, int idx, size_t grouping_num);
	void insertExpr(Token *tk, int idx, size_t grouping_num);
	virtual bool complete(Token *root, size_t current_idx);
};

class SyntaxRecoverer {
public:
	SyntaxRecoverer(void);
	virtual bool recovery(Token *root, size_t current_idx);
};

class TermCompleter : public SyntaxCompleter {
public:
	TermCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool isVariable(Token *tk);
	bool isOperatorTarget(Token *tk);
	bool isFunctionCall(Token *prev_tk, Token *tk);
	bool isBasicTerm(Token *tk, size_t current_idx);
	bool isDereferenceTerm(Token *tk, size_t current_idx);
	bool isRegexTerm(Token *tk, size_t current_idx);
	bool isRegexWithoutPrefixTerm(Token *tk, size_t current_idx);
	bool isRegexReplaceTerm(Token *tk, size_t current_idx);
	bool isRegexReplaceTermWithDoubleMiddleDelim(Token *tk, size_t current_idx);
	bool isHandleTerm(Token *tk, size_t current_idx);
	bool isAnonymousFunctionTerm(Token *tk, size_t current_idx);
	bool isCodeRefTerm(Token *tk, size_t current_idx);
	bool isFunctionCallWithParenthesis(Token *tk, size_t current_idx);
	bool isVariableDecl(Token *tk, size_t current_idx);
	bool isGlobTerm(Token *tk, size_t current_idx);
};

class PointerCompleter : public SyntaxCompleter {
public:
	PointerCompleter(void);
	bool complete(Token *root, size_t current_idx);
	void insertPointerToken(Token *root);
private:
	bool isPointer(Token *tk, size_t current_idx);
	bool isPointerChainElement(Token *tk);
	bool isPointerChainElementOfExpr(Token *tk);
	bool isPointerChainElementOfTerm(Token *tk);
	size_t _insertPointerToken(Token *tk, size_t current_idx);
	bool canContinuousPointerChain(Token *tk, Token *next_tk);
	bool notContinuousPointerChainElement(Token *tk);
	bool notContinuousPointerChainElementOfExpr(Token *tk);
	bool isArrayOrHashExpr(Token *tk, Token *next_tk);
};

class ReturnCompleter : public SyntaxCompleter {
public:
	ReturnCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool isOperatorTarget(Token *tk);
	bool isReturnTerm(Token *tk, size_t current_idx);
};

class NamedUnaryOperatorCompleter : public SyntaxCompleter, public SyntaxRecoverer {
public:
	std::vector<std::string> *named_unary_keywords;
	NamedUnaryOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool recovery(Token *tk, size_t current_idx);
private:
	bool isNamedUnaryFunction(Token *tk, size_t current_idx);
	bool isUnaryOperator(Token *tk, size_t current_idx);
	bool isUnaryKeyword(std::string target);
	bool isStatementController(Token *tk, size_t current_idx);
	bool isStatementControlKeyword(Token *tk);
	bool isHandle(Token *tk, size_t current_idx);
	bool shouldRecovery(Token *tk, size_t current_idx);
	void recoveryArgument(Token *tk, size_t current_idx);
};

class SpecialOperatorCompleter : public SyntaxCompleter {
public:
	SpecialOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool isIncDecType(Token *tk);
	bool isLeftIncDecExpr(Token *tk, size_t current_idx);
	bool isRightIncDecExpr(Token *tk, size_t current_idx);
};

class PowerCompleter : public SyntaxCompleter {
public:
	PowerCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isPower(Token *tk, int current_idx);
};

class RegexpMatchCompleter : public SyntaxCompleter {
public:
	RegexpMatchCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isRegexpMatch(Token *tk, int current_idx);
};

class HighPriorityDoubleOperatorCompleter : public SyntaxCompleter {
public:
	HighPriorityDoubleOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isHighPriorityDoubleOperator(Token *tk, size_t current_idx);
};

class LowPriorityDoubleOperatorCompleter : public SyntaxCompleter {
public:
	LowPriorityDoubleOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isLowPriorityDoubleOperator(Token *tk, size_t current_idx);
};

class ShiftCompleter : public SyntaxCompleter {
public:
	ShiftCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isShiftOperator(Token *tk, size_t current_idx);
};

class HighPriorityCompareOperatorCompleter : public SyntaxCompleter {
public:
	HighPriorityCompareOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isHighPriorityCompareOperator(Token *tk, size_t current_idx);
};

class LowPriorityCompareOperatorCompleter : public SyntaxCompleter {
public:
	LowPriorityCompareOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isLowPriorityCompareOperator(Token *tk, size_t current_idx);
};

class BitOperatorCompleter : public SyntaxCompleter {
public:
	BitOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isBitOperator(Token *tk, size_t current_idx);
};

class AndOperatorCompleter : public SyntaxCompleter {
public:
	AndOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isAndOperator(Token *tk, size_t current_idx);
};

class OrOperatorCompleter : public SyntaxCompleter {
public:
	OrOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isOrOperator(Token *tk, size_t current_idx);
};

class AssignCompleter : public SyntaxCompleter {
public:
	AssignCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isAssign(Token *tk, int current_idx);
};

class ArrowCompleter : public SyntaxCompleter {
public:
	ArrowCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isArrow(Token *tk, size_t current_idx);
};

class CommaCompleter : public SyntaxCompleter {
public:
	CommaCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isComma(Token *tk, size_t current_idx);
};

class AlphabetBitOperatorCompleter : public SyntaxCompleter {
public:
	AlphabetBitOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
private:
	bool isAlphabetBitOperator(Token *tk, size_t current_idx);
};

class SingleTermOperatorCompleter : public SyntaxCompleter {
public:
	SingleTermOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool isSimpleSingleTermOperator(Token *tk, size_t current_idx);
	bool isSingleTermOperator(Token *tk, size_t current_idx);
	bool isOperatorTarget(Token *tk);
};

class ThreeTermOperatorCompleter : public SyntaxCompleter {
public:
	ThreeTermOperatorCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool isThreeTermOperator(Token *tk, size_t current_idx);
};

class FunctionListCompleter : public SyntaxCompleter, public SyntaxRecoverer {
public:
	FunctionListCompleter(void);
	bool complete(Token *root, size_t current_idx);
	bool recovery(Token *root, size_t current_idx);
private:
	bool isPrintFunction(Token *tk);
	bool isFunctionCallWithoutParenthesis(Token *tk, size_t current_idx);
	bool isFunctionList(Token *tk, size_t current_idx);
	bool shouldRecovery(Token *tk, size_t current_idx);
	bool shouldRecoveryBaseExpr(Token *tk, Token *next_tk);
	bool shouldRecoveryBaseTerm(Token *tk, Token *next_tk);
	void recoveryArgument(Token *tk, size_t current_idx);
};

class BlockArgsFunctionCompleter : public SyntaxCompleter {
public:
	std::vector<std::string> *block_args_function_keywords;
	BlockArgsFunctionCompleter(void);
	bool complete(Token *tk, size_t current_idx);
	bool isBlockArgsFunction(Token *tk, int current_idx);
	bool isOnlyBlockArgFunction(Token *tk, int current_idx);
	bool isOperatorTarget(Token *tk);
	bool isBlockArgsFunctionKeyword(std::string target);
};

class Completer {
public:

	Completer(void);
	void templateEvaluatedFromLeft(Token *root, SyntaxCompleter *completer);
	void templateEvaluatedFromRight(Token *root, SyntaxCompleter *completer);
	void complete(Token *root);
	void completeTerm(Token *root);
	void completePointerExpr(Token *root);
	void completeBlockArgsFunctionExpr(Token *root);
	void completeIncDecGlobExpr(Token *root);
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
	void completeThreeTermOperatorExpr(Token *root);
	void completeAssignExpr(Token *root);
	void completeCommaArrowExpr(Token *root);
	void completeFunctionListExpr(Token *root);
	void completeReturn(Token *root);
	void completeAlphabetBitOperatorExpr(Token *root);
	void recoveryFunctionArgument(Token *root, SyntaxRecoverer *recoverer);
	void recoveryNamedUnaryOperatorsArgument(Token *root, SyntaxRecoverer *recoverer);
};

#define TYPE_match(ptr, T) typeid(*ptr) == typeid(T)
