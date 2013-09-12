use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'module version argument' => sub {
    my $tokens = Compiler::Lexer->new('-')->tokenize('use ModuleName 5.008_001');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Module');
    is(ref $ast->args, 'Compiler::Parser::Node::Leaf');
    is($ast->data, 'ModuleName');
    is($ast->args->data, '5.008_001');

    $tokens = Compiler::Lexer->new('-')->tokenize('use ModuleName v5.008');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Module');
    is(ref $ast->args, 'Compiler::Parser::Node::Leaf');
    is($ast->data, 'ModuleName');
    is($ast->args->data, 'v5.008');

    $tokens = Compiler::Lexer->new('-')->tokenize('use ModuleName 54');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Module');
    is(ref $ast->args, 'Compiler::Parser::Node::Leaf');
    is($ast->data, 'ModuleName');
    is($ast->args->data, '54');

    $tokens = Compiler::Lexer->new('-')->tokenize('use Foo; use Bar');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Module');
    is(ref $ast->next, 'Compiler::Parser::Node::Module');

    $tokens = Compiler::Lexer->new('-')->tokenize('use Foo; my $x = sub { }');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Module');
    is(ref $ast->next, 'Compiler::Parser::Node::Branch');
    is(ref $ast->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->right, 'Compiler::Parser::Node::Function');
    is(ref $ast->next->right->body, 'Compiler::Parser::Node::HashRef');

};

done_testing;
