/*
 * XView interface to MetaFont
 *   (written hastily and without much understanding...)
 */
#define SCREENWIDTH 1024 /* must match the constant in inimf.ch */
#define SCREENDEPTH 800 /* must match the constant in inimf.ch */

#include <stdio.h>
#include <xview/xview.h>
#include <xview/canvas.h>
#include <X11/Xlib.h>

static Frame frame; /* container */
static Canvas canvas; /* the viewing and imaging area */
static Xv_Window canvas_paintwin; /* image component of |canvas| */
static Display *display; /* handle to X server */
static Visual *screen; /* where the X server paints */
static Window xcanvas; /* the X11 ``drawable'' component of our canvas */
static GC gc; /* X graphic context */
static XGCValues GCvalues; /* changes to a graphic context */

/*
 * updatescreen; -- make sure screen display is current
 */

updatescreen()
{
  notify_dispatch();
  XFlush(display);
}

/*
 * init_screen: boolean;  return true if window operations legal
 */

initscreen()
{
  if (xv_init(NULL)==NULL) return 0;
  frame=(Frame)xv_create(NULL,FRAME,XV_WIDTH,700,XV_HEIGHT,600,
                         FRAME_SHOW_HEADER,FALSE,
                         XV_SHOW,TRUE,NULL);
  canvas=(Canvas)xv_create(frame,CANVAS,CANVAS_REPAINT_PROC,updatescreen,
            CANVAS_X_PAINT_WINDOW,TRUE,
            XV_HEIGHT,SCREENDEPTH,XV_WIDTH,SCREENWIDTH,
            CANVAS_AUTO_EXPAND,FALSE,CANVAS_AUTO_SHRINK,FALSE,
            NULL);
  canvas_paintwin=(Xv_window)xv_get(canvas,CANVAS_NTH_PAINT_WINDOW,0);
  xcanvas=(Window)xv_get(canvas_paintwin,XV_XID);
  display=(Display*)xv_get(frame,XV_DISPLAY);
  screen=(Visual*)xv_get(frame,XV_VISUAL);
  gc=XCreateGC(display,DefaultRootWindow(display),0,GCvalues);
  notify_do_dispatch(); /* this should allow terminal input */
  return 1;
}

/*
 * blankrectangle: reset rectangle bounded by ([left,right],[top,bottom])
 *			to background color
 */

blankrectangle(left, right, top, bottom)
	short left, right;
	short top, bottom;
{
  XSetFunction(display,gc,GXclear);
  XFillRectangle(display,xcanvas,gc,left,top,right-left,bottom-top);
}

/*
 * paintrow -- paint row r starting with color b,  up to next
 *		transition specified by vector a, switch colors,
 *		and continue for n transitions.
 */

paintrow(r, b, a, n)
	short r;
	short b;
	short a[];
	short n;
{
  register short *p,*q=&a[n];
  XSetFunction(display,gc,b?GXset:GXclear);
  for (p=a;p<q;p+=2)
    XFillRectangle(display,xcanvas,gc,*p,r,*(p+1)-*p,1);
  XSetFunction(display,gc,b?GXclear:GXset);
  for (p=a+1;p<q;p+=2)
    XFillRectangle(display,xcanvas,gc,*p,r,*(p+1)-*p,1);
  notify_dispatch(); /* without this, the Notifier queue overflows */
}

