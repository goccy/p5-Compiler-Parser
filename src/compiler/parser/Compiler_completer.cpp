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
	PowerCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeSingleTermOperatorExpr(Token *root)
{
	SingleTermOperatorCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeRegexpMatchExpr(Token *root)
{
	RegexpMatchCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeHighPriorityDoubleOperatorExpr(Token *root)
{
	HighPriorityDoubleOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeLowPriorityDoubleOperatorExpr(Token *root)
{
	LowPriorityDoubleOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeShiftOperatorExpr(Token *root)
{
	ShiftCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeNamedUnaryOperators(Token *root)
{
	NamedUnaryOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
	recoveryNamedUnaryOperatorsArgument(root, &completer);
}

void Completer::completeHighPriorityCompareOperatorExpr(Token *root)
{
	HighPriorityCompareOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeLowPriorityCompareOperatorExpr(Token *root)
{
	LowPriorityCompareOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeBitOperatorExpr(Token *root)
{
	BitOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeThreeTermOperatorExpr(Token *root)
{
	ThreeTermOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeAndOrOperatorExpr(Token *root)
{
	AndOperatorCompleter and_completer;
	templateEvaluatedFromLeft(root, &and_completer);
	OrOperatorCompleter or_completer;
	templateEvaluatedFromLeft(root, &or_completer);
}

void Completer::completeAssignExpr(Token *root)
{
	AssignCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeCommaArrowExpr(Token *root)
{
	ArrowCompleter arrow_completer;
	templateEvaluatedFromLeft(root, &arrow_completer);
	CommaCompleter comma_completer;
	templateEvaluatedFromLeft(root, &comma_completer);
}

void Completer::completeFunctionListExpr(Token *root)
{
	FunctionListCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
	recoveryFunctionArgument(root, &completer);
}

void Completer::completeAlphabetBitOperatorExpr(Token *root)
{
	AlphabetBitOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
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
