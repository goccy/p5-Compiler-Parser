my $a = map { $_ + 2; 1 * 2; } @b;
my ($key, $value) = map URI::Escape::uri_unescape($_), split( "=", $pair, 2 );

@query = map {
    s/\+/ /g; URI::Escape::uri_unescape($_)
} map {
 /=/ ? split(/=/, $_, 2) : ($_ => '')
} split(/[&;]/, $query_string);

$self->{headers} = HTTP::Headers->new(
    map {
        (my $field = $_) =~ s/^HTTPS?_//;
        ( $field => $env->{$_} );
    } grep { /^(?:HTTP|CONTENT)/i } keys %$env
);
