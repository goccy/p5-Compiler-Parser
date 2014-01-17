use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'map' => sub {
    my $code = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
};

done_testing;

__DATA__
my $a = map { $_ * 2 } @b;
my ($key, $value) = map URI::Escape::uri_unescape($_), split( "=", $pair, 2 );

@query =
    map { s/\+/ /g; URI::Escape::uri_unescape($_) }
    map { /=/ ? split(/=/, $_, 2) : ($_ => '')}
    split(/[&;]/, $query_string);

$self->{headers} = HTTP::Headers->new(
    map {
        (my $field = $_) =~ s/^HTTPS?_//;
        ( $field => $env->{$_} );
    }
        grep { /^(?:HTTP|CONTENT)/i } keys %$env
    );


