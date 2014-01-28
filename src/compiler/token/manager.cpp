#include <parser.hpp>

TokenManager::TokenManager(void)
{
}

void TokenManager::insertToken(Token *tk, size_t idx, Token *target)
{
	Token **temp = (Token **)realloc(tk->tks, sizeof(Token *) * (tk->token_num + 1));
	if (!temp) {
		fprintf(stderr, "[ERROR] Cannot allocate memrory");
		exit(EXIT_FAILURE);
	}
	tk->tks = temp;
	memmove(tk->tks+idx+1, tk->tks+idx, sizeof(Token *) * (tk->token_num - idx));
	tk->tks[idx] = target;
}

void TokenManager::closeToken(Token *tk, size_t base_idx, size_t start_idx, size_t close_num)
{
	Token **base = tk->tks;
	if (tk->token_num != start_idx) {
		memmove(base + base_idx, base + start_idx, sizeof(Token *) * (tk->token_num - start_idx));
	}
	for (size_t i = 1; i < close_num; i++) {
		base[tk->token_num - i] = NULL;
	}
	tk->token_num -= (close_num - 1);
}
