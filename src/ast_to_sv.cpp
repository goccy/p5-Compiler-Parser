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
#define add_key(hash, key, value) (value) ? hv_stores(hash, key, set(node_to_sv(aTHX_ value))) : NULL
#define add_token(hash, node) hv_stores(hash, "token", set(new_Token(aTHX_ node)))

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
		HV *hash = (HV*)new_Hash();
		add_token(hash, branch->tk);
		add_key(hash, "left", branch->left);
		add_key(hash, "right", branch->right);
		add_key(hash, "next", branch->next);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Branch");
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
		add_key(hash, "next", call->next);
		add_token(hash, call->tk);
		hv_stores(hash, "args", set(new_Ref(array)));
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::FunctionCall");
	} else if (TYPE_match(node, ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, array->tk);
		add_key(hash, "next", array->next);
		add_key(hash, "idx", array->idx);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Array");
	} else if (TYPE_match(node, HashNode)) {
		HashNode *h = dynamic_cast<HashNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, h->tk);
		add_key(hash, "next", h->next);
		add_key(hash, "key", h->key);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Hash");
	} else if (TYPE_match(node, DereferenceNode)) {
		DereferenceNode *dref = dynamic_cast<DereferenceNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, dref->tk);
		add_key(hash, "next", dref->next);
		add_key(hash, "expr", dref->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Dereference");
	} else if (TYPE_match(node, FunctionNode)) {
		FunctionNode *f = dynamic_cast<FunctionNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, f->tk);
		add_key(hash, "next", f->next);
		add_key(hash, "body", f->body);
		add_key(hash, "prototype", f->prototype);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Function");
	} else if (TYPE_match(node, BlockNode)) {
		BlockNode *b = dynamic_cast<BlockNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, b->tk);
		add_key(hash, "next", b->next);
		add_key(hash, "body", b->body);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Block");
	} else if (TYPE_match(node, ReturnNode)) {
		ReturnNode *r = dynamic_cast<ReturnNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, r->tk);
		add_key(hash, "next", r->next);
		add_key(hash, "body", r->body);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Return");
	} else if (TYPE_match(node, SingleTermOperatorNode)) {
		SingleTermOperatorNode *s = dynamic_cast<SingleTermOperatorNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, s->tk);
		add_key(hash, "next", s->next);
		add_key(hash, "expr", s->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::SingleTermOperator");
	} else if (TYPE_match(node, DoubleTermOperatorNode)) {
	} else if (TYPE_match(node, LeafNode)) {
		LeafNode *leaf = dynamic_cast<LeafNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, leaf->tk);
		add_key(hash, "next", leaf->next);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Leaf");
	} else if (TYPE_match(node, ListNode)) {
		ListNode *list = dynamic_cast<ListNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, list->tk);
		add_key(hash, "data", list->data);
		add_key(hash, "next", list->next);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::List");
	} else if (TYPE_match(node, ArrayRefNode)) {
		ArrayRefNode *ref = dynamic_cast<ArrayRefNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, ref->tk);
		add_key(hash, "data", ref->data);
		add_key(hash, "next", ref->next);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ArrayRef");
	} else if (TYPE_match(node, HashRefNode)) {
		HashRefNode *ref = dynamic_cast<HashRefNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, ref->tk);
		add_key(hash, "data", ref->data);
		add_key(hash, "next", ref->next);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::HashRef");
	} else if (TYPE_match(node, IfStmtNode)) {
		IfStmtNode *stmt = dynamic_cast<IfStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, stmt->tk);
		add_key(hash, "next", stmt->next);
		add_key(hash, "expr", stmt->expr);
		add_key(hash, "true_stmt", stmt->true_stmt);
		add_key(hash, "false_stmt", stmt->false_stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::IfStmt");
	} else if (TYPE_match(node, ElseStmtNode)) {
		ElseStmtNode *stmt = dynamic_cast<ElseStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, stmt->tk);
		add_key(hash, "next", stmt->next);
		add_key(hash, "stmt", stmt->stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ElseStmt");
	} else if (TYPE_match(node, ForStmtNode)) {
		ForStmtNode *stmt = dynamic_cast<ForStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, stmt->tk);
		add_key(hash, "next", stmt->next);
		add_key(hash, "init", stmt->init);
		add_key(hash, "cond", stmt->cond);
		add_key(hash, "progress", stmt->progress);
		add_key(hash, "true_stmt", stmt->true_stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ForStmt");
	} else if (TYPE_match(node, ForeachStmtNode)) {
		ForeachStmtNode *stmt = dynamic_cast<ForeachStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, stmt->tk);
		add_key(hash, "next", stmt->next);
		add_key(hash, "itr", stmt->itr);
		add_key(hash, "cond", stmt->cond);
		add_key(hash, "true_stmt", stmt->true_stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ForeachStmt");
	} else if (TYPE_match(node, WhileStmtNode)) {
		WhileStmtNode *stmt = dynamic_cast<WhileStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, stmt->tk);
		add_key(hash, "next", stmt->next);
		add_key(hash, "true_stmt", stmt->true_stmt);
		add_key(hash, "expr", stmt->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::WhileStmt");
	} else if (TYPE_match(node, ModuleNode)) {
		ModuleNode *mod = dynamic_cast<ModuleNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, mod->tk);
		add_key(hash, "next", mod->next);
		add_key(hash, "args", mod->args);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Module");
	} else if (TYPE_match(node, PackageNode)) {
		PackageNode *pkg = dynamic_cast<PackageNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, pkg->tk);
		add_key(hash, "next", pkg->next);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Package");
	} else if (TYPE_match(node, RegPrefixNode)) {
		RegPrefixNode *reg = dynamic_cast<RegPrefixNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_token(hash, reg->tk);
		add_key(hash, "next", reg->next);
		add_key(hash, "expr", reg->exp);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::RegPrefix");
	} else {
		assert(0 && "node type is not found");
	}
	return ret;
}

SV *ast_to_sv(pTHX_ AST *ast)
{
	SV *ret = node_to_sv(aTHX_ ast->root);
	set(ret);
	return ret;
}
