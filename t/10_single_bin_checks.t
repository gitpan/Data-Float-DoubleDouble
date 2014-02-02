# Here we check that when we run @dump = float_H($nv), the sign
# of $d[0] eq $d[2] && the exponent of $d[0] eq $d[3].

use strict;
use warnings;
use Data::Float::DoubleDouble qw(:all);
use Math::NV qw(:all);

my $t = 6;

print "1..$t\n";

my($c1, $c2);

my($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    ($c1, $c2) = (0, 0);
    my $str = random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    my @s = float_H($nv);

    if(substr($s[0], 0, 1) ne $s[1]) {
      $c1++;
      warn "\n$nv $s[0]\n", substr($s[0], 0, 1), " $s[1]\n"
        unless $count > 10;
      $ok = 0;
    }

    if((split /p/, $s[0])[1] ne $s[3]) {
      $c2++;
      warn "\n$nv $s[0]\n", (split /p/, $s[0])[1], " $s[3]\n"
        unless $count > 10;
      $ok = 0;
    }

    $count++ if ($c1 || $c2);
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    ($c1, $c2) = (0, 0);
    my $str = '-' . random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    my @s = float_H($nv);

    if(substr($s[0], 0, 1) ne $s[1]) {
      $c1++;
      warn "\n$nv $s[0]\n", substr($s[0], 0, 1), " $s[1]\n"
        unless $count > 10;
      $ok = 0;
    }

    if((split /p/, $s[0])[1] ne $s[3]) {
      $c2++;
      warn "\n$nv $s[0]\n", (split /p/, $s[0])[1], " $s[3]\n"
        unless $count > 10;
      $ok = 0;
    }

    $count++ if ($c1 || $c2);
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    ($c1, $c2) = (0, 0);
    my $str = random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    my @s = float_H($nv);

    if(substr($s[0], 0, 1) ne $s[1]) {
      $c1++;
      warn "\n$nv $s[0]\n", substr($s[0], 0, 1), " $s[1]\n"
        unless $count > 10;
      $ok = 0;
    }

    if((split /p/, $s[0])[1] ne $s[3]) {
      $c2++;
      warn "\n$nv $s[0]\n", (split /p/, $s[0])[1], " $s[3]\n"
        unless $count > 10;
      $ok = 0;
    }

    $count++ if ($c1 || $c2);
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    ($c1, $c2) = (0, 0);
    my $str = '-' . random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    my @s = float_H($nv);

    if(substr($s[0], 0, 1) ne $s[1]) {
      $c1++;
      warn "\n$nv $s[0]\n", substr($s[0], 0, 1), " $s[1]\n"
        unless $count > 10;
      $ok = 0;
    }

    if((split /p/, $s[0])[1] ne $s[3]) {
      $c2++;
      warn "\n$nv $s[0]\n", (split /p/, $s[0])[1], " $s[3]\n"
        unless $count > 10;
      $ok = 0;
    }

    $count++ if ($c1 || $c2);
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '0.0000000009' . "e-$exp";
  ($c1, $c2) = (0, 0);
  my $nv = Math::NV::nv($str);
  my @s = float_H($nv);

  if(substr($s[0], 0, 1) ne $s[1]) {
    $c1++;
    warn "\n$nv $s[0]\n", substr($s[0], 0, 1), " $s[1]\n"
      unless $count > 10;
    $ok = 0;
  }

  if((split /p/, $s[0])[1] ne $s[3]) {
    $c2++;
    warn "\n$nv $s[0]\n", (split /p/, $s[0])[1], " $s[3]\n"
      unless $count > 10;
    $ok = 0;
  }

  $count++ if ($c1 || $c2);
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  ($c1, $c2) = (0, 0);
  my $nv = Math::NV::nv($str);
  my @s = float_H($nv);

  if(substr($s[0], 0, 1) ne $s[1]) {
    $c1++;
    warn "\n$nv $s[0]\n", substr($s[0], 0, 1), " $s[1]\n"
      unless $count > 10;
    $ok = 0;
  }

  if((split /p/, $s[0])[1] ne $s[3]) {
    $c2++;
    warn "\n$nv $s[0]\n", (split /p/, $s[0])[1], " $s[3]\n"
      unless $count > 10;
    $ok = 0;
  }

  $count++ if ($c1 || $c2);
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

####################################
####################################

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

__END__