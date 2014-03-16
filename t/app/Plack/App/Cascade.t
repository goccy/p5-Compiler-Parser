use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/App/Cascade.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::App::Cascade',
        },
        module { 'strict',
        },
        module { 'base',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Component',
            },
        },
        module { 'Plack::Util',
        },
        module { 'Plack::Util::Accessor',
            args => reg_prefix { 'qw',
                expr => leaf 'apps catch codes',
            },
        },
        function { 'add',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'apps',
                            args => [
                            ],
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'apps',
                            args => [
                                array_ref { '[]',
                                },
                            ],
                        },
                    },
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => dereference { '@{',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'apps',
                                        args => [
                                        ],
                                    },
                                },
                            },
                            right => leaf '@_',
                        },
                    ],
                },
            ],
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
                branch { '=',
                    left => leaf '%codes',
                    right => function_call { 'map',
                        args => [
                            branch { '=>',
                                left => leaf '$_',
                                right => leaf '1',
                            },
                            dereference { '@{',
                                expr => branch { '||',
                                    left => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'catch',
                                            args => [
                                            ],
                                        },
                                    },
                                    right => array_ref { '[]',
                                        data => leaf '404',
                                    },
                                },
                            },
                        ],
                    },
                },
                branch { '->',
                    left => leaf '$self',
                    right => function_call { 'codes',
                        args => [
                            single_term_operator { '\\',
                                expr => leaf '%codes',
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
                Test::Compiler::Parser::return { 'return',
                    body => function { 'sub',
                        body => [
                            branch { '=',
                                left => leaf '$respond',
                                right => function_call { 'shift',
                                    args => [
                                    ],
                                },
                            },
                            leaf '$done',
                            branch { '=',
                                left => leaf '$respond_wrapper',
                                right => function { 'sub',
                                    body => [
                                        branch { '=',
                                            left => leaf '$res',
                                            right => function_call { 'shift',
                                                args => [
                                                ],
                                            },
                                        },
                                        if_stmt { 'if',
                                            expr => branch { '->',
                                                left => branch { '->',
                                                    left => leaf '$self',
                                                    right => function_call { 'codes',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                                right => hash_ref { '{}',
                                                    data => branch { '->',
                                                        left => leaf '$res',
                                                        right => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                },
                                            },
                                            true_stmt => Test::Compiler::Parser::return { 'return',
                                                body => function_call { 'Plack::Util::inline_object',
                                                    args => [
                                                        branch { ',',
                                                            left => branch { '=>',
                                                                left => leaf 'write',
                                                                right => function { 'sub',
                                                                    body => hash_ref { '{}',
                                                                    },
                                                                },
                                                            },
                                                            right => branch { '=>',
                                                                left => leaf 'close',
                                                                right => function { 'sub',
                                                                    body => hash_ref { '{}',
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    ],
                                                },
                                            },
                                            false_stmt => else_stmt { 'else',
                                                stmt => [
                                                    branch { '=',
                                                        left => leaf '$done',
                                                        right => leaf '1',
                                                    },
                                                    Test::Compiler::Parser::return { 'return',
                                                        body => branch { '->',
                                                            left => leaf '$respond',
                                                            right => list { '()',
                                                                data => leaf '$res',
                                                            },
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                    ],
                                },
                            },
                            branch { '=',
                                left => leaf '@try',
                                right => dereference { '@{',
                                    expr => branch { '||',
                                        left => branch { '->',
                                            left => leaf '$self',
                                            right => function_call { 'apps',
                                                args => [
                                                ],
                                            },
                                        },
                                        right => array_ref { '[]',
                                        },
                                    },
                                },
                            },
                            branch { '=',
                                left => leaf '$tries_left',
                                right => branch { '+',
                                    left => leaf '0',
                                    right => leaf '@try',
                                },
                            },
                            if_stmt { 'if',
                                expr => single_term_operator { 'not',
                                    expr => leaf '$tries_left',
                                },
                                true_stmt => Test::Compiler::Parser::return { 'return',
                                    body => branch { '->',
                                        left => leaf '$respond',
                                        right => list { '()',
                                            data => array_ref { '[]',
                                                data => branch { ',',
                                                    left => branch { ',',
                                                        left => leaf '404',
                                                        right => array_ref { '[]',
                                                            data => branch { '=>',
                                                                left => leaf 'Content-Type',
                                                                right => leaf 'text/html',
                                                            },
                                                        },
                                                    },
                                                    right => array_ref { '[]',
                                                        data => leaf '404 Not Found',
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                            foreach_stmt { 'for',
                                cond => leaf '@try',
                                true_stmt => [
                                    branch { '=',
                                        left => leaf '$res',
                                        right => branch { '->',
                                            left => leaf '$app',
                                            right => list { '()',
                                                data => leaf '$env',
                                            },
                                        },
                                    },
                                    if_stmt { 'if',
                                        expr => branch { '==',
                                            left => single_term_operator { '--',
                                                expr => leaf '$tries_left',
                                            },
                                            right => leaf '1',
                                        },
                                        true_stmt => branch { '=',
                                            left => leaf '$respond_wrapper',
                                            right => function { 'sub',
                                                body => branch { '->',
                                                    left => leaf '$respond',
                                                    right => list { '()',
                                                        data => function_call { 'shift',
                                                            args => [
                                                            ],
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                    if_stmt { 'if',
                                        expr => branch { 'eq',
                                            left => function_call { 'ref',
                                                args => [
                                                    leaf '$res',
                                                ],
                                            },
                                            right => leaf 'CODE',
                                        },
                                        true_stmt => branch { '->',
                                            left => leaf '$res',
                                            right => list { '()',
                                                data => leaf '$respond_wrapper',
                                            },
                                        },
                                        false_stmt => else_stmt { 'else',
                                            stmt => branch { '->',
                                                left => leaf '$respond_wrapper',
                                                right => list { '()',
                                                    data => leaf '$res',
                                                },
                                            },
                                        },
                                    },
                                    if_stmt { 'if',
                                        expr => leaf '$done',
                                        true_stmt => Test::Compiler::Parser::return { 'return',
                                        },
                                    },
                                ],
                                itr => leaf '$app',
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
package Plack::App::Cascade;
use strict;
use base qw(Plack::Component);

use Plack::Util;
use Plack::Util::Accessor qw(apps catch codes);

sub add {
    my $self = shift;
    $self->apps([]) unless $self->apps;
    push @{$self->apps}, @_;
}

sub prepare_app {
    my $self = shift;
    my %codes = map { $_ => 1 } @{ $self->catch || [ 404 ] };
    $self->codes(\%codes);
}

sub call {
    my($self, $env) = @_;

    return sub {
        my $respond = shift;

        my $done;
        my $respond_wrapper = sub {
            my $res = shift;
            if ($self->codes->{$res->[0]}) {
                # suppress output by giving the app an
                # output spool which drops everything on the floor
                return Plack::Util::inline_object
                    write => sub { }, close => sub { };
            } else {
                $done = 1;
                return $respond->($res);
            }
        };

        my @try = @{$self->apps || []};
        my $tries_left = 0 + @try;

        if (not $tries_left) {
            return $respond->([ 404, [ 'Content-Type' => 'text/html' ], [ '404 Not Found' ] ])
        }

        for my $app (@try) {
            my $res = $app->($env);
            if ($tries_left-- == 1) {
                $respond_wrapper = sub { $respond->(shift) };
            }

            if (ref $res eq 'CODE') {
                $res->($respond_wrapper);
            } else {
                $respond_wrapper->($res);
            }
            return if $done;
        }
    };
}

1;

__END__

=head1 NAME

Plack::App::Cascade - Cascadable compound application

=head1 SYNOPSIS

  use Plack::App::Cascade;
  use Plack::App::URLMap;
  use Plack::App::File;

  # Serve static files from multiple search paths
  my $cascade = Plack::App::Cascade->new;
  $cascade->add( Plack::App::File->new(root => "/www/example.com/foo")->to_app );
  $cascade->add( Plack::App::File->new(root => "/www/example.com/bar")->to_app );

  my $app = Plack::App::URLMap->new;
  $app->map("/static", $cascade);
  $app->to_app;

=head1 DESCRIPTION

Plack::App::Cascade is a Plack middleware component that compounds
several apps and tries them to return the first response that is not
404.

=head1 METHODS

=over 4

=item new

  $app = Plack::App::Cascade->new(apps => [ $app1, $app2 ]);

Creates a new Cascade application.

=item add

  $app->add($app1);
  $app->add($app2, $app3);

Appends a new application to the list of apps to try. You can pass the
multiple apps to the one C<add> call.

=item catch

  $app->catch([ 403, 404 ]);

Sets which error codes to catch and process onwards. Defaults to C<404>.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::App::URLMap> Rack::Cascade

=cut

