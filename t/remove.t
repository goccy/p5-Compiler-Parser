use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;
use Data::Dumper;

my $code = do { local $/; <DATA> };

subtest 'remove nodes from ast' => sub {
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    $ast->remove(node => 'Function');
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, Test::Compiler::Parser::package { 'Person',
        next => Test::Compiler::Parser::package { 'main' }
    });
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
