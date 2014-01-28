use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'simple sub' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('sub f { return $_[0] + 2; } my $code = \&f; &$code(3);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        function { 'f',
            body => Test::Compiler::Parser::return { 'return',
                body => branch { '+',
                    left => array { '$_',
                        idx => array_ref { '[]',
                            data => leaf '0'
                        }
                    },
                    right => leaf '2'
                }
            }
        },
        branch { '=',
            left => leaf '$code',
            right => single_term_operator { '\&',
                expr => function_call { 'f', args => [] }
            }
        },
        dereference { '&$code',
            expr => leaf '3'
        }
    ]);
};

subtest 'anonymous subroutine' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = sub { return $_[0] + 2; if (0) {} };');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    ok(1);
};

done_testing;
