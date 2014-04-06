#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

#define type(tk) tk->info.type
#define kind(tk) tk->info.kind

NamedUnaryOperatorCompleter::NamedUnaryOperatorCompleter(void)
{
	named_unary_keywords = new vector<string>();
	named_unary_keywords->push_back("defined");
	named_unary_keywords->push_back("exists");
	named_unary_keywords->push_back("delete");
	named_unary_keywords->push_back("length");
	named_unary_keywords->push_back("die");
	named_unary_keywords->push_back("ref");
	named_unary_keywords->push_back("shift");
	named_unary_keywords->push_back("lc");
	named_unary_keywords->push_back("write");
	//named_unary_keywords->push_back("bless");
	named_unary_keywords->push_back("sqrt");
	named_unary_keywords->push_back("abs");
	named_unary_keywords->push_back("int");
	named_unary_keywords->push_back("rand");
	named_unary_keywords->push_back("sin");
	named_unary_keywords->push_back("cos");
	named_unary_keywords->push_back("atan2");
	named_unary_keywords->push_back("chr");
	named_unary_keywords->push_back("close");
}

bool NamedUnaryOperatorCompleter::complete(Token *tk, size_t current_idx)
{
	if (isNamedUnaryFunction(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	} else if (isStatementController(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	} else if (isHandle(tk, current_idx)) {
		insertExpr(tk, current_idx, 2);
		return true;
	}
	return false;
}

bool NamedUnaryOperatorCompleter::isNamedUnaryFunction(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks       = tk->tks;
	Token *next_tk    = tks[current_idx + 1];
	if (isUnaryOperator(tk, current_idx) &&
		(next_tk->stype == SyntaxType::Expr ||
		 next_tk->stype == SyntaxType::Term ||
		 kind(next_tk)  == TokenKind::Function ||
		 kind(next_tk)  == TokenKind::Term)) return true;
	return false;
}

bool NamedUnaryOperatorCompleter::isUnaryOperator(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	Token **tks = tk->tks;
	Token *first_tk = tks[0];
	Token *current_tk = tks[current_idx];
	if (type(current_tk) == BuiltinFunc && isUnaryKeyword(current_tk->data)) return true;
	return false;
}

bool NamedUnaryOperatorCompleter::isUnaryKeyword(string target)
{
	bool ret = false;
	vector<string> list = *named_unary_keywords;
	vector<string>::iterator it = find(list.begin(), list.end(), target);
	if (it != list.end()){
		ret = true;
	}
	return ret;
}

bool NamedUnaryOperatorCompleter::isStatementController(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num == 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	if (isStatementControlKeyword(tks[current_idx]) &&
		type(tks[current_idx + 1]) == Key) return true;
	return false;
}

bool NamedUnaryOperatorCompleter::isStatementControlKeyword(Token *tk)
{
	using namespace TokenType;
	if (type(tk) == Redo || type(tk) == Next || type(tk) == Last) return true;
	return false;
}

bool NamedUnaryOperatorCompleter::isHandle(Token *tk, size_t current_idx)
{
	using namespace TokenType;
	if (tk->token_num == 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	TokenType::Type next_type = type(tks[current_idx + 1]);
	if (type(tks[current_idx]) == Handle &&
		(next_type == Key ||
		 next_type == Var ||
		 next_type == GlobalVar)) return true;
	return false;
}

bool NamedUnaryOperatorCompleter::recovery(Token *tk, size_t current_idx)
{
	if (shouldRecovery(tk, current_idx)) {
		recoveryArgument(tk, current_idx);
		return true;
	}
	return false;
}

bool NamedUnaryOperatorCompleter::shouldRecovery(Token *tk, size_t current_idx)
{
	if (tk->token_num <= 2) return false;
	if (tk->token_num <= current_idx + 1) return false;
	Token **tks = tk->tks;
	Token *current_tk = tks[current_idx];
	Token *next_tk    = tks[current_idx + 1];
	if (current_tk->stype == SyntaxType::Expr &&
		isUnaryKeyword(current_tk->tks[current_tk->token_num-1]->data) &&
		(next_tk->stype == SyntaxType::Expr ||
		 next_tk->stype == SyntaxType::Term ||
		 kind(next_tk)  == TokenKind::Term)) return true;
	return false;
}

void NamedUnaryOperatorCompleter::recoveryArgument(Token *tk, size_t current_idx)
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
