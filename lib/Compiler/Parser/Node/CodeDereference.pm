package Compiler::Parser::Node::CodeDereference;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub name { shift->{name} }
sub args { shift->{args} }

1;

__END__
