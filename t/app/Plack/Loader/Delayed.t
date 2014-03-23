use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Loader/Delayed.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Loader::Delayed',
        },
        module { 'strict',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Loader',
            },
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
                    right => leaf '$builder',
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
                leaf '$compiled',
                branch { '=',
                    left => leaf '$app',
                    right => function { 'sub',
                        body => [
                            branch { '||=',
                                left => leaf '$compiled',
                                right => branch { '->',
                                    left => branch { '->',
                                        left => leaf '$self',
                                        right => hash_ref { '{}',
                                            data => leaf 'builder',
                                        },
                                    },
                                    right => list { '()',
                                    },
                                },
                            },
                            branch { '->',
                                left => leaf '$compiled',
                                right => list { '()',
                                    data => leaf '@_',
                                },
                            },
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$server',
                        right => hash_ref { '{}',
                            data => leaf 'psgi_app_builder',
                        },
                    },
                    right => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'builder',
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
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Loader::Delayed;
use strict;
use parent qw(Plack::Loader);

sub preload_app {
    my($self, $builder) = @_;
    $self->{builder} = $builder;
}

sub run {
    my($self, $server) = @_;

    my $compiled;
    my $app = sub {
        $compiled ||= $self->{builder}->();
        $compiled->(@_);
    };

    $server->{psgi_app_builder} = $self->{builder};
    $server->run($app);
}

1;

__END__

=head1 NAME

Plack::Loader::Delayed - Delay the loading of .psgi until the first run

=head1 SYNOPSIS

  plackup -s Starlet -L Delayed myapp.psgi

=head1 DESCRIPTION

This loader delays the compilation of specified PSGI application until
the first request time. This prevents bad things from happening with
preforking web servers like L<Starlet>, when your application
manipulates resources such as sockets or database connections in the
master startup process and then shared by children.

You can combine this loader with C<-M> command line option, like:

  plackup -s Starlet -MCatalyst -L Delayed myapp.psgi

loads the module Catalyst in the master process for the better process
management with copy-on-write, however the application C<myapp.psgi>
is loaded per children.

L<Starman> since version 0.2000 loads this loader by default unless
you specify the command line option C<--preload-app> for the
L<starman> executable.

=head1 DEVELOPERS

Web server developers can make use of C<psgi_app_builder> attribute
callback set in Plack::Handler, to load the application earlier than
the first request time.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<plackup>

=cut


