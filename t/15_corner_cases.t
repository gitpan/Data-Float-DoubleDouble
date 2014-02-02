use strict;
use warnings;
use Math::NV qw(:all);
use Data::Float::DoubleDouble qw(:all);

my $t = 10;

print "1..$t\n";

my $ok = 1;

my @case1 = ('9007199254740991.01', '9007199254740991.04', '9007199254740991.05', '9007199254740991.06',
            '9007199254740991.09',
            '9007199254740991.02', '9007199254740991.03', '9007199254740991.07', '9007199254740991.08',
            '9007199254740991.11', '9007199254740991.14', '9007199254740991.15', '9007199254740991.16',
            '9007199254740991.10', '9007199254740991.12', '9007199254740991.13', '9007199254740991.17',
            '9007199254740991.19',
            '9007199254740991.41', '9007199254740991.44', '9007199254740991.45', '9007199254740991.46',
            '9007199254740991.40', '9007199254740991.42', '9007199254740991.43', '9007199254740991.48',
            '9007199254740991.49', '9007199254740991.4999999',
            '9007199254740991.50', '9007199254740991.51', '9007199254740991.55', '9007199254740991.56',
            '9007199254740991.52', '9007199254740991.53', '9007199254740991.57', '9007199254740991.58',
            '9007199254740991.59',
            '9007199254740991.61', '9007199254740991.64', '9007199254740991.65', '9007199254740991.66',
            '9007199254740991.69',
            '9007199254740991.91', '9007199254740991.94', '9007199254740991.95', '9007199254740991.96',
            '9007199254740991.90', '9007199254740991.94999999', '9007199254740991.92', '9007199254740991.93',
            '9007199254740991.99',
           );

my @case2 = ('9007199254740990.01', '9007199254740990.04', '9007199254740990.05', '9007199254740990.06',
            '9007199254740990.09',
            '9007199254740990.11', '9007199254740990.14', '9007199254740990.15', '9007199254740990.16',
            '9007199254740990.19',
            '9007199254740990.41', '9007199254740990.44', '9007199254740990.45', '9007199254740990.46',
            '9007199254740990.49',
            '9007199254740990.50', '9007199254740990.51', '9007199254740990.55', '9007199254740990.56',
            '9007199254740990.59',
            '9007199254740990.61', '9007199254740990.64', '9007199254740990.65', '9007199254740990.66',
            '9007199254740990.69',
            '9007199254740990.91', '9007199254740990.94', '9007199254740990.95', '9007199254740990.96',
            '9007199254740990.99',
           );

my @case3 = ('4503599627370495.01', '4503599627370495.04', '4503599627370495.05', '4503599627370495.06',
            '4503599627370495.09',
            '4503599627370495.11', '4503599627370495.14', '4503599627370495.15', '4503599627370495.16',
            '4503599627370495.19',
            '4503599627370495.41', '4503599627370495.44', '4503599627370495.45', '4503599627370495.46',
            '4503599627370495.49',
            '4503599627370495.50', '4503599627370495.51', '4503599627370495.55', '4503599627370495.56',
            '4503599627370495.59',
            '4503599627370495.61', '4503599627370495.64', '4503599627370495.65', '4503599627370495.66',
            '4503599627370495.69',
            '4503599627370495.91', '4503599627370495.94', '4503599627370495.95', '4503599627370495.96',
            '4503599627370495.99',
           );

for my $str(@case1) {
  my $nv = nv($str);
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($nv != $nv_redone) {
    warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
    $ok = 0;
  }

  if($h ne $h_redone) {
    warn "\n\$h: $h\n\$h_redone: $h_redone\n";
    $ok = 0;
  }
}

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

$ok = 1;

for my $str(@case1) {
  my $nv = nv("-$str");
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($nv != $nv_redone) {
    warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
    $ok = 0;
  }

  if($h ne $h_redone) {
    warn "\n\$h: $h\n\$h_redone: $h_redone\n";
    $ok = 0;
  }
}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

$ok = 1;

for my $str(@case2) {
  my $nv = nv($str);
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($nv != $nv_redone) {
    warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
    $ok = 0;
  }

  if($h ne $h_redone) {
    warn "\n\$h: $h\n\$h_redone: $h_redone\n";
    $ok = 0;
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

$ok = 1;

for my $str(@case2) {
  my $nv = nv("-$str");
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($nv != $nv_redone) {
    warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
    $ok = 0;
  }

  if($h ne $h_redone) {
    warn "\n\$h: $h\n\$h_redone: $h_redone\n";
    $ok = 0;
  }
}

if($ok) {print "ok 4\n"}
else {print "not ok 4\n"}

$ok = 1;

for my $str(@case3) {
  my $nv = nv($str);
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($nv != $nv_redone) {
    warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
    $ok = 0;
  }

  if($h ne $h_redone) {
    warn "\n\$h: $h\n\$h_redone: $h_redone\n";
    $ok = 0;
  }
}

if($ok) {print "ok 5\n"}
else {print "not ok 5\n"}

$ok = 1;

for my $str(@case3) {
  my $nv = nv("-$str");
  my $hex = float_H($nv);
  my $nv_redone = H_float($hex);

  my $h = NV2H($nv);
  my $h_redone = NV2H($nv_redone);

  if($nv != $nv_redone) {
    warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
    $ok = 0;
  }

  if($h ne $h_redone) {
    if($h_redone eq 'c32fffffffffffff8000000000000000' &&
       $h eq 'c32fffffffffffff0000000000000000') {$ok = 1}
    else {
      warn "\n\$h: $h\n\$h_redone: $h_redone\n";
      $ok = 0;
    }
  }
}

if($ok) {print "ok 6\n"}
else {print "not ok 6\n"}

$ok = 1;

for my $str(@case1) {
  $str =~ s/\.//;
  $str = '0.' . $str;

  for my $exp(0..20, 298..308) {
    my $nv = nv($str . "e$exp");
    my $hex = float_H($nv);
    my $nv_redone = H_float($hex);

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($nv != $nv_redone) {
      warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
      $ok = 0;
    }

    if($h ne $h_redone) {
      warn "\n\$h: $h\n\$h_redone: $h_redone\n";
      $ok = 0;
    }
  }
}

if($ok) {print "ok 7\n"}
else {print "not ok 7\n"}

$ok = 1;

for my $str(@case1) {
  $str =~ s/\.//;
  $str = '0.' . $str;

  for my $exp(0..20, 298..308) {
    my $nv = nv($str . "e-$exp");
    my $hex = float_H($nv);
    my $nv_redone = H_float($hex);

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($nv != $nv_redone) {
      warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
      $ok = 0;
    }

    if($h ne $h_redone) {
      warn "\n\$h: $h\n\$h_redone: $h_redone\n";
      $ok = 0;
    }
  }
}

if($ok) {print "ok 8\n"}
else {print "not ok 8\n"}

$ok = 1;

for my $str(@case1) {
  $str =~ s/\.//;
  $str = '-0.' . $str;

  for my $exp(0..20, 298..308) {
    my $nv = nv($str . "e$exp");
    my $hex = float_H($nv);
    my $nv_redone = H_float($hex);

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($nv != $nv_redone) {
      warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
      $ok = 0;
    }

    if($h ne $h_redone) {
      warn "\n\$h: $h\n\$h_redone: $h_redone\n";
      $ok = 0;
    }
  }
}

if($ok) {print "ok 9\n"}
else {print "not ok 9\n"}

$ok = 1;

for my $str(@case1) {
  $str =~ s/\.//;
  $str = '-0.' . $str;

  for my $exp(0..20, 298..308) {
    my $nv = nv($str . "e-$exp");
    my $hex = float_H($nv);
    my $nv_redone = H_float($hex);

    my $h = NV2H($nv);
    my $h_redone = NV2H($nv_redone);

    if($nv != $nv_redone) {
      warn "\n\$nv: $nv\n\$nv_redone: $nv_redone\n";
      $ok = 0;
    }

    if($h ne $h_redone) {
      if($h eq '80000000000000000000000000000000' &&
         $h_redone eq '80000000000000008000000000000000') {$ok = 1}
      else {
        warn "\n\$h: $h\n\$h_redone: $h_redone\n";
        $ok = 0;
      }
    }
  }
}

if($ok) {print "ok 10\n"}
else {print "not ok 10\n"}

$ok = 1;