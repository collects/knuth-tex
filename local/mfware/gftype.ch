% $Header: gftype.ch,v 2.2.1.4 86/01/27 15:43:41 richards Released $

%   Change file for the GFtype processor, for use on Berkeley UNIX systems.

% History:
%
% don upgraded to version 3.1 on 3/15/91
%
% don added testreadaccess (to avoid core dump on bad GF file name) on 89/10/18
%
% don made changes for version 3 and SunOS on 89/08/12
% (I simplified things by borrowing from dvitype.ch)
%
% $Log:	gftype.ch,v $
% Revision 2.2.1.4  86/01/27  15:43:41  richards
% Changed:
% 	text_file type to "text" for Pyramid compiler,
% 	who doesn't believe packed array of char == text, and
% 	won't allow write('strings') to it!
% 
% Revision 2.2.1.3  86/01/21  22:04:30  richards
% Changed:
% 	file_name_size and byte_file declaration to agree with binary I/O
% 	library updates; b_open_in() call to include path specifier
% 
% Revision 2.2.1.2  86/01/21  15:54:21  richards
% Changed:
% 	interface to byte I/O again; now cur_loc is back to a variable,
% 	and b_set_ptr() saves addr of cur_loc so it can be kept in
% 	sync with files.  b_file_loc() was called more frequently than
% 	I thought...
% 
% Revision 2.2.1.1  86/01/20  22:06:53  richards
% Incorporate new Byte-I/O routines in place of fudging Pascal into
% reading bytes; for Pyramid ....
% 
% Revision 2.2  85/10/18  23:31:09  richards
% Updated for GFtype Version 2.2
% 
% Revision 2.1  85/03/03  21:41:49  richards
% Updated to GF utilities distributed with MF Version 0.77 
% 	(New GF file format)
% 
% Revision 2.0  84/12/16  22:42:52  richards
% Updated for GFtype Version 2.0 (New GF file format)
% 
% Revision 1.2  84/12/06  02:35:40  richards
% Updated to GFtype Version 1.2; merged in changes from sdcarl!rusty
% 
% Revision 0.0  84/11/10  02:13:19  richards
% Base version for GFtype 0.0
% 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{GF$\,$\lowercase{type} changes for Berkeley {\mc UNIX}}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is GFtype, Version 3.1' {printed when the program starts}
@y
@d banner=='This is GFtype, Version 3.1 for SunOS'
                                         {printed when the program starts}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Case statement default feature of SunOS Pascal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {default for cases not listed explicitly}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Redirect GFtype output to correct output file
%	depending on gfout_active value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d print(#)==write(#)
@d print_ln(#)==write_ln(#)
@d print_nl==write_ln
@y
@d print(#)==begin if gfout_active then write(gftyout,#) else write(#) end
@d print_ln(#)==begin if gfout_active then write_ln(gftyout,#)
			else write_ln(#) end
@d print_nl==begin if gfout_active then write_ln(gftyout) else write_ln end
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Change program header to standard input/output; include external header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p program GF_type(@!gf_file,@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
procedure initialize; {this procedure gets things started properly}
  var i:integer; {loop index for initializations}
  begin print_ln(banner);@/
  @<Set initial values@>@/
  end;
@y
@p program GF_type(@!input,@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@\@=#include "gftopk_ext.h"@>@\
procedure initialize; {this procedure gets things started properly}
  var i:integer; {loop index for initializations}
  begin @<Set initial values@>@/
  @<Parse command line arguments@>;
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [5] Add file_name_size to constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@<Constants...@>=
@!terminal_line_length=150; {maximum number of characters input in a single
  line of input from the terminal}
@!line_length=79; {\\{xxx} strings will not produce lines longer than this}
@!max_row=79; {vertical extent of pixel image array}
@!max_col=79; {horizontal extent of pixel image array}
@y
@<Constants...@>=
@!terminal_line_length=150; {maximum number of characters input in a single
  line of input from the terminal}
@!line_length=79; {\\{xxx} strings will not produce lines longer than this}
@!max_row=79; {vertical extent of pixel image array}
@!max_col=79; {horizontal extent of pixel image array}
@!file_name_size=100; {max length of file name on command line}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7] Have abort append <nl> to end of msg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d abort(#)==begin print(' ',#); jump_out;
@y
@d abort(#)==begin print_ln(' ',#); jump_out;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [20] Change definition of 'byte_file' to correct subrange
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
@!UNIX_file_name=packed array[1..file_name_size] of char;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [21] Add gf_name declaration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The program deals with one binary file variable: |gf_file| is the main
input file that we are translating into symbolic form.

@<Glob...@>=
@!gf_file:byte_file; {the stuff we are \.{GF}typing}
@y
@ The program deals with one binary file variable: |gf_file| is the main
input file that we are translating into symbolic form.
We also declare array |gf_name|, used to hold the name of |gf_file|.

@<Glob...@>=
@!gf_file:byte_file; {the stuff we are \.{GF}typing}
@!gf_name: UNIX_file_name;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [22] Change to file opening
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure open_gf_file; {prepares to read packed bytes in |gf_file|}
begin reset(gf_file);
@y
The local /PASCAL/ runtimes will dump core if the file isn't present.
We avoid that by using an external procedure.

@p procedure open_gf_file; {prepares to read packed bytes in |gf_file|}
begin if testreadaccess(gf_name) then reset(gf_file,gf_name)
else abort('Can''t read the GF file');
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [24] Use modified routines to access gf_file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p function get_byte:integer; {returns the next byte, unsigned}
var b:eight_bits;
begin if eof(gf_file) then get_byte:=0
else  begin read(gf_file,b); incr(cur_loc); get_byte:=b;
  end;
end;
@#
function get_two_bytes:integer; {returns the next two bytes, unsigned}
var a,@!b:eight_bits;
begin read(gf_file,a); read(gf_file,b);
cur_loc:=cur_loc+2;
get_two_bytes:=a*256+b;
end;
@#
function get_three_bytes:integer; {returns the next three bytes, unsigned}
var a,@!b,@!c:eight_bits;
begin read(gf_file,a); read(gf_file,b); read(gf_file,c);
cur_loc:=cur_loc+3;
get_three_bytes:=(a*256+b)*256+c;
end;
@#
function signed_quad:integer; {returns the next four bytes, signed}
var a,@!b,@!c,@!d:eight_bits;
begin read(gf_file,a); read(gf_file,b); read(gf_file,c); read(gf_file,d);
cur_loc:=cur_loc+4;
if a<128 then signed_quad:=((a*256+b)*256+c)*256+d
else signed_quad:=(((a-256)*256+b)*256+c)*256+d;
end;
@y
@p function get_byte:integer; {returns the next byte, unsigned}
var b:-128..127;
begin if eof(gf_file) then get_byte:=0
else  begin read(gf_file,b); incr(cur_loc); 
            if b < 0 then get_byte := b + 256 else get_byte:=b;
  end;
end;
@#
function signed_byte:integer; {returns the next byte, signed}
var b:-128..127;
begin read(gf_file,b); incr(cur_loc);
signed_byte:=b;
end;
@#
function get_two_bytes:integer; {returns the next two bytes, unsigned}
var a,b:integer;
begin a := get_byte; b := get_byte;
get_two_bytes:=a*256+b;
end;
@#
function get_three_bytes:integer; {returns the next three bytes, unsigned}
var a,@!b,@!c:integer;
begin a := get_byte; b := get_byte; c := get_byte;
get_three_bytes:=(a*256+b)*256+c;
end;
@#
function signed_quad:integer; {returns the next four bytes, signed}
var a,@!b,@!c,@!d:integer;
begin a := signed_byte; b := get_byte; c := get_byte; d := get_byte;
signed_quad:=((a*256+b)*256+c)*256+d
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [27] Set term_in and term_out to standard input/output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The |input_ln| routine waits for the user to type a line at his or her
terminal; then it puts ASCII-code equivalents for the characters on that line
into the |buffer| array. The |term_in| file is used for terminal input,
and |term_out| for terminal output.
@^system dependencies@>

@<Glob...@>=
@!buffer:array[0..terminal_line_length] of ASCII_code;
@!term_in:text_file; {the terminal, considered as an input file}
@!term_out:text_file; {the terminal, considered as an output file}
@y
@ The |input_ln| routine waits for the user to type a line at his or her
terminal; then it puts ASCII-code equivalents for the characters on that line
into the |buffer| array. The |term_in| file is used for terminal input,
and |term_out| for terminal output.
@^system dependencies@>

@d term_in == input {standard input}
@d term_out == output {standard output}

@<Glob...@>=
@!buffer:array[0..terminal_line_length] of ASCII_code;
@!gftyout: text_file; {output from program}
@!gfout_name: packed array[1..file_name_size] of char; {file name}
@!gfout_active: boolean; {true if |gftyout| is open and ready to write}
@!first_input: boolean; {true before the first call of |input_ln|}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [28] update_terminal becomes flush()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d update_terminal == break(term_out) {empty the terminal output buffer}
@y
@d update_terminal == flush(term_out) {empty the terminal output buffer}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29] eliminate reset() from input_ln
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure input_ln; {inputs a line from the terminal}
var k:0..terminal_line_length;
begin update_terminal; reset(term_in);
if eoln(term_in) then read_ln(term_in);
k:=0;
while (k<terminal_line_length)and not eoln(term_in) do
  begin buffer[k]:=xord[term_in^]; incr(k); get(term_in);
  end;
buffer[k]:=" ";
end;
@y
@p procedure input_ln; {inputs a line from the terminal}
var k:0..terminal_line_length;
begin update_terminal;
if first_input then first_input:=false
else if eoln(term_in) then read_ln(term_in);
k:=0;
while (k<terminal_line_length)and not eoln(term_in) do
  begin buffer[k]:=xord[term_in^]; incr(k); get(term_in);
  end;
buffer[k]:=" ";
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [31] eliminate rewrite() from dialog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure dialog;
label 1,2;
begin rewrite(term_out); {prepare the terminal for output}
write_ln(term_out,banner);@/
@<Determine whether the user |wants_mnemonics|@>;
@<Determine whether the user |wants_pixels|@>;
@<Print all the selected options@>;
end;
@y
@p procedure dialog;
label 1,2;
begin
write_ln(term_out,banner);@/
@<Determine whether the user |wants_mnemonics|@>;
@<Determine whether the user |wants_pixels|@>;
@<Print all the selected options@>;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [65] finish last line written to statistics (stdout)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
print('The file had ',total_chars:1,' character');
if total_chars<>1 then print('s');
print(' altogether.');
@.The file had n characters...@>
final_end:end.
@y
print('The file had ',total_chars:1,' character');
if total_chars<>1 then print('s');
print_ln(' altogether.');
@.The file had n characters...@>
final_end:end.
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [74,75,76] Add new code to parse command line arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* System-dependent changes.
This section should be replaced, if necessary, by changes to the program
that are necessary to make \.{GFtype} work at a particular installation.
It is usually best to design your change file so that all changes to
previous sections preserve the section numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new sections, can be inserted here; then only the index
itself will get a new section number.
@^system dependencies@>
@y
@* System-dependent changes.
This section contains additions to \.{GFtype} necessary to integrate it
into the {\mc UNIX} environment.  The primary addition is a section to
parse command line arguments and put file names into their correct
variables, if needed.
@^system dependencies@>

@ The command line issued to start \.{GFtype} should also contain the
names of the input (GF) file, and optionally, the name of an output
file to receive the output from \.{GFtype}.  This segment decodes
the command line, and saves the file names in the appropriate variables.
@^system dependencies@>

@<Parse command...@>=
if (argc < 2) or (argc > 3) then
	begin print_ln('Usage: gftype GFfile [outputfile]');@/
	goto final_end; { we will be unstructured just this once }
	end;
argv(1, gf_name);
if argc > 2 then
	begin argv(2, gfout_name);@/
	rewrite(gftyout, gfout_name);@/
	gfout_active := true;@/
        print_ln(banner);@/
	end

@ We also need to initialize the values of the new boolean variables
we introduced.

@<Set initial ...@>=
gfout_active:=false;
first_input:=true;
@z

