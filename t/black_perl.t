use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;

subtest 'Black Perl' => sub {
    my $code = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($code);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    is(ref $ast, 'Compiler::Parser::Node::Label');
};

done_testing;

__DATA__

BEFOREHAND: close door, each window & exit;  wait until time;
    open spell book; study; read (spell, $scan, select); tell us;
write it, print(the hex) while each watches,
    reverse length, write again;
           kill spiders, pop them, chop, split, kill them.
              unlink arms, shift, wait and listen (listening, wait).
sort the flock (then, warn "the goats", kill "the sheep");
    kill them, dump qualms, shift moralities,
           values aside, each one;
               die sheep; die (to, reverse the => system
                      you accept (reject, respect));
next step,
    kill next sacrifice, each sacrifice,
           wait, redo ritual until "all the spirits are pleased";
    do it ("as they say").
do it(*everyone***must***participate***in***forbidden**s*e*x*).
return last victim; package body;
    exit crypt (time, times & "half a time") & close it.
           select (quickly) and warn next victim;
AFTERWARDS: tell nobody.
    wait, wait until time;
           wait until next year, next decade;
               sleep, sleep, die yourself,
                      die @last
