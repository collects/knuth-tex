%   Change file for the TFtoPL processor, for use on Berkeley UNIX systems.
%   This file was created by Pavel Curtis, Pavel@Cornell.

% History:
%   4/4/83 (PC) Original version, made to work with version 1.0 of TFtoPL,
%               released with version 0.96 of TeX in February, 1983.
%   4/16   (PC) Brought up to version 1.0 released with version 0.97 of TeX
%               in April, 1983.
%   6/30  (HWT) Revised changefile format, for use with version 1.7 Tangle.
%   7/28  (HWT) Brought up to version 2
%  11/21  (HWT) Brought up to version 2.1
% 3/24/84 (HWT) Brought up to version 2.2
% 7/12/84 (HWT) Brought up to version 2.3
% 9/3/85  (RKF)	Brought up to version 2.4
% 3/1/86  (PAM) Cosmetic upgrade to Version 2.5
% 8/7/89  (don) Cosmetic change for SunOS
% 9/15/89 (don) Cosmetic upgrade to Version 3
% 10/18/89 (don) Avoid core dump when the file isn't present
% 11/18/89 (don) Brought up to version 3.1

% The section numbers used in this file refer to the current numbers,
% and, where different, also to those in the standard TeXware report (CS1097).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{TF\lowercase{to}PL changes for SunOS}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is TFtoPL, Version 3.1' {printed when the program starts}
@y
@d banner=='This is TFtoPL, Version 3.1 for SunOS'
                                         {printed when the program starts}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Fix files in program statement; add external access procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p program TFtoPL(@!tfm_file,@!pl_file,@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@y
@p program TFtoPL(@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type UNIX_file_name=packed array[1..100] of char;
 @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
function testreadaccess(var fn:UNIX_file_name):boolean; external;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [6] Fix declaration of tfm_file; declare extra TFM-file variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!tfm_file:packed file of 0..255;
@y
@!tfm_file:packed file of -128..127; {files that contain binary data}
@!tfm_name:UNIX_file_name;
@!tfm_byte:integer;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7] Open TFM file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ On some systems you may have to do something special to read a
packed file of bytes. For example, the following code didn't work
when it was first tried at Stanford, because packed files have to be
opened with a special switch setting on the \PASCAL\ that was used.
@^system dependencies@>

@<Set init...@>=
reset(tfm_file);
@y
@ On some systems you may have to do something special to read a
packed file of bytes.

@<Set init...@>=
if argc < 3 then begin
    print_ln('Usage: tftopl <tfm-file> <pl-file>');
    goto final_end;
end;
argv(1, tfm_name);
if testreadaccess(tfm_name) then reset(tfm_file, tfm_name)
else begin print_ln('I can''t read the TFM file!'); goto final_end;
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [16] Declare pl_name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!pl_file:text;
@y
@!pl_file:text;
@!pl_name: array[1..100] of char;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [17] Open PL file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ @<Set init...@>=
rewrite(pl_file);
@y
@ @<Set init...@>=
argv(2, pl_name);
rewrite(pl_file, pl_name);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [20] Fix reading of TFM bytes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@<Read the whole input file@>=
read(tfm_file,tfm[0]);
if tfm[0]>127 then abort('The first byte of the input file exceeds 127!');
@.The first byte...@>
if eof(tfm_file) then abort('The input file is only one byte long!');
@.The input...one byte long@>
read(tfm_file,tfm[1]); lf:=tfm[0]*@'400+tfm[1];
if lf=0 then
  abort('The file claims to have length zero, but that''s impossible!');
@.The file claims...@>
if 4*lf-1>tfm_size then abort('The file is bigger than I can handle!');
@.The file is bigger...@>
for tfm_ptr:=2 to 4*lf-1 do
  begin if eof(tfm_file) then
    abort('The file has fewer bytes than it claims!');
@.The file has fewer bytes...@>
  read(tfm_file,tfm[tfm_ptr]);
  end;
if not eof(tfm_file) then
  begin print_ln('There''s some extra junk at the end of the TFM file,');
@.There's some extra junk...@>
  print_ln('but I''ll proceed as if it weren''t there.');
  end
@y
@d fget==begin get(tfm_file);
		tfm_byte:=tfm_file^;
		if tfm_byte<0 then tfm_byte:=tfm_byte+256;
		end
@d fbyte==tfm_byte
@d read_sixteen(#)==begin #:=fbyte;
  if #>127 then abort;
  fget; #:=#*@'400+fbyte;
  end
@d store_four_quarters(#)==begin fget; a:=fbyte; qw.b0:=qi(a);
  fget; b:=fbyte; qw.b1:=qi(b);
  fget; c:=fbyte; qw.b2:=qi(c);
  fget; d:=fbyte; qw.b3:=qi(d);
  #:=qw;
  end

@<Read the whole input file@>=
    {Prime the pump}
tfm_byte:=tfm_file^;
if tfm_byte<0 then tfm_byte:=tfm_byte+256;

tfm[0]:=fbyte; fget;
if tfm[0]>127 then abort('The first byte of the input file exceeds 127!');
@.The first byte...@>
if eof(tfm_file) then abort('The input file is only one byte long!');
@.The input...one byte long@>
tfm[1]:=fbyte; fget; lf:=tfm[0]*@'400+tfm[1];
if lf=0 then
  abort('The file claims to have length zero, but that''s impossible!');
@.The file claims...@>
if 4*lf-1>tfm_size then abort('The file is bigger than I can handle!');
@.The file is bigger...@>
for tfm_ptr:=2 to 4*lf-1 do
  begin if eof(tfm_file) then
    abort('The file has fewer bytes than it claims!');
@.The file has fewer bytes...@>
  tfm[tfm_ptr]:=fbyte; fget;
  end;
if not eof(tfm_file) then
  begin print_ln('There''s some extra junk at the end of the TFM file,');
@.There's some extra junk...@>
  print_ln('but I''ll proceed as if it weren''t there.');
  end

@^system dependencies@>@^Changes for Berkeley {\mc UNIX}@>
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [99, was 88] Add printing of newline at end of program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
final_end:end.
@y
final_end: print_ln(' '); end.
@z
