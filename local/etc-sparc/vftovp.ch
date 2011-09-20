%   Change file for the VFtoVP processor, for use on Berkeley UNIX systems.
%   This file based on TFtoPL.ch and DVItype.ch by Pavel Curtis, Pavel@Cornell.

% History:
% 12/11/89 (don) Initial version
% 3/23/90 (don) Fixed coredump problem when no args given
% 4/26/90 (don) Up to version 1.1
% 9/6/90 (don) Up to version 1.2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{VF\lowercase{to}VP changes for SunOS}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is VFtoVP, Version 1.2' {printed when the program starts}
@y
@d banner=='This is VFtoVP, Version 1.2 for SunOS'
                                         {printed when the program starts}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Fix files in program statement; add external access procedures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p program VFtoVP(@!vf_file,@!tfm_file,@!vpl_file,@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@y
@p program VFtoVP(@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type UNIX_file_name=packed array[1..100] of char;
 @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
function testreadaccess(var fn:UNIX_file_name):boolean; external;
procedure setpaths; external;
function testaccess(accessmode:integer; filepath:integer): boolean; external;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Add a label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@<Labels...@>=final_end;
@y
@<Labels...@>=final_end-1, final_end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4] Increase name_length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!name_length=50; {a file name shouldn't be longer than this}
@y
@!name_length=100; {a file name shouldn't be longer than this}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7] Fix declaration of vf_file; declare extra VF-file variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!vf_file:packed file of byte;
@y
@!vf_file:packed file of -128..127; {files that contain binary data}
@!vf_name:UNIX_file_name;
@!vf_byte:integer;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [10] Fix declaration of tfm_file; declare extra TFM-file variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!tfm_file:packed file of byte;
@y
@!tfm_file:packed file of -128..127; {files that contain binary data}
@!tfm_name:UNIX_file_name;
@!tfm_byte:integer;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [11] Open binary files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ On some systems you may have to do something special to read a
packed file of bytes. For example, the following code didn't work
when it was first tried at Stanford, because packed files have to be
opened with a special switch setting on the \PASCAL\ that was used.
@^system dependencies@>

@<Set init...@>=
reset(tfm_file); reset(vf_file);
@y
@ On some systems you may have to do something special to read a
packed file of bytes.

@<Set init...@>=
if argc < 4 then begin
    print_ln('Usage: vftovp <vf-file> <tfm-file> <vpl-file>');
    goto final_end-1;
end;
argv(1, vf_name); argv(2, tfm_name);
if testreadaccess(vf_name) then reset(vf_file, vf_name)
else begin print_ln('I can''t read the VF file!'); goto final_end-1;
  end;
if testreadaccess(tfm_name) then reset(tfm_file, tfm_name)
else begin print_ln('I can''t read the TFM file!'); goto final_end-1;
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [20] Declare vpl_name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!vpl_file:text;
@y
@!vpl_file:text;
@!vpl_name: array[1..100] of char;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [21] Open VPL file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ @<Set init...@>=
rewrite(vpl_file);
@y
@ @<Set init...@>=
setpaths; {read environment, to find TEXFONTS, if there}
argv(3, vpl_name);
rewrite(vpl_file, vpl_name);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [24] Fix reading of TFM bytes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@<Read the whole \.{TFM} file@>=
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

@<Read the whole \.{TFM} file@>=
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
% [31] Fix reading of VF bytes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d read_vf(#)==read(vf_file,#)
@y
@d read_vf(#)==begin vf_byte:=vf_file^;
    if vf_byte>=0 then #:=vf_byte@+else #:=vf_byte+256;
    get(vf_file);
    end
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [37] Declare real_name_of_file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!cur_name:packed array[1..name_length] of char; {external name,
  with no lower case letters}
@y
@!cur_name,@!real_name_of_file:packed array[1..name_length] of char;
	 {external name}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [38] Fix read_tfm_word to read bytes properly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d read_tfm(#)==if eof(tfm_file) then #:=0@+else read(tfm_file,#)
@y
@d read_tfm(#)==if eof(tfm_file) then #:=0
   else begin tfm_byte:=tfm_file^;
     if tfm_byte>=0 then #:=tfm_byte@+else #:=tfm_byte+256;
     get(tfm_file);
     end
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [39] Open a local TFM file using the normal font paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
reset(tfm_file,cur_name);
@^system dependencies@>
if eof(tfm_file) then
  print_ln('---not loaded, TFM file can''t be opened!')
@.TFM file can\'t be opened@>
else  begin font_bc:=0; font_ec:=256; {will cause error if not modified soon}
@y
if not testaccess(4,3) then
  print_ln('---not loaded, TFM file can''t be opened!')
@.TFM file can\'t be opened@>
else begin reset(tfm_file,real_name_of_file);
  font_bc:=0; font_ec:=256; {will cause error if not modified soon}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [42] Remove initialization of now-defunct array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ @<Set init...@>=
default_directory:=default_directory_name;
@y
@ (No initialization to be done.  Keep this module to preserve numbering.)
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [43] Fix addition of ".tfm" suffix for portability and keep lowercase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The string |cur_name| is supposed to be set to the external name of the
\.{TFM} file for the current font. This usually means that we need to
prepend the name of the default directory, and
to append the suffix `\.{.TFM}'. Furthermore, we change lower case letters
to upper case, since |cur_name| is a \PASCAL\ string.
@y
@ The string |cur_name| is supposed to be set to the external name of the
\.{TFM} file for the current font. This usually means that we need to,
at most sites, append the
suffix ``.tfm''. 
@z

@x
if a=0 then
  begin for k:=1 to default_directory_name_length do
    cur_name[k]:=default_directory[k];
  r:=default_directory_name_length;
  end
else r:=0;
@y
r:=0;
@z

@x
  if (vf[k]>="a")and(vf[k]<="z") then
      cur_name[r]:=xchr[vf[k]-@'40]
  else cur_name[r]:=xchr[vf[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='T'; cur_name[r+3]:='F'; cur_name[r+4]:='M'
@y
  cur_name[r]:=xchr[vf[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='t'; cur_name[r+3]:='f'; cur_name[r+4]:='m'
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [133] Add printing of newlines at end of program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
final_end:end.
@y
final_end: out_ln; final_end-1: print_ln(' '); end.
@z
