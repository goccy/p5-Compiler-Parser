use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'regexp' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a =~ /^not/');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Regexp');

    $tokens = Compiler::Lexer->new('')->tokenize('$a =~ /^not/g');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Regexp');
    is(ref $ast->root->right->option, 'Compiler::Parser::Node::Leaf');
};

subtest 'regexp prefix' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a =~ m/^not/');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::RegPrefix');
    is(ref $ast->root->right->expr, 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize('$a =~ m/^not/g');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::RegPrefix');
    is(ref $ast->root->right->option, 'Compiler::Parser::Node::Leaf');
};

subtest 'regexp replace' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a =~ s/^not /substr(1, 0, 0)/g');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::RegReplace');
    is(ref $ast->root->right->from, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right->to, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right->option, 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize('$a =~ s/^not /substr(1, 0, 0)/');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::RegReplace');
    is(ref $ast->root->right->from, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right->to, 'Compiler::Parser::Node::Leaf');

};

done_testing;
