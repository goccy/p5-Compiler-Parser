package Compiler::Parser::Node::Branch;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub left  { shift->{left}  }
sub right { shift->{right} }

1;
