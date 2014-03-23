use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Handler/Apache1.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Handler::Apache1',
        },
        module { 'strict',
        },
        module { 'Apache::Request',
        },
        module { 'Apache::Constants',
            args => reg_prefix { 'qw',
                expr => leaf ':common :response',
            },
        },
        module { 'Plack::Util',
        },
        module { 'Scalar::Util',
        },
        leaf '%apps',
        function { 'new',
            body => function_call { 'bless',
                args => [
                    branch { ',',
                        left => hash_ref { '{}',
                        },
                        right => function_call { 'shift',
                            args => [
                            ],
                        },
                    },
                ],
            },
        },
        function { 'preload',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                foreach_stmt { 'for',
                    cond => leaf '@_',
                    true_stmt => branch { '->',
                        left => leaf '$class',
                        right => function_call { 'load_app',
                            args => [
                                leaf '$app',
                            ],
                        },
                    },
                    itr => leaf '$app',
                },
            ],
        },
        function { 'load_app',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '$app',
                        },
                    },
                    right => leaf '@_',
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '||=',
                        left => hash { '$apps',
                            key => hash_ref { '{}',
                                data => leaf '$app',
                            },
                        },
                        right => do_stmt { 'do',
                            stmt => [
                                hash { '$ENV',
                                    key => hash_ref { '{}',
                                        data => leaf 'MOD_PERL',
                                    },
                                },
                                function_call { 'delete',
                                    args => [
                                        hash { '$ENV',
                                            key => hash_ref { '{}',
                                                data => leaf 'MOD_PERL',
                                            },
                                        },
                                    ],
                                },
                                function_call { 'Plack::Util::load_psgi',
                                    args => [
                                        leaf '$app',
                                    ],
                                },
                            ],
                        },
                    },
                },
            ],
        },
        function { 'handler',
            body => [
                branch { '=',
                    left => leaf '$class',
                    right => leaf '__PACKAGE__',
                },
                branch { '=',
                    left => leaf '$r',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$psgi',
                    right => branch { '->',
                        left => leaf '$r',
                        right => function_call { 'dir_config',
                            args => [
                                leaf 'psgi_app',
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
                                    right => branch { '->',
                                        left => leaf '$class',
                                        right => function_call { 'load_app',
                                            args => [
                                                leaf '$psgi',
                                            ],
                                        },
                                    },
                                },
                            },
                        ],
                    },
                },
            ],
        },
        function { 'call_app',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$class',
                                right => leaf '$r',
                            },
                            right => leaf '$app',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '->',
                    left => leaf '$r',
                    right => function_call { 'subprocess_env',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$env',
                    right => hash_ref { '{}',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => branch { ',',
                                                            left => branch { ',',
                                                                left => branch { ',',
                                                                    left => leaf '%ENV',
                                                                    right => branch { '=>',
                                                                        left => leaf 'psgi.version',
                                                                        right => array_ref { '[]',
                                                                            data => branch { ',',
                                                                                left => leaf '1',
                                                                                right => leaf '1',
                                                                            },
                                                                        },
                                                                    },
                                                                },
                                                                right => branch { '=>',
                                                                    left => leaf 'psgi.url_scheme',
                                                                    right => three_term_operator { '?',
                                                                        cond => branch { '=~',
                                                                            left => branch { '||',
                                                                                left => hash { '$ENV',
                                                                                    key => hash_ref { '{}',
                                                                                        data => leaf 'HTTPS',
                                                                                    },
                                                                                },
                                                                                right => leaf 'off',
                                                                            },
                                                                            right => regexp { '^(?:on|1)$',
                                                                                option => leaf 'i',
                                                                            },
                                                                        },
                                                                        true_expr => leaf 'https',
                                                                        false_expr => leaf 'http',
                                                                    },
                                                                },
                                                            },
                                                            right => branch { '=>',
                                                                left => leaf 'psgi.input',
                                                                right => leaf '$r',
                                                            },
                                                        },
                                                        right => branch { '=>',
                                                            left => leaf 'psgi.errors',
                                                            right => single_term_operator { '*',
                                                                expr => handle { 'STDERR',
                                                                },
                                                            },
                                                        },
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'psgi.multithread',
                                                        right => function_call { 'Plack::Util::FALSE',
                                                            args => [
                                                            ],
                                                        },
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'psgi.multiprocess',
                                                    right => function_call { 'Plack::Util::TRUE',
                                                        args => [
                                                        ],
                                                    },
                                                },
                                            },
                                            right => branch { '=>',
                                                left => leaf 'psgi.run_once',
                                                right => function_call { 'Plack::Util::FALSE',
                                                    args => [
                                                    ],
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'psgi.streaming',
                                            right => function_call { 'Plack::Util::TRUE',
                                                args => [
                                                ],
                                            },
                                        },
                                    },
                                    right => branch { '=>',
                                        left => leaf 'psgi.nonblocking',
                                        right => function_call { 'Plack::Util::FALSE',
                                            args => [
                                            ],
                                        },
                                    },
                                },
                                right => branch { '=>',
                                    left => leaf 'psgix.harakiri',
                                    right => function_call { 'Plack::Util::TRUE',
                                        args => [
                                        ],
                                    },
                                },
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            branch { '=',
                                left => leaf '$HTTP_AUTHORIZATION',
                                right => branch { '->',
                                    left => branch { '->',
                                        left => leaf '$r',
                                        right => function_call { 'headers_in',
                                            args => [
                                            ],
                                        },
                                    },
                                    right => hash_ref { '{}',
                                        data => leaf 'Authorization',
                                    },
                                },
                            },
                        ],
                    },
                    true_stmt => branch { '=',
                        left => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'HTTP_AUTHORIZATION',
                            },
                        },
                        right => leaf '$HTTP_AUTHORIZATION',
                    },
                },
                branch { '=',
                    left => leaf '$vpath',
                    right => branch { '.',
                        left => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'SCRIPT_NAME',
                            },
                        },
                        right => branch { '||',
                            left => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'PATH_INFO',
                                },
                            },
                            right => leaf '',
                        },
                    },
                },
                branch { '=',
                    left => leaf '$location',
                    right => branch { '||',
                        left => branch { '->',
                            left => leaf '$r',
                            right => function_call { 'location',
                                args => [
                                ],
                            },
                        },
                        right => leaf '/',
                    },
                },
                branch { '=~',
                    left => leaf '$location',
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '/$',
                    },
                },
                branch { '=~',
                    left => branch { '=',
                        left => leaf '$path_info',
                        right => leaf '$vpath',
                    },
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '^\Q$location\E',
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'SCRIPT_NAME',
                        },
                    },
                    right => leaf '$location',
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'PATH_INFO',
                        },
                    },
                    right => leaf '$path_info',
                },
                branch { '=',
                    left => leaf '$res',
                    right => branch { '->',
                        left => leaf '$app',
                        right => list { '()',
                            data => leaf '$env',
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'eq',
                        left => function_call { 'ref',
                            args => [
                                leaf '$res',
                            ],
                        },
                        right => leaf 'ARRAY',
                    },
                    true_stmt => function_call { '_handle_response',
                        args => [
                            list { '()',
                                data => branch { ',',
                                    left => leaf '$r',
                                    right => leaf '$res',
                                },
                            },
                        ],
                    },
                    false_stmt => if_stmt { 'elsif',
                        expr => branch { 'eq',
                            left => function_call { 'ref',
                                args => [
                                    leaf '$res',
                                ],
                            },
                            right => leaf 'CODE',
                        },
                        true_stmt => branch { '->',
                            left => leaf '$res',
                            right => list { '()',
                                data => function { 'sub',
                                    body => function_call { '_handle_response',
                                        args => [
                                            list { '()',
                                                data => branch { ',',
                                                    left => leaf '$r',
                                                    right => array { '$_',
                                                        idx => array_ref { '[]',
                                                            data => leaf '0',
                                                        },
                                                    },
                                                },
                                            },
                                        ],
                                    },
                                },
                            },
                        },
                        false_stmt => else_stmt { 'else',
                            stmt => function_call { 'die',
                                args => [
                                    leaf 'Bad response $res',
                                ],
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'psgix.harakiri.commit',
                        },
                    },
                    true_stmt => branch { '->',
                        left => leaf '$r',
                        right => function_call { 'child_terminate',
                            args => [
                            ],
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => leaf 'OK',
                },
            ],
        },
        function { '_handle_response',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$r',
                            right => leaf '$res',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '$status',
                                right => leaf '$headers',
                            },
                            right => leaf '$body',
                        },
                    },
                    right => dereference { '@{',
                        expr => leaf '$res',
                    },
                },
                branch { '=',
                    left => leaf '$hdrs',
                    right => three_term_operator { '?',
                        cond => branch { '&&',
                            left => branch { '>=',
                                left => leaf '$status',
                                right => leaf '200',
                            },
                            right => branch { '<',
                                left => leaf '$status',
                                right => leaf '300',
                            },
                        },
                        true_expr => branch { '->',
                            left => leaf '$r',
                            right => function_call { 'headers_out',
                                args => [
                                ],
                            },
                        },
                        false_expr => branch { '->',
                            left => leaf '$r',
                            right => function_call { 'err_headers_out',
                                args => [
                                ],
                            },
                        },
                    },
                },
                function_call { 'Plack::Util::header_iter',
                    args => [
                        list { '()',
                            data => branch { ',',
                                left => leaf '$headers',
                                right => function { 'sub',
                                    body => [
                                        branch { '=',
                                            left => list { '()',
                                                data => branch { ',',
                                                    left => leaf '$h',
                                                    right => leaf '$v',
                                                },
                                            },
                                            right => leaf '@_',
                                        },
                                        if_stmt { 'if',
                                            expr => branch { 'eq',
                                                left => function_call { 'lc',
                                                    args => [
                                                        leaf '$h',
                                                    ],
                                                },
                                                right => leaf 'content-type',
                                            },
                                            true_stmt => branch { '->',
                                                left => leaf '$r',
                                                right => function_call { 'content_type',
                                                    args => [
                                                        leaf '$v',
                                                    ],
                                                },
                                            },
                                            false_stmt => else_stmt { 'else',
                                                stmt => branch { '->',
                                                    left => leaf '$hdrs',
                                                    right => function_call { 'add',
                                                        args => [
                                                            list { '()',
                                                                data => branch { '=>',
                                                                    left => leaf '$h',
                                                                    right => leaf '$v',
                                                                },
                                                            },
                                                        ],
                                                    },
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                    ],
                },
                branch { '->',
                    left => leaf '$r',
                    right => function_call { 'status',
                        args => [
                            leaf '$status',
                        ],
                    },
                },
                branch { '->',
                    left => leaf '$r',
                    right => function_call { 'send_http_header',
                        args => [
                        ],
                    },
                },
                if_stmt { 'if',
                    expr => function_call { 'defined',
                        args => [
                            leaf '$body',
                        ],
                    },
                    true_stmt => if_stmt { 'if',
                        expr => function_call { 'Plack::Util::is_real_fh',
                            args => [
                                leaf '$body',
                            ],
                        },
                        true_stmt => branch { '->',
                            left => leaf '$r',
                            right => function_call { 'send_fd',
                                args => [
                                    leaf '$body',
                                ],
                            },
                        },
                        false_stmt => else_stmt { 'else',
                            stmt => function_call { 'Plack::Util::foreach',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => leaf '$body',
                                            right => function { 'sub',
                                                body => branch { '->',
                                                    left => leaf '$r',
                                                    right => function_call { 'print',
                                                        args => [
                                                            leaf '@_',
                                                        ],
                                                    },
                                                },
                                            },
                                        },
                                    },
                                ],
                            },
                        },
                    },
                    false_stmt => else_stmt { 'else',
                        stmt => Test::Compiler::Parser::return { 'return',
                            body => function_call { 'Plack::Util::inline_object',
                                args => [
                                    branch { ',',
                                        left => branch { '=>',
                                            left => leaf 'write',
                                            right => function { 'sub',
                                                body => branch { '->',
                                                    left => leaf '$r',
                                                    right => function_call { 'print',
                                                        args => [
                                                            leaf '@_',
                                                        ],
                                                    },
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'close',
                                            right => function { 'sub',
                                                body => hash_ref { '{}',
                                                },
                                            },
                                        },
                                    },
                                ],
                            },
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
package Plack::Handler::Apache1;
use strict;
use Apache::Request;
use Apache::Constants qw(:common :response);

use Plack::Util;
use Scalar::Util;

my %apps; # psgi file to $app mapping

sub new { bless {}, shift }

sub preload {
    my $class = shift;
    for my $app (@_) {
        $class->load_app($app);
    }
}

sub load_app {
    my($class, $app) = @_;
    return $apps{$app} ||= do {
        # Trick Catalyst, CGI.pm, CGI::Cookie and others that check
        # for $ENV{MOD_PERL}.
        #
        # Note that we delete it instead of just localizing
        # $ENV{MOD_PERL} because some users may check if the key
        # exists, and we do it this way because "delete local" is new
        # in 5.12:
        # http://perldoc.perl.org/5.12.0/perldelta.html#delete-local
        local $ENV{MOD_PERL};
        delete $ENV{MOD_PERL};

        Plack::Util::load_psgi $app;
    };
}

sub handler {
    my $class = __PACKAGE__;
    my $r     = shift;
    my $psgi  = $r->dir_config('psgi_app');
    $class->call_app($r, $class->load_app($psgi));
}

sub call_app {
    my ($class, $r, $app) = @_;

    $r->subprocess_env; # let Apache create %ENV for us :)

    my $env = {
        %ENV,
        'psgi.version'        => [ 1, 1 ],
        'psgi.url_scheme'     => ($ENV{HTTPS}||'off') =~ /^(?:on|1)$/i ? 'https' : 'http',
        'psgi.input'          => $r,
        'psgi.errors'         => *STDERR,
        'psgi.multithread'    => Plack::Util::FALSE,
        'psgi.multiprocess'   => Plack::Util::TRUE,
        'psgi.run_once'       => Plack::Util::FALSE,
        'psgi.streaming'      => Plack::Util::TRUE,
        'psgi.nonblocking'    => Plack::Util::FALSE,
        'psgix.harakiri'      => Plack::Util::TRUE,
    };

    if (defined(my $HTTP_AUTHORIZATION = $r->headers_in->{Authorization})) {
        $env->{HTTP_AUTHORIZATION} = $HTTP_AUTHORIZATION;
    }

    my $vpath    = $env->{SCRIPT_NAME} . ($env->{PATH_INFO} || '');

    my $location = $r->location || "/";
       $location =~ s{/$}{};
    (my $path_info = $vpath) =~ s/^\Q$location\E//;

    $env->{SCRIPT_NAME} = $location;
    $env->{PATH_INFO}   = $path_info;

    my $res = $app->($env);

    if (ref $res eq 'ARRAY') {
        _handle_response($r, $res);
    }
    elsif (ref $res eq 'CODE') {
        $res->(sub {
            _handle_response($r, $_[0]);
        });
    }
    else {
        die "Bad response $res";
    }

    if ($env->{'psgix.harakiri.commit'}) {
        $r->child_terminate;
    }

    return OK;
}

sub _handle_response {
    my ($r, $res) = @_;
    my ($status, $headers, $body) = @{ $res };

    my $hdrs = ($status >= 200 && $status < 300)
        ? $r->headers_out : $r->err_headers_out;

    Plack::Util::header_iter($headers, sub {
        my($h, $v) = @_;
        if (lc $h eq 'content-type') {
            $r->content_type($v);
        } else {
            $hdrs->add($h => $v);
        }
    });

    $r->status($status);
    $r->send_http_header;

    if (defined $body) {
        if (Plack::Util::is_real_fh($body)) {
            $r->send_fd($body);
        } else {
            Plack::Util::foreach($body, sub { $r->print(@_) });
        }
    }
    else {
        return Plack::Util::inline_object
            write => sub { $r->print(@_) },
            close => sub { };
    }
}

1;

__END__


=head1 NAME

Plack::Handler::Apache1 - Apache 1.3.x mod_perl handlers to run PSGI application

=head1 SYNOPSIS

  <Location />
  SetHandler perl-script
  PerlHandler Plack::Handler::Apache1
  PerlSetVar psgi_app /path/to/app.psgi
  </Location>

  <Perl>
  use Plack::Handler::Apache1;
  Plack::Handler::Apache1->preload("/path/to/app.psgi");
  </Perl>

=head1 DESCRIPTION

This is a mod_perl handler module to run any PSGI application with mod_perl on Apache 1.3.x.

If you want to run PSGI applications I<behind> Apache instead of using
mod_perl, see L<Plack::Handler::FCGI> to run with FastCGI, or use
standalone HTTP servers such as L<Starman> or L<Starlet> proxied with
mod_proxy.

=head1 AUTHOR

Aaron Trevena

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack>

=cut


