use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Handler/Standalone.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Handler::Standalone',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf ' Plack::Handler::HTTP::Server::PSGI ',
            },
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Handler::Standalone;
use strict;
use warnings;
use parent qw( Plack::Handler::HTTP::Server::PSGI );

1;

__END__

=head1 NAME

Plack::Handler::Standalone - adapter for HTTP::Server::PSGI

=head1 SYNOPSIS

  % plackup -s Standalone \
      --host 127.0.0.1 --port 9091 --timeout 120

=head1 DESCRIPTION

Plack::Handler::Standalone is an adapter for default Plack server
implementation L<HTTP::Server::PSGI>. This is just an alias for
L<Plack::Handler::HTTP::Server::PSGI>.

=head1 SEE ALSO

L<Plack::Handler::HTTP::Server::PSGI>

=cut

