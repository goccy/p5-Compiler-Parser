use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'if statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
if ($a != 2) {
    print 'true';
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'if statement 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
if ($a != 2) {
    print 'true';
} else {
    print 'false';
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $ast->root->false_stmt->stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->false_stmt->stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'if statement 3' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
if ($a != 2) {
    print 'true';
} elsif ($a == 2) {
    print 'elsif';
} elsif ($a == 3) {
    print 'elsif2';
} else {
    print 'else';
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->false_stmt->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->false_stmt->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->false_stmt->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt->false_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->false_stmt->false_stmt->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->false_stmt->false_stmt->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt->false_stmt->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt->false_stmt->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->false_stmt->false_stmt->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->false_stmt->false_stmt->false_stmt, 'Compiler::Parser::Node::ElseStmt');
    is(ref $ast->root->false_stmt->false_stmt->false_stmt->stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->false_stmt->false_stmt->false_stmt->stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'post position if statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
if ($a != 2) {
    push @{ $res->[2] }, $eof if defined $eof;
} else {
    print 'else';
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, if_stmt { 'if',
        expr => branch { '!=',
            left  => leaf '$a',
            right => leaf '2'
        },
        true_stmt => if_stmt { 'if',
            expr => function_call { 'defined',
                args => [
                    leaf '$eof'
                ]
            },
            true_stmt => function_call { 'push',
                args => [
                    branch { ',',
                        left  => dereference { '@{',
                            expr => branch { '->',
                                left  => leaf '$res',
                                right => array_ref { '[]',
                                    data => leaf '2'
                                }
                            }
                        },
                        right => leaf '$eof'
                    }
                ]
            }
        },
        false_stmt => else_stmt { 'else',
            stmt => function_call { 'print',
                args => [
                    leaf 'else'
                ]
            }
        }
    });
};

done_testing;
