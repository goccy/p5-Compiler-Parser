package Compiler::Parser::Node::Dereference;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub expr { shift->{expr} }

1;

__END__

=pod

=head1 NAME

Compiler::Parser::Node::Dereference

=head1 INHERITANCE

    Compiler::Parser::Node::Dereference
    isa Compiler::Parser::Node

=head1 DESCRIPTION

    This node is created to represent dereference of array or hash.
    Dereference node has single pointer of 'expr'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     ________________        _____________
    |                | next |             |
    |   Dereference  |----->|             |
    |________________|      |_____________|
            |
      expr  |
            v

=head2 Example

e.g.) @$array_ref; ...

               |
     __________|__________        _________
    |                     | next |         |
    |   Dereference(@$)   |----->|  .....  |
    |_____________________|      |_________|
               |
         expr  |
        _______v_______
       |               |
       |  $array_ref   |
       |_______________|

=head1 SEE ALSO

[Compiler::Parser::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
