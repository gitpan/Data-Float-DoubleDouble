use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

my $t = 5;

print "1..$t\n";

my $count = 0;

my $zero = 0;
my $neg_zero = nv('-0.0');

my $inf = 'inf' + 0.0;
my $neg_inf = $inf * - 1;

my $nan = $inf / $inf;

print "Zeroes : $zero   ", NV2H($zero), "\n",
      "       : $neg_zero   ", NV2H($neg_zero), "\n",

      "Infs   : $inf  ", NV2H($inf), "\n",
      "       : $neg_inf ", NV2H($neg_inf), "\n",

      "NaN    : $nan  ", NV2H($nan), "\n";

for my $nv ($zero, $neg_zero, $inf, $neg_inf) {
  $count++;
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($h_redone ne $h || $nv_redone != $nv) {

    my $ok = 0;

    # Not a failure iff the second double is zero && the only difference is the sign of that zero.
    if((
        (substr($h, 16, 16) eq '8000000000000000' &&  substr($h_redone, 16, 16) eq '0000000000000000')
       ||
        (substr($h_redone, 16, 16) eq '8000000000000000' &&  substr($h, 16, 16) eq '0000000000000000')
       )
       &&
        (substr($h, 0, 16) eq substr($h_redone, 0, 16))
      ) {
      $ok = 1;
    }

    if($ok) {print "ok $count\n"}
    else {
      warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n\$h: $h\n\$h_redone: $h_redone\n";
      print "not ok $count\n";
    }
  }
  else {print "ok $count\n"}
}

my $hex = float_H($nan);
my $nv_redone = H_float($hex);

my $h = NV2H($nan);
my $h_redone = NV2H($nv_redone);

if("$nan" eq 'nan' && "$nv_redone" eq 'nan' && $h eq '7ff80000000000000000000000000000' &&
   $h_redone eq $h) {print "ok 5\n"}

else {
   warn "\n\$nan: $nan\n\$nv_redone: $nv_redone\n\$h: $h\n\$h_redone: $h_redone\n";
   print "not ok 5\n";
}
