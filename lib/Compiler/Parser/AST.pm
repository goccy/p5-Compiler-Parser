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
            next unless ($parent->{$branch} == $node);
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
