/*
 * mf_arith.c -- optimized arithmetic routines for UNIX METAFONT 84
 *
 *	These functions account for a significant percentage of the processing
 *	time used by METAFONT, and have been recoded in assembly language for
 *	some classes of machines.
 *
 *      As yet I don't have code for SPARC, so I'm just using a C version
 *      by richards, in hopes that cc does better than pc on the brute-force
 *      algorithm found in mf.web.
 *
 *	function makefraction(p, q: integer): fraction;
 *		{ Calculate the function floor( (p * 2^28) / q + 0.5 )	}
 *		{ if both p and q are positive.  If not, then the value	}
 *		{ of makefraction is calculated as though both *were*	}
 *		{ positive, then the result sign adjusted.		}
 *		{ (e.g. makefraction ALWAYS rounds away from zero)	}
 *		{ In case of an overflow, return the largest possible	}
 *		{ value (2^32-1) with the correct sign, and set global	}
 *		{ variable "aritherror" to 1.  Note that -2^32 is 	}
 *		{ considered to be an illegal product for this type of	}
 *		{ arithmetic!						}
 *
 *	function takefraction(f: fraction; q: integer): integer;
 *		{ Calculate the function floor( (p * q) / 2^28 + 0.5 )	}
 *		{ takefraction() rounds in a similar manner as		}
 *		{   makefraction() above.				}
 *
 */

#include "h00vars.h"

extern	bool	aritherror;		/* to be set on overflow */

#define	EL_GORDO	0x7fffffff	/* 2^31-1		*/
#define	FRACTION_ONE	0x10000000	/* 2^28			*/
#define	FRACTION_HALF	0x08000000	/* 2^27			*/
#define	FRACTION_FOUR	0x40000000	/* 2^30			*/

int makefraction(p, q)
    register	int p, q;
{
    int		negative;
    register	int be_careful;
    register	int f;
    int		n;

    if (p < 0) {
	negative = 1;
	p = -p;
    } else negative = 0;

    if (q < 0) {
	negative = !negative;
	q = -q;
    }

    n = p / q;
    p = p % q;

    if (n >= 8) {
	aritherror = TRUE;
	return (negative? -EL_GORDO : EL_GORDO);
    }

    n = (n-1)*FRACTION_ONE;
    f = 1;
    do {
	be_careful = p - q;
	p = be_careful + p;
	if (p >= 0) {
	    f = f + f + 1;
	} else {
	    f <<= 1;
	    p += q;
	}
    } while (f < FRACTION_ONE);

    be_careful = p - q;
    if ((be_careful + p) >= 0)
	f += 1;
    return (negative? -(f+n) : (f+n));

}

int takefraction(q, f)
    register	int q;
    register	int f;
{
    int		n, negative;
    register	int p, be_careful;

    if (f < 0) {
	negative = 1;
	f = -f;
    } else negative = 0;
    if (q < 0) {
	negative = !negative;
	q = -q;
    }
    if (f < FRACTION_ONE)
	n = 0;
    else {
	n = f / FRACTION_ONE;
	f = f % FRACTION_ONE;
    	if (q < (EL_GORDO /  n))
	    n = n * q;
	else {
	    aritherror = TRUE;
	    n = EL_GORDO;
	}
    }

    f += FRACTION_ONE;
    p = FRACTION_HALF;
    if (q < FRACTION_FOUR) 
	do {
	    if (f & 0x1)
		p = (p+q) >> 1;
	    else
		p >>= 1;
	    f >>= 1;
	} while (f > 1);
    else
	do {
	    if (f & 0x1)
		p = p + ((q-p) >> 1);
	    else
		p >>= 1;
	    f >>= 1;
	} while (f > 1);

    be_careful = n - EL_GORDO;
    if ((be_careful + p) > 0) {
	aritherror = TRUE;
	n = EL_GORDO - p;
    }

    return(negative? -(n+p) : (n+p));
}


