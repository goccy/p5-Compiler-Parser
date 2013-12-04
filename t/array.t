use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'make list' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my @a = (1, 2, 3, 4);');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    my $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Branch');
    is(ref $root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right, 'Compiler::Parser::Node::List');
    is(ref $root->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'array dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('@$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    my $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Dereference');
    is(ref $root->expr, 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize('@{$a}');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Dereference');
    is(ref $root->expr, 'Compiler::Parser::Node::Leaf');

};

subtest 'array get access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    my $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Array');
    is(ref $root->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->idx->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->idx->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->idx->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'array set access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1] = 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    my $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Branch');
    is(ref $root->left, 'Compiler::Parser::Node::Array');
    is(ref $root->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->left->idx->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->left->idx->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->left->idx->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'nested array reference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = [1, [5, 6, 7] , 3, 4]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    my $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Branch');
    is(ref $root->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->left->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->right->data_node->left->left->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left->left->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $root->right->data_node->left->left->right->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->left->left->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->left->left->right->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'array reference chain' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1]->[$c + 2]->[3]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    my $root = $ast->root;
    is(ref $root, 'Compiler::Parser::Node::Branch');
    is(ref $root->left, 'Compiler::Parser::Node::Branch');
    is(ref $root->left->left, 'Compiler::Parser::Node::Array');
    is(ref $root->left->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->left->left->idx->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->left->left->idx->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->left->left->idx->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->left->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $root->left->right->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $root->left->right->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $root->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $root->right->data_node, 'Compiler::Parser::Node::Leaf');
};

done_testing;
