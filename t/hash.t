use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'make list' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my %a = (a => 2, b => 4);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left => leaf '%a',
        right => list { '()',
            data => branch { ',',
                left  => branch { '=>',
                    left  => leaf 'a',
                    right => leaf '2'
                },
                right => branch { '=>',
                    left  => leaf 'b',
                    right => leaf '4'
                }
            }
        }
    });
};

subtest 'hash dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('%$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, dereference { '%$a',
        expr => leaf '%$a'
    });

    $tokens = Compiler::Lexer->new('')->tokenize('%{$a}');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, dereference { '%{',
        expr => leaf '$a'
    });
};

subtest 'hash get access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a{$b + 1}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, hash { '$a',
        key => hash_ref { '{}',
            data => branch { '+',
                left  => leaf '$b',
                right => leaf '1'
            }
        }
    });
};

subtest 'hash set access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a{$b + 1} = 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left  => hash { '$a',
            key => hash_ref { '{}',
                data => branch { '+',
                    left  => leaf '$b',
                    right => leaf '1'
                }
            }
        },
        right => leaf '2'
    });
};

subtest 'nested hash reference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = { a => 1, b => { d => 8 }, c => 2 }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '=',
        left  => leaf '$a',
        right => hash_ref { '{}',
            data => branch { ',',
                left  => branch { ',',
                    left  => branch { '=>',
                        left  => leaf 'a',
                        right => leaf '1'
                    },
                    right => branch { '=>',
                        left  => leaf 'b',
                        right => hash_ref { '{}',
                            data => branch { '=>',
                                left  => leaf 'd',
                                right => leaf '8'
                            }
                        }
                    }
                },
                right => branch { '=>',
                    left  => leaf 'c',
                    right => leaf '2'
                }
            }
        }

    });
};

subtest 'hash reference chain' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a{$b + 1}->{$c + 2}->{d}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, branch { '->',
        left  => branch { '->',
            left  => hash { '$a',
                key => hash_ref { '{}',
                    data => branch { '+',
                        left  => leaf '$b',
                        right => leaf '1'
                    }
                }
            },
            right => hash_ref { '{}',
                data => branch { '+',
                    left  => leaf '$c',
                    right => leaf '2'
                }
            }
        },
        right => hash_ref { '{}',
            data => leaf 'd'
        }
    });
};

subtest 'hash short dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print "\t", $key, ":", $$token{$key}, "\n";');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, function_call { 'print',
        args => [
            branch { ',',
                left  => branch { ',',
                    left  => branch { ',',
                        left  => branch { ',',
                            left  => leaf '\t',
                            right => leaf '$key'
                        },
                        right => leaf ':'
                    },
                    right => dereference { '$$token',
                        expr => hash_ref { '{}',
                            data => leaf '$key'
                        }
                    }
                },
                right => leaf '\n'
            }
        ]
    });
};

done_testing;
