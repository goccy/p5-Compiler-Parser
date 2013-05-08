package Compiler::Parser::AST;
use strict;
use warnings;
use Compiler::Parser::AST::Renderer;

sub new {
    my $class = shift;
    my $self = {
        renderer => Compiler::Parser::AST::Renderer->new()
    };
    return bless($self, $class);
}

sub render {
    my ($self) = @_;
    $self->{renderer}->render($self);
}

1;
