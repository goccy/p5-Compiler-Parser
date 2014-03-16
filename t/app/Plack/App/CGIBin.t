use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/App/CGIBin.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::App::CGIBin',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::App::File',
            },
        },
        module { 'Plack::Util::Accessor',
            args => reg_prefix { 'qw',
                expr => leaf ' exec_cb ',
            },
        },
        module { 'Plack::App::WrapCGI',
        },
        function { 'allow_path_info',
            body => leaf '1',
        },
        leaf '%exec_cache',
        function { 'would_exec',
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
                    expr => function_call { 'exists',
                        args => [
                            hash { '$exec_cache',
                                key => hash_ref { '{}',
                                    data => leaf '$file',
                                },
                            },
                        ],
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => hash { '$exec_cache',
                            key => hash_ref { '{}',
                                data => leaf '$file',
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '$exec_cb',
                    right => branch { '||',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'exec_cb',
                                args => [
                                ],
                            },
                        },
                        right => function { 'sub',
                            body => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'exec_cb_default',
                                    args => [
                                        leaf '@_',
                                    ],
                                },
                            },
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '=',
                        left => hash { '$exec_cache',
                            key => hash_ref { '{}',
                                data => leaf '$file',
                            },
                        },
                        right => branch { '->',
                            left => leaf '$exec_cb',
                            right => list { '()',
                                data => leaf '$file',
                            },
                        },
                    },
                },
            ],
        },
        function { 'exec_cb_default',
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
                    expr => branch { '=~',
                        left => leaf '$file',
                        right => regexp { '\.pl$',
                            option => leaf 'i',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => leaf '0',
                    },
                    false_stmt => if_stmt { 'elsif',
                        expr => branch { '=~',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'shebang_for',
                                    args => [
                                        leaf '$file',
                                    ],
                                },
                            },
                            right => regexp { '^\#\!.*perl',
                            },
                        },
                        true_stmt => Test::Compiler::Parser::return { 'return',
                            body => leaf '0',
                        },
                        false_stmt => else_stmt { 'else',
                            stmt => Test::Compiler::Parser::return { 'return',
                                body => leaf '1',
                            },
                        },
                    },
                },
            ],
        },
        function { 'shebang_for',
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
                branch { 'or',
                    left => function_call { 'open',
                        args => [
                            branch { ',',
                                left => branch { ',',
                                    left => leaf '$fh',
                                    right => leaf '<',
                                },
                                right => leaf '$file',
                            },
                        ],
                    },
                    right => Test::Compiler::Parser::return { 'return',
                        body => leaf '',
                    },
                },
                branch { '=',
                    left => leaf '$line',
                    right => handle_read { '$fh',
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$line',
                },
            ],
        },
        function { 'serve_path',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$self',
                                right => leaf '$env',
                            },
                            right => leaf '$file',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => branch { '->',
                        left => dereference { '@{',
                            expr => leaf '$env',
                        },
                        right => hash_ref { '{}',
                            data => reg_prefix { 'qw',
                                expr => leaf 'SCRIPT_NAME PATH_INFO',
                            },
                        },
                    },
                    right => branch { '->',
                        left => dereference { '@{',
                            expr => leaf '$env',
                        },
                        right => hash_ref { '{}',
                            data => reg_prefix { 'qw',
                                expr => leaf ' plack.file.SCRIPT_NAME plack.file.PATH_INFO ',
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '$app',
                    right => branch { '||=',
                        left => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf '_compiled',
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf '$file',
                            },
                        },
                        right => branch { '->',
                            left => branch { '->',
                                left => leaf 'Plack::App::WrapCGI',
                                right => function_call { 'new',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => branch { ',',
                                                    left => branch { '=>',
                                                        left => leaf 'script',
                                                        right => leaf '$file',
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'execute',
                                                        right => branch { '->',
                                                            left => leaf '$self',
                                                            right => function_call { 'would_exec',
                                                                args => [
                                                                    leaf '$file',
                                                                ],
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                            right => function_call { 'to_app',
                                args => [
                                ],
                            },
                        },
                    },
                },
                branch { '->',
                    left => leaf '$app',
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
package Plack::App::CGIBin;
use strict;
use warnings;
use parent qw/Plack::App::File/;
use Plack::Util::Accessor qw( exec_cb );
use Plack::App::WrapCGI;

sub allow_path_info { 1 }

my %exec_cache;

sub would_exec {
    my($self, $file) = @_;

    return $exec_cache{$file} if exists $exec_cache{$file};

    my $exec_cb = $self->exec_cb || sub { $self->exec_cb_default(@_) };

    return $exec_cache{$file} = $exec_cb->($file);
}

sub exec_cb_default {
    my($self, $file) = @_;

    if ($file =~ /\.pl$/i) {
        return 0;
    } elsif ($self->shebang_for($file) =~ /^\#\!.*perl/) {
        return 0;
    } else {
        return 1;
    }
}

sub shebang_for {
    my($self, $file) = @_;

    open my $fh, "<", $file or return '';
    my $line = <$fh>;
    return $line;
}

sub serve_path {
    my($self, $env, $file) = @_;

    local @{$env}{qw(SCRIPT_NAME PATH_INFO)} = @{$env}{qw( plack.file.SCRIPT_NAME plack.file.PATH_INFO )};

    my $app = $self->{_compiled}->{$file} ||= Plack::App::WrapCGI->new(
        script => $file, execute => $self->would_exec($file),
    )->to_app;
    $app->($env);
}

1;

__END__

=head1 NAME

Plack::App::CGIBin - cgi-bin replacement for Plack servers

=head1 SYNOPSIS

  use Plack::App::CGIBin;
  use Plack::Builder;

  my $app = Plack::App::CGIBin->new(root => "/path/to/cgi-bin")->to_app;
  builder {
      mount "/cgi-bin" => $app;
  };

  # Or from the command line
  plackup -MPlack::App::CGIBin -e 'Plack::App::CGIBin->new(root => "/path/to/cgi-bin")->to_app'

=head1 DESCRIPTION

Plack::App::CGIBin allows you to load CGI scripts from a directory and
convert them into a PSGI application.

This would give you the extreme easiness when you have bunch of old
CGI scripts that is loaded using I<cgi-bin> of Apache web server.

=head1 HOW IT WORKS

This application checks if a given file path is a perl script and if
so, uses L<CGI::Compile> to compile a CGI script into a sub (like
L<ModPerl::Registry>) and then run it as a persistent application
using L<CGI::Emulate::PSGI>.

If the given file is not a perl script, it executes the script just
like a normal CGI script with fork & exec. This is like a normal web
server mode and no performance benefit is achieved.

The default mechanism to determine if a given file is a Perl script is
as follows:

=over 4

=item *

Check if the filename ends with C<.pl>. If yes, it is a Perl script.

=item *

Open the file and see if the shebang (first line of the file) contains
the word C<perl> (like C<#!/usr/bin/perl>). If yes, it is a Perl
script.

=back

You can customize this behavior by passing C<exec_cb> callback, which
takes a file path to its first argument.

For example, if your perl-based CGI script uses lots of global
variables and such and are not ready to run on a persistent
environment, you can do:

  my $app = Plack::App::CGIBin->new(
      root => "/path/to/cgi-bin",
      exec_cb => sub { 1 },
  )->to_app;

to always force the execute option for any files.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::App::File> L<CGI::Emulate::PSGI> L<CGI::Compile> L<Plack::App::WrapCGI>

See also L<Plack::App::WrapCGI> if you compile one CGI script into a
PSGI application without serving CGI scripts from a directory, to
remove overhead of filesystem lookups, etc.

=cut

