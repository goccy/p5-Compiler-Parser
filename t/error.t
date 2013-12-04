use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'error cases' => sub {

    my $tokens = Compiler::Lexer->new('-')->tokenize('if');
    my $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only declare keyword');

    $tokens = Compiler::Lexer->new('-')->tokenize('[');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only left bracket');

    $tokens = Compiler::Lexer->new('-')->tokenize('{');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only left brace');

    $tokens = Compiler::Lexer->new('-')->tokenize('(');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only left parenthesis');

    $tokens = Compiler::Lexer->new('-')->tokenize(']');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only right bracket');

    $tokens = Compiler::Lexer->new('-')->tokenize('}');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only right brace');

    $tokens = Compiler::Lexer->new('-')->tokenize(')');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'only right parenthesis');

    $tokens = Compiler::Lexer->new('-')->tokenize('[[]');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'different bracket number');

    $tokens = Compiler::Lexer->new('-')->tokenize('{{}');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'different brance number');

    $tokens = Compiler::Lexer->new('-')->tokenize('(()');
    $ast = Compiler::Parser->new->parse($tokens);
    ok(!defined $ast, 'different parenthesis number');

};

done_testing;
