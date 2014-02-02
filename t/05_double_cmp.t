# Testing 2 hypotheses:
# 1) That the 1st 16 hex chars match the 16 hex chars of a double of the same value
# 2) That the sign of the second double is '-' if the first double is greater than
#     the prescribed value ... otherwise is '+'.
# So far, both hypotheses appear to be correct.

use strict;
use warnings;
use Data::Float::DoubleDouble qw(:all);

my $t = 12;
print "1..$t\n";

eval {require Math::NV;};

if($@) {
  warn "Skipping all tests - couldn't load Math::NV\n";
  print "ok $_\n" for 1 .. $t;
  exit 0;
}

my $ok = 1;
my $ok3 = 1;

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . "e$exp";
    my $nv = Math::NV::nv($str);
    my $d_hex = D2H($nv);
    my $hex = NV2H($nv);
    my $h = substr($hex, 0, 16);
    if($h ne $d_hex) {
      warn "\nDouble: $d_hex\nNV: $h\n";
      $ok = 0;
    }
    my $double = H2D($d_hex);
    if(!is_sane($double, $nv)) {
      warn "\n\$double: $double\n\$nv: $nv\n";
      $ok3 = 0;
    }
  }
}

if($ok) {print "ok 1\n"}
else    {print "not ok 1\n"}

$ok = 1;
my $ok4 = 1;

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . "e-$exp";
    my $nv = Math::NV::nv($str);
    my $d_hex = D2H($nv);
    my $hex = NV2H($nv);
    my $h = substr($hex, 0, 16);
    if($h ne $d_hex) {
      warn "\nDouble: $d_hex\nNV: $h\n";
      $ok = 0;
    }
    my $double = H2D($d_hex);
    if(!is_sane($double, $nv)) {
      warn "\n\$double: $double\n\$nv: $nv\n";
      $ok4 = 0;
    }
  }
}

if($ok) {print "ok 2\n"}
else    {print "not ok 2\n"}

if($ok3) {print "ok 3\n"}
else     {print "not ok 3\n"}

if($ok) {print "ok 4\n"}
else    {print "not ok 4\n"}

$ok = 1;
$ok3 = 1;

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . "e$exp";
    my $nv = Math::NV::nv($str);
    my $d_hex = D2H($nv);
    my $hex = NV2H($nv);
    my $h = substr($hex, 0, 16);
    if($h ne $d_hex) {
      warn "\nDouble: $d_hex\nNV: $h\n";
      $ok = 0;
    }
    my $double = H2D($d_hex);
    if(!is_sane($double, $nv)) {
      warn "\n\$double: $double\n\$nv: $nv\n";
      $ok3 = 0;
    }
  }
}

if($ok) {print "ok 5\n"}
else    {print "not ok 5\n"}

if($ok3) {print "ok 6\n"}
else    {print "not ok 6\n"}

$ok = 1;
$ok4 = 1;

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . "e-$exp";
    my $nv = Math::NV::nv($str);
    my $d_hex = D2H($nv);
    my $hex = NV2H($nv);
    my $h = substr($hex, 0, 16);
    if($h ne $d_hex) {
      warn "\nDouble: $d_hex\nNV: $h\n";
      $ok = 0;
    }
    my $double = H2D($d_hex);
    if(!is_sane($double, $nv)) {
      warn "\n\$double: $double\n\$nv: $nv\n";
      $ok4 = 0;
    }
  }
}

if($ok) {print "ok 7\n"}
else    {print "not ok 7\n"}

if($ok4) {print "ok 8\n"}
else    {print "not ok 8\n"}

$ok = 1;
$ok4 = 1;

for my $exp(298 .. 304) {
  my $str = '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  my $d_hex = D2H($nv);
  my $hex = NV2H($nv);
  my $h = substr($hex, 0, 16);
  if($h ne $d_hex) {
    warn "\nDouble: $d_hex\nNV: $h\n";
    $ok = 0;
  }
  my $double = H2D($d_hex);
  if(!is_sane($double, $nv)) {
    warn "\n\$double: $double\n\$nv: $nv\n";
    $ok4 = 0;
  }
}

if($ok) {print "ok 9\n"}
else    {print "not ok 9\n"}

if($ok4) {print "ok 10\n"}
else    {print "not ok 10\n"}

$ok = 1;
$ok4 = 1;

for my $exp(298 .. 304) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  my $d_hex = D2H($nv);
  my $hex = NV2H($nv);
  my $h = substr($hex, 0, 16);
  if($h ne $d_hex) {
    warn "\nDouble: $d_hex\nNV: $h\n";
    $ok = 0;
  }
  my $double = H2D($d_hex);
  if(!is_sane($double, $nv)) {
    warn "\n\$double: $double\n\$nv: $nv\n";
    $ok4 = 0;
  }
}

if($ok) {print "ok 11\n"}
else    {print "not ok 11\n"}

if($ok4) {print "ok 12\n"}
else    {print "not ok 12\n"}


###############################
###############################

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

sub is_sane {
    my ($double, $nv) = (shift, shift);
    my @s = get_sign($nv);
    my $sign_check = $double > $nv ? '-' : '+';
    my $ret = $sign_check eq $s[1] ? 1 : 0;
    return $ret;
}