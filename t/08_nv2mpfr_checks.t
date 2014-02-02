# Unlike 03_str2mpfr_checks.t, because we're passing the actual NV to Math::MPFR,
# we can just use default mpfr precision of 106 throughout.
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
       "\n (03_mpfr_checks.t requires Math::MPFR)\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

Math::MPFR::Rmpfr_set_default_prec(Math::MPFR::_LDBL_MANT_DIG());

my($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "-$exp";
    my $nv1 = Math::NV::nv($str);
    my @nv1 = float_H($nv1);
    #my $len = length($nv1[1]);

    my $nv2 = Math::MPFR::Rmpfr_get_NV(Math::MPFR->new(scalar Math::NV::nv($str)), 0);
    my $h1 = NV2H($nv1);
    my $h2 = NV2H($nv2);

    if($h1 ne $h2) {

      # Not a failure iff the second double is zero && the only difference is the sign of that zero.
      if((
          (substr($h1, 16, 16) eq '8000000000000000' &&  substr($h2, 16, 16) eq '0000000000000000')
         ||
          (substr($h2, 16, 16) eq '8000000000000000' &&  substr($h1, 16, 16) eq '0000000000000000')
         )
         &&
          (substr($h2, 0, 16) eq substr($h1, 0, 16))
        ) {next}

      $count++;
      my @exp1 = get_exp($nv1);
      my @exp2 = get_exp($nv2);
      my @nv2 = float_H($nv2);
      my @out = Math::MPFR::Rmpfr_deref2(Math::MPFR->new(scalar Math::NV::nv($str)), 2, Math::MPFR::_LDBL_MANT_DIG(), 0);
      warn "\nExp1: $exp1[0] $exp1[1]\nExp2: $exp2[0] $exp2[1]\n",
           "inter_zero: ", inter_zero(@exp1), " ", inter_zero(@exp2), "\n",
           "$str\n\$h1: $h1\n\$h2: $h2\n",
           "$nv1[1]\n$nv2[1]\n$out[0]\n"
              unless $count > 10;
      $ok = 0;
      #  if(inter_zero(@exp1) || inter_zero(@exp2)); # was a condition for for $ok = 0 ... not necessary
    }
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . "e$exp";
    my $nv1 = Math::NV::nv($str);
    my $nv2 = Math::MPFR::Rmpfr_get_NV(Math::MPFR->new(scalar Math::NV::nv($str)), 0);
    my $h1 = NV2H($nv1);
    my $h2 = NV2H($nv2);

    if($h1 ne $h2) {

      # Not a failure iff the second double is zero && the only difference is the sign of that zero.
      if((
          (substr($h1, 16, 16) eq '8000000000000000' &&  substr($h2, 16, 16) eq '0000000000000000')
         ||
          (substr($h2, 16, 16) eq '8000000000000000' &&  substr($h1, 16, 16) eq '0000000000000000')
         )
         &&
          (substr($h2, 0, 16) eq substr($h1, 0, 16))
        ) {next}

      $count++;
      my @exp1 = get_exp($nv1);
      my @exp2 = get_exp($nv2);
      my @nv1 = float_H($nv1);
      my @nv2 = float_H($nv2);
      my @out = Math::MPFR::Rmpfr_deref2(Math::MPFR->new(scalar Math::NV::nv($str)), 2, Math::MPFR::_LDBL_MANT_DIG(), 0);
      warn "\nExp1: $exp1[0] $exp1[1]\nExp2: $exp2[0] $exp2[1]\n",
           "inter_zero: ", inter_zero(@exp1), " ", inter_zero(@exp2), "\n",
           "$str\n\$h1: $h1\n\$h2: $h2\n",
           "$nv1[1]\n$nv2[1]\n$out[0]\n"
              unless $count > 10;
      $ok = 0;
      #  if(inter_zero(@exp1) || inter_zero(@exp2)); # was a condition for for $ok = 0 ... not necessary
    }
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "-$exp";
    my $nv1 = Math::NV::nv($str);
    my @nv1 = float_H($nv1);
    #my $len = length($nv1[1]);

    my $nv2 = Math::MPFR::Rmpfr_get_NV(Math::MPFR->new(scalar Math::NV::nv($str)), 0);
    my $h1 = NV2H($nv1);
    my $h2 = NV2H($nv2);

    if($h1 ne $h2) {

      # Not a failure iff the second double is zero && the only difference is the sign of that zero.
      if((
          (substr($h1, 16, 16) eq '8000000000000000' &&  substr($h2, 16, 16) eq '0000000000000000')
         ||
          (substr($h2, 16, 16) eq '8000000000000000' &&  substr($h1, 16, 16) eq '0000000000000000')
         )
         &&
          (substr($h2, 0, 16) eq substr($h1, 0, 16))
        ) {next}

      $count++;
      my @exp1 = get_exp($nv1);
      my @exp2 = get_exp($nv2);
      my @nv2 = float_H($nv2);
      my @out = Math::MPFR::Rmpfr_deref2(Math::MPFR->new(scalar Math::NV::nv($str)), 2, Math::MPFR::_LDBL_MANT_DIG(), 0);
      warn "\nExp1: $exp1[0] $exp1[1]\nExp2: $exp2[0] $exp2[1]\n",
           "inter_zero: ", inter_zero(@exp1), " ", inter_zero(@exp2), "\n",
           "$str\n\$h1: $h1\n\$h2: $h2\n",
           "$nv1[1]\n$nv2[1]\n$out[0]\n"
              unless $count > 10;
      $ok = 0;
      #  if(inter_zero(@exp1) || inter_zero(@exp2)); # was a condition for for $ok = 0 ... not necessary
    }
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . "e$exp";
    my $nv1 = Math::NV::nv($str);
    my $nv2 = Math::MPFR::Rmpfr_get_NV(Math::MPFR->new(scalar Math::NV::nv($str)), 0);
    my $h1 = NV2H($nv1);
    my $h2 = NV2H($nv2);

    if($h1 ne $h2) {

      # Not a failure iff the second double is zero && the only difference is the sign of that zero.
      if((
          (substr($h1, 16, 16) eq '8000000000000000' &&  substr($h2, 16, 16) eq '0000000000000000')
         ||
          (substr($h2, 16, 16) eq '8000000000000000' &&  substr($h1, 16, 16) eq '0000000000000000')
         )
         &&
          (substr($h2, 0, 16) eq substr($h1, 0, 16))
        ) {next}

      $count++;
      my @exp1 = get_exp($nv1);
      my @exp2 = get_exp($nv2);
      my @nv1 = float_H($nv1);
      my @nv2 = float_H($nv2);
      my @out = Math::MPFR::Rmpfr_deref2(Math::MPFR->new(scalar Math::NV::nv($str)), 2, Math::MPFR::_LDBL_MANT_DIG(), 0);
      warn "\nExp1: $exp1[0] $exp1[1]\nExp2: $exp2[0] $exp2[1]\n",
           "inter_zero: ", inter_zero(@exp1), " ", inter_zero(@exp2), "\n",
           "$str\n\$h1: $h1\n\$h2: $h2\n",
           "$nv1[1]\n$nv2[1]\n$out[0]\n"
              unless $count > 10;
      $ok = 0;
      #  if(inter_zero(@exp1) || inter_zero(@exp2)); # was a condition for for $ok = 0 ... not necessary
    }
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '0.0000000009' . "e-$exp";
  my $nv1 = Math::NV::nv($str);
  my $nv2 = Math::MPFR::Rmpfr_get_NV(Math::MPFR->new(scalar Math::NV::nv($str)), 0);
  my $h1 = NV2H($nv1);
  my $h2 = NV2H($nv2);

  if($h1 ne $h2) {

    # Not a failure iff the second double is zero && the only difference is the sign of that zero.
    if((
        (substr($h1, 16, 16) eq '8000000000000000' &&  substr($h2, 16, 16) eq '0000000000000000')
       ||
        (substr($h2, 16, 16) eq '8000000000000000' &&  substr($h1, 16, 16) eq '0000000000000000')
       )
       &&
        (substr($h2, 0, 16) eq substr($h1, 0, 16))
      ) {next}

    $count++;
    my @exp1 = get_exp($nv1);
    my @exp2 = get_exp($nv2);
    my @nv1 = float_H($nv1);
    my @nv2 = float_H($nv2);
    my @out = Math::MPFR::Rmpfr_deref2(Math::MPFR->new(scalar Math::NV::nv($str)), 2, Math::MPFR::_LDBL_MANT_DIG(), 0);
    warn "\nExp1: $exp1[0] $exp1[1]\nExp2: $exp2[0] $exp2[1]\n",
         "inter_zero: ", inter_zero(@exp1), " ", inter_zero(@exp2), "\n",
         "$str\n\$h1: $h1\n\$h2: $h2\n",
         "$nv1[1]\n$nv2[1]\n$out[0]\n"
            unless $count > 10;
    $ok = 0;
    #  if(inter_zero(@exp1) || inter_zero(@exp2)); # was a condition for for $ok = 0 ... not necessary
  }
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '-' . '0.0000000009' . "e-$exp";
  my $nv1 = Math::NV::nv($str);
  my $nv2 = Math::MPFR::Rmpfr_get_NV(Math::MPFR->new(scalar Math::NV::nv($str)), 0);
  my $h1 = NV2H($nv1);
  my $h2 = NV2H($nv2);

  if($h1 ne $h2) {

    # Not a failure iff the second double is zero && the only difference is the sign of that zero.
    if((
        (substr($h1, 16, 16) eq '8000000000000000' &&  substr($h2, 16, 16) eq '0000000000000000')
       ||
        (substr($h2, 16, 16) eq '8000000000000000' &&  substr($h1, 16, 16) eq '0000000000000000')
       )
       &&
        (substr($h2, 0, 16) eq substr($h1, 0, 16))
      ) {next}

    $count++;
    my @exp1 = get_exp($nv1);
    my @exp2 = get_exp($nv2);
    my @nv1 = float_H($nv1);
    my @nv2 = float_H($nv2);
    my @out = Math::MPFR::Rmpfr_deref2(Math::MPFR->new(scalar Math::NV::nv($str)), 2, Math::MPFR::_LDBL_MANT_DIG(), 0);
    warn "\nExp1: $exp1[0] $exp1[1]\nExp2: $exp2[0] $exp2[1]\n",
         "inter_zero: ", inter_zero(@exp1), " ", inter_zero(@exp2), "\n",
         "$str\n\$h1: $h1\n\$h2: $h2\n",
         "$nv1[1]\n$nv2[1]\n$out[0]\n"
            unless $count > 10;
    $ok = 0;
    #  if(inter_zero(@exp1) || inter_zero(@exp2)); # was a condition for for $ok = 0 ... not necessary
  }
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}

__END__

