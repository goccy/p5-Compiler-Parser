use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

subtest 'reported issues' => sub {
    my $tokens = Compiler::Lexer->new('-')->tokenize('{}');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Block');
    is($ast->root->data, '');

    $tokens = Compiler::Lexer->new('-')->tokenize('\'!!3\'');
    $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '!!3');
};

done_testing;
