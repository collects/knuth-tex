/* external procedures called by TeX */
#include <sys/signal.h>
#include <sys/time.h>
#include "texpaths.h" /* defines MAXINPATHCHARS, defaultinputpath, etc. */
#include "GPCtypes.h"
#include <string.h>

#define max_file_name_length 1024

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

/* The following are for closing files */

extern _p_close(FDR f); /* in GPC rts/file.c */

Closea(FDR f)
{
	_p_close(f);
}

Closeb(FDR f)
{
	_p_close(f);
}

Closew(FDR f)
{
	_p_close(f);
}

/*
**      dateandtime(time, day, month, year)
**
**  Stores minutes since midnight, current day, month and year into
**  *time, *day, *month and *year, respectively.
**
**
*/

Dateandtime(minutes, day, month, year)
int     *minutes, *day, *month, *year;
{
        long        clock;
	struct tm   *tmptr, *localtime();
	
	clock = time(0);
	tmptr = localtime(&clock);
	
	*minutes = tmptr->tm_hour * 60 + tmptr->tm_min;
	*day = tmptr->tm_mday;
	*month = tmptr->tm_mon + 1;
	*year = tmptr->tm_year + 1900;
}


/* fixed arrays are used to hold the paths, to avoid any possible problems
   involving interaction of malloc and undump		*/

char inputpath[MAXINPATHCHARS] = defaultinputpath;
char fontpath[MAXOTHPATHCHARS] = defaultfontpath;
char formatpath[MAXOTHPATHCHARS] = defaultformatpath;
char poolpath[MAXOTHPATHCHARS] = defaultpoolpath;

extern char *getenv();

/*
 * setpaths is called to set up the arrays inputpath, fontpath, formatpath
 * and poolpath as follows:  if the user's environment has a value for the
 * appropriate value, then use it;  otherwise, leave the current value of
 * the array (which may be the default path, or it may be the result of
 * a call to setpaths on a previous run that was made the subject of
 * an undump: this will give the maker of a preloaded TeX the option of
 * providing a new set of "default" paths.
 *
 * Note that we have to copy the string from the environment area, since
 * that will change on the next run (which matters if this is for a
 * preloaded TeX).
 */
Setpaths()
{
	register char *envpath;
	
	if ((envpath = getenv("TEXINPUTS")) != NULL)
	    copypath(inputpath,envpath,MAXINPATHCHARS);
	if ((envpath = getenv("TEXFONTS")) != NULL)
	    copypath(fontpath,envpath,MAXOTHPATHCHARS);
	if ((envpath = getenv("TEXFORMATS")) != NULL)
	    copypath(formatpath,envpath,MAXOTHPATHCHARS);
	if ((envpath = getenv("TEXPOOL")) != NULL)
	    copypath(poolpath,envpath,MAXOTHPATHCHARS);
}

/*
 * copypath(s1,s2,n) copies at most n characters (including the null)
 * from string s2 to string s1, giving an error message for paths
 * that are too long.
 */
copypath(s1,s2,n)
    register char *s1,*s2;
    register int n;
{
	while ((*s1++ = *s2++) != '\0')
	    if (--n == 0) {
		fprintf(stderr, "! Environment search path is too big\n");
		*--s1 = '\0';
		return; /* let user continue with truncated path */
		}
}

#define filenamesize 1024   /* should agree with initex.ch */
#define nameoffile Nameoffile
#define realnameoffile Realnameoffile
char nameoffile[filenamesize],realnameoffile[filenamesize];

/*
 *	testaccess(amode,filepath)
 *
 *  Test whether or not the file whose name is in the global nameoffile
 *  can be opened for reading (if mode=READACCESS)
 *  or writing (if mode=WRITEACCESS).
 *
 *  The filepath argument is one of the ...FILEPATH constants defined below.
 *  If the filename given in nameoffile does not begin with '/', we try 
 *  prepending all the ':'-separated areanames in the appropriate path to the
 *  filename until access can be made, if it ever can.
 *
 *  The realnameoffile global array will contain the name that yielded an
 *  access success.
 */

#define READACCESS 4
#define WRITEACCESS 2

#define NOFILEPATH 0
#define INPUTFILEPATH 1
#define READFILEPATH 2
#define FONTFILEPATH 3
#define FORMATFILEPATH 4
#define POOLFILEPATH 5

bool
Testaccess(amode,filepath)
    int amode,filepath;
{
    register bool ok;
    register char *p;
    char *curpathplace;
    int f;
    
    switch(filepath) {
	case NOFILEPATH: curpathplace = NULL; break;
	case INPUTFILEPATH: case READFILEPATH:
			curpathplace = inputpath; break;
	case FONTFILEPATH: curpathplace = fontpath; break;
	case FORMATFILEPATH: curpathplace = formatpath; break;
	case POOLFILEPATH: curpathplace = poolpath; break;
	}
    if (nameoffile[0]=='/')	/* file name has absolute path */
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
    return (ok);
}

/*
 * packrealnameoffile(cpp) makes realnameoffile contain the directory at *cpp,
 * followed by '/', followed by the characters in nameoffile up until the
 * first blank there, and finally a '\0'.  The cpp pointer is left pointing
 * at the next directory in the path.
 * But: if *cpp == NULL, then we are supposed to use nameoffile as is.
 */
packrealnameoffile(cpp)
    char **cpp;
{
    register char *p,*realname;
    
    realname = realnameoffile;
    if ((p = *cpp)!=NULL) {
	while ((*p != ':') && (*p != '\0')) {
	    *realname++ = *p++;
	    if (realname == &(realnameoffile[filenamesize-1]))
		break;
	    }
	if (*p == '\0') *cpp = NULL; /* at end of path now */
	else *cpp = p+1; /* else get past ':' */
	*realname++ = '/';  /* separate the area from the name to follow */
	}
    /* now append nameoffile to realname... */
    p = nameoffile;
    while (*p) {
	if (realname >= &(realnameoffile[filenamesize-1])) {
	    fprintf(stderr,"! Full file name is too long\n");
	    break;
	    }
	*realname++ = *p++;
	}
    *realname = '\0';
}

