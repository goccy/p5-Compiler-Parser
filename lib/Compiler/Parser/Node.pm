package Compiler::Parser::Node;
use strict;
use warnings;
use constant {
    FIND_BY_NODE => 0,
    FIND_BY_KIND => 1,
    FIND_BY_TYPE => 2,
    FIND_BY_DATA => 3
};

sub branches {
    my ($self) = @_;
    my @keys = keys %$self;
    return [ grep {
        $_ !~ /token/     && $_ !~ /find_param/ &&
        $_ !~ /find_type/ && $_ !~ /indent/ && $_ !~ /parent/
    } @keys ];
}

sub token  { shift->{token} }
sub name   { shift->{token}->{name} }
sub data   { shift->{token}->{data} }
sub indent { shift->{indent} }
sub parent { shift->{parent} }
sub next   { shift->{next} }

sub find {
    my ($self, %args) = @_;
    return $self->__find_by_node_name($args{node}) if (exists $args{node});
    return $self->__find_by_kind_name($args{kind}) if (exists $args{kind});
    return $self->__find_by_type_name($args{type}) if (exists $args{type});
    return $self->__find_by_token_data($args{data}) if (exists $args{data});
    warn "require node or kind or type parameter";
    return [];
}

sub __find_by_node_name {
    my ($self, $node_name) = @_;
    require "Compiler/Parser/Node/$node_name.pm";
    my $name = "Compiler::Parser::Node::$node_name";
    $self->{find_param} = $name;
    $self->{find_type} = FIND_BY_NODE;
    return $self->__find($self);
}

sub __find_by_kind_name {
    my ($self, $kind_name) = @_;
    require "Compiler/Lexer/Constants.pm";
    my $kind = eval "Compiler::Lexer::Kind::T_$kind_name";
    $self->{find_param} = $kind || -1;
    $self->{find_type} = FIND_BY_KIND;
    return $self->__find($self);
}

sub __find_by_type_name {
    my ($self, $type_name) = @_;
    require "Compiler/Lexer/Constants.pm";
    my $type = eval "Compiler::Lexer::TokenType::T_$type_name";
    $self->{find_param} = $type || -1;
    $self->{find_type} = FIND_BY_TYPE;
    return $self->__find($self);
}

sub __find_by_token_data {
    my ($self, $data) = @_;
    $self->{find_param} = $data;
    $self->{find_type} = FIND_BY_DATA;
    return $self->__find($self);
}

sub __match_find_condition {
    my ($self, $node) = @_;
    my $find_type = $self->{find_type};
    my $param     = $self->{find_param};
    return ref $node eq $param if ($find_type == FIND_BY_NODE);
    return $node->token->kind == $param if ($find_type == FIND_BY_KIND);
    return $node->token->type == $param if ($find_type == FIND_BY_TYPE);
    return $node->token->data eq $param if ($find_type == FIND_BY_DATA);
    return 0;
}

sub __add_node_from_array {
    my ($self, $nodes, $find_nodes) = @_;
    $self->__add_node($_, $find_nodes) foreach (@$nodes);
    return $find_nodes;
}

sub __add_node {
    my ($self, $node, $find_nodes) = @_;
    my $nodes = $self->__find($node);
    push @$find_nodes, @$nodes if (@$nodes);
}

sub __find {
    my ($self, $node) = @_;
    my @find_nodes;
    return $self->__add_node_from_array($node, \@find_nodes) if (ref $node eq 'ARRAY');
    push @find_nodes, $node if $self->__match_find_condition($node);
    foreach my $name (@{$node->branches}) {
        my $child_node = $node->{$name};
        next unless (defined $child_node);
        if (ref $child_node eq 'ARRAY') {
            $self->__add_node_from_array($child_node, \@find_nodes);
        } else {
            $self->__add_node($child_node, \@find_nodes);
        }
    }
    return \@find_nodes;
}

1;

__END__

=pod

=head1 NAME

Compiler::Parser::Node

=head1 DESCRIPTION

=head1 METHODS

=over 1

=item my $find_nodes = $node->find(type => 'Int');

    $array_node is created by Compiler::Parser::parse.
    Find node from 'node' or 'kind' or 'type' or 'data' parameter.
    This method imported by Compiler::Parser::Node.

=back

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
