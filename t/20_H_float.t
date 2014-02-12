# Aiming to use the float_H() representation to re-create the original NV (double-double).

use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

my $t = 6;

print "1..$t\n";

my($ok, $count, $done) = (1, 0, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    my $hex = float_H($nv);

    my @bin = float_H2B($hex);

    unless($bin[1] =~ /inf|nan/) {
      next if (Data::Float::DoubleDouble::_trunc_rnd($bin[1], 53))[1];
    }

    $done++;

    my $nv_redone = H_float($hex);

    if($nv_redone != $nv) {
      $count++;
      $ok = 0;
      warn "\nNV's don't match:\n$str $nv $nv_redone\n"
       unless $count > 10;
    }

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($h_redone ne $h) {

      $count++;
      $ok = 0;
      warn "\nHex dumps don't match:\n$str\n",
       substr($h, 0, 16), " ", substr($h, 16), "\n",
       substr($h_redone, 0, 16), " ", substr($h_redone, 16), "\n",
       substr($bin[1], 0, 53), "\n", substr($bin[1], 53), "\n"
       unless $count > 10;
    }
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

warn "\nDONE: $done\n";
($ok, $count, $done) = (1, 0, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "$exp";
    my $nv = Math::NV::nv($str);
    my $hex = float_H($nv);

    my @bin = float_H2B($hex);

    unless($bin[1] =~ /inf|nan/) {
      next if (Data::Float::DoubleDouble::_trunc_rnd($bin[1], 53))[1];
    }

    $done++;

    my $nv_redone = H_float($hex);

    if($nv_redone != $nv) {
      $count++;
      $ok = 0;
      warn "\nNV's don't match:\n$str $nv $nv_redone\n"
       unless $count > 10;
    }

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($h_redone ne $h) {

      $count++;
      $ok = 0;
      warn "\nHex dumps don't match:\n$str\n",
       substr($h, 0, 16), " ", substr($h, 16), "\n",
       substr($h_redone, 0, 16), " ", substr($h_redone, 16), "\n",
       substr($bin[1], 0, 53), "\n", substr($bin[1], 53), "\n"
       unless $count > 10;
    }
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

warn "DONE: $done\n";
($ok, $count, $done) = (1, 0, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    my $hex = float_H($nv);

    my @bin = float_H2B($hex);

    unless($bin[1] =~ /inf|nan/) {
      next if (Data::Float::DoubleDouble::_trunc_rnd($bin[1], 53))[1];
    }

    $done++;

    my $nv_redone = H_float($hex);

    if($nv_redone != $nv) {
      $count++;
      $ok = 0;
      warn "\nNV's don't match:\n$str $nv $nv_redone\n"
       unless $count > 10;
    }

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($h_redone ne $h) {

      $count++;
      $ok = 0;
      warn "\nHex dumps don't match:\n$str\n",
       substr($h, 0, 16), " ", substr($h, 16), "\n",
       substr($h_redone, 0, 16), " ", substr($h_redone, 16), "\n",
       substr($bin[1], 0, 53), "\n", substr($bin[1], 53), "\n"
       unless $count > 10;
    }
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

warn "DONE: $done\n";
($ok, $count, $done) = (1, 0, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "-$exp";
    my $nv = Math::NV::nv($str);
    my $hex = float_H($nv);

    my @bin = float_H2B($hex);

    unless($bin[1] =~ /inf|nan/) {
      next if (Data::Float::DoubleDouble::_trunc_rnd($bin[1], 53))[1];
    }

    $done++;

    my $nv_redone = H_float($hex);

    if($nv_redone != $nv) {
      $count++;
      $ok = 0;
      warn "\nNV's don't match:\n$str $nv $nv_redone\n"
       unless $count > 10;
    }

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($h_redone ne $h) {

      $count++;
      $ok = 0;
      warn "\nHex dumps don't match:\n$str\n",
       substr($h, 0, 16), " ", substr($h, 16), "\n",
       substr($h_redone, 0, 16), " ", substr($h_redone, 16), "\n",
       substr($bin[1], 0, 53), "\n", substr($bin[1], 53), "\n"
       unless $count > 10;
    }
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

warn "DONE: $done\n";
($ok, $count, $done) = (1, 0, 0);

for my $exp(298 .. 304) {
  my $str = '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  my $hex = float_H($nv);

  my @bin = float_H2B($hex);

  unless($bin[1] =~ /inf|nan/) {
    next if (Data::Float::DoubleDouble::_trunc_rnd($bin[1], 53))[1];
  }

  $done++;

  my $nv_redone = H_float($hex);

  if($nv_redone != $nv) {
    $count++;
    $ok = 0;
    warn "\nNV's don't match:\n$str $nv $nv_redone\n"
     unless $count > 10;
  }

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($h_redone ne $h) {

    $count++;
    $ok = 0;
    warn "\nHex dumps don't match:\n$str\n",
     substr($h, 0, 16), " ", substr($h, 16), "\n",
     substr($h_redone, 0, 16), " ", substr($h_redone, 16), "\n",
     substr($bin[1], 0, 53), "\n", substr($bin[1], 53), "\n"
     unless $count > 10;
  }
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

warn "DONE: $done\n";
($ok, $count, $done) = (1, 0, 0);

for my $exp(298 .. 304) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  my $hex = float_H($nv);

  my @bin = float_H2B($hex);

  unless($bin[1] =~ /inf|nan/) {
    next if (Data::Float::DoubleDouble::_trunc_rnd($bin[1], 53))[1];
  }

  $done++;

  my $nv_redone = H_float($hex);

  if($nv_redone != $nv) {
    $count++;
    $ok = 0;
    warn "\nNV's don't match:\n$str $nv $nv_redone\n"
     unless $count > 10;
  }

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($h_redone ne $h) {

    $count++;
    $ok = 0;
    warn "\nHex dumps don't match:\n$str\n",
     substr($h, 0, 16), " ", substr($h, 16), "\n",
     substr($h_redone, 0, 16), " ", substr($h_redone, 16), "\n",
     substr($bin[1], 0, 53), "\n", substr($bin[1], 53), "\n"
     unless $count > 10;
  }
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

warn "DONE: $done\n";
($ok, $count, $done) = (1, 0, 0);

##########################################
##########################################

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

__END__

4e-298

3.999999999999999649312930644493e-298 -2.879304828507645629477634806369e+163

0230be08d0527e1d 00000001a712ddfb
e1dfffffffffffff feda712ddfb00000

1000010111110000010001101000001010010011111100001110101101001110001001011011101111110110000000000000000000000
1000010111110000010001101000001010010011111100001110101101001110001001011011101111110110000000000000000000000



