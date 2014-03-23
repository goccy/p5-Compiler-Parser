use strict;
use warnings;
use Test::More;
use Compiler::Lexer;
use Compiler::Parser;
use Compiler::Parser::AST::Renderer;
use Test::Compiler::Parser;

subtest 'parse Plack/Request/Upload.pm' => sub {
    my $script = do { local $/; <DATA> };
    my $tokens = Compiler::Lexer->new('')->tokenize($script);
    my $ast = Compiler::Parser->new->parse($tokens);
    Compiler::Parser::AST::Renderer->new->render($ast);
    node_ok($ast->root, [
        Test::Compiler::Parser::package { 'Plack::Request::Upload',
        },
        module { 'strict',
        },
        module { 'warnings',
        },
        module { 'Carp',
            args => list { '()',
            },
        },
        function { 'new',
            body => [
                branch { '=',
                    left => list { '()',
                        data => branch { ',',
                            left => leaf '$class',
                            right => leaf '%args',
                        },
                    },
                    right => leaf '@_',
                },
                function_call { 'bless',
                    args => [
                        branch { ',',
                            left => hash_ref { '{}',
                                data => branch { ',',
                                    left => branch { ',',
                                        left => branch { ',',
                                            left => branch { ',',
                                                left => branch { '=>',
                                                    left => leaf 'headers',
                                                    right => hash { '$args',
                                                        key => hash_ref { '{}',
                                                            data => leaf 'headers',
                                                        },
                                                    },
                                                },
                                                right => branch { '=>',
                                                    left => leaf 'tempname',
                                                    right => hash { '$args',
                                                        key => hash_ref { '{}',
                                                            data => leaf 'tempname',
                                                        },
                                                    },
                                                },
                                            },
                                            right => branch { '=>',
                                                left => leaf 'size',
                                                right => hash { '$args',
                                                    key => hash_ref { '{}',
                                                        data => leaf 'size',
                                                    },
                                                },
                                            },
                                        },
                                        right => branch { '=>',
                                            left => leaf 'filename',
                                            right => hash { '$args',
                                                key => hash_ref { '{}',
                                                    data => leaf 'filename',
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                            right => leaf '$class',
                        },
                    ],
                },
            ],
        },
        function { 'filename',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'filename',
                },
            },
        },
        function { 'headers',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'headers',
                },
            },
        },
        function { 'size',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'size',
                },
            },
        },
        function { 'tempname',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'tempname',
                },
            },
        },
        function { 'path',
            body => branch { '->',
                left => array { '$_',
                    idx => array_ref { '[]',
                        data => leaf '0',
                    },
                },
                right => hash_ref { '{}',
                    data => leaf 'tempname',
                },
            },
        },
        function { 'content_type',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                branch { '->',
                    left => branch { '->',
                        left => leaf '$self',
                        right => hash_ref { '{}',
                            data => leaf 'headers',
                        },
                    },
                    right => function_call { 'content_type',
                        args => [
                            leaf '@_',
                        ],
                    },
                },
            ],
        },
        function { 'type',
            body => branch { '->',
                left => function_call { 'shift',
                    args => [
                    ],
                },
                right => function_call { 'content_type',
                    args => [
                        leaf '@_',
                    ],
                },
            },
        },
        function { 'basename',
            body => [
                branch { '=',
                    left => leaf '$self',
                    right => function_call { 'shift',
                        args => [
                        ],
                    },
                },
                if_stmt { 'unless',
                    expr => function_call { 'defined',
                        args => [
                            branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'basename',
                                },
                            },
                        ],
                    },
                    true_stmt => [
                        module { 'File::Spec::Unix',
                        },
                        branch { '=',
                            left => leaf '$basename',
                            right => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'filename',
                                },
                            },
                        },
                        branch { '=~',
                            left => leaf '$basename',
                            right => reg_replace { 's',
                                to => leaf '/',
                                from => leaf '\\\\',
                                option => leaf 'g',
                            },
                        },
                        branch { '=',
                            left => leaf '$basename',
                            right => branch { '->',
                                left => leaf 'File::Spec::Unix',
                                right => function_call { 'splitpath',
                                    args => [
                                        leaf '$basename',
                                        array_ref { '[]',
                                            data => leaf '2',
                                        },
                                    ],
                                },
                            },
                        },
                        branch { '=~',
                            left => leaf '$basename',
                            right => reg_replace { 's',
                                to => leaf '_',
                                from => leaf '[^\w\.-]+',
                                option => leaf 'g',
                            },
                        },
                        branch { '=',
                            left => branch { '->',
                                left => leaf '$self',
                                right => hash_ref { '{}',
                                    data => leaf 'basename',
                                },
                            },
                            right => leaf '$basename',
                        },
                    ],
                },
                branch { '->',
                    left => leaf '$self',
                    right => hash_ref { '{}',
                        data => leaf 'basename',
                    },
                },
            ],
        },
        leaf '1',
    ]);
};

done_testing;

__DATA__
package Plack::Request::Upload;
use strict;
use warnings;
use Carp ();

sub new {
    my($class, %args) = @_;

    bless {
        headers  => $args{headers},
        tempname => $args{tempname},
        size     => $args{size},
        filename => $args{filename},
    }, $class;
}

sub filename { $_[0]->{filename} }
sub headers  { $_[0]->{headers} }
sub size     { $_[0]->{size} }
sub tempname { $_[0]->{tempname} }
sub path     { $_[0]->{tempname} }

sub content_type {
    my $self = shift;
    $self->{headers}->content_type(@_);
}

sub type { shift->content_type(@_) }

sub basename {
    my $self = shift;
    unless (defined $self->{basename}) {
        require File::Spec::Unix;
        my $basename = $self->{filename};
        $basename =~ s|\\|/|g;
        $basename = ( File::Spec::Unix->splitpath($basename) )[2];
        $basename =~ s|[^\w\.-]+|_|g;
        $self->{basename} = $basename;
    }
    $self->{basename};
}

1;
__END__

=head1 NAME

Plack::Request::Upload - handles file upload requests

=head1 SYNOPSIS

  # $req is Plack::Request
  my $upload = $req->uploads->{field};

  $upload->size;
  $upload->path;
  $upload->content_type;
  $upload->basename;

=head1 METHODS

=over 4

=item size

Returns the size of Uploaded file.

=item path

Returns the path to the temporary file where uploaded file is saved.

=item content_type

Returns the content type of the uploaded file.

=item filename

Returns the original filename in the client.

=item basename

Returns basename for "filename".

=back

=head1 AUTHORS

Kazuhiro Osawa

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plack::Request>, L<Catalyst::Request::Upload>

=cut

