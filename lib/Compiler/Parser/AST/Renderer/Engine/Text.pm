package Compiler::Parser::AST::Renderer::Engine::Text;
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

sub render {
    my ($self, $ast) = @_;
    my $root = $ast->root;
    my $args = +{};
    $args->{$_} = $root->{$_} foreach @{$root->branches};
    print BOLD, '├── ';
    $self->__print_data($root);
    print "\n";
    $self->__render($args, 1);
}

sub __render {
    my ($self, $nodes, $depth) = @_;
    my @names = keys %$nodes;
    my @sorted_names = grep { $_ !~ /next/ } @names;
    push @sorted_names, 'next';
    foreach my $name (@sorted_names) {
        my $node = $nodes->{$name};
        next unless (defined $node);
        $self->__render_branch($_, $name, $depth)
            foreach (ref $node eq 'ARRAY') ? @$node : ($node);
    }
}

sub __render_branch {
    my ($self, $node, $name, $depth) = @_;
    if ($name =~ /next/) {
        $depth--;
    }
    print BOLD, '|   ' foreach (1 .. $depth);
    print BOLD, '├── ';
    #print BOLD, '└─';
    $self->__print_name($name);
    print ' ';
    $self->__print_data($node);
    print "\n";
    my $args = +{};
    $args->{$_} = $node->{$_} foreach @{$node->branches};
    $self->__render($args, $depth + 1);
}

sub __print_data {
    my ($self, $node) = @_;
    print BOLD, CYAN, "[", $node->data, "]", RESET;
}

sub __print_name {
    my ($self, $name) = @_;
    print BOLD, GREEN, "<$name>", BOLD, WHITE;
}

1;
