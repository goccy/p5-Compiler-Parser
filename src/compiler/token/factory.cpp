#include <parser.hpp>

namespace TokenType = Enum::Token::Type;
namespace TokenKind = Enum::Token::Kind;
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

Token *TokenFactory::makeListToken(Token *tk)
{
	Token *ret = new Token("()", tk->finfo);
	ret->info.type = TokenType::LeftParenthesis;
	ret->info.name = "LeftParenthesis";
	ret->info.kind = TokenKind::Symbol;
	return ret;
}
