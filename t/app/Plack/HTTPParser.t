use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/HTTPParser.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::HTTPParser',
        },
        module { 'strict',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Exporter',
            },
        },
        branch { '=',
            left => leaf '@EXPORT',
            right => reg_prefix { 'qw',
                expr => leaf ' parse_http_request ',
            },
        },
        module { 'Try::Tiny',
        },
        block { '',
            body => if_stmt { 'if',
                expr => branch { '&&',
                    left => single_term_operator { '!',
                        expr => hash { '$ENV',
                            key => hash_ref { '{}',
                                data => leaf 'PLACK_HTTP_PARSER_PP',
                            },
                        },
                    },
                    right => function_call { 'try',
                        args => [
                            [
                                module { 'HTTP::Parser::XS',
                                },
                                leaf '1',
                            ],
                        ],
                    },
                },
                true_stmt => branch { '=',
                    left => single_term_operator { '*',
                        expr => leaf 'parse_http_request',
                    },
                    right => single_term_operator { '\&',
                        expr => function_call { 'HTTP::Parser::XS::parse_http_request',
                            args => [
                            ],
                        },
                    },
                },
                false_stmt => else_stmt { 'else',
                    stmt => [
                        module { 'Plack::HTTPParser::PP',
                        },
                        branch { '=',
                            left => single_term_operator { '*',
                                expr => leaf 'parse_http_request',
                            },
                            right => single_term_operator { '\&',
                                expr => function_call { 'Plack::HTTPParser::PP::parse_http_request',
                                    args => [
                                    ],
                                },
                            },
                        },
                    ],
                },
            },
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::HTTPParser;
use strict;
use parent qw(Exporter);

our @EXPORT = qw( parse_http_request );

use Try::Tiny;

{
    if (!$ENV{PLACK_HTTP_PARSER_PP} && try { require HTTP::Parser::XS; 1 }) {
        *parse_http_request = \&HTTP::Parser::XS::parse_http_request;
    } else {
        require Plack::HTTPParser::PP;
        *parse_http_request = \&Plack::HTTPParser::PP::parse_http_request;
    }
}

1;

__END__

=head1 NAME

Plack::HTTPParser - Parse HTTP headers

=head1 SYNOPSIS

  use Plack::HTTPParser qw(parse_http_request);

  my $ret = parse_http_request($header_str, \%env);
  # see HTTP::Parser::XS docs

=head1 DESCRIPTION

Plack::HTTPParser is a wrapper class to dispatch C<parse_http_request>
to Kazuho Oku's XS based HTTP::Parser::XS or pure perl fallback based
on David Robins HTTP::Parser.

If you want to force the use of the slower pure perl version even if the
fast XS version is available, set the environment variable
C<PLACK_HTTP_PARSER_PP> to 1.

=head1 SEE ALSO

L<HTTP::Parser::XS> L<HTTP::Parser>

=cut

