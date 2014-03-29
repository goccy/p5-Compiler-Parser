#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

BitOperatorCompleter::BitOperatorCompleter(void)
{
}

bool BitOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isBitOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool BitOperatorCompleter::isBitOperator(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *next_tk = tk->tks[current_idx + 1];
	if (type(next_tk) == BitAnd ||
		type(next_tk) == BitOr  ||
		type(next_tk) == BitNot) return true;
	return false;
}
