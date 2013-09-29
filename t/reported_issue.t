use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

subtest 'reported issues' => sub {
    my $tokens = Compiler::Lexer->new('-')->tokenize('{}');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Block');
    is($ast->data, '');

    $tokens = Compiler::Lexer->new('-')->tokenize('\'!!3\'');
    $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '!!3');
};

done_testing;
