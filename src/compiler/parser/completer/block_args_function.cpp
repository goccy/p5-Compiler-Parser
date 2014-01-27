#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

BlockArgsFunctionCompleter::BlockArgsFunctionCompleter(void)
{
	block_args_function_keywords = new vector<string>();
	block_args_function_keywords->push_back("map");
	block_args_function_keywords->push_back("grep");
}

bool BlockArgsFunctionCompleter::complete(Token *tk, size_t current_idx)
{
	if (isBlockArgsFunction(tk, current_idx - 2)) {
		insertExpr(tk, current_idx - 2, 3);
		return true;
	} else if (isOnlyBlockArgFunction(tk, current_idx - 1)) {
		insertExpr(tk, current_idx - 1, 2);
		return true;
	}
	return false;
}

bool BlockArgsFunctionCompleter::isBlockArgsFunction(Token *tk, int current_idx)
{
	using namespace TokenType;
	if (current_idx < 0)    return false;
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	Token *current_tk = tk->tks[current_idx];
	Token *next_tk    = tk->tks[current_idx + 1];
	if (type(current_tk) == BuiltinFunc && isBlockArgsFunctionKeyword(current_tk->data)) {
		if ((next_tk->stype == SyntaxType::Expr && type(next_tk->tks[0]) == LeftBrace) &&
			isOperatorTarget(tk->tks[current_idx + 2])) return true;
	}
	return false;
}

bool BlockArgsFunctionCompleter::isOnlyBlockArgFunction(Token *tk, int current_idx)
{
	using namespace TokenType;
	if (current_idx < 0)    return false;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token *current_tk = tk->tks[current_idx];
	Token *next_tk    = tk->tks[current_idx + 1];
	if (type(current_tk) == BuiltinFunc || type(current_tk) == Key) {
		if (next_tk->stype == SyntaxType::Expr && type(next_tk->tks[0]) == LeftBrace) return true;
	}
	return false;
}

bool BlockArgsFunctionCompleter::isOperatorTarget(Token *tk)
{
	if (tk->stype == SyntaxType::Expr ||
		tk->stype == SyntaxType::Term ||
		kind(tk)  == TokenKind::Term) return true;
	return false;
}

bool BlockArgsFunctionCompleter::isBlockArgsFunctionKeyword(string target)
{
	bool ret = false;
	vector<string> list = *block_args_function_keywords;
	vector<string>::iterator it = find(list.begin(), list.end(), target);
	if (it != list.end()){
		ret = true;
	}
	return ret;
}
