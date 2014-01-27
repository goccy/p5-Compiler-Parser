use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse example/map.pl' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        branch { '=',
            left => leaf '$a',
            right => function_call { 'map',
                args => [
                    [
                        branch { '+',
                            left => leaf '$_',
                            right => leaf '2',
                        },
                        branch { '*',
                            left => leaf '1',
                            right => leaf '2',
                        },
                    ],
                    leaf '@b',
                ],
            },
        },
        branch { '=',
            left => list { '()',
                data => branch { ',',
                    left => leaf '$key',
                    right => leaf '$value',
                },
            },
            right => function_call { 'map',
                args => [
                    branch { ',',
                        left => function_call { 'URI::Escape::uri_unescape',
                            args => [
                                leaf '$_',
                            ],
                        },
                        right => function_call { 'split',
                            args => [
                                list { '()',
                                    data => branch { ',',
                                        left => branch { ',',
                                            left => leaf '=',
                                            right => leaf '$pair',
                                        },
                                        right => leaf '2',
                                    },
                                },
                            ],
                        },
                    },
                ],
            },
        },
        branch { '=',
            left => leaf '@query',
            right => function_call { 'map',
                args => [
                    [
                        reg_replace { 's',
                            to => leaf ' ',
                            from => leaf '\+',
                            option => leaf 'g',
                        },
                        function_call { 'URI::Escape::uri_unescape',
                            args => [
                                leaf '$_',
                            ],
                        },
                    ],
                    function_call { 'map',
                        args => [
                            three_term_operator { '?',
                                cond => regexp { '=',
                                },
                                true_expr => function_call { 'split',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => branch { ',',
                                                    left => regexp { '=',
                                                    },
                                                    right => leaf '$_',
                                                },
                                                right => leaf '2',
                                            },
                                        },
                                    ],
                                },
                                false_expr => list { '()',
                                    data => branch { '=>',
                                        left => leaf '$_',
                                        right => leaf '',
                                    },
                                },
                            },
                            function_call { 'split',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => regexp { '[&;]',
                                            },
                                            right => leaf '$query_string',
                                        },
                                    },
                                ],
                            },
                        ],
                    },
                ],
            },
        },
        branch { '=',
            left => branch { '->',
                left => leaf '$self',
                right => hash_ref { '{}',
                    data => leaf 'headers',
                },
            },
            right => branch { '->',
                left => leaf 'HTTP::Headers',
                right => function_call { 'new',
                    args => [
                        function_call { 'map',
                            args => [
                                [
                                    branch { '=~',
                                        left => branch { '=',
                                            left => leaf '$field',
                                            right => leaf '$_',
                                        },
                                        right => reg_replace { 's',
                                            to => leaf '',
                                            from => leaf '^HTTPS?_',
                                        },
                                    },
                                    list { '()',
                                        data => branch { '=>',
                                            left => leaf '$field',
                                            right => branch { '->',
                                                left => leaf '$env',
                                                right => hash_ref { '{}',
                                                    data => leaf '$_',
                                                },
                                            },
                                        },
                                    },
                                ],
                                function_call { 'grep',
                                    args => [
                                        regexp { '^(?:HTTP|CONTENT)',
                                            option => leaf 'i',
                                        },
                                        function_call { 'keys',
                                            args => [
                                                dereference { '%$env',
                                                    expr => leaf '%$env',
                                                },
                                            ],
                                        },
                                    ],
                                },
                            ],
                        },
                    ],
                },
            },
        },
    ]);
};

done_testing;

__DATA__
my $a = map { $_ + 2; 1 * 2; } @b;
my ($key, $value) = map URI::Escape::uri_unescape($_), split( "=", $pair, 2 );

@query = map {
    s/\+/ /g; URI::Escape::uri_unescape($_)
} map {
 /=/ ? split(/=/, $_, 2) : ($_ => '')
} split(/[&;]/, $query_string);

$self->{headers} = HTTP::Headers->new(
    map {
        (my $field = $_) =~ s/^HTTPS?_//;
        ( $field => $env->{$_} );
    } grep { /^(?:HTTP|CONTENT)/i } keys %$env
);


