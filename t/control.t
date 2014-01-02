use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'break' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('foreach my $itr (@array) { break if ($itr); }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->root->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->true_stmt->expr, 'Compiler::Parser::Node::List');
    is(ref $ast->root->true_stmt->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt->true_stmt, 'Compiler::Parser::Node::ControlStmt');
};

subtest 'next' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('foreach my $itr (@array) { next if ($itr); }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->root->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->true_stmt->expr, 'Compiler::Parser::Node::List');
    is(ref $ast->root->true_stmt->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt->true_stmt, 'Compiler::Parser::Node::ControlStmt');
};

subtest 'last' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('foreach my $itr (@array) { last if ($itr); }');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast->root, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->root->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt, 'Compiler::Parser::Node::IfStmt');
    is(ref $ast->root->true_stmt->expr, 'Compiler::Parser::Node::List');
    is(ref $ast->root->true_stmt->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->true_stmt->true_stmt, 'Compiler::Parser::Node::ControlStmt');
};

done_testing;
