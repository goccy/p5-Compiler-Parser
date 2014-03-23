use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Test/Server.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Test::Server',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'Carp',
        },
        module { 'LWP::UserAgent',
        },
        module { 'Test::TCP',
        },
        module { 'Plack::Loader',
        },
        function { 'test_psgi',
            body => [
                branch { '=',
                    left => leaf '%args',
                    right => leaf '@_',
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$client',
                        right => function_call { 'delete',
                            args => [
                                hash { '$args',
                                    key => hash_ref { '{}',
                                        data => leaf 'client',
                                    },
                                },
                            ],
                        },
                    },
                    right => function_call { 'croak',
                        args => [
                            leaf 'client test code needed',
                        ],
                    },
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$app',
                        right => function_call { 'delete',
                            args => [
                                hash { '$args',
                                    key => hash_ref { '{}',
                                        data => leaf 'app',
                                    },
                                },
                            ],
                        },
                    },
                    right => function_call { 'croak',
                        args => [
                            leaf 'app needed',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$ua',
                    right => branch { '||',
                        left => function_call { 'delete',
                            args => [
                                hash { '$args',
                                    key => hash_ref { '{}',
                                        data => leaf 'ua',
                                    },
                                },
                            ],
                        },
                        right => branch { '->',
                            left => leaf 'LWP::UserAgent',
                            right => function_call { 'new',
                                args => [
                                ],
                            },
                        },
                    },
                },
                function_call { 'test_tcp',
                    args => [
                        list { '()',
                            data => branch { ',',
                                left => branch { ',',
                                    left => branch { '=>',
                                        left => leaf 'client',
                                        right => function { 'sub',
                                            body => [
                                                branch { '=',
                                                    left => leaf '$port',
                                                    right => function_call { 'shift',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                                branch { '=',
                                                    left => leaf '$cb',
                                                    right => function { 'sub',
                                                        body => [
                                                            branch { '=',
                                                                left => leaf '$req',
                                                                right => function_call { 'shift',
                                                                    args => [
                                                                    ],
                                                                },
                                                            },
                                                            branch { '->',
                                                                left => branch { '->',
                                                                    left => leaf '$req',
                                                                    right => function_call { 'uri',
                                                                        args => [
                                                                        ],
                                                                    },
                                                                },
                                                                right => function_call { 'scheme',
                                                                    args => [
                                                                        leaf 'http',
                                                                    ],
                                                                },
                                                            },
                                                            branch { '->',
                                                                left => branch { '->',
                                                                    left => leaf '$req',
                                                                    right => function_call { 'uri',
                                                                        args => [
                                                                        ],
                                                                    },
                                                                },
                                                                right => function_call { 'host',
                                                                    args => [
                                                                        branch { '||',
                                                                            left => hash { '$args',
                                                                                key => hash_ref { '{}',
                                                                                    data => leaf 'host',
                                                                                },
                                                                            },
                                                                            right => leaf '127.0.0.1',
                                                                        },
                                                                    ],
                                                                },
                                                            },
                                                            branch { '->',
                                                                left => branch { '->',
                                                                    left => leaf '$req',
                                                                    right => function_call { 'uri',
                                                                        args => [
                                                                        ],
                                                                    },
                                                                },
                                                                right => function_call { 'port',
                                                                    args => [
                                                                        leaf '$port',
                                                                    ],
                                                                },
                                                            },
                                                            Test::Compiler::Parser::return { 'return',
                                                                body => branch { '->',
                                                                    left => leaf '$ua',
                                                                    right => function_call { 'request',
                                                                        args => [
                                                                            leaf '$req',
                                                                        ],
                                                                    },
                                                                },
                                                            },
                                                        ],
                                                    },
                                                },
                                                branch { '->',
                                                    left => leaf '$client',
                                                    right => list { '()',
                                                        data => leaf '$cb',
                                                    },
                                                },
                                            ],
                                        },
                                    },
                                    right => branch { '=>',
                                        left => leaf 'server',
                                        right => branch { '||',
                                            left => hash { '$args',
                                                key => hash_ref { '{}',
                                                    data => leaf 'server',
                                                },
                                            },
                                            right => function { 'sub',
                                                body => [
                                                    branch { '=',
                                                        left => leaf '$port',
                                                        right => function_call { 'shift',
                                                            args => [
                                                            ],
                                                        },
                                                    },
                                                    branch { '=',
                                                        left => leaf '$server',
                                                        right => branch { '->',
                                                            left => leaf 'Plack::Loader',
                                                            right => function_call { 'auto',
                                                                args => [
                                                                    list { '()',
                                                                        data => branch { ',',
                                                                            left => branch { '=>',
                                                                                left => leaf 'port',
                                                                                right => leaf '$port',
                                                                            },
                                                                            right => branch { '=>',
                                                                                left => leaf 'host',
                                                                                right => branch { '||',
                                                                                    left => hash { '$args',
                                                                                        key => hash_ref { '{}',
                                                                                            data => leaf 'host',
                                                                                        },
                                                                                    },
                                                                                    right => leaf '127.0.0.1',
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                ],
                                                            },
                                                        },
                                                    },
                                                    branch { '->',
                                                        left => leaf '$server',
                                                        right => function_call { 'run',
                                                            args => [
                                                                leaf '$app',
                                                            ],
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    ],
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Test::Server;
use strict;
use warnings;
use Carp;
use LWP::UserAgent;
use Test::TCP;
use Plack::Loader;

sub test_psgi {
    my %args = @_;

    my $client = delete $args{client} or croak "client test code needed";
    my $app    = delete $args{app}    or croak "app needed";
    my $ua     = delete $args{ua} || LWP::UserAgent->new;

    test_tcp(
        client => sub {
            my $port = shift;
            my $cb = sub {
                my $req = shift;
                $req->uri->scheme('http');
                $req->uri->host($args{host} || '127.0.0.1');
                $req->uri->port($port);
                return $ua->request($req);
            };
            $client->($cb);
        },
        server => $args{server} || sub {
            my $port = shift;
            my $server = Plack::Loader->auto(port => $port, host => ($args{host} || '127.0.0.1'));
            $server->run($app);
        },
    );
}

1;

__END__

=head1 NAME

Plack::Test::Server - Run HTTP tests through live Plack servers

=head1 DESCRIPTION

Plack::Test::Server is a utility to run PSGI application with Plack
server implementations, and run the live HTTP tests with the server
using a callback. See L<Plack::Test> how to use this module.

=head1 AUTHOR

Tatsuhiko Miyagawa

Tokuhiro Matsuno

=head1 SEE ALSO

L<Plack::Loader> L<Test::TCP> L<Plack::Test>

=cut


