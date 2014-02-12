package Data::Float::DoubleDouble;
use warnings;
use strict;
use Config;

require 5.010;

require Exporter;
*import = \&Exporter::import;

@Data::Float::DoubleDouble::EXPORT_OK = qw(NV2H H2NV D2H H2D get_sign
 get_exp get_mant_H float_H H_float inter_zero are_inf are_nan
 float_H2B B2float_H standardise_bin_mant hex_float float_hex get_bin
 float_is_infinite float_is_nan float_is_finite float_is_zero float_is_nzfinite
 float_is_normal float_is_subnormal float_class);

%Data::Float::DoubleDouble::EXPORT_TAGS = (all =>[qw(NV2H H2NV D2H H2D
 get_sign get_exp get_mant_H float_H H_float inter_zero are_inf are_nan
 float_H2B B2float_H standardise_bin_mant float_hex hex_float get_bin
 float_is_infinite float_is_nan float_is_finite float_is_zero float_is_nzfinite
 float_is_normal float_is_subnormal float_class)]);

our $VERSION = '1.02';
$VERSION = eval $VERSION;

#$Data::Float::DoubleDouble::debug = 0; 
#$Data::Float::DoubleDouble::pack = $Config{nvtype} eq 'double' ? "F<" : "D<";

### NOTE ###
# The biggest representable power of 2 in a double is 2 **  1023  ('1' followed by '0' x 1023)
# The least representable power of 2 in a double is   2 **  -1074 ('1' preceded by '0' x 1073)
# The double-double is capable of exactly encapsulating the sum of those 2 values
# Binary representation is '1' . '0' x 2096 . '1', with implied radix point after the 1023rd '0'.
# inter_zero() for such a number returns 1992, which is 2096 - (2 * 52).

##############################
##############################
# A function to return the hex representation of the NV:

sub NV2H {

  return scalar reverse unpack "h*", pack "D<", $_[0];

}

##############################
##############################
# A function to return an NV from the hex representation provided by NV2H().

sub H2NV {

  return unpack "D<", pack "h*", scalar reverse $_[0];

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
# Return a 3-element list for the given double-double:
# 1) sign
# 2) mantissa (in binary, implicit radix point after first digit)
# 3) exponent
# For nan/inf, the mantissa is 'nan' or 'inf' respectively.

sub get_bin {
  my $hex = NV2H($_[0]);

  if($hex eq '7ff00000000000000000000000000000') { # +inf
    return ('+', 'inf', 1024);
  }
  if($hex eq 'fff00000000000000000000000000000') { # -inf
    return ('-', 'inf', 1024);
  }
  if($hex eq '7ff80000000000000000000000000000') { # + nan
    return ('+', 'nan', 1024);
  }
  if($hex eq 'fff80000000000008000000000000000') { # - nan
    return ('-', 'nan', 1024);
  }

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

  my $sign_compare;

  # Check whether either string is zero and modify signs accordingly
  # Check $bin_str2 *first*
  $sign2 = $sign1 if ($bin_str2 !~ /1/ && !$pre2);
  $sign1 = $sign2 if ($bin_str1 !~ /1/ && !$pre1);

  my $bin_pre1 = $pre1 ? '1' : '0';

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

  my($bin, $pow_adjust);

  if($sign1 eq $sign2) {
    $pow_adjust = 0;
    $bin = $bin_pre1 . $bin_str1 . $zeroes . $bin_pre2 . $bin_str2;
  }
  else {
    ($bin, $pow_adjust) = _subtract_p($bin_pre1 . $bin_str1, $zeroes . $bin_pre2 . $bin_str2); 
  }

  my $single_exp = $pre1 - 1023 - $pow_adjust;

  $bin =~ s/0+$//; # Remove trailing zeroes
  $bin .= '0' while length($bin) < 108; # Make sure the mantissa of $hex is always at least 108 bits.
  $bin .= '0' while length($bin) % 4;

  return($single_sign, $bin, $single_exp);

}

##############################
##############################

##############################
##############################
# Return a hex string representation as per perl Data::Float
# For NaN and Inf returns 'nan' or 'inf' (prefixed with either
# '+' or '-' as appropriate).

sub float_H {
  my ($sign, $mant, $exp);
  if(@_ == 1)    {($sign, $mant, $exp) = get_bin($_[0])}
  elsif(@_ == 3) {($sign, $mant, $exp) = ($_[0], $_[1], $_[2])}
  else { die "Expected either 1 or 3 args to float_H() - received ", scalar @_}

  if($mant eq 'nan') {
    $sign eq '-' ? return '-nan'
                 : return '+nan'; 
  }
  if($mant eq 'inf') {
    $sign eq '-' ? return '-inf'
                 : return '+inf';
  }

  my $mant_len = length $mant;

  # Mantissa returned by get_bin is at least 108 bits
  die "Mantissa calculated by float_H() is too short ($mant_len)"
    if $mant_len < 108;

  # Length of mantissa returned by get_bin() is always
  # evenly divisible by 4
  die "Mantissa calculated by float_H() is not divisible by 4 ($mant_len)"
    if $mant_len % 4;

  my $prefix = $sign . '0x' . substr($mant, 0, 1, '') . '.';

 
  $mant .= '0' while length($mant) % 4;

  #my $H_items = length($mant) / 4;
  #my $middle = unpack "H$H_items", pack "B*", $mant;

  my $middle = _bin2hex($mant);

  my $suffix = "p$exp";

  return $prefix . $middle . $suffix;
}

##############################
##############################
# Receive the hex argument returned by float_H(), and return the original NV.

sub H_float {

  if($_[0] eq '+inf') {return H2NV('7ff00000000000000000000000000000')} # +inf
  if($_[0] eq '-inf') {return H2NV('fff00000000000000000000000000000')} # -inf
  if($_[0] eq '+nan') {return H2NV('7ff80000000000000000000000000000')} # + nan
  if($_[0] eq '-nan') {return H2NV('fff80000000000008000000000000000')} # - nan

  my($sign, $mant, $exp) = float_H2B($_[0]);
  my $overflow = 0;
  my $overflow_exp = $exp + 1;

  my ($d1_bin, $roundup) = _trunc_rnd($mant, 53);

  if(!$roundup) {
    my $s = $sign eq '-' ? -1.0 : 1.0;
    my @d = _calculate($mant, $exp);
    if($d[0] == 0 && $sign eq '-') {
      return H2NV('80000000000000000000000000000000');
    }
    return $d[0] * $s;
  }
  else {
    my $s = $sign eq '-' ? -1.0 : 1.0;
    my $binlen = length $mant;

    if(length($d1_bin) == 54) { # overflow when doing _trunc_rnd()
      $overflow = 1;
      $mant = '0' . $mant;
      $exp++;
    }

    my $subtract_from = $d1_bin . '0' x ($binlen - 53);
    #warn "\n$binlen ", length($d1_bin), " ", length($subtract_from), "\n";

    my $m = _subtract_b($subtract_from, $mant);

    $m = substr($m, 53) unless $overflow;

    # decrement exponent if $d1 ends in 12 zeroes && $bin[1] begins with 53 zeroes
    #$exp -- if($d1_bin =~ /0000000000000$/ && $mant =~ /^11111111111111111111111111111111111111111111111111111/);

    my ($d1, $exponent) = _calculate($d1_bin, $exp);
    $exponent = $overflow_exp if $overflow;
    my ($d2, $discard) = _calculate($m, $exponent);

    if($d1 - $d2 == 0 && $sign eq '-') {
      return H2NV('80000000000000000000000000000000');
    }
    return ($d1 - $d2) * $s;
  }
}

##############################
##############################
# Convert the hex format returned by float_H to binary.
# An array of 3 elements is returned - sign, mantissa, exponent.
# For nan/inf the mantissa is set to 'nan' or 'inf' respectively.

sub float_H2B {

  if($_[0] eq '+inf') {
    return ('+', 'inf', 1024);
  }
  if($_[0] eq '-inf') {
    return ('-', 'inf', 1024);
  }
  if($_[0] eq '+nan') {
    return ('+', 'nan', 1024);
  }
  if($_[0] eq '- nan') {
    return ('-', 'nan', 1024);
  }

  my $sign = $_[0] =~ /^\-/ ? '-' : '+';
  my @split = split /p/, $_[0];
  my $exp = $split[1];
  my $lead = substr($_[0], 3, 1);
  die "Wrong leading digit" unless $lead =~ /[01]/;
  my $hex = (split /\./, $split[0])[1];
  die "Wrong number of hex chars" unless length($hex) >= 27;
  my $bin = $lead . _hex2bin($hex);
  $bin =~ s/0$//;
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

  if($mant eq 'inf') {
    $sign eq '-' ? return '-inf'
                 : return '+inf';
  }
  if($mant eq 'nan') {
    $sign eq '-' ? return '-nan'
                 : return '+nan';
  }

  my $lead = substr($mant, 0, 1, '');

  $mant = _bin2hex($mant);

  return $sign . '0x' . $lead . '.' . $mant . 'p' . $exp;
}

##############################
##############################

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
# Return true iff the argument is infinite.

sub are_inf {

  for(@_) {
    if($_ == 0 || $_ / $_ == 1 || $_ != $_) {
      return 0;
    } 
  }

  return 1;

}

##############################
##############################
# Return true iff the argument is a NaN.

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
# This sub written specifically for get_bin() the output of which,
# is, in turn, needed for float_H().

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
      return (substr($ret, 1), 1);
    }

    return ($ret, 0);    

}

##############################
##############################
# Convert a binary string to a hex string.

sub _bin2hex {
  my $len = length($_[0]);
  die "Wrong length ($len) supplied to _bin2hex()"
    if $len % 4;
  $len /=  4;
  return unpack "H$len", pack "B*", $_[0];
}

##############################
##############################
# Convert a hex string to a binary string.

sub _hex2bin {
  my $H_len = length($_[0]);
  my $B_len = $H_len * 4;
  return unpack "B$B_len", pack "H$H_len", $_[0];
  #return unpack "B*", pack "H*", $_[0];
}

##############################
##############################
# Calculate the value of the double-double using the
# base 2 representation. (Used by H_float.)

sub _calculate {
    my $bin = $_[0];
    my $exp = $_[1];
    my $ret = 0;

    my $binlen = length($bin);
    $binlen--;

    for my $pos(0 .. $binlen) {
      $ret += substr($bin, $pos, 1) ? 2 ** $exp : 0;
      $exp--;
    }

    return ($ret, $exp);
}

##############################
##############################
# Increment a binary string.
# Length of returned string will be either $len or $len+1 

sub _add_1 {
  my $mant = shift;
  my $len = length $mant;
  my $ret = '';

  my $carry = 0;

  for(my $i = -1; $i >= -$len; $i--) {
    my $top = substr($mant, $i, 1);
    my $bottom = $i == -1 ? 1 : 0;
    my $sum = $top + $bottom + $carry;

    $ret = ($sum % 2) . $ret;

    $carry = $sum >= 2 ? 1 : 0;
  }

  $ret = '1' . $ret if $carry;

  return $ret; 
}

##############################
##############################
# Normally, the 2 args that this function receives will be:
#  1) The base 2 representation (including the implied leading 0 or 1)
#     of the double-double we're working with;
#  2) The length to which we wish to truncate the string of bits (usually 53).
#
# Set a binary string to a specified no. of bits, rounding to nearest (ties
# to even) if the string needs to be truncated ... which it possibly does.
# Returns a list - first element is the truncated/rounded string, second
# element is 'true' iff rounding up occurred, else second element is false.
# This function is a key to determining the value of the double-double's
# two doubles, from the entire binary representation of the mantissa.

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
  return (_add_1($first), 1);
}

##############################
##############################

# For compatibility with Data::Float:

sub float_class {
  return "NAN" if float_is_nan($_[0]);
  return "INFINITE" if float_is_infinite($_[0]);
  return "ZERO" if $_[0] == 0;
  return "SUBNORMAL" if float_is_subnormal($_[0]);
  return "NORMAL" if float_is_normal($_[0]);
  die "Cannot determine class of float";
}

sub float_is_finite {
  !are_inf($_[0]) && !are_nan($_[0]) ? return 1
                                     : return 0;
}

sub float_is_zero {
  return 1 if $_[0] == 0;
  return 0;
}

sub float_is_nzfinite {
  return 1 if (float_is_finite($_[0]) && $_[0] != 0);
  return 0;
}

sub float_is_normal {
  return 1 if(float_is_nzfinite($_[0]) && float_hex($_[0]) =~ /1\./);
  return 0;
}

sub float_is_subnormal {
  return 1 if(float_is_nzfinite($_[0]) && float_hex($_[0]) =~ /0\./);
  return 0;
}

*float_hex = \&float_H;
*hex_float = \&H_float;
*float_is_infinite = \&are_inf;
*float_is_nan = \&are_nan;

1;

__END__

=head1 NAME

Data::Float::DoubleDouble -  human-friendly representation of the "double-double" long double


=head1 AIM

  Mostly, one would use Data::Float to do what this module does.
  But that module doesn't work with the powerpc long double,
  which uses a 'double-double' arrangement ... hence, this module.

  Given a double-double value, we aim to be able to:
   1) Convert that NV to its internal packed hex form;
   2) Convert the packed hex form of 1) back to the original value;
   3) Convert that NV to a more human-readable packed hex form,
      similar to what Data::Float's float_hex function achieves;
   4) Convert the packed hex form of 3) back to the original value;

   For 1) we use NV2H().
   For 2) we use H2NV().
   For 3) we use float_H().
   For 4) we use H_float().


=head1 FUNCTIONS

  #############################################
  $hex = NV2H($nv);

   Unpacks the NV to a string of 32 hex characters.
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
  $nv = H2NV($hex);

   For $hex written in the format returned by NV2H, H2NV($hex)
   returns the NV.
  #############################################
  $hex = D2H($nv);

   Treats the NV as a double and returns a string of 16 hex characters.
   Characters 1 to 3 (incl) embody the sign of the mantissa, the value
   (0 or 1) of the implied leading bit and the value of the exponent.
   Characters 4 to 16 (incl) embody the value of the 52-bit mantissa
   of the first double.
  #############################################
  $nv = H2D($hex);

   For $hex written in the format returned by D2H, H2D($hex) returns
   the NV.
  #############################################
  $readable_hex = float_H($nv); # Aliased to float_hex

   For *most* NVs, returns a 106-bit hex representation of the NV
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
   will always be zero for a 106-bit float. Thus the 27th hex
   character for a 106-bit float will either be "8" (representing
   a "1") or "0" (representing a "0") for the 106th bit.

   BUT: Some NV values encapsulate a value that require more than
        106 bits in order to be correctly represented.
        If the string that float_H returns is larger than as
        described above, then it will, however,  have returned a
        string that contains the *minimum* number of characters
        needed to accurately represent the given value.
        As an extreme example: the double-double arrangement can
        represent the value 2**1023 + 2**-1074, but to express
        that value as a stream of bits requires 2098 bits, and to
        express that value in the format that float_H returns
        requires 526 hex characters (all of which are zero, except
        for the first and the last). When you add the sign, radix
        point, exponent, etc., the float_H representation of that
        value consists of 535 characters.

  #############################################
  $nv = H_float($hex);

   For $hex written in the format returned by float_H(), returns
   the NV that corresponds to $hex.
  #############################################  
  @bin = get_bin($nv);

   Returns the sign, the mantissa (as a base 2 string), and the
   exponent of $nv. (There's an implied radix point between the
   first and second digits of the mantissa).
  #############################################
  @bin = float_H2B($hex);

   As for the above get_bin() function - but takes the hex
   string of the NV (as returned by float_H) as its argument,
   instead of the actual NV.
   For a more direct way of obtaining the array, use get_bin
   instead.
  #############################################
  $hex = B2float_H(@bin);

   The reverse of float_H2B. It takes the array returned by
   either get_bin or float_H2B as its arguments, and returns
   the corresponding hex form.
  #############################################
  ($sign1, $sign2) = get_sign($nv);

   Returns the signs of the two doubles contained in $nv.
  #############################################
  ($exp1, $exp2) = get_exp($nv);

   Returns the exponents of the two doubles contained in $nv.
  #############################################
  ($mantissa1, $mantissa2) = get_mant_H(NV2H($nv));

   Returns an array of the two 52-bit mantissa components of
   the two doubles in their hex form. The values of the
   implied leading (most significant) bits are not provided,
   nor are the values of the two exponents. 
  #############################################
  $intermediate_zeroes = inter_zero(get_exp($nv));

   Returns the number of zeroes that need to come between the
   mantissas of the 2 doubles when $nv is translated to the
   representation that float_H() returns.
  #############################################
  $bool = are_inf(@nv); # Aliased to float_is_infinite.

   Returns true if and only if all of the (NV) arguments are
   infinities.
   Else returns false.
  #############################################
  $bool = are_nan(@nv); # Aliased to float_is_nan.

   Returns true if and only if all of the (NV) arguments are
   NaNs. Else returns false.
  #############################################

  For Compatibility with Data::Float:

  #############################################
  $class = float_class($nv);

   Returns one of either "NAN", "INFINITE", "ZERO", "NORMAL"
   or "SUBNORMAL" - whichever is appropriate. (The NV must
   belong to one (and only one) class.
  #############################################
  $bool = float_is_nan($nv); # Alias for are_nan()

   Returns true if $nv is a NaN.
   Else returns false. 
  #############################################
  $bool = float_is_infinite($nv); # Alias for are_inf()

   Returns true if $nv is infinite.
   Else returns false.
  #############################################
  $bool = float_is_finite($nv);

   Returns true if NV is neither infinite nor a NaN.
   Else returns false.
  #############################################
  $bool = float_is_nzfinite($nv);

   Returns true if NV is neither infinite, nor a NaN, nor zero.
   Else returns false.
  #############################################
  $bool = float_is_zero($nv);

   Returns true if NV is zero.
   Else returns false.
  #############################################
  $bool = float_is_normal($nv);

   Returns true if NV is finite && non-zero && the implied
   leading digit in its internal representation is '1'.
   Else returns false.
  #############################################
  $bool = float_is_subnormal($nv);

   Returns true if NV is finite && non-zero && the implied
   leading digit in its internal representation is '0'.
  #############################################

  #############################################
  #############################################
  #############################################
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