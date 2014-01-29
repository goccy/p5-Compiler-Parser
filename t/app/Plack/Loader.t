use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Loader.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Loader',
        },
        module { 'strict',
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        module { 'Plack::Util',
        },
        module { 'Try::Tiny',
        },
        function { 'new',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => hash_ref { '{}',
                            },
                            right => leaf '$class',
                        },
                    ],
                },
            ],
        },
        function { 'watch',
        },
        function { 'auto',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '@args',
                        },
                    },
                    right => leaf '@_',
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$backend',
                        right => branch { '->',
                            left => leaf '$class',
                            right => function_call { 'guess',
                                args => [
                                ],
                            },
                        },
                    },
                    right => function_call { 'Carp::croak',
                        args => [
                            leaf 'Couldn\'t auto-guess server server implementation. Set it with PLACK_SERVER',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$server',
                    right => function_call { 'try',
                        args => [
                            branch { '->',
                                left => leaf '$class',
                                right => function_call { 'load',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => leaf '$backend',
                                                right => leaf '@args',
                                            },
                                        },
                                    ],
                                },
                            },
                            function_call { 'catch',
                                args => [
                                    [
                                        if_stmt { 'if',
                                            expr => branch { 'or',
                                                left => branch { 'eq',
                                                    left => branch { '||',
                                                        left => hash { '$ENV',
                                                            key => hash_ref { '{}',
                                                                data => leaf 'PLACK_ENV',
                                                            },
                                                        },
                                                        right => leaf '',
                                                    },
                                                    right => leaf 'development',
                                                },
                                                right => single_term_operator { '!',
                                                    expr => regexp { '^Can\'t locate ',
                                                    },
                                                },
                                            },
                                            true_stmt => if_stmt { 'if',
                                                expr => branch { '&&',
                                                    left => hash { '$ENV',
                                                        key => hash_ref { '{}',
                                                            data => leaf 'PLACK_ENV',
                                                        },
                                                    },
                                                    right => branch { 'eq',
                                                        left => hash { '$ENV',
                                                            key => hash_ref { '{}',
                                                                data => leaf 'PLACK_ENV',
                                                            },
                                                        },
                                                        right => leaf 'development',
                                                    },
                                                },
                                                true_stmt => function_call { 'warn',
                                                    args => [
                                                        branch { ',',
                                                            left => leaf 'Autoloading \'$backend\' backend failed. Falling back to the Standalone. ',
                                                            right => leaf '(You might need to install Plack::Handler::$backend from CPAN.  Caught error was: $_)\n',
                                                        },
                                                    ],
                                                },
                                            },
                                        },
                                        branch { '->',
                                            left => leaf '$class',
                                            right => function_call { 'load',
                                                args => [
                                                    list { '()',
                                                        data => branch { '=>',
                                                            left => leaf 'Standalone',
                                                            right => leaf '@args',
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                    ],
                                ],
                            },
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$server',
                },
            ],
        },
        function { 'load',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$class',
                                right => leaf '$server',
                            },
                            right => leaf '@args',
                        },
                    },
                    right => leaf '@_',
                },
                list { '()',
                    data => branch { ',',
                        left => leaf '$server_class',
                        right => leaf '$error',
                    },
                },
                function_call { 'try',
                    args => [
                        branch { '=',
                            left => leaf '$server_class',
                            right => function_call { 'Plack::Util::load_class',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => leaf '$server',
                                            right => leaf 'Plack::Handler',
                                        },
                                    },
                                ],
                            },
                        },
                        function_call { 'catch',
                            args => [
                                branch { '||=',
                                    left => leaf '$error',
                                    right => leaf '$_',
                                },
                            ],
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => list { '()',
                        data => leaf '$server_class',
                    },
                    true_stmt => branch { '->',
                        left => leaf '$server_class',
                        right => function_call { 'new',
                            args => [
                                leaf '@args',
                            ],
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => function_call { 'die',
                            args => [
                                leaf '$error',
                            ],
                        },
                    },
                },
            ],
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
                            data => leaf 'app',
                        },
                    },
                    right => branch { '->',
                        left => leaf '$builder',
                        right => list { '()',
                        },
                    },
                },
            ],
        },
        function { 'guess',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$env',
                    right => branch { '->',
                        left => leaf '$class',
                        right => function_call { 'env',
                            args => [
                            ],
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'PLACK_SERVER',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'PLACK_SERVER',
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '||',
                        left => branch { '||',
                            left => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'PHP_FCGI_CHILDREN',
                                },
                            },
                            right => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'FCGI_ROLE',
                                },
                            },
                        },
                        right => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'FCGI_SOCKET_PATH',
                            },
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => leaf 'FCGI',
                    },
                    false_stmt => if_stmt { 'elsif',
                        expr => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'GATEWAY_INTERFACE',
                            },
                        },
                        true_stmt => Test::Compiler::Parser::return { 'return',
                            body => leaf 'CGI',
                        },
                        false_stmt => if_stmt { 'elsif',
                            expr => function_call { 'exists',
                                args => [
                                    hash { '$INC',
                                        key => hash_ref { '{}',
                                            data => leaf 'Coro.pm',
                                        },
                                    },
                                ],
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
                                body => leaf 'Corona',
                            },
                            false_stmt => if_stmt { 'elsif',
                                expr => function_call { 'exists',
                                    args => [
                                        hash { '$INC',
                                            key => hash_ref { '{}',
                                                data => leaf 'AnyEvent.pm',
                                            },
                                        },
                                    ],
                                },
                                true_stmt => Test::Compiler::Parser::return { 'return',
                                    body => leaf 'Twiggy',
                                },
                                false_stmt => if_stmt { 'elsif',
                                    expr => function_call { 'exists',
                                        args => [
                                            hash { '$INC',
                                                key => hash_ref { '{}',
                                                    data => leaf 'POE.pm',
                                                },
                                            },
                                        ],
                                    },
                                    true_stmt => Test::Compiler::Parser::return { 'return',
                                        body => leaf 'POE',
                                    },
                                    false_stmt => else_stmt { 'else',
                                        stmt => Test::Compiler::Parser::return { 'return',
                                            body => leaf 'Standalone',
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            ],
        },
        function { 'env',
            body => single_term_operator { '\\',
                expr => leaf '%ENV',
            },
        },
        function { 'run',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$self',
                                right => leaf '$server',
                            },
                            right => leaf '$builder',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '->',
                    left => leaf '$server',
                    right => function_call { 'run',
                        args => [
                            branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'app',
                                },
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
package Plack::Loader;
use strict;
use Carp ();
use Plack::Util;
use Try::Tiny;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub watch {
    # do nothing. Override in subclass
}

sub auto {
    my($class, @args) = @_;

    my $backend = $class->guess
        or Carp::croak("Couldn't auto-guess server server implementation. Set it with PLACK_SERVER");

    my $server = try {
        $class->load($backend, @args);
    } catch {
        if (($ENV{PLACK_ENV}||'') eq 'development' or !/^Can't locate /) {
            warn "Autoloading '$backend' backend failed. Falling back to the Standalone. ",
                "(You might need to install Plack::Handler::$backend from CPAN.  Caught error was: $_)\n"
                    if $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development';
        }
        $class->load('Standalone' => @args);
    };

    return $server;
}

sub load {
    my($class, $server, @args) = @_;

    my($server_class, $error);
    try {
        $server_class = Plack::Util::load_class($server, 'Plack::Handler');
    } catch {
        $error ||= $_;
    };

    if ($server_class) {
        $server_class->new(@args);
    } else {
        die $error;
    }
}

sub preload_app {
    my($self, $builder) = @_;
    $self->{app} = $builder->();
}

sub guess {
    my $class = shift;

    my $env = $class->env;

    return $env->{PLACK_SERVER} if $env->{PLACK_SERVER};

    if ($env->{PHP_FCGI_CHILDREN} || $env->{FCGI_ROLE} || $env->{FCGI_SOCKET_PATH}) {
        return "FCGI";
    } elsif ($env->{GATEWAY_INTERFACE}) {
        return "CGI";
    } elsif (exists $INC{"Coro.pm"}) {
        return "Corona";
    } elsif (exists $INC{"AnyEvent.pm"}) {
        return "Twiggy";
    } elsif (exists $INC{"POE.pm"}) {
        return "POE";
    } else {
        return "Standalone";
    }
}

sub env { \%ENV }

sub run {
    my($self, $server, $builder) = @_;
    $server->run($self->{app});
}

1;

__END__

=head1 NAME

Plack::Loader - (auto)load Plack Servers

=head1 SYNOPSIS

  # auto-select server backends based on env vars
  use Plack::Loader;
  Plack::Loader->auto(%args)->run($app);

  # specify the implementation with a name
  Plack::Loader->load('FCGI', %args)->run($app);

=head1 DESCRIPTION

Plack::Loader is a factory class to load one of Plack::Handler subclasses based on the environment.

=head1 AUTOLOADING

C<< Plack::Loader->auto(%args) >> will autoload the most correct
server implementation by guessing from environment variables and Perl INC
hashes.

=over 4

=item PLACK_SERVER

  env PLACK_SERVER=AnyEvent ...

Plack users can specify the specific implementation they want to load
using the C<PLACK_SERVER> environment variable.

=item PHP_FCGI_CHILDREN, GATEWAY_INTERFACE

If there's one of FastCGI or CGI specific environment variables set,
use the corresponding server implementation.

=item %INC

If one of L<AnyEvent>, L<Coro> or L<POE> is loaded, the relevant
server implementation such as L<Twiggy>, L<Corona> or
L<POE::Component::Server::PSGI> will be loaded, if they're available.

=back

=cut



