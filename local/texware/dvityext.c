/* External procedures for texware				*/
/*   Written by Don Knuth, 2000.04.29, based on Trickey's vintage 1983 code */

#include "../texpaths.h"		/* defines default TEXFONTS path */
#include "../GPCtypes.h"		/* defines Pascal I/O structure */
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

#define namelength 100          /* should agree with .ch files */

void Argv(int n, char* str)
{
  register char *s,*t;
  if (n<0 || n>=_p_argc) return;
  s=_p_argv[n];
  if (strlen(s) >= namelength-5) {
    str[0]='\0'; return; /* we don't want it too long */
  }
  for (t=str; *s; s++,t++) *t=*s;
  *t='\0';
}

bool Testreadaccess(char *fn)
{
  return access(fn,R_OK)? FALSE: TRUE;
}

char *fontpath;

char *getenv();

/*
 * setpaths is called to set up the pointer fontpath
 * as follows:  if the user's environment has a value for TEXFONTS
 * then use it;  otherwise, use defaultfontpath.
 */
Setpaths()
{
	register char *envpath;
	
	if ((envpath = getenv("TEXFONTS")) != NULL)
	    fontpath = envpath;
	else
	    fontpath = defaultfontpath;
}

#define namelength 100   /* should agree with dvitype.ch */
char Curname[namelength],Realnameoffile[namelength];
#define curname Curname
#define realnameoffile Realnameoffile

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
Testaccess(int amode,int filepath)
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
	    if (access(realnameoffile,R_OK)==0) ok = TRUE;
	    else ok = FALSE;
	else {
	    /* WRITEACCESS: use creat to see if we could create it, but close
	    the file again if we're OK, to let pc open it for real */
	    f = creat(realnameoffile,0666);
	    if (f>=0) { ok = TRUE; close(f);}
	    else ok = FALSE;
	    }
    } while (!ok && curpathplace != NULL);
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
    while (*p) {
	if (realname >= &(realnameoffile[namelength-1])) {
	    fprintf(stderr,"! Full file name is too long\n");
	    break;
	    }
	*realname++ = *p++;
	}
    *realname = '\0';
}

int Flength(FDR filep)
{
  register FILE	*iop;	/* stdio-style FILE pointer */
  register long	pos;    /* current file position */
  register int	len;	/* the file length */

  iop = filep->FilJfn;
  pos = ftell(iop);
  fseek(iop,0L,SEEK_END);
  len = ftell(iop);
  fseek(iop,pos,0);
  return len;
}

void Bseek(FDR filep,int cnt)
{
  register FILE *iop; /* stdio-style FILE pointer */

  iop = filep->FilJfn;
  fseek(iop,(long)cnt,SEEK_SET);
}

void Flushstdout()
{
  fflush(stdout);
}

void Readbyte(FDR filep, unsigned char *x)
{ 
  /* reads a character WITHOUT using the Pascal runtime buffers etc */
  register int c;
  c=getc(filep->FilJfn);
  if (c==EOF) c=0;
  *x=c;
}

