#include <parser.hpp>

namespace SyntaxType = Enum::Parser::Syntax;

TokenFactory::TokenFactory(void)
{

}

Token *TokenFactory::makeExprToken(Token **base, size_t start_idx, size_t grouping_num)
{
	Tokens *expr = new Tokens();
	for (size_t i = 0; i < grouping_num; i++) {
		expr->push_back(base[start_idx + i]);
	}
	Token *ret = new Token(expr);
	ret->stype = SyntaxType::Expr;
	return ret;
}

Token *TokenFactory::makeTermToken(Token **base, size_t start_idx, size_t grouping_num)
{
	Tokens *expr = new Tokens();
	for (size_t i = 0; i < grouping_num; i++) {
		expr->push_back(base[start_idx + i]);
	}
	Token *ret = new Token(expr);
	ret->stype = SyntaxType::Term;
	return ret;
}
