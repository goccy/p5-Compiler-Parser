use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'simple sub' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f { return $_[0] + 2; } f();');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->body, 'Compiler::Parser::Node::Return');
    is(ref $ast->body->body, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->body->left, 'Compiler::Parser::Node::Array');
    is(ref $ast->body->body->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->body->body->left->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->{args}[0], 'Compiler::Parser::Node::List');
};

subtest 'name::space style subroutine name' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub name::::space { return $_[0] + 2; } name::space();');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->body, 'Compiler::Parser::Node::Return');
    is(ref $ast->body->body, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->body->left, 'Compiler::Parser::Node::Array');
    is(ref $ast->body->body->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->body->body->left->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->{args}[0], 'Compiler::Parser::Node::List');
};

subtest 'multi argument' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f {  my ($a, $b, $c) = @_; } f;');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->body, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->left, 'Compiler::Parser::Node::List');
    is(ref $ast->body->left->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->left->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->left->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->left->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->left->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next, 'Compiler::Parser::Node::FunctionCall');
};

subtest 'multi argument' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f { my $a = shift; my $b = shift; } f(1, 2);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->body, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->body->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $ast->next->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->{args}[0]->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'prototype' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f ($$$) {} f(1, 2, 3);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->prototype, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $ast->next->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->{args}[0]->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->{args}[0]->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->{args}[0]->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'call with &' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f {} &f(1);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->body, '');
    is(ref $ast->next, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->next->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->expr->{args}[0], 'Compiler::Parser::Node::Leaf');
};

done_testing;
