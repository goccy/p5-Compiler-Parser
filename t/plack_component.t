use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'Plack::Component' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);

    is(ref $ast, 'Compiler::Parser::Node::Package');
    is(ref $ast->next, 'Compiler::Parser::Node::Module');
    is(ref $ast->next->next, 'Compiler::Parser::Node::Module');
    is(ref $ast->next->next->next, 'Compiler::Parser::Node::Module');
    is(ref $ast->next->next->next->args, 'Compiler::Parser::Node::List');
    is(ref $ast->next->next->next->next, 'Compiler::Parser::Node::Module');
    is(ref $ast->next->next->next->next->next, 'Compiler::Parser::Node::Module');
    is(ref $ast->next->next->next->next->next->args, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->next->next->next->next->args->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->next->next->next->next->args->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->next->next->next->next->args->left->right, 'Compiler::Parser::Node::Function');
    is(ref $ast->next->next->next->next->next->args->left->right->body, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->next->next->next->next->args->left->right->body->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->next->next->next->next->args->left->right->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->next->next->next->next->args->left->right->body->right->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->next->next->next->next->args->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->next->next->next->next->args->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->next->next->next->next->args->right->right, 'Compiler::Parser::Node::Leaf');

    my $new = $ast->next->next->next->next->next->next;
    is(ref $new, 'Compiler::Parser::Node::Function');
    is(ref $new->body, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $new->body->next, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->right, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->right->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $new->body->next->right->left->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $new->body->next->next->next->expr, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->expr->left, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->expr->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->expr->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->expr->right, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->expr->right->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $new->body->next->next->next->expr->right->left->{args}[0], 'Compiler::Parser::Node::Array');
    is(ref $new->body->next->next->next->expr->right->left->{args}[0]->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $new->body->next->next->next->expr->right->left->{args}[0]->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->expr->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->true_stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->true_stmt->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0]->left, 'Compiler::Parser::Node::HashRef');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0]->left->data_node, 'Compiler::Parser::Node::Dereference');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0]->left->data_node->expr, 'Compiler::Parser::Node::Array');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0]->left->data_node->expr->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0]->left->data_node->expr->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->true_stmt->right->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $new->body->next->next->next->false_stmt->stmt, 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->false_stmt->stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->false_stmt->stmt->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $new->body->next->next->next->false_stmt->stmt->right->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $new->body->next->next->next->false_stmt->stmt->right->{args}[0]->left, 'Compiler::Parser::Node::HashRef');
    is(ref $new->body->next->next->next->false_stmt->stmt->right->{args}[0]->left->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->false_stmt->stmt->right->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $new->body->next->next->next->next, 'Compiler::Parser::Node::Leaf');

    my $mk_accessors = $new->next;
    is(ref $mk_accessors, 'Compiler::Parser::Node::Function');
    is(ref $mk_accessors->body, 'Compiler::Parser::Node::Branch');
    is(ref $mk_accessors->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $mk_accessors->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $mk_accessors->body->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $mk_accessors->body->next->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $mk_accessors->body->next->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $mk_accessors->body->next->{args}[0]->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $mk_accessors->body->next->{args}[0]->data_node->left->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $mk_accessors->body->next->{args}[0]->data_node->left->left->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $mk_accessors->body->next->{args}[0]->data_node->left->left->{args}[0]->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $mk_accessors->body->next->{args}[0]->data_node->left->right, 'Compiler::Parser::Node::Leaf');

    my $prepare_app = $mk_accessors->next;
    is(ref $prepare_app, 'Compiler::Parser::Node::Function');
    is(ref $prepare_app->body, 'Compiler::Parser::Node::Return');

    my $to_app = $prepare_app->next;
    is(ref $to_app, 'Compiler::Parser::Node::Function');
    is(ref $to_app->body, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $to_app->body->next, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $to_app->body->next->next, 'Compiler::Parser::Node::Return');
    is(ref $to_app->body->next->next->body, 'Compiler::Parser::Node::Function');
    is(ref $to_app->body->next->next->body->body, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->next->next->body->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->next->body->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $to_app->body->next->next->body->body->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    my $response_cb = $to_app->next;
    is(ref $response_cb, 'Compiler::Parser::Node::Function');
    is(ref $response_cb->body, 'Compiler::Parser::Node::Branch');
    is(ref $response_cb->body->left, 'Compiler::Parser::Node::List');
    is(ref $response_cb->body->left->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $response_cb->body->left->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $response_cb->body->left->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $response_cb->body->left->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $response_cb->body->left->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $response_cb->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $response_cb->body->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $response_cb->body->next->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $response_cb->body->next->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $response_cb->body->next->{args}[0]->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $response_cb->body->next->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $response_cb->next, 'Compiler::Parser::Node::Leaf');
};

done_testing;


__DATA__
package Plack::Component;
use strict;
use warnings;
use Carp ();
use Plack::Util;
use overload '&{}' => sub { shift->to_app(@_) }, fallback => 1;

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $self;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        $self = bless {%{$_[0]}}, $class;
    } else {
        $self = bless {@_}, $class;
    }

    $self;
}

# NOTE:
# this is for back-compat only,
# future modules should use
# Plack::Util::Accessor directly
# or their own favorite accessor
# generator.
# - SL
sub mk_accessors {
    my $self = shift;
    Plack::Util::Accessor::mk_accessors( ref( $self ) || $self, @_ )
}

sub prepare_app { return }

sub to_app {
    my $self = shift;
    $self->prepare_app;
    return sub { $self->call(@_) };
}


sub response_cb {
    my($self, $res, $cb) = @_;
    Plack::Util::response_cb($res, $cb);
}

1;

__END__
....
