use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

subtest '=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a = 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '+=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a += 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '+=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '-=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a -= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '-=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '*=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a *= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '*=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '/=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a /= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '/=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '%=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a %= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '%=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '.=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("\$a .= '1'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '.=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '**=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a **= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '**=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '//=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a //= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '//=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '&=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a &= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '&=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '|=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a |= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '|=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '^=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a ^= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '^=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '||=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a ||= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '||=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

subtest '&&=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a &&= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->right, 'Compiler::Parser::Node::Leaf');
    is($ast->root->data, '&&=');
    is($ast->root->left->data,  '$a');
    is($ast->root->right->data, '1');
};

done_testing;
