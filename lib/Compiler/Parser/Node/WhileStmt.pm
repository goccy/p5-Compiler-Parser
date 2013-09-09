package Compiler::Parser::Node::WhileStmt;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub expr { shift->{expr} }
sub true_stmt { shift->{true_stmt} }

1;
