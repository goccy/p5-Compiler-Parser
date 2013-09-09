package Compiler::Parser::Node::ElseStmt;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub stmt { shift->{stmt} }

1;
