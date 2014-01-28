use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'pointer chain' => sub {
    my $tokens = Compiler::Lexer->new('-')->tokenize(<<'SCRIPT');
$fh->{IO}{hoge}->{fuga}[0]{piyo}->hoge->fuga() && 1;
$fh[0]{hoge}{fuga}[1]{piyo};
$fh{a}{hoge}{fuga}[1]{piyo};
*{$fh}{IO};
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        branch { '&&',
            left => branch { '->',
                left => branch { '->',
                    left => branch { '->',
                        left => branch { '->',
                            left => branch { '->',
                                left  => branch { '->',
                                    left  => branch { '->',
                                        left  => leaf '$fh',
                                        right => hash_ref { '{}',
                                            data => leaf 'IO'
                                        }
                                    },
                                    right => hash_ref { '{}',
                                        data => leaf 'hoge'
                                    }
                                },
                                right => hash_ref { '{}',
                                    data => leaf 'fuga'
                                }
                            },
                            right => array_ref { '[]',
                                data => leaf '0'
                            }
                        },
                        right => hash_ref { '{}',
                            data => leaf 'piyo'
                        }
                    },
                    right => function_call { 'hoge', args => [] }
                },
                right => function_call { 'fuga',
                    args => [ list { '()' } ]
                }
            },
            right => leaf '1'
        },
        branch { '->',
            left  => branch { '->',
                left  => branch { '->',
                    left  => branch { '->',
                        left  => array { '$fh',
                            idx => array_ref { '[]',
                                data => leaf '0'
                            }
                        },
                        right => hash_ref { '{}',
                            data => leaf 'hoge'
                        }
                    },
                    right => hash_ref { '{}',
                        data => leaf 'fuga'
                    }
                },
                right => array_ref { '[]',
                    data => leaf '1'
                }
            },
            right => hash_ref { '{}',
                data => leaf 'piyo'
            }
        },
        branch { '->',
            left  => branch { '->',
                left  => branch { '->',
                    left  => branch { '->',
                        left  => hash { '$fh',
                            key => hash_ref { '{}',
                                data => leaf 'a'
                            }
                        },
                        right => hash_ref { '{}',
                            data => leaf 'hoge'
                        }
                    },
                    right => hash_ref { '{}',
                        data => leaf 'fuga'
                    }
                },
                right => array_ref { '[]',
                    data => leaf '1'
                }
            },
            right => hash_ref { '{}',
                data => leaf 'piyo'
            }
        },
        single_term_operator { '*',
            expr => branch { '->',
                left  => hash_ref { '{}',
                    data => leaf '$fh'
                },
                right => hash_ref { '{}',
                    data => leaf 'IO'
                }
            }
        }
    ]);
};

done_testing;
