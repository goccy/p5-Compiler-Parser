use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

my $tokens = Compiler::Lexer->new('-')->tokenize('1 + 1');
my $ast = Compiler::Parser->new->parse($tokens);
is(ref $ast, 'Compiler::Parser::Node::Branch');
is(ref $ast->{left},  'Compiler::Parser::Node::Leaf');
is(ref $ast->{right}, 'Compiler::Parser::Node::Leaf');

done_testing;
