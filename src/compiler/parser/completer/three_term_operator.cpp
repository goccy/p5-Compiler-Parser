#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

ThreeTermOperatorCompleter::ThreeTermOperatorCompleter(void)
{

}

bool ThreeTermOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isThreeTermOperator(tk, current_idx)) {
		insertExpr(tk, current_idx - 5, 5);
		return true;
	}
	return false;
}

bool ThreeTermOperatorCompleter::isThreeTermOperator(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 4) return false;
	if (current_idx   <= 4) return false;
	Token **tks = tk->tks;
	if (tks[current_idx - 1]->stype != SyntaxType::BlockStmt &&
		type(tks[current_idx - 2])  == TokenType::Colon &&
		tks[current_idx - 3]->stype != SyntaxType::BlockStmt &&
		type(tks[current_idx - 4])  == TokenType::ThreeTermOperator &&
		tks[current_idx - 5]->stype != SyntaxType::BlockStmt) return true;
	return false;
}
