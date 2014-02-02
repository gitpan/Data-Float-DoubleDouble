# Because we pass a string to Math::MPFR, we can't use a precision of 106
# Instead we need to use the effective precision of the long double, which
# can be less than 106 when the second double is de-normalised.
# When we pass the actual long double (as in 07_nv2mpfr_cross_checks.t),
# we *can* set the precision to 106 throughout.
# When the *first* double is de-normalised, we need to call the align() sub.

use warnings;
use strict;
use Math::NV qw(:all);
#use Math::MPFR qw(:mpfr);

use Data::Float::DoubleDouble qw(:all);

# If $ARGV[0] is "debug", extra info is supplied re tests 1 & 2 (-ve exponents) only.
# If $ARGV[0] is "DEBUG", extra info is supplied re all 4 tests.
$Data::Float::DoubleDouble::debug = 1 if(defined($ARGV[0]) && $ARGV[0] =~ /debug/i);

my $t = 6;

print "1..$t\n";

eval {require Math::MPFR;};
if($@) {
  warn "\n Skipping all tests - couldn't load Math::MPFR.",
       "\n (02_str2mpfr_cross_checks.t requires Math::MPFR)\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}


my($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . 'e' . "-$exp";
    my $ref = populate($str);
    die "Check failed for $str" unless $ref->{check};

    Math::MPFR::Rmpfr_set_default_prec(length($ref->{bin})); # $ref->{bin} is not always 106 binary characters long
    my $fr = Math::MPFR->new($str);

    my @out = Math::MPFR::Rmpfr_deref2($fr, 2, length($ref->{bin}), 0); 
    $out[0] =~ s/^\-//;

  $out[0] = align($out[0], $ref->{bin}); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

    if($ref->{bin} ne $out[0]) {
      $count++;
      $ok = 0;
      warn "$str\n$ref->{bin}\n$out[0]\n\n"
        unless $count > 10;
    }      
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . 'e' . "-$exp";
    my $ref = populate($str);
    die "Check failed for $str" unless $ref->{check};

    Math::MPFR::Rmpfr_set_default_prec(length($ref->{bin})); # $ref->{bin} is not always 106 binary characters long
    my $fr = Math::MPFR->new($str);

    my @out = Math::MPFR::Rmpfr_deref2($fr, 2, length($ref->{bin}), 0);
    $out[0] =~ s/^\-//;

  $out[0] = align($out[0], $ref->{bin}); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

    if($ref->{bin} ne $out[0]) {
      $count++;
      $ok = 0;
      warn "$str\n$ref->{bin}\n$out[0]\n\n"
        unless $count > 10;
    }      
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

# Turn off debug for the +ve exponent tests *unless* $ARGV[0] eq 'DEBUG'
if($Data::Float::DoubleDouble::debug) {
  unless($ARGV[0] eq 'DEBUG') {
    warn "Turning off \$debug for +ve exponents\n";
    $Data::Float::DoubleDouble::debug = 0;
  }
}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = random_select($digits) . "e$exp";
    my $ref = populate($str);
    die "Check failed for $str" unless $ref->{check};

    Math::MPFR::Rmpfr_set_default_prec(length($ref->{bin})); # $ref->{bin} is not always 106 binary characters long
    my $fr = Math::MPFR->new($str);

    my @out = Math::MPFR::Rmpfr_deref2($fr, 2, length($ref->{bin}), 0);
    $out[0] =~ s/^\-//;

  $out[0] = align($out[0], $ref->{bin}); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

    align($ref->{bin}, $out[0]); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

    if(($ref->{bin} ne $out[0]) && !are_inf($ref->{val})) {
      $count++;
      $ok = 0;
      warn "$str\n$ref->{bin}\n$out[0]\n\n"
        unless $count > 10;
    }      
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

($ok, $count) = (1, 0);

for my $exp(0..10, 20, 30, 280 .. 300) {
  for my $digits(1..15) {
    my $str = '-' . random_select($digits) . "e$exp";
    my $ref = populate($str);
    die "Check failed for $str" unless $ref->{check};

    Math::MPFR::Rmpfr_set_default_prec(length($ref->{bin})); # $ref->{bin} is not always 106 binary characters long
    my $fr = Math::MPFR->new($str);

    my @out = Math::MPFR::Rmpfr_deref2($fr, 2, length($ref->{bin}), 0);
    $out[0] =~ s/^\-//;

  $out[0] = align($out[0], $ref->{bin}); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

    if(($ref->{bin} ne $out[0]) && !are_inf($ref->{val})) {
      $count++;
      $ok = 0;
      warn "$str\n$ref->{bin}\n$out[0]\n\n"
        unless $count > 10;
    }      
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '-0.0000000009' . "e-$exp";
  my $ref = populate($str);
  die "Check failed for $str" unless $ref->{check};

  Math::MPFR::Rmpfr_set_default_prec(length($ref->{bin})); # $ref->{bin} is not always 106 binary characters long
  my $fr = Math::MPFR->new($str);

  my @out = Math::MPFR::Rmpfr_deref2($fr, 2, length($ref->{bin}), 0);
  $out[0] =~ s/^\-//;

  $out[0] = align($out[0], $ref->{bin}); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

  if(($ref->{bin} ne $out[0]) && !are_inf($ref->{val})) {
    $count++;
    $ok = 0;
    warn "$str\n$ref->{bin}\n$out[0]\n\n"
      unless $count > 10;
  }      
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

($ok, $count) = (1, 0);

for my $exp(298 .. 304) {
  my $str = '-0.0000000009' . "e-$exp";
  my $ref = populate($str);
  die "Check failed for $str" unless $ref->{check};

  Math::MPFR::Rmpfr_set_default_prec(length($ref->{bin})); # $ref->{bin} is not always 106 binary characters long
  my $fr = Math::MPFR->new($str);

  my @out = Math::MPFR::Rmpfr_deref2($fr, 2, length($ref->{bin}), 0);
  $out[0] =~ s/^\-//;

  $out[0] = align($out[0], $ref->{bin}); # No-op iff $ref->{bin} does not begin with '0' (ie if first double is not denormalised.)

  if(($ref->{bin} ne $out[0]) && !are_inf($ref->{val})) {
    $count++;
    $ok = 0;
    warn "$str\n$ref->{bin}\n$out[0]\n\n"
      unless $count > 10;
  }      
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

sub populate {

  my $val = Math::NV::nv($_[0]);
  my $hex = NV2H($val);
  my @f = float_H($val);
  my $check = H2NV($hex);

  $check = $check == $val || are_nan($check, $val) ? 1 : 0;

  my %h = ('val' => $val, 'unpack' => $hex, 'hex' => $f[0], 'bin' => $f[2], 'check' => $check);

  return \%h;
}


sub random_select {
  my $ret = '';
  for(1 .. $_[0]) {
    $ret .= int(rand(10));
  }
  return $ret;
}


sub align {
  my $zero_count = 0;
  my $ret = $_[0]; # $out[0]
  my $len = length($_[1]); # $ref->{bin}

  while(substr($_[1], $zero_count, 1) eq '0') {
    $zero_count++;
  }

  $ret = '0' x $zero_count . $ret;

  return (Data::Float::DoubleDouble::_trunc_rnd($ret, $len))[0];
}



__END__

