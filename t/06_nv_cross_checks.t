use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

my $t = 6;

print "1..$t\n";

my($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . "e$exp";
    my $nv = Math::NV::nv($str);
    next if are_inf($nv);
    my @nv = float_H($nv);
    my ($mantissa, $exponent, $precision) = Math::NV::ld2binary($nv, 0);
    my $mant = $mantissa =~ /^0\./ ? substr($mantissa, 2) : $mantissa; # The condition should always be
                                                                       # true - but let's catch the
                                                                       # exception if it happens.

    while((length($mant) > length($nv[2])) && $mant =~ /0$/) {
      chop $mant;
    }

    while((length($nv[2]) > length($mant)) && $nv[2] =~ /0$/) {
      chop $nv[2];
    }

    if($mant ne $nv[2]) {
      $count++;
      $ok = 0;
      if($count < 10) {
        warn "\n$str $nv\nM::NV:\n$nv[1]$nv[2]\nD::F::DD:\n$mant\n";
      }
    }
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . "e-$exp";
    my $nv = Math::NV::nv($str);
    my @nv = float_H($nv);
    my ($mantissa, $exponent, $precision) = Math::NV::ld2binary($nv, 0);
    my $mant = $mantissa =~ /^0\./ ? substr($mantissa, 2) : $mantissa;

    while((length($mant) > length($nv[2])) && $mant =~ /0$/) {
      chop $mant;
    }

    while((length($nv[2]) > length($mant)) && $nv[2] =~ /0$/) {
      chop $nv[2];
    }

    if($mant ne $nv[2]) {
      $count++;
      $ok = 0;
      if($count < 10) {
        warn "\n$str $nv\nM::NV:\n$nv[1]$nv[2]\nD::F::DD:\n$mant\n";
      }
    }
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . "e$exp";
    my $nv = Math::NV::nv($str);
    next if are_inf($nv);
    my @nv = float_H($nv);
    my ($mantissa, $exponent, $precision) = Math::NV::ld2binary($nv, 0);
    my $mant = $mantissa =~ /^\-0\./ ? substr($mantissa, 3) : $mantissa; # The condition should always be
                                                                       # true - but let's catch the
                                                                       # exception if it happens.

    while((length($mant) > length($nv[2])) && $mant =~ /0$/) {
      chop $mant;
    }

    while((length($nv[2]) > length($mant)) && $nv[2] =~ /0$/) {
      chop $nv[2];
    }

    if($mant ne $nv[2]) {
      $count++;
      $ok = 0;
      if($count < 10) {
        warn "\n$str $nv\nM::NV:\n$mant\n$nv[2]\nD::F::DD:\n$mant\n$mantissa\n";
      }
    }
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

#exit 0;

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . "e-$exp";
    my $nv = Math::NV::nv($str);
    my @nv = float_H($nv);
    my ($mantissa, $exponent, $precision) = Math::NV::ld2binary($nv, 0);
    my $mant = $mantissa =~ /^\-0\./ ? substr($mantissa, 3) : $mantissa;

    while((length($mant) > length($nv[2])) && $mant =~ /0$/) {
      chop $mant;
    }

    while((length($nv[2]) > length($mant)) && $nv[2] =~ /0$/) {
      chop $nv[2];
    }

    if($mant ne $nv[2]) {
      $count++;
      $ok = 0;
      if($count < 10) {
        warn "\n$str $nv\nM::NV:\n$nv[1]$nv[2]\nD::F::DD:\n$mant\n";
      }
    }
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

######################################
######################################

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  my $str = '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  my @nv = float_H($nv);
  my ($mantissa, $exponent, $precision) = Math::NV::ld2binary($nv, 0);
  my $mant = $mantissa =~ /^0\./ ? substr($mantissa, 2) : $mantissa;

  while((length($mant) > length($nv[2])) && $mant =~ /0$/) {
    chop $mant;
  }

  while((length($nv[2]) > length($mant)) && $nv[2] =~ /0$/) {
    chop $nv[2];
  }

  # $nv[2] will include the preceding zeroes, whereas $mant won't.
  while($nv[2] =~ /^0/) {
    $nv[2] = substr($nv[2], 1);
  }

  if($mant ne $nv[2]) {
    $count++;
    $ok = 0;
    if($count < 10) {
      warn "\n$str $nv\nM::NV:\n$nv[2]\nD::F::DD:\n$mant\n$mantissa\n";
    }
  }
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  my $nv = Math::NV::nv($str);
  my @nv = float_H($nv);
  my ($mantissa, $exponent, $precision) = Math::NV::ld2binary($nv, 0);
  my $mant = $mantissa =~ /^\-0\./ ? substr($mantissa, 3) : $mantissa;

  while((length($mant) > length($nv[2])) && $mant =~ /0$/) {
    chop $mant;
  }

  while((length($nv[2]) > length($mant)) && $nv[2] =~ /0$/) {
    chop $nv[2];
  }

  # $nv[2] will include the preceding zeroes, whereas $mant won't.
  while($nv[2] =~ /^0/) {
    $nv[2] = substr($nv[2], 1);
  }

  if($mant ne $nv[2]) {
    $count++;
    $ok = 0;
    if($count < 10) {
      warn "\n$str $nv\nM::NV:\n$nv[2]\nD::F::DD:\n$mant\n$mantissa\n";
    }
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