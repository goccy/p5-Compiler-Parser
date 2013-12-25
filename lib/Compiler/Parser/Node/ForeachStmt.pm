package Compiler::Parser::Node::ForeachStmt;
use strict;
use warnings;
use base 'Compiler::Parser::Node';

sub cond { shift->{cond} }
sub itr { shift->{itr} }
sub true_stmt { shift->{true_stmt} }

1;

__END__

=pod

=head1 NAME

Compiler::Parser::Node::ForeachStmt

=head1 INHERITANCE

    Compiler::Parser::Node::ForeachStmt
    isa Compiler::Parser::Node

=head1 DESCRIPTION

    This node is created to represent foreach statement.
    ForeachStmt node has three pointers of 'cond', 'itr' and 'true_stmt'.
    Also, this node has 'next' pointer to access next statement's node.

=head1 LAYOUT

     _____________________________________        _____________
    |                                     | next |             |
    |             ForeachStmt             |----->|             |
    |_____________________________________|      |_____________|
           |          |             |
     cond  |      itr |   true_stmt |
           v          v             v

=head2 Example

e.g.) foreach my $itr (@array) { $itr++ }

                            |
     _______________________|________________________        _____________
    |                                                | next |             |
    |               ForeachStmt(foreach)             |----->|             |
    |________________________________________________|      |_____________|
               |            |            |
          cond |        itr |  true_stmt |
           ____v____    ____v____    ____v____
          |         |  |         |  |         |
          |   ++    |  |  $itr   |  |   ++    |
          |_________|  |_________|  |_________|
               |                          |
          expr |                     expr |
           ____v____                  ____v____
          |         |                |         |
          | @array  |                |  $itr   |
          |_________|                |_________|



=head1 SEE ALSO

[Compiler::Parser::Node](http://search.cpan.org/perldoc?Compiler::Parser::Node)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
