/* external procedures called by MF */
#include <sys/signal.h>
#include <sys/time.h>
#include "mfpaths.h" /* defines MAXINPATHCHARS, defaultinputpath, etc. */
#include "h00vars.h"

/* The following are for closing files */

closea(f)
	int *f; /* actually, file pointer, but it doesn't matter */
{
	close1(f);
}

closeb(f)
	int *f; /* actually, file pointer, but it doesn't matter */
{
	close1(f);
}

closew(f)
	int *f; /* actually, file pointer, but it doesn't matter */
{
	close1(f);
}

extern int interrupt;	/* To be made nonzero to tell MF about interrupts */

/*
**	catchint()
**
**  Gets called when the user hits his interrupt key.  Sets the global
**  "interrupt" nonzero, then sets it up so that the next interrupt will
**  also be caught here.
**
*/

catchint()
{
	interrupt = 1;
	signal(SIGINT,catchint);
}

/*
**      dateandtime(time, day, month, year)
**
**  Stores minutes since midnight, current day, month and year into
**  *time, *day, *month and *year, respectively.
**
**  Also, set things up so that catchint() will get control on interrupts.
**
*/

dateandtime(minutes, day, month, year)
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
	signal(SIGINT,catchint);
}


/* fixed arrays are used to hold the paths, to avoid any possible problems
   involving interaction of malloc and undump		*/

char inputpath[MAXINPATHCHARS] = defaultinputpath;
char basepath[MAXOTHPATHCHARS] = defaultbasepath;
char poolpath[MAXOTHPATHCHARS] = defaultpoolpath;

char *getenv();

/*
 * setpaths is called to set up the arrays inputpath, basepath, and
 * poolpath as follows:  if the user's environment has a value for the
 * appropriate value, then use it;  otherwise, leave the current value of
 * the array (which may be the default path, or it may be the result of
 * a call to setpaths on a previous run that was made the subject of
 * an undump: this will give the maker of a preloaded MF the option of
 * providing a new set of "default" paths.
 *
 * Note that we have to copy the string from the environment area, since
 * that will change on the next run (which matters if this is for a
 * preloaded MF).
 */
setpaths()
{
	register char *envpath;
	
	if ((envpath = getenv("MFINPUTS")) != NULL)
	    excopypath(inputpath,envpath,MAXINPATHCHARS);
	if ((envpath = getenv("MFBASES")) != NULL)
	    excopypath(basepath,envpath,MAXOTHPATHCHARS);
	if ((envpath = getenv("MFPOOL")) != NULL)
	    excopypath(poolpath,envpath,MAXOTHPATHCHARS);
}

/*
 * excopypath(s1,s2,n) copies at most n characters (including the null)
 * from string s2 to string s1, giving an error message for paths
 * that are too long.
 */
excopypath(s1,s2,n)
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

extern short buffer[],xord[]; 
extern short last,first; /* pointers into buffer */

/*
 * lineread reads from the Pascal text file with iorec pointer filep
 * into buffer[first], buffer[first+1],..., buffer[last-1] (and
 * setting "last").
 * Characters are read until a newline is found (which isn't put in the
 * buffer) or until the next character would go into buffer[lastlim].
 * The characters need to be translated, so really xord[c] is put into
 * the buffer when c is read.
 * If end-of-file is encountered, the funit field of *filep is set
 * appropriately.
 */
lineread(filep, lastlim)
struct iorec *filep;
int lastlim;
{
	register c;
	register short *cs; /* pointer into buffer where next char goes */
	register FILE *iop; /* stdio-style FILE pointer */
	int l; /* how many more chars are allowed before buffer overflow */
	short *bf; /* hold address of buffer[first] */
	
	iop = filep->fbuf;
	bf = cs = &(buffer[first]);
	l = lastlim-first;
	  /* overflow when next char would go into buffer[lastlim] */
	while (--l>=0 && (c = getc(iop)) != EOF && c!='\n')
	    *cs++ = xord[c];
	if (c == EOF)
	    filep->funit |= EOFF; /* we hit end-of-file */
	last = first+cs-bf;
}

#define filenamesize 1024   /* should agree with inimf.ch */
extern char nameoffile[],realnameoffile[]; /* these have size filenamesize */

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
#define BASEFILEPATH 4
#define POOLFILEPATH 5

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
	case INPUTFILEPATH: case READFILEPATH:
			curpathplace = inputpath; break;
	case BASEFILEPATH: curpathplace = basepath; break;
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
    if (ok) {  /* pad realnameoffile with blanks, as Pascal wants */
	for (p = realnameoffile; *p != '\0'; p++)
	    /* nothing: find end of string */ ;
	while (p < &(realnameoffile[filenamesize]))
	    *p++ = ' ';
	}
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
    while (*p != ' ') {
	if (realname >= &(realnameoffile[filenamesize-1])) {
	    fprintf(stderr,"! Full file name is too long\n");
	    break;
	    }
	*realname++ = *p++;
	}
    *realname = '\0';
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


/*
**	writegf(a,b)
**
**  writegf is called to write gfbuf[a..b] to gffile
**  Unfortunately, gfbuf is declared as eight_bits, which in our
**  implementation means that two bytes are taken by each entry.
**  We only want to output the low order (first) byte of each pair.
*/
extern struct iorec gffile;
extern short gfbuf[];
writegf (a,b)
	int a,b;
{
	register short *ptr,*final;
	register FILE *iop;
	
	iop=gffile.fbuf;
	ptr= &(gfbuf[a]);
	final= &(gfbuf[b]);
	while (ptr<=final) {
		putc((char) (*ptr & 0377), iop);
		ptr += 1;
		}
	/* Note: The above code used to be machine dependent. By changing
	 *  the declarations from "char *" to "short *" we get the machine
	 *  to do its own byte ordering of the de-reference of "ptr" above.
	 *  Then we AND off the low bits (now that it's been pulled from
	 *  memory correctly) and cast it into a "char" for putc().
	 *	--Peter Kessler's idea; explanation, AND, cast a la clp.
	 */
}


/*
**	close1(filep)
**  close1 does the proper things to pc's runtime system file data structure
**  to close a file
*/
close1(filep)

	register struct iorec		*filep;
{
        register struct iorec           *next;
        
	if (filep->fbuf != 0) {
		if ((filep->funit & FDEF) == 0) {
                        next = (struct iorec *) &_fchain;
                        while (next->fchain != FILNIL
                                                  &&  next->fchain != filep)
                                next = next->fchain;
                        if (next->fchain != FILNIL)
                                next->fchain = next->fchain->fchain;
        
			if (filep->fblk > PREDEF) {
				fflush(filep->fbuf);
				setbuf(filep->fbuf, NULL);
			}
			fclose(filep->fbuf);
			if (ferror(filep->fbuf)) {
/*				ERROR("%s: Close failed\n",
					filep->pfname); */
				return;
			}
			filep->fbuf=0;
		}
		if ((filep->funit & TEMP) != 0 &&
		    unlink(filep->pfname)) {
/*			PERROR("Could not remove ", filep->pfname); */
			return;
		}
	}
}
   
/*
**  The following procedure is due to sjc@s1-c.
**
**	calledit(filename, fnlength, linenumber)
**
**  MF84 can call this to implement the 'e' feature in error-recovery
**  mode, invoking a text editor on the erroneous source file.
**  
**  You should pass to "filename" the first character of the packed array
**  containing the filename, and to "fnlength" the size of the filename.
**  
**  Ordinarily, this invokes emacs. If you want a different
**  editor, create a shell environment variable MFEDIT containing
**  the string that invokes that editor, with "%s" indicating where
**  the filename goes and "%d" indicating where the decimal
**  linenumber (if any) goes. For example, a MFEDIT string for "vi" might be:
**  
**	setenv MFEDIT "/usr/bin/vi +%d %s"
**  
*/

   char dvalue[] = "emacs +%d %s";
   char *mfeditvalue = &dvalue[0];

   calledit(filename, fnlength, linenumber)
      char *filename;
      int fnlength, linenumber;
   {
      char *temp, *command, c;
      int sdone, ddone, i;

      sdone = ddone = 0;

      /* Replace default with environment variable if possible. */
      if (NULL != (temp = (char *) getenv("MFEDIT")))
	 mfeditvalue = temp;

      /* Make command string containing envvalue, filename, and linenumber */
      if (NULL ==
	 (command = (char *) malloc(strlen(mfeditvalue) + fnlength + 25))) {
	 fprintf(stderr, "! Not enough memory to issue editor command\n");
	 exit(1);
	 }
      temp = command;
      while ((c = *mfeditvalue++) != '\0') {
	 if (c == '%') {
	    switch (c = *mfeditvalue++) {
	       case 'd': 
		  if (ddone) {
		     fprintf(stderr,
		     "! Line number cannot appear twice in editor command\n");
		     exit(1);
		     }
		  sprintf(temp, "%d", linenumber);
		  while (*temp != '\0')
		     temp++;
		  ddone = 1;
		  break;
	       case 's':
		  if (sdone) {
		     fprintf(stderr,
			"! Filename cannot appear twice in editor command\n");
		     exit(1);
		     }
		  i = 0;
		  while (i < fnlength)
		     *temp++ = filename[i++] ^ 0x80; /* changed for 8-bit MF */
		  sdone = 1;
		  break;
	       case '\0':
		  *temp++ = '%';
		  mfeditvalue--; /* Back up to \0 to force termination. */
		  break;
	       default:
		  *temp++ = '%';
		  *temp++ = c;
		  break;
	       }
	    }
	 else
	    *temp++ = c;
	 }
      *temp = '\0';

      /* Execute command. */
      if (0 != system(command))
	 fprintf(stderr, "! Trouble executing command %s\n", command);

      /* Quit, indicating MF had found an error before you typed "e". */
      exit(1);
      }
