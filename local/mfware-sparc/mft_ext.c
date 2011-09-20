/* External procedures for MFT*/
/* (culled from weavext.c and ext.c for WEAVE and TeX) */
/*   Written by: H. Trickey, 11/17/83   */
/* (modified for 8-bit input by don on 10/16/89) */

/* Note: these procedures aren't necessary; the default input_ln and
 * flush_buffer routines in tangle/weave work fine on UNIX.
 * However a very big time improvement is achieved by using these.
 *
 * These procedures are the same as for tangle, except for a slight offset
 * in which characters are output from outbuf in linewrite.
 */

#define BUF_SIZE 100		/* should agree with mft.web */

#include "mfpaths.h"		/* defines default MFINPUTS path */
#include "h00vars.h"		/* defines Pascal I/O structure */

extern short buffer[];		/* 0..BUF_SIZE.  Input goes here */
extern short outbuf[];		/* 0..OUT_BUF_SIZE. Output from here */
extern short xord[];
extern char xchr[];	/* character translation arrays */
extern char limit;		/* index into buffer.  Note that limit
				   is 0..buf_size (= 0..100) in mft.web; this
				   differs from the definition in weave.web */

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
/* and now, some routines to implement paths for file names.  These routines
   are taken from Howard Trickey's port of dvitype (2/19/84).  Howard
   adapted them from his port of TeX, ext.c */

char *inputpath;

char *getenv();

/*
 * setpaths is called to set up the pointer inputpath
 * as follows:  if the user's environment has a value for TEXINPUTS
 * then use it;  otherwise, use defaultinputpath.
 */
setpaths()
{
	register char *envpath;
	
	if ((envpath = getenv("TEXINPUTS")) != NULL)
	    inputpath = envpath;
	else
	    inputpath = defaultinputpath;
}

#define maxfilenamelength 100   /* should agree with mft.ch */
extern char stylename[],realnameoffile[]; /* these have size namelength */

/*
 *	testaccess(amode,filepath)
 *
 *  Test whether or not the file whose name is in the global curname
 *  can be opened for reading (if mode=READACCESS)
 *  or writing (if mode=WRITEACCESS).
* [the code here isn't as general as it should be ... it assumes that stylefile
*  is the only file name of interest! Maybe I'll fix this some day -- don]
 *
 *  The filepath argument is one of the ...FILEPATH constants defined below.
 *  If the filename given in curname does not begin with '/', we try 
 *  prepending all the ':'-separated areanames in the appropriate path to the
 *  filename until access can be made, if it ever can.
 *
 *  The realnameoffile global array will contain the name that yielded an
 *  access success.
 */

/* note that corresponding constants are defined in mft.ch */

#define READACCESS 4
#define WRITEACCESS 2

#define NOFILEPATH 0
#define GOODFILEPATH 3

bool
testaccess(amode,filepath)
    int amode,filepath;
{
    register bool ok;
    register char *p;
    char *curpathplace;
    int f;
    
    switch(filepath) {
	case NOFILEPATH: curpathplace = NULL; break;
	case GOODFILEPATH: curpathplace = inputpath; break;
	}
    if (stylename[0]=='/')	/* file name has absolute path */
	curpathplace = NULL;
    do {
	packrealnameoffile(&curpathplace);
	if (amode==READACCESS)
	    /* use system call "access" to see if we could read it */
	    if (access(realnameoffile,READACCESS)==0) ok = TRUE;
	    else ok = FALSE;
	else {
	    /* WRITEACCESS: use creat to see if we could create it, but close
	    the file again if we're OK, to let pc open it for real */
	    f = creat(realnameoffile,0666);
	    if (f>=0) ok = TRUE;
	    else ok = FALSE;
	    if (ok)
		close(f);
	    }
    } while (!ok && curpathplace != NULL);
    if (ok) {  /* pad realnameoffile with blanks, as Pascal wants */
	for (p = realnameoffile; *p != '\0'; p++)
	    /* nothing: find end of string */ ;
	while (p < &(realnameoffile[maxfilenamelength]))
	    *p++ = ' ';
	}
    return (ok);
}

/*
 * packrealnameoffile(cpp) makes realnameoffile contain the directory at *cpp,
 * followed by '/', followed by the characters in stylename up until the
 * first blank there, and finally a '\0'.  The cpp pointer is left pointing
 * at the next directory in the path.
 * But: if *cpp == NULL, then we are supposed to use stylename as is.
 */
packrealnameoffile(cpp)
    char **cpp;
{
    register char *p,*realname;
    
    realname = realnameoffile;
    if ((p = *cpp)!=NULL) {
	while ((*p != ':') && (*p != '\0')) {
	    *realname++ = *p++;
	    if (realname == &(realnameoffile[maxfilenamelength-1]))
		break;
	    }
	if (*p == '\0') *cpp = NULL; /* at end of path now */
	else *cpp = p+1; /* else get past ':' */
	*realname++ = '/';  /* separate the area from the name to follow */
	}
    /* now append stylename to realname... */
    p = stylename;
    while (*p != ' ') {
	if (realname >= &(realnameoffile[maxfilenamelength-1])) {
	    fprintf(stderr,"! Full file name is too long\n");
	    break;
	    }
	*realname++ = *p++;
	}
    *realname = '\0';
}

bool testreadaccess(fn)
	char  *fn;
{
	register char *p;

	fn[maxfilenamelength-1] = ' ';
	p = fn;
	while (*p++ != ' ');
	p--;
	*p = '\0';
	if (access(fn,4)==0) {
	  *p = ' '; return(TRUE);}
	else {*p = ' '; return(FALSE);}
}
