package Compiler::Parser::Node::ArrayRef;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub data_node { shift->{data} }

1;
