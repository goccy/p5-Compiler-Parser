#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

RegexpMatchCompleter::RegexpMatchCompleter(void)
{
}

bool RegexpMatchCompleter::complete(Token *tk, size_t current_idx)
{
	if (isRegexpMatch(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool RegexpMatchCompleter::isRegexpMatch(Token *tk, int current_idx)
{
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	if (type(tk->tks[current_idx + 1]) == TokenType::RegOK ||
		type(tk->tks[current_idx + 1]) == TokenType::RegNot) return true;
	return false;
}
