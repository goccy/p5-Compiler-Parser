#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

ShiftCompleter::ShiftCompleter(void)
{
}

bool ShiftCompleter::complete(Token *tk, size_t current_idx)
{
	if (isShiftOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool ShiftCompleter::isShiftOperator(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *next_tk = tk->tks[current_idx + 1];
	if (type(next_tk) == TokenType::LeftShift  ||
		type(next_tk) == TokenType::RightShift) return true;
	return false;
}
