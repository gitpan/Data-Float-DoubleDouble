package Data::Float::DoubleDouble;
use warnings;
use strict;
use Config;

require 5.010;

require Exporter;
*import = \&Exporter::import;

@Data::Float::DoubleDouble::EXPORT_OK = qw(NV2H H2NV D2H H2D get_sign
 get_exp get_mant_H float_H H_float inter_zero are_inf are_nan
 float_H2B B2float_H standardise_bin_mant hex_float float_hex);

%Data::Float::DoubleDouble::EXPORT_TAGS = (all =>[qw(NV2H H2NV D2H H2D
 get_sign get_exp get_mant_H float_H H_float inter_zero are_inf are_nan
 float_H2B B2float_H standardise_bin_mant float_hex hex_float)]);

our $VERSION = '0.03';
$VERSION = eval $VERSION;

$Data::Float::DoubleDouble::debug = 0;
$Data::Float::DoubleDouble::pack = $Config{nvtype} eq 'double' ? "F<" : "D<";

##############################
##############################
# A function to return the hex representation of the NV:

sub NV2H {

  return scalar reverse unpack "h*", pack $Data::Float::DoubleDouble::pack, $_[0];

}

##############################
##############################
# A function to return an NV from the hex representation provided by NV2H().

sub H2NV {

  return unpack $Data::Float::DoubleDouble::pack, pack "h*", scalar reverse $_[0];

}

##############################
##############################
# A function to return the hex representation of a double:

sub D2H {

  return scalar reverse unpack "h*", pack "d<", $_[0];

}

##############################
##############################
# A function to return a double from the hex representation provided by D2H().

sub H2D {

  return unpack "d<", pack "h*", scalar reverse $_[0];

}

##############################
##############################
# A function to get the sign(s) of the NV

sub get_sign {

  my $hex = NV2H($_[0]);

  my $sign1 = hex(substr($hex,  0, 1)) >= 8 ? '-' : '+';
  my $sign2 = hex(substr($hex, 16, 1)) >= 8 ? '-' : '+';
  return ($sign1, $sign2);

}

##############################
##############################

sub get_exp {

  my $hex = NV2H($_[0]);;

  my $exp1 = hex(substr($hex, 0, 3));
  my $exp2 = hex(substr($hex, 16, 3));

  $exp1 -= 2048 if $exp1 > 2047; # Remove sign bit
  $exp2 -= 2048 if $exp2 > 2047; # Remove sign bit

  $exp1++ unless $exp1;
  $exp2++ unless $exp2;

  return ($exp1 - 1023, $exp2 - 1023);

}

##############################
##############################
# Return the mantissas of the 2 doubles.

sub get_mant_H {

  my $hex = shift;
  return (substr($hex, 3, 13), substr($hex,19, 13));

}

##############################
##############################
# Return a hex string representation as per perl Data::Float

sub float_H {

  my $hex = NV2H($_[0]);

  my $pre1 = hex(substr($hex, 0, 3));
  my $pre2 = hex(substr($hex, 16, 3));
  my $discard = 0;

  my $sign1 = '+';
  my $sign2 = '+';

  if($pre1 > 2047) {
    $pre1 -= 2048;
    $sign1 = '-';
  }

  my $single_sign = $sign1;

  if($pre2 > 2047) {
    $pre2 -= 2048;
    $sign2 = '-';
  }

  my($s1, $s2) = get_mant_H($hex);

  die "\$s1 is too long: ", length($s1)
    if length $s1 > 13;

  die "\$s2 is too long: ", length($s2)
    if length $s2 > 13;

  my $bin_str1 = unpack("B52", (pack "H*", $s1));
  my $bin_str2 = unpack("B52", (pack "H*", $s2));
  my $bin = 'Not yet evaluated';

  my $sign_compare;

  # Check whether either string is zero and modify signs accordingly
  # Check $bin_str2 *first*
  $sign2 = $sign1 if ($bin_str2 !~ /1/ && !$pre2);
  $sign1 = $sign2 if ($bin_str1 !~ /1/ && !$pre1);

  if($sign1 eq  $sign2) {
    $sign_compare = $sign1 eq '-' ? 'nn' : 'pp';
  }
  else {
    $sign_compare = $sign1 eq '-' ? 'np' : 'pn';
  }

  my $bin_pre1 = $pre1 ? '1' : '0';

  $sign1 .= $pre1 ? '0x1.' : '0x0.';
  $pre1++ unless $pre1;

  my $bin_pre2 = $pre2 ? '1' : '0';
  $pre2++ unless $pre2;

  my($exp1, $exp2) = ($pre1 - 1023, $pre2 - 1023);
  my $inter_zero = inter_zero($exp1, $exp2);
  my $zeroes = '0' x $inter_zero;

  if($inter_zero < 0) {
    $bin_pre2 = '';
    $inter_zero++;
    $bin_str2 = substr($bin_str2, $inter_zero * -1);   
  }

  if($sign_compare eq 'nn' || $sign_compare eq 'pp') {
    $bin = $bin_pre1 . $bin_str1 . $zeroes . $bin_pre2 . $bin_str2;
    $bin = substr($bin, 0, 106);
  }
  else {
    $bin = _subtract_p($bin_pre1 . $bin_str1, $zeroes . $bin_pre2 . $bin_str2); 
    $bin = substr($bin, 0, 106);
  }

  my $ret2 = $bin;

  my $suffix = $pre1 - 1023;

  $suffix = $suffix > 0 ? '+' . "$suffix"
                        : "$suffix";

  my $single_exp = $suffix;

  $suffix = 'p' . $suffix;

  $bin .= '0' while length($bin) < 108; # Make sure the mantissa of $hex is always of the correct length.
  return ($sign1 . _bin2hex(substr($bin, 1, 108)) . $suffix, $single_sign, $ret2, $single_exp) if wantarray;
  return $sign1 . _bin2hex(substr($bin, 1, 108)) . $suffix;

}

##############################
##############################

##############################
##############################
# Receive the hex argument returned by float_H(), and return the original NV.

sub H_float {

  my @bin = float_H2B($_[0]);

  standardise_bin_mant($bin[1]); # Set $bin[1] to 109 bits. (Last 3 bits will always be 0.)

  my $d2_bin_mant = substr($bin[1], 53);
  my($d1, $roundup) = _bin2d(@bin, 1);


  if(!$roundup) { # Calculate $d2, concatenate it onto $d1.
    my @bin_d2 = ($bin[0], $d2_bin_mant, $bin[2] - 54);

    my($d2, $discard) = _bin2d(@bin_d2, 2);

    return H2NV($d1 . $d2);
  }
  else {
    my $overflow = 0;
    my $subtract_from = (_trunc_rnd($bin[1], 53))[0] . '0' x 56;
    while(length($subtract_from) > 109) { # Still needed - to satisfy _subtract_b().
                                          # (Strings must be of same length.)
      chop $subtract_from;
      $overflow++;
      warn "In H_float: overflow is greater than 1" if $overflow > 1;
    }
    my $mant = _subtract_b($subtract_from, $bin[1]);

    $mant = substr($mant, 53, 53);

    my $sign = $bin[0] eq '-' ? '+' : '-';
    my $exp = $bin[2] - 54;

    # decrement exponent if $d1 ends in 12 zeroes && $bin[1] begins with 53 zeroes
    $exp -- if($d1 =~ /0000000000000$/ && $bin[1] =~ /^11111111111111111111111111111111111111111111111111111/);

    my ($d2, $discard) = _bin2d($sign, $mant, $exp, 2);

    return H2NV($d1 . $d2);
  }
}

##############################
##############################
# Convert the hex format returned by float_H to binary.
# An array of 3 elements is returned - sign, mantissa, exponent.

sub float_H2B {

  my $sign = $_[0] =~ /^\-/ ? '-' : '+';
  my @split = split /p/, $_[0];
  my $exp = $split[1];
  my $lead = substr($_[0], 3, 1);
  die "Wrong leading digit" unless $lead =~ /[01]/;
  my $hex = (split /\./, $split[0])[1];
  die "Wrong number of hex chars" unless length($hex) == 27;
  my $bin = $lead . _hex2bin($hex);
  return ($sign, $bin, $exp);
}

##############################
##############################
# Convert from binary representation to the hex representation
# returned by float_H.

sub B2float_H {

  my $sign = shift;
  my $mant = shift;
  my $exp = shift;

  my $lead = substr($mant, 0, 1, '');

  $mant = _bin2hex($mant);

  return $sign . '0x' . $lead . '.' . $mant . 'p' . $exp;
}

##############################
##############################
# Takes 1 arg - the binary mantissa (including the implied leading digit).
# Aim is to standardise the binary mantissa to 109 bits by adding trailing 0 bits.
# The binary mantissa that float_H returns (in list context) is NOT standardised.
# It aims to match the mantissa that mpfr returns.
# The binary mantissa that float_H2B returns should already be standardised.

sub standardise_bin_mant {
  my $bin = shift;
  $bin .= '0' while length($bin) < 109;
  return $bin;
}

##############################
##############################
# A function to return the number of zeroes between the 2 doubles.
# Takes the 2 exponents (eg, as provided by get_exp) as args.

sub inter_zero {

  die "inter_zero() takes 2 arguments"
   unless @_ == 2;

  my($exp1, $exp2) = (shift, shift);

  return $exp1 - 53 - $exp2;

}

##############################
##############################

sub are_inf {

  for(@_) {
    if($_ == 0 || $_ / $_ == 1) {
      return 0;
    } 
  }

  return 1;

}

##############################
##############################

sub are_nan {

  for(@_) {
    return 0 if $_ == $_;
  }

  return 1;
  
}

##############################
############################## 
##############################
##############################
# Binary subtract second arg from first arg - args must be of same length.

sub _subtract_b {

    my($bin_str1, $bin_str2) = (shift, shift);
    my($len1, $len2) = (length $bin_str1, length $bin_str2);
    if($len1 != $len2) {
      warn "\n$bin_str1\n$bin_str2\n";
      die "Binary strings must be of same length - we have lengths $len1 & $len2";
    }

    my $ret = '';
    my $borrow = 0;

    for(my $i = -1; $i >= -$len1; $i--) {
      my $bottom = substr($bin_str2, $i, 1);
      if($borrow) {
        $bottom++;
        $borrow = 0;
      }

      my $top = substr($bin_str1, $i, 1);
      if($bottom > $top) {
         $top += 2;
         $borrow = 1;
      }

      $ret = ($top - $bottom) . $ret;
    }

    die "_subtract_b returned wrong value: $ret"
      if length $ret != $len1;

    return $ret;    

}
##############################
##############################
# Binary-subtract the second arg from the first arg.
# This sub written specifically for float_H().

sub _subtract_p {

    my($bin_str1, $bin_str2) = (shift, shift);
    my($len1, $len2) = (length $bin_str1, length $bin_str2);
    my $len3 = $len1 + $len2;
    my $overflow = 0;

    if($bin_str1 eq '1'. ('0' x 52)) {$overflow = 1}  

    $bin_str1 .= '0' x $len2;
    $bin_str2 = 0 x $len1 . $bin_str2;

    my $ret = '';
    my($borrow, $payback) = (0, 0);

    for(my $i = -1; $i >= -$len3; $i--) {
      my $bottom = substr($bin_str2, $i, 1);
      if($borrow) {
        $bottom++;
        $borrow = 0;
      }

      my $top = substr($bin_str1, $i, 1);
      if($bottom > $top) {
         $top += 2;
         $borrow = 1;
      }

      $ret = ($top - $bottom) . $ret;
    }

    die "_subtract_p returned wrong value: $ret"
      if length $ret != $len3;


    if($overflow && $ret =~ /^01111111111111111111111111111111111111111111111111111/) {
      return substr($ret, 1);
    }

    return $ret;    

}

##############################
##############################
# Increment a 53-bit binary string.

sub _add_1 {
  my $mant = shift;
  my $ret = '';

  my $carry = 0;

  for(my $i = -1; $i >= -53; $i--) {
    my $top = substr($mant, $i, 1);
    my $bottom = $i == -1 ? 1 : 0;
    my $sum = $top + $bottom + $carry;

    $ret = $sum % 2 . $ret;

    $carry = $sum >= 2 ? 1 : 0;
  }

  $ret = '1' . $ret if $carry;

  return $ret;
}

##############################
##############################



##############################
##############################
# Set a binary string to a specified no. of bits, rounding to nearest (ties
# to even) if the string needs to be truncated ... which it possibly does.
# Returns a list - first element is the truncated/rounded string, second
# element is 'true' iff rounding up occurred, else second element is false.
# This function is a key to determining the value of the first double, from
# the full 106-bit binary representation of the mantissa.

sub _trunc_rnd {

  my $bin = shift;
  my $binlen = shift;
  my $binlen_plus_1 = $binlen + 1;

  die "Wrong string in _trunc_rnd"
    if $bin =~ /[^01]/;

  $bin .= '0' while length($bin) < $binlen;

  my $len = length $bin;

  return ($bin, 0) if $len == $binlen; # '0' signifies that returned value was *not* rounded up.

  my $first = substr($bin, 0, $binlen);
  my $remain = substr($bin, $binlen, $len - $binlen);

  return ($first, 0) unless $remain =~ /^1/;

  if($len > $binlen_plus_1 && substr($bin, $binlen_plus_1, $len - $binlen_plus_1) =~ /1/) {
    return (Data::Float::DoubleDouble::_add_1($first), 1); # '1' signifies that returned vale *was* rounded up.
  }

  if(substr($first, -1, 1) eq '0') {return ($first, 0)}
  return (Data::Float::DoubleDouble::_add_1($first), 1);
}

##############################
##############################

sub _bin2hex {
  return unpack "H27", pack "B*", $_[0];
}

##############################
##############################

sub _hex2bin {
  return unpack "B108", pack "H27", $_[0];
}

##############################
##############################
# Take a double-double in binary form as a list of 3 args (sign, mantissa, exponent).
# If the 4th arg is 1', return the value of the first double (in the same format as
# provided by NV2H).
# For the case where 4th arg is '1' return a second value of either 0 (meaning that
# the first value was *not* rounded away from zero, or 1 (meaning that the first value
# *was* rounded away from zero).
# If the 4th arg is '2' return the value of the second double (in the same format as
# provided by NV2H).
# For the case where 4th arg is '2', the second returned value is not in any way
# useful or relevant - so we simply return undef.
# The function dies if 4th arg is neither '1' nor '2'.

sub _bin2d {

  die "4th arg to _bin2d() needs to be either '1' or '2'"
    if($_[3] != 2 && $_[3] != 1);

  my @ret;

  if($_[3] == 1) { 
    @ret = _bin2d_1(@_);
  }
  else {
    @ret = _bin2d_2(@_);
  }

  return @ret;

}

###############################
###############################
# Given the sign, the exponent, and the 53-bit mantissa of the 1st double,
# return the double as a hex dump (in the same format as provided by D2H).

sub _bin2d_1 {

  die "4th arg to _bin2d_1() needs to be '1'"
    if $_[3] != 1;

  my $sign = shift;
  my $m = shift;
  my $exp = shift;
  my $which = shift;
  
  my $pre = $exp + 1023;

  my($mant, $roundup);

  ($mant, $roundup) = _trunc_rnd($m, 53);

  if($mant !~ /1/) {
    $sign eq '-' ? return '8' . ('0' x15)
                 : return '0' x 16;
  }

  if($mant =~ /^0/ && $mant =~ /1/) {
    $pre--;
    warn "$sign\n$mant\n$exp\nExpected prefix to be zero - got $pre" if $pre;
  }

  $pre += 2048 if $sign eq '-';

  my $bin_mant = substr($mant, 1, 52);

  my $hex_mant = unpack "H13", pack "B52", $bin_mant;

  $pre = sprintf "%x", $pre;
  while(length($pre) < 3) {$pre = '0' . $pre}

  my $ret = $pre . $hex_mant;
  my $len = length($ret);

  die "$pre\n$sign\n$mant\n$exp\n_bin2d_1() wants to return a ${len}-length string: $ret"
    unless $len == 16;

  return ($ret, $roundup);
}

###############################
###############################
# Given the sign, the exponent, and the 53-bit mantissa of the 2nd double,
# return the double as a hex dump (in the same format as provided by D2H).

sub _bin2d_2 {

  die "4th arg to _bin2d_2() needs to be '2'"
    if $_[3] != 2;

  my $sign = shift;
  my $m = shift;
  my $exp = shift;
  my $which = shift;
  my $den = 0;
  my $adjust = 1;

  my $shift = 0;
  while(substr($m, $shift, 1) eq '0') {
    $shift++;
  }

  if($exp - $shift < -1022) {
    $den = 1;
    $adjust = -1023 - ($exp - $shift);

    if($adjust > $shift) {
      $den = 2;
      $adjust -= $shift;
      $m = ('0' x $adjust) . $m;
      $m = substr($m, 0, 53);
    }

    $exp = -1022;
  }

  my $pre = $exp + 1023;

  my $mant = $m;

  if($mant !~ /1/) {
    $sign eq '-' ? return '8' . ('0' x15)
                 : return '0' x 16;
  }

  if($den) {
    $pre-- if $adjust;
  }
  else {
    $mant .= '0' x $shift;
    $pre -= $shift - 1;
    $mant = substr($mant, $shift, 53);    
  }

  $pre += 2048 if $sign eq '-';

  my $bin_mant;

  if(!$den && $exp == -1022) {
    $bin_mant = substr($mant, 0, 52);
  }
  elsif($den == 1) {
    $bin_mant = substr($mant, $shift - $adjust + 1, 52);
  }
  else {
    $bin_mant = substr($mant, 1, 52);
  }
  my $hex_mant = unpack "H13", pack "B52", $bin_mant;

  $pre = sprintf "%x", $pre;
  while(length($pre) < 3) {$pre = '0' . $pre}

  my $ret = $pre . $hex_mant;

  return ($ret, undef);
}

###############################
###############################

###############################
###############################

###############################
###############################

# For compatibility with Data::Float:

*float_hex = \&float_H;
*hex_float = \&H_float;

1;

__END__

=head1 NAME

Data::Float::DoubleDouble -  human-friendly representation of the "double-double" long double


=head1 AIM

  Given a double-double value, we aim to be able to:
   1) Convert that double to its internal packed hex form;
   2) Convert the packed hex form of 1) back to the original value;
   3) Convert that double to a more readable 106-bit packed hex form,
      similar to what Data::Float's float_hex function achieves;
   4) Convert the packed hex form of 3) back to the original value;

   For 1) we use NV2H().
   For 2) we use H2NV().
   For 3) we use float_H().
   For 4) we use H_float().

   NOTE: If data is lost when float_H converts to the 106-bit form
         then H_float() cannot return the exact original value.
         (See example/caveats.p in the source.) 
         TODO: Alter float_H() so that it does not lose data. This
         would mean that it presents up to 2047-bit values (as
         needed - depending upon what the actual given value is).
         Such a change would then mean that H_float() can return
         the original value for all NV's. It would also mean that
         the string returned by float_H() is not necessarily so
         "human-friendly" after all, as it could consist of up to
         519 characters.
        


=head1 FUNCTIONS

  #############################################
  $hex = NV2H($nv);

   Returns a representation of the NV as a string of 32 hex characters.
   The first 16 characters relate to the value of the most significant
   double:
    Characters 1 to 3 (incl) embody the sign of the mantissa, the value 
    of the exponent, and the value (0 or 1) of the implied leading bit.
    Characters 4 to 16 (incl) embody the value of the 52-bit mantissa.

   The second 16 characters (17 to 32) relate to the value of the least
   siginificant double:
    Characters 17 to 19 (incl) embody the sign of the mantissa, the 
    value of the exponent, and the value (0 or 1) of the implied
    leading bit.
    Characters 20 to 32 (incl) embody the value of the 52-bit mantissa.

   For a more human-readable hex representation, use float_H().
  #############################################   

  #############################################
  $nv = H2NV($hex);

   For $hex written in the format returned by NV2H, H2NV($hex)
   returns the NV.
  #############################################

  #############################################
  $hex = D2H($nv);

   Treats the NV as a double and returns a string of 16 hex characters.
   Characters 1 to 3 (incl) embody the sign of the mantissa and the 
   value of the exponent.
   Characters 4 to 16 (incl) embody the value of the 52-bit mantissa
   of the first double.
  #############################################
   
  #############################################
  $nv = H2D($hex);

   For $hex written in the format returned by D2H, H2D($hex) returns
   the NV.
  #############################################    

  #############################################
  $readable_hex = float_H($nv);
  ($readable_hex, $mant_bin, $sign, $exp_bin) = float_H($nv);

   In scalar context returns a 106-bit hex representation of the NV
   (long double) $nv in the format
   s0xd.hhhhhhhhhhhhhhhhhhhhhhhhhhhpe where:
    s is the sign (either '-' or '+')
    0x is literally "0x"
    d is the leading (first) bit of the number (either '1' or '0')
    . is literally "." (the decimal point)
    hhhhhhhhhhhhhhhhhhhhhhhhhhh is a string of 27 hex digits
                                representing the remaining 105 bits
                                of the mantissa.
    p is a literal "p" that separates mantissa from exponent
    e is the (signed) exponent

   The keen mind will have realised that 27 hex digits encode 108
   (not 105) bits. However, the last 3 bits are to be ignored and
   will always be zero. Thus the 27th hex character will either be
   "8" (representing a "1") or "0" (representing a "0") for the
   106th bit.

   In list context, returns an additional 3 elements:
    1) the sign of the NV;
    2) a binary string representation of the NV with an *implicit*
       decimal point between the first and second (leftmost) digits;
    3) the exponent (as a base 10 count of the base 2 places).
  #############################################    

  #############################################
  $nv = H_float($hex);

   For $hex written in the format returned by float_H(), returns
   the NV that corresponds to $hex.
  #############################################    

  #############################################
  @signs = get_sign($nv);

   Returns the signs of the two doubles contained in $nv.
  #############################################

  #############################################
  @exps = get_exp($nv);

   Returns the exponents of the two doubles contained in $nv.
  #############################################

  #############################################
  @mantissas = get_mant_H(NV2H($nv));

   Returns an array of the two 52-bit mantissa components of the two
   doubles in their hex form. The value of the implied leading (most
   significant) bit is not provided. 
  #############################################

  #############################################
  $intermediate_zeroes = inter_zero(get_exp($nv));

   Returns the number of zeroes that need to come between the
   mantissas of the 2 doubles when $nv is translated to the
   representation that float_H() returns.
  #############################################

  #############################################
  $bool = are_inf(@nv);

   Returns true if and only if all of the (NV) arguments are
   infinities.
   Else returns false.
  #############################################

  #############################################
  $bool = are_nan(@nv);

   Returns true if and only if all of the (NV) arguments are NaNs.
   Else returns false.
  #############################################

=head1 TODO

   Over time, introduce the features of (and functions provided by)
   Data::Float

=head1 LICENSE

   This program is free software; you may redistribute it and/or 
   modify it under the same terms as Perl itself.
   Copyright 2014 Sisyphus

=head1 AUTHOR

   Sisyphus <sisyphus at(@) cpan dot (.) org>

=cut