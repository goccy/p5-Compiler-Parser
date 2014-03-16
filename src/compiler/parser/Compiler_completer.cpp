#include <parser.hpp>

using namespace std;
namespace TokenType = Enum::Token::Type;
namespace SyntaxType = Enum::Parser::Syntax;
namespace TokenKind = Enum::Token::Kind;

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

Completer::Completer(void)
{
	named_unary_keywords = new vector<string>();
	named_unary_keywords->push_back("defined");
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

void Completer::complete(Token *root)
{
	completeTerm(root);
	// ->
	completePointerExpr(root);
	// ++, --, *
	completeIncDecGlobExpr(root);
	// **
	completePowerExpr(root);
	// !, ~, \, +, -, &, ~~
	completeSingleTermOperatorExpr(root);
	// =~, !~
	completeRegexpMatchExpr(root);
	// *, /, %, x
	completeHighPriorityDoubleOperatorExpr(root);
	// +, -, .
	completeLowPriorityDoubleOperatorExpr(root);
	// <<, >>
	completeShiftOperatorExpr(root);
	//handler, builtin functions
	completeNamedUnaryOperators(root);
	recoveryNamedUnaryOperatorsArgument(root);
	// <, >, <=, >=, lt, gt, le, ge
	completeHighPriorityCompareOperatorExpr(root);
	// ==, !=, <=>, eq, ne, cmp, ~~
	completeLowPriorityCompareOperatorExpr(root);
	// &, |, ^
	completeBitOperatorExpr(root);
	// &&, ||
	completeAndOrOperatorExpr(root);
	//?:
	completeThreeTermOperatorExpr(root);
	// =, +=, -=, *=, ...
	completeAssignExpr(root);
	// ,, =>
	completeCommaArrowExpr(root);
	// function args ....
	completeFunctionListExpr(root);
	recoveryFunctionArgument(root);
	completeBlockArgsFunctionExpr(root);
	completeReturn(root);
	// not, and, or, xor
	completeAlphabetBitOperatorExpr(root);
}

void Completer::insertExpr(Token *tk, int idx, size_t grouping_num)
{
	TokenFactory token_factory;
	TokenManager token_manager;
	Token **tks = tk->tks;
	size_t end_idx = idx + grouping_num;
	tks[idx] = token_factory.makeExprToken(tks, idx, grouping_num);
	token_manager.closeToken(tk, idx + 1, end_idx, grouping_num);
}

void Completer::templateEvaluatedFromLeft(Token *root, SyntaxCompleter *completer)
{
RESTART:;
	for (size_t i = 0; i < root->token_num; i++) {
		if (completer->complete(root, i)) {
			goto RESTART;
		}
		if (root->tks[i]->token_num > 0) {
			templateEvaluatedFromLeft(root->tks[i], completer);
		}
	}
}

void Completer::templateEvaluatedFromRight(Token *root, SyntaxCompleter *completer)
{
RESTART:;
	for (int i = root->token_num - 1; i >= 0; i--) {
		if (completer->complete(root, i)) {
			goto RESTART;
		}
		if (root->tks[i]->token_num > 0) {
			templateEvaluatedFromRight(root->tks[i], completer);
		}
	}
}

void Completer::completeExprFromLeft(Token *root, TokenType::Type type)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
	TokenFactory token_factory;
RESTART:;
	for (size_t i = 0; i < tk_n; i++) {
		if (tk_n > 3 && tk_n > i+2 && tks[i+1]->info.type == type) {
			insertExpr(root, i, 3);
			tk_n -= 2;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeExprFromLeft(tks[i], type);
		}
	}
}

void Completer::completeExprFromRight(Token *root, TokenType::Type type)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (int i = tk_n - 1; i >= 0; i--) {
		if (tk_n > 3 && i-2 >= 0 && tks[i-1]->info.type == type) {
			insertExpr(root, i - 2, 3);
			tk_n -= 2;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeExprFromRight(tks[i], type);
		}
	}
}

void Completer::completeExprFromRight(Token *root, TokenKind::Kind kind)
{
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (int i = tk_n - 1; i >= 0; i--) {
		if (tk_n > 3 && i-2 >= 0 && tks[i-1]->info.kind == kind) {
			insertExpr(root, i - 2, 3);
			tk_n -= 2;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeExprFromRight(tks[i], kind);
		}
	}
}

void Completer::completePointerExpr(Token *root)
{
	insertPointerToken(root);
	completeExprFromLeft(root, TokenType::Pointer);
}

bool Completer::isPointerChain(Token *tk)
{
	using namespace TokenType;
	Type type = tk->info.type;
	SyntaxType::Type stype = tk->stype;
	if (type == GlobalVar || type == Var || type == Method ||
		type == Pointer || type == Namespace || type == SpecificKeyword ||
		(stype == SyntaxType::Expr &&
		 (tk->tks[0]->info.type == LeftBrace ||
		  tk->tks[0]->info.type == LeftBracket ||
		  tk->tks[0]->info.type == ScalarDereference  ||
		  tk->tks[0]->info.type == ArrayDereference)) ||
		(stype == SyntaxType::Term && tk->tks[0]->info.kind != TokenKind::RegPrefix)) {
		return true;
	}
	return false;
}

bool Completer::isArrayOrHashExpr(size_t start_idx, size_t idx, Token *tk, Token *next_tk)
{
	using namespace TokenType;
	if (start_idx != idx) return false;
	if (tk->info.type != Var && tk->info.type != GlobalVar) return false;
	if (next_tk->stype != SyntaxType::Expr) return false;
	Type type = next_tk->tks[0]->info.type;
	if (type == LeftBracket || type == LeftBrace) return true;
	return false;
}

bool Completer::notNeedsPointer(Token *tk)
{
	using namespace TokenType;
	Type type = tk->info.type;
	SyntaxType::Type stype = tk->stype;
	if (type == Namespace         ||
		type == GlobalVar         ||
		type == Var               ||
		type == ScalarDereference ||
		type == ArrayDereference) return true;
	if (stype == SyntaxType::Expr &&
		(tk->tks[0]->info.type == ArrayDereference ||
		 tk->tks[0]->info.type == ScalarDereference)) return true;
	return false;
}

void Completer::insertPointerToken(Token *root)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = tks[i];
		if (isPointerChain(tk)) {
			size_t start_idx = i;
			while (i + 1 < tk_n && isPointerChain(tks[i+1])) {
				tk = tks[i];
				Token *next_tk = tks[i+1];
				if ((tk->stype == SyntaxType::Expr && notNeedsPointer(next_tk)) ||
					(notNeedsPointer(tk) && notNeedsPointer(next_tk))) {
				} else if (tk->info.type != Pointer && !isArrayOrHashExpr(start_idx, i, tks[i], next_tk) &&
					!(next_tk->stype == SyntaxType::Term && next_tk->tks[0]->info.type == BuiltinFunc) &&
					next_tk->info.type != Pointer) {
					Token *pointer = new Token("->", next_tk->finfo);
					pointer->info.type = TokenType::Pointer;
					pointer->info.name = "Pointer";
					pointer->info.kind = TokenKind::Operator;
					tks = Array_insert(tks, tk_n, i + 1, pointer);
					root->tks = tks;
					tk_n++;
					root->token_num = tk_n;
				}
				i += 2;
			}
		}
		if (i < tk_n && tks[i]->token_num > 0) {
			insertPointerToken(tks[i]);
		}
	}
}

void Completer::completeBlockArgsFunctionExpr(Token *root)
{
	BlockArgsFunctionCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeIncDecGlobExpr(Token *root)
{
	SpecialOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completePowerExpr(Token *root)
{
	completeExprFromRight(root, TokenType::Exp);
}

void Completer::completeSingleTermOperatorExpr(Token *root)
{
	// !, ~, \, +, -
	SingleTermOperatorCompleter completer;
	templateEvaluatedFromRight(root, &completer);
}

void Completer::completeRegexpMatchExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::RegOK);
	completeExprFromLeft(root, TokenType::RegNot);
}
void Completer::completeHighPriorityDoubleOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Mul);
	completeExprFromLeft(root, TokenType::Div);
	completeExprFromLeft(root, TokenType::Mod);
	completeExprFromLeft(root, TokenType::StringMul);
	completeExprFromLeft(root, TokenType::Slice);
}

void Completer::completeLowPriorityDoubleOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Add);
	completeExprFromLeft(root, TokenType::Sub);
	completeExprFromLeft(root, TokenType::StringAdd);
}

void Completer::completeShiftOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::LeftShift);
	completeExprFromLeft(root, TokenType::RightShift);
}

void Completer::completeNamedUnaryOperators(Token *root)
{
	NamedUnaryOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

bool Completer::isUnaryKeyword(string target)
{
	bool ret = false;
	vector<string> list = *named_unary_keywords;
	vector<string>::iterator it = find(list.begin(), list.end(), target);
	if (it != list.end()){
		ret = true;
	}
	return ret;
}

void Completer::completeHighPriorityCompareOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Greater);
	completeExprFromLeft(root, TokenType::Less);
	completeExprFromLeft(root, TokenType::GreaterEqual);
	completeExprFromLeft(root, TokenType::LessEqual);
	completeExprFromLeft(root, TokenType::StringGreater);
	completeExprFromLeft(root, TokenType::StringLess);
	completeExprFromLeft(root, TokenType::StringGreaterEqual);
	completeExprFromLeft(root, TokenType::StringLessEqual);
}

void Completer::completeLowPriorityCompareOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::EqualEqual);
	completeExprFromLeft(root, TokenType::NotEqual);
	completeExprFromLeft(root, TokenType::Compare);
	completeExprFromLeft(root, TokenType::StringEqual);
	completeExprFromLeft(root, TokenType::StringNotEqual);
	completeExprFromLeft(root, TokenType::StringCompare);
	//completeExprFromLeft(root, TokenType::PolymorphicCompare);
}

void Completer::completeBitOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::BitAnd);
	completeExprFromLeft(root, TokenType::BitOr);
	completeExprFromLeft(root, TokenType::BitNot);
}

void Completer::completeThreeTermOperatorExpr(Token *root)
{
	ThreeTermOperatorCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeAndOrOperatorExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::And);
	completeExprFromLeft(root, TokenType::Or);
}

void Completer::completeAssignExpr(Token *root)
{
	completeExprFromRight(root, TokenKind::Assign);
}

void Completer::completeCommaArrowExpr(Token *root)
{
	completeExprFromLeft(root, TokenType::Arrow);
	completeExprFromLeft(root, TokenType::Comma);
}

void Completer::completeFunctionListExpr(Token *root)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = tks[i];
		if (tk_n > 2 && tk_n > i+1 &&
			tk->info.type == TokenType::BuiltinFunc &&
			((tks[i+1]->stype == SyntaxType::Expr &&
			  tks[i+1]->tks[0]->info.type != TokenType::LeftBrace) ||
			 tks[i+1]->info.type == ShortHashDereference ||
			 tks[i+1]->info.type == ShortArrayDereference ||
			 tks[i+1]->info.type == ShortScalarDereference ||
			 tks[i+1]->stype     == SyntaxType::Term ||
			 tks[i+1]->info.kind == TokenKind::Term)) {
			insertExpr(root, i, 2);
			tk_n -= 1;
			goto RESTART;
		}
		if (tks[i]->token_num > 0) {
			completeFunctionListExpr(tks[i]);
		}
	}
}

void Completer::completeAlphabetBitOperatorExpr(Token *root)
{
	completeExprFromRight(root, TokenType::Not);
	completeExprFromLeft(root, TokenType::AlphabetAnd);
	completeExprFromLeft(root, TokenType::AlphabetOr);
	completeExprFromLeft(root, TokenType::AlphabetXOr);
}

void Completer::completeTerm(Token *root)
{
	TermCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::completeReturn(Token *root)
{
	ReturnCompleter completer;
	templateEvaluatedFromLeft(root, &completer);
}

void Completer::recoveryNamedUnaryOperatorsArgument(Token *root)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = tks[i];
		if (tk_n > 2 && tk_n > i+1 &&
			tk->stype == SyntaxType::Expr && isUnaryKeyword(tk->tks[tk->token_num-1]->data) &&
			(tks[i+1]->stype == SyntaxType::Expr ||
			 tks[i+1]->stype == SyntaxType::Term ||
			 tks[i+1]->info.kind == TokenKind::Term)) {
			Token *expr = tks[i+1];
			Token *function_argument = expr;
			Token **new_tks = (Token **)realloc(tk->tks, (tk->token_num + 1) * PTR_SIZE);
			assert(new_tks && "cannot allocate memory");
			tk->tks = new_tks;
			tk->tks[tk->token_num++] = function_argument;
			Tokens *recovery_tks = new Tokens();
			for (size_t j = 0; j < i + 1; j++) {
				recovery_tks->push_back(tks[j]);
			}
			for (size_t j = i + 2; j < tk_n; j++) {
				recovery_tks->push_back(tks[j]);
			}
			size_t size = recovery_tks->size();
			new_tks = (Token **)realloc(tks, size * PTR_SIZE);
			assert(new_tks && "cannot allocate memory");
			tks = new_tks;
			for (size_t j = 0; j < size; j++) {
				tks[j] = recovery_tks->at(j);
			}
			root->token_num = size;
			tk_n = size;
			goto RESTART;
		}
		if (tk->token_num > 0) {
			recoveryNamedUnaryOperatorsArgument(tks[i]);
		}
	}
}

void Completer::recoveryFunctionArgument(Token *root)
{
	using namespace TokenType;
	Token **tks = root->tks;
	size_t tk_n = root->token_num;
RESTART:;
	for (size_t i = 0; i < tk_n; i++) {
		Token *tk = tks[i];
		if (tk_n > 2 && tk_n > i+1 &&
			((tk->stype == SyntaxType::Expr &&
			  tk->tks[0]->info.type != LeftBrace &&
			  (tks[i+1]->stype == SyntaxType::Expr ||
			  tks[i+1]->stype == SyntaxType::Term ||
			  tks[i+1]->info.type == TokenType::ArrayVar)) ||
			 (tk->stype == SyntaxType::Term &&
			  (tks[i+1]->stype == SyntaxType::Term ||
			   tks[i+1]->info.type == TokenType::ArrayVar)))) {
			Token *expr = tks[i+1];
			Token *function_argument = expr;
			Token **new_tks = (Token **)realloc(tk->tks, (tk->token_num + 1) * PTR_SIZE);
			assert(new_tks && "cannot allocate memory");
			tk->tks = new_tks;
			tk->tks[tk->token_num++] = function_argument;
			Tokens *recovery_tks = new Tokens();
			for (size_t j = 0; j < i + 1; j++) {
				recovery_tks->push_back(tks[j]);
			}
			for (size_t j = i + 2; j < tk_n; j++) {
				recovery_tks->push_back(tks[j]);
			}
			size_t size = recovery_tks->size();
			new_tks = (Token **)realloc(tks, size * PTR_SIZE);
			assert(new_tks && "cannot allocate memory");
			tks = new_tks;
			for (size_t j = 0; j < size; j++) {
				tks[j] = recovery_tks->at(j);
			}
			root->token_num = size;
			tk_n = size;
			goto RESTART;
		}
		if (tk->token_num > 0) {
			recoveryFunctionArgument(tks[i]);
		}
	}
}
