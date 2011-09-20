/* External procedures for weave */
/*   Written by: H. Trickey, 11/17/83   */

/* Modified for 8-bit input --- don  8/31/89 */

/* Note: these procedures aren't necessary; the default input_ln and
 * flush_buffer routines in tangle/weave work fine on UNIX.
 * However a very big time improvement is achieved by using these.
 *
 * These procedures are the same as for tangle, except for a slight offset
 * in which characters are output from outbuf in linewrite.
 */

#define BUF_SIZE 100		/* should agree with tangle.web */

#include "h00vars.h"		/* defines Pascal I/O structure */

extern short buffer[];		/* 0..BUF_SIZE.  Input goes here */
extern short outbuf[];		/* 0..OUT_BUF_SIZE. Output from here */
extern short xord[];
extern char xchr[];	/* character translation arrays */
extern short limit;		/* index into buffer.  Note that limit
				   is 0..long_buf_size in weave.web; this
				   differs from the definition in tangle.web */

/*
 * lineread reads from the Pascal text file with iorec pointer filep
 * into buffer[0], buffer[1],..., buffer[limit-1] (and
 * setting "limit").
 * Characters are read until a newline is found (which isn't put in the
 * buffer) or until the next character would go into buffer[BUF_SIZE].
 * And trailing blanks are to be ignored, so limit is really set to
 * one past the last non-blank.
 * The characters need to be translated, so really xord[c] is put into
 * the buffer when c is read.
 * If end-of-file is encountered, the funit field of *filep is set
 * appropriately.
 */
lineread(filep)
struct iorec *filep;
{
	register c;
	register short *cs; /* pointer into buffer where next char goes */
	register short *cnb; /* last non-blank character input */
	register FILE *iop; /* stdio-style FILE pointer */
	register int l; /* how many chars allowed before buffer overflow */
	
	iop = filep->fbuf;
	cnb = cs = &(buffer[0]);
	l = BUF_SIZE;
	  /* overflow when next char would go into buffer[BUF_SIZE] */
	while (--l>=0 && (c = getc(iop)) != EOF && c!='\n')
	    if((*cs++ = xord[c])!=' ') cnb = cs;
	if (c == EOF)
	    filep->funit |= EOFF; /* we hit end-of-file */
	limit = cnb-&(buffer[0]);
}

/*
 * linewrite writes to the Pascal text file with iorec pointer filep
 * from outbuf[1], outbuf[1],..., outbuf[cnt].
 * (Note the offset of indices vis a vis the tangext version of this.)
 * Translation is done, so that xchr[c] is output instead of c.
 */
 linewrite(filep,cnt)
 struct iorec *filep;
 int cnt;
 {
 	register FILE *iop; /* stdio-style FILE pointer */
	register short *cs; /* pointer to next character to output */
	register int l; /* how many characters left to output */
	
	iop = filep->fbuf;
	cs = &(outbuf[1]);
	l = cnt;
	while (--l>=0) putc(xchr[*cs++],iop);
}
	
/*
**	testeof(filep)
**
**  Test whether or not the Pascal text file with iorec pointer filep
**  has reached end-of-file (when the only I/O on it is done with
**  lineread, above).
**  We may have to read the next character and unget it to see if perhaps
**  the end-of-file is next.
*/

bool
testeof(filep)
register struct iorec *filep;
{
	register char c;
	register FILE *iop; /* stdio-style FILE pointer */
	if (filep->funit & EOFF)
		return(TRUE);
	else { /* check to see if next is EOF */
		iop = filep->fbuf;
		c = getc(iop);
		if (c == EOF)
			return(TRUE);
		else {
			ungetc(c,iop);
			return(FALSE);
			}
	}
}
