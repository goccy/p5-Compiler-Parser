use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Request.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Request',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { '5.008_001',
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
        module { 'HTTP::Headers',
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        module { 'Hash::MultiValue',
        },
        module { 'HTTP::Body',
        },
        module { 'Plack::Request::Upload',
        },
        module { 'Stream::Buffered',
        },
        module { 'URI',
        },
        module { 'URI::Escape',
            args => list { '()',
            },
        },
        function { 'new',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'unless',
                    expr => branch { '&&',
                        left => function_call { 'defined',
                            args => [
                                leaf '$env',
                            ],
                        },
                        right => branch { 'eq',
                            left => function_call { 'ref',
                                args => [
                                    leaf '$env',
                                ],
                            },
                            right => leaf 'HASH',
                        },
                    },
                    true_stmt => function_call { 'Carp::croak',
                        args => [
                            reg_prefix { 'q',
                                expr => leaf '$env is required',
                            },
                        ],
                    },
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => hash_ref { '{}',
                                data => branch { '=>',
                                    left => leaf 'env',
                                    right => leaf '$env',
                                },
                            },
                            right => leaf '$class',
                        },
                    ],
                },
            ],
        },
        function { 'env',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'env',
                },
            },
        },
        function { 'address',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'REMOTE_ADDR',
                },
            },
        },
        function { 'remote_host',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'REMOTE_HOST',
                },
            },
        },
        function { 'protocol',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'SERVER_PROTOCOL',
                },
            },
        },
        function { 'method',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'REQUEST_METHOD',
                },
            },
        },
        function { 'port',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'SERVER_PORT',
                },
            },
        },
        function { 'user',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'REMOTE_USER',
                },
            },
        },
        function { 'request_uri',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'REQUEST_URI',
                },
            },
        },
        function { 'path_info',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'PATH_INFO',
                },
            },
        },
        function { 'path',
            body => branch { '||',
                left => branch { '->',
                    left => branch { '->',
                        left => array { '$_',
                            idx => array_ref { '[]',
                                data => leaf '0',
                            },
                        },
                        right => function_call { 'env',
                            args => [
                            ],
                        },
                    },
                    right => hash_ref { '{}',
                        data => leaf 'PATH_INFO',
                    },
                },
                right => leaf '/',
            },
        },
        function { 'script_name',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'SCRIPT_NAME',
                },
            },
        },
        function { 'scheme',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'psgi.url_scheme',
                },
            },
        },
        function { 'secure',
            body => branch { 'eq',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'scheme',
                        args => [
                        ],
                    },
                },
                right => leaf 'https',
            },
        },
        function { 'body',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'psgi.input',
                },
            },
        },
        function { 'input',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'psgi.input',
                },
            },
        },
        function { 'content_length',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'CONTENT_LENGTH',
                },
            },
        },
        function { 'content_type',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'CONTENT_TYPE',
                },
            },
        },
        function { 'session',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'psgix.session',
                },
            },
        },
        function { 'session_options',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'psgix.session.options',
                },
            },
        },
        function { 'logger',
            body => branch { '->',
                left => branch { '->',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0',
                        },
                    },
                    right => function_call { 'env',
                        args => [
                        ],
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'psgix.logger',
                },
            },
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
                if_stmt { 'unless',
                    expr => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'HTTP_COOKIE',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => hash_ref { '{}',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '&&',
                        left => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'env',
                                    args => [
                                    ],
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf 'plack.cookie.parsed',
                            },
                        },
                        right => branch { 'eq',
                            left => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'plack.cookie.string',
                                },
                            },
                            right => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'HTTP_COOKIE',
                                },
                            },
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'env',
                                    args => [
                                    ],
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf 'plack.cookie.parsed',
                            },
                        },
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.cookie.string',
                        },
                    },
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'HTTP_COOKIE',
                        },
                    },
                },
                leaf '%results',
                branch { '=',
                    left => leaf '@pairs',
                    right => function_call { 'grep',
                        args => [
                            branch { ',',
                                left => reg_prefix { 'm',
                                    expr => leaf '=',
                                },
                                right => function_call { 'split',
                                    args => [
                                        branch { ',',
                                            left => leaf '[;,] ?',
                                            right => branch { '->',
                                                left => branch { '->',
                                                    left => leaf '$self',
                                                    right => function_call { 'env',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                                right => hash_ref { '{}',
                                                    data => leaf 'plack.cookie.string',
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        ],
                    },
                },
                foreach_stmt { 'for',
                    cond => leaf '@pairs',
                    true_stmt => [
                        branch { '=~',
                            left => leaf '$pair',
                            right => reg_replace { 's',
                                to => leaf '',
                                from => leaf '^\s+',
                            },
                        },
                        branch { '=~',
                            left => leaf '$pair',
                            right => reg_replace { 's',
                                to => leaf '',
                                from => leaf '\s+$',
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
                        if_stmt { 'unless',
                            expr => function_call { 'exists',
                                args => [
                                    hash { '$results',
                                        key => hash_ref { '{}',
                                            data => leaf '$key',
                                        },
                                    },
                                ],
                            },
                            true_stmt => branch { '=',
                                left => hash { '$results',
                                    key => hash_ref { '{}',
                                        data => leaf '$key',
                                    },
                                },
                                right => leaf '$value',
                            },
                        },
                    ],
                    itr => leaf '$pair',
                },
                branch { '=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.cookie.parsed',
                        },
                    },
                    right => single_term_operator { '\\',
                        expr => leaf '%results',
                    },
                },
            ],
        },
        function { 'query_parameters',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '||=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.query',
                        },
                    },
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { '_parse_query',
                            args => [
                            ],
                        },
                    },
                },
            ],
        },
        function { '_parse_query',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                leaf '@query',
                branch { '=',
                    left => leaf '$query_string',
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'QUERY_STRING',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$query_string',
                        ],
                    },
                    true_stmt => if_stmt { 'if',
                        expr => branch { '=~',
                            left => leaf '$query_string',
                            right => regexp { '=',
                            },
                        },
                        true_stmt => branch { '=',
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
                        false_stmt => else_stmt { 'else',
                            stmt => branch { '=',
                                left => leaf '@query',
                                right => function_call { 'map',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => function_call { 'URI::Escape::uri_unescape',
                                                    args => [
                                                        leaf '$_',
                                                    ],
                                                },
                                                right => leaf '',
                                            },
                                        },
                                        function_call { 'split',
                                            args => [
                                                list { '()',
                                                    data => branch { ',',
                                                        left => branch { ',',
                                                            left => regexp { '\+',
                                                            },
                                                            right => leaf '$query_string',
                                                        },
                                                        right => leaf '-1',
                                                    },
                                                },
                                            ],
                                        },
                                    ],
                                },
                            },
                        },
                    },
                },
                branch { '->',
                    left => leaf 'Hash::MultiValue',
                    right => function_call { 'new',
                        args => [
                            leaf '@query',
                        ],
                    },
                },
            ],
        },
        function { 'content',
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
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'psgix.input.buffered',
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { '_parse_request_body',
                            args => [
                            ],
                        },
                    },
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$fh',
                        right => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'input',
                                args => [
                                ],
                            },
                        },
                    },
                    right => Test::Compiler::Parser::return { 'return',
                        body => leaf '',
                    },
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$cl',
                        right => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'env',
                                    args => [
                                    ],
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf 'CONTENT_LENGTH',
                            },
                        },
                    },
                    right => Test::Compiler::Parser::return { 'return',
                        body => leaf '',
                    },
                },
                branch { '->',
                    left => leaf '$fh',
                    right => function_call { 'seek',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => leaf '0',
                                    right => leaf '0',
                                },
                            },
                        ],
                    },
                },
                branch { '->',
                    left => leaf '$fh',
                    right => function_call { 'read',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => leaf '$content',
                                        right => leaf '$cl',
                                    },
                                    right => leaf '0',
                                },
                            },
                        ],
                    },
                },
                branch { '->',
                    left => leaf '$fh',
                    right => function_call { 'seek',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => leaf '0',
                                    right => leaf '0',
                                },
                            },
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$content',
                },
            ],
        },
        function { 'raw_body',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => function_call { 'content',
                    args => [
                    ],
                },
            },
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
                    expr => single_term_operator { '!',
                        expr => function_call { 'defined',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'headers',
                                    },
                                },
                            ],
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$env',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'env',
                                    args => [
                                    ],
                                },
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
                    ],
                },
                branch { '->',
                    left => leaf '$self',
                    right => hash_ref { '{}',
                        data => leaf 'headers',
                    },
                },
            ],
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
        function { 'referer',
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
                right => function_call { 'referer',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'user_agent',
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
                right => function_call { 'user_agent',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'body_parameters',
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
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.body',
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { '_parse_request_body',
                            args => [
                            ],
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.body',
                        },
                    },
                },
            ],
        },
        function { 'parameters',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '||=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.merged',
                        },
                    },
                    right => do_stmt { 'do',
                        stmt => [
                            branch { '=',
                                left => leaf '$query',
                                right => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'query_parameters',
                                        args => [
                                        ],
                                    },
                                },
                            },
                            branch { '=',
                                left => leaf '$body',
                                right => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'body_parameters',
                                        args => [
                                        ],
                                    },
                                },
                            },
                            branch { '->',
                                left => leaf 'Hash::MultiValue',
                                right => function_call { 'new',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => branch { '->',
                                                    left => leaf '$query',
                                                    right => function_call { 'flatten',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                                right => branch { '->',
                                                    left => leaf '$body',
                                                    right => function_call { 'flatten',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        ],
                    },
                },
            ],
        },
        function { 'uploads',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.upload',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'env',
                                    args => [
                                    ],
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf 'plack.request.upload',
                            },
                        },
                    },
                },
                branch { '->',
                    left => leaf '$self',
                    right => function_call { '_parse_request_body',
                        args => [
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.upload',
                        },
                    },
                },
            ],
        },
        function { 'param',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '==',
                        left => leaf '@_',
                        right => leaf '0',
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => function_call { 'keys',
                            args => [
                                dereference { '%{',
                                    expr => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'parameters',
                                            args => [
                                            ],
                                        },
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '$key',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'wantarray',
                        args => [
                        ],
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'parameters',
                                    args => [
                                    ],
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf '$key',
                            },
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'parameters',
                                args => [
                                ],
                            },
                        },
                        right => function_call { 'get_all',
                            args => [
                                leaf '$key',
                            ],
                        },
                    },
                },
            ],
        },
        function { 'upload',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '==',
                        left => leaf '@_',
                        right => leaf '0',
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => function_call { 'keys',
                            args => [
                                dereference { '%{',
                                    expr => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'uploads',
                                            args => [
                                            ],
                                        },
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '$key',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'wantarray',
                        args => [
                        ],
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'uploads',
                                    args => [
                                    ],
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf '$key',
                            },
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'uploads',
                                args => [
                                ],
                            },
                        },
                        right => function_call { 'get_all',
                            args => [
                                leaf '$key',
                            ],
                        },
                    },
                },
            ],
        },
        function { 'uri',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$base',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { '_uri_base',
                            args => [
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '$path_escape_class',
                    right => reg_prefix { 'q',
                        expr => leaf '^/;:@&=A-Za-z0-9\$_.+!*\'(),-',
                    },
                },
                branch { '=',
                    left => leaf '$path',
                    right => function_call { 'URI::Escape::uri_escape',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => branch { '||',
                                        left => branch { '->',
                                            left => branch { '->',
                                                left => leaf '$self',
                                                right => function_call { 'env',
                                                    args => [
                                                    ],
                                                },
                                            },
                                            right => hash_ref { '{}',
                                                data => leaf 'PATH_INFO',
                                            },
                                        },
                                        right => leaf '',
                                    },
                                    right => leaf '$path_escape_class',
                                },
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { '&&',
                        left => function_call { 'defined',
                            args => [
                                branch { '->',
                                    left => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'env',
                                            args => [
                                            ],
                                        },
                                    },
                                    right => hash_ref { '{}',
                                        data => leaf 'QUERY_STRING',
                                    },
                                },
                            ],
                        },
                        right => branch { 'ne',
                            left => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'QUERY_STRING',
                                },
                            },
                            right => leaf '',
                        },
                    },
                    true_stmt => branch { '.=',
                        left => leaf '$path',
                        right => branch { '.',
                            left => leaf '?',
                            right => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'QUERY_STRING',
                                },
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '=~',
                        left => leaf '$path',
                        right => reg_prefix { 'm',
                            expr => leaf '^/',
                        },
                    },
                    true_stmt => branch { '=~',
                        left => leaf '$base',
                        right => reg_replace { 's',
                            to => leaf '',
                            from => leaf '/$',
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => branch { '->',
                            left => leaf 'URI',
                            right => function_call { 'new',
                                args => [
                                    branch { '.',
                                        left => leaf '$base',
                                        right => leaf '$path',
                                    },
                                ],
                            },
                        },
                        right => function_call { 'canonical',
                            args => [
                            ],
                        },
                    },
                },
            ],
        },
        function { 'base',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf 'URI',
                        right => function_call { 'new',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => function_call { '_uri_base',
                                        args => [
                                        ],
                                    },
                                },
                            ],
                        },
                    },
                    right => function_call { 'canonical',
                        args => [
                        ],
                    },
                },
            ],
        },
        function { '_uri_base',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$env',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'env',
                            args => [
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '$uri',
                    right => branch { '.',
                        left => branch { '.',
                            left => branch { '.',
                                left => branch { '||',
                                    left => branch { '->',
                                        left => leaf '$env',
                                        right => hash_ref { '{}',
                                            data => leaf 'psgi.url_scheme',
                                        },
                                    },
                                    right => leaf 'http',
                                },
                                right => leaf '://',
                            },
                            right => branch { '||',
                                left => branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf 'HTTP_HOST',
                                    },
                                },
                                right => branch { '.',
                                    left => branch { '.',
                                        left => branch { '||',
                                            left => branch { '->',
                                                left => leaf '$env',
                                                right => hash_ref { '{}',
                                                    data => leaf 'SERVER_NAME',
                                                },
                                            },
                                            right => leaf '',
                                        },
                                        right => leaf ':',
                                    },
                                    right => branch { '||',
                                        left => branch { '->',
                                            left => leaf '$env',
                                            right => hash_ref { '{}',
                                                data => leaf 'SERVER_PORT',
                                            },
                                        },
                                        right => leaf '80',
                                    },
                                },
                            },
                        },
                        right => branch { '||',
                            left => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'SCRIPT_NAME',
                                },
                            },
                            right => leaf '/',
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$uri',
                },
            ],
        },
        function { 'new_response',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                module { 'Plack::Response',
                },
                branch { '->',
                    left => leaf 'Plack::Response',
                    right => function_call { 'new',
                        args => [
                            leaf '@_',
                        ],
                    },
                },
            ],
        },
        function { '_parse_request_body',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$ct',
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'CONTENT_TYPE',
                        },
                    },
                },
                branch { '=',
                    left => leaf '$cl',
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'CONTENT_LENGTH',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '&&',
                        left => single_term_operator { '!',
                            expr => leaf '$ct',
                        },
                        right => single_term_operator { '!',
                            expr => leaf '$cl',
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'plack.request.body',
                                },
                            },
                            right => branch { '->',
                                left => leaf 'Hash::MultiValue',
                                right => function_call { 'new',
                                    args => [
                                    ],
                                },
                            },
                        },
                        branch { '=',
                            left => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'plack.request.upload',
                                },
                            },
                            right => branch { '->',
                                left => leaf 'Hash::MultiValue',
                                right => function_call { 'new',
                                    args => [
                                    ],
                                },
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                        },
                    ],
                },
                branch { '=',
                    left => leaf '$body',
                    right => branch { '->',
                        left => leaf 'HTTP::Body',
                        right => function_call { 'new',
                            args => [
                                list { '()',
                                    data => branch { ',',
                                        left => leaf '$ct',
                                        right => leaf '$cl',
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.http.body',
                        },
                    },
                    right => leaf '$body',
                },
                branch { '->',
                    left => leaf '$body',
                    right => function_call { 'cleanup',
                        args => [
                            leaf '1',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$input',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'input',
                            args => [
                            ],
                        },
                    },
                },
                leaf '$buffer',
                if_stmt { 'if',
                    expr => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'psgix.input.buffered',
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$input',
                        right => function_call { 'seek',
                            args => [
                                list { '()',
                                    data => branch { ',',
                                        left => leaf '0',
                                        right => leaf '0',
                                    },
                                },
                            ],
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => branch { '=',
                            left => leaf '$buffer',
                            right => branch { '->',
                                left => leaf 'Stream::Buffered',
                                right => function_call { 'new',
                                    args => [
                                        leaf '$cl',
                                    ],
                                },
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '$spin',
                    right => leaf '0',
                },
                while_stmt { 'while',
                    expr => leaf '$cl',
                    true_stmt => [
                        branch { '->',
                            left => leaf '$input',
                            right => function_call { 'read',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => leaf '$chunk',
                                            right => three_term_operator { '?',
                                                cond => branch { '<',
                                                    left => leaf '$cl',
                                                    right => leaf '8192',
                                                },
                                                true_expr => leaf '$cl',
                                                false_expr => leaf '8192',
                                            },
                                        },
                                    },
                                ],
                            },
                        },
                        branch { '=',
                            left => leaf '$read',
                            right => function_call { 'length',
                                args => [
                                    leaf '$chunk',
                                ],
                            },
                        },
                        branch { '-=',
                            left => leaf '$cl',
                            right => leaf '$read',
                        },
                        branch { '->',
                            left => leaf '$body',
                            right => function_call { 'add',
                                args => [
                                    leaf '$chunk',
                                ],
                            },
                        },
                        if_stmt { 'if',
                            expr => leaf '$buffer',
                            true_stmt => branch { '->',
                                left => leaf '$buffer',
                                right => function_call { 'print',
                                    args => [
                                        leaf '$chunk',
                                    ],
                                },
                            },
                        },
                        if_stmt { 'if',
                            expr => branch { '&&',
                                left => branch { '==',
                                    left => leaf '$read',
                                    right => leaf '0',
                                },
                                right => branch { '>',
                                    left => single_term_operator { '++',
                                        expr => leaf '$spin',
                                    },
                                    right => leaf '2000',
                                },
                            },
                            true_stmt => function_call { 'Carp::croak',
                                args => [
                                    leaf 'Bad Content-Length: maybe client disconnect? ($cl bytes remaining)',
                                ],
                            },
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => leaf '$buffer',
                    true_stmt => [
                        branch { '=',
                            left => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'psgix.input.buffered',
                                },
                            },
                            right => leaf '1',
                        },
                        branch { '=',
                            left => branch { '->',
                                left => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'env',
                                        args => [
                                        ],
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'psgi.input',
                                },
                            },
                            right => branch { '->',
                                left => leaf '$buffer',
                                right => function_call { 'rewind',
                                    args => [
                                    ],
                                },
                            },
                        },
                    ],
                    false_stmt => else_stmt { 'else',
                        stmt => branch { '->',
                            left => leaf '$input',
                            right => function_call { 'seek',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => leaf '0',
                                            right => leaf '0',
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.body',
                        },
                    },
                    right => branch { '->',
                        left => leaf 'Hash::MultiValue',
                        right => function_call { 'from_mixed',
                            args => [
                                branch { '->',
                                    left => leaf '$body',
                                    right => function_call { 'param',
                                        args => [
                                        ],
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '@uploads',
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf 'Hash::MultiValue',
                            right => function_call { 'from_mixed',
                                args => [
                                    branch { '->',
                                        left => leaf '$body',
                                        right => function_call { 'upload',
                                            args => [
                                            ],
                                        },
                                    },
                                ],
                            },
                        },
                        right => function_call { 'flatten',
                            args => [
                            ],
                        },
                    },
                },
                leaf '@obj',
                while_stmt { 'while',
                    expr => branch { '=',
                        left => list { '()',
                            data => branch { ',',
                                left => leaf '$k',
                                right => leaf '$v',
                            },
                        },
                        right => function_call { 'splice',
                            args => [
                                branch { ',',
                                    left => branch { ',',
                                        left => leaf '@uploads',
                                        right => leaf '0',
                                    },
                                    right => leaf '2',
                                },
                            ],
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => branch { ',',
                                    left => leaf '@obj',
                                    right => leaf '$k',
                                },
                                right => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { '_make_upload',
                                        args => [
                                            leaf '$v',
                                        ],
                                    },
                                },
                            },
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'env',
                                args => [
                                ],
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf 'plack.request.upload',
                        },
                    },
                    right => branch { '->',
                        left => leaf 'Hash::MultiValue',
                        right => function_call { 'new',
                            args => [
                                leaf '@obj',
                            ],
                        },
                    },
                },
                leaf '1',
            ],
        },
        function { '_make_upload',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$upload',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '%copy',
                    right => dereference { '%$upload',
                        expr => leaf '%$upload',
                    },
                },
                branch { '=',
                    left => hash { '$copy',
                        key => hash_ref { '{}',
                            data => leaf 'headers',
                        },
                    },
                    right => branch { '->',
                        left => leaf 'HTTP::Headers',
                        right => function_call { 'new',
                            args => [
                                dereference { '%{',
                                    expr => branch { '->',
                                        left => leaf '$upload',
                                        right => hash_ref { '{}',
                                            data => leaf 'headers',
                                        },
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '->',
                    left => leaf 'Plack::Request::Upload',
                    right => function_call { 'new',
                        args => [
                            leaf '%copy',
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
package Plack::Request;
use strict;
use warnings;
use 5.008_001;
our $VERSION = '1.0024';
$VERSION = eval $VERSION;

use HTTP::Headers;
use Carp ();
use Hash::MultiValue;
use HTTP::Body;

use Plack::Request::Upload;
use Stream::Buffered;
use URI;
use URI::Escape ();

sub new {
    my($class, $env) = @_;
    Carp::croak(q{$env is required})
        unless defined $env && ref($env) eq 'HASH';

    bless { env => $env }, $class;
}

sub env { $_[0]->{env} }

sub address     { $_[0]->env->{REMOTE_ADDR} }
sub remote_host { $_[0]->env->{REMOTE_HOST} }
sub protocol    { $_[0]->env->{SERVER_PROTOCOL} }
sub method      { $_[0]->env->{REQUEST_METHOD} }
sub port        { $_[0]->env->{SERVER_PORT} }
sub user        { $_[0]->env->{REMOTE_USER} }
sub request_uri { $_[0]->env->{REQUEST_URI} }
sub path_info   { $_[0]->env->{PATH_INFO} }
sub path        { $_[0]->env->{PATH_INFO} || '/' }
sub script_name { $_[0]->env->{SCRIPT_NAME} }
sub scheme      { $_[0]->env->{'psgi.url_scheme'} }
sub secure      { $_[0]->scheme eq 'https' }
sub body        { $_[0]->env->{'psgi.input'} }
sub input       { $_[0]->env->{'psgi.input'} }

sub content_length   { $_[0]->env->{CONTENT_LENGTH} }
sub content_type     { $_[0]->env->{CONTENT_TYPE} }

sub session         { $_[0]->env->{'psgix.session'} }
sub session_options { $_[0]->env->{'psgix.session.options'} }
sub logger          { $_[0]->env->{'psgix.logger'} }

sub cookies {
    my $self = shift;

    return {} unless $self->env->{HTTP_COOKIE};

    # HTTP_COOKIE hasn't changed: reuse the parsed cookie
    if (   $self->env->{'plack.cookie.parsed'}
        && $self->env->{'plack.cookie.string'} eq $self->env->{HTTP_COOKIE}) {
        return $self->env->{'plack.cookie.parsed'};
    }

    $self->env->{'plack.cookie.string'} = $self->env->{HTTP_COOKIE};

    my %results;
    my @pairs = grep m/=/, split "[;,] ?", $self->env->{'plack.cookie.string'};
    for my $pair ( @pairs ) {
        # trim leading trailing whitespace
        $pair =~ s/^\s+//; $pair =~ s/\s+$//;

        my ($key, $value) = map URI::Escape::uri_unescape($_), split( "=", $pair, 2 );

        # Take the first one like CGI.pm or rack do
        $results{$key} = $value unless exists $results{$key};
    }

    $self->env->{'plack.cookie.parsed'} = \%results;
}

sub query_parameters {
    my $self = shift;
    $self->env->{'plack.request.query'} ||= $self->_parse_query;
}

sub _parse_query {
    my $self = shift;

    my @query;
    my $query_string = $self->env->{QUERY_STRING};
    if (defined $query_string) {
        if ($query_string =~ /=/) {
            # Handle  ?foo=bar&bar=foo type of query
            @query =
                map { s/\+/ /g; URI::Escape::uri_unescape($_) }
                map { /=/ ? split(/=/, $_, 2) : ($_ => '')}
                split(/[&;]/, $query_string);
        } else {
            # Handle ...?dog+bones type of query
            @query =
                map { (URI::Escape::uri_unescape($_), '') }
                split(/\+/, $query_string, -1);
        }
    }

    Hash::MultiValue->new(@query);
}

sub content {
    my $self = shift;

    unless ($self->env->{'psgix.input.buffered'}) {
        $self->_parse_request_body;
    }

    my $fh = $self->input                 or return '';
    my $cl = $self->env->{CONTENT_LENGTH} or return '';

    $fh->seek(0, 0); # just in case middleware/apps read it without seeking back
    $fh->read(my($content), $cl, 0);
    $fh->seek(0, 0);

    return $content;
}

sub raw_body { $_[0]->content }

# XXX you can mutate headers with ->headers but it's not written through to the env

sub headers {
    my $self = shift;
    if (!defined $self->{headers}) {
        my $env = $self->env;
        $self->{headers} = HTTP::Headers->new(
            map {
                (my $field = $_) =~ s/^HTTPS?_//;
                ( $field => $env->{$_} );
            }
                grep { /^(?:HTTP|CONTENT)/i } keys %$env
            );
    }
    $self->{headers};
}

sub content_encoding { shift->headers->content_encoding(@_) }
sub header           { shift->headers->header(@_) }
sub referer          { shift->headers->referer(@_) }
sub user_agent       { shift->headers->user_agent(@_) }

sub body_parameters {
    my $self = shift;

    unless ($self->env->{'plack.request.body'}) {
        $self->_parse_request_body;
    }

    return $self->env->{'plack.request.body'};
}

# contains body + query
sub parameters {
    my $self = shift;

    $self->env->{'plack.request.merged'} ||= do {
        my $query = $self->query_parameters;
        my $body  = $self->body_parameters;
        Hash::MultiValue->new($query->flatten, $body->flatten);
    };
}

sub uploads {
    my $self = shift;

    if ($self->env->{'plack.request.upload'}) {
        return $self->env->{'plack.request.upload'};
    }

    $self->_parse_request_body;
    return $self->env->{'plack.request.upload'};
}

sub param {
    my $self = shift;

    return keys %{ $self->parameters } if @_ == 0;

    my $key = shift;
    return $self->parameters->{$key} unless wantarray;
    return $self->parameters->get_all($key);
}

sub upload {
    my $self = shift;

    return keys %{ $self->uploads } if @_ == 0;

    my $key = shift;
    return $self->uploads->{$key} unless wantarray;
    return $self->uploads->get_all($key);
}

sub uri {
    my $self = shift;

    my $base = $self->_uri_base;

    # We have to escape back PATH_INFO in case they include stuff like
    # ? or # so that the URI parser won't be tricked. However we should
    # preserve '/' since encoding them into %2f doesn't make sense.
    # This means when a request like /foo%2fbar comes in, we recognize
    # it as /foo/bar which is not ideal, but that's how the PSGI PATH_INFO
    # spec goes and we can't do anything about it. See PSGI::FAQ for details.

    # See RFC 3986 before modifying.
    my $path_escape_class = q{^/;:@&=A-Za-z0-9\$_.+!*'(),-};

    my $path = URI::Escape::uri_escape($self->env->{PATH_INFO} || '', $path_escape_class);
    $path .= '?' . $self->env->{QUERY_STRING}
        if defined $self->env->{QUERY_STRING} && $self->env->{QUERY_STRING} ne '';

    $base =~ s!/$!! if $path =~ m!^/!;

    return URI->new($base . $path)->canonical;
}

sub base {
    my $self = shift;
    URI->new($self->_uri_base)->canonical;
}

sub _uri_base {
    my $self = shift;

    my $env = $self->env;

    my $uri = ($env->{'psgi.url_scheme'} || "http") .
        "://" .
        ($env->{HTTP_HOST} || (($env->{SERVER_NAME} || "") . ":" . ($env->{SERVER_PORT} || 80))) .
        ($env->{SCRIPT_NAME} || '/');

    return $uri;
}

sub new_response {
    my $self = shift;
    require Plack::Response;
    Plack::Response->new(@_);
}

sub _parse_request_body {
    my $self = shift;

    my $ct = $self->env->{CONTENT_TYPE};
    my $cl = $self->env->{CONTENT_LENGTH};
    if (!$ct && !$cl) {
        # No Content-Type nor Content-Length -> GET/HEAD
        $self->env->{'plack.request.body'}   = Hash::MultiValue->new;
        $self->env->{'plack.request.upload'} = Hash::MultiValue->new;
        return;
    }

    my $body = HTTP::Body->new($ct, $cl);

    # HTTP::Body will create temporary files in case there was an
    # upload.  Those temporary files can be cleaned up by telling
    # HTTP::Body to do so. It will run the cleanup when the request
    # env is destroyed. That the object will not go out of scope by
    # the end of this sub we will store a reference here.
    $self->env->{'plack.request.http.body'} = $body;
    $body->cleanup(1);

    my $input = $self->input;

    my $buffer;
    if ($self->env->{'psgix.input.buffered'}) {
        # Just in case if input is read by middleware/apps beforehand
        $input->seek(0, 0);
    } else {
        $buffer = Stream::Buffered->new($cl);
    }

    my $spin = 0;
    while ($cl) {
        $input->read(my $chunk, $cl < 8192 ? $cl : 8192);
        my $read = length $chunk;
        $cl -= $read;
        $body->add($chunk);
        $buffer->print($chunk) if $buffer;

        if ($read == 0 && $spin++ > 2000) {
            Carp::croak "Bad Content-Length: maybe client disconnect? ($cl bytes remaining)";
        }
    }

    if ($buffer) {
        $self->env->{'psgix.input.buffered'} = 1;
        $self->env->{'psgi.input'} = $buffer->rewind;
    } else {
        $input->seek(0, 0);
    }

    $self->env->{'plack.request.body'}   = Hash::MultiValue->from_mixed($body->param);

    my @uploads = Hash::MultiValue->from_mixed($body->upload)->flatten;
    my @obj;
    while (my($k, $v) = splice @uploads, 0, 2) {
        push @obj, $k, $self->_make_upload($v);
    }

    $self->env->{'plack.request.upload'} = Hash::MultiValue->new(@obj);

    1;
}

sub _make_upload {
    my($self, $upload) = @_;
    my %copy = %$upload;
    $copy{headers} = HTTP::Headers->new(%{$upload->{headers}});
    Plack::Request::Upload->new(%copy);
}

1;
__END__

=head1 NAME

Plack::Request - Portable HTTP request object from PSGI env hash

=head1 SYNOPSIS

  use Plack::Request;

  my $app_or_middleware = sub {
      my $env = shift; # PSGI env

      my $req = Plack::Request->new($env);

      my $path_info = $req->path_info;
      my $query     = $req->param('query');

      my $res = $req->new_response(200); # new Plack::Response
      $res->finalize;
  };

=head1 DESCRIPTION

L<Plack::Request> provides a consistent API for request objects across
web server environments.

=head1 CAVEAT

Note that this module is intended to be used by Plack middleware
developers and web application framework developers rather than
application developers (end users).

Writing your web application directly using Plack::Request is
certainly possible but not recommended: it's like doing so with
mod_perl's Apache::Request: yet too low level.

If you're writing a web application, not a framework, then you're
encouraged to use one of the web application frameworks that support PSGI (L<http://plackperl.org/#frameworks>),
or see modules like L<HTTP::Engine> to provide higher level
Request and Response API on top of PSGI.

=head1 METHODS

Some of the methods defined in the earlier versions are deprecated in
version 0.99. Take a look at L</"INCOMPATIBILITIES">.

Unless otherwise noted, all methods and attributes are B<read-only>,
and passing values to the method like an accessor doesn't work like
you expect it to.

=head2 new

    Plack::Request->new( $env );

Creates a new request object.

=head1 ATTRIBUTES

=over 4

=item env

Returns the shared PSGI environment hash reference. This is a
reference, so writing to this environment passes through during the
whole PSGI request/response cycle.

=item address

Returns the IP address of the client (C<REMOTE_ADDR>).

=item remote_host

Returns the remote host (C<REMOTE_HOST>) of the client. It may be
empty, in which case you have to get the IP address using C<address>
method and resolve on your own.

=item method

Contains the request method (C<GET>, C<POST>, C<HEAD>, etc).

=item protocol

Returns the protocol (HTTP/1.0 or HTTP/1.1) used for the current request.

=item request_uri

Returns the raw, undecoded request URI path. You probably do B<NOT>
want to use this to dispatch requests.

=item path_info

Returns B<PATH_INFO> in the environment. Use this to get the local
path for the requests.

=item path

Similar to C<path_info> but returns C</> in case it is empty. In other
words, it returns the virtual path of the request URI after C<<
$req->base >>. See L</"DISPATCHING"> for details.

=item script_name

Returns B<SCRIPT_NAME> in the environment. This is the absolute path
where your application is hosted.

=item scheme

Returns the scheme (C<http> or C<https>) of the request.

=item secure

Returns true or false, indicating whether the connection is secure (https).

=item body, input

Returns C<psgi.input> handle.

=item session

Returns (optional) C<psgix.session> hash. When it exists, you can
retrieve and store per-session data from and to this hash.

=item session_options

Returns (optional) C<psgix.session.options> hash.

=item logger

Returns (optional) C<psgix.logger> code reference. When it exists,
your application is supposed to send the log message to this logger,
using:

  $req->logger->({ level => 'debug', message => "This is a debug message" });

=item cookies

Returns a reference to a hash containing the cookies. Values are
strings that are sent by clients and are URI decoded.

If there are multiple cookies with the same name in the request, this
method will ignore the duplicates and return only the first value. If
that causes issues for you, you may have to use modules like
CGI::Simple::Cookie to parse C<$request->header('Cookies')> by
yourself.

=item query_parameters

Returns a reference to a hash containing query string (GET)
parameters. This hash reference is L<Hash::MultiValue> object.

=item body_parameters

Returns a reference to a hash containing posted parameters in the
request body (POST). As with C<query_parameters>, the hash
reference is a L<Hash::MultiValue> object.

=item parameters

Returns a L<Hash::MultiValue> hash reference containing (merged) GET
and POST parameters.

=item content, raw_body

Returns the request content in an undecoded byte string for POST requests.

=item uri

Returns an URI object for the current request. The URI is constructed
using various environment values such as C<SCRIPT_NAME>, C<PATH_INFO>,
C<QUERY_STRING>, C<HTTP_HOST>, C<SERVER_NAME> and C<SERVER_PORT>.

Every time this method is called it returns a new, cloned URI object.

=item base

Returns an URI object for the base path of current request. This is
like C<uri> but only contains up to C<SCRIPT_NAME> where your
application is hosted at.

Every time this method is called it returns a new, cloned URI object.

=item user

Returns C<REMOTE_USER> if it's set.

=item headers

Returns an L<HTTP::Headers> object containing the headers for the current request.

=item uploads

Returns a reference to a hash containing uploads. The hash reference
is a L<Hash::MultiValue> object and values are L<Plack::Request::Upload>
objects.

=item content_encoding

Shortcut to $req->headers->content_encoding.

=item content_length

Shortcut to $req->headers->content_length.

=item content_type

Shortcut to $req->headers->content_type.

=item header

Shortcut to $req->headers->header.

=item referer

Shortcut to $req->headers->referer.

=item user_agent

Shortcut to $req->headers->user_agent.

=item param

Returns GET and POST parameters with a CGI.pm-compatible param
method. This is an alternative method for accessing parameters in
$req->parameters. Unlike CGI.pm, it does I<not> allow
setting or modifying query parameters.

    $value  = $req->param( 'foo' );
    @values = $req->param( 'foo' );
    @params = $req->param;

=item upload

A convenient method to access $req->uploads.

    $upload  = $req->upload('field');
    @uploads = $req->upload('field');
    @fields  = $req->upload;

    for my $upload ( $req->upload('field') ) {
        print $upload->filename;
    }

=item new_response

  my $res = $req->new_response;

Creates a new L<Plack::Response> object. Handy to remove dependency on
L<Plack::Response> in your code for easy subclassing and duck typing
in web application frameworks, as well as overriding Response
generation in middlewares.

=back

=head2 Hash::MultiValue parameters

Parameters that can take one or multiple values (i.e. C<parameters>,
C<query_parameters>, C<body_parameters> and C<uploads>) store the
hash reference as a L<Hash::MultiValue> object. This means you can use
the hash reference as a plain hash where values are B<always> scalars
(B<NOT> array references), so you don't need to code ugly and unsafe
C<< ref ... eq 'ARRAY' >> anymore.

And if you explicitly want to get multiple values of the same key, you
can call the C<get_all> method on it, such as:

  my @foo = $req->query_parameters->get_all('foo');

You can also call C<get_one> to always get one parameter independent
of the context (unlike C<param>), and even call C<mixed> (with
Hash::MultiValue 0.05 or later) to get the I<traditional> hash
reference,

  my $params = $req->parameters->mixed;

where values are either a scalar or an array reference depending on
input, so it might be useful if you already have the code to deal with
that ugliness.

=head2 PARSING POST BODY and MULTIPLE OBJECTS

The methods to parse request body (C<content>, C<body_parameters> and
C<uploads>) are carefully coded to save the parsed body in the
environment hash as well as in the temporary buffer, so you can call
them multiple times and create Plack::Request objects multiple times
in a request and they should work safely, and won't parse request body
more than twice for the efficiency.

=head1 DISPATCHING

If your application or framework wants to dispatch (or route) actions
based on request paths, be sure to use C<< $req->path_info >> not C<<
$req->uri->path >>.

This is because C<path_info> gives you the virtual path of the request,
regardless of how your application is mounted. If your application is
hosted with mod_perl or CGI scripts, or even multiplexed with tools
like L<Plack::App::URLMap>, request's C<path_info> always gives you
the action path.

Note that C<path_info> might give you an empty string, in which case
you should assume that the path is C</>.

You will also want to use C<< $req->base >> as a base prefix when
building URLs in your templates or in redirections. It's a good idea
for you to subclass Plack::Request and define methods such as:

  sub uri_for {
      my($self, $path, $args) = @_;
      my $uri = $self->base;
      $uri->path($uri->path . $path);
      $uri->query_form(@$args) if $args;
      $uri;
  }

So you can say:

  my $link = $req->uri_for('/logout', [ signoff => 1 ]);

and if C<< $req->base >> is C</app> you'll get the full URI for
C</app/logout?signoff=1>.

=head1 INCOMPATIBILITIES

In version 0.99, many utility methods are removed or deprecated, and
most methods are made read-only. These methods were deleted in version
1.0001.

All parameter-related methods such as C<parameters>,
C<body_parameters>, C<query_parameters> and C<uploads> now contains
L<Hash::MultiValue> objects, rather than I<scalar or an array
reference depending on the user input> which is insecure. See
L<Hash::MultiValue> for more about this change.

C<< $req->path >> method had a bug, where the code and the document
was mismatching. The document was suggesting it returns the sub
request path after C<< $req->base >> but the code was always returning
the absolute URI path. The code is now updated to be an alias of C<<
$req->path_info >> but returns C</> in case it's empty. If you need
the older behavior, just call C<< $req->uri->path >> instead.

Cookie handling is simplified, and doesn't use L<CGI::Simple::Cookie>
anymore, which means you B<CAN NOT> set array reference or hash
reference as a cookie value and expect it be serialized. You're always
required to set string value, and encoding or decoding them is totally
up to your application or framework. Also, C<cookies> hash reference
now returns I<strings> for the cookies rather than CGI::Simple::Cookie
objects, which means you no longer have to write a wacky code such as:

  $v = $req->cookie->{foo} ? $req->cookie->{foo}->value : undef;

and instead, simply do:

  $v = $req->cookie->{foo};

=head1 AUTHORS

Tatsuhiko Miyagawa

Kazuhiro Osawa

Tokuhiro Matsuno

=head1 SEE ALSO

L<Plack::Response> L<HTTP::Request>, L<Catalyst::Request>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

