package Compiler::Parser::Node::Function;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub body { shift->{body} }
sub prototype { shift->{prototype} }

1;
