
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


/* Radix of exponent representation, b. */

SV * _FLT_RADIX(void) {
#ifdef FLT_RADIX
 return newSViv(FLT_RADIX);
#else
 return &PL_sv_undef;
#endif
}

/* Maximum representable finite floating-point number,

	(1 - b**-p) * b**emax
*/

SV * _LDBL_MAX(void) {
#ifdef LDBL_MAX
 return newSVnv(LDBL_MAX);
#else
 return &PL_sv_undef;
#endif
}

/* Minimum normalized positive floating-point number, b**(emin - 1).  */

SV * _LDBL_MIN(void) {
#ifdef LDBL_MIN
 return newSVnv(LDBL_MIN);
#else
 return &PL_sv_undef;
#endif
}

/* Number of decimal digits, q, such that any floating-point number with q
   decimal digits can be rounded into a floating-point number with p radix b
   digits and back again without change to the q decimal digits,

	p * log10(b)			if b is a power of 10
	floor((p - 1) * log10(b))	otherwise
*/

SV * _LDBL_DIG(void) {
#ifdef LDBL_DIG
 return newSViv(LDBL_DIG);
#else
 return &PL_sv_undef;
#endif
}

/* Number of base-FLT_RADIX digits in the significand, p.  */

SV * _LDBL_MANT_DIG(void) {
#ifdef LDBL_MANT_DIG
 return newSViv(LDBL_MANT_DIG);
#else
 return &PL_sv_undef;
#endif
}

/* Minimum int x such that FLT_RADIX**(x-1) is a normalized float, emin */

SV * _LDBL_MIN_EXP(void) {
#ifdef LDBL_MIN_EXP
 return newSViv(LDBL_MIN_EXP);
#else
 return &PL_sv_undef;
#endif
}

/* Maximum int x such that FLT_RADIX**(x-1) is a representable float, emax.  */

SV * _LDBL_MAX_EXP(void) {
#ifdef LDBL_MAX_EXP
 return newSViv(LDBL_MAX_EXP);
#else
 return &PL_sv_undef;
#endif
}

/* Minimum negative integer such that 10 raised to that power is in the
   range of normalized floating-point numbers,

	ceil(log10(b) * (emin - 1))
*/

SV * _LDBL_MIN_10_EXP(void) {
#ifdef LDBL_MIN_10_EXP
 return newSViv(LDBL_MIN_10_EXP);
#else
 return &PL_sv_undef;
#endif
}

/* Maximum integer such that 10 raised to that power is in the range of
   representable finite floating-point numbers,

	floor(log10((1 - b**-p) * b**emax))
*/

SV * _LDBL_MAX_10_EXP(void) {
#ifdef LDBL_MAX_10_EXP
 return newSViv(LDBL_MAX_10_EXP);
#else
 return &PL_sv_undef;
#endif
}

/* The difference between 1 and the least value greater than 1 that is
   representable in the given floating point type, b**1-p.  */

SV * _LDBL_EPSILON(void) {
#ifdef LDBL_EPSILON
 return newSVnv(LDBL_EPSILON);
#else
 return &PL_sv_undef;
#endif
}

SV * _LDBL_DECIMAL_DIG(void) {
#ifdef LDBL_DECIMAL_DIG
 return newSViv(LDBL_DECIMAL_DIG);
#else
 return &PL_sv_undef;
#endif
}

/* Whether types support subnormal numbers.  */

SV * _LDBL_HAS_SUBNORM(void) {
#ifdef LDBL_HAS_SUBNORM
 return newSViv(LDBL_HAS_SUBNORM);
#else
 return &PL_sv_undef;
#endif
}

/* Minimum positive values, including subnormals.  */

SV * _LDBL_TRUE_MIN(void) {
#ifdef LDBL_TRUE_MIN
 return newSVnv(LDBL_TRUE_MIN);
#else
 return &PL_sv_undef;
#endif
}
















MODULE = Data::Float::DoubleDouble	PACKAGE = Data::Float::DoubleDouble	

PROTOTYPES: DISABLE


SV *
_FLT_RADIX ()
		

SV *
_LDBL_MAX ()
		

SV *
_LDBL_MIN ()
		

SV *
_LDBL_DIG ()
		

SV *
_LDBL_MANT_DIG ()
		

SV *
_LDBL_MIN_EXP ()
		

SV *
_LDBL_MAX_EXP ()
		

SV *
_LDBL_MIN_10_EXP ()
		

SV *
_LDBL_MAX_10_EXP ()
		

SV *
_LDBL_EPSILON ()
		

SV *
_LDBL_DECIMAL_DIG ()
		

SV *
_LDBL_HAS_SUBNORM ()
		

SV *
_LDBL_TRUE_MIN ()
		

