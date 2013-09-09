package Compiler::Parser::Node::ForStmt;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub init { shift->{init} }
sub cond { shift->{cond} }
sub progress { shift->{progress} }
sub true_stmt { shift->{true_stmt} }

1;
