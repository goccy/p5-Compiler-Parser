#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

TermCompleter::TermCompleter(void)
{

}

bool TermCompleter::complete(Token *root, size_t current_idx)
{
	using namespace TokenType;
	Token **tks = root->tks;
	if (isBasicTerm(root, current_idx)) {
		insertTerm(root, current_idx, 2);
		return true;
	} else if (isDereferenceTerm(root, current_idx)) {
		insertTerm(root, current_idx, 2);
		return true;
	}  else if (isRegexTerm(root, current_idx)) {
		if (root->token_num > current_idx + 4 && type(tks[current_idx+4]) == RegOpt) {
			insertTerm(root, current_idx, 5);
		} else {
			insertTerm(root, current_idx, 4);
		}
		return true;
	} else if (isRegexWithoutPrefixTerm(root, current_idx)) {
		if (root->token_num > current_idx + 3 && type(tks[current_idx+3]) == RegOpt) {
			insertTerm(root, current_idx, 4);
		} else {
			insertTerm(root, current_idx, 3);
		}
		return true;
	} else if (isRegexReplaceTerm(root, current_idx)) {
		if (root->token_num > current_idx + 6 && type(tks[current_idx+6]) == RegOpt) {
			insertTerm(root, current_idx, 7);
		} else {
			insertTerm(root, current_idx, 6);
		}
		return true;
	} else if (isRegexReplaceTermWithDoubleMiddleDelim(root, current_idx)) {
		if (root->token_num > current_idx + 7 && type(tks[current_idx+7]) == RegOpt) {
			insertTerm(root, current_idx, 8);
		} else {
			insertTerm(root, current_idx, 7);
		}
		return true;
	} else if (isHandleTerm(root, current_idx)) {
		insertTerm(root, current_idx, 3);
		return true;
	} else if (isAnonymousFunctionTerm(root, current_idx)) {
		insertTerm(root, current_idx, 2);
		return true;
	} else if (isCodeRefTerm(root, current_idx)) {
		insertTerm(root, current_idx, 3);
		return true;
	} else if (isFunctionCallWithParenthesis(root, current_idx)) {
		Token *tk = root->tks[current_idx];
		if (type(tk) == Key) {
			type(tk) = Call;
			kind(tk) = TokenKind::Function;
		}
		insertTerm(root, current_idx, 2);
		return true;
	} else if (isVariableDecl(root, current_idx)) {
		insertTerm(root, current_idx, 2);
		return true;
	} else if (isGlobTerm(root, current_idx)) {
		insertTerm(root, current_idx, 2);
		return true;
	}
	return false;
}

bool TermCompleter::isGlobTerm(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	Token *current_tk = tk->tks[current_idx];
	Token *next_tk    = tk->tks[current_idx + 1];
	if (type(current_tk) == Glob &&
		(type(next_tk) == Key ||
		 type(next_tk) == STDIN  ||
		 type(next_tk) == STDOUT ||
		 type(next_tk) == STDERR ||
		 kind(next_tk) == TokenKind::Term ||
		 next_tk->stype == SyntaxType::Expr)) return true;
	if (current_idx != 0) return false;
	if (type(current_tk) == Mul && type(next_tk) == Key) {
		current_tk->info.type = Glob;
		return true;
	}
	return false;
}

bool TermCompleter::isVariable(Token *tk)
{
	using namespace TokenType;
	TokenType::Type type = tk->info.type;
	if (type == Var            ||
		type == CodeVar        ||
		type == ArrayVar       ||
		type == ArgumentArray  ||
		type == HashVar        ||
		type == LocalVar       || 
		type == SpecificValue  ||
		type == LocalArrayVar  || 
		type == LocalHashVar   ||
		type == GlobalVar      ||
		type == GlobalArrayVar ||
		type == GlobalHashVar
	) return true;
	return false;
}

bool TermCompleter::isFunctionCall(Token *prev_tk, Token *tk)
{
	using namespace TokenType;
	if (prev_tk && 
		type(prev_tk) != UseDecl     &&
		type(prev_tk) != RequireDecl &&
		type(tk) == Namespace) return true;
	if (type(tk) == Key    ||
		type(tk) == Method ||
		type(tk) == Call   ||
		type(tk) == BuiltinFunc) return true;
	return false;
}

bool TermCompleter::isBasicTerm(Token *tk, size_t current_idx)
{
	/* $a[...] or $a{...} */
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks    = tk->tks;
	Token *next_tk = tk->tks[current_idx + 1];
	if (tks[0] && (type(tks[0]) == ForStmt || type(tks[0]) == ForeachStmt)) return false;
	if (!isVariable(tks[current_idx])) return false;
	if (!next_tk || next_tk->stype != SyntaxType::Expr) return false;
	return true;
}

bool TermCompleter::isDereferenceTerm(Token *tk, size_t current_idx)
{
	/* @{...} */
	if (tk->token_num <= 2) return false;
	Token **tks       = tk->tks;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	if (kind(current_tk) == TokenKind::Modifier &&
		next_tk && next_tk->stype == SyntaxType::Expr) return true;
	return false;
}

bool TermCompleter::isOperatorTarget(Token *tk)
{
	if (tk->stype == SyntaxType::Expr || tk->stype == SyntaxType::Term ||
		kind(tk)  == TokenKind::Term) return true;
	return false;
}

bool TermCompleter::isRegexTerm(Token *tk, size_t current_idx)
{
	/* m|...| */
	using namespace TokenType;
	if (tk->token_num <= 4) return false;
	Token **tks = tk->tks;
	Token *current_tk = tk->tks[current_idx];
	if (tk->token_num <= current_idx + 3) return false;
	if (current_idx == 0) return false;
	if (kind(current_tk) == TokenKind::RegPrefix &&
		type(tks[current_idx + 1]) == RegDelim &&
		type(tks[current_idx + 2]) == RegExp &&
		type(tks[current_idx + 3]) == RegDelim) return true;
	return false;
}

bool TermCompleter::isRegexWithoutPrefixTerm(Token *tk, size_t current_idx)
{
	/* /.../ */
	using namespace TokenType;
	if (current_idx == 0) return false;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token **tks = tk->tks;
	if (kind(tks[current_idx - 1]) != TokenKind::RegPrefix &&
		type(tks[current_idx])     == RegDelim &&
		type(tks[current_idx + 1]) == RegExp &&
		type(tks[current_idx + 2]) == RegDelim) return true;
	return false;
}

bool TermCompleter::isRegexReplaceTerm(Token *tk, size_t current_idx)
{
	/* s/ ... / ... / */
	using namespace TokenType;
	if (current_idx == 0)   return false;
	if (tk->token_num <= 6) return false;
	if (tk->token_num <= current_idx + 5) return false;
	Token **tks = tk->tks;
	if (kind(tks[current_idx])     == TokenKind::RegReplacePrefix &&
		type(tks[current_idx + 1]) == RegDelim &&
		type(tks[current_idx + 2]) == RegReplaceFrom &&
		type(tks[current_idx + 3]) == RegMiddleDelim &&
		type(tks[current_idx + 4]) == RegReplaceTo &&
		type(tks[current_idx + 5]) == RegDelim) return true;
	return false;
}

bool TermCompleter::isRegexReplaceTermWithDoubleMiddleDelim(Token *tk, size_t current_idx)
{
	/* s{ ... }{ ... } */
	using namespace TokenType;
	if (current_idx == 0)   return false;
	if (tk->token_num <= 7) return false;
	if (tk->token_num <= current_idx + 6) return false;
	Token **tks = tk->tks;
	if (kind(tks[current_idx])     == TokenKind::RegReplacePrefix &&
		type(tks[current_idx + 1]) == RegDelim &&
		type(tks[current_idx + 2]) == RegReplaceFrom &&
		type(tks[current_idx + 3]) == RegMiddleDelim &&
		type(tks[current_idx + 4]) == RegMiddleDelim &&
		type(tks[current_idx + 5]) == RegReplaceTo &&
		type(tks[current_idx + 6]) == RegDelim) return true;
	return false;
}

bool TermCompleter::isHandleTerm(Token *tk, size_t current_idx)
{
	/* <$fh> */
	using namespace TokenType;
	if (current_idx == 0) return false;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 2) return false;
	if (type(tk->tks[current_idx]) == HandleDelim  &&
		isOperatorTarget(tk->tks[current_idx + 1]) &&
		type(tk->tks[current_idx + 2]) == HandleDelim) return true;
	return false;
}

bool TermCompleter::isAnonymousFunctionTerm(Token *tk, size_t current_idx)
{
	/* sub { ... } */
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	if (type(tks[current_idx])      == FunctionDecl &&
		tks[current_idx + 1]->stype == SyntaxType::BlockStmt) return true;
	return false;
}

bool TermCompleter::isCodeRefTerm(Token *tk, size_t current_idx)
{
	/* \& */
	using namespace TokenType;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token **tks = tk->tks;
	if (type(tks[current_idx])     == Ref &&
		type(tks[current_idx + 1]) == CallDecl) return true;
	return false;
}

bool TermCompleter::isFunctionCallWithParenthesis(Token *tk, size_t current_idx)
{
	/* func(...) */
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	Token *prev_tk    = (current_idx > 0) ? tks[current_idx - 1] : NULL;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	if (isFunctionCall(prev_tk, current_tk) &&
		next_tk->stype == SyntaxType::Expr &&
		type(next_tk->tks[0]) == LeftParenthesis) return true;
	return false;
}

bool TermCompleter::isVariableDecl(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	if ((type(tk->tks[current_idx]) == VarDecl ||
		 type(tk->tks[current_idx]) == LocalVarDecl) &&
		isVariable(tk->tks[current_idx + 1])) return true;
	return false;
}
