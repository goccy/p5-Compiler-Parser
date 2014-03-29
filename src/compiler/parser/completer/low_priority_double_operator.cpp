#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

LowPriorityDoubleOperatorCompleter::LowPriorityDoubleOperatorCompleter(void)
{
}

bool LowPriorityDoubleOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isLowPriorityDoubleOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool LowPriorityDoubleOperatorCompleter::isLowPriorityDoubleOperator(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *next_tk = tk->tks[current_idx + 1];
	if (type(next_tk) == TokenType::Add       ||
		type(next_tk) == TokenType::Sub       ||
		type(next_tk) == TokenType::StringAdd) return true;
	return false;
}
