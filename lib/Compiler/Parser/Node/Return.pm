package Compiler::Parser::Node::Return;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub body { shift->{body} }

1;
