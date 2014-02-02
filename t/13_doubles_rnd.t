# Check that the double matches exactly the *first* double of the double-double.
# Essentially the same as 05_double_cmp.t, except that here we're using doubles that
# were calculated on a perl where nvtype is double. (The nvtype shouldn't matter - 
# it's good to see that it doesn't.)

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
  my $hex_dump = NV2H($nv);

  # First 16 chars of $hex_dump should match $h{$k}
  if(substr($hex_dump, 0, 16) ne $h{$k}) { 
    $ok = 0;
    $count++;
    warn "\n$done: $k\n$h{$k} ", substr($hex_dump, 0, 16), "\n";
  }
}
 
if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

__END__

for my $k(keys(%h)) {
  my $nv = Math::NV::nv($k);
  my $hex = float_H($nv);
  my $hex_dump = NV2H($nv);
  my @bin = float_H2B($hex);
  next unless $bin[1] =~ /1/;
  $done++;

  my($double_hex, $roundup) = Data::Float::DoubleDouble::_bin2d(@bin, 1);

  if(!$roundup) { # First 16 chars of $hex_dump should match $h{$k}
    if(substr($hex_dump, 0, 16) ne $h{$k}) { 
      $ok = 0;
      $count++;
      warn "\n$done: $k: $roundup\n$h{$k} ", substr($hex_dump, 0, 16), "\n$bin[0] $bin[2]\n$bin[1]\n";
      #  unless $count > 5;
    }
  }
  else { # First 16 chars of $hex_dump should *not* match $h{$k}
    if(substr($hex_dump, 0, 16) ne $h{$k}) { 
      $ok = 0;
      $count++;
      warn "\n$done: $k: $roundup\n$h{$k} ", substr($hex_dump, 0, 16), "\n$bin[0] $bin[2]\n$bin[1]\n";
      #  unless $count > 5;
    }
  }
}

 
if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

__END__