use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/App/Directory.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::App::Directory',
        },
        module { 'parent',
            args => reg_prefix { 'qw',
                expr => leaf 'Plack::App::File',
            },
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'Plack::Util',
        },
        module { 'HTTP::Date',
        },
        module { 'Plack::MIME',
        },
        module { 'DirHandle',
        },
        module { 'URI::Escape',
        },
        module { 'Plack::Request',
        },
        branch { '=',
            left => leaf '$dir_file',
            right => leaf '<tr><td class=\'name\'><a href=\'%s\'>%s</a></td><td class=\'size\'>%s</td><td class=\'type\'>%s</td><td class=\'mtime\'>%s</td></tr>',
        },
        branch { '=',
            left => leaf '$dir_page',
            right => leaf '<html><head>
  <title>%s</title>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <style type=\'text/css\'>
table { width:100%%; }
.name { text-align:left; }
.size, .mtime { text-align:right; }
.type { width:11em; }
.mtime { width:15em; }
  </style>
</head><body>
<h1>%s</h1>
<hr />
<table>
  <tr>
    <th class=\'name\'>Name</th>
    <th class=\'size\'>Size</th>
    <th class=\'type\'>Type</th>
    <th class=\'mtime\'>Last Modified</th>
  </tr>
%s
</table>
<hr />
</body></html>
',
        },
        function { 'should_handle',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$self',
                            right => leaf '$file',
                        },
                    },
                    right => leaf '@_',
                },
                Test::Compiler::Parser::return { 'return',
                    body => branch { '||',
                        left => handle { '-d',
                            expr => leaf '$file',
                        },
                        right => handle { '-f',
                            expr => leaf '$file',
                        },
                    },
                },
            ],
        },
        function { 'return_dir_redirect',
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
                    left => leaf '$uri',
                    right => branch { '->',
                        left => branch { '->',
                            left => leaf 'Plack::Request',
                            right => function_call { 'new',
                                args => [
                                    leaf '$env',
                                ],
                            },
                        },
                        right => function_call { 'uri',
                            args => [
                            ],
                        },
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => array_ref { '[]',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => leaf '301',
                                    right => array_ref { '[]',
                                        data => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { '=>',
                                                        left => leaf 'Location',
                                                        right => branch { '.',
                                                            left => leaf '$uri',
                                                            right => leaf '/',
                                                        },
                                                    },
                                                    right => branch { '=>',
                                                        left => leaf 'Content-Type',
                                                        right => leaf 'text/plain',
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'Content-Length',
                                                    right => leaf '8',
                                                },
                                            },
                                        },
                                    },
                                },
                                right => array_ref { '[]',
                                    data => leaf 'Redirect',
                                },
                            },
                        },
                    },
                },
            ],
        },
        function { 'serve_path',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => branch { ',',
                                left => branch { ',',
                                    left => leaf '$self',
                                    right => leaf '$env',
                                },
                                right => leaf '$dir',
                            },
                            right => leaf '$fullpath',
                        },
                    },
                    right => leaf '@_',
                },
                if_stmt { 'if',
                    expr => handle { '-f',
                        expr => leaf '$dir',
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'SUPER::serve_path',
                                args => [
                                    list { '()',
                                        data => branch { ',',
                                            left => branch { ',',
                                                left => leaf '$env',
                                                right => leaf '$dir',
                                            },
                                            right => leaf '$fullpath',
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '$dir_url',
                    right => branch { '.',
                        left => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'SCRIPT_NAME',
                            },
                        },
                        right => branch { '->',
                            left => leaf '$env',
                            right => hash_ref { '{}',
                                data => leaf 'PATH_INFO',
                            },
                        },
                    },
                },
                if_stmt { 'if',
                    expr => branch { '!~',
                        left => leaf '$dir_url',
                        right => reg_prefix { 'm',
                            expr => leaf '/$',
                        },
                    },
                    true_stmt => Test::Compiler::Parser::return { 'return',
                        body => branch { '->',
                            left => leaf '$self',
                            right => function_call { 'return_dir_redirect',
                                args => [
                                    leaf '$env',
                                ],
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '@files',
                    right => list { '()',
                        data => array_ref { '[]',
                            data => branch { ',',
                                left => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => leaf '../',
                                            right => leaf 'Parent Directory',
                                        },
                                        right => leaf '',
                                    },
                                    right => leaf '',
                                },
                                right => leaf '',
                            },
                        },
                    },
                },
                branch { '=',
                    left => leaf '$dh',
                    right => branch { '->',
                        left => leaf 'DirHandle',
                        right => function_call { 'new',
                            args => [
                                leaf '$dir',
                            ],
                        },
                    },
                },
                leaf '@children',
                while_stmt { 'while',
                    expr => function_call { 'defined',
                        args => [
                            branch { '=',
                                left => leaf '$ent',
                                right => branch { '->',
                                    left => leaf '$dh',
                                    right => function_call { 'read',
                                        args => [
                                        ],
                                    },
                                },
                            },
                        ],
                    },
                    true_stmt => [
                        if_stmt { 'if',
                            expr => branch { 'or',
                                left => branch { 'eq',
                                    left => leaf '$ent',
                                    right => leaf '.',
                                },
                                right => branch { 'eq',
                                    left => leaf '$ent',
                                    right => leaf '..',
                                },
                            },
                            true_stmt => control_stmt { 'next' },
                        },
                        function_call { 'push',
                            args => [
                                branch { ',',
                                    left => leaf '@children',
                                    right => leaf '$ent',
                                },
                            ],
                        },
                    ],
                },
                foreach_stmt { 'for',
                    cond => function_call { 'sort',
                        args => [
                            branch { 'cmp',
                                left => leaf '$a',
                                right => leaf '$b',
                            },
                            leaf '@children',
                        ],
                    },
                    true_stmt => [
                        branch { '=',
                            left => leaf '$file',
                            right => leaf '$dir/$basename',
                        },
                        branch { '=',
                            left => leaf '$url',
                            right => branch { '.',
                                left => leaf '$dir_url',
                                right => leaf '$basename',
                            },
                        },
                        branch { '=',
                            left => leaf '$is_dir',
                            right => handle { '-d',
                                expr => leaf '$file',
                            },
                        },
                        branch { '=',
                            left => leaf '@stat',
                            right => function_call { 'stat',
                                args => [
                                    leaf '_',
                                ],
                            },
                        },
                        branch { '=',
                            left => leaf '$url',
                            right => function_call { 'join',
                                args => [
                                    branch { ',',
                                        left => leaf '/',
                                        right => function_call { 'map',
                                            args => [
                                                function_call { 'uri_escape',
                                                    args => [
                                                        leaf '$_',
                                                    ],
                                                },
                                                function_call { 'split',
                                                    args => [
                                                        branch { ',',
                                                            left => reg_prefix { 'm',
                                                                expr => leaf '/',
                                                            },
                                                            right => leaf '$url',
                                                        },
                                                    ],
                                                },
                                            ],
                                        },
                                    },
                                ],
                            },
                        },
                        if_stmt { 'if',
                            expr => leaf '$is_dir',
                            true_stmt => [
                                branch { '.=',
                                    left => leaf '$basename',
                                    right => leaf '/',
                                },
                                branch { '.=',
                                    left => leaf '$url',
                                    right => leaf '/',
                                },
                            ],
                        },
                        branch { '=',
                            left => leaf '$mime_type',
                            right => three_term_operator { '?',
                                cond => leaf '$is_dir',
                                true_expr => leaf 'directory',
                                false_expr => branch { '||',
                                    left => branch { '->',
                                        left => leaf 'Plack::MIME',
                                        right => function_call { 'mime_type',
                                            args => [
                                                leaf '$file',
                                            ],
                                        },
                                    },
                                    right => leaf 'text/plain',
                                },
                            },
                        },
                        function_call { 'push',
                            args => [
                                branch { ',',
                                    left => leaf '@files',
                                    right => array_ref { '[]',
                                        data => branch { ',',
                                            left => branch { ',',
                                                left => branch { ',',
                                                    left => branch { ',',
                                                        left => leaf '$url',
                                                        right => leaf '$basename',
                                                    },
                                                    right => array { '$stat',
                                                        idx => array_ref { '[]',
                                                            data => leaf '7',
                                                        },
                                                    },
                                                },
                                                right => leaf '$mime_type',
                                            },
                                            right => function_call { 'HTTP::Date::time2str',
                                                args => [
                                                    array { '$stat',
                                                        idx => array_ref { '[]',
                                                            data => leaf '9',
                                                        },
                                                    },
                                                ],
                                            },
                                        },
                                    },
                                },
                            ],
                        },
                    ],
                    itr => leaf '$basename',
                },
                branch { '=',
                    left => leaf '$path',
                    right => function_call { 'Plack::Util::encode_html',
                        args => [
                            leaf 'Index of $env->{PATH_INFO}',
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$files',
                    right => function_call { 'join',
                        args => [
                            branch { ',',
                                left => leaf '\n',
                                right => function_call { 'map',
                                    args => [
                                        [
                                            branch { '=',
                                                left => leaf '$f',
                                                right => leaf '$_',
                                            },
                                            function_call { 'sprintf',
                                                args => [
                                                    branch { ',',
                                                        left => leaf '$dir_file',
                                                        right => function_call { 'map',
                                                            args => [
                                                                branch { ',',
                                                                    left => function_call { 'Plack::Util::encode_html',
                                                                        args => [
                                                                            leaf '$_',
                                                                        ],
                                                                    },
                                                                    right => dereference { '@$f',
                                                                        expr => leaf '@$f',
                                                                    },
                                                                },
                                                            ],
                                                        },
                                                    },
                                                ],
                                            },
                                        ],
                                        leaf '@files',
                                    ],
                                },
                            },
                        ],
                    },
                },
                branch { '=',
                    left => leaf '$page',
                    right => function_call { 'sprintf',
                        args => [
                            branch { ',',
                                left => branch { ',',
                                    left => branch { ',',
                                        left => leaf '$dir_page',
                                        right => leaf '$path',
                                    },
                                    right => leaf '$path',
                                },
                                right => leaf '$files',
                            },
                        ],
                    },
                },
                Test::Compiler::Parser::return { 'return',
                    body => array_ref { '[]',
                        data => branch { ',',
                            left => branch { ',',
                                left => leaf '200',
                                right => array_ref { '[]',
                                    data => branch { '=>',
                                        left => leaf 'Content-Type',
                                        right => leaf 'text/html; charset=utf-8',
                                    },
                                },
                            },
                            right => array_ref { '[]',
                                data => leaf '$page',
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
package Plack::App::Directory;
use parent qw(Plack::App::File);
use strict;
use warnings;
use Plack::Util;
use HTTP::Date;
use Plack::MIME;
use DirHandle;
use URI::Escape;
use Plack::Request;

# Stolen from rack/directory.rb
my $dir_file = "<tr><td class='name'><a href='%s'>%s</a></td><td class='size'>%s</td><td class='type'>%s</td><td class='mtime'>%s</td></tr>";
my $dir_page = <<PAGE;
<html><head>
  <title>%s</title>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <style type='text/css'>
table { width:100%%; }
.name { text-align:left; }
.size, .mtime { text-align:right; }
.type { width:11em; }
.mtime { width:15em; }
  </style>
</head><body>
<h1>%s</h1>
<hr />
<table>
  <tr>
    <th class='name'>Name</th>
    <th class='size'>Size</th>
    <th class='type'>Type</th>
    <th class='mtime'>Last Modified</th>
  </tr>
%s
</table>
<hr />
</body></html>
PAGE

sub should_handle {
    my($self, $file) = @_;
    return -d $file || -f $file;
}

sub return_dir_redirect {
    my ($self, $env) = @_;
    my $uri = Plack::Request->new($env)->uri;
    return [ 301,
        [
            'Location' => $uri . '/',
            'Content-Type' => 'text/plain',
            'Content-Length' => 8,
        ],
        [ 'Redirect' ],
    ];
}

sub serve_path {
    my($self, $env, $dir, $fullpath) = @_;

    if (-f $dir) {
        return $self->SUPER::serve_path($env, $dir, $fullpath);
    }

    my $dir_url = $env->{SCRIPT_NAME} . $env->{PATH_INFO};

    if ($dir_url !~ m{/$}) {
        return $self->return_dir_redirect($env);
    }

    my @files = ([ "../", "Parent Directory", '', '', '' ]);

    my $dh = DirHandle->new($dir);
    my @children;
    while (defined(my $ent = $dh->read)) {
        next if $ent eq '.' or $ent eq '..';
        push @children, $ent;
    }

    for my $basename (sort { $a cmp $b } @children) {
        my $file = "$dir/$basename";
        my $url = $dir_url . $basename;

        my $is_dir = -d $file;
        my @stat = stat _;

        $url = join '/', map {uri_escape($_)} split m{/}, $url;

        if ($is_dir) {
            $basename .= "/";
            $url      .= "/";
        }

        my $mime_type = $is_dir ? 'directory' : ( Plack::MIME->mime_type($file) || 'text/plain' );
        push @files, [ $url, $basename, $stat[7], $mime_type, HTTP::Date::time2str($stat[9]) ];
    }

    my $path  = Plack::Util::encode_html("Index of $env->{PATH_INFO}");
    my $files = join "\n", map {
        my $f = $_;
        sprintf $dir_file, map Plack::Util::encode_html($_), @$f;
    } @files;
    my $page  = sprintf $dir_page, $path, $path, $files;

    return [ 200, ['Content-Type' => 'text/html; charset=utf-8'], [ $page ] ];
}

1;

__END__

=head1 NAME

Plack::App::Directory - Serve static files from document root with directory index

=head1 SYNOPSIS

  # app.psgi
  use Plack::App::Directory;
  my $app = Plack::App::Directory->new({ root => "/path/to/htdocs" })->to_app;

=head1 DESCRIPTION

This is a static file server PSGI application with directory index a la Apache's mod_autoindex.

=head1 CONFIGURATION

=over 4

=item root

Document root directory. Defaults to the current directory.

=back

=head1 AUTHOR

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::App::File>

=cut

