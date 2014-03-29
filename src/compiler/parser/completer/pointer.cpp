#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

PointerCompleter::PointerCompleter(void)
{

}

bool PointerCompleter::complete(Token *tk, size_t current_idx)
{
	if (isPointer(tk, current_idx)) {
		insertExpr(tk, current_idx, 3);
		return true;
	}
	return false;
}

bool PointerCompleter::isPointer(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 3) return false;
	if (tk->token_num <= current_idx + 2) return false;
	if (type(tk->tks[current_idx + 1]) == TokenType::Pointer) return true;
	return false;
}

bool PointerCompleter::isPointerChainElement(Token *tk)
{
	using namespace TokenType;
	Type type = tk->info.type;
	if (type == GlobalVar               ||
		type == Var                     ||
		type == Method                  ||
		type == Pointer                 ||
		type == Namespace               ||
		type == SpecificKeyword         ||
		isPointerChainElementOfExpr(tk) ||
		isPointerChainElementOfTerm(tk)
	) return true;
	return false;
}

bool PointerCompleter::isPointerChainElementOfExpr(Token *tk)
{
	using namespace TokenType;
	if (tk->stype != SyntaxType::Expr) return false;
	Token *first_tk = tk->tks[0];
	if (type(first_tk) == LeftBrace         ||
		type(first_tk) == LeftBracket       ||
		type(first_tk) == ScalarDereference ||
		type(first_tk) == ArrayDereference) return true;
	return false;
}

bool PointerCompleter::isPointerChainElementOfTerm(Token *tk)
{
	if (tk->stype != SyntaxType::Term) return false;
	Token *first_tk = tk->tks[0];
	if (kind(first_tk) != TokenKind::RegPrefix) return true;
	return false;
}

bool PointerCompleter::notContinuousPointerChainElement(Token *tk)
{
	using namespace TokenType;
	Type type = tk->info.type;
	SyntaxType::Type stype = tk->stype;
	if (type == Namespace         ||
		type == GlobalVar         ||
		type == Var               ||
		type == ScalarDereference ||
		type == Comma             ||
		type == Arrow             ||
		type == ArrayDereference  ||
		notContinuousPointerChainElementOfExpr(tk)
	) return true;
	return false;
}

bool PointerCompleter::notContinuousPointerChainElementOfExpr(Token *tk)
{
	using namespace TokenType;
	if (tk->stype != SyntaxType::Expr) return false;
	Token *first_tk = tk->tks[0];
	if (type(first_tk) == ArrayDereference ||
		type(first_tk) == ScalarDereference) return true;
	return false;
}

void PointerCompleter::insertPointerToken(Token *root)
{
	using namespace TokenType;
RESTART:;
	for (size_t i = 0; i < root->token_num; i++) {
		if (isPointerChainElement(root->tks[i])) {
			i = _insertPointerToken(root, i);
		}
		if (i < root->token_num && root->tks[i]->token_num > 0) {
			insertPointerToken(root->tks[i]);
		}
	}
}

bool PointerCompleter::canContinuousPointerChain(Token *tk, Token *next_tk)
{
	using namespace TokenType;
	if (tk->stype == SyntaxType::Expr &&
		notContinuousPointerChainElement(next_tk)) return false;
	if (notContinuousPointerChainElement(tk) &&
		notContinuousPointerChainElement(next_tk)) return false;
	if (type(tk) == Pointer) return false;
	if (isArrayOrHashExpr(tk, next_tk)) return false;
	if (next_tk->stype        == SyntaxType::Term &&
		type(next_tk->tks[0]) == BuiltinFunc) return false;
	if (type(next_tk) == Pointer) return false;

	return true;
}

bool PointerCompleter::isArrayOrHashExpr(Token *tk, Token *next_tk)
{
	using namespace TokenType;
	if (tk->info.type != Var && tk->info.type != GlobalVar) return false;
	if (next_tk->stype != SyntaxType::Expr) return false;
	Type type = type(next_tk->tks[0]);
	if (type == LeftBracket || type == LeftBrace) return true;
	return false;
}

template<typename T> T **Array_insert(T **array, size_t array_size, size_t idx, T *ptr)
{
	T **temp = (T **)realloc(array, sizeof(T *) * (array_size + 1));
	if (!temp) {
		fprintf(stderr, "[ERROR] Cannot allocate memrory");
		exit(EXIT_FAILURE);
	}
	array = temp;
	memmove(array+idx+1, array+idx, sizeof(T *) * (array_size - idx));
	array[idx] = ptr;
	return array;
}

size_t PointerCompleter::_insertPointerToken(Token *tk, size_t current_idx)
{
	size_t i = current_idx;
	for (; i + 1 < tk->token_num && isPointerChainElement(tk->tks[i+1]); i += 2) {
		Token *current_tk = tk->tks[i];
		Token *next_tk    = tk->tks[i+1];
		if (canContinuousPointerChain(current_tk, next_tk)) {
			TokenFactory token_factory;
			Token *pointer = token_factory.makePointerToken(next_tk);
			tk->tks = Array_insert(tk->tks, tk->token_num, i + 1, pointer);
			tk->token_num++;
		}
	}
	return i;
}
