use strict;
use warnings;
use Data::Float::DoubleDouble qw(:all);

print "1..1\n";

my $nv = 3.5;
my $addon = 2 ** -250;

my $hex1 = NV2H($nv);

$nv += $addon;

my $hex2 = NV2H($nv);

if($hex1 ne $hex2) {print "ok 1\n"}
else {
  warn "\n\$hex1: $hex1\n\$hex2: $hex2\n";
  print "not ok 1\n";
}