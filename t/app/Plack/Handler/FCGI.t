use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Handler/FCGI.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Handler::FCGI',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'constant',
            args => branch { '=>',
                left => leaf 'RUNNING_IN_HELL',
                right => branch { 'eq',
                    left => leaf '$^O',
                    right => leaf 'MSWin32',
                },
            },
        },
        module { 'Scalar::Util',
            args => reg_prefix { 'qw',
                expr => leaf 'blessed',
            },
        },
        module { 'Plack::Util',
        },
        module { 'FCGI',
        },
        module { 'HTTP::Status',
            args => reg_prefix { 'qw',
                expr => leaf 'status_message',
            },
        },
        module { 'URI',
        },
        module { 'URI::Escape',
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
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'bless',
                        args => [
                            branch { ',',
                                left => hash_ref { '{}',
                                    data => leaf '@_',
                                },
                                right => leaf '$class',
                            },
                        ],
                    },
                },
                branch { '||=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'leave_umask',
                        },
                    },
                    right => leaf '0',
                },
                branch { '||=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'keep_stderr',
                        },
                    },
                    right => leaf '0',
                },
                branch { '||=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'nointr',
                        },
                    },
                    right => leaf '0',
                },
                branch { '||=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'daemonize',
                        },
                    },
                    right => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'detach',
                        },
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'blessed',
                        args => [
                            branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'manager',
                                },
                            },
                        ],
                    },
                    true_stmt => branch { '||=',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'nproc',
                            },
                        },
                        right => leaf '1',
                    },
                },
                branch { '||=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'pid',
                        },
                    },
                    right => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'pidfile',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'port',
                        },
                    },
                    true_stmt => branch { '||=',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'listen',
                            },
                        },
                        right => array_ref { '[]',
                            data => leaf ':$self->{port}',
                        },
                    },
                },
                branch { '||=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'backlog',
                        },
                    },
                    right => leaf '100',
                },
                if_stmt { 'unless',
                    expr => function_call { 'exists',
                        args => [
                            branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'manager',
                                },
                            },
                        ],
                    },
                    true_stmt => branch { '=',
                        left => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'manager',
                            },
                        },
                        right => leaf 'FCGI::ProcManager',
                    },
                },
                leaf '$self',
            ],
        },
        function { 'run',
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
                branch { '=',
                    left => leaf '$sock',
                    right => leaf '0',
                },
                if_stmt { 'if',
                    expr => handle { '-S',
                        expr => handle { 'STDIN',
                        },
                    },
                    true_stmt => hash_ref { '{}',
                    },
                    false_stmt => if_stmt { 'elsif',
                        expr => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'listen',
                            },
                        },
                        true_stmt => [
                            branch { '=',
                                left => leaf '$old_umask',
                                right => function_call { 'umask',
                                    args => [
                                    ],
                                },
                            },
                            if_stmt { 'unless',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'leave_umask',
                                    },
                                },
                                true_stmt => function_call { 'umask',
                                    args => [
                                        leaf '0',
                                    ],
                                },
                            },
                            branch { 'or',
                                left => branch { '=',
                                    left => leaf '$sock',
                                    right => function_call { 'FCGI::OpenSocket',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => branch { '->',
                                                        left => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'listen',
                                                            },
                                                        },
                                                        right => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                    right => branch { '->',
                                                        left => leaf '$self',
                                                        right => hash_ref { '{}',
                                                            data => leaf 'backlog',
                                                        },
                                                    },
                                                },
                                            },
                                        ],
                                    },
                                },
                                right => function_call { 'die',
                                    args => [
                                        leaf 'failed to open FastCGI socket: $!',
                                    ],
                                },
                            },
                            if_stmt { 'unless',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'leave_umask',
                                    },
                                },
                                true_stmt => function_call { 'umask',
                                    args => [
                                        leaf '$old_umask',
                                    ],
                                },
                                false_stmt => if_stmt { 'elsif',
                                    expr => single_term_operator { '!',
                                        expr => leaf 'RUNNING_IN_HELL',
                                    },
                                    true_stmt => function_call { 'die',
                                        args => [
                                            leaf 'STDIN is not a socket: specify a listen location',
                                        ],
                                    },
                                },
                            },
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => dereference { '@{',
                            expr => leaf '$self',
                        },
                        right => hash_ref { '{}',
                            data => reg_prefix { 'qw',
                                expr => leaf 'stdin stdout stderr',
                            },
                        },
                    },
                    right => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { '->',
                                    left => leaf 'IO::Handle',
                                    right => function_call { 'new',
                                        args => [
                                        ],
                                    },
                                },
                                right => branch { '->',
                                    left => leaf 'IO::Handle',
                                    right => function_call { 'new',
                                        args => [
                                        ],
                                    },
                                },
                            },
                            right => branch { '->',
                                left => leaf 'IO::Handle',
                                right => function_call { 'new',
                                    args => [
                                    ],
                                },
                            },
                        },
                    },
                },
                leaf '%env',
                branch { '=',
                    left => leaf '$request',
                    right => function_call { 'FCGI::Request',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'stdin',
                                                            },
                                                        },
                                                        right => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'stdout',
                                                            },
                                                        },
                                                    },
                                                    right => three_term_operator { '?',
                                                        cond => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'keep_stderr',
                                                            },
                                                        },
                                                        true_expr => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'stdout',
                                                            },
                                                        },
                                                        false_expr => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf 'stderr',
                                                            },
                                                        },
                                                    },
                                                },
                                                right => single_term_operator { '\\',
                                                    expr => leaf '%env',
                                                },
                                            },
                                            right => leaf '$sock',
                                        },
                                        right => three_term_operator { '?',
                                            cond => branch { '->',
                                                left => leaf '$self',
                                                right => hash_ref { '{}',
                                                    data => leaf 'nointr',
                                                },
                                            },
                                            true_expr => leaf '0',
                                            false_expr => single_term_operator { '&',
                                                expr => function_call { 'FCGI::FAIL_ACCEPT_ON_INTR',
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
                },
                leaf '$proc_manager',
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'listen',
                        },
                    },
                    true_stmt => [
                        if_stmt { 'if',
                            expr => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'daemonize',
                                },
                            },
                            true_stmt => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'daemon_fork',
                                    args => [
                                    ],
                                },
                            },
                        },
                        if_stmt { 'if',
                            expr => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'manager',
                                },
                            },
                            true_stmt => [
                                if_stmt { 'if',
                                    expr => function_call { 'blessed',
                                        args => [
                                            branch { '->',
                                                left => leaf '$self',
                                                right => hash_ref { '{}',
                                                    data => leaf 'manager',
                                                },
                                            },
                                        ],
                                    },
                                    true_stmt => [
                                        foreach_stmt { 'for',
                                            cond => reg_prefix { 'qw',
                                                expr => leaf 'nproc pid proc_title',
                                            },
                                            true_stmt => if_stmt { 'if',
                                                expr => branch { '->',
                                                    left => leaf '$self',
                                                    right => hash_ref { '{}',
                                                        data => leaf '$_',
                                                    },
                                                },
                                                true_stmt => function_call { 'die',
                                                    args => [
                                                        leaf 'Don\'t use \'$_\' when passing in a \'manager\' object',
                                                    ],
                                                },
                                            },
                                        },
                                        branch { '=',
                                            left => leaf '$proc_manager',
                                            right => branch { '->',
                                                left => leaf '$self',
                                                right => hash_ref { '{}',
                                                    data => leaf 'manager',
                                                },
                                            },
                                        },
                                    ],
                                    false_stmt => else_stmt { 'else',
                                        stmt => [
                                            function_call { 'Plack::Util::load_class',
                                                args => [
                                                    branch { '->',
                                                        left => leaf '$self',
                                                        right => hash_ref { '{}',
                                                            data => leaf 'manager',
                                                        },
                                                    },
                                                ],
                                            },
                                            branch { '=',
                                                left => leaf '$proc_manager',
                                                right => branch { '->',
                                                    left => branch { '->',
                                                        left => leaf '$self',
                                                        right => hash_ref { '{}',
                                                            data => leaf 'manager',
                                                        },
                                                    },
                                                    right => function_call { 'new',
                                                        args => [
                                                            hash_ref { '{}',
                                                                data => branch { ',',
                                                                    left => branch { ',',
                                                                        left => branch { ',',
                                                                            left => branch { '=>',
                                                                                left => leaf 'n_processes',
                                                                                right => branch { '->',
                                                                                    left => leaf '$self',
                                                                                    right => hash_ref { '{}',
                                                                                        data => leaf 'nproc',
                                                                                    },
                                                                                },
                                                                            },
                                                                            right => branch { '=>',
                                                                                left => leaf 'pid_fname',
                                                                                right => branch { '->',
                                                                                    left => leaf '$self',
                                                                                    right => hash_ref { '{}',
                                                                                        data => leaf 'pid',
                                                                                    },
                                                                                },
                                                                            },
                                                                        },
                                                                        right => three_term_operator { '?',
                                                                            cond => function_call { 'exists',
                                                                                args => [
                                                                                    branch { '->',
                                                                                        left => leaf '$self',
                                                                                        right => hash_ref { '{}',
                                                                                            data => leaf 'proc_title',
                                                                                        },
                                                                                    },
                                                                                ],
                                                                            },
                                                                            true_expr => list { '()',
                                                                                data => branch { '=>',
                                                                                    left => leaf 'pm_title',
                                                                                    right => branch { '->',
                                                                                        left => leaf '$self',
                                                                                        right => hash_ref { '{}',
                                                                                            data => leaf 'proc_title',
                                                                                        },
                                                                                    },
                                                                                },
                                                                            },
                                                                            false_expr => list { '()',
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
                                if_stmt { 'if',
                                    expr => branch { '->',
                                        left => leaf '$self',
                                        right => hash_ref { '{}',
                                            data => leaf 'daemonize',
                                        },
                                    },
                                    true_stmt => branch { '->',
                                        left => leaf '$self',
                                        right => function_call { 'daemon_detach',
                                            args => [
                                            ],
                                        },
                                    },
                                },
                                branch { '->',
                                    left => leaf '$proc_manager',
                                    right => function_call { 'pm_manage',
                                        args => [
                                        ],
                                    },
                                },
                            ],
                            false_stmt => if_stmt { 'elsif',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'daemonize',
                                    },
                                },
                                true_stmt => branch { '->',
                                    left => leaf '$self',
                                    right => function_call { 'daemon_detach',
                                        args => [
                                        ],
                                    },
                                },
                            },
                        },
                    ],
                },
                while_stmt { 'while',
                    expr => branch { '>=',
                        left => branch { '->',
                            left => leaf '$request',
                            right => function_call { 'Accept',
                                args => [
                                ],
                            },
                        },
                        right => leaf '0',
                    },
                    true_stmt => [
                        branch { '&&',
                            left => leaf '$proc_manager',
                            right => branch { '->',
                                left => leaf '$proc_manager',
                                right => function_call { 'pm_pre_dispatch',
                                    args => [
                                    ],
                                },
                            },
                        },
                        branch { '=',
                            left => leaf '$env',
                            right => hash_ref { '{}',
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
                                                                            left => leaf '%env',
                                                                            right => branch { '=>',
                                                                                left => leaf 'psgi.version',
                                                                                right => array_ref { '[]',
                                                                                    data => branch { ',',
                                                                                        left => leaf '1',
                                                                                        right => leaf '1',
                                                                                    },
                                                                                },
                                                                            },
                                                                        },
                                                                        right => branch { '=>',
                                                                            left => leaf 'psgi.url_scheme',
                                                                            right => three_term_operator { '?',
                                                                                cond => branch { '=~',
                                                                                    left => branch { '||',
                                                                                        left => hash { '$env',
                                                                                            key => hash_ref { '{}',
                                                                                                data => leaf 'HTTPS',
                                                                                            },
                                                                                        },
                                                                                        right => leaf 'off',
                                                                                    },
                                                                                    right => regexp { '^(?:on|1)$',
                                                                                        option => leaf 'i',
                                                                                    },
                                                                                },
                                                                                true_expr => leaf 'https',
                                                                                false_expr => leaf 'http',
                                                                            },
                                                                        },
                                                                    },
                                                                    right => branch { '=>',
                                                                        left => leaf 'psgi.input',
                                                                        right => branch { '->',
                                                                            left => leaf '$self',
                                                                            right => hash_ref { '{}',
                                                                                data => leaf 'stdin',
                                                                            },
                                                                        },
                                                                    },
                                                                },
                                                                right => branch { '=>',
                                                                    left => leaf 'psgi.errors',
                                                                    right => branch { '->',
                                                                        left => leaf '$self',
                                                                        right => hash_ref { '{}',
                                                                            data => leaf 'stderr',
                                                                        },
                                                                    },
                                                                },
                                                            },
                                                            right => branch { '=>',
                                                                left => leaf 'psgi.multithread',
                                                                right => function_call { 'Plack::Util::FALSE',
                                                                    args => [
                                                                    ],
                                                                },
                                                            },
                                                        },
                                                        right => branch { '=>',
                                                            left => leaf 'psgi.multiprocess',
                                                            right => function_call { 'Plack::Util::TRUE',
                                                                args => [
                                                                ],
                                                            },
                                                        },
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'psgi.run_once',
                                                        right => function_call { 'Plack::Util::FALSE',
                                                            args => [
                                                            ],
                                                        },
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'psgi.streaming',
                                                    right => function_call { 'Plack::Util::TRUE',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                            },
                                            right => branch { '=>',
                                                left => leaf 'psgi.nonblocking',
                                                right => function_call { 'Plack::Util::FALSE',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'psgix.harakiri',
                                            right => function_call { 'defined',
                                                args => [
                                                    leaf '$proc_manager',
                                                ],
                                            },
                                        },
                                    },
                                },
                            },
                        },
                        function_call { 'delete',
                            args => [
                                branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf 'HTTP_CONTENT_TYPE',
                                    },
                                },
                            ],
                        },
                        function_call { 'delete',
                            args => [
                                branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf 'HTTP_CONTENT_LENGTH',
                                    },
                                },
                            ],
                        },
                        branch { '=',
                            left => leaf '$uri',
                            right => branch { '->',
                                left => leaf 'URI',
                                right => function_call { 'new',
                                    args => [
                                        branch { '.',
                                            left => leaf 'http://localhost',
                                            right => branch { '->',
                                                left => leaf '$env',
                                                right => hash_ref { '{}',
                                                    data => leaf 'REQUEST_URI',
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                        branch { '=',
                            left => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'PATH_INFO',
                                },
                            },
                            right => function_call { 'uri_unescape',
                                args => [
                                    branch { '->',
                                        left => leaf '$uri',
                                        right => function_call { 'path',
                                            args => [
                                            ],
                                        },
                                    },
                                ],
                            },
                        },
                        branch { '=~',
                            left => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'PATH_INFO',
                                },
                            },
                            right => reg_replace { 's',
                                to => leaf '',
                                from => leaf '^\Q$env->{SCRIPT_NAME}\E',
                            },
                        },
                        if_stmt { 'if',
                            expr => single_term_operator { '!',
                                expr => function_call { 'exists',
                                    args => [
                                        branch { '->',
                                            left => leaf '$env',
                                            right => hash_ref { '{}',
                                                data => leaf 'PATH_INFO',
                                            },
                                        },
                                    ],
                                },
                            },
                            true_stmt => branch { '=',
                                left => branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf 'PATH_INFO',
                                    },
                                },
                                right => leaf '',
                            },
                        },
                        foreach_stmt { 'for',
                            cond => reg_prefix { 'qw',
                                expr => leaf 'CONTENT_TYPE CONTENT_LENGTH',
                            },
                            true_stmt => [
                                function_call { 'no',
                                    args => [
                                        leaf 'warnings',
                                    ],
                                },
                                if_stmt { 'if',
                                    expr => branch { '&&',
                                        left => function_call { 'exists',
                                            args => [
                                                branch { '->',
                                                    left => leaf '$env',
                                                    right => hash_ref { '{}',
                                                        data => leaf '$key',
                                                    },
                                                },
                                            ],
                                        },
                                        right => branch { 'eq',
                                            left => branch { '->',
                                                left => leaf '$env',
                                                right => hash_ref { '{}',
                                                    data => leaf '$key',
                                                },
                                            },
                                            right => leaf '',
                                        },
                                    },
                                    true_stmt => function_call { 'delete',
                                        args => [
                                            branch { '->',
                                                left => leaf '$env',
                                                right => hash_ref { '{}',
                                                    data => leaf '$key',
                                                },
                                            },
                                        ],
                                    },
                                },
                            ],
                            itr => leaf '$key',
                        },
                        if_stmt { 'if',
                            expr => function_call { 'defined',
                                args => [
                                    branch { '=',
                                        left => leaf '$HTTP_AUTHORIZATION',
                                        right => branch { '->',
                                            left => leaf '$env',
                                            right => hash_ref { '{}',
                                                data => leaf 'Authorization',
                                            },
                                        },
                                    },
                                ],
                            },
                            true_stmt => branch { '=',
                                left => branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf 'HTTP_AUTHORIZATION',
                                    },
                                },
                                right => leaf '$HTTP_AUTHORIZATION',
                            },
                        },
                        branch { '=',
                            left => leaf '$res',
                            right => function_call { 'Plack::Util::run_app',
                                args => [
                                    branch { ',',
                                        left => leaf '$app',
                                        right => leaf '$env',
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
                            true_stmt => branch { '->',
                                left => leaf '$self',
                                right => function_call { '_handle_response',
                                    args => [
                                        leaf '$res',
                                    ],
                                },
                            },
                            false_stmt => if_stmt { 'elsif',
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
                                        data => function { 'sub',
                                            body => branch { '->',
                                                left => leaf '$self',
                                                right => function_call { '_handle_response',
                                                    args => [
                                                        array { '$_',
                                                            idx => array_ref { '[]',
                                                                data => leaf '0',
                                                            },
                                                        },
                                                    ],
                                                },
                                            },
                                        },
                                    },
                                },
                                false_stmt => else_stmt { 'else',
                                    stmt => function_call { 'die',
                                        args => [
                                            leaf 'Bad response $res',
                                        ],
                                    },
                                },
                            },
                        },
                        branch { '->',
                            left => leaf '$request',
                            right => function_call { 'Finish',
                                args => [
                                ],
                            },
                        },
                        branch { '&&',
                            left => leaf '$proc_manager',
                            right => branch { '->',
                                left => leaf '$proc_manager',
                                right => function_call { 'pm_post_dispatch',
                                    args => [
                                        list { '()',
                                        },
                                    ],
                                },
                            },
                        },
                        if_stmt { 'if',
                            expr => branch { '&&',
                                left => leaf '$proc_manager',
                                right => branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf 'psgix.harakiri.commit',
                                    },
                                },
                            },
                            true_stmt => branch { '->',
                                left => leaf '$proc_manager',
                                right => function_call { 'pm_exit',
                                    args => [
                                        leaf 'safe exit with harakiri',
                                    ],
                                },
                            },
                        },
                    ],
                },
            ],
        },
        function { '_handle_response',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$res',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'stdout',
                        },
                    },
                    right => function_call { 'autoflush',
                        args => [
                            leaf '1',
                        ],
                    },
                },
                function_call { 'binmode',
                    args => [
                        branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'stdout',
                            },
                        },
                    ],
                },
                leaf '$hdrs',
                branch { '=',
                    left => leaf '$message',
                    right => function_call { 'status_message',
                        args => [
                            branch { '->',
                                left => leaf '$res',
                                right => array_ref { '[]',
                                    data => leaf '0',
                                },
                            },
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$hdrs',
                    right => leaf 'Status: $res->[0] $message\015\012',
                },
                branch { '=',
                    left => leaf '$headers',
                    right => branch { '->',
                        left => leaf '$res',
                        right => array_ref { '[]',
                            data => leaf '1',
                        },
                    },
                },
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
                                        left => dereference { '@$headers',
                                            expr => leaf '@$headers',
                                        },
                                        right => leaf '0',
                                    },
                                    right => leaf '2',
                                },
                            ],
                        },
                    },
                    true_stmt => branch { '.=',
                        left => leaf '$hdrs',
                        right => leaf '$k: $v\015\012',
                    },
                },
                branch { '.=',
                    left => leaf '$hdrs',
                    right => leaf '\015\012',
                },
                function_call { 'print',
                    args => [
                        branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf 'stdout',
                            },
                        },
                        leaf '$hdrs',
                    ],
                },
                branch { '=',
                    left => leaf '$cb',
                    right => function { 'sub',
                        body => function_call { 'print',
                            args => [
                                branch { '->',
                                    left => hash_ref { '{}',
                                        data => branch { '->',
                                            left => leaf '$self',
                                            right => hash_ref { '{}',
                                                data => leaf 'stdout',
                                            },
                                        },
                                    },
                                    right => array { '$_',
                                        idx => array_ref { '[]',
                                            data => leaf '0',
                                        },
                                    },
                                },
                            ],
                        },
                    },
                },
                branch { '=',
                    left => leaf '$body',
                    right => branch { '->',
                        left => leaf '$res',
                        right => array_ref { '[]',
                            data => leaf '2',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$body',
                        ],
                    },
                    true_stmt => function_call { 'Plack::Util::foreach',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => leaf '$body',
                                    right => leaf '$cb',
                                },
                            },
                        ],
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => function_call { 'Plack::Util::inline_object',
                                args => [
                                    branch { ',',
                                        left => branch { '=>',
                                            left => leaf 'write',
                                            right => leaf '$cb',
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
                    },
                },
            ],
        },
        function { 'daemon_fork',
            body => [
                module { 'POSIX',
                },
                branch { '&&',
                    left => function_call { 'fork',
                        args => [
                        ],
                    },
                    right => function_call { 'exit',
                        args => [
                        ],
                    },
                },
            ],
        },
        function { 'daemon_detach',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                function_call { 'print',
                    args => [
                        leaf 'FastCGI daemon started (pid $$)\n',
                    ],
                },
                branch { 'or',
                    left => function_call { 'open',
                        args => [
                            branch { ',',
                                left => handle { 'STDIN',
                                },
                                right => leaf '+</dev/null',
                            },
                        ],
                    },
                    right => function_call { 'die',
                        args => [
                            leaf '$!',
                        ],
                    },
                },
                branch { 'or',
                    left => function_call { 'open',
                        args => [
                            branch { ',',
                                left => handle { 'STDOUT',
                                },
                                right => leaf '>&STDIN',
                            },
                        ],
                    },
                    right => function_call { 'die',
                        args => [
                            leaf '$!',
                        ],
                    },
                },
                branch { 'or',
                    left => function_call { 'open',
                        args => [
                            branch { ',',
                                left => handle { 'STDERR',
                                },
                                right => leaf '>&STDIN',
                            },
                        ],
                    },
                    right => function_call { 'die',
                        args => [
                            leaf '$!',
                        ],
                    },
                },
                function_call { 'POSIX::setsid',
                    args => [
                        list { '()',
                        },
                    ],
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Handler::FCGI;
use strict;
use warnings;
use constant RUNNING_IN_HELL => $^O eq 'MSWin32';

use Scalar::Util qw(blessed);
use Plack::Util;
use FCGI;
use HTTP::Status qw(status_message);
use URI;
use URI::Escape;

sub new {
    my $class = shift;
    my $self  = bless {@_}, $class;

    $self->{leave_umask} ||= 0;
    $self->{keep_stderr} ||= 0;
    $self->{nointr}      ||= 0;
    $self->{daemonize}   ||= $self->{detach}; # compatibility
    $self->{nproc}       ||= 1 unless blessed $self->{manager};
    $self->{pid}         ||= $self->{pidfile}; # compatibility
    $self->{listen}      ||= [ ":$self->{port}" ] if $self->{port}; # compatibility
    $self->{backlog}     ||= 100;
    $self->{manager}     = 'FCGI::ProcManager' unless exists $self->{manager};

    $self;
}

sub run {
    my ($self, $app) = @_;

    my $sock = 0;
    if (-S STDIN) {
        # running from web server. Do nothing
        # Note it should come before listen check because of plackup's default
    } elsif ($self->{listen}) {
        my $old_umask = umask;
        unless ($self->{leave_umask}) {
            umask(0);
        }
        $sock = FCGI::OpenSocket( $self->{listen}->[0], $self->{backlog} )
            or die "failed to open FastCGI socket: $!";
        unless ($self->{leave_umask}) {
            umask($old_umask);
        }
    } elsif (!RUNNING_IN_HELL) {
        die "STDIN is not a socket: specify a listen location";
    }

    @{$self}{qw(stdin stdout stderr)} 
      = (IO::Handle->new, IO::Handle->new, IO::Handle->new);

    my %env;
    my $request = FCGI::Request(
        $self->{stdin}, $self->{stdout},
        ($self->{keep_stderr} ? $self->{stdout} : $self->{stderr}), \%env, $sock,
        ($self->{nointr} ? 0 : &FCGI::FAIL_ACCEPT_ON_INTR),
    );

    my $proc_manager;

    if ($self->{listen}) {
        $self->daemon_fork if $self->{daemonize};

        if ($self->{manager}) {
            if (blessed $self->{manager}) {
                for (qw(nproc pid proc_title)) {
                    die "Don't use '$_' when passing in a 'manager' object"
                        if $self->{$_};
                }
                $proc_manager = $self->{manager};
            } else {
                Plack::Util::load_class($self->{manager});
                $proc_manager = $self->{manager}->new({
                    n_processes => $self->{nproc},
                    pid_fname   => $self->{pid},
                    (exists $self->{proc_title}
                         ? (pm_title => $self->{proc_title}) : ()),
                });
            }

            # detach *before* the ProcManager inits
            $self->daemon_detach if $self->{daemonize};

            $proc_manager->pm_manage;
        }
        elsif ($self->{daemonize}) {
            $self->daemon_detach;
        }
    }

    while ($request->Accept >= 0) {
        $proc_manager && $proc_manager->pm_pre_dispatch;

        my $env = {
            %env,
            'psgi.version'      => [1,1],
            'psgi.url_scheme'   => ($env{HTTPS}||'off') =~ /^(?:on|1)$/i ? 'https' : 'http',
            'psgi.input'        => $self->{stdin},
            'psgi.errors'       => $self->{stderr}, # FCGI.pm redirects STDERR in Accept() loop, so just print STDERR
                                                    # print to the correct error handle based on keep_stderr
            'psgi.multithread'  => Plack::Util::FALSE,
            'psgi.multiprocess' => Plack::Util::TRUE,
            'psgi.run_once'     => Plack::Util::FALSE,
            'psgi.streaming'    => Plack::Util::TRUE,
            'psgi.nonblocking'  => Plack::Util::FALSE,
            'psgix.harakiri'    => defined $proc_manager,
        };

        delete $env->{HTTP_CONTENT_TYPE};
        delete $env->{HTTP_CONTENT_LENGTH};

        # lighttpd munges multiple slashes in PATH_INFO into one. Try recovering it
        my $uri = URI->new("http://localhost" .  $env->{REQUEST_URI});
        $env->{PATH_INFO} = uri_unescape($uri->path);
        $env->{PATH_INFO} =~ s/^\Q$env->{SCRIPT_NAME}\E//;

        # root access for mod_fastcgi
        if (!exists $env->{PATH_INFO}) {
            $env->{PATH_INFO} = '';
        }

        # typical fastcgi_param from nginx might get empty values
        for my $key (qw(CONTENT_TYPE CONTENT_LENGTH)) {
            no warnings;
            delete $env->{$key} if exists $env->{$key} && $env->{$key} eq '';
        }

        if (defined(my $HTTP_AUTHORIZATION = $env->{Authorization})) {
            $env->{HTTP_AUTHORIZATION} = $HTTP_AUTHORIZATION;
        }

        my $res = Plack::Util::run_app $app, $env;

        if (ref $res eq 'ARRAY') {
            $self->_handle_response($res);
        }
        elsif (ref $res eq 'CODE') {
            $res->(sub {
                $self->_handle_response($_[0]);
            });
        }
        else {
            die "Bad response $res";
        }

        # give pm_post_dispatch the chance to do things after the client thinks
        # the request is done
        $request->Finish;

        $proc_manager && $proc_manager->pm_post_dispatch();

        if ($proc_manager && $env->{'psgix.harakiri.commit'}) {
            $proc_manager->pm_exit("safe exit with harakiri");
        }
    }
}

sub _handle_response {
    my ($self, $res) = @_;

    $self->{stdout}->autoflush(1);
    binmode $self->{stdout};

    my $hdrs;
    my $message = status_message($res->[0]);
    $hdrs = "Status: $res->[0] $message\015\012";

    my $headers = $res->[1];
    while (my ($k, $v) = splice @$headers, 0, 2) {
        $hdrs .= "$k: $v\015\012";
    }
    $hdrs .= "\015\012";

    print { $self->{stdout} } $hdrs;

    my $cb = sub { print { $self->{stdout} } $_[0] };
    my $body = $res->[2];
    if (defined $body) {
        Plack::Util::foreach($body, $cb);
    }
    else {
        return Plack::Util::inline_object
            write => $cb,
            close => sub { };
    }
}

sub daemon_fork {
    require POSIX;
    fork && exit;
}

sub daemon_detach {
    my $self = shift;
    print "FastCGI daemon started (pid $$)\n";
    open STDIN,  "+</dev/null" or die $!; ## no critic
    open STDOUT, ">&STDIN"     or die $!;
    open STDERR, ">&STDIN"     or die $!;
    POSIX::setsid();
}

1;

__END__

=head1 NAME

Plack::Handler::FCGI - FastCGI handler for Plack

=head1 SYNOPSIS

  # Run as a standalone daemon
  plackup -s FCGI --listen /tmp/fcgi.sock --daemonize --nproc 10

  # Run from your web server like mod_fastcgi
  #!/usr/bin/env plackup -s FCGI
  my $app = sub { ... };

  # Roll your own
  my $server = Plack::Handler::FCGI->new(
      nproc  => $num_proc,
      listen => [ $port_or_socket ],
      detach => 1,
  );
  $server->run($app);


=head1 DESCRIPTION

This is a handler module to run any PSGI application as a standalone
FastCGI daemon or a .fcgi script.

=head2 OPTIONS

=over 4

=item listen

    listen => [ '/path/to/socket' ]
    listen => [ ':8080' ]

Listen on a socket path, hostname:port, or :port.

=item port

listen via TCP on port on all interfaces (Same as C<< listen => ":$port" >>)

=item leave-umask

Set to 1 to disable setting umask to 0 for socket open

=item nointr

Do not allow the listener to be interrupted by Ctrl+C

=item nproc

Specify a number of processes for FCGI::ProcManager

=item pid

Specify a filename for the pid file

=item manager

Specify either a FCGI::ProcManager subclass, or an actual FCGI::ProcManager-compatible object.

  use FCGI::ProcManager::Dynamic;
  Plack::Handler::FCGI->new(
      manager => FCGI::ProcManager::Dynamic->new(...),
  );

=item daemonize

Daemonize the process.

=item proc-title

Specify process title

=item keep-stderr

Send STDERR to STDOUT instead of the webserver

=item backlog

Maximum length of the queue of pending connections

=back

=head2 WEB SERVER CONFIGURATIONS

In all cases, you will want to install L<FCGI> and L<FCGI::ProcManager>.
You may find it most convenient to simply install L<Task::Plack> which
includes both of these.

=head3 nginx

This is an example nginx configuration to run your FCGI daemon on a
Unix domain socket and run it at the server's root URL (/).

  http {
    server {
      listen 3001;
      location / {
        set $script "";
        set $path_info $uri;
        fastcgi_pass unix:/tmp/fastcgi.sock;
        fastcgi_param  SCRIPT_NAME      $script;
        fastcgi_param  PATH_INFO        $path_info;
        fastcgi_param  QUERY_STRING     $query_string;
        fastcgi_param  REQUEST_METHOD   $request_method;
        fastcgi_param  CONTENT_TYPE     $content_type;
        fastcgi_param  CONTENT_LENGTH   $content_length;
        fastcgi_param  REQUEST_URI      $request_uri;
        fastcgi_param  SERVER_PROTOCOL  $server_protocol;
        fastcgi_param  REMOTE_ADDR      $remote_addr;
        fastcgi_param  REMOTE_PORT      $remote_port;
        fastcgi_param  SERVER_ADDR      $server_addr;
        fastcgi_param  SERVER_PORT      $server_port;
        fastcgi_param  SERVER_NAME      $server_name;
      }
    }
  }

If you want to host your application in a non-root path, then you
should mangle this configuration to set the path to C<SCRIPT_NAME> and
the rest of the path in C<PATH_INFO>.

See L<http://wiki.nginx.org/NginxFcgiExample> for more details.

=head3 Apache mod_fastcgi

After installing C<mod_fastcgi>, you should add the C<FastCgiExternalServer>
directive to your Apache config:

  FastCgiExternalServer /tmp/myapp.fcgi -socket /tmp/fcgi.sock

  ## Then set up the location that you want to be handled by fastcgi:

  # EITHER from a given path
  Alias /myapp/ /tmp/myapp.fcgi/

  # OR at the root
  Alias / /tmp/myapp.fcgi/

Now you can use plackup to listen to the socket that you've just configured in Apache.

  $  plackup -s FCGI --listen /tmp/myapp.sock psgi/myapp.psgi

The above describes the "standalone" method, which is usually appropriate.
There are other methods, described in more detail at 
L<Catalyst::Engine::FastCGI/Standalone_server_mode> (with regards to Catalyst, but which may be set up similarly for Plack).

See also L<http://www.fastcgi.com/mod_fastcgi/docs/mod_fastcgi.html#FastCgiExternalServer>
for more details.

=head3 lighttpd

To host the app in the root path, you're recommended to use lighttpd
1.4.23 or newer with C<fix-root-scriptname> flag like below.

  fastcgi.server = ( "/" =>
     ((
       "socket" => "/tmp/fcgi.sock",
       "check-local" => "disable",
       "fix-root-scriptname" => "enable",
     ))

If you use lighttpd older than 1.4.22 where you don't have
C<fix-root-scriptname>, mouting apps under the root causes wrong
C<SCRIPT_NAME> and C<PATH_INFO> set. Also, mouting under the empty
root (C<"">) or a path that has a trailing slash would still cause
weird values set even with C<fix-root-scriptname>. In such cases you
can use L<Plack::Middleware::LighttpdScriptNameFix> to fix it.

To mount in the non-root path over TCP:

  fastcgi.server = ( "/foo" =>
     ((
       "host" = "127.0.0.1",
       "port" = "5000",
       "check-local" => "disable",
     ))

It's recommended that your mount path does B<NOT> have the trailing
slash. If you I<really> need to have one, you should consider using
L<Plack::Middleware::LighttpdScriptNameFix> to fix the wrong
B<PATH_INFO> values set by lighttpd.

=cut

=head2 Authorization

Most fastcgi configuration does not pass C<Authorization> headers to
C<HTTP_AUTHORIZATION> environment variable by default for security
reasons. Authentication middleware such as L<Plack::Middleware::Auth::Basic> or
L<Catalyst::Authentication::Credential::HTTP> requires the variable to
be set up. Plack::Handler::FCGI supports extracting the C<Authorization> environment
variable when it is configured that way.

Apache2 with mod_fastcgi:

  --pass-header Authorization

mod_fcgid:

  FcgiPassHeader Authorization

=head1 SEE ALSO

L<Plack>

=cut


