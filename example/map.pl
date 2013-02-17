my @a = (1, 2, 3, 4);
my @b = map {$_ * 2} map { $_ * 3; $_; } @a;
my @chars = map(chr, @a);
my @c = map +( $_ => 1 ), @a;
print @b, "\n";
