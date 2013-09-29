package Compiler::Parser::Node::Handle;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub expr { shift->{expr} }

1;
