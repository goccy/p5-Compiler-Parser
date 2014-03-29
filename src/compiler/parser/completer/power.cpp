#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

PowerCompleter::PowerCompleter(void)
{

}

bool PowerCompleter::complete(Token *tk, size_t current_idx)
{
	if (isPower(tk, current_idx - 2)) {
		insertExpr(tk, current_idx - 2, 3);
		return true;
	}
	return false;
}

bool PowerCompleter::isPower(Token *tk, int current_idx)
{
	if (current_idx < 0) return false;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	if (type(tk->tks[current_idx + 1]) == TokenType::Exp) return true;
	return false;
}
