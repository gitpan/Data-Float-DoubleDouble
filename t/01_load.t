use strict;
use warnings;

print "1..1\n";

eval {require Data::Float::DoubleDouble;};

if($@) {
  warn "\$\@: $@";
  print "not ok 1\n";
}
else {print "ok 1\n"}