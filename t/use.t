use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

my $tokens = Compiler::Lexer->new('-')->tokenize('use Data::Dumper');
my $ast = Compiler::Parser->new->parse($tokens);
my $root = $ast->root;
is(ref $root, 'Compiler::Parser::Node::Module');
is($root->token->data, 'Data::Dumper');

done_testing;
