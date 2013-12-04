use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

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

done_testing;
