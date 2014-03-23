use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Test/MockHTTP.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Test::MockHTTP',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'Carp',
        },
        module { 'HTTP::Request',
        },
        module { 'HTTP::Response',
        },
        module { 'HTTP::Message::PSGI',
        },
        module { 'Try::Tiny',
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
                            if_stmt { 'unless',
                                expr => function_call { 'defined',
                                    args => [
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
                                                ],
                                            },
                                        },
                                    ],
                                },
                                true_stmt => branch { '->',
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
                            },
                            if_stmt { 'unless',
                                expr => function_call { 'defined',
                                    args => [
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
                                                ],
                                            },
                                        },
                                    ],
                                },
                                true_stmt => branch { '->',
                                    left => branch { '->',
                                        left => leaf '$req',
                                        right => function_call { 'uri',
                                            args => [
                                            ],
                                        },
                                    },
                                    right => function_call { 'host',
                                        args => [
                                            leaf 'localhost',
                                        ],
                                    },
                                },
                            },
                            branch { '=',
                                left => leaf '$env',
                                right => branch { '->',
                                    left => leaf '$req',
                                    right => function_call { 'to_psgi',
                                        args => [
                                        ],
                                    },
                                },
                            },
                            branch { '=',
                                left => leaf '$res',
                                right => function_call { 'try',
                                    args => [
                                        branch { '->',
                                            left => leaf 'HTTP::Response',
                                            right => function_call { 'from_psgi',
                                                args => [
                                                    branch { '->',
                                                        left => leaf '$app',
                                                        right => list { '()',
                                                            data => leaf '$env',
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                        function_call { 'catch',
                                            args => [
                                                branch { '->',
                                                    left => leaf 'HTTP::Response',
                                                    right => function_call { 'from_psgi',
                                                        args => [
                                                            array_ref { '[]',
                                                                data => branch { ',',
                                                                    left => branch { ',',
                                                                        left => leaf '500',
                                                                        right => array_ref { '[]',
                                                                            data => branch { '=>',
                                                                                left => leaf 'Content-Type',
                                                                                right => leaf 'text/plain',
                                                                            },
                                                                        },
                                                                    },
                                                                    right => array_ref { '[]',
                                                                        data => leaf '$_',
                                                                    },
                                                                },
                                                            },
                                                        ],
                                                    },
                                                },
                                            ],
                                        },
                                    ],
                                },
                            },
                            branch { '->',
                                left => leaf '$res',
                                right => function_call { 'request',
                                    args => [
                                        leaf '$req',
                                    ],
                                },
                            },
                            Test::Compiler::Parser::return { 'return',
                                body => leaf '$res',
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
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Test::MockHTTP;
use strict;
use warnings;

use Carp;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use Try::Tiny;

sub test_psgi {
    my %args = @_;

    my $client = delete $args{client} or croak "client test code needed";
    my $app    = delete $args{app}    or croak "app needed";

    my $cb = sub {
        my $req = shift;
        $req->uri->scheme('http')    unless defined $req->uri->scheme;
        $req->uri->host('localhost') unless defined $req->uri->host;
        my $env = $req->to_psgi;

        my $res = try {
            HTTP::Response->from_psgi($app->($env));
        } catch {
            HTTP::Response->from_psgi([ 500, [ 'Content-Type' => 'text/plain' ], [ $_ ] ]);
        };

        $res->request($req);
        return $res;
    };

    $client->($cb);
}

1;

__END__

=head1 NAME

Plack::Test::MockHTTP - Run mocked HTTP tests through PSGI applications

=head1 DESCRIPTION

Plack::Test::MockHTTP is a utility to run PSGI application given
HTTP::Request objects and return HTTP::Response object out of PSGI
application response. See L<Plack::Test> how to use this module.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::Test>

=cut



