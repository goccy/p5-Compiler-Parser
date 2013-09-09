package Compiler::Parser::Node::ForeachStmt;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub cond { shift->{cond} }
sub itr { shift->{itr} }
sub true_stmt { shift->{true_stmt} }

1;
