use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/HTTPParser/PP.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::HTTPParser::PP',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'URI::Escape',
        },
        function { 'parse_http_request',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$chunk',
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '||=',
                    left => leaf '$env',
                    right => hash_ref { '{}',
                    },
                },
                branch { '=~',
                    left => leaf '$chunk',
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '^(\x0d?\x0a)+',
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'length',
                        args => [
                            leaf '$chunk',
                        ],
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => leaf '-2',
                    },
                },
                if_stmt { 'if',
                    expr => branch { '=~',
                        left => leaf '$chunk',
                        right => regexp { '^(.*?\x0d?\x0a\x0d?\x0a)',
                            option => leaf 's',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => function_call { '_parse_header',
                            args => [
                                list { '()',
                                    data => branch { ',',
                                        left => branch { ',',
                                            left => leaf '$chunk',
                                            right => function_call { 'length',
                                                args => [
                                                    leaf '$1',
                                                ],
                                            },
                                        },
                                        right => leaf '$env',
                                    },
                                },
                            ],
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '-2',
                },
            ],
        },
        function { '_parse_header',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$chunk',
                                right => leaf '$eoh',
                            },
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$header',
                    right => function_call { 'substr',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => leaf '$chunk',
                                            right => leaf '0',
                                        },
                                        right => leaf '$eoh',
                                    },
                                    right => leaf '',
                                },
                            },
                        ],
                    },
                },
                branch { '=~',
                    left => leaf '$chunk',
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '^\x0d?\x0a\x0d?\x0a',
                    },
                },
                branch { '=',
                    left => leaf '@header',
                    right => function_call { 'split',
                        args => [
                            branch { ',',
                                left => regexp { '\x0d?\x0a',
                                },
                                right => leaf '$header',
                            },
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$request',
                    right => function_call { 'shift',
                        args => [
                            leaf '@header',
                        ],
                    },
                },
                leaf '@out',
                foreach_stmt { 'for',
                    cond => leaf '@header',
                    true_stmt => if_stmt { 'if',
                        expr => regexp { '^[ \t]+',
                        },
                        true_stmt => [
                            if_stmt { 'unless',
                                expr => leaf '@out',
                                true_stmt => Test::Compiler::Parser::return { 'return',
                                    body => leaf '-1',
                                },
                            },
                            branch { '.=',
                                left => array { '$out',
                                    idx => array_ref { '[]',
                                        data => leaf '-1',
                                    },
                                },
                                right => leaf '$_',
                            },
                        ],
                        false_stmt => else_stmt { 'else',
                            stmt => function_call { 'push',
                                args => [
                                    branch { ',',
                                        left => leaf '@out',
                                        right => leaf '$_',
                                    },
                                ],
                            },
                        },
                    },
                },
                leaf '$obj',
                list { '()',
                    data => branch { ',',
                        left => leaf '$major',
                        right => leaf '$minor',
                    },
                },
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$method',
                                right => leaf '$uri',
                            },
                            right => leaf '$http',
                        },
                    },
                    right => function_call { 'split',
                        args => [
                            branch { ',',
                                left => regexp { ' ',
                                },
                                right => leaf '$request',
                            },
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => branch { 'and',
                        left => leaf '$http',
                        right => branch { '=~',
                            left => leaf '$http',
                            right => regexp { '^HTTP\/(\d+)\.(\d+)$',
                                option => leaf 'i',
                            },
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => leaf '-1',
                    },
                },
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$major',
                            right => leaf '$minor',
                        },
                    },
                    right => list { '()',
                        data => branch { ',',
                            left => leaf '$1',
                            right => leaf '$2',
                        },
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'REQUEST_METHOD',
                        },
                    },
                    right => leaf '$method',
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'SERVER_PROTOCOL',
                        },
                    },
                    right => leaf 'HTTP/$major.$minor',
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'REQUEST_URI',
                        },
                    },
                    right => leaf '$uri',
                },
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$path',
                            right => leaf '$query',
                        },
                    },
                    right => branch { '=~',
                        left => leaf '$uri',
                        right => regexp { '^([^?]*)(?:\?(.*))?$',
                            option => leaf 's',
                        },
                    },
                },
                foreach_stmt { 'for',
                    cond => list { '()',
                        data => branch { ',',
                            left => leaf '$path',
                            right => leaf '$query',
                        },
                    },
                    true_stmt => if_stmt { 'if',
                        expr => branch { '&&',
                            left => function_call { 'defined',
                                args => [
                                ],
                            },
                            right => function_call { 'length',
                                args => [
                                ],
                            },
                        },
                        true_stmt => reg_replace { 's',
                            to => leaf '',
                            from => leaf '\#.*$',
                        },
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'PATH_INFO',
                        },
                    },
                    right => function_call { 'URI::Escape::uri_unescape',
                        args => [
                            leaf '$path',
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'QUERY_STRING',
                        },
                    },
                    right => branch { '||',
                        left => leaf '$query',
                        right => leaf '',
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'SCRIPT_NAME',
                        },
                    },
                    right => leaf '',
                },
                branch { '=',
                    left => leaf '$token',
                    right => reg_prefix { 'qr',
                        expr => leaf '[^][\x00-\x1f\x7f()<>@,;:\\\"\/?={} \t]+',
                    },
                },
                leaf '$k',
                foreach_stmt { 'for',
                    cond => leaf '@out',
                    true_stmt => [
                        if_stmt { 'if',
                            expr => branch { '=~',
                                left => leaf '$header',
                                right => reg_replace { 's',
                                    to => leaf '',
                                    from => leaf '^($token): ?',
                                },
                            },
                            true_stmt => [
                                branch { '=',
                                    left => leaf '$k',
                                    right => leaf '$1',
                                },
                                branch { '=~',
                                    left => leaf '$k',
                                    right => reg_replace { 's',
                                        to => leaf '_',
                                        from => leaf '-',
                                        option => leaf 'g',
                                    },
                                },
                                branch { '=',
                                    left => leaf '$k',
                                    right => function_call { 'uc',
                                        args => [
                                            leaf '$k',
                                        ],
                                    },
                                },
                                if_stmt { 'if',
                                    expr => branch { '!~',
                                        left => leaf '$k',
                                        right => regexp { '^(?:CONTENT_LENGTH|CONTENT_TYPE)$',
                                        },
                                    },
                                    true_stmt => branch { '=',
                                        left => leaf '$k',
                                        right => leaf 'HTTP_$k',
                                    },
                                },
                            ],
                            false_stmt => if_stmt { 'elsif',
                                expr => branch { '=~',
                                    left => leaf '$header',
                                    right => regexp { '^\s+',
                                    },
                                },
                                true_stmt => hash_ref { '{}',
                                },
                                false_stmt => else_stmt { 'else',
                                    stmt => Test::Compiler::Parser::return { 'return',
                                        body => leaf '-1',
                                    },
                                },
                            },
                        },
                        if_stmt { 'if',
                            expr => function_call { 'exists',
                                args => [
                                    branch { '->',
                                        left => leaf '$env',
                                        right => hash_ref { '{}',
                                            data => leaf '$k',
                                        },
                                    },
                                ],
                            },
                            true_stmt => branch { '.=',
                                left => branch { '->',
                                    left => leaf '$env',
                                    right => hash_ref { '{}',
                                        data => leaf '$k',
                                    },
                                },
                                right => leaf ', $header',
                            },
                            false_stmt => else_stmt { 'else',
                                stmt => branch { '=',
                                    left => branch { '->',
                                        left => leaf '$env',
                                        right => hash_ref { '{}',
                                            data => leaf '$k',
                                        },
                                    },
                                    right => leaf '$header',
                                },
                            },
                        },
                    ],
                    itr => leaf '$header',
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf '$eoh',
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::HTTPParser::PP;
use strict;
use warnings;
use URI::Escape;

sub parse_http_request {
    my($chunk, $env) = @_;
    $env ||= {};

    # pre-header blank lines are allowed (RFC 2616 4.1)
    $chunk =~ s/^(\x0d?\x0a)+//;
    return -2 unless length $chunk;

    # double line break indicates end of header; parse it
    if ($chunk =~ /^(.*?\x0d?\x0a\x0d?\x0a)/s) {
        return _parse_header($chunk, length $1, $env);
    }
    return -2;  # still waiting for unknown amount of header lines
}

sub _parse_header {
    my($chunk, $eoh, $env) = @_;

    my $header = substr($chunk, 0, $eoh,'');
    $chunk =~ s/^\x0d?\x0a\x0d?\x0a//;

    # parse into lines
    my @header  = split /\x0d?\x0a/,$header;
    my $request = shift @header;

    # join folded lines
    my @out;
    for(@header) {
        if(/^[ \t]+/) {
            return -1 unless @out;
            $out[-1] .= $_;
        } else {
            push @out, $_;
        }
    }

    # parse request or response line
    my $obj;
    my ($major, $minor);

    my ($method,$uri,$http) = split / /,$request;
    return -1 unless $http and $http =~ /^HTTP\/(\d+)\.(\d+)$/i;
    ($major, $minor) = ($1, $2);

    $env->{REQUEST_METHOD}  = $method;
    $env->{SERVER_PROTOCOL} = "HTTP/$major.$minor";
    $env->{REQUEST_URI}     = $uri;

    my($path, $query) = ( $uri =~ /^([^?]*)(?:\?(.*))?$/s );
    for ($path, $query) { s/\#.*$// if defined && length } # dumb clients sending URI fragments

    $env->{PATH_INFO}    = URI::Escape::uri_unescape($path);
    $env->{QUERY_STRING} = $query || '';
    $env->{SCRIPT_NAME}  = '';

    # import headers
    my $token = qr/[^][\x00-\x1f\x7f()<>@,;:\\"\/?={} \t]+/;
    my $k;
    for my $header (@out) {
        if ( $header =~ s/^($token): ?// ) {
            $k = $1;
            $k =~ s/-/_/g;
            $k = uc $k;

            if ($k !~ /^(?:CONTENT_LENGTH|CONTENT_TYPE)$/) {
                $k = "HTTP_$k";
            }
        } elsif ( $header =~ /^\s+/) {
            # multiline header
        } else {
            return -1;
        }

        if (exists $env->{$k}) {
            $env->{$k} .= ", $header";
        } else {
            $env->{$k} = $header;
        }
    }

    return $eoh;
}

1;

__END__

=head1 NAME

Plack::HTTPParser::PP - Pure perl fallback of HTTP::Parser::XS

=head1 DESCRIPTION

Do not use this module directly. Use L<Plack::HTTPParser> instead.

=head1 AUTHOR

Tatsuhiko Miyagawa

=cut


