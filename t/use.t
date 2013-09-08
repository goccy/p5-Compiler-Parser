use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

my $tokens = Compiler::Lexer->new('-')->tokenize('use Data::Dumper');
my $ast = Compiler::Parser->new->parse($tokens);
is(ref $ast, 'Compiler::Parser::Node::Module');
is($ast->token->data, 'Data::Dumper');

done_testing;
