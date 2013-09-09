use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'for statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
for (my $i = 0; $i < 10; $i++) {
    say $i;
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForStmt');
    is(ref $ast->init, 'Compiler::Parser::Node::Branch');
    is(ref $ast->init->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->init->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->cond, 'Compiler::Parser::Node::Branch');
    is(ref $ast->cond->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->cond->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->progress, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->progress->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'while statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
while ($j < 10) {
    say $j;
    $j++;
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::WhileStmt');
    is(ref $ast->expr, 'Compiler::Parser::Node::Branch');
    is(ref $ast->expr->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->expr->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->next, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->true_stmt->next->expr, 'Compiler::Parser::Node::Leaf');
};

subtest 'foreach statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
foreach my $itr (@a) {
    say $itr;
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
for my $itr (@a) {
    say $itr;
}
SCRIPT
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'foreach statement 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
foreach $itr (@a) {
    say $itr;
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
for $itr (@a) {
    say $itr;
}
SCRIPT
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->itr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

};

subtest 'foreach statement 3' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
foreach (@a) {
    say $_;
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
for (@a) {
    say $_;
}
SCRIPT
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForeachStmt');
    is(ref $ast->cond, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'double loop' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize(<<'SCRIPT');
for (my $i = 1; $i < 10; $i++) {
    for (my $j = 1; $j < 10; $j++) {
        print $i * $j, "  ";
    }
    say "";
}
SCRIPT
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::ForStmt');
    is(ref $ast->init, 'Compiler::Parser::Node::Branch');
    is(ref $ast->init->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->init->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->cond, 'Compiler::Parser::Node::Branch');
    is(ref $ast->cond->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->cond->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->progress, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->progress->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt, 'Compiler::Parser::Node::ForStmt');
    is(ref $ast->true_stmt->init, 'Compiler::Parser::Node::Branch');
    is(ref $ast->true_stmt->init->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->init->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->cond, 'Compiler::Parser::Node::Branch');
    is(ref $ast->true_stmt->cond->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->cond->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->progress, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->true_stmt->progress->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->true_stmt, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->true_stmt->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->true_stmt->true_stmt->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->true_stmt->true_stmt->{args}[0]->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->true_stmt->{args}[0]->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->true_stmt->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->true_stmt->next, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->true_stmt->next->{args}[0], 'Compiler::Parser::Node::Leaf');
};

done_testing;
