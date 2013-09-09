use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'simple sub' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f { return $_[0] + 2; } my $code = \&f; &$code(3);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Function');
    is(ref $ast->body, 'Compiler::Parser::Node::Return');
    is(ref $ast->body->body, 'Compiler::Parser::Node::Branch');
    is(ref $ast->body->body->left, 'Compiler::Parser::Node::Array');
    is(ref $ast->body->body->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->body->body->left->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->body->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->next->right->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->next->next, 'Compiler::Parser::Node::Dereference');
    is(ref $ast->next->next->expr, 'Compiler::Parser::Node::Leaf');
};

done_testing;
