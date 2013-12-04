use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;

subtest 'add' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 + 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '+');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'sub' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 - 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '-');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'mul' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 * 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '*');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'div' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 / 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '/');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'mod' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 % 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '%');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'exp' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 ** 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '**');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'default' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 // 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '//');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'left shift' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 << 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '<<');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'right shift' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 >> 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '>>');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'slice' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 .. 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '..');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'grater' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 > 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '>');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'grater equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 >= 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '>=');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'less' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 < 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '<');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'less equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 <= 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '<=');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'equal equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 == 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '==');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'not equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 != 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '!=');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'polymorphoc compare' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 ~~ 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '~~');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'regexp ok' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 =~ 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '=~');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'regexp not ok' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 !~ 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '!~');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'and' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 && 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '&&');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'and' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 and 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'and');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'bit and' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 & 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '&');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'bit xor' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 ^ 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '^');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'xor' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 xor 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'xor');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 || 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '||');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'bit or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 | 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '|');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('1 or 2');
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'or');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string add' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' . '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, '.');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string mul' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' x '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'x');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string less' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' lt '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'lt');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string grater' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' gt '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'gt');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string grater equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' ge '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'ge');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string less equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' le '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'le');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' eq '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'eq');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string not equal' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' ne '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'ne');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

subtest 'string compare' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize("'1' cmp '2'");
    my $ast = Compiler::Parser->new->parse($tokens);
    is(ref $ast->root, 'Compiler::Parser::Node::Branch');
    is(ref $ast->root->{left},  'Compiler::Parser::Node::Leaf');
    is(ref $ast->root->{right}, 'Compiler::Parser::Node::Leaf');
    is($ast->root->{token}->data, 'cmp');
    is($ast->root->{left}->data,  '1');
    is($ast->root->{right}->data, '2');
};

done_testing;
