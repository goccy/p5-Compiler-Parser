use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Util/Accessor.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Util::Accessor',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        function { 'import',
            body => [
                function_call { 'shift',
                    args => [
                    ],
                },
                if_stmt { 'unless',
                    expr => leaf '@_',
                    true_stmt => Test::Compiler::Parser::return { 'return',
                    },
                },
                branch { '=',
                    left => leaf '$package',
                    right => function_call { 'caller',
                        args => [
                            list { '()',
                            },
                        ],
                    },
                },
                function_call { 'mk_accessors',
                    args => [
                        list { '()',
                            data => branch { ',',
                                left => leaf '$package',
                                right => leaf '@_',
                            },
                        },
                    ],
                },
            ],
        },
        function { 'mk_accessors',
            body => [
                branch { '=',
                    left => leaf '$package',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                function_call { 'no',
                    args => [
                        leaf 'strict',
                        leaf 'refs',
                    ],
                },
                foreach_stmt { 'foreach',
                    cond => leaf '@_',
                    true_stmt => branch { '=',
                        left => single_term_operator { '*',
                            expr => branch { '.',
                                left => branch { '.',
                                    left => leaf '$package',
                                    right => leaf '::',
                                },
                                right => leaf '$field',
                            },
                        },
                        right => function { 'sub',
                            body => [
                                if_stmt { 'if',
                                    expr => branch { '==',
                                        left => function_call { 'scalar',
                                            args => [
                                                leaf '@_',
                                            ],
                                        },
                                        right => leaf '1',
                                    },
                                    true_stmt => Test::Compiler::Parser::return { 'return',
                                        body => branch { '->',
                                            left => array { '$_',
                                                idx => array_ref { '[]',
                                                    data => leaf '0',
                                                },
                                            },
                                            right => hash_ref { '{}',
                                                data => leaf '$field',
                                            },
                                        },
                                    },
                                },
                                Test::Compiler::Parser::return { 'return',
                                    body => branch { '=',
                                        left => branch { '->',
                                            left => array { '$_',
                                                idx => array_ref { '[]',
                                                    data => leaf '0',
                                                },
                                            },
                                            right => hash_ref { '{}',
                                                data => leaf '$field',
                                            },
                                        },
                                        right => three_term_operator { '?',
                                            cond => branch { '==',
                                                left => function_call { 'scalar',
                                                    args => [
                                                        leaf '@_',
                                                    ],
                                                },
                                                right => leaf '2',
                                            },
                                            true_expr => array { '$_',
                                                idx => array_ref { '[]',
                                                    data => leaf '1',
                                                },
                                            },
                                            false_expr => array_ref { '[]',
                                                data => array { '@_',
                                                    idx => array_ref { '[]',
                                                        data => branch { '..',
                                                            left => leaf '1',
                                                            right => single_term_operator { '$#',
                                                                expr => leaf '_',
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                    },
                                },
                            ],
                        },
                    },
                    itr => leaf '$field',
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Util::Accessor;
use strict;
use warnings;

sub import {
    shift;
    return unless @_;
    my $package = caller();
    mk_accessors( $package, @_ );
}

sub mk_accessors {
    my $package = shift;
    no strict 'refs';
    foreach my $field ( @_ ) {
        *{ $package . '::' . $field } = sub {
            return $_[0]->{ $field } if scalar( @_ ) == 1;
            return $_[0]->{ $field }  = scalar( @_ ) == 2 ? $_[1] : [ @_[1..$#_] ];
        };
    }
}

1;

__END__

=head1 NAME

Plack::Util::Accessor - Accessor generation utility for Plack

=head1 DESCRIPTION

This module is just a simple accessor generator for Plack to replace
the Class::Accessor::Fast usage and so our classes don't have to inherit
from their accessor generator.

=head1 SEE ALSO

L<PSGI> L<http://plackperl.org/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

