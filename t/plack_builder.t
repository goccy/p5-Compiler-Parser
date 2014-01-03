use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'Plack::Builder' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Builder' },
        module { 'strict' },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf ' Exporter '
            }
        },
        branch { '=',
            left  => leaf '@EXPORT',
            right => reg_prefix { 'qw',
                expr => leaf ' builder add enable enable_if mount '
            }
        },
        module { 'Carp',
            args => list { '()' }
        },
        module { 'Plack::App::URLMap' },
        module { 'Plack::Middleware::Conditional' },
        function { 'new',
            body => [
                branch { '=',
                    left  => leaf '$class',
                    right => function_call { 'shift',
                        args => []
                    }
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left  => hash_ref { '{}',
                                data => branch { '=>',
                                    left  => leaf 'middlewares',
                                    right => array_ref { '[]' }
                                }
                            },
                            right => leaf '$class'
                        }
                    ]
                }
            ]
        },
        function { 'add_middleware',
            body => [
                branch { '=',
                    left  => list { '()',
                        data => branch { ',',
                            left  => branch { ',',
                                left  => leaf '$self',
                                right => leaf '$mw'
                            },
                            right => leaf '@args'
                        }
                    },
                    right => leaf '@_'
                },
                if_stmt { 'if',
                    expr => branch { 'ne',
                        left  => function_call { 'ref',
                            args => [
                                leaf '$mw'
                            ]
                        },
                        right => leaf 'CODE'
                    },
                    true_stmt => [
                        branch { '=',
                            left  => leaf '$mw_class',
                            right => function_call { 'Plack::Util::load_class',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left  => leaf '$mw',
                                            right => leaf 'Plack::Middleware'
                                        }
                                    }
                                ]
                            }
                        },
                        branch { '=',
                            left  => leaf '$mw',
                            right => function { 'sub',
                                body => branch { '->',
                                    left  => leaf '$mw_class',
                                    right => function_call { 'wrap',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left  => array { '$_',
                                                        idx => array_ref { '[]',
                                                            data => leaf '0'
                                                        }
                                                    },
                                                    right => leaf '@args'
                                                }
                                            }
                                        ]
                                    }
                                }
                            }
                        }
                    ]
                },
                branch { ',',
                    left  => function_call { 'push',
                        args => [
                            dereference { '@{',
                                expr => branch { '->',
                                    left  => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf 'middlewares'
                                    }
                                }
                            }
                        ]
                    },
                    right => leaf '$mw'
                }
            ]
        },
        function { 'add_middleware_if',
            body => [
                branch { '=',
                    left  => list { '()',
                        data => branch { ',',
                            left  => branch { ',',
                                left  => branch { ',',
                                    left  => leaf '$self',
                                    right => leaf '$cond'
                                },
                                right => leaf '$mw'
                            },
                            right => leaf '@args'
                        }
                    },
                    right => leaf '@_'
                }
            ]
        }
    ]);

=hoge
    my $add_middleware_if = $add_middleware_method->next;

    is(ref $add_middleware_if->body->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $add_middleware_if->body->next->expr, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->expr->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $add_middleware_if->body->next->expr->left->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->true_stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $add_middleware_if->body->next->true_stmt->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $add_middleware_if->body->next->true_stmt->right->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->true_stmt->right->{args}[0]->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt->right->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt->next, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->true_stmt->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt->next->right, 'Compiler::Parser::Node::Function');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right->{args}[0]->data_node->left, 'Compiler::Parser::Node::Array');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right->{args}[0]->data_node->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right->{args}[0]->data_node->left->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->true_stmt->next->right->body->right->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $add_middleware_if->body->next->next->left->{args}[0], 'Compiler::Parser::Node::Dereference');
    is(ref $add_middleware_if->body->next->next->left->{args}[0]->expr, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->left->{args}[0]->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->next->left->{args}[0]->expr->right, 'Compiler::Parser::Node::HashRef');
    is(ref $add_middleware_if->body->next->next->left->{args}[0]->expr->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->next->right, 'Compiler::Parser::Node::Function');
    is(ref $add_middleware_if->body->next->next->right->body, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->right->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->next->right->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left->left, 'Compiler::Parser::Node::Array');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left->left->idx->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $add_middleware_if->body->next->next->right->body->right->{args}[0]->data_node->left->right->right, 'Compiler::Parser::Node::Leaf');

    my $_mount = $add_middleware_if->next;
    is(ref $_mount, 'Compiler::Parser::Node::Function');
    is(ref $_mount->body, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->left, 'Compiler::Parser::Node::List');
    is(ref $_mount->body->left->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->left->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->left->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->left->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $_mount->body->next->expr, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $_mount->body->next->expr->expr, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->expr->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->expr->expr->right, 'Compiler::Parser::Node::HashRef');
    is(ref $_mount->body->next->expr->expr->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->expr->expr->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->true_stmt->left, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->true_stmt->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->true_stmt->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $_mount->body->next->true_stmt->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->true_stmt->right, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->true_stmt->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->true_stmt->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $_mount->body->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->next->left, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->next->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->next->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $_mount->body->next->next->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $_mount->body->next->next->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $_mount->body->next->next->right->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->next->right->{args}[0]->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->next->right->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $_mount->body->next->next->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $_mount->body->next->next->next->right, 'Compiler::Parser::Node::HashRef');
    is(ref $_mount->body->next->next->next->right->data_node, 'Compiler::Parser::Node::Leaf');

    my $to_app = $_mount->next;
    is(ref $to_app, 'Compiler::Parser::Node::Function');
    is(ref $to_app->body, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->left, 'Compiler::Parser::Node::List');
    is(ref $to_app->body->left->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->left->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->left->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $to_app->body->next->expr, 'Compiler::Parser::Node::List');
    is(ref $to_app->body->next->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->next->true_stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->true_stmt->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $to_app->body->next->true_stmt->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $to_app->body->next->true_stmt->right->{args}[0]->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->false_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $to_app->body->next->false_stmt->expr, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->next->false_stmt->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->false_stmt->expr->right, 'Compiler::Parser::Node::HashRef');
    is(ref $to_app->body->next->false_stmt->expr->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->false_stmt->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->next->false_stmt->true_stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->false_stmt->true_stmt->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $to_app->body->next->false_stmt->true_stmt->right->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $to_app->body->next->false_stmt->true_stmt->right->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->false_stmt->true_stmt->right->{args}[0]->right, 'Compiler::Parser::Node::HashRef');
    is(ref $to_app->body->next->false_stmt->true_stmt->right->{args}[0]->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $to_app->body->next->false_stmt->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $to_app->body->next->false_stmt->false_stmt->stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $to_app->body->next->false_stmt->false_stmt->stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

    my $wrap = $to_app->next;
    is(ref $wrap, 'Compiler::Parser::Node::Function');
    is(ref $wrap->body, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->left, 'Compiler::Parser::Node::List');
    is(ref $wrap->body->left->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->left->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->left->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $wrap->body->next->expr, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->expr->left, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->expr->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->expr->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $wrap->body->next->expr->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->expr->right, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->expr->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->expr->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->expr->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->expr->right->right->right, 'Compiler::Parser::Node::HashRef');
    is(ref $wrap->body->next->expr->right->right->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $wrap->body->next->true_stmt->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->true_stmt->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->true_stmt->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $wrap->body->next->next->cond, 'Compiler::Parser::Node::FunctionCall');
    is(ref $wrap->body->next->next->cond->{args}[0], 'Compiler::Parser::Node::Dereference');
    is(ref $wrap->body->next->next->cond->{args}[0]->expr, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->next->cond->{args}[0]->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next->cond->{args}[0]->expr->right, 'Compiler::Parser::Node::HashRef');
    is(ref $wrap->body->next->next->cond->{args}[0]->expr->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->next->true_stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next->true_stmt->right, 'Compiler::Parser::Node::Branch');
    is(ref $wrap->body->next->next->true_stmt->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next->true_stmt->right->right, 'Compiler::Parser::Node::List');
    is(ref $wrap->body->next->next->true_stmt->right->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $wrap->body->next->next->next, 'Compiler::Parser::Node::Leaf');

    my $assign = $wrap->next;
    is(ref $assign, 'Compiler::Parser::Node::Branch');
    is(ref $assign->left, 'Compiler::Parser::Node::Leaf');
    is(ref $assign->right, 'Compiler::Parser::Node::Branch');
    is(ref $assign->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $assign->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $assign->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $assign->right->right->right, 'Compiler::Parser::Node::Function');
    is(ref $assign->right->right->right->body, 'Compiler::Parser::Node::FunctionCall');
    is(ref $assign->right->right->right->body->{args}[0], 'Compiler::Parser::Node::Leaf');

    my $enable = $assign->next;
    is(ref $enable, 'Compiler::Parser::Node::Function');
    is(ref $enable->body, 'Compiler::Parser::Node::Branch');
    is(ref $enable->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $enable->body->right, 'Compiler::Parser::Node::Leaf');

    my $enable_if = $enable->next;
    is(ref $enable_if, 'Compiler::Parser::Node::Function');
    is(ref $enable_if->body, 'Compiler::Parser::Node::Branch');
    is(ref $enable_if->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $enable_if->body->right, 'Compiler::Parser::Node::Leaf');
    is(ref $enable_if->prototype, 'Compiler::Parser::Node::Leaf');

    my $mount = $enable_if->next;
    is(ref $mount, 'Compiler::Parser::Node::Function');
    is(ref $mount->body, 'Compiler::Parser::Node::Branch');
    is(ref $mount->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $mount->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $mount->body->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $mount->body->next->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $mount->body->next->expr->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $mount->body->next->expr->{args}[0]->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $mount->body->next->true_stmt, 'Compiler::Parser::Node::Branch');
    is(ref $mount->body->next->true_stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $mount->body->next->true_stmt->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $mount->body->next->true_stmt->right->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $mount->body->next->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $mount->body->next->false_stmt->stmt, 'Compiler::Parser::Node::Branch');
    is(ref $mount->body->next->false_stmt->stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $mount->body->next->false_stmt->stmt->right, 'Compiler::Parser::Node::List');
    is(ref $mount->body->next->false_stmt->stmt->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $mount->body->next->false_stmt->stmt->right->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $mount->body->next->false_stmt->stmt->right->data_node->right, 'Compiler::Parser::Node::Leaf');

    my $builder = $mount->next;
    is(ref $builder, 'Compiler::Parser::Node::Function');
    is(ref $builder->body, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $builder->body->next, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->right, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->next->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $builder->body->next->next, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->next->next->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next->right, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->next->next->next->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $builder->body->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->next->next->next->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next->next->right, 'Compiler::Parser::Node::Function');
    is(ref $builder->body->next->next->next->next->right->body, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $builder->body->next->next->next->next->right->body->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next->next->right->body->next, 'Compiler::Parser::Node::Branch');
    is(ref $builder->body->next->next->next->next->right->body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next->next->right->body->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $builder->body->next->next->next->next->right->body->next->right->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $builder->body->next->next->next->next->right->body->next->next, 'Compiler::Parser::Node::Leaf');

    my $body = $builder->body->next->next->next->next->next;
    is(ref $body, 'Compiler::Parser::Node::Branch');
    is(ref $body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->right, 'Compiler::Parser::Node::Function');
    is(ref $body->right->body, 'Compiler::Parser::Node::Branch');
    is(ref $body->right->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->right->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $body->right->body->right->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $body->next, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->right, 'Compiler::Parser::Node::Function');
    is(ref $body->next->right->body, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->right->body->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->right->body->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $body->next->right->body->right->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->right, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->right->right, 'Compiler::Parser::Node::List');
    is(ref $body->next->next->next, 'Compiler::Parser::Node::IfStmt');
    is(ref $body->next->next->next->expr, 'Compiler::Parser::Node::List');
    is(ref $body->next->next->next->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $body->next->next->next->true_stmt->expr, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->next->true_stmt->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $body->next->next->next->true_stmt->true_stmt->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->next->true_stmt->true_stmt->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->true_stmt->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $body->next->next->next->true_stmt->false_stmt->stmt, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->next->true_stmt->false_stmt->stmt->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->false_stmt->stmt->right, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->next->true_stmt->false_stmt->stmt->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->true_stmt->false_stmt->stmt->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $body->next->next->next->next, 'Compiler::Parser::Node::Branch');
    is(ref $body->next->next->next->next->left, 'Compiler::Parser::Node::Leaf');
    is(ref $body->next->next->next->next->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $body->next->next->next->next->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $body->next->next->next->next->right->{args}[0]->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->prototype, 'Compiler::Parser::Node::Leaf');
    is(ref $builder->next, 'Compiler::Parser::Node::Leaf');
=cut

};

done_testing;

__DATA__
package Plack::Builder;
use strict;
use parent qw( Exporter );
our @EXPORT = qw( builder add enable enable_if mount );

use Carp ();
use Plack::App::URLMap;
use Plack::Middleware::Conditional; # TODO delayed load?

sub new {
    my $class = shift;
    bless { middlewares => [ ] }, $class;
}

sub add_middleware {
    my($self, $mw, @args) = @_;

    if (ref $mw ne 'CODE') {
        my $mw_class = Plack::Util::load_class($mw, 'Plack::Middleware');
        $mw = sub { $mw_class->wrap($_[0], @args) };
    }

    push @{$self->{middlewares}}, $mw;
}

sub add_middleware_if {
    my($self, $cond, $mw, @args) = @_;

    if (ref $mw ne 'CODE') {
        my $mw_class = Plack::Util::load_class($mw, 'Plack::Middleware');
        $mw = sub { $mw_class->wrap($_[0], @args) };
    }

    push @{$self->{middlewares}}, sub {
        Plack::Middleware::Conditional->wrap($_[0], condition => $cond, builder => $mw);
    };
}

# do you want remove_middleware() etc.?

sub _mount {
    my ($self, $location, $app) = @_;

    if (!$self->{_urlmap}) {
        $self->{_urlmap} = Plack::App::URLMap->new;
    }

    $self->{_urlmap}->map($location => $app);
    $self->{_urlmap}; # for backward compat.
}

sub to_app {
    my($self, $app) = @_;

    if ($app) {
        $self->wrap($app);
    } elsif ($self->{_urlmap}) {
        $self->wrap($self->{_urlmap});
    } else {
        Carp::croak("to_app() is called without mount(). No application to build.");
    }
}

sub wrap {
    my($self, $app) = @_;

    if ($self->{_urlmap} && $app ne $self->{_urlmap}) {
        Carp::carp("WARNING: wrap() and mount() can't be used altogether in Plack::Builder.\n" .
                   "WARNING: This causes all previous mount() mappings to be ignored.");
    }

    for my $mw (reverse @{$self->{middlewares}}) {
        $app = $mw->($app);
    }

    $app;
}

# DSL goes here
our $_add = our $_add_if = our $_mount = sub {
    Carp::croak("enable/mount should be called inside builder {} block");
};

sub enable         { $_add->(@_) }
sub enable_if(&$@) { $_add_if->(@_) }

sub mount {
    my $self = shift;
    if (Scalar::Util::blessed($self)) {
        $self->_mount(@_);
    }else{
        $_mount->($self, @_);
    }
}

sub builder(&) {
    my $block = shift;

    my $self = __PACKAGE__->new;

    my $mount_is_called;
    my $urlmap = Plack::App::URLMap->new;
    local $_mount = sub {
        $mount_is_called++;
        $urlmap->map(@_);
        $urlmap;
    };
    local $_add = sub {
        $self->add_middleware(@_);
    };
    local $_add_if = sub {
        $self->add_middleware_if(@_);
    };

    my $app = $block->();

    if ($mount_is_called) {
        if ($app ne $urlmap) {
            Carp::carp("WARNING: You used mount() in a builder block, but the last line (app) isn't using mount().\n" .
                       "WARNING: This causes all mount() mappings to be ignored.\n");
        } else {
            $app = $app->to_app;
        }
    }

    $self->to_app($app);
}

1;

__END__

