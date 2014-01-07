use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'make list' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
return if -p $fh or -c _ or -b _;
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
};

done_testing;



