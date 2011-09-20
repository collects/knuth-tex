/*
 * This file defines the default paths that will be used for TeX software.
 * (These paths are used if the user's environment doesn't specify paths
 * in TEXINPUTS, TEXFONTS, TEXBASES, or TEXPOOL.)
 *
 * Paths should be colon-separated and no longer than MAXINPATHCHARS-1
 * (for defaultinputpath) or MAXOTHPATHCHARS (for other default paths).
 */

#define MAXINPATHCHARS  700	/* maximum number of chars in an input path */

#define defaultinputpath  ".:..:/home/tex/local/lib:/home/tex/dist/lib"
    /* this should always start with "." */

#define MAXOTHPATHCHARS 200     /* other paths should be much shorter */

#define defaultfontpath   "/home/fonts"
    /* it is probably best not to include "." here to prevent confusion
       by spooled device drivers that think they know where the fonts
       really are */

#define defaultformatpath ".:/home/tex/local/tex"

#define defaultpoolpath   ".:/home/tex/local/tex"


