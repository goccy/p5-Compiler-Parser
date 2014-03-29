#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

HighPriorityCompareOperatorCompleter::HighPriorityCompareOperatorCompleter(void)
{
}

bool HighPriorityCompareOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isHighPriorityCompareOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool HighPriorityCompareOperatorCompleter::isHighPriorityCompareOperator(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *next_tk = tk->tks[current_idx + 1];
	if (type(next_tk) == Greater            ||
		type(next_tk) == Less               ||
		type(next_tk) == GreaterEqual       ||
		type(next_tk) == LessEqual          ||
		type(next_tk) == StringGreater      ||
		type(next_tk) == StringLess         ||
		type(next_tk) == StringGreaterEqual ||
		type(next_tk) == StringLessEqual) return true;
	return false;
}
