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
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::List');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'array dereference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('@$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Dereference');
    is(ref $ast->expr, 'Compiler::Parser::Node::Leaf');

    $tokens = Compiler::Lexer->new('')->tokenize('@{$a}');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Dereference');
    is(ref $ast->expr, 'Compiler::Parser::Node::Leaf');

};

subtest 'array get access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Array');
    is(ref $ast->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->idx->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->idx->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->idx->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'array set access' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1] = 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Array');
    is(ref $ast->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->idx->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->idx->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->idx->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'nested array reference' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = [1, [5, 6, 7] , 3, 4]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->right->data_node->left->left->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left->right->data_node->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->data_node->left->left->right->data_node->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->left->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->left->right->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->data_node->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'array reference chain' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a[$b + 1]->[$c + 2]->[3]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left, 'Compiler::Parser::Node::Array');
    is(ref $ast->left->left->idx, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->left->idx->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->idx->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->idx->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->right->data_node, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->data_node->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->data_node->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Leaf');
};

done_testing;
