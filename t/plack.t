use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Data::Dumper;
BEGIN {
    use_ok('Compiler::Parser');
    use_ok('Compiler::Parser::AST::Renderer');
};

my $filename = $ARGV[0];
open my $fh, '<', $filename;
my $script = do { local $/; <$fh> };
my $tokens = Compiler::Lexer->new('')->tokenize($script);
my $parser = Compiler::Parser->new();
my $ast = $parser->parse($$tokens);
Compiler::Parser::AST::Renderer->new->render($ast);
done_testing;
