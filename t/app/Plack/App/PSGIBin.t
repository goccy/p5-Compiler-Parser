use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/App/PSGIBin.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::App::PSGIBin',
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
        module { 'Plack::Util',
        },
        function { 'allow_path_info',
            body => leaf '1',
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
                        right => function_call { 'Plack::Util::load_psgi',
                            args => [
                                leaf '$file',
                            ],
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
package Plack::App::PSGIBin;
use strict;
use warnings;
use parent qw/Plack::App::File/;
use Plack::Util;

sub allow_path_info { 1 }

sub serve_path {
    my($self, $env, $file) = @_;

    local @{$env}{qw(SCRIPT_NAME PATH_INFO)} = @{$env}{qw( plack.file.SCRIPT_NAME plack.file.PATH_INFO )};

    my $app = $self->{_compiled}->{$file} ||= Plack::Util::load_psgi($file);
    $app->($env);
}

1;

__END__

=head1 NAME

Plack::App::PSGIBin - Run .psgi files from a directory

=head1 SYNOPSIS

  use Plack::App::PSGIBin;
  use Plack::Builder;

  my $app = Plack::App::PSGIBin->new(root => "/path/to/psgi/scripts")->to_app;
  builder {
      mount "/psgi" => $app;
  };

  # Or from the command line
  plackup -MPlack::App::PSGIBin -e 'Plack::App::PSGIBin->new(root => "/path/psgi/scripts")->to_app'

=head1 DESCRIPTION

This application loads I<.psgi> files (or actually whichever filename
extensions) from the root directory and run it as a PSGI
application. Suppose you have a directory containing C<foo.psgi> and
C<bar.psgi>, map this application to C</app> with
L<Plack::App::URLMap> and you can access them via the URL:

  http://example.com/app/foo.psgi
  http://example.com/app/bar.psgi

to load them. You can rename the file to the one without C<.psgi>
extension to make the URL look nicer, or use the URL rewriting tools
like L<Plack::Middleware::Rewrite> to do the same thing.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::App::CGIBin>

