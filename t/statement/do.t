use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'do statement' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('open (my $fh, "<", $filename) or die ($filename . ": cannot find"); my $script = do { local $/ ; <$fh> };');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $ast->left->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next, 'Compiler::Parser::Node::DoStmt');
    is(ref $ast->next->stmt, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->next->stmt->next, 'Compiler::Parser::Node::HandleRead');
};

done_testing;
