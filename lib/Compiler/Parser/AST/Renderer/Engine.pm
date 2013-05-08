package Compiler::Parser::AST::Renderer::Engine;
use strict;
use warnings;

sub new {
    my ($self, $engine_name) = @_;
    my $class = "Compiler/Parser/AST/Renderer/Engine/$engine_name";
    require "$class.pm";
    $class =~ s|/|::|g;
    return $class->new();
}

1;
