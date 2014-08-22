use strict;
use warnings;

print "1..2\n";

eval {require Data::Float::DoubleDouble;};

if($@) {
  warn "\$\@: $@";
  print "not ok 1\n";
}
else {print "ok 1\n"}

if($Data::Float::DoubleDouble::VERSION eq '1.06') {
  print "ok 2\n";
}
else {
  warn "version: $Data::Float::DoubleDouble::VERSION\n";
  print "not ok 2\n";
}
