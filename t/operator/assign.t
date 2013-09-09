use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

subtest '=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a = 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '+=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a += 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '+=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '-=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a -= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '-=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '*=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a *= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '*=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '/=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a /= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '/=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '%=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a %= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '%=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '.=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("\$a .= '1'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '.=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '**=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a **= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '**=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '//=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a //= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '//=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '&=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a &= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '&=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '|=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a |= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '|=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '^=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a ^= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '^=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '||=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a ||= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '||=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

subtest '&&=' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a &&= 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left,  'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '&&=');
    is($ast->left->data,  '$a');
    is($ast->right->data, '1');
};

done_testing;
