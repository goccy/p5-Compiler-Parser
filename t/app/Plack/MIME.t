use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/MIME.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::MIME',
        },
        module { 'strict',
        },
        branch { '=',
            left => leaf '$MIME_TYPES',
            right => hash_ref { '{}',
                data => branch { ',',
                    left => branch { ',',
                        left => branch { ',',
                            left => branch { '=>',
                                left => leaf '.3gp',
                                right => leaf 'video/3gpp',
                            },
                            right => branch { '=>',
                                left => leaf '.yaml',
                                right => leaf 'text/yaml',
                            },
                        },
                        right => branch { '=>',
                            left => leaf '.yml',
                            right => leaf 'text/yaml',
                        },
                    },
                    right => branch { '=>',
                        left => leaf '.zip',
                        right => leaf 'application/zip',
                    },
                },
            },
        },
        branch { '=',
            left => leaf '$fallback',
            right => function { 'sub',
                body => hash_ref { '{}',
                },
            },
        },
        function { 'mime_type',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '$file',
                        },
                    },
                    right => leaf '@_',
                },
                branch { 'or',
                    left => branch { '=~',
                        left => leaf '$file',
                        right => regexp { '(\.[a-zA-Z0-9]+)$',
                        },
                    },
                    right => Test::Compiler::Parser::return { 'return',
                    },
                },
                branch { '||',
                    left => branch { '->',
                        left => leaf '$MIME_TYPES',
                        right => hash_ref { '{}',
                            data => function_call { 'lc',
                                args => [
                                    leaf '$1',
                                ],
                            },
                        },
                    },
                    right => branch { '->',
                        left => leaf '$fallback',
                        right => function_call { 'lc',
                            args => [
                                leaf '$1',
                            ],
                        },
                    },
                },
            ],
        },
        function { 'add_type',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                while_stmt { 'while',
                    expr => branch { '=',
                        left => list { '()',
                            data => branch { ',',
                                left => leaf '$ext',
                                right => leaf '$type',
                            },
                        },
                        right => function_call { 'splice',
                            args => [
                                branch { ',',
                                    left => branch { ',',
                                        left => leaf '@_',
                                        right => leaf '0',
                                    },
                                    right => leaf '2',
                                },
                            ],
                        },
                    },
                    true_stmt => branch { '=',
                        left => branch { '->',
                            left => leaf '$MIME_TYPES',
                            right => hash_ref { '{}',
                                data => function_call { 'lc',
                                    args => [
                                        leaf '$ext',
                                    ],
                                },
                            },
                        },
                        right => leaf '$type',
                    },
                },
            ],
        },
        function { 'set_fallback',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '$cb',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$fallback',
                    right => leaf '$cb',
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::MIME;
use strict;

# stolen from rack.mime.rb
our $MIME_TYPES = {
    ".3gp"     => "video/3gpp",
    ".yaml"    => "text/yaml",
    ".yml"     => "text/yaml",
    ".zip"     => "application/zip"
};

my $fallback = sub { };

sub mime_type {
    my($class, $file) = @_;
    $file =~ /(\.[a-zA-Z0-9]+)$/ or return;
    $MIME_TYPES->{lc $1} || $fallback->(lc $1);
}

sub add_type {
    my $class = shift;
    while (my($ext, $type) = splice @_, 0, 2) {
        $MIME_TYPES->{lc $ext} = $type;
    }
}

sub set_fallback {
    my($class, $cb) = @_;
    $fallback = $cb;
}

1;

__END__

=head1 NAME

Plack::MIME - MIME type registry

=head1 SYNOPSIS

  use Plack::MIME;

  my $mime = Plack::MIME->mime_type(".png"); # image/png

  # register new type(s)
  Plack::MIME->add_type(".foo" => "application/x-foo");

  # Use MIME::Types as a fallback
  use MIME::Types 'by_suffix';
  Plack::MIME->set_fallback(sub { (by_suffix $_[0])[0] });

=head1 DESCRIPTION

Plack::MIME is a simple MIME type registry for Plack applications. The
selection of MIME types is based on Rack's Rack::Mime module.

=head1 SEE ALSO

Rack::Mime L<MIME::Types>

=cut



