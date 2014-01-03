use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'package' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('package Person; sub new { my $class = shift; bless {}, $class; } package main; 1 + 1;');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Person' },
        function { 'new',
            body => [
                branch { '=',
                    left  => leaf '$class',
                    right => function_call { 'shift', args => [] },
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left  => hash_ref { '{}' },
                            right => leaf '$class'
                        }
                    ]
                }
            ]
        },
        Test::Compiler::Parser::package { 'main' },
        branch { '+',
            left  => leaf '1',
            right => leaf '1'
        }
    ]);
};

subtest 'use base' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('package Person; use base "Base"; 1;');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Person' },
        module { 'base',
            args => leaf 'Base'
        },
        leaf '1'
    ]);
};

done_testing;
