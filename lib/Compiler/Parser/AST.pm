package Compiler::Parser::AST;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT_OK = qw/walk/;

sub new {
    my $class = shift;
    return bless({}, $class);
}

sub root { shift->{root} }

sub find {
    my ($self, %args) = @_;
    return $self->root->find(%args);
}

sub remove {
    my ($self, %args) = @_;
    my $nodes = $self->root->find(%args);
    foreach my $node (@$nodes) {
        my $parent = $node->parent;
        next unless $parent;
        foreach my $branch (@{$parent->branches}, 'next') {
            my $child = $parent->{$branch};
            next unless ($child && $child == $node);
            $parent->{$branch} = $node->next;
        }
    }
}

sub walk(&$) {
    my ($ast, $callback);
    if (ref $_[0] eq 'Compiler::Parser::AST') {
        ($ast, $callback) = @_;
    } elsif (ref $_[1] eq 'Compiler::Parser::AST') {
        ($callback, $ast) = @_;
    }
    $ast->__walk($ast->root, $callback);
}

sub __walk {
    my ($self, $node, $callback) = @_;
    $_ = $node;
    &$callback($node);
    my @sorted_names = grep { $_ !~ /next/ } @{$node->branches};
    push @sorted_names, 'next';
    foreach my $name (@sorted_names) {
        my $child_node = $node->{$name};
        next unless (defined $child_node);
        $self->__walk($_, $callback)
            foreach (ref $child_node eq 'ARRAY') ? @$child_node : ($child_node);
    }
}

1;

__END__

=pod

=head1 NAME

Compiler::Parser::AST

=head1 DESCRIPTION

=head1 METHODS

=over 1

=item my $ast = Compiler::Parser->new->parse($tokens);

    Get blessed object of Compiler::Parser::AST.
    This method requires $tokens from Compiler::Lexer::tokenize.

=item my $root_node = $ast->root;

    Get root node from AST.
    $ast is created by Compiler::Parser::parse.

=item my $find_nodes = $ast->find(type => 'Int');

    Find node from 'node' or 'kind' or 'type' or 'data' parameter.

=item $ast->walk(sub { my $node = shift; });

    Walk AST. This method requires anonymous subroutine as argument.
    Subroutine's first argument is instance inherited Compiler::Parser::Node.

=item walk { my $node = $_; } $ast;

    Walk AST. This method must be exported by 'use Compiler::Parser::AST qw/walk/;'
    $_ is instance inherited Compiler::Parser::Node.

=item $ast->remove(node => 'Function');

    Remove nodes from 'node' or 'kind' or 'type' or 'data' parameter.

=back

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

