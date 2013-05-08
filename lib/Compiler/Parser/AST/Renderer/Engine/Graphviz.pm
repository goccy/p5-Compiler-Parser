package Compiler::Parser::AST::Renderer::Engine::Graphviz;
use strict;
use warnings;
use Graphviz;

sub new {
    my $class = shift;
    my $g = Graphviz->new;
    my $self = {
        g => $g
    }
    return bless($self, $class);
}

sub render {
    my ($self, $ast) = @_;
    # do someting
}

1;
