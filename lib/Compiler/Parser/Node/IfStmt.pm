package Compiler::Parser::Node::IfStmt;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub expr { shift->{expr} }
sub true_stmt { shift->{true_stmt} }
sub false_stmt { shift->{false_stmt} }

1;
