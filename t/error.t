use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'error cases' => sub {
    my $tokens = Compiler::Lexer->new('-')->tokenize('if');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, '');

    $tokens = Compiler::Lexer->new('-')->tokenize('[');
    $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, '');
};

done_testing;
