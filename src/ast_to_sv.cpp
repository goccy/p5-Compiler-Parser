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

static SV *new_Token(pTHX_ Token *token)
{
	HV *hash = (HV*)new_Hash();
	hv_stores(hash, "stype", set(new_Int(token->stype)));
	hv_stores(hash, "type", set(new_Int(token->info.type)));
	hv_stores(hash, "kind", set(new_Int(token->info.kind)));
	hv_stores(hash, "line", set(new_Int(token->finfo.start_line_num)));
	hv_stores(hash, "has_warnings", set(new_Int(token->info.has_warnings)));
	hv_stores(hash, "name", set(new_String(token->info.name, strlen(token->info.name))));
	hv_stores(hash, "data", set(new_String(token->data.c_str(), strlen(token->data.c_str()))));
	HV *stash = (HV *)gv_stashpv("Compiler::Lexer::Token", sizeof("Compiler::Lexer::Token") + 1);
	return sv_bless(new_Ref(hash), stash);
}

static SV *bless(pTHX_ HV *self, const char *classname)
{
	HV *stash = (HV *)gv_stashpv(classname, strlen(classname) + 1);
	return sv_bless(new_Ref(self), stash);
}

static SV *node_to_sv(pTHX_ Node *node)
{
	SV *ret = NULL;
	if (!node) return ret;
	if (TYPE_match(node, BranchNode)) {
		BranchNode *branch = dynamic_cast<BranchNode *>(node);
		SV *left = node_to_sv(aTHX_ branch->left);
		SV *right = node_to_sv(aTHX_ branch->right);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ branch->tk)));
		hv_stores(hash, "left", set(left));
		hv_stores(hash, "right", set(right));
		ret = bless(aTHX_ hash, "Compiler::Parser::BranchNode");
	} else if (TYPE_match(node, FunctionCallNode)) {
		FunctionCallNode *call = dynamic_cast<FunctionCallNode *>(node);
		Nodes *args = call->args;
		size_t argsize = args->size();
		AV *array = new_Array();
		for (size_t i = 0; i < argsize; i++) {
			SV *arg = node_to_sv(aTHX_ args->at(i));
			if (!arg) continue;
			av_push(array, set(arg));
		}
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ call->tk)));
		hv_stores(hash, "args", set(new_Ref(array)));
		ret = bless(aTHX_ hash, "Compiler::Parser::FunctionCallNode");
	} else if (TYPE_match(node, ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ array->tk)));
		hv_stores(hash, "idx", set(node_to_sv(aTHX_ array->idx)));
		ret = bless(aTHX_ hash, "Compiler::Parser::ArrayNode");
	} else if (TYPE_match(node, HashNode)) {
		HashNode *h = dynamic_cast<HashNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ h->tk)));
		hv_stores(hash, "key", set(node_to_sv(aTHX_ h->key)));
		ret = bless(aTHX_ hash, "Compiler::Parser::HashNode");
	} else if (TYPE_match(node, FunctionNode)) {
		FunctionNode *f = dynamic_cast<FunctionNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ f->tk)));
		hv_stores(hash, "body", set(node_to_sv(aTHX_ f->body)));
		ret = bless(aTHX_ hash, "Compiler::Parser::FunctionNode");
	} else if (TYPE_match(node, BlockNode)) {
		BlockNode *b = dynamic_cast<BlockNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ b->tk)));
		hv_stores(hash, "body", set(node_to_sv(aTHX_ b->body)));
		ret = bless(aTHX_ hash, "Compiler::Parser::BlockNode");
	} else if (TYPE_match(node, ReturnNode)) {
		ReturnNode *r = dynamic_cast<ReturnNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ r->tk)));
		hv_stores(hash, "body", set(node_to_sv(aTHX_ r->body)));
		ret = bless(aTHX_ hash, "Compiler::Parser::ReturnNode");
	} else if (TYPE_match(node, SingleTermOperatorNode)) {
		SingleTermOperatorNode *s = dynamic_cast<SingleTermOperatorNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ s->tk)));
		hv_stores(hash, "expr", set(node_to_sv(aTHX_ s->expr)));
		ret = bless(aTHX_ hash, "Compiler::Parser::SingleTermOperatorNode");
	} else if (TYPE_match(node, DoubleTermOperatorNode)) {
	} else if (TYPE_match(node, LeafNode)) {
		LeafNode *leaf = dynamic_cast<LeafNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ leaf->tk)));
		ret = bless(aTHX_ hash, "Compiler::Parser::LeafNode");
	} else if (TYPE_match(node, IfStmtNode)) {
		IfStmtNode *stmt = dynamic_cast<IfStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ stmt->tk)));
		hv_stores(hash, "expr", set(node_to_sv(aTHX_ stmt->expr)));
		hv_stores(hash, "true_stmt", set(node_to_sv(aTHX_ stmt->true_stmt)));
		hv_stores(hash, "false_stmt", set(node_to_sv(aTHX_ stmt->false_stmt)));
		ret = bless(aTHX_ hash, "Compiler::Parser::IfStmtNode");
	} else if (TYPE_match(node, ElseStmtNode)) {
		ElseStmtNode *stmt = dynamic_cast<ElseStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ stmt->tk)));
		hv_stores(hash, "stmt", set(node_to_sv(aTHX_ stmt->stmt)));
		ret = bless(aTHX_ hash, "Compiler::Parser::ElseStmtNode");
	} else if (TYPE_match(node, ForStmtNode)) {
		ForStmtNode *stmt = dynamic_cast<ForStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		hv_stores(hash, "token", set(new_Token(aTHX_ stmt->tk)));
		hv_stores(hash, "init", set(node_to_sv(aTHX_ stmt->init)));
		hv_stores(hash, "cond", set(node_to_sv(aTHX_ stmt->cond)));
		hv_stores(hash, "progress", set(node_to_sv(aTHX_ stmt->progress)));
		hv_stores(hash, "true_stmt", set(node_to_sv(aTHX_ stmt->true_stmt)));
		ret = bless(aTHX_ hash, "Compiler::Parser::ForStmtNode");
	} else {
		assert(node && "node type is not found");
	}
	return ret;
}

SV *ast_to_sv(pTHX_ AST *ast)
{
	Node *traverse_ptr = ast->root;
	AV *ret = new_Array();
	for (; traverse_ptr->next != NULL; traverse_ptr = traverse_ptr->next) {
		SV *node = node_to_sv(aTHX_ traverse_ptr);
		if (!node) continue;
		av_push(ret, set(node));
	}
	return (SV *)new_Ref(ret);
}
