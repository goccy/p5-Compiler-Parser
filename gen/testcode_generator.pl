use strict;
use warnings;
use Compiler::Lexer;
use Compiler::Parser;
use Term::ANSIColor qw(:constants);
use String::CamelCase qw/decamelize/;
use Data::Dumper;

my $template = do { local $/; <DATA> };
my $body;

sub generate {
    my ($ast) = @_;
    my $root = $ast->root;
    my $depth = 1;
    if ($root->{next}) {
        $depth++;
        $body .= "[\n";
    }
    my $node_name = print_block_start($root, $depth);
    __generate($_ => $root->{$_}, $depth+1) foreach grep { $_ !~ /next/ } @{$root->branches};
    print_block_end($node_name, $depth);
    __generate_next($root->{next}, $depth) if $root->{next};
    if ($root->{next}) {
        $body .= indent($depth-1) . "]";
    }
}

sub __generate_next {
    my ($node, $depth) = @_;
    my $node_name = print_block_start($node, $depth);
    __generate($_ => $node->{$_}, $depth+1) foreach grep { $_ !~ /next/ } @{$node->branches};
    print_block_end($node_name, $depth);
    __generate_next($node->{next}, $depth) if $node->{next};
}

sub indent {
    my ($depth) = @_;
    return ' ' x 4 x $depth;
}

sub print_block_start {
    my ($node, $depth) = @_;
    my ($name) = ref($node) =~ /.*::(.*)/;
    my $node_name = decamelize($name);
    $node_name = 'Test::Compiler::Parser::package' if ($node_name eq 'package');
    $node_name = 'Test::Compiler::Parser::return'  if ($node_name eq 'return');
    if ($node_name eq 'leaf') {
        $body .= indent($depth) . sprintf("%s '%s',\n", $node_name, $node->data);
    } else {
        $body .= indent($depth) . sprintf("%s { '%s',\n", $node_name, $node->data);
    }
    return $node_name;
}

sub print_block_start_with_branch {
    my ($node, $branch_name, $depth, $multiple) = @_;
    my ($name) = ref($node) =~ /.*::(.*)/;
    my $node_name = decamelize($name);
    $node_name = 'Test::Compiler::Parser::package' if ($node_name eq 'package');
    $node_name = 'Test::Compiler::Parser::return'  if ($node_name eq 'return');
    if ($node_name eq 'leaf') {
        $body .= indent($depth) . sprintf("%s => %s '%s',\n", $branch_name, $node_name, $node->data);
    } elsif ($multiple) {
        $body .= indent($depth) . sprintf("%s => [\n%s%s { '%s',\n", $branch_name, indent($depth+1), $node_name, $node->data);
    } else {
        $body .= indent($depth) . sprintf("%s => %s { '%s',\n", $branch_name, $node_name, $node->data);
    }
    return $node_name;
}

sub print_block_end {
    my ($node_name, $depth) = @_;
    $body .= indent($depth) .  "},\n" unless $node_name eq 'leaf';
}

sub print_node {
    my ($branch_name, $node, $depth) = @_;

    my $multiple = 0;
    if ($node->{next}) {
        $multiple = 1;
    }
    my $node_name = print_block_start_with_branch($node, $branch_name, $depth, $multiple);
    $depth++ if ($multiple);
    __generate($_ => $node->{$_}, $depth+1) foreach grep { $_ !~ /next/ } @{$node->branches};
    print_block_end($node_name, $depth);
    __generate_next($node->{next}, $depth) if $node->{next};
    if ($node->{next}) {
        $body .= indent($depth-1) . "],\n";
    }
}

sub __generate_array {
    my ($node, $depth) = @_;
    my $node_name;
    foreach my $arg (@$node) {
        if ($arg->{next}) {
            $depth++;
            $body .= indent($depth) . "[\n";
        }
        my $node_name = print_block_start($arg, $depth+1);
        __generate($_ => $arg->{$_}, $depth+2) foreach grep { $_ !~ /next/ } @{$arg->branches};
        print_block_end($node_name, $depth + 1);
        __generate_next($arg->{next}, $depth + 1) if $arg->{next};
        if ($arg->{next}) {
            $body .= indent($depth) . "],\n";
            $depth--;
        }
    }
    return $node_name;
}

sub __generate {
    my ($branch_name, $node, $depth) = @_;
    return unless $node;
    if (ref($node) eq 'ARRAY') {
        $body .= indent($depth) .  "$branch_name => [\n";
        my $node_name = __generate_array($node, $depth);
        print_block_end('', $depth+1) if ($node_name && $node_name ne 'leaf');
        $body .= indent($depth) . "],\n";
    } else {
        print_node($branch_name, $node, $depth);
     }
}

foreach my $filename (@ARGV) {
    print "... generate $filename\n";
    open my $fh, '<', $filename or die "Cannot load $filename";
    my $code = do { local $/; <$fh> };
    if (my $pid = fork()) {
        waitpid($pid, 0);
    } else {
        my $ast = Compiler::Parser->new->parse(Compiler::Lexer->new->tokenize($code));
        $body = '';
        generate($ast);
        open $fh, '>', 'test.t';
        print $fh sprintf $template, $filename, $body, $code;
        close $fh;
        exit;
    }
}

__DATA__
use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse %s' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, %s);
};

done_testing;

__DATA__
%s
