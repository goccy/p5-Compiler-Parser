use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest '/perl/base/if' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('-')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);

    is(ref $ast->root, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->right, 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->next->next->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $ast->root->next->next->false_stmt->stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->false_stmt->stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

    is(ref $ast->root->next->next->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->next->next->next->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->next->next->next->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->next->next->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $ast->root->next->next->next->false_stmt->stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->next->next->next->false_stmt->stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

};

done_testing;

__DATA__
#!./perl

print "1..2\n";

# first test to see if we can run the tests.

$x = 'test';
if ($x eq $x) { print "ok 1\n"; } else { print "not ok 1\n";}
if ($x ne $x) { print "not ok 2\n"; } else { print "ok 2\n";}
