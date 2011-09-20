%   Change file for the PLtoTF processor, for use on Berkeley UNIX systems.
%   This file was created by Pavel Curtis, Pavel@Cornell.

% History:
%   4/4/83 (PC) Original version, made to work with version 1.2 of PLtoTF.
%   4/16   (PC) Brought up to version 1.3 of PLtoTF.
%   6/30  (HWT) Revised changefile format for version 1.7 Tangle
%   7/28  (HWT) Brought up to version 2
%  11/21  (HWT) Brought up to version 2.1
%  9/3/85 (RKF) Brought up to version 2.3
%  8/7/89 (don) Cosmetic change for SunOS
%  9/16/89 (don) Cosmetic change for version 3
%  10/16/89 (don) Avoided core dump when PL file can't be opened
%  11/18/89 (don) Brought up to version 3.1
%  9/6/90   (don) Version 3.3
%  3/25/91  (don) Version 3.4
%  3/6/95   (don) Version 3.5

% The section numbers used in this file refer to the current nunmbers,
% and, where different, also to those in the standard TeXware report (CS1097).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{PL\lowercase{to}TF changes for SunOS}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is PLtoTF, Version 3.5' {printed when the program starts}
@y
@d banner=='This is PLtoTF, Version 3.5 for SunOS'
                                         {printed when the program starts}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Fix filenames in program statement; add `final_end' label; add access
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p program PLtoTF(@!pl_file,@!tfm_file,@!output);
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@y
@d final_end==9999

@p program PLtoTF(@!output);
label final_end;
const @<Constants in the outer block@>@/
type UNIX_file_name=packed array[1..100] of char;
 @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
function testreadaccess(var fn:UNIX_file_name):boolean; external;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [6] Open PL file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
reset(pl_file);
@y
if argc < 3 then begin
    print_ln('Usage: pltotf <pl-file> <tfm-file>');
    goto final_end;
end;
argv(1, pl_name);
if testreadaccess(pl_name) then reset(pl_file, pl_name)
else begin print_ln('I can''t read the PL file!'); goto final_end;
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [15] Change type of tfm_file and declare extra TFM-file variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!tfm_file:packed file of 0..255;
@y
@!tfm_file            : packed file of -128..127;
@!tmp                 : 0..255;
@!tfm_name, 
@!pl_name             : UNIX_file_name;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [16] Open TFM file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ On some systems you may have to do something special to write a
packed file of bytes. For example, the following code didn't work
when it was first tried at Stanford, because packed files have to be
opened with a special switch setting on the \PASCAL\ that was used.
@^system dependencies@>

@<Set init...@>=
rewrite(tfm_file);
@y
@ On some systems you may have to do something special to write a
packed file of bytes.
@^system dependencies@>

@<Set init...@>=
argv(2, tfm_name);
rewrite(tfm_file, tfm_name);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [127, was 119] Change TFM-byte output to fix ranges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d out(#)==write(tfm_file,#)
@y
@d out(#)==begin
              tmp := #;
              if tmp > 127 then
                 write(tfm_file, tmp - 256)
              else   
                 write(tfm_file, tmp)
           end
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [147, was 135] Define label `final_end'; print newline at end of program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
end.
@y
final_end: print_ln(' '); end.
@z
