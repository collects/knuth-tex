/* External procedures for the binary demo program using GPC */

#include "GPCtypes.h" /* defines GNU Pascal I/O structure */
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

#define namelength 100          /* should agree with binarydemo.p */

bool Argv(int n, char* str)
{
  register char *s,*t;
  if (n<0 || n>=_p_argc) return FALSE;
  s=_p_argv[n];
  if (strlen(s) >= namelength) return FALSE;
  for (t=str; *s; s++,t++) *t=*s;
  *t='\0';
  return TRUE;
}

void Bread(FDR filep, char *x)
{ 
  /* reads a character WITHOUT using the Pascal runtime buffers etc */
  register char c;
  c=getc(filep->FilJfn);
  *x=c;
}

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

bool Testreadaccess(char *fn)
{
  return access(fn,R_OK)? FALSE: TRUE;
}

bool Testwriteaccess(fn)
  char  *fn;
{
  int f;
  f = creat(fn,0666);   /* we try to create a new file, because
		simply testing write access with access(fn,W_OK)
		will fail when the file doesn't exist */
  if (f >= 0) {
    close(f); return TRUE;
    } else return FALSE;
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

void Movetobyte(FDR filep,int cnt)
{
  register FILE *iop; /* stdio-style FILE pointer */

  iop = filep->FilJfn;
  fseek(iop,(long)cnt,SEEK_SET);
}
