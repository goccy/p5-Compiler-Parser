package Compiler::Parser::Node::HashRef;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub data_node { shift->{data} }

1;
