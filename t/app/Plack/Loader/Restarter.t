use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Loader/Restarter.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Loader::Restarter',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Loader',
            },
        },
        module { 'Plack::Util',
        },
        module { 'Try::Tiny',
        },
        function { 'new',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '$runner',
                        },
                    },
                    right => leaf '@_',
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => hash_ref { '{}',
                                data => branch { '=>',
                                    left => leaf 'watch',
                                    right => array_ref { '[]',
                                    },
                                },
                            },
                            right => leaf '$class',
                        },
                    ],
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
                            data => leaf 'builder',
                        },
                    },
                    right => leaf '$builder',
                },
            ],
        },
        function { 'watch',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '@dir',
                        },
                    },
                    right => leaf '@_',
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => dereference { '@{',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'watch',
                                    },
                                },
                            },
                            right => leaf '@dir',
                        },
                    ],
                },
            ],
        },
        function { '_fork_and_start',
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
                function_call { 'delete',
                    args => [
                        branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'pid',
                            },
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
                if_stmt { 'unless',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$pid',
                        ],
                    },
                    true_stmt => function_call { 'die',
                        args => [
                            leaf 'Can\'t fork: $!',
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '==',
                        left => leaf '$pid',
                        right => leaf '0',
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => leaf '$server',
                            right => function_call { 'run',
                                args => [
                                    branch { '->',
                                        left => branch { '->',
                                            left => leaf '$self',
                                            right => hash_ref { '{}',
                                                data => leaf 'builder',
                                            },
                                        },
                                        right => list { '()',
                                        },
                                    },
                                ],
                            },
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => branch { '=',
                            left => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'pid',
                                },
                            },
                            right => leaf '$pid',
                        },
                    },
                },
            ],
        },
        function { '_kill_child',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$pid',
                        right => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'pid',
                            },
                        },
                    },
                    right => Test::Compiler::Parser::return { 'return',
                    },
                },
                function_call { 'warn',
                    args => [
                        leaf 'Killing the existing server (pid:$pid)\n',
                    ],
                },
                function_call { 'kill',
                    args => [
                        branch { '=>',
                            left => leaf 'TERM',
                            right => leaf '$pid',
                        },
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
            ],
        },
        function { 'valid_file',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$file',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => branch { '&&',
                        left => branch { '&&',
                            left => branch { '=~',
                                left => branch { '->',
                                    left => leaf '$file',
                                    right => hash_ref { '{}',
                                        data => leaf 'path',
                                    },
                                },
                                right => reg_prefix { 'm',
                                    expr => leaf '(\d+)$',
                                },
                            },
                            right => branch { '>=',
                                left => leaf '$1',
                                right => leaf '4913',
                            },
                        },
                        right => branch { '<=',
                            left => leaf '$1',
                            right => leaf '5036',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => leaf '0',
                    },
                },
                branch { '!~',
                    left => branch { '->',
                        left => leaf '$file',
                        right => hash_ref { '{}',
                            data => leaf 'path',
                        },
                    },
                    right => reg_prefix { 'm',
                        expr => leaf '\.(?:git|svn)[/\\\]|\.(?:bak|swp|swpx|swx)$|~$|_flymake\.p[lm]$|\.#',
                    },
                },
            ],
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
                    left => leaf '$self',
                    right => function_call { '_fork_and_start',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => leaf '$server',
                                    right => leaf '$builder',
                                },
                            },
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'pid',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                    },
                },
                module { 'Filesys::Notify::Simple',
                },
                branch { '=',
                    left => leaf '$watcher',
                    right => branch { '->',
                        left => leaf 'Filesys::Notify::Simple',
                        right => function_call { 'new',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'watch',
                                    },
                                },
                            ],
                        },
                    },
                },
                function_call { 'warn',
                    args => [
                        leaf 'Watching @{$self->{watch}} for file updates.\n',
                    ],
                },
                branch { '=',
                    left => hash { '$SIG',
                        key => hash_ref { '{}',
                            data => leaf 'TERM',
                        },
                    },
                    right => function { 'sub',
                        body => [
                            branch { '->',
                                left => leaf '$self',
                                right => function_call { '_kill_child',
                                    args => [
                                    ],
                                },
                            },
                            function_call { 'exit',
                                args => [
                                    leaf '0',
                                ],
                            },
                        ],
                    },
                },
                while_stmt { 'while',
                    expr => leaf '1',
                    true_stmt => [
                        leaf '@restart',
                        branch { '->',
                            left => leaf '$watcher',
                            right => function_call { 'wait',
                                args => [
                                    function { 'sub',
                                        body => [
                                            branch { '=',
                                                left => leaf '@events',
                                                right => leaf '@_',
                                            },
                                            branch { '=',
                                                left => leaf '@events',
                                                right => function_call { 'grep',
                                                    args => [
                                                        branch { ',',
                                                            left => branch { '->',
                                                                left => leaf '$self',
                                                                right => function_call { 'valid_file',
                                                                    args => [
                                                                        leaf '$_',
                                                                    ],
                                                                },
                                                            },
                                                            right => leaf '@events',
                                                        },
                                                    ],
                                                },
                                            },
                                            if_stmt { 'unless',
                                                expr => leaf '@events',
                                                true_stmt => Test::Compiler::Parser::return { 'return',
                                                },
                                            },
                                            branch { '=',
                                                left => leaf '@restart',
                                                right => leaf '@events',
                                            },
                                        ],
                                    },
                                ],
                            },
                        },
                        if_stmt { 'unless',
                            expr => leaf '@restart',
                            true_stmt => control_stmt { 'next',
                            },
                        },
                        foreach_stmt { 'for',
                            cond => leaf '@restart',
                            true_stmt => function_call { 'warn',
                                args => [
                                    leaf '-- $ev->{path} updated.\n',
                                ],
                            },
                            itr => leaf '$ev',
                        },
                        branch { '->',
                            left => leaf '$self',
                            right => function_call { '_kill_child',
                                args => [
                                ],
                            },
                        },
                        function_call { 'warn',
                            args => [
                                leaf 'Successfully killed! Restarting the new server process.\n',
                            ],
                        },
                        branch { '->',
                            left => leaf '$self',
                            right => function_call { '_fork_and_start',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => leaf '$server',
                                            right => leaf '$builder',
                                        },
                                    },
                                ],
                            },
                        },
                        if_stmt { 'unless',
                            expr => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'pid',
                                },
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
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
package Plack::Loader::Restarter;
use strict;
use warnings;
use parent qw(Plack::Loader);
use Plack::Util;
use Try::Tiny;

sub new {
    my($class, $runner) = @_;
    bless { watch => [] }, $class;
}

sub preload_app {
    my($self, $builder) = @_;
    $self->{builder} = $builder;
}

sub watch {
    my($self, @dir) = @_;
    push @{$self->{watch}}, @dir;
}

sub _fork_and_start {
    my($self, $server) = @_;

    delete $self->{pid}; # re-init in case it's a restart

    my $pid = fork;
    die "Can't fork: $!" unless defined $pid;

    if ($pid == 0) { # child
        return $server->run($self->{builder}->());
    } else {
        $self->{pid} = $pid;
    }
}

sub _kill_child {
    my $self = shift;

    my $pid = $self->{pid} or return;
    warn "Killing the existing server (pid:$pid)\n";
    kill 'TERM' => $pid;
    waitpid($pid, 0);
}

sub valid_file {
    my($self, $file) = @_;

    # vim temporary file is  4913 to 5036
    # http://www.mail-archive.com/vim_dev@googlegroups.com/msg07518.html
    if ( $file->{path} =~ m{(\d+)$} && $1 >= 4913 && $1 <= 5036) {
        return 0;
    }
    $file->{path} !~ m!\.(?:git|svn)[/\\]|\.(?:bak|swp|swpx|swx)$|~$|_flymake\.p[lm]$|\.#!;
}

sub run {
    my($self, $server, $builder) = @_;

    $self->_fork_and_start($server, $builder);
    return unless $self->{pid};

    require Filesys::Notify::Simple;
    my $watcher = Filesys::Notify::Simple->new($self->{watch});
    warn "Watching @{$self->{watch}} for file updates.\n";
    local $SIG{TERM} = sub { $self->_kill_child; exit(0); };

    while (1) {
        my @restart;

        # this is blocking
        $watcher->wait(sub {
            my @events = @_;
            @events = grep $self->valid_file($_), @events;
            return unless @events;

            @restart = @events;
        });

        next unless @restart;

        for my $ev (@restart) {
            warn "-- $ev->{path} updated.\n";
        }

        $self->_kill_child;
        warn "Successfully killed! Restarting the new server process.\n";
        $self->_fork_and_start($server, $builder);
        return unless $self->{pid};
    }
}

1;

__END__

=head1 NAME

Plack::Loader::Restarter - Restarting loader

=head1 SYNOPSIS

  plackup -r -R paths

=head1 DESCRIPTION

Plack::Loader::Restarter is a loader backend that implements C<-r> and
C<-R> option for the L<plackup> script. It forks the server as a child
process and the parent watches the directories for file updates, and
whenever it receives the notification, kills the child server and
restart.

=head1 SEE ALSO

L<Plack::Runner>, L<Catalyst::Restarter>

=cut

