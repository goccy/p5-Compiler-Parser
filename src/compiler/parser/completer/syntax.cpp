#include <parser.hpp>

SyntaxCompleter::SyntaxCompleter(void)
{

}

void SyntaxCompleter::insertTerm(Token *tk, int idx, size_t grouping_num)
{
	TokenFactory token_factory;
	TokenManager token_manager;
	Token **tks = tk->tks;
	size_t end_idx = idx + grouping_num;
	tks[idx] = token_factory.makeTermToken(tks, idx, grouping_num);
	token_manager.closeToken(tk, idx + 1, end_idx, grouping_num);
}

void SyntaxCompleter::insertExpr(Token *tk, int idx, size_t grouping_num)
{
	TokenFactory token_factory;
	TokenManager token_manager;
	Token **tks = tk->tks;
	size_t end_idx = idx + grouping_num;
	tks[idx] = token_factory.makeExprToken(tks, idx, grouping_num);
	token_manager.closeToken(tk, idx + 1, end_idx, grouping_num);
}

bool SyntaxCompleter::complete(Token *, size_t)
{
	return false;
}
