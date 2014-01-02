use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'make list' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my @a = (1, 2, 3, 4);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left  => leaf '@a',
        right => list { '()',
            data => branch { ',',
                left  => branch { ',',
                    left  => branch { ',',
                        left  => leaf '1',
                        right => leaf '2'
                    },
                    right => leaf '3'
                },
                right => leaf '4'
            }
        }
    });
};

subtest 'array dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('@$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, dereference { '@$a',
        expr => leaf '@$a'
    });

    $tokens = Compiler::Lexer->new('')->tokenize('@{$a}');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, dereference { '@{',
        expr => leaf '$a'
    });
};

subtest 'array get access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, array { '$a',
        idx => array_ref { '[]',
            data => branch { '+',
                left  => leaf '$b',
                right => leaf '1'
            }
        }
    });
};

subtest 'array set access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1] = 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => array { '$a',
            idx => array_ref { '[]',
                data => branch { '+',
                    left  => leaf '$b',
                    right => leaf '1'
                }
            }
        },
        right => leaf '2'
    });
};

subtest 'nested array reference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = [1, [5, 6, 7] , 3, 4]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '$a',
        right => array_ref { '[]',
            data => branch { ',',
                left => branch { ',',
                    left => branch { ',',
                        left => leaf '1',
                        right => array_ref { '[]',
                            data => branch { ',',
                                left => branch { ',',
                                    left  => leaf '5',
                                    right => leaf '6'
                                },
                                right => leaf '7'
                            }
                        }
                    },
                    right => leaf '3'
                },
                right => leaf '4'
            }
        }
    });
};

subtest 'array reference chain' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1]->[$c + 2]->[3]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '->',
        left => branch { '->',
            left => array { '$a',
                idx => array_ref { '[]',
                    data => branch { '+',
                        left  => leaf '$b',
                        right => leaf '1'
                    }
                }
            },
            right => array_ref { '[]',
                data => branch { '+',
                    left  => leaf '$c',
                    right => leaf '2'
                }
            }
        },
        right => array_ref { '[]',
            data => leaf '3'
        }
    });
};

done_testing;
