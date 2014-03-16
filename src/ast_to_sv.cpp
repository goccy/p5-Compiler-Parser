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
#define add_key(hash, key, value) (void)((value) ? hv_stores(hash, key, set(node_to_sv(aTHX_ value))) : NULL)
#define add_token(hash, node) (void)hv_stores(hash, "token", set(new_Token(aTHX_ node)))
#define add_parent(hash, key, parent) do {								\
		SV *sv = get_value(hash, key);									\
		if (sv && parent) (void)hv_stores((HV *)SvRV(sv), "parent", set(parent)); \
	} while (0)

#ifdef __cplusplus
};
#endif

static SV *node_to_sv(pTHX_ Node *node);

static SV *new_Token(pTHX_ Token *token)
{
	HV *hash = (HV*)new_Hash();
	(void)hv_stores(hash, "stype", set(new_Int(token->stype)));
	(void)hv_stores(hash, "type", set(new_Int(token->info.type)));
	(void)hv_stores(hash, "kind", set(new_Int(token->info.kind)));
	(void)hv_stores(hash, "line", set(new_Int(token->finfo.start_line_num)));
	(void)hv_stores(hash, "has_warnings", set(new_Int(token->info.has_warnings)));
	(void)hv_stores(hash, "name", set(new_String(token->info.name, strlen(token->info.name))));
	(void)hv_stores(hash, "data", set(new_String(token->data.c_str(), strlen(token->data.c_str()))));
	HV *stash = (HV *)gv_stashpv("Compiler::Lexer::Token", sizeof("Compiler::Lexer::Token") + 1);
	return sv_bless(new_Ref(hash), stash);
}

static SV *bless(pTHX_ HV *self, const char *classname)
{
	HV *stash = (HV *)gv_stashpv(classname, strlen(classname) + 1);
	return sv_bless(new_Ref(self), stash);
}

static void append_common_pointer(pTHX_ HV *hash, Node *node) {
	(void)hv_stores(hash, "indent", set(new_Int(node->tk->finfo.indent)));
	add_key(hash, "next",   node->next);
	add_token(hash, node->tk);
}

static SV *node_to_sv(pTHX_ Node *node)
{
	SV *ret = NULL;
	if (!node) return ret;
	if (TYPE_match(node, BranchNode)) {
		BranchNode *branch = dynamic_cast<BranchNode *>(node);
		HV *hash = (HV*)new_Hash();
		add_key(hash, "left", branch->left);
		add_key(hash, "right", branch->right);
		append_common_pointer(aTHX_ hash, branch);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Branch");
		if (branch->left)  add_parent(hash, "left", ret);
		if (branch->right) add_parent(hash, "right", ret);
		if (branch->next)  add_parent(hash, "next", ret);
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
		append_common_pointer(aTHX_ hash, call);
		(void)hv_stores(hash, "args", set(new_Ref(array)));
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::FunctionCall");
	} else if (TYPE_match(node, ArrayNode)) {
		ArrayNode *array = dynamic_cast<ArrayNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, array);
		add_key(hash, "idx", array->idx);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Array");
		if (array->idx) add_parent(hash, "idx", ret);
		if (array->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, HashNode)) {
		HashNode *h = dynamic_cast<HashNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, h);
		add_key(hash, "key", h->key);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Hash");
		if (h->key) add_parent(hash, "key", ret);
		if (h->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, DereferenceNode)) {
		DereferenceNode *dref = dynamic_cast<DereferenceNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, dref);
		add_key(hash, "expr", dref->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Dereference");
		if (dref->expr) add_parent(hash, "expr", ret);
		if (dref->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, CodeDereferenceNode)) {
		CodeDereferenceNode *dref = dynamic_cast<CodeDereferenceNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, dref);
		add_key(hash, "name", dref->name);
		add_key(hash, "args", dref->args);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::CodeDereference");
		if (dref->name) add_parent(hash, "name", ret);
		if (dref->args) add_parent(hash, "args", ret);
		if (dref->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, FunctionNode)) {
		FunctionNode *f = dynamic_cast<FunctionNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, f);
		add_key(hash, "body", f->body);
		add_key(hash, "prototype", f->prototype);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Function");
		if (f->body) add_parent(hash, "body", ret);
		if (f->prototype) add_parent(hash, "prototype", ret);
		if (f->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, BlockNode)) {
		BlockNode *b = dynamic_cast<BlockNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, b);
		add_key(hash, "body", b->body);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Block");
		if (b->body) add_parent(hash, "body", ret);
		if (b->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ReturnNode)) {
		ReturnNode *r = dynamic_cast<ReturnNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, r);
		add_key(hash, "body", r->body);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Return");
		if (r->body) add_parent(hash, "body", ret);
		if (r->next)  add_parent(hash, "next", ret);
		if (r->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, SingleTermOperatorNode)) {
		SingleTermOperatorNode *s = dynamic_cast<SingleTermOperatorNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, s);
		add_key(hash, "expr", s->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::SingleTermOperator");
		if (s->expr) add_parent(hash, "expr", ret);
		if (s->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, DoubleTermOperatorNode)) {
	} else if (TYPE_match(node, LeafNode)) {
		LeafNode *leaf = dynamic_cast<LeafNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, leaf);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Leaf");
	} else if (TYPE_match(node, ListNode)) {
		ListNode *list = dynamic_cast<ListNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, list);
		add_key(hash, "data", list->data);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::List");
		if (list->data) add_parent(hash, "data", ret);
		if (list->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ArrayRefNode)) {
		ArrayRefNode *ref = dynamic_cast<ArrayRefNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, ref);
		add_key(hash, "data", ref->data);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ArrayRef");
		if (ref->data) add_parent(hash, "data", ret);
		if (ref->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, HashRefNode)) {
		HashRefNode *ref = dynamic_cast<HashRefNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, ref);
		add_key(hash, "data", ref->data);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::HashRef");
		if (ref->data) add_parent(hash, "data", ret);
		if (ref->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, IfStmtNode)) {
		IfStmtNode *stmt = dynamic_cast<IfStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, stmt);
		add_key(hash, "expr", stmt->expr);
		add_key(hash, "true_stmt", stmt->true_stmt);
		add_key(hash, "false_stmt", stmt->false_stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::IfStmt");
		if (stmt->expr) add_parent(hash, "expr", ret);
		if (stmt->true_stmt)  add_parent(hash, "true_stmt", ret);
		if (stmt->false_stmt) add_parent(hash, "false_stmt", ret);
		if (stmt->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ElseStmtNode)) {
		ElseStmtNode *stmt = dynamic_cast<ElseStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, stmt);
		add_key(hash, "stmt", stmt->stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ElseStmt");
		if (stmt->stmt) add_parent(hash, "stmt", ret);
		if (stmt->next) add_parent(hash, "next", ret);
	} else if (TYPE_match(node, DoStmtNode)) {
		DoStmtNode *stmt = dynamic_cast<DoStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, stmt);
		add_key(hash, "stmt", stmt->stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::DoStmt");
		if (stmt->stmt) add_parent(hash, "stmt", ret);
		if (stmt->next) add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ForStmtNode)) {
		ForStmtNode *stmt = dynamic_cast<ForStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, stmt);
		add_key(hash, "init", stmt->init);
		add_key(hash, "cond", stmt->cond);
		add_key(hash, "progress", stmt->progress);
		add_key(hash, "true_stmt", stmt->true_stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ForStmt");
		if (stmt->init) add_parent(hash, "init", ret);
		if (stmt->cond) add_parent(hash, "cond", ret);
		if (stmt->progress) add_parent(hash, "progress", ret);
		if (stmt->true_stmt) add_parent(hash, "true_stmt", ret);
		if (stmt->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ForeachStmtNode)) {
		ForeachStmtNode *stmt = dynamic_cast<ForeachStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, stmt);
		add_key(hash, "itr", stmt->itr);
		add_key(hash, "cond", stmt->cond);
		add_key(hash, "true_stmt", stmt->true_stmt);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ForeachStmt");
		if (stmt->itr) add_parent(hash, "itr", ret);
		if (stmt->cond) add_parent(hash, "cond", ret);
		if (stmt->true_stmt) add_parent(hash, "true_stmt", ret);
		if (stmt->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, WhileStmtNode)) {
		WhileStmtNode *stmt = dynamic_cast<WhileStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, stmt);
		add_key(hash, "true_stmt", stmt->true_stmt);
		add_key(hash, "expr", stmt->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::WhileStmt");
		if (stmt->true_stmt) add_parent(hash, "true_stmt", ret);
		if (stmt->expr) add_parent(hash, "expr", ret);
		if (stmt->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ModuleNode)) {
		ModuleNode *mod = dynamic_cast<ModuleNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, mod);
		add_key(hash, "args", mod->args);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Module");
		if (mod->args) add_parent(hash, "args", ret);
		if (mod->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, PackageNode)) {
		PackageNode *pkg = dynamic_cast<PackageNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, pkg);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Package");
		if (pkg->next) add_parent(hash, "next", ret);
	} else if (TYPE_match(node, RegPrefixNode)) {
		RegPrefixNode *reg = dynamic_cast<RegPrefixNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, reg);
		add_key(hash, "option", reg->option);
		add_key(hash, "expr", reg->exp);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::RegPrefix");
		if (reg->option) add_parent(hash, "option", ret);
		if (reg->exp) add_parent(hash, "expr", ret);
		if (reg->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, RegReplaceNode)) {
		RegReplaceNode *reg = dynamic_cast<RegReplaceNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, reg);
		add_key(hash, "from", reg->from);
		add_key(hash, "to", reg->to);
		add_key(hash, "option", reg->option);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::RegReplace");
		if (reg->from) add_parent(hash, "from", ret);
		if (reg->to)   add_parent(hash, "to", ret);
		if (reg->option) add_parent(hash, "option", ret);
		if (reg->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, RegexpNode)) {
		RegexpNode *reg = dynamic_cast<RegexpNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, reg);
		add_key(hash, "option", reg->option);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Regexp");
		if (reg->option) add_parent(hash, "option", ret);
		if (reg->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, LabelNode)) {
		LabelNode *label = dynamic_cast<LabelNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, label);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Label");
	} else if (TYPE_match(node, HandleNode)) {
		HandleNode *fh = dynamic_cast<HandleNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, fh);
		add_key(hash, "expr", fh->expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::Handle");
		if (fh->expr) add_parent(hash, "expr", ret);
		if (fh->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, HandleReadNode)) {
		HandleReadNode *fh = dynamic_cast<HandleReadNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, fh);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::HandleRead");
	} else if (TYPE_match(node, ThreeTermOperatorNode)) {
		ThreeTermOperatorNode *term = dynamic_cast<ThreeTermOperatorNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, term);
		add_key(hash, "cond", term->cond);
		add_key(hash, "true_expr", term->true_expr);
		add_key(hash, "false_expr", term->false_expr);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ThreeTermOperator");
		if (term->cond) add_parent(hash, "cond", ret);
		if (term->true_expr)  add_parent(hash, "true_expr", ret);
		if (term->false_expr) add_parent(hash, "false_expr", ret);
		if (term->next)  add_parent(hash, "next", ret);
	} else if (TYPE_match(node, ControlStmtNode)) {
		ControlStmtNode *control = dynamic_cast<ControlStmtNode *>(node);
		HV *hash = (HV*)new_Hash();
		append_common_pointer(aTHX_ hash, control);
		ret = bless(aTHX_ hash, "Compiler::Parser::Node::ControlStmt");
		if (control->next)  add_parent(hash, "next", ret);
	} else {
		assert(0 && "node type is not found");
	}
	return ret;
}

SV *ast_to_sv(pTHX_ AST *ast)
{
	SV *root = node_to_sv(aTHX_ ast->root);
	HV *hash = (HV*)new_Hash();
	hv_stores(hash, "root", set(root));
	SV *ret = set(bless(aTHX_ hash, "Compiler::Parser::AST"));
	return ret;
}
