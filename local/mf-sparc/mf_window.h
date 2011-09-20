{ $Header: mf_window.h,v 0.999999 86/01/13 00:43:56 richards Released $ }

{ External procedures for UNIX MetaFont VIRMF for display graphics }

function initscreen: boolean;
    external;

procedure updatescreen;
    external;

procedure blankrectangle(leftcol, rightcol: screencol; toprow, botrow: screenrow);
    external;

procedure paintrow(r: screenrow; b: pixelcolor; var a: transspec; n: screencol);
    external;
