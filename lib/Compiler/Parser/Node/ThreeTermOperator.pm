package Compiler::Parser::Node::ThreeTermOperator;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub cond { shift->{cond} }
sub true_expr { shift->{true_expr} }
sub false_expr { shift->{false_expr} }

1;
