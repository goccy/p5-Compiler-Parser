use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Term::ANSIColor qw(:constants);
use String::CamelCase qw/decamelize/;
use Data::Dumper;

sub generate {
    my ($ast) = @_;
    my $root = $ast->root;
    my $args = +{};
    my ($name) = ref($root) =~ /.*::(.*)/;
    my $node_name = decamelize($name);
    my $data      = $root->data;
    print "$node_name { '$data',";
    __generate($_ => $root->{$_}, 1) foreach grep { $_ !~ /next/ } @{$root->branches};
    print "}\n";
    print ",\n";
    __generate_next($root->{next}, 0) if $root->{next};
    print "]\n";
}

sub __generate_next {
    my ($node, $depth) = @_;
    my ($name) = ref($node) =~ /.*::(.*)/;
    my $node_name = decamelize($name);
    if ($node_name eq 'leaf') {
        print ' ' x 4 x $depth, sprintf("%s '%s',\n", $node_name, $node->data);
    } else {
        print ' ' x 4 x $depth, sprintf("%s { '%s',\n", $node_name, $node->data);
    }
    __generate($_ => $node->{$_}, $depth+1) foreach grep { $_ !~ /next/ } @{$node->branches};
    print ' ' x 4 x $depth,  "},\n" unless $node_name eq 'leaf';
    __generate_next($node->{next}, $depth) if $node->{next};
}

sub __generate {
    my ($branch_name, $node, $depth) = @_;
    return unless $node;
    if (ref($node) eq 'ARRAY') {
        print ' ' x 4 x $depth,  "[\n";
        my $node_name;
        foreach my $arg (@$node) {
            my ($name) = ref($arg) =~ /.*::(.*)/;
            $node_name = decamelize($name);
            if ($node_name eq 'leaf') {
                print ' ' x 4 x ($depth+1), sprintf("%s '%s',\n", $node_name, $arg->data);
            } else {
                print ' ' x 4 x ($depth+1), sprintf("%s { '%s',\n", $node_name, $arg->data);
            }
            __generate($_ => $arg->{$_}, $depth+1) foreach grep { $_ !~ /next/ } @{$arg->branches};
        }
        print ' ' x 4 x $depth, "]\n";
        print ' ' x 4 x $depth,  "},\n" unless $node_name eq 'leaf';
    } else {
        my ($name) = ref($node) =~ /.*::(.*)/;
        my $node_name = decamelize($name);
        if ($node_name eq 'leaf') {
            print ' ' x 4 x $depth, sprintf("%s => %s '%s',\n", $branch_name, $node_name, $node->data);
        } else {
            print ' ' x 4 x $depth, sprintf("%s => %s { '%s',\n", $branch_name, $node_name, $node->data);
        }
        __generate($_ => $node->{$_}, $depth+1) foreach grep { $_ !~ /next/ } @{$node->branches};
        print ' ' x 4 x $depth,  "},\n" unless $node_name eq 'leaf';

    }
    __generate_next($node->{next}, 1) if (ref($node) eq 'HASH') && $node->{next};
}

foreach my $filename (@ARGV) {
    print "... generate $filename\n";
    open my $fh, '<', $filename or die "Cannot load $filename";
    my $code = do { local $/; <$fh> };
    if (my $pid = fork()) {
        waitpid($pid, 0);
    } else {
        my $ast = Compiler::Parser->new->parse(Compiler::Lexer->new->tokenize($code));
        generate($ast);
        exit;
    }
}

