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
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->left->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $ast->root->left->{args}[0]->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left->{args}[0]->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left->{args}[0]->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->left->{args}[0]->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->left->{args}[0]->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->root->right->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->right->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next, 'Compiler::Parser::Node::DoStmt');
    is(ref $ast->root->next->stmt, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->next->stmt->next, 'Compiler::Parser::Node::HandleRead');
};

done_testing;
