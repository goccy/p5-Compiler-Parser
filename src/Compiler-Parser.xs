#include <parser.hpp>

#ifdef __cplusplus
extern "C" {
#endif
#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#define new_Array() (AV*)sv_2mortal((SV*)newAV())
#define new_Hash() (HV*)sv_2mortal((SV*)newHV())
#define new_String(s, len) sv_2mortal(newSVpv(s, len))
#define new_Int(u) sv_2mortal(newSVuv(u))
#define new_Ref(sv) sv_2mortal(newRV_inc((SV*)sv))
#define set(e) SvREFCNT_inc(e)
#define get_value(hash, key) *hv_fetchs(hash, key, strlen(key))
#ifdef __cplusplus
};
#endif
SV *ast_to_sv(pTHX_ AST *ast);

typedef Enum::Token::Type::Type TokenType;
typedef Enum::Token::Kind::Kind TokenKind;

typedef Parser* Compiler_Parser;

MODULE = Compiler::Parser PACKAGE = Compiler::Parser
PROTOTYPES: DISABLE

Compiler_Parser
new(classname)
	char *classname
CODE:
{
	Parser *parser = new Parser();
	RETVAL = parser;
}
OUTPUT:
	RETVAL

SV *
parse(self, tokens_)
	Compiler_Parser self
	AV *tokens_
CODE:
{
	int tokens_size = av_len(tokens_);
	if (tokens_size < 0) {
		RETVAL = NULL;
		return;
	}
	SV **tokens = tokens_->sv_u.svu_array;
	Tokens tks;
	for (int i = 0; i <= tokens_size; i++) {
		SV *token_ = (SV *)*av_fetch(tokens_, i, FALSE);
		if (sv_isa(token_, "Compiler::Lexer::Token")) {
			token_ = SvRV(token_);
		}
		HV *token = (HV *)token_;
		const char *name = SvPVX(get_value(token, "name"));
		const char *data = SvPVX(get_value(token, "data"));
		int line = SvIVX(get_value(token, "line"));
		int has_warnings = SvIVX(get_value(token, "has_warnings"));
		TokenType type = (TokenType)SvIVX(get_value(token, "type"));
		TokenKind kind = (TokenKind)SvIVX(get_value(token, "kind"));
		FileInfo finfo;
		finfo.start_line_num = line;
		finfo.end_line_num = line;
		//finfo.filename = self->finfo.filename;
		TokenInfo info;
		info.type = type;
		info.kind = kind;
		info.name = name;
		info.data = data;
		info.has_warnings = has_warnings;
		Token *tk = new Token(std::string(data), finfo);
		tk->info = info;
		tk->type = type;
		tks.push_back(tk);
	}
	AST *ast = self->parse(&tks);
	//ast->dump();
	RETVAL = ast_to_sv(aTHX_ ast);
}
OUTPUT:
    RETVAL
