use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Response.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Response',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        branch { '=',
            left => leaf '$VERSION',
            right => leaf '1.0024',
        },
        branch { '=',
            left => leaf '$VERSION',
            right => function_call { 'eval',
                args => [
                    leaf '$VERSION',
                ],
            },
        },
        module { 'Plack::Util::Accessor',
            args => reg_prefix { 'qw',
                expr => leaf 'body status',
            },
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        module { 'Scalar::Util',
            args => list { '()',
            },
        },
        module { 'HTTP::Headers',
        },
        module { 'URI::Escape',
            args => list { '()',
            },
        },
        function { 'code',
            body => branch { '->',
                left => function_call { 'shift',
                    args => [
                    ],
                },
                right => function_call { 'status',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'content',
            body => branch { '->',
                left => function_call { 'shift',
                    args => [
                    ],
                },
                right => function_call { 'body',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'new',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => leaf '$class',
                                    right => leaf '$rc',
                                },
                                right => leaf '$headers',
                            },
                            right => leaf '$content',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'bless',
                        args => [
                            branch { ',',
                                left => hash_ref { '{}',
                                },
                                right => leaf '$class',
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$rc',
                        ],
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'status',
                            args => [
                                leaf '$rc',
                            ],
                        },
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$headers',
                        ],
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'headers',
                            args => [
                                leaf '$headers',
                            ],
                        },
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$content',
                        ],
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'body',
                            args => [
                                leaf '$content',
                            ],
                        },
                    },
                },
                leaf '$self',
            ],
        },
        function { 'headers',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => leaf '@_',
                    true_stmt => [
                        branch { '=',
                            left => leaf '$headers',
                            right => function_call { 'shift',
                                args => [
                                ],
                            },
                        },
                        if_stmt { 'if',
                            expr => branch { 'eq',
                                left => function_call { 'ref',
                                    args => [
                                        leaf '$headers',
                                    ],
                                },
                                right => leaf 'ARRAY',
                            },
                            true_stmt => [
                                if_stmt { 'if',
                                    expr => branch { '!=',
                                        left => branch { '%',
                                            left => dereference { '@$headers',
                                                expr => leaf '@$headers',
                                            },
                                            right => leaf '2',
                                        },
                                        right => leaf '0',
                                    },
                                    true_stmt => function_call { 'Carp::carp',
                                        args => [
                                            leaf 'Odd number of headers',
                                        ],
                                    },
                                },
                                branch { '=',
                                    left => leaf '$headers',
                                    right => branch { '->',
                                        left => leaf 'HTTP::Headers',
                                        right => function_call { 'new',
                                            args => [
                                                dereference { '@$headers',
                                                    expr => leaf '@$headers',
                                                },
                                            ],
                                        },
                                    },
                                },
                            ],
                            false_stmt => if_stmt { 'elsif',
                                expr => branch { 'eq',
                                    left => function_call { 'ref',
                                        args => [
                                            leaf '$headers',
                                        ],
                                    },
                                    right => leaf 'HASH',
                                },
                                true_stmt => branch { '=',
                                    left => leaf '$headers',
                                    right => branch { '->',
                                        left => leaf 'HTTP::Headers',
                                        right => function_call { 'new',
                                            args => [
                                                dereference { '%$headers',
                                                    expr => leaf '%$headers',
                                                },
                                            ],
                                        },
                                    },
                                },
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => branch { '=',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'headers',
                                    },
                                },
                                right => leaf '$headers',
                            },
                        },
                    ],
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => branch { '||=',
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
                                            list { '()',
                                            },
                                        ],
                                    },
                                },
                            },
                        },
                    },
                },
            ],
        },
        function { 'cookies',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => leaf '@_',
                    true_stmt => branch { '=',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'cookies',
                            },
                        },
                        right => function_call { 'shift',
                            args => [
                            ],
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => branch { '||=',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'cookies',
                                    },
                                },
                                right => single_term_operator { '+',
                                    expr => hash_ref { '{}',
                                    },
                                },
                            },
                        },
                    },
                },
            ],
        },
        function { 'header',
            body => branch { '->',
                left => branch { '->',
                    left => function_call { 'shift',
                        args => [
                        ],
                    },
                    right => function_call { 'headers',
                        args => [
                        ],
                    },
                },
                right => function_call { 'header',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'content_length',
            body => branch { '->',
                left => branch { '->',
                    left => function_call { 'shift',
                        args => [
                        ],
                    },
                    right => function_call { 'headers',
                        args => [
                        ],
                    },
                },
                right => function_call { 'content_length',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'content_type',
            body => branch { '->',
                left => branch { '->',
                    left => function_call { 'shift',
                        args => [
                        ],
                    },
                    right => function_call { 'headers',
                        args => [
                        ],
                    },
                },
                right => function_call { 'content_type',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'content_encoding',
            body => branch { '->',
                left => branch { '->',
                    left => function_call { 'shift',
                        args => [
                        ],
                    },
                    right => function_call { 'headers',
                        args => [
                        ],
                    },
                },
                right => function_call { 'content_encoding',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'location',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'headers',
                                args => [
                                ],
                            },
                        },
                        right => function_call { 'header',
                            args => [
                                list { '()',
                                    data => branch { '=>',
                                        left => leaf 'Location',
                                        right => leaf '@_',
                                    },
                                },
                            ],
                        },
                    },
                },
            ],
        },
        function { 'redirect',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => leaf '@_',
                    true_stmt => [
                        branch { '=',
                            left => leaf '$url',
                            right => function_call { 'shift',
                                args => [
                                ],
                            },
                        },
                        branch { '=',
                            left => leaf '$status',
                            right => branch { '||',
                                left => function_call { 'shift',
                                    args => [
                                    ],
                                },
                                right => leaf '302',
                            },
                        },
                        branch { '->',
                            left => leaf '$self',
                            right => function_call { 'location',
                                args => [
                                    leaf '$url',
                                ],
                            },
                        },
                        branch { '->',
                            left => leaf '$self',
                            right => function_call { 'status',
                                args => [
                                    leaf '$status',
                                ],
                            },
                        },
                    ],
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'location',
                            args => [
                            ],
                        },
                    },
                },
            ],
        },
        function { 'finalize',
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
                        right => function_call { 'status',
                            args => [
                                list { '()',
                                },
                            ],
                        },
                    },
                    true_stmt => function_call { 'Carp::croak',
                        args => [
                            leaf 'missing status',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$headers',
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'headers',
                                args => [
                                ],
                            },
                        },
                        right => function_call { 'clone',
                            args => [
                            ],
                        },
                    },
                },
                branch { '->',
                    left => leaf '$self',
                    right => function_call { '_finalize_cookies',
                        args => [
                            leaf '$headers',
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => array_ref { '[]',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'status',
                                            args => [
                                            ],
                                        },
                                    },
                                    right => single_term_operator { '+',
                                        expr => array_ref { '[]',
                                            data => function_call { 'map',
                                                args => [
                                                    [
                                                        branch { '=',
                                                            left => leaf '$k',
                                                            right => leaf '$_',
                                                        },
                                                        function_call { 'map',
                                                            args => [
                                                                [
                                                                    branch { '=',
                                                                        left => leaf '$v',
                                                                        right => leaf '$_',
                                                                    },
                                                                    branch { '=~',
                                                                        left => leaf '$v',
                                                                        right => reg_replace { 's',
                                                                            to => leaf 'chr(32)',
                                                                            from => leaf '\015\012[\040|\011]+',
                                                                            option => leaf 'ge',
                                                                        },
                                                                    },
                                                                    branch { '=~',
                                                                        left => leaf '$v',
                                                                        right => reg_replace { 's',
                                                                            to => leaf '',
                                                                            from => leaf '\015|\012',
                                                                            option => leaf 'g',
                                                                        },
                                                                    },
                                                                    list { '()',
                                                                        data => branch { '=>',
                                                                            left => leaf '$k',
                                                                            right => leaf '$v',
                                                                        },
                                                                    },
                                                                ],
                                                                branch { '->',
                                                                    left => leaf '$headers',
                                                                    right => function_call { 'header',
                                                                        args => [
                                                                            leaf '$_',
                                                                        ],
                                                                    },
                                                                },
                                                            ],
                                                        },
                                                    ],
                                                    branch { '->',
                                                        left => leaf '$headers',
                                                        right => function_call { 'header_field_names',
                                                            args => [
                                                            ],
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                    },
                                },
                                right => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { '_body',
                                        args => [
                                        ],
                                    },
                                },
                            },
                        },
                    },
                },
            ],
        },
        function { '_body',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$body',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'body',
                            args => [
                            ],
                        },
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$body',
                        ],
                    },
                    true_stmt => branch { '=',
                        left => leaf '$body',
                        right => array_ref { '[]',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'or',
                        left => single_term_operator { '!',
                            expr => function_call { 'ref',
                                args => [
                                    leaf '$body',
                                ],
                            },
                        },
                        right => branch { '&&',
                            left => branch { '&&',
                                left => function_call { 'Scalar::Util::blessed',
                                    args => [
                                        leaf '$body',
                                    ],
                                },
                                right => function_call { 'overload::Method',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => leaf '$body',
                                                right => reg_prefix { 'q',
                                                    expr => leaf '""',
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                            right => single_term_operator { '!',
                                expr => branch { '->',
                                    left => leaf '$body',
                                    right => function_call { 'can',
                                        args => [
                                            leaf 'getline',
                                        ],
                                    },
                                },
                            },
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => array_ref { '[]',
                            data => leaf '$body',
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => leaf '$body',
                        },
                    },
                },
            ],
        },
        function { '_finalize_cookies',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$headers',
                        },
                    },
                    right => leaf '@_',
                },
                while_stmt { 'while',
                    expr => branch { '=',
                        left => list { '()',
                            data => branch { ',',
                                left => leaf '$name',
                                right => leaf '$val',
                            },
                        },
                        right => function_call { 'each',
                            args => [
                                dereference { '%{',
                                    expr => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'cookies',
                                            args => [
                                            ],
                                        },
                                    },
                                },
                            ],
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$cookie',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { '_bake_cookie',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => leaf '$name',
                                                right => leaf '$val',
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                        branch { '->',
                            left => leaf '$headers',
                            right => function_call { 'push_header',
                                args => [
                                    list { '()',
                                        data => branch { '=>',
                                            left => leaf 'Set-Cookie',
                                            right => leaf '$cookie',
                                        },
                                    },
                                ],
                            },
                        },
                    ],
                },
            ],
        },
        function { '_bake_cookie',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$self',
                                right => leaf '$name',
                            },
                            right => leaf '$val',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'unless',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$val',
                        ],
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => leaf '',
                    },
                },
                if_stmt { 'unless',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                leaf '$val',
                            ],
                        },
                        right => leaf 'HASH',
                    },
                    true_stmt => branch { '=',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => branch { '=>',
                                left => leaf 'value',
                                right => leaf '$val',
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '@cookie',
                    right => list { '()',
                        data => branch { '.',
                            left => branch { '.',
                                left => function_call { 'URI::Escape::uri_escape',
                                    args => [
                                        leaf '$name',
                                    ],
                                },
                                right => leaf '=',
                            },
                            right => function_call { 'URI::Escape::uri_escape',
                                args => [
                                    branch { '->',
                                        left => leaf '$val',
                                        right => hash_ref { '{}',
                                            data => leaf 'value',
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => leaf 'domain',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@cookie',
                                right => branch { '.',
                                    left => leaf 'domain=',
                                    right => branch { '->',
                                        left => leaf '$val',
                                        right => hash_ref { '{}',
                                            data => leaf 'domain',
                                        },
                                    },
                                },
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => leaf 'path',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@cookie',
                                right => branch { '.',
                                    left => leaf 'path=',
                                    right => branch { '->',
                                        left => leaf '$val',
                                        right => hash_ref { '{}',
                                            data => leaf 'path',
                                        },
                                    },
                                },
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => leaf 'expires',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@cookie',
                                right => branch { '.',
                                    left => leaf 'expires=',
                                    right => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { '_date',
                                            args => [
                                                branch { '->',
                                                    left => leaf '$val',
                                                    right => hash_ref { '{}',
                                                        data => leaf 'expires',
                                                    },
                                                },
                                            ],
                                        },
                                    },
                                },
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => leaf 'max-age',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@cookie',
                                right => branch { '.',
                                    left => leaf 'max-age=',
                                    right => branch { '->',
                                        left => leaf '$val',
                                        right => hash_ref { '{}',
                                            data => leaf 'max-age',
                                        },
                                    },
                                },
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => leaf 'secure',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@cookie',
                                right => leaf 'secure',
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$val',
                        right => hash_ref { '{}',
                            data => leaf 'httponly',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@cookie',
                                right => leaf 'HttpOnly',
                            },
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => function_call { 'join',
                        args => [
                            branch { ',',
                                left => leaf '; ',
                                right => leaf '@cookie',
                            },
                        ],
                    },
                },
            ],
        },
        branch { '=',
            left => leaf '@MON',
            right => reg_prefix { 'qw',
                expr => leaf ' Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ',
            },
        },
        branch { '=',
            left => leaf '@WDAY',
            right => reg_prefix { 'qw',
                expr => leaf ' Sun Mon Tue Wed Thu Fri Sat ',
            },
        },
        function { '_date',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$expires',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => branch { '=~',
                        left => leaf '$expires',
                        right => regexp { '^\d+$',
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => list { '()',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => leaf '$sec',
                                                        right => leaf '$min',
                                                    },
                                                    right => leaf '$hour',
                                                },
                                                right => leaf '$mday',
                                            },
                                            right => leaf '$mon',
                                        },
                                        right => leaf '$year',
                                    },
                                    right => leaf '$wday',
                                },
                            },
                            right => function_call { 'gmtime',
                                args => [
                                    leaf '$expires',
                                ],
                            },
                        },
                        branch { '+=',
                            left => leaf '$year',
                            right => leaf '1900',
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => function_call { 'sprintf',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => branch { ',',
                                                            left => branch { ',',
                                                                left => branch { ',',
                                                                    left => leaf '%s, %02d-%s-%04d %02d:%02d:%02d GMT',
                                                                    right => array { '$WDAY',
                                                                        idx => array_ref { '[]',
                                                                            data => leaf '$wday',
                                                                        },
                                                                    },
                                                                },
                                                                right => leaf '$mday',
                                                            },
                                                            right => array { '$MON',
                                                                idx => array_ref { '[]',
                                                                    data => leaf '$mon',
                                                                },
                                                            },
                                                        },
                                                        right => leaf '$year',
                                                    },
                                                    right => leaf '$hour',
                                                },
                                                right => leaf '$min',
                                            },
                                            right => leaf '$sec',
                                        },
                                    },
                                ],
                            },
                        },
                    ],
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$expires',
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Response;
use strict;
use warnings;
our $VERSION = '1.0024';
$VERSION = eval $VERSION;

use Plack::Util::Accessor qw(body status);
use Carp ();
use Scalar::Util ();
use HTTP::Headers;
use URI::Escape ();

sub code    { shift->status(@_) }
sub content { shift->body(@_)   }

sub new {
    my($class, $rc, $headers, $content) = @_;

    my $self = bless {}, $class;
    $self->status($rc)       if defined $rc;
    $self->headers($headers) if defined $headers;
    $self->body($content)    if defined $content;

    $self;
}

sub headers {
    my $self = shift;

    if (@_) {
        my $headers = shift;
        if (ref $headers eq 'ARRAY') {
            Carp::carp("Odd number of headers") if @$headers % 2 != 0;
            $headers = HTTP::Headers->new(@$headers);
        } elsif (ref $headers eq 'HASH') {
            $headers = HTTP::Headers->new(%$headers);
        }
        return $self->{headers} = $headers;
    } else {
        return $self->{headers} ||= HTTP::Headers->new();
    }
}

sub cookies {
    my $self = shift;
    if (@_) {
        $self->{cookies} = shift;
    } else {
        return $self->{cookies} ||= +{ };
    }
}

sub header { shift->headers->header(@_) } # shortcut

sub content_length {
    shift->headers->content_length(@_);
}

sub content_type {
    shift->headers->content_type(@_);
}

sub content_encoding {
    shift->headers->content_encoding(@_);
}

sub location {
    my $self = shift;
    return $self->headers->header('Location' => @_);
}

sub redirect {
    my $self = shift;

    if (@_) {
        my $url = shift;
        my $status = shift || 302;
        $self->location($url);
        $self->status($status);
    }

    return $self->location;
}

sub finalize {
    my $self = shift;
    Carp::croak "missing status" unless $self->status();

    my $headers = $self->headers->clone;
    $self->_finalize_cookies($headers);

    return [
        $self->status,
        +[
            map {
                my $k = $_;
                map {
                    my $v = $_;
                    $v =~ s/\015\012[\040|\011]+/chr(32)/ge; # replace LWS with a single SP
                    $v =~ s/\015|\012//g; # remove CR and LF since the char is invalid here

                    ( $k => $v )
                } $headers->header($_);

            } $headers->header_field_names
        ],
        $self->_body,
    ];
}

sub _body {
    my $self = shift;
    my $body = $self->body;
       $body = [] unless defined $body;
    if (!ref $body or Scalar::Util::blessed($body) && overload::Method($body, q("")) && !$body->can('getline')) {
        return [ $body ];
    } else {
        return $body;
    }
}

sub _finalize_cookies {
    my($self, $headers) = @_;

    while (my($name, $val) = each %{$self->cookies}) {
        my $cookie = $self->_bake_cookie($name, $val);
        $headers->push_header('Set-Cookie' => $cookie);
    }
}

sub _bake_cookie {
    my($self, $name, $val) = @_;

    return '' unless defined $val;
    $val = { value => $val } unless ref $val eq 'HASH';

    my @cookie = ( URI::Escape::uri_escape($name) . "=" . URI::Escape::uri_escape($val->{value}) );
    push @cookie, "domain=" . $val->{domain}   if $val->{domain};
    push @cookie, "path=" . $val->{path}       if $val->{path};
    push @cookie, "expires=" . $self->_date($val->{expires}) if $val->{expires};
    push @cookie, "max-age=" . $val->{"max-age"} if $val->{"max-age"};
    push @cookie, "secure"                     if $val->{secure};
    push @cookie, "HttpOnly"                   if $val->{httponly};

    return join "; ", @cookie;
}

my @MON  = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @WDAY = qw( Sun Mon Tue Wed Thu Fri Sat );

sub _date {
    my($self, $expires) = @_;

    if ($expires =~ /^\d+$/) {
        # all numbers -> epoch date
        # (cookies use '-' as date separator, HTTP uses ' ')
        my($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($expires);
        $year += 1900;

        return sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
                       $WDAY[$wday], $mday, $MON[$mon], $year, $hour, $min, $sec);

    }

    return $expires;
}

1;
__END__

=head1 NAME

Plack::Response - Portable HTTP Response object for PSGI response

=head1 SYNOPSIS

  use Plack::Response;

  sub psgi_handler {
      my $env = shift;

      my $res = Plack::Response->new(200);
      $res->content_type('text/html');
      $res->body("Hello World");

      return $res->finalize;
  }

=head1 DESCRIPTION

Plack::Response allows you a way to create PSGI response array ref through a simple API.

=head1 METHODS

=over 4

=item new

  $res = Plack::Response->new;
  $res = Plack::Response->new($status);
  $res = Plack::Response->new($status, $headers);
  $res = Plack::Response->new($status, $headers, $body);

Creates a new Plack::Response object.

=item status

  $res->status(200);
  $status = $res->status;

Sets and gets HTTP status code. C<code> is an alias.

=item headers

  $headers = $res->headers;
  $res->headers([ 'Content-Type' => 'text/html' ]);
  $res->headers({ 'Content-Type' => 'text/html' });
  $res->headers( HTTP::Headers->new );

Sets and gets HTTP headers of the response. Setter can take either an
array ref, a hash ref or L<HTTP::Headers> object containing a list of
headers.

=item body

  $res->body($body_str);
  $res->body([ "Hello", "World" ]);
  $res->body($io);

Gets and sets HTTP response body. Setter can take either a string, an
array ref, or an IO::Handle-like object. C<content> is an alias.

Note that this method doesn't automatically set I<Content-Length> for
the response. You have to set it manually if you want, with the
C<content_length> method (see below).

=item header

  $res->header('X-Foo' => 'bar');
  my $val = $res->header('X-Foo');

Shortcut for C<< $res->headers->header >>.

=item content_type, content_length, content_encoding

  $res->content_type('text/plain');
  $res->content_length(123);
  $res->content_encoding('gzip');

Shortcut for the equivalent get/set methods in C<< $res->headers >>.

=item redirect

  $res->redirect($url);
  $res->redirect($url, 301);

Sets redirect URL with an optional status code, which defaults to 302.

Note that this method doesn't normalize the given URI string. Users of
this module have to be responsible about properly encoding URI paths
and parameters.

=item location

Gets and sets C<Location> header.

Note that this method doesn't normalize the given URI string in the
setter. See above in C<redirect> for details.

=item cookies

  $res->cookies->{foo} = 123;
  $res->cookies->{foo} = { value => '123' };

Returns a hash reference containing cookies to be set in the
response. The keys of the hash are the cookies' names, and their
corresponding values are a plain string (for C<value> with everything
else defaults) or a hash reference that can contain keys such as
C<value>, C<domain>, C<expires>, C<path>, C<httponly>, C<secure>,
C<max-age>.

C<expires> can take a string or an integer (as an epoch time) and
B<does not> convert string formats such as C<+3M>.

  $res->cookies->{foo} = {
      value => 'test',
      path  => "/",
      domain => '.example.com',
      expires => time + 24 * 60 * 60,
  };

=item finalize

  $res->finalize;

Returns the status code, headers, and body of this response as a PSGI
response array reference.

=back

=head1 AUTHOR

Tokuhiro Matsuno

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::Request>

=cut

