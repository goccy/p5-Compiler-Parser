package Compiler::Parser;
use 5.008_001;
use strict;
use warnings;
use Compiler::Parser::Node;
use Compiler::Parser::Node::Branch;
use Compiler::Parser::Node::Block;
use Compiler::Parser::Node::Module;
use Compiler::Parser::Node::Package;
use Compiler::Parser::Node::RegPrefix;
use Compiler::Parser::Node::ForStmt;
use Compiler::Parser::Node::ForeachStmt;
use Compiler::Parser::Node::WhileStmt;
use Compiler::Parser::Node::Function;
use Compiler::Parser::Node::FunctionCall;
use Compiler::Parser::Node::IfStmt;
use Compiler::Parser::Node::ElseStmt;
use Compiler::Parser::Node::SingleTermOperator;
use Compiler::Parser::Node::Array;
use Compiler::Parser::Node::Hash;
use Compiler::Parser::Node::Leaf;
use Compiler::Parser::Node::List;
use Compiler::Parser::Node::ArrayRef;
use Compiler::Parser::Node::HashRef;
use Compiler::Parser::Node::Dereference;
use Compiler::Parser::Node::Return;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = '0.02';
require XSLoader;
XSLoader::load('Compiler::Parser', $VERSION);

sub link_ast {
    my ($self, $ASTs) = @_;
    foreach my $ast (values %$ASTs) {
        my $nodes = $self->__find_module_nodes($ast);
        foreach my $node (@$nodes) {
            my $module_name = $node->{token}->data;
            $node->{ast} = $ASTs->{$module_name};
        }
    }
}

sub __add_node_from_array {
    my ($self, $nodes, $module_nodes) = @_;
    $self->__add_node($_, $module_nodes) foreach (@$nodes);
}

sub __add_node {
    my ($self, $node, $module_nodes) = @_;
    push @$module_nodes, $node if (ref $node eq 'Compiler::Parser::Node::Module');
    my $nodes = $self->__find_module_nodes($node);
    push @$module_nodes, @$nodes if (@$nodes);
}

sub __find_module_nodes {
    my ($self, $node) = @_;
    my @module_nodes;
    if (ref $node eq 'ARRAY') {
        $self->__add_node_from_array($node, \@module_nodes);
    } else {
        push @module_nodes, $node if (ref $node eq 'Compiler::Parser::Node::Module');
        foreach my $name (@{$node->branches}) {
            my $child_node = $node->{$name};
            next unless (defined $child_node);
            if (ref $child_node eq 'ARRAY') {
                $self->__add_node_from_array($child_node, \@module_nodes);
            } else {
                $self->__add_node($child_node, \@module_nodes);
            }
        }
    }
    return \@module_nodes;
}

1;
__END__

=head1 NAME

Compiler::Parser - Create Abstract Syntax Tree for Perl5

=head1 SYNOPSIS

    use Compiler::Lexer;
    use Compiler::Parser;
    use Compiler::Parser::AST::Renderer;

    my $filename = $ARGV[0];
    open(my $fh, "<", $filename) or die("$filename could not find.");
    my $script = do { local $/; <$fh> };
    my $lexer = Compiler::Lexer->new($filename);
    my $tokens = $lexer->tokenize($script);
    my $parser = Compiler::Parser->new();
    my $ast = $parser->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);

=head1 DESCRIPTION

Compiler::Parser creates abstract syntax tree for perl5.

=head1 METHODS

=over

=item my $parser = Compiler::Parser->new();

    Create new instance of Compiler::Parser.

=item my $ast = $parser->parse($tokens);

    Get array reference includes abstract syntax tree each statement.
    This method requires `$tokens` from Compiler::Lexer::tokenize.

=item my $renderer = Compiler::Parser::AST::Renderer->new();

    Create new instance of Compiler::Parser::AST::Renderer.

=item $renderer->render($ast)

    Render abstract syntax tree.
    This method requires `$ast` from Compiler::Parser::parse.
    Default rendering engine is Compiler::Parser::AST::Renderer::Engine::Text.

=back

=head1 SEE ALSO

[Compiler::Lexer](http://search.cpan.org/perldoc?Compiler::Lexer)

=head1 AUTHOR

Masaaki Goshima (goccy) <goccy54@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Masaaki Goshima (goccy).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
