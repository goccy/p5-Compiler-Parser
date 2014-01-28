use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'break' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('foreach my $itr (@array) { break if ($itr); }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, foreach_stmt { 'foreach',
        cond => leaf '@array',
        itr  => leaf '$itr',
        true_stmt => if_stmt { 'if',
            expr => list { '()',
                data => leaf '$itr'
            },
            true_stmt => control_stmt 'break'
        }
    });
};

subtest 'next' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('foreach my $itr (@array) { next if ($itr); }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, foreach_stmt { 'foreach',
        cond => leaf '@array',
        itr  => leaf '$itr',
        true_stmt => if_stmt { 'if',
            expr => list { '()',
                data => leaf '$itr'
            },
            true_stmt => control_stmt 'next'
        }
    });
};

subtest 'last' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('foreach my $itr (@array) { last if ($itr); }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, foreach_stmt { 'foreach',
        cond => leaf '@array',
        itr  => leaf '$itr',
        true_stmt => if_stmt { 'if',
            expr => list { '()',
                data => leaf '$itr'
            },
            true_stmt => control_stmt 'last'
        }
    });
};

done_testing;
