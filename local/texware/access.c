#define namelength 100          /* must agree with tftopl.ch and pltotf.ch */

bool testreadaccess(fn)
	char  *fn;
{
	register char *p;

	fn[namelength-1] = ' ';
	p = fn;
	while (*p++ != ' ');
	p--;
	*p = '\0';
	if (access(fn,4)==0) {
	  *p = ' '; return(TRUE);}
	else {*p = ' '; return(FALSE);}
}

