#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

ReturnCompleter::ReturnCompleter(void)
{

}

bool ReturnCompleter::complete(Token *root, size_t current_idx)
{
	if (isReturnTerm(root, current_idx)) {
		insertTerm(root, current_idx, 2);
		return true;
	}
	return false;
}

bool ReturnCompleter::isOperatorTarget(Token *tk)
{
	if (tk->stype == SyntaxType::Expr || tk->stype == SyntaxType::Term ||
		kind(tk)  == TokenKind::Term) return true;
	return false;
}

bool ReturnCompleter::isReturnTerm(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	if (type(tk->tks[current_idx]) == Return &&
		isOperatorTarget(tk->tks[current_idx + 1])) return true;
	return false;
}
