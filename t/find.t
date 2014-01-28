use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Data::Dumper;

my $code = do { local $/; <DATA> };

subtest 'find_by_node' => sub {
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    my $nodes = $ast->find(node => 'Package');
    is($nodes->[0]->data, 'Person');
    is($nodes->[1]->data, 'main');
    my $sub_nodes = $nodes->[0]->find(node => 'Function');
    is($sub_nodes->[0]->data, 'new');
};

subtest 'find_by_kind' => sub {
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    my $nodes = $ast->find(kind => 'Operator');
    is(ref $nodes->[0], 'Compiler::Parser::Node::Branch');
    is(ref $nodes->[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $nodes->[0]->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'find_by_type' => sub {
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    my $nodes = $ast->find(type => 'Int');
    is(ref $nodes->[0], 'Compiler::Parser::Node::Leaf');
    is(ref $nodes->[1], 'Compiler::Parser::Node::Leaf');
};

subtest 'find_by_data' => sub {
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    my $nodes = $ast->find(data => 'shift');
    is(ref $nodes->[0], 'Compiler::Parser::Node::FunctionCall');
};

done_testing;

__DATA__
package Person;

sub new {
    my $class = shift;
    bless {}, $class;
}

package main;

sub main {
    return 1 + 1;
}
