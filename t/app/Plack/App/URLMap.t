use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/App/URLMap.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::App::URLMap',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::Component',
            },
        },
        module { 'constant',
            args => branch { '=>',
                left => leaf 'DEBUG',
                right => hash { '$ENV',
                    key => hash_ref { '{}',
                        data => leaf 'PLACK_URLMAP_DEBUG',
                    },
                },
            },
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        function { 'mount',
            body => branch { '->',
                left => function_call { 'shift',
                    args => [
                    ],
                },
                right => function_call { 'map',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'map',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$location',
                            right => leaf '$app',
                        },
                    },
                    right => leaf '@_',
                },
                leaf '$host',
                if_stmt { 'if',
                    expr => branch { '=~',
                        left => leaf '$location',
                        right => reg_prefix { 'm',
                            expr => leaf '^https?://(.*?)(/.*)',
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$host',
                            right => leaf '$1',
                        },
                        branch { '=',
                            left => leaf '$location',
                            right => leaf '$2',
                        },
                    ],
                },
                if_stmt { 'if',
                    expr => branch { '!~',
                        left => leaf '$location',
                        right => reg_prefix { 'm',
                            expr => leaf '^/',
                        },
                    },
                    true_stmt => function_call { 'Carp::croak',
                        args => [
                            leaf 'Paths need to start with /',
                        ],
                    },
                },
                branch { '=~',
                    left => leaf '$location',
                    right => reg_replace { 's',
                        to => leaf '',
                        from => leaf '/$',
                    },
                },
                function_call { 'push',
                    args => [
                        branch { ',',
                            left => dereference { '@{',
                                expr => branch { '->',
                                    left => leaf '$self',
                                    right => hash_ref { '{}',
                                        data => leaf '_mapping',
                                    },
                                },
                            },
                            right => array_ref { '[]',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => leaf '$host',
                                        right => leaf '$location',
                                    },
                                    right => leaf '$app',
                                },
                            },
                        },
                    ],
                },
            ],
        },
        function { 'prepare_app',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '=',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf '_sorted_mapping',
                        },
                    },
                    right => array_ref { '[]',
                        data => function_call { 'map',
                            args => [
                                array_ref { '[]',
                                    data => branch { '->',
                                        left => dereference { '@{',
                                            expr => leaf '$_',
                                        },
                                        right => array_ref { '[]',
                                            data => branch { '..',
                                                left => leaf '2',
                                                right => leaf '4',
                                            },
                                        },
                                    },
                                },
                                function_call { 'sort',
                                    args => [
                                        branch { '||',
                                            left => branch { '<=>',
                                                left => branch { '->',
                                                    left => leaf '$b',
                                                    right => array_ref { '[]',
                                                        data => leaf '0',
                                                    },
                                                },
                                                right => branch { '->',
                                                    left => leaf '$a',
                                                    right => array_ref { '[]',
                                                        data => leaf '0',
                                                    },
                                                },
                                            },
                                            right => branch { '<=>',
                                                left => branch { '->',
                                                    left => leaf '$b',
                                                    right => array_ref { '[]',
                                                        data => leaf '1',
                                                    },
                                                },
                                                right => branch { '->',
                                                    left => leaf '$a',
                                                    right => array_ref { '[]',
                                                        data => leaf '1',
                                                    },
                                                },
                                            },
                                        },
                                        function_call { 'map',
                                            args => [
                                                array_ref { '[]',
                                                    data => branch { ',',
                                                        left => branch { ',',
                                                            left => three_term_operator { '?',
                                                                cond => branch { '->',
                                                                    left => leaf '$_',
                                                                    right => array_ref { '[]',
                                                                        data => leaf '0',
                                                                    },
                                                                },
                                                                true_expr => function_call { 'length',
                                                                    args => [
                                                                        branch { '->',
                                                                            left => leaf '$_',
                                                                            right => array_ref { '[]',
                                                                                data => leaf '0',
                                                                            },
                                                                        },
                                                                    ],
                                                                },
                                                                false_expr => leaf '0',
                                                            },
                                                            right => function_call { 'length',
                                                                args => [
                                                                    branch { '->',
                                                                        left => leaf '$_',
                                                                        right => array_ref { '[]',
                                                                            data => leaf '1',
                                                                        },
                                                                    },
                                                                ],
                                                            },
                                                        },
                                                        right => dereference { '@$_',
                                                            expr => leaf '@$_',
                                                        },
                                                    },
                                                },
                                                branch { ',',
                                                    left => dereference { '@{',
                                                        expr => branch { '->',
                                                            left => leaf '$self',
                                                            right => hash_ref { '{}',
                                                                data => leaf '_mapping',
                                                            },
                                                        },
                                                    },
                                                },
                                            ],
                                        },
                                    ],
                                },
                            ],
                        },
                    },
                },
            ],
        },
        function { 'call',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$env',
                        },
                    },
                    right => leaf '@_',
                },
                branch { '=',
                    left => leaf '$path_info',
                    right => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'PATH_INFO',
                        },
                    },
                },
                branch { '=',
                    left => leaf '$script_name',
                    right => branch { '->',
                        left => leaf '$env',
                        right => hash_ref { '{}',
                            data => leaf 'SCRIPT_NAME',
                        },
                    },
                },
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$http_host',
                            right => leaf '$server_name',
                        },
                    },
                    right => branch { '->',
                        left => dereference { '@{',
                            expr => leaf '$env',
                        },
                        right => hash_ref { '{}',
                            data => reg_prefix { 'qw',
                                expr => leaf ' HTTP_HOST SERVER_NAME ',
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { 'and',
                        left => leaf '$http_host',
                        right => branch { '=',
                            left => leaf '$port',
                            right => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'SERVER_PORT',
                                },
                            },
                        },
                    },
                    true_stmt => branch { '=~',
                        left => leaf '$http_host',
                        right => reg_replace { 's',
                            to => leaf '',
                            from => leaf ':$port$',
                        },
                    },
                },
                foreach_stmt { 'for',
                    cond => dereference { '@{',
                        expr => branch { '->',
                            left => leaf '$self',
                            right => hash_ref { '{}',
                                data => leaf '_sorted_mapping',
                            },
                        },
                    },
                    true_stmt => [
                        branch { '=',
                            left => list { '()',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => leaf '$host',
                                        right => leaf '$location',
                                    },
                                    right => leaf '$app',
                                },
                            },
                            right => dereference { '@$map',
                                expr => leaf '@$map',
                            },
                        },
                        branch { '=',
                            left => leaf '$path',
                            right => leaf '$path_info',
                        },
                        function_call { 'no',
                            args => [
                                leaf 'warnings',
                                leaf 'uninitialized',
                            ],
                        },
                        branch { '&&',
                            left => leaf 'DEBUG',
                            right => function_call { 'warn',
                                args => [
                                    leaf 'Matching request (Host=$http_host Path=$path) and the map (Host=$host Path=$location)\n',
                                ],
                            },
                        },
                        if_stmt { 'unless',
                            expr => branch { 'or',
                                left => branch { 'or',
                                    left => single_term_operator { 'not',
                                        expr => function_call { 'defined',
                                            args => [
                                                leaf '$host',
                                            ],
                                        },
                                    },
                                    right => branch { 'eq',
                                        left => leaf '$http_host',
                                        right => leaf '$host',
                                    },
                                },
                                right => branch { 'eq',
                                    left => leaf '$server_name',
                                    right => leaf '$host',
                                },
                            },
                            true_stmt => control_stmt { 'next',
                            },
                        },
                        if_stmt { 'unless',
                            expr => branch { 'or',
                                left => branch { 'eq',
                                    left => leaf '$location',
                                    right => leaf '',
                                },
                                right => branch { '=~',
                                    left => leaf '$path',
                                    right => reg_replace { 's',
                                        to => leaf '',
                                        from => leaf '^\Q$location\E',
                                    },
                                },
                            },
                            true_stmt => control_stmt { 'next',
                            },
                        },
                        if_stmt { 'unless',
                            expr => branch { 'or',
                                left => branch { 'eq',
                                    left => leaf '$path',
                                    right => leaf '',
                                },
                                right => branch { '=~',
                                    left => leaf '$path',
                                    right => reg_prefix { 'm',
                                        expr => leaf '^/',
                                    },
                                },
                            },
                            true_stmt => control_stmt { 'next',
                            },
                        },
                        branch { '&&',
                            left => leaf 'DEBUG',
                            right => function_call { 'warn',
                                args => [
                                    leaf '-> Matched!\n',
                                ],
                            },
                        },
                        branch { '=',
                            left => leaf '$orig_path_info',
                            right => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'PATH_INFO',
                                },
                            },
                        },
                        branch { '=',
                            left => leaf '$orig_script_name',
                            right => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'SCRIPT_NAME',
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
                            right => leaf '$path',
                        },
                        branch { '=',
                            left => branch { '->',
                                left => leaf '$env',
                                right => hash_ref { '{}',
                                    data => leaf 'SCRIPT_NAME',
                                },
                            },
                            right => branch { '.',
                                left => leaf '$script_name',
                                right => leaf '$location',
                            },
                        },
                        Test::Compiler::Parser::return { 'return',
                            body => branch { '->',
                                left => leaf '$self',
                                right => function_call { 'response_cb',
                                    args => [
                                        list { '()',
                                            data => branch { ',',
                                                left => branch { '->',
                                                    left => leaf '$app',
                                                    right => list { '()',
                                                        data => leaf '$env',
                                                    },
                                                },
                                                right => function { 'sub',
                                                    body => [
                                                        branch { '=',
                                                            left => branch { '->',
                                                                left => leaf '$env',
                                                                right => hash_ref { '{}',
                                                                    data => leaf 'PATH_INFO',
                                                                },
                                                            },
                                                            right => leaf '$orig_path_info',
                                                        },
                                                        branch { '=',
                                                            left => branch { '->',
                                                                left => leaf '$env',
                                                                right => hash_ref { '{}',
                                                                    data => leaf 'SCRIPT_NAME',
                                                                },
                                                            },
                                                            right => leaf '$orig_script_name',
                                                        },
                                                    ],
                                                },
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                    ],
                    itr => leaf '$map',
                },
                branch { '&&',
                    left => leaf 'DEBUG',
                    right => function_call { 'warn',
                        args => [
                            leaf 'All matching failed.\n',
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => array_ref { '[]',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '404',
                                right => array_ref { '[]',
                                    data => branch { '=>',
                                        left => leaf 'Content-Type',
                                        right => leaf 'text/plain',
                                    },
                                },
                            },
                            right => array_ref { '[]',
                                data => leaf 'Not Found',
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
package Plack::App::URLMap;
use strict;
use warnings;
use parent qw(Plack::Component);
use constant DEBUG => $ENV{PLACK_URLMAP_DEBUG};

use Carp ();

sub mount { shift->map(@_) }

sub map {
    my $self = shift;
    my($location, $app) = @_;

    my $host;
    if ($location =~ m!^https?://(.*?)(/.*)!) {
        $host     = $1;
        $location = $2;
    }

    if ($location !~ m!^/!) {
        Carp::croak("Paths need to start with /");
    }
    $location =~ s!/$!!;

    push @{$self->{_mapping}}, [ $host, $location, $app ];
}

sub prepare_app {
    my $self = shift;
    # sort by path length
    $self->{_sorted_mapping} = [
        map  { [ @{$_}[2..4] ] }
        sort { $b->[0] <=> $a->[0] || $b->[1] <=> $a->[1] }
        map  { [ ($_->[0] ? length $_->[0] : 0), length($_->[1]), @$_ ] } @{$self->{_mapping}},
    ];
}

sub call {
    my ($self, $env) = @_;

    my $path_info   = $env->{PATH_INFO};
    my $script_name = $env->{SCRIPT_NAME};

    my($http_host, $server_name) = @{$env}{qw( HTTP_HOST SERVER_NAME )};

    if ($http_host and my $port = $env->{SERVER_PORT}) {
        $http_host =~ s/:$port$//;
    }

    for my $map (@{ $self->{_sorted_mapping} }) {
        my($host, $location, $app) = @$map;
        my $path = $path_info; # copy
        no warnings 'uninitialized';
        DEBUG && warn "Matching request (Host=$http_host Path=$path) and the map (Host=$host Path=$location)\n";
        next unless not defined $host     or
                    $http_host   eq $host or
                    $server_name eq $host;
        next unless $location eq '' or $path =~ s!^\Q$location\E!!;
        next unless $path eq '' or $path =~ m!^/!;
        DEBUG && warn "-> Matched!\n";

        my $orig_path_info   = $env->{PATH_INFO};
        my $orig_script_name = $env->{SCRIPT_NAME};

        $env->{PATH_INFO}  = $path;
        $env->{SCRIPT_NAME} = $script_name . $location;
        return $self->response_cb($app->($env), sub {
            $env->{PATH_INFO} = $orig_path_info;
            $env->{SCRIPT_NAME} = $orig_script_name;
        });
    }

    DEBUG && warn "All matching failed.\n";

    return [404, [ 'Content-Type' => 'text/plain' ], [ "Not Found" ]];
}

1;

__END__

=head1 NAME

Plack::App::URLMap - Map multiple apps in different paths

=head1 SYNOPSIS

  use Plack::App::URLMap;

  my $app1 = sub { ... };
  my $app2 = sub { ... };
  my $app3 = sub { ... };

  my $urlmap = Plack::App::URLMap->new;
  $urlmap->map("/" => $app1);
  $urlmap->map("/foo" => $app2);
  $urlmap->map("http://bar.example.com/" => $app3);

  my $app = $urlmap->to_app;

=head1 DESCRIPTION

Plack::App::URLMap is a PSGI application that can dispatch multiple
applications based on URL path and hostnames (a.k.a "virtual hosting")
and takes care of rewriting C<SCRIPT_NAME> and C<PATH_INFO> (See
L</"HOW THIS WORKS"> for details). This module is inspired by
Ruby's Rack::URLMap.

=head1 METHODS

=over 4

=item map

  $urlmap->map("/foo" => $app);
  $urlmap->map("http://bar.example.com/" => $another_app);

Maps URL path or an absolute URL to a PSGI application. The match
order is sorted by host name length and then path length (longest strings
first).

URL paths need to match from the beginning and should match completely
until the path separator (or the end of the path). For example, if you
register the path C</foo>, it I<will> match with the request C</foo>,
C</foo/> or C</foo/bar> but it I<won't> match with C</foox>.

Mapping URLs with host names is also possible, and in that case the URL
mapping works like a virtual host.

Mappings will nest.  If $app is already mapped to C</baz> it will
match a request for C</foo/baz> but not C</foo>. See L</"HOW THIS
WORKS"> for more details.

=item mount

Alias for C<map>.

=item to_app

  my $handler = $urlmap->to_app;

Returns the PSGI application code reference. Note that the
Plack::App::URLMap object is callable (by overloading the code
dereference), so returning the object itself as a PSGI application
should also work.

=back

=head1 DEBUGGING

You can set the environment variable C<PLACK_URLMAP_DEBUG> to see how
this application matches with the incoming request host names and
paths.

=head1 HOW THIS WORKS

This application works by I<fixing> C<SCRIPT_NAME> and C<PATH_INFO>
before dispatching the incoming request to the relocated
applications.

Say you have a Wiki application that takes C</index> and C</page/*>
and makes a PSGI application C<$wiki_app> out of it, using one of
supported web frameworks, you can put the whole application under
C</wiki> by:

  # MyWikiApp looks at PATH_INFO and handles /index and /page/*
  my $wiki_app = sub { MyWikiApp->run(@_) };
  
  use Plack::App::URLMap;
  my $app = Plack::App::URLMap->new;
  $app->mount("/wiki" => $wiki_app);

When a request comes in with C<PATH_INFO> set to C</wiki/page/foo>,
the URLMap application C<$app> strips the C</wiki> part from
C<PATH_INFO> and B<appends> that to C<SCRIPT_NAME>.

That way, if the C<$app> is mounted under the root
(i.e. C<SCRIPT_NAME> is C<"">) with standalone web servers like
L<Starman>, C<SCRIPT_NAME> is now locally set to C</wiki> and
C<PATH_INFO> is changed to C</page/foo> when C<$wiki_app> gets called.

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::Builder>

=cut

