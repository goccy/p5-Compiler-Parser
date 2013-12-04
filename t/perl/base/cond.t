use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest '/perl/base/cond' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('-')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->right, 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next->next->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->next->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next->next->next->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->next->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->next->next->next->next->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->next->next->next->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->next->next->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->next->next->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');

};

done_testing;

__DATA__
#!./perl

# make sure conditional operators work

print "1..4\n";

$x = '0';

$x eq $x && (print "ok 1\n");
$x ne $x && (print "not ok 1\n");
$x eq $x || (print "not ok 2\n");
$x ne $x || (print "ok 2\n");

$x == $x && (print "ok 3\n");
$x != $x && (print "not ok 3\n");
$x == $x || (print "not ok 4\n");
$x != $x || (print "ok 4\n");
