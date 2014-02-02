# Check that double-double, when rounded to a double, is as expected.

use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);
require 't/doubles.p';

my $t = 1;

print "1..$t\n";

my %h = get_doubles();
die "Couldn't load doubles"
  unless $h{'455504204489529e1'} eq '43302ec95f05e03a';

my($ok, $count, $done) = (1,0, 0);

for my $k(keys(%h)) {
  my $nv = Math::NV::nv($k);
  my $hex = float_H($nv);
  my @bin = float_H2B($hex);
  next unless $bin[1] =~ /1/;
  $done++;

  my($double_hex, $roundup) = Data::Float::DoubleDouble::_bin2d(@bin, 1);

  if($double_hex ne $h{$k}) {
    $ok = 0;
    $count++;
    warn "\n$done: $k\n$h{$k} $double_hex\n$bin[0] $bin[2]\n$bin[1]\n";
    #  unless $count > 5;
  }
}

 
if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

__END__