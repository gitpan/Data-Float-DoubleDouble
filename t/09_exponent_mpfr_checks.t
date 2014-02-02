# In this script we're just checking that we've got the correct exponent for the binary string
# rendition of the double-double. Because we're passing the actual NV to Math::MPFR,
# we can use default mpfr precision of 106 throughout.
# However, it's important that we assign the value of the NV using nv().

use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

my $t = 6;

print "1..$t\n";

eval {require Math::MPFR;};
if($@) {
  warn "\n Skipping all tests - couldn't load Math::MPFR.",
       "\n (09_exponent_mpfr_checks.t requires Math::MPFR)\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

Math::MPFR::Rmpfr_set_default_prec(Math::MPFR::_LDBL_MANT_DIG());

my($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    next if (!$nv || are_inf($nv));
    my @exp = get_exp($nv);

    my @fr = Math::MPFR::Rmpfr_deref2(Math::MPFR->new($nv), 2, 0, 0);

    if($exp[0] ne ($fr[1] - 1)) {
      $count++;
      warn "\n$nv\n$fr[1] $exp[0] $exp[1]\n$fr[0]\n"
        unless $count > 10;
      $ok = 0;
    }
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    next if (!$nv || are_inf($nv));
    my @exp = get_exp($nv);

    my @fr = Math::MPFR::Rmpfr_deref2(Math::MPFR->new($nv), 2, 0, 0);

    if($exp[0] ne ($fr[1] - 1)) {
      $count++;
      warn "\n$nv\n$fr[1] $exp[0] $exp[1]\n$fr[0]\n"
        unless $count > 10;
      $ok = 0;
    }
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    next if (!$nv || are_inf($nv));
    die "NV should be less than zero"
      unless $nv < 0;
    my @exp = get_exp($nv);

    my @fr = Math::MPFR::Rmpfr_deref2(Math::MPFR->new($nv), 2, 0, 0);

    if($exp[0] ne ($fr[1] - 1)) {
      $count++;
      warn "\n$nv\n$fr[1] $exp[0] $exp[1]\n$fr[0]\n"
        unless $count > 10;
      $ok = 0;
    }
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    next if (!$nv || are_inf($nv));
    die "NV should be less than zero"
      unless $nv < 0;
    my @exp = get_exp($nv);

    my @fr = Math::MPFR::Rmpfr_deref2(Math::MPFR->new($nv), 2, 0, 0);

    if($exp[0] ne ($fr[1] - 1)) {
      $count++;
      warn "\n$nv\n$fr[1] $exp[0] $exp[1]\n$fr[0]\n"
        unless $count > 10;
      $ok = 0;
    }
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  next if (!$nv || are_inf($nv));
  my @exp = get_exp($nv);

  my @fr = Math::MPFR::Rmpfr_deref2(Math::MPFR->new($nv), 2, 0, 0);

  my @bin = float_H2B(float_H($nv));

  my $add = 0;

  while(substr($bin[1], $add, 1) eq '0') {
    $add++;
  }

  if($exp[0] ne ($fr[1] + $add - 1)) {
    $count++;
    warn "\n$nv\n$fr[1] $exp[0] $exp[1]\n$fr[0]\n$bin[1]\n"
      unless $count > 10;
    $ok = 0;
  }
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  next if (!$nv || are_inf($nv));
  die "NV should be less than zero"
    unless $nv < 0;
  my @exp = get_exp($nv);

  my @fr = Math::MPFR::Rmpfr_deref2(Math::MPFR->new($nv), 2, 0, 0);

  my @bin = float_H2B(float_H($nv));

  my $add = 0;

  while(substr($bin[1], $add, 1) eq '0') {
    $add++;
  }

  if($exp[0] ne ($fr[1] + $add - 1)) {
    $count++;
    warn "\n$nv\n$fr[1] $exp[0] $exp[1]\n$fr[0]\n$bin[1]\n"
      unless $count > 10;
    $ok = 0;
  }
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

######################################
######################################

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

__END__

