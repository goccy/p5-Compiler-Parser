package Test::Compiler::Parser;
use strict;
use warnings;
use Test::More;
use parent 'Exporter';

our @EXPORT = qw/
    node_ok
    branch
    leaf
    list
    dereference
    array
    array_ref
    package
/;

sub node_ok {
    my ($root, $blessed_node) = @_;
    my @branches = grep { $_ ne 'token_data' } keys %$blessed_node;
    is($root->data, $blessed_node->{token_data});
    foreach my $branch (@branches) {
        is(ref($root->{$branch}), ref($blessed_node->{$branch}));
        node_ok($root->{$branch}, $blessed_node->{$branch});
    }
}

sub get_property {
    my ($callback) = @_;
    my @results = &$callback;
    my $token_data = shift @results;
    my %property = @results;
    $property{token_data} = $token_data;
    return \%property;
}

sub check_property {
    my ($property, @branches) = @_;
    foreach (@branches) {
        die "needs $_ property" unless (exists $property->{$_});
    }
}

sub branch(&) {
    my $property = get_property(@_);
    check_property($property, qw/left right/);
    return bless $property, 'Compiler::Parser::Node::Branch';
}

sub leaf($) {
    my $token_data = shift;
    return bless {
        token_data => $token_data
    }, 'Compiler::Parser::Node::Leaf';
}

sub list(&) {
    my $property = get_property(@_);
    check_property($property, qw/data/);
    return bless $property, 'Compiler::Parser::Node::List';
}

sub dereference(&) {
    my $property = get_property(@_);
    check_property($property, qw/expr/);
    return bless $property, 'Compiler::Parser::Node::Dereference';
}

sub array(&) {
    my $property = get_property(@_);
    check_property($property, qw/idx/);
    return bless $property, 'Compiler::Parser::Node::Array';
}

sub array_ref(&) {
    my $property = get_property(@_);
    check_property($property, qw/data/);
    return bless $property, 'Compiler::Parser::Node::ArrayRef';
}

sub package(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Package';
}

1;
