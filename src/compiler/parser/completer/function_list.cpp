#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

FunctionListCompleter::FunctionListCompleter(void)
{

}

bool FunctionListCompleter::complete(Token *tk, size_t current_idx)
{
	if (isFunctionCallWithoutParenthesis(tk, current_idx)) {
		Token *current_tk = tk->tks[current_idx];
		if (type(current_tk) == TokenType::Key) {
			type(current_tk) = TokenType::Call;
			kind(current_tk) = TokenKind::Function;
		}
		insertExpr(tk, current_idx, 2);
		return true;
	} else if (isFunctionList(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	}
	return false;
}

bool FunctionListCompleter::isPrintFunction(Token *tk)
{
	if (!tk) return false;
	if (type(tk) != TokenType::BuiltinFunc) return false;
	if (tk->data != "print") return false;
	return true;
}

bool FunctionListCompleter::isFunctionCallWithoutParenthesis(Token *tk, size_t current_idx)
{
	/* key ... */
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	Token *prev_tk    = (current_idx > 0) ? tks[current_idx - 1] : NULL;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	if (!isPrintFunction(prev_tk) &&
		type(current_tk) == TokenType::Key &&
		(kind(next_tk) == TokenKind::Term ||
		 next_tk->stype == SyntaxType::Expr)) return true;
	return false;
}

bool FunctionListCompleter::isFunctionList(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	Token *next_tk = tks[current_idx + 1];
	if (type(tks[current_idx]) != BuiltinFunc) return false;
	if (next_tk->stype        == SyntaxType::Expr &&
		type(next_tk->tks[0]) != LeftBrace) return true;
	if (type(next_tk)  == STDIN  ||
		type(next_tk)  == STDOUT ||
		type(next_tk)  == STDERR ||
		type(next_tk)  == ShortHashDereference   ||
		type(next_tk)  == ShortArrayDereference  ||
		type(next_tk)  == ShortScalarDereference ||
		kind(next_tk)  == TokenKind::Term ||
		next_tk->stype == SyntaxType::Term) return true;
	return false;
}

bool FunctionListCompleter::recovery(Token *tk, size_t current_idx)
{
	if (shouldRecovery(tk, current_idx)) {
		recoveryArgument(tk, current_idx);
		return true;
	}
	return false;
}

bool FunctionListCompleter::shouldRecovery(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	if (shouldRecoveryBaseExpr(current_tk, next_tk) ||
		shouldRecoveryBaseTerm(current_tk, next_tk)) return true;
	return false;
}

bool FunctionListCompleter::shouldRecoveryBaseExpr(Token *tk, Token *next_tk)
{
	using namespace TokenType;
	if (tk->stype != SyntaxType::Expr) return false;
	if (type(tk->tks[0]) == LeftBrace) return false;
	if (next_tk->stype == SyntaxType::Expr ||
		next_tk->stype == SyntaxType::Term ||
		type(next_tk)  == ArrayVar) return true;
	return false;
}

bool FunctionListCompleter::shouldRecoveryBaseTerm(Token *tk, Token *next_tk)
{
	using namespace TokenType;
	if (tk->stype != SyntaxType::Term) return false;
	if (next_tk->stype == SyntaxType::Term ||
		type(next_tk)  == ArrayVar) return true;
	return false;
}

void FunctionListCompleter::recoveryArgument(Token *tk, size_t current_idx)
{
	Token **tks = tk->tks;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	current_tk->tks = (Token **)safe_realloc(current_tk->tks, (current_tk->token_num + 1) * PTR_SIZE);
	current_tk->tks[current_tk->token_num++] = next_tk;
	Tokens *recovery_tks = new Tokens();
	for (size_t i = 0; i < tk->token_num; i++) {
		if (i == current_idx + 1) continue;
		recovery_tks->push_back(tks[i]);
	}
	size_t size = recovery_tks->size();
	tks = (Token **)safe_realloc(tks, size * PTR_SIZE);
	for (size_t i = 0; i < size; i++) {
		tks[i] = recovery_tks->at(i);
	}
	tk->token_num = size;
}
