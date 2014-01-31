use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'pointer' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a->{b}->c->[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '->',
        left  => branch { '->',
            left  => branch { '->',
                left  => leaf '$a',
                right => hash_ref { '{}',
                    data => leaf 'b'
                }
            },
            right => function_call { 'c',
                args => []
            }
        },
        right => array_ref { '[]',
            data => leaf '0'
        }
    });
};

subtest 'pointer and assign' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v = $a->{b}->c->[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left  => leaf '$v',
        right => branch { '->',
            left  => branch { '->',
                left  => branch { '->',
                    left  => leaf '$a',
                    right => hash_ref { '{}',
                        data => leaf 'b'
                    }
                },
                right => function_call { 'c',
                    args => []
                }
            },
            right => array_ref { '[]',
                data => leaf '0'
            }
        }
    });
};

subtest 'and or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $v = $a->{b}->c(defined $a && 1 || $b < 3 || $c > 5)');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '$v',
        right => branch { '->',
            left => branch { '->',
                left => leaf '$a',
                right => hash_ref { '{}',
                    data => leaf 'b',
                },
            },
            right => function_call { 'c',
                args => [
                    branch { '||',
                        left => branch { '||',
                            left => branch { '&&',
                                left => function_call { 'defined',
                                    args => [
                                        leaf '$a',
                                    ],
                                },
                                right => leaf '1',
                            },
                            right => branch { '<',
                                left => leaf '$b',
                                right => leaf '3',
                            },
                        },
                        right => branch { '>',
                            left => leaf '$c',
                            right => leaf '5',
                        },
                    },
                ],
            },
        },
    });
};

subtest 'binary operator and single term operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v + $v + $v++ + $v-- * ++$v / --$v % $v x $v + $v ** $v ** $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '+',
        left => branch { '+',
            left => branch { '+',
                left => branch { '+',
                    left => leaf '$v',
                    right => leaf '$v',
                },
                right => single_term_operator { '++',
                    expr => leaf '$v',
                },
            },
            right => branch { 'x',
                left => branch { '%',
                    left => branch { '/',
                        left => branch { '*',
                            left => single_term_operator { '--',
                                expr => leaf '$v',
                            },
                            right => single_term_operator { '++',
                                expr => leaf '$v',
                            },
                        },
                        right => single_term_operator { '--',
                            expr => leaf '$v',
                        },
                    },
                    right => leaf '$v',
                },
                right => leaf '$v',
            },
        },
        right => branch { '**',
            left => leaf '$v',
            right => branch { '**',
                left => leaf '$v',
                right => leaf '$v',
            },
        },
    });
};

subtest 'binary operator and single term operator 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!$v + ~$v + \$v + +$v - +($v) - -$v - -($v) << $v >> $v + $v & $v + $v | $v + $v ^ $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '^',
        left => branch { '|',
            left => branch { '&',
                left => branch { '>>',
                    left => branch { '<<',
                        left => branch { '-',
                            left => branch { '-',
                                left => branch { '-',
                                    left => branch { '+',
                                        left => branch { '+',
                                            left => branch { '+',
                                                left => single_term_operator { '!',
                                                    expr => leaf '$v',
                                                },
                                                right => single_term_operator { '~',
                                                    expr => leaf '$v',
                                                },
                                            },
                                            right => single_term_operator { '\\',
                                                expr => leaf '$v',
                                            },
                                        },
                                        right => single_term_operator { '+',
                                            expr => leaf '$v',
                                        },
                                    },
                                    right => single_term_operator { '+',
                                        expr => leaf '$v',
                                    },
                                },
                                right => single_term_operator { '-',
                                    expr => leaf '$v',
                                },
                            },
                            right => single_term_operator { '-',
                                expr => leaf '$v',
                            },
                        },
                        right => leaf '$v',
                    },
                    right => branch { '+',
                        left => leaf '$v',
                        right => leaf '$v',
                    },
                },
                right => branch { '+',
                    left => leaf '$v',
                    right => leaf '$v',
                },
            },
            right => branch { '+',
                left => leaf '$v',
                right => leaf '$v',
            },
        },
        right => leaf '$v',
    });
};

subtest 'assign' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = $v =~ $v =~ $v !~ $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '$a',
        right => branch { '!~',
            left => branch { '=~',
                left => branch { '=~',
                    left => leaf '$v',
                    right => leaf '$v',
                },
                right => leaf '$v',
            },
            right => leaf '$v',
        },
    });
};

subtest 'string compare' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $b = $v < $v && $v > $v || $v gt $v && $v le $v || $v == $v && $v <=> $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '$b',
        right => branch { '||',
            left => branch { '||',
                left => branch { '&&',
                    left => branch { '<',
                        left => leaf '$v',
                        right => leaf '$v',
                    },
                    right => branch { '>',
                        left => leaf '$v',
                        right => leaf '$v',
                    },
                },
                right => branch { '&&',
                    left => branch { 'gt',
                        left => leaf '$v',
                        right => leaf '$v',
                    },
                    right => branch { 'le',
                        left => leaf '$v',
                        right => leaf '$v',
                    },
                },
            },
            right => branch { '&&',
                left => branch { '==',
                    left => leaf '$v',
                    right => leaf '$v',
                },
                right => branch { '<=>',
                    left => leaf '$v',
                    right => leaf '$v',
                },
            },
        },
    });
};

subtest 'assign 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $c = $v += $v -= $v *= $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '$c',
        right => branch { '+=',
            left => leaf '$v',
            right => branch { '-=',
                left => leaf '$v',
                right => branch { '*=',
                    left => leaf '$v',
                    right => leaf '$v',
                },
            },
        },
    });
};

subtest 'print argument' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print $v || $v , $v && $v, $v + $v * $v, $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, function_call { 'print',
        args => [
            branch { ',',
                left => branch { ',',
                    left => branch { ',',
                        left => branch { '||',
                            left => leaf '$v',
                            right => leaf '$v',
                        },
                        right => branch { '&&',
                            left => leaf '$v',
                            right => leaf '$v',
                        },
                    },
                    right => branch { '+',
                        left => leaf '$v',
                        right => branch { '*',
                            left => leaf '$v',
                            right => leaf '$v',
                        },
                    },
                },
                right => leaf '$v',
            },
        ],
    });
};

subtest 'print argument pattern2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print - $v || $v => $v && $v => $v + $v * $v => $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, function_call { 'print',
        args => [
            branch { '=>',
                left => branch { '=>',
                    left => branch { '=>',
                        left => branch { '||',
                            left => single_term_operator { '-',
                                expr => leaf '$v',
                            },
                            right => leaf '$v',
                        },
                        right => branch { '&&',
                            left => leaf '$v',
                            right => leaf '$v',
                        },
                    },
                    right => branch { '+',
                        left => leaf '$v',
                        right => branch { '*',
                            left => leaf '$v',
                            right => leaf '$v',
                        },
                    },
                },
                right => leaf '$v',
            },
        ],
    });
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v = $a->{b}->c(defined $a) || die "died"');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '$v',
        right => branch { '||',
            left => branch { '->',
                left => branch { '->',
                    left => leaf '$a',
                    right => hash_ref { '{}',
                        data => leaf 'b',
                    },
                },
                right => function_call { 'c',
                    args => [
                        function_call { 'defined',
                            args => [
                                leaf '$a',
                            ],
                        },
                    ],
                },
            },
            right => function_call { 'die',
                args => [
                    leaf 'died',
                ],
            },
        },
    });
};

subtest 'unary operator includes or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v = $a->{b}->c($a) or die "died"');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { 'or',
        left  => branch { '=',
            left  => leaf '$v',
            right => branch { '->',
                left  => branch { '->',
                    left  => leaf '$a',
                    right => hash_ref { '{}',
                        data => leaf 'b'
                    }
                },
                right => function_call { 'c',
                    args => [
                        leaf '$a'
                    ]
                }
            }
        },
        right => function_call { 'die',
            args => [
                leaf 'died'
            ]
        }
    });
};

subtest 'defined and term' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v{0}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, single_term_operator { '!',
        expr => function_call { 'defined',
            args => [
                hash { '$v',
                   key => hash_ref { '{}',
                       data => leaf '0'
                   }
                }
            ]
        }
    });
};

subtest 'defined and term 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v{0} || 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '||',
        left => single_term_operator { '!',
            expr => function_call { 'defined',
                args => [
                    hash { '$v',
                       key => hash_ref { '{}',
                           data => leaf '0'
                       }
                   }
                ]
            }
        },
        right => leaf '1'
    });
};

subtest 'defined and term 3' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root,  single_term_operator { '!',
        expr => function_call { 'defined',
            args => [
                array { '$v',
                   idx => array_ref { '[]',
                       data => leaf '0'
                   }
                }
            ]
        }
    });
};

subtest 'defined and term 4' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root,  single_term_operator { '!',
        expr => function_call { 'defined',
            args => [
                branch { '->',
                    left  => leaf '$v',
                    right => array_ref { '[]',
                       data => leaf '0'
                   }
                }
            ]
        }
    });
};

subtest 'defined and term 5' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0] || 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '||',
        left => single_term_operator { '!',
            expr => function_call { 'defined',
                args => [
                    branch { '->',
                        left  => leaf '$v',
                        right => array_ref { '[]',
                            data => leaf '0'
                        }
                    }
                ]
            }
        },
        right => leaf '1'
    });
};

subtest 'defined and term 6' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->{0}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, single_term_operator { '!',
        expr => function_call { 'defined',
            args => [
                branch { '->',
                    left => leaf '$v',
                    right => hash_ref { '{}',
                        data => leaf '0',
                    },
                },
            ],
        },
    });
};

subtest 'defined and term 7' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->{0} || 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '||',
        left => single_term_operator { '!',
            expr => function_call { 'defined',
                args => [
                    branch { '->',
                        left => leaf '$v',
                        right => hash_ref { '{}',
                            data => leaf '0',
                        },
                    },
                ],
            },
        },
        right => leaf '1',
    });
};

subtest 'defined and term 8' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0]->{0} && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '&&',
        left => single_term_operator { '!',
            expr => function_call { 'defined',
                args => [
                    branch { '->',
                        left => branch { '->',
                            left => leaf '$v',
                            right => array_ref { '[]',
                                data => leaf '0',
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf '0',
                        },
                    },
                ],
            },
        },
        right => leaf 'undef',
    });
};

subtest 'defined and term 9' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '&&',
        left => single_term_operator { '!',
            expr => function_call { 'defined',
                args => [
                    branch { '+',
                        left => branch { '->',
                            left => branch { '->',
                                left => leaf '$v',
                                right => array_ref { '[]',
                                    data => leaf '0',
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf '0',
                            },
                        },
                        right => leaf '1',
                    },
                ],
            },
        },
        right => leaf 'undef',
    });
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!print $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, single_term_operator { '!',
        expr => function_call { 'print',
            args => [
                branch { '&&',
                    left => branch { '+',
                        left => branch { '->',
                            left => branch { '->',
                                left => leaf '$v',
                                right => array_ref { '[]',
                                    data => leaf '0',
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf '0',
                            },
                        },
                        right => leaf '1',
                    },
                    right => leaf 'undef',
                },
            ],
        },
    });
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('defined $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '&&',
        left => function_call { 'defined',
            args => [
                branch { '+',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$v',
                            right => array_ref { '[]',
                                data => leaf '0',
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf '0',
                        },
                    },
                    right => leaf '1',
                },
            ],
        },
        right => leaf 'undef',
    });
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, function_call { 'print',
        args => [
            branch { '&&',
                left => branch { '+',
                    left => branch { '->',
                        left => branch { '->',
                            left => leaf '$v',
                            right => array_ref { '[]',
                                data => leaf '0',
                            },
                        },
                        right => hash_ref { '{}',
                            data => leaf '0',
                        },
                    },
                    right => leaf '1',
                },
                right => leaf 'undef',
            },
        ],
    });
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print $v->[0]->{0} + 1 && undef xor die "hoge"');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { 'xor',
        left => function_call { 'print',
            args => [
                branch { '&&',
                    left => branch { '+',
                        left => branch { '->',
                            left => branch { '->',
                                left => leaf '$v',
                                right => array_ref { '[]',
                                    data => leaf '0',
                                },
                            },
                            right => hash_ref { '{}',
                                data => leaf '0',
                            },
                        },
                        right => leaf '1',
                    },
                    right => leaf 'undef',
                },
            ],
        },
        right => function_call { 'die',
            args => [
                leaf 'hoge',
            ],
        },
    });
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print reverse sort keys values %v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, function_call { 'print',
        args => [
            function_call { 'reverse',
                args => [
                    function_call { 'sort',
                        args => [
                            function_call { 'keys',
                                args => [
                                    function_call { 'values',
                                        args => [
                                            leaf '%v',
                                        ],
                                    },
                                ],
                            },
                        ],
                    },
                ],
            },
        ],
    });
};

done_testing;
