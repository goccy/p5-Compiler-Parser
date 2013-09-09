use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'pointer' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$a->{b}->c->[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->right->data_node, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '->');
    is($ast->left->data, '->');
    is($ast->left->left->data, '->');
    is($ast->left->left->left->data, '$a');
    is($ast->left->left->right->data, '{}');
    is($ast->left->left->right->data_node->data, 'b');
    is($ast->left->right->data, 'c');
    is($ast->right->data, '[]');
    is($ast->right->data_node->data, '0');
};

subtest 'pointer and assign' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v = $a->{b}->c->[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->right->right->data_node, 'Compiler::Parser::Node::Leaf');
    is($ast->data, '=');
    is($ast->left->data, '$v');
    is($ast->right->left->data, '->');
    is($ast->right->left->left->data, '->');
    is($ast->right->left->left->left->data, '$a');
    is($ast->right->left->left->right->data, '{}');
    is($ast->right->left->left->right->data_node->data, 'b');
    is($ast->right->left->right->data, 'c');
    is($ast->right->right->data, '[]');
    is($ast->right->right->data_node->data, '0');
};

subtest 'and or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $v = $a->{b}->c(defined $a && 1 || $b < 3 || $c > 5)');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->right->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->{args}[0]->left->left->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->right->{args}[0]->left->left->left->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->{args}[0]->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->{args}[0]->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->{args}[0]->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->{args}[0]->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->{args}[0]->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->{args}[0]->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->{args}[0]->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'binary operator and single term operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v + $v + $v++ + $v-- * ++$v / --$v % $v x $v + $v ** $v ** $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->left->left->left->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->right->left->left->left->left->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->right->left->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->right->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'binary operator and single term operator 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!$v + ~$v + \$v + +$v - +($v) - -$v - -($v) << $v >> $v + $v & $v + $v | $v + $v ^ $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left->left->left->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->left->left->left->left->left->left->left->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->left->left->left->left->left->left->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->left->left->left->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->left->left->left->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->left->left->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->left->left->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->left->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->left->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->left->left->right->expr, 'Compiler::Parser::Node::List');
    is(ref $ast->left->left->left->left->left->left->left->right->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->left->right->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->left->right, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->left->left->left->left->right->expr, 'Compiler::Parser::Node::List');
    is(ref $ast->left->left->left->left->left->right->expr->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'assign' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $a = $v =~ $v =~ $v !~ $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'string compare' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $b = $v < $v && $v > $v || $v gt $v && $v le $v || $v == $v && $v <=> $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->right->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'assign 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('my $c = $v += $v -= $v *= $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right->right->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'print argument' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print $v || $v , $v && $v, $v + $v * $v, $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'print argument pattern2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print - $v || $v => $v && $v => $v + $v * $v => $v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->{args}[0]->left->left->left->left->expr, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->left->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->right->right->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->right->right->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v = $a->{b}->c(defined $a) || die "died"');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->left->right->{args}[0], 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->left->right->{args}[0]->{args}[0], 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->right->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'unary operator includes or' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('$v = $a->{b}->c($a) or die "died"');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->right->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->right->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->left->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->left->right->{args}[0], 'Compiler::Parser::Node::List');
    is(ref $ast->right->left->right->{args}[0]->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->right->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v{0}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->expr->{args}[0], 'Compiler::Parser::Node::Hash');
    is(ref $ast->expr->{args}[0]->{key}, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->expr->{args}[0]->{key}->data_node, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 2' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v{0} || 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->expr->{args}[0], 'Compiler::Parser::Node::Hash');
    is(ref $ast->left->expr->{args}[0]->{key}, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->expr->{args}[0]->{key}->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 3' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->expr->{args}[0], 'Compiler::Parser::Node::Array');
    is(ref $ast->expr->{args}[0]->{idx}, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->expr->{args}[0]->{idx}->data_node, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 4' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0]');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->expr->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->expr->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->expr->{args}[0]->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->expr->{args}[0]->right->data_node, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 5' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0] || 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->expr->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->expr->{args}[0]->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 6' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->{0}');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->expr->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->expr->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->expr->{args}[0]->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->expr->{args}[0]->right->data_node, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 7' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->{0} || 1');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->expr->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->expr->{args}[0]->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 8' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0]->{0} && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->expr->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->expr->{args}[0]->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->expr->{args}[0]->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'defined and term 9' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!defined $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->left->expr, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->expr->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->expr->{args}[0]->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->left->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->expr->{args}[0]->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->expr->{args}[0]->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->expr->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('!print $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::SingleTermOperator');
    is(ref $ast->expr, 'Compiler::Parser::Node::FunctionCall');
    # TODO
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('defined $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->left->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->{args}[0]->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->{args}[0]->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print $v->[0]->{0} + 1 && undef');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->{args}[0]->left->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->{args}[0]->left->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->left->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->{args}[0]->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print $v->[0]->{0} + 1 && undef xor die "hoge"');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->left->{args}[0], 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left->left->left, 'Compiler::Parser::Node::Branch');
    is(ref $ast->left->{args}[0]->left->left->left->left, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->left->left->left->right, 'Compiler::Parser::Node::ArrayRef');
    is(ref $ast->left->{args}[0]->left->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->left->left->right, 'Compiler::Parser::Node::HashRef');
    is(ref $ast->left->{args}[0]->left->left->right->data_node, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->left->{args}[0]->right, 'Compiler::Parser::Node::Leaf');
    is(ref $ast->right, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->right->{args}[0], 'Compiler::Parser::Node::Leaf');
};

subtest 'unary operator' => sub {
    my $tokens = Compiler::Lexer->new('')->tokenize('print reverse sort keys values %v');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0], 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0]->{args}[0], 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0]->{args}[0]->{args}[0], 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0]->{args}[0]->{args}[0]->{args}[0], 'Compiler::Parser::Node::FunctionCall');
    is(ref $ast->{args}[0]->{args}[0]->{args}[0]->{args}[0]->{args}[0], 'Compiler::Parser::Node::Leaf');
};

done_testing;
