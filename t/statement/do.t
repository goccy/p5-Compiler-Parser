use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'do statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('open (my $fh, "<", $filename) or die ($filename . ": cannot find"); my $script = do { local $/ ; <$fh> };');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        branch { 'or',
            left  => function_call { 'open',
                args => [
                    list { '()',
                        data => branch { ',',
                            left  => branch { ',',
                                left  => leaf '$fh',
                                right => leaf '<'
                            },
                            right => leaf '$filename'
                        }
                    }
                ]
            },
            right => function_call { 'die',
                args => [
                    branch { '.',
                        left  => leaf '$filename',
                        right => leaf ': cannot find'
                    }
                ]
            }
        },
        branch { '=',
            left  => leaf '$script',
            right => do_stmt { 'do',
                stmt => [
                    leaf '$/',
                    leaf '$fh'
                ]
            }
        }
    ]);
};

done_testing;
