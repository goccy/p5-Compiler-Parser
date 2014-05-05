use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Handler/HTTP/Server/PSGI.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Handler::HTTP::Server::PSGI',
        },
        module { 'strict',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf ' HTTP::Server::PSGI ',
            },
        },
        function { 'new',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '%args',
                        },
                    },
                    right => leaf '@_',
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => hash_ref { '{}',
                                data => leaf '%args',
                            },
                            right => leaf '$class',
                        },
                    ],
                },
            ],
        },
        function { 'run',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$app',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf '$self',
                        right => function_call { '_server',
                            args => [
                            ],
                        },
                    },
                    right => function_call { 'run',
                        args => [
                            leaf '$app',
                        ],
                    },
                },
            ],
        },
        function { '_server',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '->',
                    left => leaf 'HTTP::Server::PSGI',
                    right => function_call { 'new',
                        args => [
                            dereference { '%$self',
                                expr => leaf '%$self',
                            },
                        ],
                    },
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Handler::HTTP::Server::PSGI;
use strict;

# for temporary backward compat
use parent qw( HTTP::Server::PSGI );

sub new {
    my($class, %args) = @_;
    bless { %args }, $class;
}

sub run {
    my($self, $app) = @_;
    $self->_server->run($app);
}

sub _server {
    my $self = shift;
    HTTP::Server::PSGI->new(%$self);
}

1;

__END__

=head1 NAME

Plack::Handler::HTTP::Server::PSGI - adapter for HTTP::Server::PSGI

=head1 SYNOPSIS

  % plackup -s HTTP::Server::PSGI \
      --host 127.0.0.1 --port 9091 --timeout 120

=head1 BACKWARD COMPATIBLITY

Since Plack 0.99_22 this handler doesn't support preforking
configuration i.e. C<--max-workers>. Use L<Starman> or L<Starlet> if
you need preforking PSGI web server.

=head1 CONFIGURATIONS

=over 4

=item host

Host the server binds to. Defaults to all interfaces.

=item port

Port number the server listens on. Defaults to 8080.

=item timeout

Number of seconds a request times out. Defaults to 300.

=item max-reqs-per-child

Number of requests per worker to process. Defaults to 100.

=back

=head1 AUTHOR

Kazuho Oku

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack> L<HTTP::Server::PSGI>

=cut

