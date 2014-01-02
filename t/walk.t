use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST qw/walk/;
use Compiler::Parser::AST::Renderer;

my $code = do { local $/; <DATA> };

subtest 'walk ast' => sub {
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    my @nodes;
    # walk method call type A
    $ast->walk(sub {
        my $node = shift;
        push @nodes, $node;
    });
    is(scalar @nodes, 15);

    @nodes = ();
    # walk method call type B
    walk {
        push @nodes, $_;
    } $ast;
    is(scalar @nodes, 15);
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
