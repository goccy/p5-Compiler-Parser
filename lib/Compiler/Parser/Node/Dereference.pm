package Compiler::Parser::Node::Dereference;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub expr { shift->{expr} }

1;
