use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Loader/Shotgun.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Loader::Shotgun',
        },
        module { 'strict',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Loader',
            },
        },
        module { 'Storable',
        },
        module { 'Try::Tiny',
        },
        module { 'Plack::Middleware::BufferedStreaming',
        },
        function { 'preload_app',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$builder',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'builder',
                        },
                    },
                    right => function { 'sub',
                        body => branch { '->',
                            left => leaf 'Plack::Middleware::BufferedStreaming',
                            right => function_call { 'wrap',
                                args => [
                                    branch { '->',
                                        left => leaf '$builder',
                                        right => list { '()',
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
            ],
        },
        function { 'run',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$server',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$app',
                    right => function { 'sub',
                        body => [
                            branch { '=',
                                left => leaf '$env',
                                right => function_call { 'shift',
                                    args => [
                                    ],
                                },
                            },
                            function_call { 'pipe',
                                args => [
                                    branch { ',',
                                        left => leaf '$read',
                                        right => leaf '$write',
                                    },
                                ],
                            },
                            branch { '=',
                                left => leaf '$pid',
                                right => function_call { 'fork',
                                    args => [
                                    ],
                                },
                            },
                            if_stmt { 'if',
                                expr => leaf '$pid',
                                true_stmt => [
                                    function_call { 'close',
                                        args => [
                                            leaf '$write',
                                        ],
                                    },
                                    branch { '=',
                                        left => leaf '$res',
                                        right => function_call { 'Storable::thaw',
                                            args => [
                                                function_call { 'join',
                                                    args => [
                                                        branch { ',',
                                                            left => leaf '',
                                                            right => handle_read { '$read',
                                                            },
                                                        },
                                                    ],
                                                },
                                            ],
                                        },
                                    },
                                    function_call { 'close',
                                        args => [
                                            leaf '$read',
                                        ],
                                    },
                                    function_call { 'waitpid',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$pid',
                                                    right => leaf '0',
                                                },
                                            },
                                        ],
                                    },
                                    Test::Compiler::Parser::return { 'return',
                                        body => leaf '$res',
                                    },
                                ],
                                false_stmt => else_stmt { 'else',
                                    stmt => [
                                        function_call { 'close',
                                            args => [
                                                leaf '$read',
                                            ],
                                        },
                                        leaf '$res',
                                        function_call { 'try',
                                            args => [
                                                [
                                                    branch { '=',
                                                        left => branch { '->',
                                                            left => leaf '$env',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'psgi.streaming',
                                                            },
                                                        },
                                                        right => leaf '0',
                                                    },
                                                    branch { '=',
                                                        left => leaf '$res',
                                                        right => branch { '->',
                                                            left => branch { '->',
                                                                left => branch { '->',
                                                                    left => leaf '$self',
                                                                    right => hash_ref { '{}',
                                                                        data => leaf 'builder',
                                                                    },
                                                                },
                                                                right => list { '()',
                                                                },
                                                            },
                                                            right => list { '()',
                                                                data => leaf '$env',
                                                            },
                                                        },
                                                    },
                                                    leaf '@body',
                                                    function_call { 'Plack::Util::foreach',
                                                        args => [
                                                            list { '()',
                                                                data => branch { ',',
                                                                    left => branch { '->',
                                                                        left => leaf '$res',
                                                                        right => array_ref { '[]',
                                                                            data => leaf '2',
                                                                        },
                                                                    },
                                                                    right => function { 'sub',
                                                                        body => function_call { 'push',
                                                                            args => [
                                                                                branch { ',',
                                                                                    left => leaf '@body',
                                                                                    right => array { '$_',
                                                                                        idx => array_ref { '[]',
                                                                                            data => leaf '0',
                                                                                        },
                                                                                    },
                                                                                },
                                                                            ],
                                                                        },
                                                                    },
                                                                },
                                                            },
                                                        ],
                                                    },
                                                    branch { '=',
                                                        left => branch { '->',
                                                            left => leaf '$res',
                                                            right => array_ref { '[]',
                                                                data => leaf '2',
                                                            },
                                                        },
                                                        right => single_term_operator { '\\',
                                                            expr => leaf '@body',
                                                        },
                                                    },
                                                ],
                                                function_call { 'catch',
                                                    args => [
                                                        [
                                                            branch { '->',
                                                                left => branch { '->',
                                                                    left => leaf '$env',
                                                                    right => hash_ref { '{}',
                                                                        data => leaf 'psgi.errors',
                                                                    },
                                                                },
                                                                right => function_call { 'print',
                                                                    args => [
                                                                        leaf '$_',
                                                                    ],
                                                                },
                                                            },
                                                            branch { '=',
                                                                left => leaf '$res',
                                                                right => array_ref { '[]',
                                                                    data => branch { ',',
                                                                        left => branch { ',',
                                                                            left => leaf '500',
                                                                            right => array_ref { '[]',
                                                                                data => branch { ',',
                                                                                    left => leaf 'Content-Type',
                                                                                    right => leaf 'text/plain',
                                                                                },
                                                                            },
                                                                        },
                                                                        right => array_ref { '[]',
                                                                            data => leaf 'Internal Server Error',
                                                                        },
                                                                    },
                                                                },
                                                            },
                                                        ],
                                                    ],
                                                },
                                            ],
                                        },
                                        function_call { 'print',
                                            args => [
                                                branch { '->',
                                                    left => hash_ref { '{}',
                                                        data => leaf '$write',
                                                    },
                                                    right => function_call { 'Storable::freeze',
                                                        args => [
                                                            leaf '$res',
                                                        ],
                                                    },
                                                },
                                            ],
                                        },
                                        function_call { 'close',
                                            args => [
                                                leaf '$write',
                                            ],
                                        },
                                        function_call { 'exit',
                                            args => [
                                            ],
                                        },
                                    ],
                                },
                            },
                        ],
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
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Loader::Shotgun;
use strict;
use parent qw(Plack::Loader);
use Storable;
use Try::Tiny;
use Plack::Middleware::BufferedStreaming;

sub preload_app {
    my($self, $builder) = @_;
    $self->{builder} = sub { Plack::Middleware::BufferedStreaming->wrap($builder->()) };
}

sub run {
    my($self, $server) = @_;

    my $app = sub {
        my $env = shift;

        pipe my $read, my $write;

        my $pid = fork;
        if ($pid) {
            # parent
            close $write;
            my $res = Storable::thaw(join '', <$read>);
            close $read;
            waitpid($pid, 0);

            return $res;
        } else {
            # child
            close $read;

            my $res;
            try {
                $env->{'psgi.streaming'} = 0;
                $res = $self->{builder}->()->($env);
                my @body;
                Plack::Util::foreach($res->[2], sub { push @body, $_[0] });
                $res->[2] = \@body;
            } catch {
                $env->{'psgi.errors'}->print($_);
                $res = [ 500, [ "Content-Type", "text/plain" ], [ "Internal Server Error" ] ];
            };

            print {$write} Storable::freeze($res);
            close $write;
            exit;
        }
    };

    $server->run($app);
}

1;

__END__

=head1 NAME

Plack::Loader::Shotgun - forking implementation of plackup

=head1 SYNOPSIS

  plackup -L Shotgun

=head1 DESCRIPTION

Shotgun loader delays the compilation and execution of your
application until the runtime. When a new request comes in, this forks
a new child, compiles your code and runs the application.

This should be an ultimate alternative solution when reloading with
L<Plack::Middleware::Refresh> doesn't work, or plackup's default C<-r>
filesystem watcher causes problems. I can imagine this is useful for
applications which expects their application is only evaluated once
(like in-file templates) or on operating systems with broken fork
implementation, etc.

This is much like good old CGI's fork and run but you don't need a web
server, and there's a benefit of preloading modules that are not
likely to change. For instance if you develop a web application using
Moose and DBIx::Class,

  plackup -MMoose -MDBIx::Class -L Shotgun yourapp.psgi

would preload those modules and only re-evaluates your code in every
request.

=head1 AUTHOR

Tatsuhiko Miyagawa with an inspiration from L<http://github.com/rtomayko/shotgun>

=head1 SEE ALSO

L<plackup>

=cut

