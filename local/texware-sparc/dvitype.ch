%   Change file for the DVItype processor, for use on Berkeley UNIX systems.
%   This file was created by Howard Trickey, CSD.Trickey@SCORE, and modified
%   by Pavel Curtis, Pavel@Cornell.

% History:
%   ??     (HT) Original version.
%   4/4/83 (PC) Merged with Pavel's change file and made to work with the
%               version 1.0 of DVItype released with version 0.95 of TeX in
%               February, 1983.
%   4/18   (PC) Added changes to module 47 so that it would work the same
%               when input was a file (or pipe) as with a terminal.
%   6/29  (HWT) Brought up to version 1.1 as released with version 0.99 of
%		TeX, with new change file format
%   7/28  (HWT) Brought up to version 2 as released with version 0.999.
%		Only the banner changes.
%  11/21  (HWT) Brought up to version 2.2 as released with version 1.0.
%  2/19/84 (HWT) Made it use TEXFONTS environment.
%  3/23/84 (HWT) Brought up to version 2.3.
%  7/11/84 (HWT) Brought up to version 2.6 as released with version 1.1.
%  8/4/84 (RKF) To version 2.7
%  9/3/85 (RKF) To version 2.8
%  12/5/87 (PAM) To version 2.9
%  8/10/89 (don) Cosmetic change for SunOS; moved usage test
%  10/15/89 (don) Fixed input_ln so that initial newline isn't lost
%  10/18/89 (don) Enabled random reading
%  10/30/89 (don) To version 3
%  11/18/89 (don) To version 3.1
%  1/2/90 (don) To version 3.2
%  5/17/90 (don) To version 3.3
%  9/6/90  (don) To version 3.4
%  3/7/95  (don) To version 3.5
%  12/28/95 (don) To version 3.6
%  12/23/96 (don) Identified the TFM file that was missing

% The section numbers used in this file refer to those in the standard
% TeXware report (CS1097).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{DVI$\,$\lowercase{type} changes for SunOS}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is DVItype, Version 3.6' {printed when the program starts}
@y
@d banner=='This is DVItype, Version 3.6 for SunOS'
                                         {printed when the program starts}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Use default case statement feature of SunOS Pascal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {default for cases not listed explicitly}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Change filenames in program statement; add #include statement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d print(#)==write(#)
@d print_ln(#)==write_ln(#)

@p program DVI_type(@!dvi_file,@!output);
@y
For Berkeley {\mc UNIX}, we need the name |output| for the dialog, so make
the output come out on a file called |'dvitype.out'|.

@d print(#)==write(dvityout,#)
@d print_ln(#)==write_ln(dvityout,#)

@p program DVI_type(@!input,@!output);
@z

@x
var @<Globals in the outer block@>@/
@y
var @<Globals in the outer block@>@/
@\@=#include "dvityext.h"@>@\ {declarations for external C procedures}
@z

@x
  begin print_ln(banner);@/
@y
  begin
  setpaths; {read environment, to find TEXFONTS, if there}
  rewrite(dvityout,'dvitype.out'); {prepare typescript for output}
  print_ln(banner);@/
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [5] Increase name_length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!name_length=50; {a file name shouldn't be longer than this}
@y
@!name_length=100; {a file name shouldn't be longer than this}
@z


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [21] Change definition of 'byte_file' to correct subrange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
We shall stick to simple \PASCAL\ in this program, for reasons of clarity,
even if such simplicity is sometimes unrealistic.

@<Types...@>=
@!eight_bits=0..255; {unsigned one-byte quantity}
@!byte_file=packed file of eight_bits; {files that contain binary data}
@y
On Berkeley {\mc UNIX}, we have to use |-128..127| for byte files, as
explained in the \TeX\ changes.

@<Types...@>=
@!eight_bits=0..255; {unsigned one-byte quantity}
@!byte_file=packed file of -128..127; {files that contain binary data}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [23] Fix up opening the binary files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure open_dvi_file; {prepares to read packed bytes in |dvi_file|}
begin reset(dvi_file);
cur_loc:=0;
end;
@#
procedure open_tfm_file; {prepares to read packed bytes in |tfm_file|}
begin reset(tfm_file,cur_name);
end;
@y
On Berkeley {\mc UNIX}, the |eof| testing won't work.
We use the external |test_access| procedure, which also does path searching
based on the user's environment or the default path.

@d read_access_mode=4  {``read'' mode for |test_access|}
@d write_access_mode=2 {``write'' mode for |test_access|}

@d no_file_path=0    {no path searching should be done}
@d font_file_path=3  {path specifier for \.{TFM} files}

@p procedure open_dvi_file; {prepares to read packed bytes in |dvi_file|}
begin argv(1, cur_name);
    if test_access(read_access_mode,no_file_path) then
	begin dvi_name:=real_name_of_file; reset(dvi_file,dvi_name)
        end
    else begin
	write_ln('DVI file not found');
	jump_out;
    end;
    cur_loc:=0;
end;
@#
procedure open_tfm_file; {prepares to read packed bytes in |tfm_file|}
begin
if test_access(read_access_mode,font_file_path) then
    reset(tfm_file,real_name_of_file)
else begin
    write_ln('TFM file not found: ',cur_name);
    jump_out
end;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [24] Declare real_name_of_file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
|dvi_file|, and |cur_name| is a string variable that will be set to the
current font metric file name before |open_tfm_file| is called.

@<Glob...@>=
@!cur_loc:integer; {where we are about to look, in |dvi_file|}
@!cur_name:packed array[1..name_length] of char; {external name,
  with no lower case letters}
@y
|dvi_file|, and |cur_name| is a string variable that will be set to the
current font metric file name before |open_tfm_file| is called.
Under UNIX, we also have a |real_name_of_file| string, that gets
set by the external |test_access| procedure after path searching.

@<Glob...@>=
@!cur_loc:integer; {where we are about to look, in |dvi_file|}
@!cur_name,@!real_name_of_file,@!dvi_name:packed array[1..name_length] of char;
	 {external name}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [26] Fix read_tfm_word to read bytes properly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure read_tfm_word;
begin read(tfm_file,b0); read(tfm_file,b1);
read(tfm_file,b2); read(tfm_file,b3);
end;
@y
@d get_tfm_byte(#) ==
    read(tfm_file,byte); if byte < 0 then # := byte + 256 else # := byte;

@p procedure read_tfm_word;
var byte : -128..127;
begin
get_tfm_byte(b0);
get_tfm_byte(b1);
get_tfm_byte(b2);
get_tfm_byte(b3);
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [27] Fix up functions to read DVI bytes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p function get_byte:integer; {returns the next byte, unsigned}
var b:eight_bits;
begin if eof(dvi_file) then get_byte:=0
else  begin read(dvi_file,b); incr(cur_loc); get_byte:=b;
  end;
end;
@#
function signed_byte:integer; {returns the next byte, signed}
var b:eight_bits;
begin read(dvi_file,b); incr(cur_loc);
if b<128 then signed_byte:=b @+ else signed_byte:=b-256;
end;
@#
function get_two_bytes:integer; {returns the next two bytes, unsigned}
var a,@!b:eight_bits;
begin read(dvi_file,a); read(dvi_file,b);
cur_loc:=cur_loc+2;
get_two_bytes:=a*256+b;
end;
@#
function signed_pair:integer; {returns the next two bytes, signed}
var a,@!b:eight_bits;
begin read(dvi_file,a); read(dvi_file,b);
cur_loc:=cur_loc+2;
if a<128 then signed_pair:=a*256+b
else signed_pair:=(a-256)*256+b;
end;
@#
function get_three_bytes:integer; {returns the next three bytes, unsigned}
var a,@!b,@!c:eight_bits;
begin read(dvi_file,a); read(dvi_file,b); read(dvi_file,c);
cur_loc:=cur_loc+3;
get_three_bytes:=(a*256+b)*256+c;
end;
@#
function signed_trio:integer; {returns the next three bytes, signed}
var a,@!b,@!c:eight_bits;
begin read(dvi_file,a); read(dvi_file,b); read(dvi_file,c);
cur_loc:=cur_loc+3;
if a<128 then signed_trio:=(a*256+b)*256+c
else signed_trio:=((a-256)*256+b)*256+c;
end;
@#
function signed_quad:integer; {returns the next four bytes, signed}
var a,@!b,@!c,@!d:eight_bits;
begin read(dvi_file,a); read(dvi_file,b); read(dvi_file,c); read(dvi_file,d);
cur_loc:=cur_loc+4;
if a<128 then signed_quad:=((a*256+b)*256+c)*256+d
else signed_quad:=(((a-256)*256+b)*256+c)*256+d;
end;
@y
@p function get_byte:integer; {returns the next byte, unsigned}
var b:-128..127;
begin if eof(dvi_file) then get_byte:=0
else  begin read(dvi_file,b); incr(cur_loc); 
            if b < 0 then get_byte := b + 256 else get_byte:=b;
  end;
end;
@#
function signed_byte:integer; {returns the next byte, signed}
var b:-128..127;
begin read(dvi_file,b); incr(cur_loc);
signed_byte:=b;
end;
@#
function get_two_bytes:integer; {returns the next two bytes, unsigned}
var a,b:integer;
begin a := get_byte; b := get_byte;
get_two_bytes:=a*256+b;
end;
@#
function signed_pair:integer; {returns the next two bytes, signed}
var a,@!b:integer;
begin  a := signed_byte; b := get_byte;
signed_pair:=a*256+b
end;
@#
function get_three_bytes:integer; {returns the next three bytes, unsigned}
var a,@!b,@!c:integer;
begin a := get_byte; b := get_byte; c := get_byte;
get_three_bytes:=(a*256+b)*256+c;
end;
@#
function signed_trio:integer; {returns the next three bytes, signed}
var a,@!b,@!c:integer;
begin a := signed_byte; b := get_byte; c := get_byte;
signed_trio:=(a*256+b)*256+c
end;
@#
function signed_quad:integer; {returns the next four bytes, signed}
var a,@!b,@!c,@!d:integer;
begin a := signed_byte; b := get_byte; c := get_byte; d := get_byte;
signed_quad:=((a*256+b)*256+c)*256+d
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [28] Redefine dvi_length() and move_to_byte().
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p function dvi_length:integer;
begin set_pos(dvi_file,-1); dvi_length:=cur_pos(dvi_file);
end;
@#
procedure move_to_byte(n:integer);
begin set_pos(dvi_file,n); cur_loc:=n;
end;
@y
@p function dvi_length:integer;
begin dvi_length:=flength(dvi_file);
end;
@#
procedure move_to_byte(n:integer);
begin bseek(dvi_file,n); cur_loc:=n;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [45] Define term_in and term_out and declare dvityout, first_input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
and |term_out| for terminal output.
@^system dependencies@>

@<Glob...@>=
@!buffer:array[0..terminal_line_length] of ASCII_code;
@!term_in:text_file; {the terminal, considered as an input file}
@!term_out:text_file; {the terminal, considered as an output file}
@y
and |term_out| for terminal output.
@^system dependencies@>

@d term_in==input
@d term_out==output

@<Glob...@>=
@!buffer:array[0..terminal_line_length] of ASCII_code;
@!dvityout:text;
@!first_input:boolean; {true until |input_ln| has been invoked}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [46] Define update_terminal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d update_terminal == break(term_out) {empty the terminal output buffer}
@y
@d update_terminal == flush(term_out) {empty the terminal output buffer}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [47] Remove call to reset(term_in) and initial eoln test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
begin update_terminal; reset(term_in);
if eoln(term_in) then read_ln(term_in);
@y
begin update_terminal;
if first_input then first_input:=false
else if eoln(term_in) then read_ln(term_in);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [50] Remove call to rewrite(term_out)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
begin rewrite(term_out); {prepare the terminal for output}
@y
begin
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [64] Set default_directory_name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d default_directory_name=='TeXfonts:' {change this to the correct name}
@d default_directory_name_length=9 {change this to the correct length}

@<Glob...@>=
@!default_directory:packed array[1..default_directory_name_length] of char;
@y
Actually, under UNIX the standard area is defined in an external
``texpaths.h'' file.  And the users have a path searched for fonts,
by setting the TEXFONTS environment variable.
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [65] Remove initialization of now-defunct array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ @<Set init...@>=
default_directory:=default_directory_name;
@y
@ (No initialization to be done.  Keep this module to preserve numbering.)
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [66] Fix addition of ".tfm" suffix for portability and keep lowercase
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
if p=0 then
  begin for k:=1 to default_directory_name_length do
    cur_name[k]:=default_directory[k];
  r:=default_directory_name_length;
  end
else r:=0;
@y
r:=0;
@z

@x
  if (names[k]>="a")and(names[k]<="z") then
      cur_name[r]:=xchr[names[k]-@'40]
  else cur_name[r]:=xchr[names[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='T'; cur_name[r+3]:='F'; cur_name[r+4]:='M'
@y
  cur_name[r]:=xchr[names[k]];
  end;
cur_name[r+1]:='.'; cur_name[r+2]:='t'; cur_name[r+3]:='f'; cur_name[r+4]:='m'
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [105] Reopen DVI file after postamble has been checked
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
if not eof(dvi_file) then bad_dvi('signature in byte ',cur_loc-1:1,
@.signature...should be...@>
    ' should be 223')
else if cur_loc<k+4 then
  print_ln('not enough signature bytes at end of file (',
@.not enough signature bytes...@>
    cur_loc-k:1,')');
@y
if not eof(dvi_file) then bad_dvi('signature in byte ',cur_loc-1:1,
@.signature...should be...@>
    ' should be 223');
if cur_loc<k+4 then
  print_ln('not enough signature bytes at end of file (',
@.not enough signature bytes...@>
    cur_loc-k:1,')');
reset(dvi_file,dvi_name) {the Berkeley UNIX routines have closed the file}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [107] Check usage; also print newline at end of program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
dialog; {set up all the options}
@y
if argc <> 2 then
  begin write_ln('Usage: dvitype <dvi-file>'); goto final_end;
  end;
first_input:=true; dialog; {set up all the options}
@z
@x
final_end:end.
@y
final_end: print_ln(' '); end.
@z
