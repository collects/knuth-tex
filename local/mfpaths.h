/*
 * This file defines the default paths that will be used for MF software.
 * (These paths are used if the user's environment doesn't specify paths
 * in MFINPUTS, MFBASES, or MFPOOL.)
 *
 * Paths should be colon-separated and no longer than MAXINPATHCHARS-1
 * (for defaultinputpath) or MAXOTHPATHCHARS (for other default paths).
 */

#define MAXINPATHCHARS  700	/* maximum number of chars in an input path */

#define defaultinputpath  ".:/home/tex/local/lib:/home/tex/dist/cm:/home/tex/dist/lib:/home/tex/local/cm:/home/src/ams:/home/src/mf"
    /* this should always start with "." */

#define MAXOTHPATHCHARS 100     /* other paths should be much shorter */

#define defaultbasepath ".:/home/tex/local/mf"

#define defaultpoolpath   ".:/home/tex/local/mf"


