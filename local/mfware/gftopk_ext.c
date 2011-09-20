#include "h00vars.h"		/* defines Pascal I/O structure */

#define namelength 100          /* should agree with gftopk.ch and gftype.ch */

bseek(filep,cnt)
	register struct iorec	*filep;
	int      	cnt;
{
	register FILE	*iop;	/* stdio-style FILE pointer */

	iop = filep->fbuf;
	fseek(iop,(long)cnt,0);
}

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
