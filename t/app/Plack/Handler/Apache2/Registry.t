use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Handler/Apache2/Registry.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Handler::Apache2::Registry',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'Try::Tiny',
        },
        module { 'Apache2::Const',
        },
        module { 'Apache2::Log',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Handler::Apache2',
            },
        },
        function { 'handler',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => leaf '__PACKAGE__',
                },
                branch { '=',
                    left => list { '()',
                        data => leaf '$r',
                    },
                    right => leaf '@_',
                },
                Test::Compiler::Parser::return { 'return',
                    body => function_call { 'try',
                        args => [
                            [
                                branch { '=',
                                    left => leaf '$app',
                                    right => branch { '->',
                                        left => leaf '$class',
                                        right => function_call { 'load_app',
                                            args => [
                                                branch { '->',
                                                    left => leaf '$r',
                                                    right => function_call { 'filename',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                            ],
                                        },
                                    },
                                },
                                branch { '->',
                                    left => leaf '$class',
                                    right => function_call { 'call_app',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$r',
                                                    right => leaf '$app',
                                                },
                                            },
                                        ],
                                    },
                                },
                            ],
                            function_call { 'catch',
                                args => [
                                    if_stmt { 'if',
                                        expr => regexp { 'no such file',
                                            option => leaf 'i',
                                        },
                                        true_stmt => [
                                            branch { '->',
                                                left => leaf '$r',
                                                right => function_call { 'log_error',
                                                    args => [
                                                        leaf '$_',
                                                    ],
                                                },
                                            },
                                            Test::Compiler::Parser::return { 'return',
                                                body => function_call { 'Apache2::Const::NOT_FOUND',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        ],
                                        false_stmt => else_stmt { 'else',
                                            stmt => [
                                                branch { '->',
                                                    left => leaf '$r',
                                                    right => function_call { 'log_error',
                                                        args => [
                                                            leaf '$_',
                                                        ],
                                                    },
                                                },
                                                Test::Compiler::Parser::return { 'return',
                                                    body => function_call { 'Apache2::Const::SERVER_ERROR',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                            ],
                                        },
                                    },
                                ],
                            },
                        ],
                    },
                },
            ],
        },
        function { 'fixup_path',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$class',
                                right => leaf '$r',
                            },
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=~',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'PATH_INFO',
                        },
                    },
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '^$env->{SCRIPT_NAME}',
                    },
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Handler::Apache2::Registry;
use strict;
use warnings;
use Try::Tiny;
use Apache2::Const;
use Apache2::Log;
use parent qw/Plack::Handler::Apache2/;

sub handler {
    my $class = __PACKAGE__;
    my ($r) = @_;

    return try {
        my $app = $class->load_app( $r->filename );
        $class->call_app( $r, $app );
    }catch{
        if(/no such file/i){
            $r->log_error( $_ );
            return Apache2::Const::NOT_FOUND;
        }else{
            $r->log_error( $_ );
            return Apache2::Const::SERVER_ERROR;
        }
    };
}

# Overriding
sub fixup_path {
    my ($class, $r, $env) = @_;
    $env->{PATH_INFO} =~ s{^$env->{SCRIPT_NAME}}{};
}

1;

__END__

=head1 NAME

Plack::Handler::Apache2::Registry - Runs .psgi files.

=head1 SYNOPSIS

  PerlModule Plack::Handler::Apache2::Registry;
  <Location /psgi-bin>
  SetHandler modperl
  PerlHandler Plack::Handler::Apache2::Registry
  </Location>

=head1 DESCRIPTION

This is a handler module to run any *.psgi files with mod_perl2,
just like ModPerl::Registry.

=head1 AUTHOR

Masahiro Honma E<lt>hiratara@cpan.orgE<gt>

=head1 SEE ALSO

L<Plack::Handler::Apache2>

=cut


