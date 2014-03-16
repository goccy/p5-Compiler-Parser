use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/TempBuffer.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::TempBuffer',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'parent',
            args => leaf 'Stream::Buffered',
        },
        function { 'new',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$Plack::TempBuffer::MaxMemoryBufferSize',
                        ],
                    },
                    true_stmt => [
                        function_call { 'warn',
                            args => [
                                branch { '.',
                                    left => leaf 'Setting \$Plack::TempBuffer::MaxMemoryBufferSize is deprecated. ',
                                    right => leaf 'You should set \$Stream::Buffered::MaxMemoryBufferSize instead.',
                                },
                            ],
                        },
                        branch { '=',
                            left => leaf '$Stream::Buffered::MaxMemoryBufferSize',
                            right => leaf '$Plack::TempBuffer::MaxMemoryBufferSize',
                        },
                    ],
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '->',
                        left => leaf '$class',
                        right => function_call { 'SUPER::new',
                            args => [
                                leaf '@_',
                            ],
                        },
                    },
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::TempBuffer;
use strict;
use warnings;

use parent 'Stream::Buffered';

sub new {
    my $class = shift;

    if (defined $Plack::TempBuffer::MaxMemoryBufferSize) {
        warn "Setting \$Plack::TempBuffer::MaxMemoryBufferSize is deprecated. "
           . "You should set \$Stream::Buffered::MaxMemoryBufferSize instead.";
        $Stream::Buffered::MaxMemoryBufferSize = $Plack::TempBuffer::MaxMemoryBufferSize;
    }

    return $class->SUPER::new(@_);
}

1;

