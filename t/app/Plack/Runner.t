use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Runner.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Runner',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        module { 'Plack::Util',
        },
        module { 'Try::Tiny',
        },
        function { 'new',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => hash_ref { '{}',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => branch { '=>',
                                                            left => leaf 'env',
                                                            right => hash { '$ENV',
                                                                key => hash_ref { '{}',
                                                                    data => leaf 'PLACK_ENV',
                                                                },
                                                            },
                                                        },
                                                        right => branch { '=>',
                                                            left => leaf 'loader',
                                                            right => leaf 'Plack::Loader',
                                                        },
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'includes',
                                                        right => array_ref { '[]',
                                                        },
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'modules',
                                                    right => array_ref { '[]',
                                                    },
                                                },
                                            },
                                            right => branch { '=>',
                                                left => leaf 'default_middleware',
                                                right => leaf '1',
                                            },
                                        },
                                        right => leaf '@_',
                                    },
                                },
                            },
                            right => leaf '$class',
                        },
                    ],
                },
            ],
        },
        function { 'build',
            body => [
                branch { '=',
                    left => leaf '$block',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$app',
                    right => branch { '||',
                        left => function_call { 'shift',
                            args => [
                            ],
                        },
                        right => function { 'sub',
                            body => hash_ref { '{}',
                            },
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => function { 'sub',
                        body => branch { '->',
                            left => leaf '$block',
                            right => list { '()',
                                data => branch { '->',
                                    left => leaf '$app',
                                    right => list { '()',
                                    },
                                },
                            },
                        },
                    },
                },
            ],
            prototype => leaf '&;$',
        },
        function { 'parse_options',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '@ARGV',
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '@ARGV',
                    right => function_call { 'map',
                        args => [
                            three_term_operator { '?',
                                cond => regexp { '^(-[IMe])(.+)',
                                },
                                true_expr => list { '()',
                                    data => branch { ',',
                                        left => leaf '$1',
                                        right => leaf '$2',
                                    },
                                },
                                false_expr => leaf '$_',
                            },
                            leaf '@ARGV',
                        ],
                    },
                },
                list { '()',
                    data => branch { ',',
                        left => branch { ',',
                            left => branch { ',',
                                left => leaf '$host',
                                right => leaf '$port',
                            },
                            right => leaf '$socket',
                        },
                        right => leaf '@listen',
                    },
                },
                module { 'Getopt::Long',
                },
                branch { '=',
                    left => leaf '$parser',
                    right => branch { '->',
                        left => leaf 'Getopt::Long::Parser',
                        right => function_call { 'new',
                            args => [
                                list { '()',
                                    data => branch { ',',
                                        left => branch { '=>',
                                            left => leaf 'config',
                                            right => array_ref { '[]',
                                                data => branch { ',',
                                                    left => branch { ',',
                                                        left => leaf 'no_auto_abbrev',
                                                        right => leaf 'no_ignore_case',
                                                    },
                                                    right => leaf 'pass_through',
                                                },
                                            },
                                        },
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '->',
                    left => leaf '$parser',
                    right => function_call { 'getoptions',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => branch { ',',
                                                            left => branch { ',',
                                                                left => branch { ',',
                                                                    left => branch { ',',
                                                                        left => branch { ',',
                                                                            left => branch { ',',
                                                                                left => branch { ',',
                                                                                    left => branch { ',',
                                                                                        left => branch { ',',
                                                                                            left => branch { ',',
                                                                                                left => branch { ',',
                                                                                                    left => branch { ',',
                                                                                                        left => branch { ',',
                                                                                                            left => branch { '=>',
                                                                                                                left => leaf 'a|app=s',
                                                                                                                right => single_term_operator { '\\',
                                                                                                                    expr => branch { '->',
                                                                                                                        left => leaf '$self',
                                                                                                                        right => hash_ref { '{}',
                                                                                                                            data => leaf 'app',
                                                                                                                        },
                                                                                                                    },
                                                                                                                },
                                                                                                            },
                                                                                                            right => branch { '=>',
                                                                                                                left => leaf 'o|host=s',
                                                                                                                right => single_term_operator { '\\',
                                                                                                                    expr => leaf '$host',
                                                                                                                },
                                                                                                            },
                                                                                                        },
                                                                                                        right => branch { '=>',
                                                                                                            left => leaf 'p|port=i',
                                                                                                            right => single_term_operator { '\\',
                                                                                                                expr => leaf '$port',
                                                                                                            },
                                                                                                        },
                                                                                                    },
                                                                                                    right => branch { '=>',
                                                                                                        left => leaf 's|server=s',
                                                                                                        right => single_term_operator { '\\',
                                                                                                            expr => branch { '->',
                                                                                                                left => leaf '$self',
                                                                                                                right => hash_ref { '{}',
                                                                                                                    data => leaf 'server',
                                                                                                                },
                                                                                                            },
                                                                                                        },
                                                                                                    },
                                                                                                },
                                                                                                right => branch { '=>',
                                                                                                    left => leaf 'S|socket=s',
                                                                                                    right => single_term_operator { '\\',
                                                                                                        expr => leaf '$socket',
                                                                                                    },
                                                                                                },
                                                                                            },
                                                                                            right => branch { '=>',
                                                                                                left => leaf 'l|listen=s@',
                                                                                                right => single_term_operator { '\\',
                                                                                                    expr => leaf '@listen',
                                                                                                },
                                                                                            },
                                                                                        },
                                                                                        right => branch { '=>',
                                                                                            left => leaf 'D|daemonize',
                                                                                            right => single_term_operator { '\\',
                                                                                                expr => branch { '->',
                                                                                                    left => leaf '$self',
                                                                                                    right => hash_ref { '{}',
                                                                                                        data => leaf 'daemonize',
                                                                                                    },
                                                                                                },
                                                                                            },
                                                                                        },
                                                                                    },
                                                                                    right => branch { '=>',
                                                                                        left => leaf 'E|env=s',
                                                                                        right => single_term_operator { '\\',
                                                                                            expr => branch { '->',
                                                                                                left => leaf '$self',
                                                                                                right => hash_ref { '{}',
                                                                                                    data => leaf 'env',
                                                                                                },
                                                                                            },
                                                                                        },
                                                                                    },
                                                                                },
                                                                                right => branch { '=>',
                                                                                    left => leaf 'e=s',
                                                                                    right => single_term_operator { '\\',
                                                                                        expr => branch { '->',
                                                                                            left => leaf '$self',
                                                                                            right => hash_ref { '{}',
                                                                                                data => leaf 'eval',
                                                                                            },
                                                                                        },
                                                                                    },
                                                                                },
                                                                            },
                                                                            right => branch { '=>',
                                                                                left => leaf 'I=s@',
                                                                                right => branch { '->',
                                                                                    left => leaf '$self',
                                                                                    right => hash_ref { '{}',
                                                                                        data => leaf 'includes',
                                                                                    },
                                                                                },
                                                                            },
                                                                        },
                                                                        right => branch { '=>',
                                                                            left => leaf 'M=s@',
                                                                            right => branch { '->',
                                                                                left => leaf '$self',
                                                                                right => hash_ref { '{}',
                                                                                    data => leaf 'modules',
                                                                                },
                                                                            },
                                                                        },
                                                                    },
                                                                    right => branch { '=>',
                                                                        left => leaf 'r|reload',
                                                                        right => function { 'sub',
                                                                            body => branch { '=',
                                                                                left => branch { '->',
                                                                                    left => leaf '$self',
                                                                                    right => hash_ref { '{}',
                                                                                        data => leaf 'loader',
                                                                                    },
                                                                                },
                                                                                right => leaf 'Restarter',
                                                                            },
                                                                        },
                                                                    },
                                                                },
                                                                right => branch { '=>',
                                                                    left => leaf 'R|Reload=s',
                                                                    right => function { 'sub',
                                                                        body => [
                                                                            branch { '=',
                                                                                left => branch { '->',
                                                                                    left => leaf '$self',
                                                                                    right => hash_ref { '{}',
                                                                                        data => leaf 'loader',
                                                                                    },
                                                                                },
                                                                                right => leaf 'Restarter',
                                                                            },
                                                                            branch { '->',
                                                                                left => branch { '->',
                                                                                    left => leaf '$self',
                                                                                    right => function_call { 'loader',
                                                                                        args => [
                                                                                        ],
                                                                                    },
                                                                                },
                                                                                right => function_call { 'watch',
                                                                                    args => [
                                                                                        function_call { 'split',
                                                                                            args => [
                                                                                                branch { ',',
                                                                                                    left => leaf ',',
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
                                                                },
                                                            },
                                                            right => branch { '=>',
                                                                left => leaf 'L|loader=s',
                                                                right => single_term_operator { '\\',
                                                                    expr => branch { '->',
                                                                        left => leaf '$self',
                                                                        right => hash_ref { '{}',
                                                                            data => leaf 'loader',
                                                                        },
                                                                    },
                                                                },
                                                            },
                                                        },
                                                        right => branch { '=>',
                                                            left => leaf 'access-log=s',
                                                            right => single_term_operator { '\\',
                                                                expr => branch { '->',
                                                                    left => leaf '$self',
                                                                    right => hash_ref { '{}',
                                                                        data => leaf 'access_log',
                                                                    },
                                                                },
                                                            },
                                                        },
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'path=s',
                                                        right => single_term_operator { '\\',
                                                            expr => branch { '->',
                                                                left => leaf '$self',
                                                                right => hash_ref { '{}',
                                                                    data => leaf 'path',
                                                                },
                                                            },
                                                        },
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'h|help',
                                                    right => single_term_operator { '\\',
                                                        expr => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'help',
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                            right => branch { '=>',
                                                left => leaf 'v|version',
                                                right => single_term_operator { '\\',
                                                    expr => branch { '->',
                                                        left => leaf '$self',
                                                        right => hash_ref { '{}',
                                                            data => leaf 'version',
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'default-middleware!',
                                            right => single_term_operator { '\\',
                                                expr => branch { '->',
                                                    left => leaf '$self',
                                                    right => hash_ref { '{}',
                                                        data => leaf 'default_middleware',
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        ],
                    },
                },
                list { '()',
                    data => branch { ',',
                        left => leaf '@options',
                        right => leaf '@argv',
                    },
                },
                while_stmt { 'while',
                    expr => function_call { 'defined',
                        args => [
                            branch { '=',
                                left => leaf '$arg',
                                right => function_call { 'shift',
                                    args => [
                                        leaf '@ARGV',
                                    ],
                                },
                            },
                        ],
                    },
                    true_stmt => if_stmt { 'if',
                        expr => branch { '=~',
                            left => leaf '$arg',
                            right => reg_replace { 's',
                                to => leaf '',
                                from => leaf '^--?',
                            },
                        },
                        true_stmt => [
                            branch { '=',
                                left => leaf '@v',
                                right => function_call { 'split',
                                    args => [
                                        branch { ',',
                                            left => branch { ',',
                                                left => leaf '=',
                                                right => leaf '$arg',
                                            },
                                            right => leaf '2',
                                        },
                                    ],
                                },
                            },
                            branch { '=~',
                                left => array { '$v',
                                    idx => array_ref { '[]',
                                        data => leaf '0',
                                    },
                                },
                                right => reg_replace { 'tr',
                                    to => leaf '_',
                                    from => leaf '-',
                                },
                            },
                            if_stmt { 'if',
                                expr => branch { '==',
                                    left => leaf '@v',
                                    right => leaf '2',
                                },
                                true_stmt => function_call { 'push',
                                    args => [
                                        branch { ',',
                                            left => leaf '@options',
                                            right => leaf '@v',
                                        },
                                    ],
                                },
                                false_stmt => if_stmt { 'elsif',
                                    expr => branch { '=~',
                                        left => array { '$v',
                                            idx => array_ref { '[]',
                                                data => leaf '0',
                                            },
                                        },
                                        right => reg_replace { 's',
                                            to => leaf '',
                                            from => leaf '^(disable|enable)_',
                                        },
                                    },
                                    true_stmt => function_call { 'push',
                                        args => [
                                            branch { ',',
                                                left => branch { ',',
                                                    left => leaf '@options',
                                                    right => array { '$v',
                                                        idx => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                },
                                                right => branch { 'eq',
                                                    left => leaf '$1',
                                                    right => leaf 'enable',
                                                },
                                            },
                                        ],
                                    },
                                    false_stmt => else_stmt { 'else',
                                        stmt => function_call { 'push',
                                            args => [
                                                branch { ',',
                                                    left => branch { ',',
                                                        left => leaf '@options',
                                                        right => array { '$v',
                                                            idx => array_ref { '[]',
                                                                data => leaf '0',
                                                            },
                                                        },
                                                    },
                                                    right => function_call { 'shift',
                                                        args => [
                                                            leaf '@ARGV',
                                                        ],
                                                    },
                                                },
                                            ],
                                        },
                                    },
                                },
                            },
                        ],
                        false_stmt => else_stmt { 'else',
                            stmt => function_call { 'push',
                                args => [
                                    branch { ',',
                                        left => leaf '@argv',
                                        right => leaf '$arg',
                                    },
                                ],
                            },
                        },
                    },
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => leaf '@options',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'mangle_host_port_socket',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => leaf '$host',
                                                        right => leaf '$port',
                                                    },
                                                    right => leaf '$socket',
                                                },
                                                right => leaf '@listen',
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'daemonize',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => leaf '@options',
                                right => branch { '=>',
                                    left => leaf 'daemonize',
                                    right => leaf '1',
                                },
                            },
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'options',
                        },
                    },
                    right => single_term_operator { '\\',
                        expr => leaf '@options',
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'argv',
                        },
                    },
                    right => single_term_operator { '\\',
                        expr => leaf '@argv',
                    },
                },
            ],
        },
        function { 'set_options',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => dereference { '@{',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'options',
                                    },
                                },
                            },
                            right => leaf '@_',
                        },
                    ],
                },
            ],
        },
        function { 'mangle_host_port_socket',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => branch { ',',
                                        left => leaf '$self',
                                        right => leaf '$host',
                                    },
                                    right => leaf '$port',
                                },
                                right => leaf '$socket',
                            },
                            right => leaf '@listen',
                        },
                    },
                    right => leaf '@_',
                },
                foreach_stmt { 'for',
                    cond => function_call { 'reverse',
                        args => [
                            leaf '@listen',
                        ],
                    },
                    true_stmt => if_stmt { 'if',
                        expr => branch { '=~',
                            left => leaf '$listen',
                            right => regexp { ':\d+$',
                            },
                        },
                        true_stmt => [
                            branch { '=',
                                left => list { '()',
                                    data => branch { ',',
                                        left => leaf '$host',
                                        right => leaf '$port',
                                    },
                                },
                                right => function_call { 'split',
                                    args => [
                                        branch { ',',
                                            left => branch { ',',
                                                left => regexp { ':',
                                                },
                                                right => leaf '$listen',
                                            },
                                            right => leaf '2',
                                        },
                                    ],
                                },
                            },
                            if_stmt { 'if',
                                expr => branch { 'eq',
                                    left => leaf '$host',
                                    right => leaf '',
                                },
                                true_stmt => branch { '=',
                                    left => leaf '$host',
                                    right => leaf 'undef',
                                },
                            },
                        ],
                        false_stmt => else_stmt { 'else',
                            stmt => branch { '||=',
                                left => leaf '$socket',
                                right => leaf '$listen',
                            },
                        },
                    },
                    itr => leaf '$listen',
                },
                if_stmt { 'unless',
                    expr => leaf '@listen',
                    true_stmt => if_stmt { 'if',
                        expr => leaf '$socket',
                        true_stmt => branch { '=',
                            left => leaf '@listen',
                            right => list { '()',
                                data => leaf '$socket',
                            },
                        },
                        false_stmt => else_stmt { 'else',
                            stmt => [
                                branch { '||=',
                                    left => leaf '$port',
                                    right => leaf '5000',
                                },
                                branch { '=',
                                    left => leaf '@listen',
                                    right => list { '()',
                                        data => three_term_operator { '?',
                                            cond => leaf '$host',
                                            true_expr => leaf '$host:$port',
                                            false_expr => leaf ':$port',
                                        },
                                    },
                                },
                            ],
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { ',',
                        left => branch { ',',
                            left => branch { ',',
                                left => branch { '=>',
                                    left => leaf 'host',
                                    right => leaf '$host',
                                },
                                right => branch { '=>',
                                    left => leaf 'port',
                                    right => leaf '$port',
                                },
                            },
                            right => branch { '=>',
                                left => leaf 'listen',
                                right => single_term_operator { '\\',
                                    expr => leaf '@listen',
                                },
                            },
                        },
                        right => branch { '=>',
                            left => leaf 'socket',
                            right => leaf '$socket',
                        },
                    },
                },
            ],
        },
        function { 'version_cb',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '||',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'version_cb',
                        },
                    },
                    right => function { 'sub',
                        body => [
                            module { 'Plack',
                            },
                            function_call { 'print',
                                args => [
                                    leaf 'Plack $Plack::VERSION\n',
                                ],
                            },
                        ],
                    },
                },
            ],
        },
        function { 'setup',
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
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'help',
                        },
                    },
                    true_stmt => [
                        module { 'Pod::Usage',
                        },
                        function_call { 'Pod::Usage::pod2usage',
                            args => [
                                leaf '0',
                            ],
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'version',
                        },
                    },
                    true_stmt => [
                        branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'version_cb',
                                    args => [
                                    ],
                                },
                            },
                            right => list { '()',
                            },
                        },
                        function_call { 'exit',
                            args => [
                            ],
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => dereference { '@{',
                        expr => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'includes',
                            },
                        },
                    },
                    true_stmt => [
                        module { 'lib',
                        },
                        branch { '->',
                            left => leaf 'lib',
                            right => function_call { 'import',
                                args => [
                                    dereference { '@{',
                                        expr => branch { '->',
                                            left => leaf '$self',
                                            right => hash_ref { '{}',
                                                data => leaf 'includes',
                                            },
                                        },
                                    },
                                ],
                            },
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'eval',
                        },
                    },
                    true_stmt => function_call { 'push',
                        args => [
                            branch { ',',
                                left => dereference { '@{',
                                    expr => branch { '->',
                                        left => leaf '$self',
                                        right => hash_ref { '{}',
                                            data => leaf 'modules',
                                        },
                                    },
                                },
                                right => leaf 'Plack::Builder',
                            },
                        ],
                    },
                },
                foreach_stmt { 'for',
                    cond => dereference { '@{',
                        expr => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'modules',
                            },
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => list { '()',
                                data => branch { ',',
                                    left => leaf '$module',
                                    right => leaf '@import',
                                },
                            },
                            right => function_call { 'split',
                                args => [
                                    regexp { '[=,]',
                                    },
                                ],
                            },
                        },
                        branch { 'or',
                            left => function_call { 'eval',
                                args => [
                                    leaf 'require $module',
                                ],
                            },
                            right => function_call { 'die',
                                args => [
                                    leaf '$@',
                                ],
                            },
                        },
                        branch { '->',
                            left => leaf '$module',
                            right => function_call { 'import',
                                args => [
                                    leaf '@import',
                                ],
                            },
                        },
                    ],
                },
            ],
        },
        function { 'locate_app',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '@args',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$psgi',
                    right => branch { '||',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'app',
                            },
                        },
                        right => array { '$args',
                            idx => array_ref { '[]',
                                data => leaf '0',
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                leaf '$psgi',
                            ],
                        },
                        right => leaf 'CODE',
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => function { 'sub',
                            body => hash_ref { '{}',
                                data => leaf '$psgi',
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'eval',
                        },
                    },
                    true_stmt => [
                        branch { '->',
                            left => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'loader',
                                    args => [
                                    ],
                                },
                            },
                            right => function_call { 'watch',
                                args => [
                                    leaf 'lib',
                                ],
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => function_call { 'build',
                                args => [
                                    [
                                        function_call { 'no',
                                            args => [
                                                leaf 'strict',
                                            ],
                                        },
                                        function_call { 'no',
                                            args => [
                                                leaf 'warnings',
                                            ],
                                        },
                                        branch { '=',
                                            left => leaf '$eval',
                                            right => leaf 'builder { $self->{eval};',
                                        },
                                        if_stmt { 'if',
                                            expr => leaf '$psgi',
                                            true_stmt => branch { '.=',
                                                left => leaf '$eval',
                                                right => leaf 'Plack::Util::load_psgi(\$psgi);',
                                            },
                                        },
                                        branch { '.=',
                                            left => leaf '$eval',
                                            right => leaf '}',
                                        },
                                        branch { 'or',
                                            left => function_call { 'eval',
                                                args => [
                                                    leaf '$eval',
                                                ],
                                            },
                                            right => function_call { 'die',
                                                args => [
                                                    leaf '$@',
                                                ],
                                            },
                                        },
                                    ],
                                ],
                            },
                        },
                    ],
                },
                branch { '||=',
                    left => leaf '$psgi',
                    right => leaf 'app.psgi',
                },
                module { 'File::Basename',
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'loader',
                            args => [
                            ],
                        },
                    },
                    right => function_call { 'watch',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => branch { '.',
                                        left => function_call { 'File::Basename::dirname',
                                            args => [
                                                leaf '$psgi',
                                            ],
                                        },
                                        right => leaf '/lib',
                                    },
                                    right => leaf '$psgi',
                                },
                            },
                        ],
                    },
                },
                function_call { 'build',
                    args => [
                        function_call { 'Plack::Util::load_psgi',
                            args => [
                                leaf '$psgi',
                            ],
                        },
                    ],
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
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'loader',
                            },
                        },
                        right => leaf 'Restarter',
                    },
                    true_stmt => function_call { 'push',
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
                },
            ],
        },
        function { 'apply_middleware',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => leaf '$self',
                                    right => leaf '$app',
                                },
                                right => leaf '$class',
                            },
                            right => leaf '@args',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$mw_class',
                    right => function_call { 'Plack::Util::load_class',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => leaf '$class',
                                    right => leaf 'Plack::Middleware',
                                },
                            },
                        ],
                    },
                },
                function_call { 'build',
                    args => [
                        branch { '->',
                            left => leaf '$mw_class',
                            right => function_call { 'wrap',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => array { '$_',
                                                idx => array_ref { '[]',
                                                    data => leaf '0',
                                                },
                                            },
                                            right => leaf '@args',
                                        },
                                    },
                                ],
                            },
                        },
                        leaf '$app',
                    ],
                },
            ],
        },
        function { 'prepare_devel',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$app',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'default_middleware',
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$app',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'apply_middleware',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => leaf '$app',
                                                right => leaf 'Lint',
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                        branch { '=',
                            left => leaf '$app',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'apply_middleware',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => leaf '$app',
                                                right => leaf 'StackTrace',
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                        if_stmt { 'if',
                            expr => branch { 'and',
                                left => single_term_operator { '!',
                                    expr => hash { '$ENV',
                                        key => hash_ref { '{}',
                                            data => leaf 'GATEWAY_INTERFACE',
                                        },
                                    },
                                },
                                right => single_term_operator { '!',
                                    expr => branch { '->',
                                        left => leaf '$self',
                                        right => hash_ref { '{}',
                                            data => leaf 'access_log',
                                        },
                                    },
                                },
                            },
                            true_stmt => branch { '=',
                                left => leaf '$app',
                                right => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'apply_middleware',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$app',
                                                    right => leaf 'AccessLog',
                                                },
                                            },
                                        ],
                                    },
                                },
                            },
                        },
                    ],
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => dereference { '@{',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'options',
                                    },
                                },
                            },
                            right => branch { '=>',
                                left => leaf 'server_ready',
                                right => function { 'sub',
                                    body => [
                                        branch { '=',
                                            left => list { '()',
                                                data => leaf '$args',
                                            },
                                            right => leaf '@_',
                                        },
                                        branch { '=',
                                            left => leaf '$name',
                                            right => branch { '||',
                                                left => branch { '->',
                                                    left => leaf '$args',
                                                    right => hash_ref { '{}',
                                                        data => leaf 'server_software',
                                                    },
                                                },
                                                right => function_call { 'ref',
                                                    args => [
                                                        leaf '$args',
                                                    ],
                                                },
                                            },
                                        },
                                        branch { '=',
                                            left => leaf '$host',
                                            right => branch { '||',
                                                left => branch { '->',
                                                    left => leaf '$args',
                                                    right => hash_ref { '{}',
                                                        data => leaf 'host',
                                                    },
                                                },
                                                right => leaf '0',
                                            },
                                        },
                                        branch { '=',
                                            left => leaf '$proto',
                                            right => branch { '||',
                                                left => branch { '->',
                                                    left => leaf '$args',
                                                    right => hash_ref { '{}',
                                                        data => leaf 'proto',
                                                    },
                                                },
                                                right => leaf 'http',
                                            },
                                        },
                                        function_call { 'print',
                                            args => [
                                                handle { 'STDERR',
                                                    expr => leaf '$name: Accepting connections at $proto://$host:$args->{port}/\n',
                                                },
                                            ],
                                        },
                                    ],
                                },
                            },
                        },
                    ],
                },
                leaf '$app',
            ],
        },
        function { 'loader',
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
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf '_loader',
                        },
                    },
                    right => branch { '->',
                        left => function_call { 'Plack::Util::load_class',
                            args => [
                                list { '()',
                                    data => branch { ',',
                                        left => branch { '->',
                                            left => leaf '$self',
                                            right => hash_ref { '{}',
                                                data => leaf 'loader',
                                            },
                                        },
                                        right => leaf 'Plack::Loader',
                                    },
                                },
                            ],
                        },
                        right => function_call { 'new',
                            args => [
                            ],
                        },
                    },
                },
            ],
        },
        function { 'load_server',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$loader',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'server',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => leaf '$loader',
                            right => function_call { 'load',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => branch { '->',
                                                left => leaf '$self',
                                                right => hash_ref { '{}',
                                                    data => leaf 'server',
                                                },
                                            },
                                            right => dereference { '@{',
                                                expr => branch { '->',
                                                    left => leaf '$self',
                                                    right => hash_ref { '{}',
                                                        data => leaf 'options',
                                                    },
                                                },
                                            },
                                        },
                                    },
                                ],
                            },
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => branch { '->',
                                left => leaf '$loader',
                                right => function_call { 'auto',
                                    args => [
                                        dereference { '@{',
                                            expr => branch { '->',
                                                left => leaf '$self',
                                                right => hash_ref { '{}',
                                                    data => leaf 'options',
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                    },
                },
            ],
        },
        function { 'run',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'ref',
                        args => [
                            leaf '$self',
                        ],
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$self',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'new',
                                    args => [
                                    ],
                                },
                            },
                        },
                        branch { '->',
                            left => leaf '$self',
                            right => function_call { 'parse_options',
                                args => [
                                    leaf '@_',
                                ],
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'run',
                                    args => [
                                    ],
                                },
                            },
                        },
                    ],
                },
                if_stmt { 'unless',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'options',
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'parse_options',
                            args => [
                                list { '()',
                                },
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '@args',
                    right => three_term_operator { '?',
                        cond => leaf '@_',
                        true_expr => leaf '@_',
                        false_expr => dereference { '@{',
                            expr => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'argv',
                                },
                            },
                        },
                    },
                },
                branch { '->',
                    left => leaf '$self',
                    right => function_call { 'setup',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$app',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'locate_app',
                            args => [
                                leaf '@args',
                            ],
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'path',
                        },
                    },
                    true_stmt => [
                        module { 'Plack::App::URLMap',
                        },
                        branch { '=',
                            left => leaf '$app',
                            right => function_call { 'build',
                                args => [
                                    [
                                        branch { '=',
                                            left => leaf '$urlmap',
                                            right => branch { '->',
                                                left => leaf 'Plack::App::URLMap',
                                                right => function_call { 'new',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        },
                                        branch { '->',
                                            left => leaf '$urlmap',
                                            right => function_call { 'mount',
                                                args => [
                                                    list { '()',
                                                        data => branch { '=>',
                                                            left => branch { '->',
                                                                left => leaf '$self',
                                                                right => hash_ref { '{}',
                                                                    data => leaf 'path',
                                                                },
                                                            },
                                                            right => array { '$_',
                                                                idx => array_ref { '[]',
                                                                    data => leaf '0',
                                                                },
                                                            },
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                        branch { '->',
                                            left => leaf '$urlmap',
                                            right => function_call { 'to_app',
                                                args => [
                                                ],
                                            },
                                        },
                                    ],
                                    leaf '$app',
                                ],
                            },
                        },
                    ],
                },
                branch { '||=',
                    left => hash { '$ENV',
                        key => hash_ref { '{}',
                            data => leaf 'PLACK_ENV',
                        },
                    },
                    right => branch { '||',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'env',
                            },
                        },
                        right => leaf 'development',
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => hash { '$ENV',
                            key => hash_ref { '{}',
                                data => leaf 'PLACK_ENV',
                            },
                        },
                        right => leaf 'development',
                    },
                    true_stmt => branch { '=',
                        left => leaf '$app',
                        right => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'prepare_devel',
                                args => [
                                    leaf '$app',
                                ],
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'access_log',
                        },
                    },
                    true_stmt => [
                        branch { 'or',
                            left => function_call { 'open',
                                args => [
                                    branch { ',',
                                        left => branch { ',',
                                            left => leaf '$logfh',
                                            right => leaf '>>',
                                        },
                                        right => branch { '->',
                                            left => leaf '$self',
                                            right => hash_ref { '{}',
                                                data => leaf 'access_log',
                                            },
                                        },
                                    },
                                ],
                            },
                            right => function_call { 'die',
                                args => [
                                    leaf 'open($self->{access_log}): $!',
                                ],
                            },
                        },
                        branch { '->',
                            left => leaf '$logfh',
                            right => function_call { 'autoflush',
                                args => [
                                    leaf '1',
                                ],
                            },
                        },
                        branch { '=',
                            left => leaf '$app',
                            right => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'apply_middleware',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => branch { ',',
                                                    left => leaf '$app',
                                                    right => leaf 'AccessLog',
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'logger',
                                                    right => function { 'sub',
                                                        body => branch { '->',
                                                            left => leaf '$logfh',
                                                            right => function_call { 'print',
                                                                args => [
                                                                    leaf '@_',
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
                        },
                    ],
                },
                branch { '=',
                    left => leaf '$loader',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'loader',
                            args => [
                            ],
                        },
                    },
                },
                branch { '->',
                    left => leaf '$loader',
                    right => function_call { 'preload_app',
                        args => [
                            leaf '$app',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$server',
                    right => branch { '->',
                        left => leaf '$self',
                        right => function_call { 'load_server',
                            args => [
                                leaf '$loader',
                            ],
                        },
                    },
                },
                branch { '->',
                    left => leaf '$loader',
                    right => function_call { 'run',
                        args => [
                            leaf '$server',
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
package Plack::Runner;
use strict;
use warnings;
use Carp ();
use Plack::Util;
use Try::Tiny;

sub new {
    my $class = shift;
    bless {
        env      => $ENV{PLACK_ENV},
        loader   => 'Plack::Loader',
        includes => [],
        modules  => [],
        default_middleware => 1,
        @_,
    }, $class;
}

# delay the build process for reloader
sub build(&;$) {
    my $block = shift;
    my $app   = shift || sub { };
    return sub { $block->($app->()) };
}

sub parse_options {
    my $self = shift;

    local @ARGV = @_;

    # From 'prove': Allow cuddling the paths with -I, -M and -e
    @ARGV = map { /^(-[IMe])(.+)/ ? ($1,$2) : $_ } @ARGV;

    my($host, $port, $socket, @listen);

    require Getopt::Long;
    my $parser = Getopt::Long::Parser->new(
        config => [ "no_auto_abbrev", "no_ignore_case", "pass_through" ],
    );

    $parser->getoptions(
        "a|app=s"      => \$self->{app},
        "o|host=s"     => \$host,
        "p|port=i"     => \$port,
        "s|server=s"   => \$self->{server},
        "S|socket=s"   => \$socket,
        'l|listen=s@'  => \@listen,
        'D|daemonize'  => \$self->{daemonize},
        "E|env=s"      => \$self->{env},
        "e=s"          => \$self->{eval},
        'I=s@'         => $self->{includes},
        'M=s@'         => $self->{modules},
        'r|reload'     => sub { $self->{loader} = "Restarter" },
        'R|Reload=s'   => sub { $self->{loader} = "Restarter"; $self->loader->watch(split ",", $_[1]) },
        'L|loader=s'   => \$self->{loader},
        "access-log=s" => \$self->{access_log},
        "path=s"       => \$self->{path},
        "h|help"       => \$self->{help},
        "v|version"    => \$self->{version},
        "default-middleware!" => \$self->{default_middleware},
    );

    my(@options, @argv);
    while (defined(my $arg = shift @ARGV)) {
        if ($arg =~ s/^--?//) {
            my @v = split '=', $arg, 2;
            $v[0] =~ tr/-/_/;
            if (@v == 2) {
                push @options, @v;
            } elsif ($v[0] =~ s/^(disable|enable)_//) {
                push @options, $v[0], $1 eq 'enable';
            } else {
                push @options, $v[0], shift @ARGV;
            }
        } else {
            push @argv, $arg;
        }
    }

    push @options, $self->mangle_host_port_socket($host, $port, $socket, @listen);
    push @options, daemonize => 1 if $self->{daemonize};

    $self->{options} = \@options;
    $self->{argv}    = \@argv;
}

sub set_options {
    my $self = shift;
    push @{$self->{options}}, @_;
}

sub mangle_host_port_socket {
    my($self, $host, $port, $socket, @listen) = @_;

    for my $listen (reverse @listen) {
        if ($listen =~ /:\d+$/) {
            ($host, $port) = split /:/, $listen, 2;
            $host = undef if $host eq '';
        } else {
            $socket ||= $listen;
        }
    }

    unless (@listen) {
        if ($socket) {
            @listen = ($socket);
        } else {
            $port ||= 5000;
            @listen = ($host ? "$host:$port" : ":$port");
        }
    }

    return host => $host, port => $port, listen => \@listen, socket => $socket;
}

sub version_cb {
    my $self = shift;
    $self->{version_cb} || sub {
        require Plack;
        print "Plack $Plack::VERSION\n";
    };
}

sub setup {
    my $self = shift;

    if ($self->{help}) {
        require Pod::Usage;
        Pod::Usage::pod2usage(0);
    }

    if ($self->{version}) {
        $self->version_cb->();
        exit;
    }

    if (@{$self->{includes}}) {
        require lib;
        lib->import(@{$self->{includes}});
    }

    if ($self->{eval}) {
        push @{$self->{modules}}, 'Plack::Builder';
    }

    for (@{$self->{modules}}) {
        my($module, @import) = split /[=,]/;
        eval "require $module" or die $@;
        $module->import(@import);
    }
}

sub locate_app {
    my($self, @args) = @_;

    my $psgi = $self->{app} || $args[0];

    if (ref $psgi eq 'CODE') {
        return sub { $psgi };
    }

    if ($self->{eval}) {
        $self->loader->watch("lib");
        return build {
            no strict;
            no warnings;
            my $eval = "builder { $self->{eval};";
            $eval .= "Plack::Util::load_psgi(\$psgi);" if $psgi;
            $eval .= "}";
            eval $eval or die $@;
        };
    }

    $psgi ||= "app.psgi";

    require File::Basename;
    $self->loader->watch( File::Basename::dirname($psgi) . "/lib", $psgi );
    build { Plack::Util::load_psgi $psgi };
}

sub watch {
    my($self, @dir) = @_;

    push @{$self->{watch}}, @dir
        if $self->{loader} eq 'Restarter';
}

sub apply_middleware {
    my($self, $app, $class, @args) = @_;

    my $mw_class = Plack::Util::load_class($class, 'Plack::Middleware');
    build { $mw_class->wrap($_[0], @args) } $app;
}

sub prepare_devel {
    my($self, $app) = @_;

    if ($self->{default_middleware}) {
        $app = $self->apply_middleware($app, 'Lint');
        $app = $self->apply_middleware($app, 'StackTrace');
        if (!$ENV{GATEWAY_INTERFACE} and !$self->{access_log}) {
            $app = $self->apply_middleware($app, 'AccessLog');
        }
    }

    push @{$self->{options}}, server_ready => sub {
        my($args) = @_;
        my $name  = $args->{server_software} || ref($args); # $args is $server
        my $host  = $args->{host} || 0;
        my $proto = $args->{proto} || 'http';
        print STDERR "$name: Accepting connections at $proto://$host:$args->{port}/\n";
    };

    $app;
}

sub loader {
    my $self = shift;
    $self->{_loader} ||= Plack::Util::load_class($self->{loader}, 'Plack::Loader')->new;
}

sub load_server {
    my($self, $loader) = @_;

    if ($self->{server}) {
        return $loader->load($self->{server}, @{$self->{options}});
    } else {
        return $loader->auto(@{$self->{options}});
    }
}

sub run {
    my $self = shift;

    unless (ref $self) {
        $self = $self->new;
        $self->parse_options(@_);
        return $self->run;
    }

    unless ($self->{options}) {
        $self->parse_options();
    }

    my @args = @_ ? @_ : @{$self->{argv}};

    $self->setup;

    my $app = $self->locate_app(@args);

    if ($self->{path}) {
        require Plack::App::URLMap;
        $app = build {
            my $urlmap = Plack::App::URLMap->new;
            $urlmap->mount($self->{path} => $_[0]);
            $urlmap->to_app;
        } $app;
    }

    $ENV{PLACK_ENV} ||= $self->{env} || 'development';
    if ($ENV{PLACK_ENV} eq 'development') {
        $app = $self->prepare_devel($app);
    }

    if ($self->{access_log}) {
        open my $logfh, ">>", $self->{access_log}
            or die "open($self->{access_log}): $!";
        $logfh->autoflush(1);
        $app = $self->apply_middleware($app, 'AccessLog', logger => sub { $logfh->print( @_ ) });
    }

    my $loader = $self->loader;
    $loader->preload_app($app);

    my $server = $self->load_server($loader);
    $loader->run($server);
}

1;

__END__

=head1 NAME

Plack::Runner - plackup core

=head1 SYNOPSIS

  # Your bootstrap script
  use Plack::Runner;
  my $app = sub { ... };

  my $runner = Plack::Runner->new;
  $runner->parse_options(@ARGV);
  $runner->run($app);

=head1 DESCRIPTION

Plack::Runner is the core of L<plackup> runner script. You can create
your own frontend to run your application or framework, munge command
line options and pass that to C<run> method of this class.

C<run> method does exactly the same thing as the L<plackup> script
does, but one notable addition is that you can pass a PSGI application
code reference directly to the method, rather than via C<.psgi>
file path or with C<-e> switch. This would be useful if you want to
make an installable PSGI application.

Also, when C<-h> or C<--help> switch is passed, the usage text is
automatically extracted from your own script using L<Pod::Usage>.

=head1 NOTES

Do not directly call this module from your C<.psgi>, since that makes
your PSGI application unnecessarily depend on L<plackup> and won't run
other backends like L<Plack::Handler::Apache2> or mod_psgi.

If you I<really> want to make your C<.psgi> runnable as a standalone
script, you can do this:

  my $app = sub { ... };

  unless (caller) {
      require Plack::Runner;
      my $runner = Plack::Runner->new;
      $runner->parse_options(@ARGV);
      return $runner->run($app);
  }

  return $app;

B<WARNING>: this section used to recommend C<if (__FILE__ eq $0)> but
it's known to be broken since Plack 0.9971, since C<$0> is now
I<always> set to the .psgi file path even when you run it from
plackup.

=head1 SEE ALSO

L<plackup>

=cut



