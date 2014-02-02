# Here we check that the hex format returned by float_H converts to binary and
# and back again correctly (using float_H2B and B2float_H).

use warnings;
use strict;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

my $t = 6;

print "1..$t\n";

my($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    #next if(!$nv || are_inf($nv));
    my @f = float_H($nv);
    my $hex = shift @f;
    my @check = float_H2B($hex);
    my $check = B2float_H(@check);

    if($check ne $hex) {
      $count++;
      warn "\n$nv\n$hex $check\n"
       unless $count > 10;
    }

    if($f[0] ne $check[0]) {
      $count++;
      warn "\n$nv\n$f[0] $check[0]\n"
       unless $count > 10;
    }

    if(standardise_bin_mant($f[1]) ne $check[1]) {
      $count++;
      warn "\n$nv\n", standardise_bin_mant($f[1]), "\n$check[1]\n"
       unless $count > 10;
    }

    if($f[2] ne $check[2]) {
      $count++;
      warn "\n$nv\n$f[2] $check[2]\n"
       unless $count > 10;
    }

    $ok = 0 if $count;
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

($count, $ok) = (0, 1);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    #next if(!$nv || are_inf($nv));
    my @f = float_H($nv);
    my $hex = shift @f;
    my @check = float_H2B($hex);
    my $check = B2float_H(@check);

    if($check ne $hex) {
      $count++;
      warn "\n$nv\n$hex $check\n"
       unless $count > 10;
    }

    if($f[0] ne $check[0]) {
      $count++;
      warn "\n$nv\n$f[0] $check[0]\n"
       unless $count > 10;
    }

    if(standardise_bin_mant($f[1]) ne $check[1]) {
      $count++;
      warn "\n$nv\n", standardise_bin_mant($f[1]), "\n$check[1]\n"
       unless $count > 10;
    }

    if($f[2] ne $check[2]) {
      $count++;
      warn "\n$nv\n$f[2] $check[2]\n"
       unless $count > 10;
    }

    $ok = 0 if $count;
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

($count, $ok) = (0, 1);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    #next if(!$nv || are_inf($nv));
    my @f = float_H($nv);
    my $hex = shift @f;
    my @check = float_H2B($hex);
    my $check = B2float_H(@check);

    if($check ne $hex) {
      $count++;
      warn "\n$nv\n$hex $check\n"
       unless $count > 10;
    }

    if($f[0] ne $check[0]) {
      $count++;
      warn "\n$nv\n$f[0] $check[0]\n"
       unless $count > 10;
    }

    if(standardise_bin_mant($f[1]) ne $check[1]) {
      $count++;
      warn "\n$nv\n", standardise_bin_mant($f[1]), "\n$check[1]\n"
       unless $count > 10;
    }

    if($f[2] ne $check[2]) {
      $count++;
      warn "\n$nv\n$f[2] $check[2]\n"
       unless $count > 10;
    }

    $ok = 0 if $count;
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

($count, $ok) = (0, 1);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    #next if(!$nv || are_inf($nv));
    my @f = float_H($nv);
    my $hex = shift @f;
    my @check = float_H2B($hex);
    my $check = B2float_H(@check);

    if($check ne $hex) {
      $count++;
      warn "\n$nv\n$hex $check\n"
       unless $count > 10;
    }

    if($f[0] ne $check[0]) {
      $count++;
      warn "\n$nv\n$f[0] $check[0]\n"
       unless $count > 10;
    }

    if(standardise_bin_mant($f[1]) ne $check[1]) {
      $count++;
      warn "\n$nv\n", standardise_bin_mant($f[1]), "\n$check[1]\n"
       unless $count > 10;
    }

    if($f[2] ne $check[2]) {
      $count++;
      warn "\n$nv\n$f[2] $check[2]\n"
       unless $count > 10;
    }

    $ok = 0 if $count;
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  #next if(!$nv || are_inf($nv));
  my @f = float_H($nv);
  my $hex = shift @f;
  my @check = float_H2B($hex);
  my $check = B2float_H(@check);

  if($check ne $hex) {
    $count++;
    warn "\n$nv\n$hex $check\n"
     unless $count > 10;
  }

  if($f[0] ne $check[0]) {
    $count++;
    warn "\n$nv\n$f[0] $check[0]\n"
     unless $count > 10;
  }

  if(standardise_bin_mant($f[1]) ne $check[1]) {
    $count++;
    warn "\n$nv\n", standardise_bin_mant($f[1]), "\n$check[1]\n"
     unless $count > 10;
  }

  if($f[2] ne $check[2]) {
    $count++;
    warn "\n$nv\n$f[2] $check[2]\n"
     unless $count > 10;
  }

  $ok = 0 if $count;
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  #next if(!$nv || are_inf($nv));
  my @f = float_H($nv);
  my $hex = shift @f;
  my @check = float_H2B($hex);
  my $check = B2float_H(@check);

  if($check ne $hex) {
    $count++;
    warn "\n$nv\n$hex $check\n"
     unless $count > 10;
  }

  if($f[0] ne $check[0]) {
    $count++;
    warn "\n$nv\n$f[0] $check[0]\n"
     unless $count > 10;
  }

  if(standardise_bin_mant($f[1]) ne $check[1]) {
    $count++;
    warn "\n$nv\n", standardise_bin_mant($f[1]), "\n$check[1]\n"
     unless $count > 10;
  }

  if($f[2] ne $check[2]) {
    $count++;
    warn "\n$nv\n$f[2] $check[2]\n"
     unless $count > 10;
  }

  $ok = 0 if $count;
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

##############################
##############################

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

