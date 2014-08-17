# We provide valid_hex, valid_bin, and valid_unpack.
# This test script aims at testing those subs.
# It is nowhere near complete.

use strict;
use warnings;
use Data::Float::DoubleDouble qw(:all);

my $t = 7;
print "1..$t\n";

my $pinf =  H2NV('7ff00000000000000000000000000000');
my $ninf =  H2NV('fff00000000000000000000000000000');
my $pnan =  H2NV('7ff80000000000000000000000000000');
my $nnan =  H2NV('fff80000000000008000000000000000');
my $pzero = H2NV('00000000000000000000000000000000');
my $nzero = H2NV('80000000000000000000000000000000');

my $ok = 1;
$t = 1;

for($pinf, $ninf, $pnan, $nnan, $pzero, $nzero) {

   my @one = float_B  ($_, 'raw');
   my @two = float_H2B(float_H($_, 'raw'), 'raw');

   unless(is_same(\@one, \@two)) {
     warn "NV: $_\n";
     $ok = 0;
   }

   my @check = valid_bin(@one, 0);

   unless(is_same(\@one, \@check)) {
     warn "NV: $_\n";
     $ok = 0;
   }

   my $hex = float_H($_, 'raw');

   if($hex ne valid_hex($hex, 1)) {
     warn "\n$_: $hex ", valid_hex($hex), "\n";
     $ok = 0;
   }

   my $nv2h = NV2H($_);

   if($nv2h ne valid_unpack($nv2h, 1)) {
     warn "\n$_: $nv2h ", valid_unpack($nv2h), "\n";
     $ok = 0;
   }

}

# test 1

if($ok) {print "ok $t\n"}
else {print "not ok $t\n"}
$t++;
$ok = 1;

for('+', '-', '') {
  my @bin = ($_, 'inf', 1024);
  my @one = $_ ? @bin
                 : ('+', 'inf', 1024);
  my @two = valid_bin(@bin);
  $ok = 0 unless is_same(\@one, \@two);
}

# test 2

if($ok) {print "ok $t\n"}
else {print "not ok $t\n"}
$t++;
$ok = 1;

for('+', '-', '') {
  my @bin = ($_, 'nan', 1024);
  my @one = $_ ? @bin
                 : ('+', 'nan', 1024);
  my @two = valid_bin(@bin);
  $ok = 0 unless is_same(\@one, \@two);
}

# test 3

if($ok) {print "ok $t\n"}
else {print "not ok $t\n"}
$t++;
$ok = 1;

for('+', '-', '') {
  my $h = $_ . 'inf';
  my $wanted = $_ ? $h
                  : '+inf';
  my $v = valid_hex($h);
  $ok = 0 unless $v eq $wanted;
}

# test 4

if($ok) {print "ok $t\n"}
else {print "not ok $t\n"}
$t++;
$ok = 1;

for('+', '-', '') {
  my $h = $_ . 'nan';
  my $wanted = $_ ? $h
                  : '+nan';
  my $v = valid_hex($h);
  $ok = 0 unless $v eq $wanted;
}

# test 5

if($ok) {print "ok $t\n"}
else {print "not ok $t\n"}
$t++;
$ok = 1;

eval {valid_bin('', '0000001000100', '1024');};

# test 6

if($@ =~ /^Invalid inf\/nan format/) {
  print "ok $t\n";
}
else {
  warn "n\$\@: $@\n";
  print "not ok $t\n";
}
$t++;

eval {valid_hex('0x0.111110000000000000000000000p1024');};

# test 7
if($@ =~ /^Invalid inf\/nan format/) {
  print "ok $t\n";
}
else {
  warn "n\$\@: $@\n";
  print "not ok $t\n";
}
$t++;

sub is_same {
   my @one = @{$_[0]};
   my @two = @{$_[1]};

   return 0 if @one != @two;

   for(0..$#one) {
     if($one[$_] ne $two[$_]) {
       warn "\n$one[$_] $two[$_]\n";
       return 0;
     }
   }
   return 1;
}
