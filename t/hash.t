use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'make list' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my %a = (a => 2, b => 4);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::List');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'hash dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('%$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Dereference');
    is(ref $ast->expr, 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize('%{$a}');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Dereference');
    is(ref $ast->expr, 'Compiler::Parser::Node::Leaf');
};

subtest 'hash get access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a{$b + 1}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Hash');
    is(ref $ast->key, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->key->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->key->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->key->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'hash set access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a{$b + 1} = 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Hash');
    is(ref $ast->left->key, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->key->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->key->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->key->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'nested array reference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = { a => 1, b => { d => 8 }, c => 2 }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->right->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->data_node->left->right->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->right->right->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->right->right->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'hash reference chain' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a{$b + 1}->{$c + 2}->{d}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left, 'Compiler::Parser::Node::Hash');
    is(ref $ast->left->left->key, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->left->key->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->key->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->key->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Leaf');
};

subtest 'hash short dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print "\t", $key, ":", $$token{$key}, "\n";');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right, 'Compiler::Parser::Node::Dereference');
    is(ref $ast->{args}[0]->left->right->expr, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->{args}[0]->left->right->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
};

done_testing;
