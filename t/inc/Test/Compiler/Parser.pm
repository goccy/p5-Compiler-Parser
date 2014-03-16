package Test::Compiler::Parser;
use strict;
use warnings;
use Test::More;
use parent 'Exporter';
use Carp;

our @EXPORT = qw/
    node_ok
    branch
    leaf
    list
    dereference
    code_dereference
    array
    array_ref
    hash
    hash_ref
    function
    function_call
    single_term_operator
    foreach_stmt
    while_stmt
    if_stmt
    else_stmt
    control_stmt
    do_stmt
    module
    reg_prefix
    block
    regexp
    reg_replace
    three_term_operator
    handle
    handle_read
/;

sub node_child_ok {
    my ($node, $param) = @_;
    if (ref $node eq 'ARRAY') {
        foreach my $elem (@$node) {
            node_ok($elem, $param);
        }
    } else {
        my @branches = grep { $_ ne 'token_data' } keys %$param;
        is($node->data, $param->{token_data}, 'data   == ' . $node->data);
        foreach my $branch (@branches) {
            if (ref($param->{$branch}) eq 'ARRAY') {
                node_array_ok($node->{$branch}, $param->{$branch});
            } else {
                is(ref($param->{$branch}), ref($node->{$branch}), 'branch == ' . $branch);
                node_ok($node->{$branch}, $param->{$branch});
            }
        }
    }
}

sub node_array_ok {
    my ($node, $params) = @_;
    if (ref $node eq 'ARRAY') {
        foreach my $elem (@$node) {
            if (ref $params eq 'ARRAY') {
                node_ok($elem, shift @$params);
            } else {
                node_ok($elem, $params);
            }
        }
    } else {
        foreach my $param (@$params) {
            node_ok($node, $param);
            $node = $node->next;
        }
    }
}

sub node_ok {
    my ($root, $param) = @_;
    if (ref $param eq 'ARRAY') {
        node_array_ok($root, $param);
    } else {
        node_child_ok($root, $param);
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
        Carp::confess "needs $_ property" unless (exists $property->{$_});
    }
}

sub branch(&) {
    my $property = get_property(@_);
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
    return bless $property, 'Compiler::Parser::Node::List';
}

sub dereference(&) {
    my $property = get_property(@_);
    check_property($property, qw/expr/);
    return bless $property, 'Compiler::Parser::Node::Dereference';
}

sub code_dereference(&) {
    my $property = get_property(@_);
    check_property($property, qw/name/);
    check_property($property, qw/args/);
    return bless $property, 'Compiler::Parser::Node::CodeDereference';
}

sub array(&) {
    my $property = get_property(@_);
    check_property($property, qw/idx/);
    return bless $property, 'Compiler::Parser::Node::Array';
}

sub array_ref(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::ArrayRef';
}

sub hash(&) {
    my $property = get_property(@_);
    check_property($property, qw/key/);
    return bless $property, 'Compiler::Parser::Node::Hash';
}

sub hash_ref(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::HashRef';
}

sub package(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Package';
}

sub function(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Function';
}

sub return(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Return';
}

sub function_call(&) {
    my $property = get_property(@_);
    check_property($property, qw/args/);
    return bless $property, 'Compiler::Parser::Node::FunctionCall';
}

sub single_term_operator(&) {
    my $property = get_property(@_);
    check_property($property, qw/expr/);
    return bless $property, 'Compiler::Parser::Node::SingleTermOperator';
}

sub foreach_stmt(&) {
    my $property = get_property(@_);
    check_property($property, qw/cond/);
    check_property($property, qw/true_stmt/);
    return bless $property, 'Compiler::Parser::Node::ForeachStmt';
}

sub while_stmt(&) {
    my $property = get_property(@_);
    check_property($property, qw/expr/);
    check_property($property, qw/true_stmt/);
    return bless $property, 'Compiler::Parser::Node::WhileStmt';
}

sub if_stmt(&) {
    my $property = get_property(@_);
    check_property($property, qw/expr/);
    check_property($property, qw/true_stmt/);
    return bless $property, 'Compiler::Parser::Node::IfStmt';
}

sub else_stmt(&) {
    my $property = get_property(@_);
    check_property($property, qw/stmt/);
    return bless $property, 'Compiler::Parser::Node::ElseStmt';
}

sub three_term_operator(&) {
    my $property = get_property(@_);
    check_property($property, qw/cond/);
    check_property($property, qw/true_expr/);
    check_property($property, qw/false_expr/);
    return bless $property, 'Compiler::Parser::Node::ThreeTermOperator';
}

sub block(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Block';
}

sub regexp(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Regexp';
}

sub reg_replace(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::RegReplace';
}

sub module(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Module';
}

sub reg_prefix(&) {
    my $property = get_property(@_);
    check_property($property, qw/expr/);
    return bless $property, 'Compiler::Parser::Node::RegPrefix';
}

sub do_stmt(&) {
    my $property = get_property(@_);
    check_property($property, qw/stmt/);
    return bless $property, 'Compiler::Parser::Node::DoStmt';
}

sub handle(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::Handle';
}

sub handle_read(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::HandleRead';
}

sub control_stmt(&) {
    my $property = get_property(@_);
    return bless $property, 'Compiler::Parser::Node::ControlStmt';
}

1;
