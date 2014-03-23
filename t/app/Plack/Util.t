use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Util.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Util',
        },
        module { 'strict',
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        module { 'Scalar::Util',
        },
        module { 'IO::Handle',
        },
        module { 'overload',
            args => list { '()',
            },
        },
        module { 'File::Spec',
            args => list { '()',
            },
        },
        function { 'TRUE',
            body => branch { '==',
                left => leaf '1',
                right => leaf '1',
            },
            prototype => leaf '',
        },
        function { 'FALSE',
            body => single_term_operator { '!',
                expr => function_call { 'TRUE',
                    args => [
                    ],
                },
            },
            prototype => leaf '',
        },
        function { 'load_class',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '$prefix',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => leaf '$prefix',
                    true_stmt => if_stmt { 'unless',
                        expr => branch { '||',
                            left => branch { '=~',
                                left => leaf '$class',
                                right => reg_replace { 's',
                                    to => leaf '',
                                    from => leaf '^\+',
                                },
                            },
                            right => branch { '=~',
                                left => leaf '$class',
                                right => regexp { '^$prefix',
                                },
                            },
                        },
                        true_stmt => branch { '=',
                            left => leaf '$class',
                            right => leaf '$prefix\::$class',
                        },
                    },
                },
                branch { '=',
                    left => leaf '$file',
                    right => leaf '$class',
                },
                branch { '=~',
                    left => leaf '$file',
                    right => reg_replace { 's',
                        to => leaf '/',
                        from => leaf '::',
                        option => leaf 'g',
                    },
                },
                module { '$file.pm',
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$class',
                },
            ],
        },
        function { 'is_real_fh',
            body => [
                branch { '=',
                    left => leaf '$fh',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                block { '',
                    body => [
                        function_call { 'no',
                            args => [
                                leaf 'warnings',
                                leaf 'uninitialized',
                            ],
                        },
                        if_stmt { 'if',
                            expr => branch { 'or',
                                left => branch { 'or',
                                    left => handle { '-p',
                                        expr => leaf '$fh',
                                    },
                                    right => handle { '-c',
                                        expr => leaf '_',
                                    },
                                },
                                right => handle { '-b',
                                    expr => leaf '_',
                                },
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
                                body => function_call { 'FALSE',
                                    args => [
                                    ],
                                },
                            },
                        },
                    ],
                },
                branch { 'or',
                    left => branch { '=',
                        left => leaf '$reftype',
                        right => function_call { 'Scalar::Util::reftype',
                            args => [
                                leaf '$fh',
                            ],
                        },
                    },
                    right => Test::Compiler::Parser::return { 'return',
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'or',
                        left => branch { 'eq',
                            left => leaf '$reftype',
                            right => leaf 'IO',
                        },
                        right => branch { '&&',
                            left => branch { 'eq',
                                left => leaf '$reftype',
                                right => leaf 'GLOB',
                            },
                            right => branch { '->',
                                left => single_term_operator { '*',
                                    expr => hash_ref { '{}',
                                        data => leaf '$fh',
                                    },
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'IO',
                                },
                            },
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$m_fileno',
                            right => branch { '->',
                                left => leaf '$fh',
                                right => function_call { 'fileno',
                                    args => [
                                    ],
                                },
                            },
                        },
                        if_stmt { 'unless',
                            expr => function_call { 'defined',
                                args => [
                                    leaf '$m_fileno',
                                ],
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
                                body => function_call { 'FALSE',
                                    args => [
                                    ],
                                },
                            },
                        },
                        if_stmt { 'unless',
                            expr => branch { '>=',
                                left => leaf '$m_fileno',
                                right => leaf '0',
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
                                body => function_call { 'FALSE',
                                    args => [
                                    ],
                                },
                            },
                        },
                        branch { '=',
                            left => leaf '$f_fileno',
                            right => function_call { 'fileno',
                                args => [
                                    leaf '$fh',
                                ],
                            },
                        },
                        if_stmt { 'unless',
                            expr => function_call { 'defined',
                                args => [
                                    leaf '$f_fileno',
                                ],
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
                                body => function_call { 'FALSE',
                                    args => [
                                    ],
                                },
                            },
                        },
                        if_stmt { 'unless',
                            expr => branch { '>=',
                                left => leaf '$f_fileno',
                                right => leaf '0',
                            },
                            true_stmt => Test::Compiler::Parser::return { 'return',
                                body => function_call { 'FALSE',
                                    args => [
                                    ],
                                },
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => function_call { 'TRUE',
                                args => [
                                ],
                            },
                        },
                    ],
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => function_call { 'FALSE',
                                args => [
                                ],
                            },
                        },
                    },
                },
            ],
            prototype => leaf '$',
        },
        function { 'set_io_path',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$fh',
                            right => leaf '$path',
                        },
                    },
                    right => leaf '@_',
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => leaf '$fh',
                            right => leaf 'Plack::Util::IOWithPath',
                        },
                    ],
                },
                branch { '->',
                    left => leaf '$fh',
                    right => function_call { 'path',
                        args => [
                            leaf '$path',
                        ],
                    },
                },
            ],
        },
        function { 'content_length',
            body => [
                branch { '=',
                    left => leaf '$body',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$body',
                        ],
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                leaf '$body',
                            ],
                        },
                        right => leaf 'ARRAY',
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$cl',
                            right => leaf '0',
                        },
                        foreach_stmt { 'for',
                            cond => dereference { '@$body',
                                expr => leaf '@$body',
                            },
                            true_stmt => branch { '+=',
                                left => leaf '$cl',
                                right => function_call { 'length',
                                    args => [
                                        leaf '$chunk',
                                    ],
                                },
                            },
                            itr => leaf '$chunk',
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => leaf '$cl',
                        },
                    ],
                    false_stmt => if_stmt { 'elsif',
                        expr => function_call { 'is_real_fh',
                            args => [
                                leaf '$body',
                            ],
                        },
                        true_stmt => Test::Compiler::Parser::return { 'return',
                            body => branch { '-',
                                left => handle { '-s',
                                    expr => leaf '$body',
                                },
                                right => function_call { 'tell',
                                    args => [
                                        leaf '$body',
                                    ],
                                },
                            },
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                },
            ],
        },
        function { 'foreach',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$body',
                            right => leaf '$cb',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                leaf '$body',
                            ],
                        },
                        right => leaf 'ARRAY',
                    },
                    true_stmt => foreach_stmt { 'for',
                        cond => dereference { '@$body',
                            expr => leaf '@$body',
                        },
                        true_stmt => if_stmt { 'if',
                            expr => function_call { 'length',
                                args => [
                                    leaf '$line',
                                ],
                            },
                            true_stmt => branch { '->',
                                left => leaf '$cb',
                                right => list { '()',
                                    data => leaf '$line',
                                },
                            },
                        },
                        itr => leaf '$line',
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => [
                            if_stmt { 'unless',
                                expr => function_call { 'ref',
                                    args => [
                                        leaf '$/',
                                    ],
                                },
                                true_stmt => branch { '=',
                                    left => leaf '$/',
                                    right => single_term_operator { '\\',
                                        expr => leaf '65536',
                                    },
                                },
                            },
                            while_stmt { 'while',
                                expr => function_call { 'defined',
                                    args => [
                                        branch { '=',
                                            left => leaf '$line',
                                            right => branch { '->',
                                                left => leaf '$body',
                                                right => function_call { 'getline',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        },
                                    ],
                                },
                                true_stmt => if_stmt { 'if',
                                    expr => function_call { 'length',
                                        args => [
                                            leaf '$line',
                                        ],
                                    },
                                    true_stmt => branch { '->',
                                        left => leaf '$cb',
                                        right => list { '()',
                                            data => leaf '$line',
                                        },
                                    },
                                },
                            },
                            branch { '->',
                                left => leaf '$body',
                                right => function_call { 'close',
                                    args => [
                                    ],
                                },
                            },
                        ],
                    },
                },
            ],
        },
        function { 'class_to_file',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=~',
                    left => leaf '$class',
                    right => reg_replace { 's',
                        to => leaf '/',
                        from => leaf '::',
                        option => leaf 'g',
                    },
                },
                branch { '.',
                    left => leaf '$class',
                    right => leaf '.pm',
                },
            ],
        },
        function { '_load_sandbox',
            body => [
                branch { '=',
                    left => leaf '$_file',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$_package',
                    right => leaf '$_file',
                },
                branch { '=~',
                    left => leaf '$_package',
                    right => reg_replace { 's',
                        to => leaf 'sprintf("_%2x", unpack("C", $1))',
                        from => leaf '([^A-Za-z0-9_])',
                        option => leaf 'eg',
                    },
                },
                branch { '=',
                    left => leaf '$0',
                    right => leaf '$_file',
                },
                branch { '=',
                    left => leaf '@ARGV',
                    right => list { '()',
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => function_call { 'eval',
                        args => [
                            function_call { 'sprintf',
                                args => [
                                    branch { ',',
                                        left => leaf 'package Plack::Sandbox::%s;
{
    my $app = do $_file;
    if ( !$app && ( my $error = $@ || $! )) { die $error; }
    $app;
}
',
                                        right => leaf '$_package',
                                    },
                                ],
                            },
                        ],
                    },
                },
            ],
        },
        function { 'load_psgi',
            body => [
                branch { '=',
                    left => leaf '$stuff',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => hash { '$ENV',
                        key => hash_ref { '{}',
                            data => leaf 'PLACK_ENV',
                        },
                    },
                    right => branch { '||',
                        left => hash { '$ENV',
                            key => hash_ref { '{}',
                                data => leaf 'PLACK_ENV',
                            },
                        },
                        right => leaf 'development',
                    },
                },
                branch { '=',
                    left => leaf '$file',
                    right => three_term_operator { '?',
                        cond => branch { '=~',
                            left => leaf '$stuff',
                            right => regexp { '^[a-zA-Z0-9\_\:]+$',
                            },
                        },
                        true_expr => function_call { 'class_to_file',
                            args => [
                                leaf '$stuff',
                            ],
                        },
                        false_expr => branch { '->',
                            left => leaf 'File::Spec',
                            right => function_call { 'rel2abs',
                                args => [
                                    leaf '$stuff',
                                ],
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '$app',
                    right => function_call { '_load_sandbox',
                        args => [
                            leaf '$file',
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => leaf '$@',
                    true_stmt => function_call { 'die',
                        args => [
                            leaf 'Error while loading $file: $@',
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$app',
                },
            ],
        },
        function { 'run_app',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$app',
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                Test::Compiler::Parser::return { 'return',
                    body => function_call { 'eval',
                        args => [
                            branch { '||',
                                left => hash_ref { '{}',
                                    data => branch { '->',
                                        left => leaf '$app',
                                        right => list { '()',
                                            data => leaf '$env',
                                        },
                                    },
                                },
                                right => do_stmt { 'do',
                                    stmt => [
                                        branch { '=',
                                            left => leaf '$body',
                                            right => leaf 'Internal Server Error',
                                        },
                                        branch { '->',
                                            left => branch { '->',
                                                left => leaf '$env',
                                                right => hash_ref { '{}',
                                                    data => leaf 'psgi.errors',
                                                },
                                            },
                                            right => function_call { 'print',
                                                args => [
                                                    leaf '$@',
                                                ],
                                            },
                                        },
                                        array_ref { '[]',
                                            data => branch { ',',
                                                left => branch { ',',
                                                    left => leaf '500',
                                                    right => array_ref { '[]',
                                                        data => branch { ',',
                                                            left => branch { '=>',
                                                                left => leaf 'Content-Type',
                                                                right => leaf 'text/plain',
                                                            },
                                                            right => branch { '=>',
                                                                left => leaf 'Content-Length',
                                                                right => function_call { 'length',
                                                                    args => [
                                                                        leaf '$body',
                                                                    ],
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                                right => array_ref { '[]',
                                                    data => leaf '$body',
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
            prototype => leaf '$$',
        },
        function { 'headers',
            body => [
                branch { '=',
                    left => leaf '$headers',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                function_call { 'inline_object',
                    args => [
                        list { '()',
                            data => branch { ',',
                                left => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => branch { '=>',
                                                            left => leaf 'iter',
                                                            right => function { 'sub',
                                                                body => function_call { 'header_iter',
                                                                    args => [
                                                                        list { '()',
                                                                            data => branch { ',',
                                                                                left => leaf '$headers',
                                                                                right => leaf '@_',
                                                                            },
                                                                        },
                                                                    ],
                                                                },
                                                            },
                                                        },
                                                        right => branch { '=>',
                                                            left => leaf 'get',
                                                            right => function { 'sub',
                                                                body => function_call { 'header_get',
                                                                    args => [
                                                                        list { '()',
                                                                            data => branch { ',',
                                                                                left => leaf '$headers',
                                                                                right => leaf '@_',
                                                                            },
                                                                        },
                                                                    ],
                                                                },
                                                            },
                                                        },
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'set',
                                                        right => function { 'sub',
                                                            body => function_call { 'header_set',
                                                                args => [
                                                                    list { '()',
                                                                        data => branch { ',',
                                                                            left => leaf '$headers',
                                                                            right => leaf '@_',
                                                                        },
                                                                    },
                                                                ],
                                                            },
                                                        },
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'push',
                                                    right => function { 'sub',
                                                        body => function_call { 'header_push',
                                                            args => [
                                                                list { '()',
                                                                    data => branch { ',',
                                                                        left => leaf '$headers',
                                                                        right => leaf '@_',
                                                                    },
                                                                },
                                                            ],
                                                        },
                                                    },
                                                },
                                            },
                                            right => branch { '=>',
                                                left => leaf 'exists',
                                                right => function { 'sub',
                                                    body => function_call { 'header_exists',
                                                        args => [
                                                            list { '()',
                                                                data => branch { ',',
                                                                    left => leaf '$headers',
                                                                    right => leaf '@_',
                                                                },
                                                            },
                                                        ],
                                                    },
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'remove',
                                            right => function { 'sub',
                                                body => function_call { 'header_remove',
                                                    args => [
                                                        list { '()',
                                                            data => branch { ',',
                                                                left => leaf '$headers',
                                                                right => leaf '@_',
                                                            },
                                                        },
                                                    ],
                                                },
                                            },
                                        },
                                    },
                                    right => branch { '=>',
                                        left => leaf 'headers',
                                        right => function { 'sub',
                                            body => hash_ref { '{}',
                                                data => leaf '$headers',
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    ],
                },
            ],
        },
        function { 'header_iter',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$headers',
                            right => leaf '$code',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '@headers',
                    right => dereference { '@$headers',
                        expr => leaf '@$headers',
                    },
                },
                while_stmt { 'while',
                    expr => branch { '=',
                        left => list { '()',
                            data => branch { ',',
                                left => leaf '$key',
                                right => leaf '$val',
                            },
                        },
                        right => function_call { 'splice',
                            args => [
                                branch { ',',
                                    left => branch { ',',
                                        left => leaf '@headers',
                                        right => leaf '0',
                                    },
                                    right => leaf '2',
                                },
                            ],
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$code',
                        right => list { '()',
                            data => branch { ',',
                                left => leaf '$key',
                                right => leaf '$val',
                            },
                        },
                    },
                },
            ],
        },
        function { 'header_get',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$headers',
                            right => leaf '$key',
                        },
                    },
                    right => list { '()',
                        data => branch { ',',
                            left => function_call { 'shift',
                                args => [
                                ],
                            },
                            right => function_call { 'lc',
                                args => [
                                    function_call { 'shift',
                                        args => [
                                        ],
                                    },
                                ],
                            },
                        },
                    },
                },
                leaf '@val',
                function_call { 'header_iter',
                    args => [
                        branch { ',',
                            left => leaf '$headers',
                            right => function { 'sub',
                                body => if_stmt { 'if',
                                    expr => branch { 'eq',
                                        left => function_call { 'lc',
                                            args => [
                                                array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '0',
                                                    },
                                                },
                                            ],
                                        },
                                        right => leaf '$key',
                                    },
                                    true_stmt => function_call { 'push',
                                        args => [
                                            branch { ',',
                                                left => leaf '@val',
                                                right => array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '1',
                                                    },
                                                },
                                            },
                                        ],
                                    },
                                },
                            },
                        },
                    ],
                },
                Test::Compiler::Parser::return { 'return',
                    body => three_term_operator { '?',
                        cond => function_call { 'wantarray',
                            args => [
                            ],
                        },
                        true_expr => leaf '@val',
                        false_expr => array { '$val',
                            idx => array_ref { '[]',
                                data => leaf '0',
                            },
                        },
                    },
                },
            ],
        },
        function { 'header_set',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$headers',
                                right => leaf '$key',
                            },
                            right => leaf '$val',
                        },
                    },
                    right => leaf '@_',
                },
                list { '()',
                    data => branch { ',',
                        left => leaf '$set',
                        right => leaf '@new_headers',
                    },
                },
                function_call { 'header_iter',
                    args => [
                        branch { ',',
                            left => leaf '$headers',
                            right => function { 'sub',
                                body => [
                                    if_stmt { 'if',
                                        expr => branch { 'eq',
                                            left => function_call { 'lc',
                                                args => [
                                                    leaf '$key',
                                                ],
                                            },
                                            right => function_call { 'lc',
                                                args => [
                                                    array { '$_',
                                                        idx => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                        true_stmt => [
                                            if_stmt { 'if',
                                                expr => leaf '$set',
                                                true_stmt => Test::Compiler::Parser::return { 'return',
                                                },
                                            },
                                            branch { '=',
                                                left => array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '1',
                                                    },
                                                },
                                                right => leaf '$val',
                                            },
                                            single_term_operator { '++',
                                                expr => leaf '$set',
                                            },
                                        ],
                                    },
                                    function_call { 'push',
                                        args => [
                                            branch { ',',
                                                left => branch { ',',
                                                    left => leaf '@new_headers',
                                                    right => array { '$_',
                                                        idx => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                },
                                                right => array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '1',
                                                    },
                                                },
                                            },
                                        ],
                                    },
                                ],
                            },
                        },
                    ],
                },
                if_stmt { 'unless',
                    expr => leaf '$set',
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => branch { ',',
                                    left => leaf '@new_headers',
                                    right => leaf '$key',
                                },
                                right => leaf '$val',
                            },
                        ],
                    },
                },
                branch { '=',
                    left => dereference { '@$headers',
                        expr => leaf '@$headers',
                    },
                    right => leaf '@new_headers',
                },
            ],
        },
        function { 'header_push',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$headers',
                                right => leaf '$key',
                            },
                            right => leaf '$val',
                        },
                    },
                    right => leaf '@_',
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => branch { ',',
                                left => dereference { '@$headers',
                                    expr => leaf '@$headers',
                                },
                                right => leaf '$key',
                            },
                            right => leaf '$val',
                        },
                    ],
                },
            ],
        },
        function { 'header_exists',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$headers',
                            right => leaf '$key',
                        },
                    },
                    right => list { '()',
                        data => branch { ',',
                            left => function_call { 'shift',
                                args => [
                                ],
                            },
                            right => function_call { 'lc',
                                args => [
                                    function_call { 'shift',
                                        args => [
                                        ],
                                    },
                                ],
                            },
                        },
                    },
                },
                leaf '$exists',
                function_call { 'header_iter',
                    args => [
                        branch { ',',
                            left => leaf '$headers',
                            right => function { 'sub',
                                body => if_stmt { 'if',
                                    expr => branch { 'eq',
                                        left => function_call { 'lc',
                                            args => [
                                                array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '0',
                                                    },
                                                },
                                            ],
                                        },
                                        right => leaf '$key',
                                    },
                                    true_stmt => branch { '=',
                                        left => leaf '$exists',
                                        right => leaf '1',
                                    },
                                },
                            },
                        },
                    ],
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$exists',
                },
            ],
        },
        function { 'header_remove',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$headers',
                            right => leaf '$key',
                        },
                    },
                    right => list { '()',
                        data => branch { ',',
                            left => function_call { 'shift',
                                args => [
                                ],
                            },
                            right => function_call { 'lc',
                                args => [
                                    function_call { 'shift',
                                        args => [
                                        ],
                                    },
                                ],
                            },
                        },
                    },
                },
                leaf '@new_headers',
                function_call { 'header_iter',
                    args => [
                        branch { ',',
                            left => leaf '$headers',
                            right => function { 'sub',
                                body => if_stmt { 'unless',
                                    expr => branch { 'eq',
                                        left => function_call { 'lc',
                                            args => [
                                                array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '0',
                                                    },
                                                },
                                            ],
                                        },
                                        right => leaf '$key',
                                    },
                                    true_stmt => function_call { 'push',
                                        args => [
                                            branch { ',',
                                                left => branch { ',',
                                                    left => leaf '@new_headers',
                                                    right => array { '$_',
                                                        idx => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                },
                                                right => array { '$_',
                                                    idx => array_ref { '[]',
                                                        data => leaf '1',
                                                    },
                                                },
                                            },
                                        ],
                                    },
                                },
                            },
                        },
                    ],
                },
                branch { '=',
                    left => dereference { '@$headers',
                        expr => leaf '@$headers',
                    },
                    right => leaf '@new_headers',
                },
            ],
        },
        function { 'status_with_no_entity_body',
            body => [
                branch { '=',
                    left => leaf '$status',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '||',
                        left => branch { '||',
                            left => branch { '<',
                                left => leaf '$status',
                                right => leaf '200',
                            },
                            right => branch { '==',
                                left => leaf '$status',
                                right => leaf '204',
                            },
                        },
                        right => branch { '==',
                            left => leaf '$status',
                            right => leaf '304',
                        },
                    },
                },
            ],
        },
        function { 'encode_html',
            body => [
                branch { '=',
                    left => leaf '$str',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=~',
                    left => leaf '$str',
                    right => reg_replace { 's',
                        to => leaf '&amp;',
                        from => leaf '&',
                        option => leaf 'g',
                    },
                },
                branch { '=~',
                    left => leaf '$str',
                    right => reg_replace { 's',
                        to => leaf '&gt;',
                        from => leaf '>',
                        option => leaf 'g',
                    },
                },
                branch { '=~',
                    left => leaf '$str',
                    right => reg_replace { 's',
                        to => leaf '&lt;',
                        from => leaf '<',
                        option => leaf 'g',
                    },
                },
                branch { '=~',
                    left => leaf '$str',
                    right => reg_replace { 's',
                        to => leaf '&quot;',
                        from => leaf '"',
                        option => leaf 'g',
                    },
                },
                branch { '=~',
                    left => leaf '$str',
                    right => reg_replace { 's',
                        to => leaf '&#39;',
                        from => leaf '\'',
                        option => leaf 'g',
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$str',
                },
            ],
        },
        function { 'inline_object',
            body => [
                branch { '=',
                    left => leaf '%args',
                    right => leaf '@_',
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => single_term_operator { '\\',
                                expr => leaf '%args',
                            },
                            right => leaf 'Plack::Util::Prototype',
                        },
                    ],
                },
            ],
        },
        function { 'response_cb',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$res',
                            right => leaf '$cb',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$body_filter',
                    right => function { 'sub',
                        body => [
                            branch { '=',
                                left => list { '()',
                                    data => branch { ',',
                                        left => leaf '$cb',
                                        right => leaf '$res',
                                    },
                                },
                                right => leaf '@_',
                            },
                            branch { '=',
                                left => leaf '$filter_cb',
                                right => branch { '->',
                                    left => leaf '$cb',
                                    right => list { '()',
                                        data => leaf '$res',
                                    },
                                },
                            },
                            if_stmt { 'if',
                                expr => branch { '&&',
                                    left => function_call { 'defined',
                                        args => [
                                            leaf '$filter_cb',
                                        ],
                                    },
                                    right => branch { 'eq',
                                        left => function_call { 'ref',
                                            args => [
                                                leaf '$filter_cb',
                                            ],
                                        },
                                        right => leaf 'CODE',
                                    },
                                },
                                true_stmt => [
                                    function_call { 'Plack::Util::header_remove',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => branch { '->',
                                                        left => leaf '$res',
                                                        right => array_ref { '[]',
                                                            data => leaf '1',
                                                        },
                                                    },
                                                    right => leaf 'Content-Length',
                                                },
                                            },
                                        ],
                                    },
                                    if_stmt { 'if',
                                        expr => function_call { 'defined',
                                            args => [
                                                branch { '->',
                                                    left => leaf '$res',
                                                    right => array_ref { '[]',
                                                        data => leaf '2',
                                                    },
                                                },
                                            ],
                                        },
                                        true_stmt => if_stmt { 'if',
                                            expr => branch { 'eq',
                                                left => function_call { 'ref',
                                                    args => [
                                                        branch { '->',
                                                            left => leaf '$res',
                                                            right => array_ref { '[]',
                                                                data => leaf '2',
                                                            },
                                                        },
                                                    ],
                                                },
                                                right => leaf 'ARRAY',
                                            },
                                            true_stmt => [
                                                foreach_stmt { 'for',
                                                    cond => dereference { '@{',
                                                        expr => branch { '->',
                                                            left => leaf '$res',
                                                            right => array_ref { '[]',
                                                                data => leaf '2',
                                                            },
                                                        },
                                                    },
                                                    true_stmt => branch { '=',
                                                        left => leaf '$line',
                                                        right => branch { '->',
                                                            left => leaf '$filter_cb',
                                                            right => list { '()',
                                                                data => leaf '$line',
                                                            },
                                                        },
                                                    },
                                                    itr => leaf '$line',
                                                },
                                                branch { '=',
                                                    left => leaf '$eof',
                                                    right => branch { '->',
                                                        left => leaf '$filter_cb',
                                                        right => list { '()',
                                                            data => leaf 'undef',
                                                        },
                                                    },
                                                },
                                                if_stmt { 'if',
                                                    expr => function_call { 'defined',
                                                        args => [
                                                            leaf '$eof',
                                                        ],
                                                    },
                                                    true_stmt => function_call { 'push',
                                                        args => [
                                                            branch { ',',
                                                                left => dereference { '@{',
                                                                    expr => branch { '->',
                                                                        left => leaf '$res',
                                                                        right => array_ref { '[]',
                                                                            data => leaf '2',
                                                                        },
                                                                    },
                                                                },
                                                                right => leaf '$eof',
                                                            },
                                                        ],
                                                    },
                                                },
                                            ],
                                            false_stmt => else_stmt { 'else',
                                                stmt => [
                                                    branch { '=',
                                                        left => leaf '$body',
                                                        right => branch { '->',
                                                            left => leaf '$res',
                                                            right => array_ref { '[]',
                                                                data => leaf '2',
                                                            },
                                                        },
                                                    },
                                                    branch { '=',
                                                        left => leaf '$getline',
                                                        right => function { 'sub',
                                                            body => branch { '->',
                                                                left => leaf '$body',
                                                                right => function_call { 'getline',
                                                                    args => [
                                                                    ],
                                                                },
                                                            },
                                                        },
                                                    },
                                                    branch { '=',
                                                        left => branch { '->',
                                                            left => leaf '$res',
                                                            right => array_ref { '[]',
                                                                data => leaf '2',
                                                            },
                                                        },
                                                        right => function_call { 'Plack::Util::inline_object',
                                                            args => [
                                                                branch { ',',
                                                                    left => branch { '=>',
                                                                        left => leaf 'getline',
                                                                        right => function { 'sub',
                                                                            body => branch { '->',
                                                                                left => leaf '$filter_cb',
                                                                                right => list { '()',
                                                                                    data => branch { '->',
                                                                                        left => leaf '$getline',
                                                                                        right => list { '()',
                                                                                        },
                                                                                    },
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                    right => branch { '=>',
                                                                        left => leaf 'close',
                                                                        right => function { 'sub',
                                                                            body => branch { '->',
                                                                                left => leaf '$body',
                                                                                right => function_call { 'close',
                                                                                    args => [
                                                                                    ],
                                                                                },
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
                                        false_stmt => else_stmt { 'else',
                                            stmt => Test::Compiler::Parser::return { 'return',
                                                body => leaf '$filter_cb',
                                            },
                                        },
                                    },
                                ],
                            },
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                leaf '$res',
                            ],
                        },
                        right => leaf 'ARRAY',
                    },
                    true_stmt => [
                        branch { '->',
                            left => leaf '$body_filter',
                            right => list { '()',
                                data => branch { ',',
                                    left => leaf '$cb',
                                    right => leaf '$res',
                                },
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => leaf '$res',
                        },
                    ],
                    false_stmt => if_stmt { 'elsif',
                        expr => branch { 'eq',
                            left => function_call { 'ref',
                                args => [
                                    leaf '$res',
                                ],
                            },
                            right => leaf 'CODE',
                        },
                        true_stmt => Test::Compiler::Parser::return { 'return',
                            body => function { 'sub',
                                body => [
                                    branch { '=',
                                        left => leaf '$respond',
                                        right => function_call { 'shift',
                                            args => [
                                            ],
                                        },
                                    },
                                    branch { '=',
                                        left => leaf '$cb',
                                        right => leaf '$cb',
                                    },
                                    branch { '->',
                                        left => leaf '$res',
                                        right => list { '()',
                                            data => function { 'sub',
                                                body => [
                                                    branch { '=',
                                                        left => leaf '$res',
                                                        right => function_call { 'shift',
                                                            args => [
                                                            ],
                                                        },
                                                    },
                                                    branch { '=',
                                                        left => leaf '$filter_cb',
                                                        right => branch { '->',
                                                            left => leaf '$body_filter',
                                                            right => list { '()',
                                                                data => branch { ',',
                                                                    left => leaf '$cb',
                                                                    right => leaf '$res',
                                                                },
                                                            },
                                                        },
                                                    },
                                                    if_stmt { 'if',
                                                        expr => leaf '$filter_cb',
                                                        true_stmt => [
                                                            branch { '=',
                                                                left => leaf '$writer',
                                                                right => branch { '->',
                                                                    left => leaf '$respond',
                                                                    right => list { '()',
                                                                        data => leaf '$res',
                                                                    },
                                                                },
                                                            },
                                                            if_stmt { 'if',
                                                                expr => leaf '$writer',
                                                                true_stmt => Test::Compiler::Parser::return { 'return',
                                                                    body => function_call { 'Plack::Util::inline_object',
                                                                        args => [
                                                                            branch { ',',
                                                                                left => branch { '=>',
                                                                                    left => leaf 'write',
                                                                                    right => function { 'sub',
                                                                                        body => branch { '->',
                                                                                            left => leaf '$writer',
                                                                                            right => function_call { 'write',
                                                                                                args => [
                                                                                                    branch { '->',
                                                                                                        left => leaf '$filter_cb',
                                                                                                        right => list { '()',
                                                                                                            data => leaf '@_',
                                                                                                        },
                                                                                                    },
                                                                                                ],
                                                                                            },
                                                                                        },
                                                                                    },
                                                                                },
                                                                                right => branch { '=>',
                                                                                    left => leaf 'close',
                                                                                    right => function { 'sub',
                                                                                        body => [
                                                                                            branch { '=',
                                                                                                left => leaf '$chunk',
                                                                                                right => branch { '->',
                                                                                                    left => leaf '$filter_cb',
                                                                                                    right => list { '()',
                                                                                                        data => leaf 'undef',
                                                                                                    },
                                                                                                },
                                                                                            },
                                                                                            if_stmt { 'if',
                                                                                                expr => function_call { 'defined',
                                                                                                    args => [
                                                                                                        leaf '$chunk',
                                                                                                    ],
                                                                                                },
                                                                                                true_stmt => branch { '->',
                                                                                                    left => leaf '$writer',
                                                                                                    right => function_call { 'write',
                                                                                                        args => [
                                                                                                            leaf '$chunk',
                                                                                                        ],
                                                                                                    },
                                                                                                },
                                                                                            },
                                                                                            branch { '->',
                                                                                                left => leaf '$writer',
                                                                                                right => function_call { 'close',
                                                                                                    args => [
                                                                                                    ],
                                                                                                },
                                                                                            },
                                                                                        ],
                                                                                    },
                                                                                },
                                                                            },
                                                                        ],
                                                                    },
                                                                },
                                                            },
                                                        ],
                                                        false_stmt => else_stmt { 'else',
                                                            stmt => Test::Compiler::Parser::return { 'return',
                                                                body => branch { '->',
                                                                    left => leaf '$respond',
                                                                    right => list { '()',
                                                                        data => leaf '$res',
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$res',
                },
            ],
        },
        Test::Compiler::Parser::package { 'Plack::Util::Prototype',
        },
        leaf '$AUTOLOAD',
        function { 'can',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '1',
                        },
                    },
                },
            },
        },
        function { 'AUTOLOAD',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$attr',
                    right => leaf '$AUTOLOAD',
                },
                branch { '=~',
                    left => leaf '$attr',
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '.*:',
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf '$attr',
                                    },
                                },
                            ],
                        },
                        right => leaf 'CODE',
                    },
                    true_stmt => branch { '->',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf '$attr',
                            },
                        },
                        right => list { '()',
                            data => leaf '@_',
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => function_call { 'Carp::croak',
                            args => [
                                reg_prefix { 'qq',
                                    expr => leaf 'Can\'t locate object method "$attr" via package "Plack::Util::Prototype"',
                                },
                            ],
                        },
                    },
                },
            ],
        },
        function { 'DESTROY',
        },
        Test::Compiler::Parser::package { 'Plack::Util::IOWithPath',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'IO::Handle',
            },
        },
        function { 'path',
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
                            left => dereference { '${',
                                expr => single_term_operator { '*',
                                    expr => leaf '$self',
                                },
                            },
                            right => hash_ref { '{}',
                                data => single_term_operator { '+',
                                    expr => leaf '__PACKAGE__',
                                },
                            },
                        },
                        right => function_call { 'shift',
                            args => [
                            ],
                        },
                    },
                },
                branch { '->',
                    left => dereference { '${',
                        expr => single_term_operator { '*',
                            expr => leaf '$self',
                        },
                    },
                    right => hash_ref { '{}',
                        data => single_term_operator { '+',
                            expr => leaf '__PACKAGE__',
                        },
                    },
                },
            ],
        },
        Test::Compiler::Parser::package { 'Plack::Util',
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Util;
use strict;
use Carp ();
use Scalar::Util;
use IO::Handle;
use overload ();
use File::Spec ();

sub TRUE()  { 1==1 }
sub FALSE() { !TRUE }

sub load_class {
    my($class, $prefix) = @_;

    if ($prefix) {
        unless ($class =~ s/^\+// || $class =~ /^$prefix/) {
            $class = "$prefix\::$class";
        }
    }

    my $file = $class;
    $file =~ s!::!/!g;
    require "$file.pm"; ## no critic

    return $class;
}

sub is_real_fh ($) {
    my $fh = shift;

    {
        no warnings 'uninitialized';
        return FALSE if -p $fh or -c _ or -b _;
    }

    my $reftype = Scalar::Util::reftype($fh) or return;
    if (   $reftype eq 'IO'
        or $reftype eq 'GLOB' && *{$fh}{IO}
    ) {
        # if it's a blessed glob make sure to not break encapsulation with
        # fileno($fh) (e.g. if you are filtering output then file descriptor
        # based operations might no longer be valid).
        # then ensure that the fileno *opcode* agrees too, that there is a
        # valid IO object inside $fh either directly or indirectly and that it
        # corresponds to a real file descriptor.
        my $m_fileno = $fh->fileno;
        return FALSE unless defined $m_fileno;
        return FALSE unless $m_fileno >= 0;

        my $f_fileno = fileno($fh);
        return FALSE unless defined $f_fileno;
        return FALSE unless $f_fileno >= 0;
        return TRUE;
    } else {
        # anything else, including GLOBS without IO (even if they are blessed)
        # and non GLOB objects that look like filehandle objects cannot have a
        # valid file descriptor in fileno($fh) context so may break.
        return FALSE;
    }
}

sub set_io_path {
    my($fh, $path) = @_;
    bless $fh, 'Plack::Util::IOWithPath';
    $fh->path($path);
}

sub content_length {
    my $body = shift;

    return unless defined $body;

    if (ref $body eq 'ARRAY') {
        my $cl = 0;
        for my $chunk (@$body) {
            $cl += length $chunk;
        }
        return $cl;
    } elsif ( is_real_fh($body) ) {
        return (-s $body) - tell($body);
    }

    return;
}

sub foreach {
    my($body, $cb) = @_;

    if (ref $body eq 'ARRAY') {
        for my $line (@$body) {
            $cb->($line) if length $line;
        }
    } else {
        local $/ = \65536 unless ref $/;
        while (defined(my $line = $body->getline)) {
            $cb->($line) if length $line;
        }
        $body->close;
    }
}

sub class_to_file {
    my $class = shift;
    $class =~ s!::!/!g;
    $class . ".pm";
}

sub _load_sandbox {
    my $_file = shift;

    my $_package = $_file;
    $_package =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;

    local $0 = $_file; # so FindBin etc. works
    local @ARGV = ();  # Some frameworks might try to parse @ARGV

    return eval sprintf <<'END_EVAL', $_package;
package Plack::Sandbox::%s;
{
    my $app = do $_file;
    if ( !$app && ( my $error = $@ || $! )) { die $error; }
    $app;
}
END_EVAL
}

sub load_psgi {
    my $stuff = shift;

    local $ENV{PLACK_ENV} = $ENV{PLACK_ENV} || 'development';

    my $file = $stuff =~ /^[a-zA-Z0-9\_\:]+$/ ? class_to_file($stuff) : File::Spec->rel2abs($stuff);
    my $app = _load_sandbox($file);
    die "Error while loading $file: $@" if $@;

    return $app;
}

sub run_app($$) {
    my($app, $env) = @_;

    return eval { $app->($env) } || do {
        my $body = "Internal Server Error";
        $env->{'psgi.errors'}->print($@);
        [ 500, [ 'Content-Type' => 'text/plain', 'Content-Length' => length($body) ], [ $body ] ];
    };
}

sub headers {
    my $headers = shift;
    inline_object(
        iter   => sub { header_iter($headers, @_) },
        get    => sub { header_get($headers, @_) },
        set    => sub { header_set($headers, @_) },
        push   => sub { header_push($headers, @_) },
        exists => sub { header_exists($headers, @_) },
        remove => sub { header_remove($headers, @_) },
        headers => sub { $headers },
    );
}

sub header_iter {
    my($headers, $code) = @_;

    my @headers = @$headers; # copy
    while (my($key, $val) = splice @headers, 0, 2) {
        $code->($key, $val);
    }
}

sub header_get {
    my($headers, $key) = (shift, lc shift);

    my @val;
    header_iter $headers, sub {
        push @val, $_[1] if lc $_[0] eq $key;
    };

    return wantarray ? @val : $val[0];
}

sub header_set {
    my($headers, $key, $val) = @_;

    my($set, @new_headers);
    header_iter $headers, sub {
        if (lc $key eq lc $_[0]) {
            return if $set;
            $_[1] = $val;
            $set++;
        }
        push @new_headers, $_[0], $_[1];
    };

    push @new_headers, $key, $val unless $set;
    @$headers = @new_headers;
}

sub header_push {
    my($headers, $key, $val) = @_;
    push @$headers, $key, $val;
}

sub header_exists {
    my($headers, $key) = (shift, lc shift);

    my $exists;
    header_iter $headers, sub {
        $exists = 1 if lc $_[0] eq $key;
    };

    return $exists;
}

sub header_remove {
    my($headers, $key) = (shift, lc shift);

    my @new_headers;
    header_iter $headers, sub {
        push @new_headers, $_[0], $_[1]
            unless lc $_[0] eq $key;
    };

    @$headers = @new_headers;
}

sub status_with_no_entity_body {
    my $status = shift;
    return $status < 200 || $status == 204 || $status == 304;
}

sub encode_html {
    my $str = shift;
    $str =~ s/&/&amp;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/"/&quot;/g;
    $str =~ s/'/&#39;/g;
    return $str;
}

sub inline_object {
    my %args = @_;
    bless \%args, 'Plack::Util::Prototype';
}

sub response_cb {
    my($res, $cb) = @_;

    my $body_filter = sub {
        my($cb, $res) = @_;
        my $filter_cb = $cb->($res);
        # If response_cb returns a callback, treat it as a $body filter
        if (defined $filter_cb && ref $filter_cb eq 'CODE') {
            Plack::Util::header_remove($res->[1], 'Content-Length');
            if (defined $res->[2]) {
                if (ref $res->[2] eq 'ARRAY') {
                    for my $line (@{$res->[2]}) {
                        $line = $filter_cb->($line);
                    }
                    # Send EOF.
                    my $eof = $filter_cb->( undef );
                    push @{ $res->[2] }, $eof if defined $eof;
                } else {
                    my $body    = $res->[2];
                    my $getline = sub { $body->getline };
                    $res->[2] = Plack::Util::inline_object
                        getline => sub { $filter_cb->($getline->()) },
                        close => sub { $body->close };
                }
            } else {
                return $filter_cb;
            }
        }
    };

    if (ref $res eq 'ARRAY') {
        $body_filter->($cb, $res);
        return $res;
    } elsif (ref $res eq 'CODE') {
        return sub {
            my $respond = shift;
            my $cb = $cb;  # To avoid the nested closure leak for 5.8.x
            $res->(sub {
                my $res = shift;
                my $filter_cb = $body_filter->($cb, $res);
                if ($filter_cb) {
                    my $writer = $respond->($res);
                    if ($writer) {
                        return Plack::Util::inline_object
                            write => sub { $writer->write($filter_cb->(@_)) },
                            close => sub {
                                my $chunk = $filter_cb->(undef);
                                $writer->write($chunk) if defined $chunk;
                                $writer->close;
                            };
                    }
                } else {
                    return $respond->($res);
                }
            });
        };
    }

    return $res;
}

package Plack::Util::Prototype;

our $AUTOLOAD;
sub can {
    $_[0]->{$_[1]};
}

sub AUTOLOAD {
    my $self = shift;
    my $attr = $AUTOLOAD;
    $attr =~ s/.*://;
    if (ref($self->{$attr}) eq 'CODE') {
        $self->{$attr}->(@_);
    } else {
        Carp::croak(qq/Can't locate object method "$attr" via package "Plack::Util::Prototype"/);
    }
}

sub DESTROY { }

package Plack::Util::IOWithPath;
use parent qw(IO::Handle);

sub path {
    my $self = shift;
    if (@_) {
        ${*$self}{+__PACKAGE__} = shift;
    }
    ${*$self}{+__PACKAGE__};
}

package Plack::Util;

1;

__END__

=head1 NAME

Plack::Util - Utility subroutines for Plack server and framework developers

=head1 FUNCTIONS

=over 4

=item TRUE, FALSE

  my $true  = Plack::Util::TRUE;
  my $false = Plack::Util::FALSE;

Utility constants to include when you specify boolean variables in C<$env> hash (e.g. C<psgi.multithread>).

=item load_class

  my $class = Plack::Util::load_class($class [, $prefix ]);

Constructs a class name and C<require> the class. Throws an exception
if the .pm file for the class is not found, just with the built-in
C<require>.

If C<$prefix> is set, the class name is prepended to the C<$class>
unless C<$class> begins with C<+> sign, which means the class name is
already fully qualified.

  my $class = Plack::Util::load_class("Foo");                   # Foo
  my $class = Plack::Util::load_class("Baz", "Foo::Bar");       # Foo::Bar::Baz
  my $class = Plack::Util::load_class("+XYZ::ZZZ", "Foo::Bar"); # XYZ::ZZZ

Note that this function doesn't validate (or "sanitize") the passed
string, hence if you pass a user input to this function (which is an
insecure thing to do in the first place) it might lead to unexpected
behavior of loading files outside your C<@INC> path. If you want a
generic module loading function, you should check out CPAN modules
such as L<Module::Runtime>.

=item is_real_fh

  if ( Plack::Util::is_real_fh($fh) ) { }

returns true if a given C<$fh> is a real file handle that has a file
descriptor. It returns false if C<$fh> is PerlIO handle that is not
really related to the underlying file etc.

=item content_length

  my $cl = Plack::Util::content_length($body);

Returns the length of content from body if it can be calculated. If
C<$body> is an array ref it's a sum of length of each chunk, if
C<$body> is a real filehandle it's a remaining size of the filehandle,
otherwise returns undef.

=item set_io_path

  Plack::Util::set_io_path($fh, "/path/to/foobar.txt");

Sets the (absolute) file path to C<$fh> filehandle object, so you can
call C<< $fh->path >> on it. As a side effect C<$fh> is blessed to an
internal package but it can still be treated as a normal file
handle.

This module doesn't normalize or absolutize the given path, and is
intended to be used from Server or Middleware implementations. See
also L<IO::File::WithPath>.

=item foreach

  Plack::Util::foreach($body, $cb);

Iterate through I<$body> which is an array reference or
IO::Handle-like object and pass each line (which is NOT really
guaranteed to be a I<line>) to the callback function.

It internally sets the buffer length C<$/> to 65536 in case it reads
the binary file, unless otherwise set in the caller's code.

=item load_psgi

  my $app = Plack::Util::load_psgi $psgi_file_or_class;

Load C<app.psgi> file or a class name (like C<MyApp::PSGI>) and
require the file to get PSGI application handler. If the file can't be
loaded (e.g. file doesn't exist or has a perl syntax error), it will
throw an exception.

Since version 1.0006, this function would not load PSGI files from
include paths (C<@INC>) unless it looks like a class name that only
consists of C<[A-Za-z0-9_:]>. For example:

  Plack::Util::load_psgi("app.psgi");          # ./app.psgi
  Plack::Util::load_psgi("/path/to/app.psgi"); # /path/to/app.psgi
  Plack::Util::load_psgi("MyApp::PSGI");       # MyApp/PSGI.pm from @INC

B<Security>: If you give this function a class name or module name
that is loadable from your system, it will load the module. This could
lead to a security hole:

  my $psgi = ...; # user-input: consider "Moose"
  $app = Plack::Util::load_psgi($psgi); # this would lead to 'require "Moose.pm"'!

Generally speaking, passing an external input to this function is
considered very insecure. If you really want to do that, validate that
a given file name contains dots (like C<foo.psgi>) and also turn it
into a full path in your caller's code.

=item run_app

  my $res = Plack::Util::run_app $app, $env;

Runs the I<$app> by wrapping errors with I<eval> and if an error is
found, logs it to C<< $env->{'psgi.errors'} >> and returns the
template 500 Error response.

=item header_get, header_exists, header_set, header_push, header_remove

  my $hdrs = [ 'Content-Type' => 'text/plain' ];

  my $v = Plack::Util::header_get($hdrs, $key); # First found only
  my @v = Plack::Util::header_get($hdrs, $key);
  my $bool = Plack::Util::header_exists($hdrs, $key);
  Plack::Util::header_set($hdrs, $key, $val);   # overwrites existent header
  Plack::Util::header_push($hdrs, $key, $val);
  Plack::Util::header_remove($hdrs, $key);

Utility functions to manipulate PSGI response headers array
reference. The methods that read existent header value handles header
name as case insensitive.

  my $hdrs = [ 'Content-Type' => 'text/plain' ];
  my $v = Plack::Util::header_get($hdrs, 'content-type'); # 'text/plain'

=item headers

  my $headers = [ 'Content-Type' => 'text/plain' ];

  my $h = Plack::Util::headers($headers);
  $h->get($key);
  if ($h->exists($key)) { ... }
  $h->set($key => $val);
  $h->push($key => $val);
  $h->remove($key);
  $h->headers; # same reference as $headers

Given a header array reference, returns a convenient object that has
an instance methods to access C<header_*> functions with an OO
interface. The object holds a reference to the original given
C<$headers> argument and updates the reference accordingly when called
write methods like C<set>, C<push> or C<remove>. It also has C<headers>
method that would return the same reference.

=item status_with_no_entity_body

  if (status_with_no_entity_body($res->[0])) { }

Returns true if the given status code doesn't have any Entity body in
HTTP response, i.e. it's 100, 101, 204 or 304.

=item inline_object

  my $o = Plack::Util::inline_object(
      write => sub { $h->push_write(@_) },
      close => sub { $h->push_shutdown },
  );
  $o->write(@stuff);
  $o->close;

Creates an instant object that can react to methods passed in the
constructor. Handy to create when you need to create an IO stream
object for input or errors.

=item encode_html

  my $encoded_string = Plack::Util::encode( $string );

Entity encodes C<<>, C<< > >>, C<&>, C<"> and C<'> in the input string
and returns it.

=item response_cb

See L<Plack::Middleware/RESPONSE CALLBACK> for details.

=back

=cut




