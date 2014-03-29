package builder::MyBuilder;
use strict;
use warnings FATAL => 'all';
use 5.008005;
use base 'Module::Build::XSUtil';
use constant DEBUG => 1;

sub new {
    my ( $class, %args ) = @_;
    my @ignore_warnings_options = map { "-Wno-$_" } qw(missing-field-initializers);
    my $self = $class->SUPER::new(
        %args,
        generate_ppport_h    => 'include/ppport.h',
        needs_compiler_cpp   => 1,
        c_source => [qw/src/],
        xs_files => { 'src/Compiler-Parser.xs' => 'lib/Compiler/Parser.xs' },
        cc_warnings => 0, # TODO
        extra_compiler_flags => ['-Iinclude', @ignore_warnings_options, '-g3'],
        add_to_cleanup => [
            'lib/Compiler/Parser/*.o', 'lib/Compiler/Parser/*.c',
            'lib/Compiler/Parser/*.xs',
        ],
    );
    $self->{config}->set('optimize' => '-O0') if (DEBUG);
    return $self;
}

1;
