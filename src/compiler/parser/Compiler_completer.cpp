#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

Completer::Completer(void)
{
}

void Completer::complete(Token *root)
{
	completeTerm(root);
	// ->
	completePointerExpr(root);
	// ++, --, *
	completeIncDecGlobExpr(root);
	// **
	completePowerExpr(root);
	// !, ~, \, +, -, &, ~~
	completeSingleTermOperatorExpr(root);
	// =~, !~
	completeRegexpMatchExpr(root);
	// *, /, %, x
	completeHighPriorityDoubleOperatorExpr(root);
	// +, -, .
	completeLowPriorityDoubleOperatorExpr(root);
	// <<, >>
	completeShiftOperatorExpr(root);
	//handler, builtin functions
	completeNamedUnaryOperators(root);
	// <, >, <=, >=, lt, gt, le, ge
	completeHighPriorityCompareOperatorExpr(root);
	// ==, !=, <=>, eq, ne, cmp, ~~
	completeLowPriorityCompareOperatorExpr(root);
	// &, |, ^
	completeBitOperatorExpr(root);
	// &&, ||
	completeAndOrOperatorExpr(root);
	//?:
	completeThreeTermOperatorExpr(root);
	// =, +=, -=, *=, ...
	completeAssignExpr(root);
	// ,, =>
	completeCommaArrowExpr(root);
	// function args ....
	completeFunctionListExpr(root);
	//recoveryFunctionArgument(root);
	completeBlockArgsFunctionExpr(root);
	completeReturn(root);
	// not, and, or, xor
	completeAlphabetBitOperatorExpr(root);
}

void Completer::insertExpr(Token *tk, int idx, size_t grouping_num)
{
	TokenFactory token_factory;
	TokenManager token_manager;
	Token **tks = tk->tks;
	size_t end_idx = idx + grouping_num;
	tks[idx] = token_factory.makeExprToken(tks, idx, grouping_num);
	token_manager.closeToken(tk, idx + 1, end_idx, grouping_num);
}

void Completer::templateEvaluatedFromLeft(Token *root, SyntaxCompleter *completer)
{
RESTART:;
	for (size_t i = 0; i < root->token_num; i++) {
		if (completer->complete(root, i)) {
			goto RESTART;
		}
		if (root->tks[i]->token_num > 0) {
			templateEvaluatedFromLeft(root->tks[i], completer);
		}
	}
}

void Completer::templateEvaluatedFromRight(Token *root, SyntaxCompleter *completer)
{
RESTART:;
	for (int i = root->token_num - 1; i >= 0; i--) {
		if (completer->complete(root, i)) {
			goto RESTART;
		}
		if (root->tks[i]->token_num > 0) {
			templateEvaluatedFromRight(root->tks[i], completer);
		}
	}
}

void Completer::completeExprFromLeft(Token *root, TokenType::Type type)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
	TokenFactory token_factory;
RESTART:;
	for (size_t i = 0; i < tk_n; i++) {
		if (tk_n > 3 && tk_n > i+2 && tks[i+1]->info.type == type) {
			insertExpr(root, i, 3);
			tk_n -= 2;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeExprFromLeft(tks[i], type);
		}
	}
}

void Completer::completeExprFromRight(Token *root, TokenType::Type type)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (int i = tk_n - 1; i >= 0; i--) {
		if (tk_n > 3 && i-2 >= 0 && tks[i-1]->info.type == type) {
			insertExpr(root, i - 2, 3);
			tk_n -= 2;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeExprFromRight(tks[i], type);
		}
	}
}

void Completer::completeExprFromRight(Token *root, TokenKind::Kind kind)
{
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (int i = tk_n - 1; i >= 0; i--) {
		if (tk_n > 3 && i-2 >= 0 && tks[i-1]->info.kind == kind) {
			insertExpr(root, i - 2, 3);
			tk_n -= 2;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeExprFromRight(tks[i], kind);
		}
	}
}

void Completer::completePointerExpr(Token *root)
{
	PointerCompleter completer;
	completer.insertPointerToken(root);
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeBlockArgsFunctionExpr(Token *root)
{
	BlockArgsFunctionCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeIncDecGlobExpr(Token *root)
{
	SpecialOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completePowerExpr(Token *root)
{
	completeExprFromRight(root, TokenType::Exp);
}

void Completer::completeSingleTermOperatorExpr(Token *root)
{
	// !, ~, \, +, -
	SingleTermOperatorCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeRegexpMatchExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::RegOK);
	completeExprFromLeft(root, TokenType::RegNot);
}
void Completer::completeHighPriorityDoubleOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Mul);
	completeExprFromLeft(root, TokenType::Div);
	completeExprFromLeft(root, TokenType::Mod);
	completeExprFromLeft(root, TokenType::StringMul);
	completeExprFromLeft(root, TokenType::Slice);
}

void Completer::completeLowPriorityDoubleOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Add);
	completeExprFromLeft(root, TokenType::Sub);
	completeExprFromLeft(root, TokenType::StringAdd);
}

void Completer::completeShiftOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::LeftShift);
	completeExprFromLeft(root, TokenType::RightShift);
}

void Completer::completeNamedUnaryOperators(Token *root)
{
	NamedUnaryOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
	recoveryNamedUnaryOperatorsArgument(root, &completer);
}

void Completer::completeHighPriorityCompareOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Greater);
	completeExprFromLeft(root, TokenType::Less);
	completeExprFromLeft(root, TokenType::GreaterEqual);
	completeExprFromLeft(root, TokenType::LessEqual);
	completeExprFromLeft(root, TokenType::StringGreater);
	completeExprFromLeft(root, TokenType::StringLess);
	completeExprFromLeft(root, TokenType::StringGreaterEqual);
	completeExprFromLeft(root, TokenType::StringLessEqual);
}

void Completer::completeLowPriorityCompareOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::EqualEqual);
	completeExprFromLeft(root, TokenType::NotEqual);
	completeExprFromLeft(root, TokenType::Compare);
	completeExprFromLeft(root, TokenType::StringEqual);
	completeExprFromLeft(root, TokenType::StringNotEqual);
	completeExprFromLeft(root, TokenType::StringCompare);
	//completeExprFromLeft(root, TokenType::PolymorphicCompare);
}

void Completer::completeBitOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::BitAnd);
	completeExprFromLeft(root, TokenType::BitOr);
	completeExprFromLeft(root, TokenType::BitNot);
}

void Completer::completeThreeTermOperatorExpr(Token *root)
{
	ThreeTermOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeAndOrOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::And);
	completeExprFromLeft(root, TokenType::Or);
}

void Completer::completeAssignExpr(Token *root)
{
	completeExprFromRight(root, TokenKind::Assign);
}

void Completer::completeCommaArrowExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Arrow);
	completeExprFromLeft(root, TokenType::Comma);
}

void Completer::completeFunctionListExpr(Token *root)
{
	FunctionListCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
	recoveryFunctionArgument(root, &completer);
}

void Completer::completeAlphabetBitOperatorExpr(Token *root)
{
	completeExprFromRight(root, TokenType::Not);
	completeExprFromLeft(root, TokenType::AlphabetAnd);
	completeExprFromLeft(root, TokenType::AlphabetOr);
	completeExprFromLeft(root, TokenType::AlphabetXOr);
}

void Completer::completeTerm(Token *root)
{
	TermCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeReturn(Token *root)
{
	ReturnCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::recoveryNamedUnaryOperatorsArgument(Token *root, SyntaxRecoverer *recoverer)
{
RESTART:;
	for (size_t i = 0; i < root->token_num; i++) {
		if (recoverer->recovery(root, i)) {
			goto RESTART;
		}
		if (root->tks[i]->token_num > 0) {
			recoveryNamedUnaryOperatorsArgument(root->tks[i], recoverer);
		}
	}
}

void Completer::recoveryFunctionArgument(Token *root, SyntaxRecoverer *recoverer)
{
RESTART:;
	for (size_t i = 0; i < root->token_num; i++) {
		if (recoverer->recovery(root, i)) {
			goto RESTART;
		}
		if (root->tks[i]->token_num > 0) {
			recoveryFunctionArgument(root->tks[i], recoverer);
		}
	}
}
