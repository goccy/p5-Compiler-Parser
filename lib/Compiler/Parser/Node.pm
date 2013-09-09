package Compiler::Parser::Node;
use strict;
use warnings;

sub branches {
    my ($self) = @_;
    my @keys = keys %$self;
    return [ grep { $_ !~ /token/ } @keys ];
}

sub token {
    my ($self) = @_;
    return $self->{token};
}

sub name {
    my ($self) = @_;
    return $self->{token}->{name};
}

sub data {
    my ($self) = @_;
    return $self->{token}->{data};
}

sub next { shift->{next} }

1;
