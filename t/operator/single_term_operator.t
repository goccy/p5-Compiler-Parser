use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

subtest 'inc' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a++');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '++');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'inc' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('++$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '++');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'dec' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a--');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '--');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'dec' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('--$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '--');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'bit not' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('~$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '~');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'add' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('+$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '+');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'sub' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('-$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '-');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'ref with scalar' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('\$a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '\\');
    is($ast->root->{expr}->data,  '$a');
};

subtest 'ref with array' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('\@a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '\\');
    is($ast->root->{expr}->data,  '@a');
};

subtest 'ref with hash' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('\%a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '\\');
    is($ast->root->{expr}->data,  '%a');
};

subtest 'ref with code' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('\&a');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->root->{expr},  'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '\&');
    is($ast->root->{expr}->data,  'a');
};

done_testing;
