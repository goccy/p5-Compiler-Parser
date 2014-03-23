#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

SpecialOperatorCompleter::SpecialOperatorCompleter(void)
{

}

bool SpecialOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isLeftIncDecExpr(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	} else if (isRightIncDecExpr(tk, current_idx)) {
		insertExpr(tk, current_idx - 1, 2);
		return true;
	}
	return false;
}

bool SpecialOperatorCompleter::isIncDecType(Token *tk)
{
	using namespace TokenType;
	if (type(tk) == Inc || type(tk) == Dec) return true;
	return false;
}

bool SpecialOperatorCompleter::isLeftIncDecExpr(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	if (isIncDecType(current_tk) &&
		(kind(next_tk) == TokenKind::Term ||
		 next_tk->stype == SyntaxType::Expr)) return true;
	return false;
}

bool SpecialOperatorCompleter::isRightIncDecExpr(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (current_idx <= 0)   return false;
	Token *current_tk = tk->tks[current_idx];
	Token *prev_tk    = tk->tks[current_idx - 1];
	if (isIncDecType(current_tk) &&
		(kind(prev_tk) == TokenKind::Term ||
		 prev_tk->stype == SyntaxType::Expr)) return true;
	return false;
}
