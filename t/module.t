use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'module version argument' => sub {
    my $tokens = Compiler::Lexer->new('-')->tokenize('use ModuleName 5.008_001');
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, module { 'ModuleName',
        args => leaf '5.008_001'
    });

    $tokens = Compiler::Lexer->new('-')->tokenize('use ModuleName v5.008');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, module { 'ModuleName',
        args => leaf 'v5.008'
    });

    $tokens = Compiler::Lexer->new('-')->tokenize('use ModuleName 54');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, module { 'ModuleName',
        args => leaf '54'
    });

    $tokens = Compiler::Lexer->new('-')->tokenize('use Foo; use Bar');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        module { 'Foo' },
        module { 'Bar' },
    ]);

    $tokens = Compiler::Lexer->new('-')->tokenize('use Foo; my $x = sub { }');
    $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        module { 'Foo' },
        branch { '=',
            left  => leaf '$x',
            right => function { 'sub',
                body => hash_ref { '{}' }
            }
        },
    ]);
};

done_testing;
