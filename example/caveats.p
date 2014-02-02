# We demonstrate a couple of caveats regarding hex_float and float_hex conversions.

use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

# For most NV's the following will print 'ok 1':

# $nv = 700e-289;
# $hex = float_H($nv);
# $nv_redone = H_float($hex);
# $hex_redone = float_H($nv_redone);
# print "ok 1\n" if $nv == $nv_redone && $hex eq $hex_redone;

# But for some values (and 700e-289 is one such value, on my machine anyway),
# because of a bug in perl that no-one can be bothered fixing, perl assigns
# the wrong value. Math::NV assigns correctly - and that code needs to be
# rewritten as follows:

# use Math::NV qw(nv);
# $nv = nv('700e-289');
# $hex = float_H($nv);
# $nv_redone = H_float($hex);
# $hex_redone = float_H($nv_redone);
# print "ok 1\n" if $nv == $nv_redone && $hex eq $hex_redone;


print "\n   Without Math::NV\n   ================\n";

print " Internal representations:\n";

for(2123742e-10, 3114947e-10, 550275e-280, 700e-289, 7589718e-282) {
  print NV2H($_), "\n";
}

for(2123742e-10, 3114947e-10, 550275e-280, 700e-289, 7589718e-282) {
 my $nv = $_;
 my $hex = float_H($nv);
 my $nv_redone = H_float($hex);
 my $hex_redone = float_H($nv_redone);

 $nv == $nv_redone ? print " $nv NV's match\n" : print " $nv NV's do NOT match\n";
 $hex eq $hex_redone ? print " $nv Hex's match\n" : print " $nv Hex's do NOT match\n";
}

print "\n   With Math::NV (unquoted)\n   ========================\n";

print " Internal representations:\n";

for(2123742e-10, 3114947e-10, 550275e-280, 700e-289, 7589718e-282) {
  print NV2H(nv($_)), "\n";
}

for(2123742e-10, 3114947e-10, 550275e-280, 700e-289, 7589718e-282) {
 my $nv = nv($_);
 my $hex = float_H($nv);
 my $nv_redone = H_float($hex);
 my $hex_redone = float_H($nv_redone);

 $nv == $nv_redone ? print " $nv NV's match\n" : print " $nv NV's do NOT match\n";
 $hex eq $hex_redone ? print " $nv Hex's match\n" : print " $nv Hex's do NOT match\n";
}

print "\n   With Math::NV (quoted)\n   ======================\n";

print " Internal representations:\n";

for('2123742e-10', '3114947e-10', '550275e-280', '700e-289', '7589718e-282') {
  print NV2H(nv($_)), "\n";
}

for('2123742e-10', '3114947e-10', '550275e-280', '700e-289', '7589718e-282') {
 my $nv = nv($_);
 my $hex = float_H($nv);
 my $nv_redone = H_float($hex);
 my $hex_redone = float_H($nv_redone);

 $nv == $nv_redone ? print " $nv NV's match\n" : print " $nv NV's do NOT match\n";
 $hex eq $hex_redone ? print " $nv Hex's match\n" : print " $nv Hex's do NOT match\n";
}

# Further, we can deduce from the results of the above that different NV's reduce to
# an identical (106 bit) hex dump.
# This is because not all double-double NV's can accurately be represented in 106 bits.
# As an extreme example:

print "\n   56.0 + (2 ** -150)\n   ==================\n";

my $nv1 = 56.0;
my $nv2 = $nv1 + (2 ** -150);

print " Intermediate zeroes: ", inter_zero(get_exp($nv2)), "\n\n";

$nv1 == $nv2 ? print "$nv1 == $nv2 ... UNEXPECTED result\n"
             : print "\$nv1 != \$nv2 ... expected result\n";

my $h1 = float_H($nv1);
my $h2 = float_H($nv2);

print " \$nv1 (internal representation): ", NV2H($nv1),
    "\n \$nv2 (internal representation): ", NV2H($nv2), "\n";

$h1 eq $h2 ? print " 106-bit hex dump: $h1\n \$h1 eq \$h2 ... expected result\n"
           : print " $h1 ne $h2 ... UNEXPECTED result\n";

# So, there we see 2 different values ($nv1 and $nv2) having the
# the same hex dump - for the simple reason that the nearest 106
# bit representation of $nv2 is the same as the nearest (which,
# in this case, is exact) representation of $nv1 (56.0).
# The same thing was happening in the first examples - perl
# was assigning value that was slightly different ot the value
# that Math::NV::nv() assigned - yet both values, when rounded
# to 106 bits, were identical.

# Next we see that, although $nv1 != $nv2, ($nv1 * 1.1) == ($nv2 * 1.1)

$nv1 * 1.1 == $nv2 * 1.1 ? print " (\$nv1 * 1.1) == (\$nv2 * 1.1) ... as expected\n"
                         : print " (\$nv1 * 1.1) != (\$nv2 * 1.1) ... UNEXPECTED\n";

__END__

for my $exp(-300 .. -280, -30, -20, -10..10, 20, 30, 280 .. 300) {
  for my $digits(1..30) {
    my $str = random_select($digits) . "e$exp";

    my $nv = $str + 0.0;
    my $h = float_H($nv1);

    my $nv_redone = H_float($h);
    my $h_redone = float_H($nv_redone);

    #print "." if $nv1 != $nv2;

    if($h ne $h_redone) {
      die "Totally unexpected !!! $str"
        if $nv == $nv_redone; 
      print " $str:\n $h $h_redone";
    }
  }
}

print "\n";


sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

__END__

2123742e-10
3114947e-10
12283e-280
550275e-280
700e-289
2719821e-289