/* some typedefs to allow C extensions in GPC programs */
#include <stdio.h>

typedef enum {FALSE, TRUE} bool;
typedef struct Fdr* FDR;
typedef int (*t_InFunc) (void *,       char *, int, int *);
typedef int (*t_OutFunc)(void *, const char *, int, int *);
typedef enum { foReset, foRewrite, foAppend, foSeekRead, foSeekWrite, foSeekUpdate } TOpenMode;
typedef void      (*TOpenProc)  (void *, TOpenMode);
typedef size_t    (*TReadFunc)  (void *, char *, size_t);
typedef size_t    (*TWriteFunc) (void *, const char *, size_t);
typedef void      (*TFlushProc)  (void *);
typedef void      (*TCloseProc)  (void *);
typedef void      (*TDoneProc)   (void *);

typedef long long int UnixTimeType; /* This is hard-coded in the compiler. Do not change here. */
#define FILE_BUFSIZE 1024

typedef struct {
  int  Capacity;
  int  length;
  char string [256];  /* the length is actually variable */
} STRING;

typedef struct
{
  char Bound;
  char Force;
  char Extensions_valid;
  char Readable;
  char Writable;
  char Executable;
  char Existing;
  char Directory;
  long long int Size;
  UnixTimeType AccessTime;
  UnixTimeType ModificationTime;
  UnixTimeType ChangeTime;
  int  Error;
  FILE *CFile;
  STRING Name;
} GPC_BINDING;

struct Fdr {
  unsigned char *FilBuf; /* address of the file buffer in heap         */
  int   FilSta;          /* status bits; see below                     */
  int   FilSiz;          /* buffer size: if packed then in bits else bytes */
                         /* THE ABOVE FIELDS ACCESSED BY COMPILER      */
                         /* The fields below are used only by RTS      */
  /* Internal buffering and used for ReadStr/WriteStr */
  unsigned char *BufPtr; /* NOT the Standard Pascal file buffer, that is (*FilBuf) */
  int   BufSize;
  int   BufPos;
  int   Flags;
  char *FilNam;          /* Internal name of the file                  */
  char *ExtNam;          /* External name of the file                  */
  FILE *FilJfn;          /* FILE pointer                               */
  int   RtsSta;          /* run time system status bits                */
  FDR   NxtFdr;          /* FDR chain pointer                          */
  GPC_BINDING *Binding;  /* Binding of the file                        */
  char *BoundName;       /* Name the binding refers to as a CString    */
  int   BindingChanged;
  t_InFunc   hack_InFunc;
  t_OutFunc  hack_OutFunc;
  void      *PrivateData;
  TOpenProc  OpenProc;
  TReadFunc  ReadFunc;
  TWriteFunc WriteFunc;
  TFlushProc FlushProc;
  TCloseProc CloseProc;
  TDoneProc  DoneProc;
  unsigned char InternalBuffer [FILE_BUFSIZE]; /* NOT the Standard Pascal file buffer, that is (*FilBuf) */
};

/* FilSta bit definitions */

#define FiUnd      (1 << 0)  /* File buffer is totally undefined */
#define FiEof      (1 << 2)  /* End of file is true */
#define FiEln      (1 << 3)  /* End of line is true. Textfiles only */
#define FiTxt      (1 << 4)  /* It's a TEXT file */
#define FiExt      (1 << 5)  /* External file */
#define FiExtB     (1 << 6)  /* External or bound file */
#define FiPck      (1 << 7)  /* Packed file */
#define FiClr      (1 << 8)  /* Empty file */
#define FiLzy      (1 << 9)  /* This file is lazy */
#define FiEofOK    (1 << 10) /* Internal flag if FiUnd is set: Accept EOF without EOLN */
#define FiDacc     (1 << 11) /* This is a direct access file */
#define FiLget     (1 << 12) /* Must do a get before buffer reference (Lazy I/O) */
#define FiByte     (1 << 13) /* File buffer is actually one byte size */
#define FiBindable (1 << 15) /* File is bindable */

/* RtsSta bit definitions */

#define FiNOP    0 /* File has not been opened */
#define FiRONLY  (1 << 0) /* File opened but is read only */
#define FiORE    (1 << 1) /* File open for reading */
#define FiWRI    (1 << 2) /* File open for writing */
#define FiRND    (1 << 3) /* File open for random access */
#define FiWONLY  (1 << 4) /* File opened but is write only */
/* RtsSta: Device specific bits */
#define FiTTY    (1 << 10) /* TTY: flush output before GET */
#define FiSEEK   (1 << 12) /* File is seekable */
#define FiSIZEK  (1 << 13) /* Size of file is known */
#define FiFLUSH  (1 << 14) /* flush after write */

extern int _p_argc; /* argument count on command line */
extern char **_p_argv; /* argument vector on command line */
extern char **_p_envp; /* environment vector */
