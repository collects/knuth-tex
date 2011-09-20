/* External procedures for tangle/weave */
/* Written by Don Knuth, 29 April 2000, based on Howard Trickey's code of 83 */

/* Note: The input files are read directly with C routines, instead
  of using the Pascal runtime system. So we do our own EOF testing.
  The GNU Pascal routines are used only to open ("reset") the files. */

#define BUF_SIZE 500 /* should agree with long_buf_size in weave.web */
#define max_file_name_length 60 /* should agree with tangle.ch */

#include "GPCtypes.h" /* defines GNU Pascal I/O structure */
#include <string.h>

void Argv(int n, char* str)
{
  register char *s,*t;
  if (n<0 || n>=_p_argc) return;
  s=_p_argv[n];
  if (strlen(s) >= max_file_name_length-5) {
    str[0]='\0'; return; /* TANGLE doesn't want it too long */
  }
  for (t=str; *s; s++,t++) *t=*s;
  *t='\0';
}

void Flushstdout()
{
  fflush(stdout);
}

#define buffer Buffer /* GNU Pascal likes to capitalize */
#define xord Xord
#define xchr Xchr
#define limit Limit

unsigned char buffer[BUF_SIZE+1];  /* 0..BUF_SIZE.  Input goes here */
unsigned char xord[256];
unsigned char xchr[256];	/* character translation arrays */
int limit;	/* index into buffer */

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
 * If end-of-file is encountered, the FilSta field of *filep is set
 * appropriately.
 */
void Lineread(FDR filep)
{
	register int	c;
	register unsigned char	*cs;	/* points to where next char goes */
	register unsigned char	*cnb;	/* last non-blank character input */
	register FILE *iop;	/* stdio-style FILE pointer */
	register int	l;	/* how many chars before buffer overflow */

	iop = filep->FilJfn;
	cnb = cs = &buffer[0];
	l = BUF_SIZE;

	/* overflow when next char would go into buffer[BUF_SIZE] */
	while ((--l >= 0) && ((c = getc(iop)) != EOF) && (c != '\n')) {
		if ((*cs++ = xord[c]) != ' ')
			cnb = cs;
	}

	if (c == EOF)
		filep->FilSta |= FiEof;	/* we hit end-of-file */
        /* actually that wasn't necessary, since testeof uses feof */

	limit = (cnb - &buffer[0]);
}

/*
 *	testeof(filep)
 *
 *  Test whether or not the Pascal text file with iorec pointer filep
 *  has reached end-of-file (when the only I/O on it is done with
 *  lineread, above).
 *  We may have to read the next character and unget it to see if perhaps
 *  the end-of-file is next.
 */
bool Testeof(FDR filep)
{
  register int c;
  register FILE *iop; /* stdio-style FILE pointer */

  iop = filep->FilJfn;
  if (feof(iop)) return TRUE;
  c = getc(iop);
  if (c == EOF) return TRUE;
  else {
    ungetc(c,iop);
    return FALSE;
  }
}

void Exit(int c)
{
  exit(c);
}
