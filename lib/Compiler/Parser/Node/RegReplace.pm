package Compiler::Parser::Node::RegReplace;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub from { shift->{from} }
sub to { shift->{to} }
sub option { shift->{option} }

1;
