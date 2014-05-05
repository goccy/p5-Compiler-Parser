use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/App/WrapCGI.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::App::WrapCGI',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Component',
            },
        },
        module { 'Plack::Util::Accessor',
            args => reg_prefix { 'qw',
                expr => leaf 'script execute _app',
            },
        },
        module { 'File::Spec',
        },
        module { 'CGI::Emulate::PSGI',
        },
        module { 'CGI::Compile',
        },
        module { 'Carp',
        },
        module { 'POSIX',
            args => leaf ':sys_wait_h',
        },
        function { 'prepare_app',
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
                        left => leaf '$script',
                        right => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'script',
                                args => [
                                ],
                            },
                        },
                    },
                    right => function_call { 'croak',
                        args => [
                            leaf '\'script\' is not set',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$script',
                    right => branch { '->',
                        left => leaf 'File::Spec',
                        right => function_call { 'rel2abs',
                            args => [
                                leaf '$script',
                            ],
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'execute',
                            args => [
                            ],
                        },
                    },
                    true_stmt => [
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
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$stdoutr',
                                                    right => leaf '$stdoutw',
                                                },
                                            },
                                        ],
                                    },
                                    function_call { 'pipe',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$stdinr',
                                                    right => leaf '$stdinw',
                                                },
                                            },
                                        ],
                                    },
                                    branch { '=',
                                        left => leaf '$pid',
                                        right => function_call { 'fork',
                                            args => [
                                                list { '()',
                                                },
                                            ],
                                        },
                                    },
                                    if_stmt { 'unless',
                                        expr => function_call { 'defined',
                                            args => [
                                                leaf '$pid',
                                            ],
                                        },
                                        true_stmt => function_call { 'Carp::croak',
                                            args => [
                                                leaf 'fork failed: $!',
                                            ],
                                        },
                                    },
                                    if_stmt { 'if',
                                        expr => branch { '==',
                                            left => leaf '$pid',
                                            right => leaf '0',
                                        },
                                        true_stmt => [
                                            branch { '=',
                                                left => hash { '$SIG',
                                                    key => hash_ref { '{}',
                                                        data => leaf '__DIE__',
                                                    },
                                                },
                                                right => function { 'sub',
                                                    body => [
                                                        function_call { 'print',
                                                            args => [
                                                                handle { 'STDERR',
                                                                },
                                                                leaf '@_',
                                                            ],
                                                        },
                                                        function_call { 'exit',
                                                            args => [
                                                                leaf '1',
                                                            ],
                                                        },
                                                    ],
                                                },
                                            },
                                            function_call { 'close',
                                                args => [
                                                    leaf '$stdoutr',
                                                ],
                                            },
                                            function_call { 'close',
                                                args => [
                                                    leaf '$stdinw',
                                                ],
                                            },
                                            branch { '=',
                                                left => leaf '%ENV',
                                                right => list { '()',
                                                    data => branch { ',',
                                                        left => leaf '%ENV',
                                                        right => branch { '->',
                                                            left => leaf 'CGI::Emulate::PSGI',
                                                            right => function_call { 'emulate_environment',
                                                                args => [
                                                                    leaf '$env',
                                                                ],
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                            branch { 'or',
                                                left => function_call { 'open',
                                                    args => [
                                                        list { '()',
                                                            data => branch { ',',
                                                                left => handle { 'STDOUT',
                                                                },
                                                                right => branch { '.',
                                                                    left => leaf '>&=',
                                                                    right => function_call { 'fileno',
                                                                        args => [
                                                                            leaf '$stdoutw',
                                                                        ],
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    ],
                                                },
                                                right => function_call { 'Carp::croak',
                                                    args => [
                                                        leaf 'Cannot dup STDOUT: $!',
                                                    ],
                                                },
                                            },
                                            branch { 'or',
                                                left => function_call { 'open',
                                                    args => [
                                                        list { '()',
                                                            data => branch { ',',
                                                                left => handle { 'STDIN',
                                                                },
                                                                right => branch { '.',
                                                                    left => leaf '<&=',
                                                                    right => function_call { 'fileno',
                                                                        args => [
                                                                            leaf '$stdinr',
                                                                        ],
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    ],
                                                },
                                                right => function_call { 'Carp::croak',
                                                    args => [
                                                        leaf 'Cannot dup STDIN: $!',
                                                    ],
                                                },
                                            },
                                            function_call { 'chdir',
                                                args => [
                                                    function_call { 'File::Basename::dirname',
                                                        args => [
                                                            leaf '$script',
                                                        ],
                                                    },
                                                ],
                                            },
                                            branch { 'or',
                                                left => function_call { 'exec',
                                                    args => [
                                                        leaf '$script',
                                                    ],
                                                },
                                                right => function_call { 'Carp::croak',
                                                    args => [
                                                        leaf 'cannot exec: $!',
                                                    ],
                                                },
                                            },
                                            function_call { 'exit',
                                                args => [
                                                    leaf '2',
                                                ],
                                            },
                                        ],
                                    },
                                    function_call { 'close',
                                        args => [
                                            leaf '$stdoutw',
                                        ],
                                    },
                                    function_call { 'close',
                                        args => [
                                            leaf '$stdinr',
                                        ],
                                    },
                                    function_call { 'syswrite',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$stdinw',
                                                    right => do_stmt { 'do',
                                                        stmt => [
                                                            leaf '$/',
                                                            branch { '=',
                                                                left => leaf '$fh',
                                                                right => branch { '->',
                                                                    left => leaf '$env',
                                                                    right => hash_ref { '{}',
                                                                        data => leaf 'psgi.input',
                                                                    },
                                                                },
                                                            },
                                                            handle_read { '$fh',
                                                            },
                                                        ],
                                                    },
                                                },
                                            },
                                        ],
                                    },
                                    function_call { 'close',
                                        args => [
                                            leaf '$stdinw',
                                        ],
                                    },
                                    branch { '=',
                                        left => leaf '$res',
                                        right => leaf '',
                                    },
                                    while_stmt { 'while',
                                        expr => branch { '<=',
                                            left => function_call { 'waitpid',
                                                args => [
                                                    list { '()',
                                                        data => branch { ',',
                                                            left => leaf '$pid',
                                                            right => leaf 'WNOHANG',
                                                        },
                                                    },
                                                ],
                                            },
                                            right => leaf '0',
                                        },
                                        true_stmt => branch { '.=',
                                            left => leaf '$res',
                                            right => do_stmt { 'do',
                                                stmt => [
                                                    leaf '$/',
                                                    handle_read { '$stdoutr',
                                                    },
                                                ],
                                            },
                                        },
                                    },
                                    branch { '.=',
                                        left => leaf '$res',
                                        right => do_stmt { 'do',
                                            stmt => [
                                                leaf '$/',
                                                handle_read { '$stdoutr',
                                                },
                                            ],
                                        },
                                    },
                                    if_stmt { 'if',
                                        expr => function_call { 'POSIX::WIFEXITED',
                                            args => [
                                                leaf '$?',
                                            ],
                                        },
                                        true_stmt => Test::Compiler::Parser::return { 'return',
                                            body => function_call { 'CGI::Parse::PSGI::parse_cgi_output',
                                                args => [
                                                    single_term_operator { '\\',
                                                        expr => leaf '$res',
                                                    },
                                                ],
                                            },
                                        },
                                        false_stmt => else_stmt { 'else',
                                            stmt => function_call { 'Carp::croak',
                                                args => [
                                                    leaf 'Error at run_on_shell CGI: $!',
                                                ],
                                            },
                                        },
                                    },
                                ],
                            },
                        },
                        branch { '->',
                            left => leaf '$self',
                            right => function_call { '_app',
                                args => [
                                    leaf '$app',
                                ],
                            },
                        },
                    ],
                    false_stmt => else_stmt { 'else',
                        stmt => [
                            branch { '=',
                                left => leaf '$sub',
                                right => branch { '->',
                                    left => leaf 'CGI::Compile',
                                    right => function_call { 'compile',
                                        args => [
                                            leaf '$script',
                                        ],
                                    },
                                },
                            },
                            branch { '=',
                                left => leaf '$app',
                                right => branch { '->',
                                    left => leaf 'CGI::Emulate::PSGI',
                                    right => function_call { 'handler',
                                        args => [
                                            leaf '$sub',
                                        ],
                                    },
                                },
                            },
                            branch { '->',
                                left => leaf '$self',
                                right => function_call { '_app',
                                    args => [
                                        leaf '$app',
                                    ],
                                },
                            },
                        ],
                    },
                },
            ],
        },
        function { 'call',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf '$self',
                        right => function_call { '_app',
                            args => [
                            ],
                        },
                    },
                    right => list { '()',
                        data => leaf '$env',
                    },
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::App::WrapCGI;
use strict;
use warnings;
use parent qw(Plack::Component);
use Plack::Util::Accessor qw(script execute _app);
use File::Spec;
use CGI::Emulate::PSGI;
use CGI::Compile;
use Carp;
use POSIX ":sys_wait_h";

sub prepare_app {
    my $self = shift;
    my $script = $self->script
        or croak "'script' is not set";

    $script = File::Spec->rel2abs($script);

    if ($self->execute) {
        my $app = sub {
            my $env = shift;

            pipe( my $stdoutr, my $stdoutw );
            pipe( my $stdinr,  my $stdinw );


            my $pid = fork();
            Carp::croak("fork failed: $!") unless defined $pid;


            if ($pid == 0) { # child
                local $SIG{__DIE__} = sub {
                    print STDERR @_;
                    exit(1);
                };

                close $stdoutr;
                close $stdinw;

                local %ENV = (%ENV, CGI::Emulate::PSGI->emulate_environment($env));

                open( STDOUT, ">&=" . fileno($stdoutw) )
                  or Carp::croak "Cannot dup STDOUT: $!";
                open( STDIN, "<&=" . fileno($stdinr) )
                  or Carp::croak "Cannot dup STDIN: $!";

                chdir(File::Basename::dirname($script));
                exec($script) or Carp::croak("cannot exec: $!");

                exit(2);
            }

            close $stdoutw;
            close $stdinr;

            syswrite($stdinw, do {
                local $/;
                my $fh = $env->{'psgi.input'};
                <$fh>;
            });
            # close STDIN so child will stop waiting
            close $stdinw;

            my $res = '';
            while (waitpid($pid, WNOHANG) <= 0) {
                $res .= do { local $/; <$stdoutr> };
            }
            $res .= do { local $/; <$stdoutr> };

            if (POSIX::WIFEXITED($?)) {
                return CGI::Parse::PSGI::parse_cgi_output(\$res);
            } else {
                Carp::croak("Error at run_on_shell CGI: $!");
            }
        };
        $self->_app($app);
    } else {
        my $sub = CGI::Compile->compile($script);
        my $app = CGI::Emulate::PSGI->handler($sub);

        $self->_app($app);
    }
}

sub call {
    my($self, $env) = @_;
    $self->_app->($env);
}

1;

__END__

=head1 NAME

Plack::App::WrapCGI - Compiles a CGI script as PSGI application

=head1 SYNOPSIS

  use Plack::App::WrapCGI;

  my $app = Plack::App::WrapCGI->new(script => "/path/to/script.pl")->to_app;

  # if you want to execute as a real CGI script
  my $app = Plack::App::WrapCGI->new(script => "/path/to/script.rb", execute => 1)->to_app;

=head1 DESCRIPTION

Plack::App::WrapCGI compiles a CGI script into a PSGI application
using L<CGI::Compile> and L<CGI::Emulate::PSGI>, and runs it with any
PSGI server as a PSGI application.

See also L<Plack::App::CGIBin> if you have a directory that contains a
lot of CGI scripts and serve them like Apache's mod_cgi.

=head1 METHODS

=over 4

=item new

  my $app = Plack::App::WrapCGI->new(%args);

Creates a new PSGI application using the given script. I<%args> has two
parameters:

=over 8

=item script

The path to a CGI-style program. This is a required parameter.

=item execute

An optional parameter. When set to a true value, this app will run the script
with a CGI-style C<fork>/C<exec> model. Note that you may run programs written
in other languages with this approach.

=back

=back

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::App::CGIBin>

=cut

