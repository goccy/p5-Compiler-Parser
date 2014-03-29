#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

AndOperatorCompleter::AndOperatorCompleter(void)
{
}

bool AndOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isAndOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool AndOperatorCompleter::isAndOperator(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *next_tk = tk->tks[current_idx + 1];
	if (type(next_tk) == TokenType::And) return true;
	return false;
}

OrOperatorCompleter::OrOperatorCompleter(void)
{
}

bool OrOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isOrOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool OrOperatorCompleter::isOrOperator(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *next_tk = tk->tks[current_idx + 1];
	if (type(next_tk) == TokenType::Or) return true;
	return false;
}
