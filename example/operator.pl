$v = $a->{b}->c;
my $v = $a->{b}->c(defined $a && 1 || $b < 3 || $c > 5);
$v + $v + $v++ + $v-- * ++$v / --$v % $v x $v + $v ** $v ** $v;
!$v + ~$v + \$v + +$v - +($v) - -$v - -($v) << $v >> $v + $v & $v + $v | $v + $v ^ $v;
my $a = $v =~ $v =~ $v !~ $v;
#my $a = ((($v =~ $v) =~ $v) !~ $v);
my $b = $v < $v && $v > $v || $v gt $v && $v le $v || $v == $v && $v <=> $v;# || $v ~~ $v;
#my $b = $v < $v && $v > $v || $v gt $v && $v le $v || $v == $v && $v <=> $v || $v ~~ $v;
my $c = $v += $v -= $v *= $v;
print $v || $v , $v && $v, $v + $v * $v, $v;
#print (((($v || $v) , ($v && $v)), ($v + ($v * $v))), $v);
print + $v || $v , $v && $v, $v + $v * $v, $v;
print - $v || $v => $v && $v => $v + $v * $v => $v;
$v = $a->{b}->c(defined $a) || die "died";
$v = $a->{b}->c($a) or die "died";
if (!defined $v{0}) {}
if (!defined $v{0} || 1) {}
if (!defined $v[0]) {}
if (!defined $v[0] || 1) {}
if (!defined $v->[0]) {}
if (!defined $v->[0] || 1) {}
if (!defined $v->{0}) {}
if (!defined $v->{0} || 1) {}
if (!defined $v->{0}->[0]) {}
if (!defined $v->{0}->[0] || 1) {}
if (!defined $v->[0]->{0}) {}
if (!defined $v->[0]->{0} + 1) {}
if (!defined $v->[0]->{0} && undef) {}
if (!defined $v->[0]->{0} + 1 && undef) {}
!print $v->[0]->{0} + 1 && undef;
defined $v->[0]->{0} + 1 && undef;
print $v->[0]->{0} + 1 && undef;
print $v->[0]->{0} + 1 && undef xor die "hoge";
print reverse sort keys values %v;
