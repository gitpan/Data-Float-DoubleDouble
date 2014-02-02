use ExtUtils::MakeMaker;
use strict;
use warnings;

require 5.010;

if($Config::Config{nvtype} ne 'long double') {
  warn "  This module is usable only with 'long double' builds of perl\n",
       "  Your \$Config{nvtype} reports '", $Config::Config{nvtype}, "'";
  exit 0;
} 

my $nv1 = 1.0;
my $nv2 = $nv1 + (2 ** -200);

if($nv1 == $nv2) {
  warn "  This module is not usable with this architecture's long double\n",
       "  It requires that the long double type is a 'double-double'\n";
  exit 0;
}

my %h = (NAME => 'Data::Float::DoubleDouble',
         VERSION_FROM => 'DoubleDouble.pm',
         PREREQ_PM => {'Math::NV' => '0.02'},
        );

WriteMakefile(%h);