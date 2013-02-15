sub hoge {
	print @_, "\n";
	return 2;
}

my $val = 1;
if (!$val) {
    print "true\n";
}

print hoge * 2, "\n";
#$val++;
++$val;
#$val--;
--$val;
#$val = ++$val + ($val)++;
$val = +$val - -$val;
$val = -$val + +$val;
$val & $val;
\@val;
\%val;
\&$val;
print $val, "\n";
