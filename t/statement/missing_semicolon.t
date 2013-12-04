use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'missing last statement\'s semicolon' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f { my $a; $a = 1 } ');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Function');
    is(ref $ast->root->body, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->body->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->body->next->right, 'Compiler::Parser::Node::Leaf');
};

done_testing;
