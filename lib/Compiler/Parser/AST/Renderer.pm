package Compiler::Parser::AST::Renderer;
use strict;
use warnings;
use Compiler::Parser::AST::Renderer::Engine;

sub new {
    my $class = shift;
    my $self = {
        engine => Compiler::Parser::AST::Renderer::Engine->new('Text')
    };
    return bless($self, $class);
}

sub render {
    my ($self, $ast) = @_;
    $self->{engine}->render($ast);
}

1;
