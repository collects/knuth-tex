/* External procedures for dvitype				*/
/*   Written by: H. Trickey, 2/19/83 (adapted from TeX's ext.c) */

#include "texpaths.h"		/* defines default TEXFONTS path */
#include "h00vars.h"		/* defines Pascal I/O structure */

char *fontpath;

char *getenv();

/*
 * setpaths is called to set up the pointer fontpath
 * as follows:  if the user's environment has a value for TEXFONTS
 * then use it;  otherwise, use defaultfontpath.
 */
setpaths()
{
	register char *envpath;
	
	if ((envpath = getenv("TEXFONTS")) != NULL)
	    fontpath = envpath;
	else
	    fontpath = defaultfontpath;
}

#define namelength 100   /* should agree with dvitype.ch */
extern char curname[],realnameoffile[]; /* these have size namelength */

/*
 *	testaccess(amode,filepath)
 *
 *  Test whether or not the file whose name is in the global curname
 *  can be opened for reading (if mode=READACCESS)
 *  or writing (if mode=WRITEACCESS).
 *
 *  The filepath argument is one of the ...FILEPATH constants defined below.
 *  If the filename given in curname does not begin with '/', we try 
 *  prepending all the ':'-separated areanames in the appropriate path to the
 *  filename until access can be made, if it ever can.
 *
 *  The realnameoffile global array will contain the name that yielded an
 *  access success.
 */

#define READACCESS 4
#define WRITEACCESS 2

#define NOFILEPATH 0
#define FONTFILEPATH 3

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
	case FONTFILEPATH: curpathplace = fontpath; break;
	}
    if (curname[0]=='/')	/* file name has absolute path */
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
	while (p < &(realnameoffile[namelength]))
	    *p++ = ' ';
	}
    return (ok);
}

/*
 * packrealnameoffile(cpp) makes realnameoffile contain the directory at *cpp,
 * followed by '/', followed by the characters in curname up until the
 * first blank there, and finally a '\0'.  The cpp pointer is left pointing
 * at the next directory in the path.
 * But: if *cpp == NULL, then we are supposed to use curname as is.
 */
packrealnameoffile(cpp)
    char **cpp;
{
    register char *p,*realname;
    
    realname = realnameoffile;
    if ((p = *cpp)!=NULL) {
	while ((*p != ':') && (*p != '\0')) {
	    *realname++ = *p++;
	    if (realname == &(realnameoffile[namelength-1]))
		break;
	    }
	if (*p == '\0') *cpp = NULL; /* at end of path now */
	else *cpp = p+1; /* else get past ':' */
	*realname++ = '/';  /* separate the area from the name to follow */
	}
    /* now append curname to realname... */
    p = curname;
    while (*p != ' ') {
	if (realname >= &(realnameoffile[namelength-1])) {
	    fprintf(stderr,"! Full file name is too long\n");
	    break;
	    }
	*realname++ = *p++;
	}
    *realname = '\0';
}

int flength(filep)
	register struct iorec	*filep;
{
	register FILE	*iop;	/* stdio-style FILE pointer */
	register long	pos;    /* current file position */
	register int	len;	/* the file length */

	iop = filep->fbuf;
	pos = ftell(iop);
	fseek(iop,0L,2);
	len = ftell(iop);
	fseek(iop,pos,0);
	return(len);
}

bseek(filep,cnt)
	register struct iorec	*filep;
	int      	cnt;
{
	register FILE	*iop;	/* stdio-style FILE pointer */

	iop = filep->fbuf;
	fseek(iop,(long)cnt,0);
}

