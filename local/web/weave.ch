% Change file for the WEAVE processor, for use with GNU Pascal.
%   This file was created by Don Knuth, based on the original
%   UNIX port by Howard Trickey, Pavel Curtis, et al.
%   (See ../web-sparc for details of that work.)

% History:
%  2000.04.29   Original version

% NOTE: The module numbers refer to the standard WEB manual (CS 980).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{WEAVE changes for{\mc GNU} Pascal}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is WEAVE, Version 4.4'
@y
@d banner=='This is WEAVE, Version 4.4 for Linux'
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] add input and output, remove other files, add ref to scan_args,
% [2]       and #include external definition for exit(), etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
program WEAVE(@!web_file,@!change_file,@!tex_file);
label end_of_WEAVE; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@<Error handling procedures@>@/
@y
program WEAVE(@!input,@!output);
label end_of_WEAVE; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@\
@=#include "tangext.h"@>
@\@/
@<Error handling procedures@>@/
@<Declaration of |scan_args|@>@/
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Show statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d stat==@{ {change this to `$\\{stat}\equiv\null$'
  when gathering usage statistics}
@d tats==@t@>@} {change this to `$\\{tats}\equiv\null$'
  when gathering usage statistics}
@y
@d stat== {I'm gathering usage statistics}
@d tats== {because I have to know how close \TeX\ comes to the limits}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4] compiler options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@{@&$C-,A+,D-@} {no range check, catch arithmetic overflow, no debug overhead}
@!debug @{@&$C+,D+@}@+ gubed {but turn everything on when debugging}
@y
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7] Fix others:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {ISO extended Pascal default cases}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [8] Constants: Make stack_size=400 instead of 200
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!stack_size=200; {number of simultaneous output levels}
@y
@!stack_size=400; {number of simultaneous output levels}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [11] make ASCII codes take 1 byte (not 4 or more!)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!ASCII_code=0..255; {eight-bit numbers, a subrange of the integers}
@y
@!ASCII_code=ByteCard; {eight-bit numbers, a subrange of the integers}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [12] make the compiler recognize a text file as text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d text_char == char {the data type of characters in text files}
@d first_text_char=0 {ordinal number of the smallest element of |text_char|}
@d last_text_char=255 {ordinal number of the largest element of |text_char|}

@<Types...@>=
@!text_file=packed file of text_char;
@y
@d text_char == char {the data type of characters in text files}
@d first_text_char=0 {ordinal number of the smallest element of |text_char|}
@d last_text_char=255 {ordinal number of the largest element of |text_char|}
@d text_file==text
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [13] xchr and xord now external
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!xord: array [text_char] of ASCII_code;
  {specifies conversion of input characters}
@!xchr: array [ASCII_code] of text_char;
  {specifies conversion of output characters}
@y
@!xord: external array [text_char] of ASCII_code;
  {specifies conversion of input characters}
@!xchr: external array [ASCII_code] of text_char;
  {specifies conversion of output characters}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [17] enable maximum character set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
for i:=1 to @'37 do xchr[i]:=' ';
for i:=@'200 to @'377 do xchr[i]:=' ';
@y
for i:=1 to @'37 do xchr[i]:=chr(i);
for i:=@'200 to @'377 do xchr[i]:=chr(i);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [20] terminal output: use standard i/o
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d print(#)==write(term_out,#) {`|print|' means write on the terminal}
@y
@d term_out==output
@d print(#)==write(term_out,#) {`|print|' means write on the terminal}
@z

@x
@<Globals...@>=
@!term_out:text_file; {the terminal as an output file}
@y

@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [21] init terminal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ Different systems have different ways of specifying that the output on a
certain file will appear on the user's terminal. Here is one way to do this
on the \PASCAL\ system that was used in \.{TANGLE}'s initial development:
@^system dependencies@>

@<Set init...@>=
rewrite(term_out,'TTY:'); {send |term_out| output to the terminal}
@y
@ Different systems have different ways of specifying that the output on a
certain file will appear on the user's terminal.
@^system dependencies@>

@<Set init...@>=
 {Nothing need be done on Linux}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [22] flush terminal buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d update_terminal == break(term_out) {empty the terminal output buffer}
@y
@d update_terminal == flush_stdout {empty the terminal output buffer}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [24] open input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The following code opens the input files.  Since these files were listed
in the program header, we assume that the \PASCAL\ runtime system has
already checked that suitable file names have been given; therefore no
additional error checking needs to be done. We will see below that
\.{WEAVE} reads through the entire input twice.
@^system dependencies@>

@p procedure open_input; {prepare to read |web_file| and |change_file|}
begin reset(web_file); reset(change_file);
end;
@y
@ The following code opens the input files.
This is called after |scan_args| has filled the file name variables
appropriately.
@^system dependencies@>

@p procedure open_input; {prepare to read |web_file| and |change_file|}
begin
reset(web_file,web_name); reset(change_file,change_name);
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [26] opening tex file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The following code opens |tex_file|.
Since this file was listed in the program header, we assume that the
\PASCAL\ runtime system has checked that a suitable external file name has
been given.
@^system dependencies@>

@<Set init...@>=
rewrite(tex_file);
@y
@ The following code opens |tex_file|.
The |scan_args| procedure is used to set up |tex_name| as required.
@^system dependencies@>

@<Set init...@>=
scan_args;
rewrite(tex_file,tex_name);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [27] buffer now external
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@<Globals...@>=@!buffer: array[0..long_buf_size] of ASCII_code;
@y
@<Globals...@>=@!buffer: external array[0..long_buf_size] of ASCII_code;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [28] faster input_ln
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p function input_ln(var f:text_file):boolean;
  {inputs a line or returns |false|}
var final_limit:0..buf_size; {|limit| without trailing blanks}
begin limit:=0; final_limit:=0;
if eof(f) then input_ln:=false
else  begin while not eoln(f) do
    begin buffer[limit]:=xord[f^]; get(f);
    incr(limit);
    if buffer[limit-1]<>" " then final_limit:=limit;
    if limit=buf_size then
      begin while not eoln(f) do get(f);
      decr(limit); {keep |buffer[buf_size]| empty}
      if final_limit>limit then final_limit:=limit;
      print_nl('! Input line too long'); loc:=0; error;
@.Input line too long@>
      end;
    end;
  read_ln(f); limit:=final_limit; input_ln:=true;
  end;
end;
@y
With Linux we call an external C procedure, |line_read|.
That routine fills |buffer| from 0 onwards with the |xord|'ed values
of the next line, setting |limit| appropriately (ignoring trailing
blanks).
It will stop if |limit=buf_size|, and the following will cause an error
message.

@p function input_ln(var f:text_file):boolean;
  {inputs a line or returns |false|}
begin limit:=0;
if test_eof(f) then input_ln:=false
else  begin line_read(f);
    if limit=buf_size then
      begin
      decr(limit); {keep |buffer[buf_size]| empty}
      print_nl('! Input line too long'); loc:=0; error;
@.Input line too long@>
      end;
   input_ln:=true;
  end;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [50] don't enter xrefs if no_xref set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d append_xref(#)==if xref_ptr=max_refs then overflow('cross reference')
  else  begin incr(xref_ptr); num(xref_ptr):=#;
    end

@p procedure new_xref(@!p:name_pointer);
label exit;
var q:xref_number; {pointer to previous cross reference}
@!m,@!n: sixteen_bits; {new and previous cross-reference value}
begin if (reserved(p)or(byte_start[p]+1=byte_start[p+ww]))and
@y
If the user has sent the |no_xref| flag (the -x option of the command line),
then it is unnecessary to keep track of cross references for identifers.
If one were careful, one could probably make more changes around module
100 to avoid a lot of identifier looking up.

@d append_xref(#)==if xref_ptr=max_refs then overflow('cross reference')
  else  begin incr(xref_ptr); num(xref_ptr):=#;
    end

@p procedure new_xref(@!p:name_pointer);
label exit;
var q:xref_number; {pointer to previous cross-reference}
@!m,@!n: sixteen_bits; {new and previous cross-reference value}
begin if no_xref then return;
if (reserved(p)or(byte_start[p]+1=byte_start[p+ww]))and
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [53] Work around a bug in GPC version 2.8.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@t\hskip1em@>@!tok_mem: packed array [0..max_toks] of sixteen_bits; {tokens}
@y
@t\hskip1em@>@!tok_mem: array [0..max_toks] of sixteen_bits; {tokens}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [185] Work around a bug in GPC version 2.8.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
reswitch: case next_control of
string,verbatim: @<Append a \(string scrap@>;
identifier: @<Append an identifier scrap@>;
TeX_string: @<Append a \TeX\ string scrap@>;
othercases easy_cases
endcases
@y
reswitch: if (next_control=string)or(next_control=verbatim)
 then @<Append a \(string scrap@>
else if (next_control=identifier) then @<Append an identifier scrap@>
else if (next_control=TeX_string) then @<Append a \TeX\ string scrap@>
else easy_cases
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [239] omit index and module names if no_xref set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@<Phase III: Output the cross-reference index@>=
@y
If the user has set the |no_xref| flag (the -x option on the command line),
just finish off the page, omitting the index, module name list, and table of
contents.

@<Phase III: Output the cross-reference index@>=
if no_xref then begin
        finish_line;
        out("\"); out5("v")("f")("i")("l")("l");
        out4("\")("e")("n")("d");
        finish_line;
        end
else begin
@z

@x
print('Done.');
@y
end;
print('Done.');
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [258] term_in == input, when debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
any error stop will set |debug_cycle| to zero.
@y
any error stop will set |debug_cycle| to zero.

@d term_in==input
@z

@x
@!term_in:text_file; {the user's terminal as an input file}
@y

@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [259] Take out reset(term_in)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
reset(term_in,'TTY:','/I'); {open |term_in| as the terminal, don't do a |get|}
@y

@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [261] print newline at end of run and exit based upon value of history
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure Phase_I;
@y
@d UNIXexit==e@&x@&i@&t

@p procedure Phase_I;
@z

@x
end.
@y
new_line;
if (history <> spotless) and (history <> harmless_message) then
    UNIXexit(1)
else
    UNIXexit(0);
end.
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [264] system dependent changes--the scan_args procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* System-dependent changes.
This module should be replaced, if necessary, by changes to the program
that are necessary to make \.{WEAVE} work at a particular installation.
It is usually best to design your change file so that all changes to
previous modules preserve the module numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new modules, can be inserted here; then only the index
itself will get a new module number.
@^system dependencies@>
@y
@* System-dependent changes.
@^system dependencies@>

@ The user calls \.{WEAVE} with arguments on the command line.
These are either file names or flags (beginning with '-').
The following globals are for communicating the user's desires to the rest
of the program. The various |file_name| variables contain strings with
the full names of those files, as UNIX knows them.

The only flag that affects weave is |'-x'| whose status is kept in |no_xref|.

@d max_file_name_length==60

@<Globals...@>=
@!web_name,@!change_name,@!tex_name:
        array[1..max_file_name_length] of char;
@!no_xref:boolean;

@ @<Types...@>=
UNIX_filename=packed array[1..max_file_name_length] of char;

@ The |scan_args| procedure looks at the command line arguments and sets
the |file_name| variables accordingly.
At least one file name must be present: the \.{WEB} file.  It may have
an extension, or it may omit it to get |'.web'| added.
The \TeX\ output file name is formed by replacing the \.{WEB} file
name extension by |'.tex'|.

If there is another file name present among the arguments, it is the
change file, again either with an extension or without one to get |'.ch'|
An omitted change file argument means that |'/dev/null'| should be used,
when no changes are desired.

An argument beginning with a minus sign is a flag.
Any letters following the minus sign may cause global flag variables to be
set.
Currently, an |x| means that the cross referencing information---the index,
the module name list, and the table of contents---is to be suppressed.

@<Declaration of |scan_args|@>=
procedure scan_args;
var dot_pos,i,a: integer; {indices}
@!fname: UNIX_filename; {temporary argument holder}
@!found_web,@!found_change: boolean; {|true| when those file names have
                                        been seen}
begin
found_web:=false;
found_change:=false;
no_xref:=false;
for a:=1 to argc-1 do begin
        argv(a,fname); {put argument number |a| into |fname|}
        if fname[1]<>'-' then begin
                if not found_web then
                        @<Get |web_name| and |tex_name| from |fname|@>
                else if not found_change then
                        @<Get |change_name| from |fname|@>
                else  @<Print usage error message and quit@>;
                end
        else @<Handle flag argument in |fname|@>;
        end;
if not found_web then @<Print usage error message and quit@>;
if not found_change then @<Set up null change file@>;
end;

@ Use all of |fname| for the |web_name| if there is a |'.'| in it,
otherwise add |'.web'|.
The other file names come from adding things after the dot.
The |argv| procedure will not put more than |max_file_name_length-5|
characters into |fname|, and this leaves enough room in the |file_name|
variables to add the extensions.

The end of a file name is marked with a |chr(0)|, the convention assumed by 
the |argv| and |reset| and |rewrite| procedures.

@<Get |web_name|...@>=
begin
dot_pos:=-1;
i:=1;
while (fname[i]<>chr(0)) and (i<=max_file_name_length-5) do begin
        web_name[i]:=fname[i];
        if fname[i]='.' then dot_pos:=i;
        incr(i);
        end;
if dot_pos=-1 then begin
        dot_pos:=i;
        web_name[dot_pos]:='.';
        web_name[dot_pos+1]:='w';
        web_name[dot_pos+2]:='e';
        web_name[dot_pos+3]:='b';
        web_name[dot_pos+4]:=chr(0);
        end
else web_name[i]:=chr(0);
for i:=1 to dot_pos do begin
        tex_name[i]:=web_name[i];
        end;
tex_name[dot_pos+1]:='t';
tex_name[dot_pos+2]:='e';
tex_name[dot_pos+3]:='x';
tex_name[dot_pos+4]:=chr(0);
found_web:=true;
end

@ @<Get |change_name|...@>=
begin
dot_pos:=-1;
i:=1;
while (fname[i]<>chr(0)) and (i<=max_file_name_length-5)
do begin
        change_name[i]:=fname[i];
        if fname[i]='.' then dot_pos:=i;
        incr(i);
        end;
if dot_pos=-1 then begin
        dot_pos:=i;
        change_name[dot_pos]:='.';
        change_name[dot_pos+1]:='c';
        change_name[dot_pos+2]:='h';
        change_name[dot_pos+3]:=chr(0);
        end
else change_name[i]:=chr(0);
found_change:=true;
end

@ @<Set up null...@>=
begin
        change_name[1]:='/';
        change_name[2]:='d';
        change_name[3]:='e';
        change_name[4]:='v';
        change_name[5]:='/';
        change_name[6]:='n';
        change_name[7]:='u';
        change_name[8]:='l';
        change_name[9]:='l';
        change_name[10]:=chr(0);
end

@ @<Handle flag...@>=
begin
i:=2;
while (fname[i]<>chr(0)) and (i<=max_file_name_length-5) do begin
        if fname[i]='x' then no_xref:=true;
        incr(i);
        end;
end

@ @<Print usage error message and quit@>=
begin
print_nl('! Usage: weave [-x] webfile[.web] [changefile[.ch]]');
error;
jump_out;
end

@z
