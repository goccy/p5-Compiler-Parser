#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

SingleTermOperatorCompleter::SingleTermOperatorCompleter(void)
{

}

bool SingleTermOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isSimpleSingleTermOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	} else if (isSingleTermOperator(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	}
	return false;
}

bool SingleTermOperatorCompleter::isSimpleSingleTermOperator(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	TokenType::Type type = type(tk->tks[current_idx]);
	if ((type == IsNot || type == Not || type == Ref || type == BitNot) &&
		type(tk->tks[current_idx + 1]) != CallDecl) return true;
	return false;
}

bool SingleTermOperatorCompleter::isSingleTermOperator(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (current_idx <= 0)   return false;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	TokenType::Type type = type(tk->tks[current_idx]);
	Token *prev_tk = tk->tks[current_idx - 1];
	if ((type == Add    ||
		 type == Sub    ||
		 type == BitAnd ||
		 type == PolymorphicCompare ||
		 type == ArraySize) && !isOperatorTarget(prev_tk)) return true;
	return false;
}

bool SingleTermOperatorCompleter::isOperatorTarget(Token *tk)
{
	using namespace TokenType;
	if (kind(tk)  == TokenKind::Term  ||
		tk->stype == SyntaxType::Term ||
		tk->stype == SyntaxType::Expr) return true;
	return false;
}
