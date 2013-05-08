package Compiler::Parser::AST::Renderer::Engine::Text;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

sub render {
    my ($self, $ast) = @_;
    print "render plain text!!!\n";
}

1;
