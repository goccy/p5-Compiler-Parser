use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Handler/HTTP/Server/Simple.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Handler::HTTP::Server::Simple',
        },
        module { 'strict',
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
                branch { '=',
                    left => leaf '$server',
                    right => branch { '->',
                        left => leaf 'Plack::Handler::HTTP::Server::Simple::PSGIServer',
                        right => function_call { 'new',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'port',
                                    },
                                },
                            ],
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'host',
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$server',
                        right => function_call { 'host',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'host',
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '->',
                    left => leaf '$server',
                    right => function_call { 'app',
                        args => [
                            leaf '$app',
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$server',
                        right => hash_ref { '{}',
                            data => leaf '_server_ready',
                        },
                    },
                    right => branch { '||',
                        left => function_call { 'delete',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'server_ready',
                                    },
                                },
                            ],
                        },
                        right => function { 'sub',
                            body => hash_ref { '{}',
                            },
                        },
                    },
                },
                branch { '->',
                    left => leaf '$server',
                    right => function_call { 'run',
                        args => [
                        ],
                    },
                },
            ],
        },
        Test::Compiler::Parser::package { 'Plack::Handler::HTTP::Server::Simple::PSGIServer',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'HTTP::Server::Simple::PSGI',
            },
        },
        function { 'print_banner',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf '_server_ready',
                        },
                    },
                    right => list { '()',
                        data => hash_ref { '{}',
                            data => branch { ',',
                                left => branch { ',',
                                    left => branch { ',',
                                        left => branch { '=>',
                                            left => leaf 'host',
                                            right => branch { '->',
                                                left => leaf '$self',
                                                right => function_call { 'host',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'port',
                                            right => branch { '->',
                                                left => leaf '$self',
                                                right => function_call { 'port',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        },
                                    },
                                    right => branch { '=>',
                                        left => leaf 'server_software',
                                        right => leaf 'HTTP::Server::Simple::PSGI',
                                    },
                                },
                            },
                        },
                    },
                },
            ],
        },
        Test::Compiler::Parser::package { 'Plack::Handler::HTTP::Server::Simple',
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Handler::HTTP::Server::Simple;
use strict;

sub new {
    my($class, %args) = @_;
    bless {%args}, $class;
}

sub run {
    my($self, $app) = @_;

    my $server = Plack::Handler::HTTP::Server::Simple::PSGIServer->new($self->{port});
    $server->host($self->{host}) if $self->{host};
    $server->app($app);
    $server->{_server_ready} = delete $self->{server_ready} || sub {};

    $server->run;
}

package Plack::Handler::HTTP::Server::Simple::PSGIServer;
use parent qw(HTTP::Server::Simple::PSGI);

sub print_banner {
    my $self = shift;

    $self->{_server_ready}->({
        host => $self->host,
        port => $self->port,
        server_software => 'HTTP::Server::Simple::PSGI',
    });
}

package Plack::Handler::HTTP::Server::Simple;

1;

__END__

=head1 NAME

Plack::Handler::HTTP::Server::Simple - Adapter for HTTP::Server::Simple

=head1 SYNOPSIS

  plackup -s HTTP::Server::Simple --port 9090

=head1 DESCRIPTION

Plack::Handler::HTTP::Server::Simple is an adapter to run PSGI
applications on L<HTTP::Server::Simple>.

=head1 SEE ALSO

L<Plack>, L<HTTP::Server::Simple::PSGI>

=head1 AUTHOR

Tatsuhiko Miyagawa


=cut

