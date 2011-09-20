%   Change file for the TANGLE processor, for use on Berkeley UNIX systems.
%   This file was created by Howard Trickey and Pavel Curtis.
%   Subsequent small updates (to match Stanford releases) by
%   Richard Furuta and Pierre MacKay

% History:
%  10/9/82 (HT) Original version
%  11/29   (HT) New version, with conversion to lowercase handled properly
%               Also, new control sequence:
%                       @=...text...@>   Put ...text... verbatim on a line
%                                        by itself in the Pascal output.
%                                        (argument must fit on one line)
%               This control sequence facilitates putting #include "gcons.h"
%               (for example) in files meant for the pc compiler.
%               Also, changed command line usage, so that the absence of a
%               change file implies no change file, rather than one with the
%               same name as the web file, with .ch at the end.
%  1/15/83 (HT) Changed to work with version 1.2, which incorporates the
%               above change (though unbundling the output line breaking),
%               so mainly had to remove stuff.
%  2/17    (HT) Fixed bug that caused 0-9 in identifiers to be converted to
%               Q-Y on output.
%  3/18    (HT) Brought up to work with Version 1.5.  Added -r command line
%               flag to cause a .rpl file to be written with all the lines
%               of the .web file that were replaced because of the .ch file
%               (useful for comparing with previous .rpl files, to see if a
%               change file will still work with a new version of a .web file)
%               Also, made it write a newline just before exit.
%  4/12    (PC) Merged with Pavel's version, including adding a call to exit()
%               at the end depending upon the value of history.
%  4/16    (PC) Brought up to date with version 1.5 released April, 1983.
%  6/28   (HWT) Brought up to date with version 1.7 released June, 1983.
%		With new change file format, the -r option is now unnecessary.
%  7/17   (HWT) Brought up to date with version 2.0 released July, 1983.
% 11/17   (HWT) Made some I/O use external C procedures, for speedup.
% 8/4/84 (RKF)	To version 2.6
% 9/3/85 (RKF)	To version 2.7
% 12/28/85(PAM) To version 2.8, and increase ww and zz so that METAFONT fits
% 8/10/89 (don) To version 3, with `otherwise' fixed too
% 8/31/89 (don) To version 4, with all possible characters enabled
% 10/6/89 (don) Removed changes for "unambig_length"; I must meet higher goals.
%               Also fixed bugs related to uppercase
% 10/16/89  don fixed bug when ".web" and ".ch" are explicitly stated
% 9/6/90 (don)  To version 4.1
% 3/25/91 (don) To version 4.2
% 9/19/91 (don) To version 4.3
% 2/27/93 (don) To version 4.4

% NOTE: The module numbers refer to the standard WEB manual (CS 980).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{TANGLE changes for Berkeley {\mc UNIX}}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is TANGLE, Version 4.4'
@y
@d banner=='This is TANGLE, Version 4.4 for SunOS'
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] add input and output, remove other files, add ref to scan_args,
% [2]       and #include external definition for exit(), etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
program TANGLE(@!web_file,@!change_file,@!Pascal_file,@!pool);
label end_of_TANGLE; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@<Error handling procedures@>@/
@y
program TANGLE(@!input,@!output);
label end_of_TANGLE; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@\
@=#include "tangext.h"@>
@\@/
@<Error handling procedures@>@/
@<Declaration of |scan_args|@>@/
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4] compiler options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@{@&$C-,A+,D-@} {no range check, catch arithmetic overflow, no debug overhead}
@!debug @{@&$C+,D+@}@+ gubed {but turn everything on when debugging}
@y
@=(*$C-*)@> {no range check}
@!debug @=(*$C+*)@>@+ gubed {but turn everything on when debugging}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7] Fix others:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {SunOS Pascal default cases}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [8] keep long identifier names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!max_id_length=12; {long identifiers are chopped to this length, which must
  not exceed |line_length|}
@y
@!max_id_length=50; {long identifiers are chopped to this length, which must
  not exceed |line_length|}
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
 {Nothing need be done on Berkeley UNIX}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [22] flush terminal buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d update_terminal == break(term_out) {empty the terminal output buffer}
@y
@d update_terminal == flush(term_out) {empty the terminal output buffer}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [24] open input files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The following code opens the input files.  Since these files were listed
in the program header, we assume that the \PASCAL\ runtime system has
already checked that suitable file names have been given; therefore no
additional error checking needs to be done.
@^system dependencies@>

@p procedure open_input; {prepare to read |web_file| and |change_file|}
begin reset(web_file); reset(change_file);
end;
@y
@ The following code opens the input files.
This happens after the initialize procedure has executed.
That will have called the |scan_args| procedure to set up the global
variables |web_name| and |change_name| to the appropriate file
names.
These globals, and the |scan_args| procedure will be defined at the end
where they won't disturb the module numbering.
@^system dependencies@>

@p procedure open_input; {prepare to read |web_file| and |change_file|}
begin
reset(web_file,web_name); reset(change_file,change_name);
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [26] open output files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The following code opens |Pascal_file| and |pool|.
Since these files were listed in the program header, we assume that the
\PASCAL\ runtime system has checked that suitable external file names have
been given.
@^system dependencies@>

@<Set init...@>=
rewrite(Pascal_file); rewrite(pool);
@y
@ The following code opens |Pascal_file| and |pool|.
Use the |scan_args| procedure to fill the global file names,
according to the names given on the command line.
@^system dependencies@>

@<Set init...@>=
scan_args;
rewrite(Pascal_file,Pascal_name); rewrite(pool,pool_name);
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
With Berkeley {\mc UNIX} we call an external C procedure, |line_read|.
That routine fills |buffer| from 0 onwards with the |xord|'ed values
of the next line, setting |limit| appropriately (ignoring trailing
blanks).
It will stop if |limit=buf_size|, and the following will cause an error
message.
Note: for bootstrapping purposes it is all right to use the original form
of |input_ln|; it will just run slower.

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
% [38] Data Structures: provide for larger |byte_mem| and |tok_mem|
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x Extra capacity:
@d ww=2 {we multiply the byte capacity by approximately this amount}
@d zz=3 {we multiply the token capacity by approximately this amount}
@y
@d ww=3 {we multiply the byte capacity by approximately this amount}
@d zz=4 {we multiply the token capacity by approximately this amount}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [96] faster flush_buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d check_break==if out_ptr>line_length then flush_buffer

@p procedure flush_buffer; {writes one line to output file}
var k:0..out_buf_size; {index into |out_buf|}
@!b:0..out_buf_size; {value of |break_ptr| upon entry}
begin b:=break_ptr;
if (semi_ptr<>0)and(out_ptr-semi_ptr<=line_length) then break_ptr:=semi_ptr;
for k:=1 to break_ptr do write(Pascal_file,xchr[out_buf[k-1]]);
@y
For Berkeley {\mc UNIX} we use an external C procedure, |line_write|,
to write the |xchr|'d version of characters to a file.
This improves the speed significantly.

@d check_break==if out_ptr>line_length then flush_buffer

@p procedure flush_buffer; {writes one line to output file}
var k:0..out_buf_size; {index into |out_buf|}
@!b:0..out_buf_size; {value of |break_ptr| upon entry}
begin b:=break_ptr;
if (semi_ptr<>0)and(out_ptr-semi_ptr<=line_length) then break_ptr:=semi_ptr;
line_write(Pascal_file,break_ptr);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [105] Accept DIV, div, MOD, and mod
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
 (((out_contrib[1]="D")and(out_contrib[2]="I")and(out_contrib[3]="V")) or@|
 ((out_contrib[1]="M")and(out_contrib[2]="O")and(out_contrib[3]="D")) ))or@|
@^uppercase@>
@y
  (((out_contrib[1]="D")and(out_contrib[2]="I")and(out_contrib[3]="V")) or@|
  ((out_contrib[1]="d")and(out_contrib[2]="i")and(out_contrib[3]="v")) or@|
  ((out_contrib[1]="M")and(out_contrib[2]="O")and(out_contrib[3]="D")) or@|
  ((out_contrib[1]="m")and(out_contrib[2]="o")and(out_contrib[3]="d")) ))or@|
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [110] lowercase ids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@^uppercase@>
  if ((out_buf[out_ptr-3]="D")and(out_buf[out_ptr-2]="I")and
    (out_buf[out_ptr-1]="V"))or @/
     ((out_buf[out_ptr-3]="M")and(out_buf[out_ptr-2]="O")and
    (out_buf[out_ptr-1]="D")) then@/ goto bad_case
@y
  if ((out_buf[out_ptr-3]="D")and(out_buf[out_ptr-2]="I")and
    (out_buf[out_ptr-1]="V"))or @/
     ((out_buf[out_ptr-3]="d")and(out_buf[out_ptr-2]="i")and
    (out_buf[out_ptr-1]="v"))or @/
     ((out_buf[out_ptr-3]="M")and(out_buf[out_ptr-2]="O")and
    (out_buf[out_ptr-1]="D"))or @/
     ((out_buf[out_ptr-3]="m")and(out_buf[out_ptr-2]="o")and
    (out_buf[out_ptr-1]="d")) then@/ goto bad_case
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [114] lowercase operators (`and', `or', etc.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
and_sign: begin out_contrib[1]:="A"; out_contrib[2]:="N"; out_contrib[3]:="D";
@^uppercase@>
  send_out(ident,3);
  end;
not_sign: begin out_contrib[1]:="N"; out_contrib[2]:="O"; out_contrib[3]:="T";
  send_out(ident,3);
  end;
set_element_sign: begin out_contrib[1]:="I"; out_contrib[2]:="N";
  send_out(ident,2);
  end;
or_sign: begin out_contrib[1]:="O"; out_contrib[2]:="R"; send_out(ident,2);
@y
and_sign: begin out_contrib[1]:="a"; out_contrib[2]:="n"; out_contrib[3]:="d";
  send_out(ident,3);
  end;
not_sign: begin out_contrib[1]:="n"; out_contrib[2]:="o"; out_contrib[3]:="t";
  send_out(ident,3);
  end;
set_element_sign: begin out_contrib[1]:="i"; out_contrib[2]:="n";
  send_out(ident,2);
  end;
or_sign: begin out_contrib[1]:="o"; out_contrib[2]:="r"; send_out(ident,2);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [116] Remove conversion to uppercase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ Single-character identifiers represent themselves, while longer ones
appear in |byte_mem|. All must be converted to uppercase,
with underlines removed. Extremely long identifiers must be chopped.

(Some \PASCAL\ compilers work with lowercase letters instead of
uppercase. If this module of \.{TANGLE} is changed, it's also necessary
to change from uppercase to lowercase in the modules that are
listed in the index under ``uppercase''.)
@^system dependencies@>
@^uppercase@>

@d up_to(#)==#-24,#-23,#-22,#-21,#-20,#-19,#-18,#-17,#-16,#-15,#-14,
  #-13,#-12,#-11,#-10,#-9,#-8,#-7,#-6,#-5,#-4,#-3,#-2,#-1,#

@<Cases related to identifiers@>=
"A",up_to("Z"): begin out_contrib[1]:=cur_char; send_out(ident,1);
  end;
"a",up_to("z"): begin out_contrib[1]:=cur_char-@'40; send_out(ident,1);
  end;
identifier: begin k:=0; j:=byte_start[cur_val]; w:=cur_val mod ww;
  while (k<max_id_length)and(j<byte_start[cur_val+ww]) do
    begin incr(k); out_contrib[k]:=byte_mem[w,j]; incr(j);
    if out_contrib[k]>="a" then out_contrib[k]:=out_contrib[k]-@'40
    else if out_contrib[k]="_" then decr(k);
    end;
  send_out(ident,k);
  end;
@y
@ Single-character identifiers represent themselves, while longer ones
appear in |byte_mem|. All must be converted to lowercase,
with underlines removed. Extremely long identifiers must be chopped.
@^system dependencies@>

@d up_to(#)==#-24,#-23,#-22,#-21,#-20,#-19,#-18,#-17,#-16,#-15,#-14,
  #-13,#-12,#-11,#-10,#-9,#-8,#-7,#-6,#-5,#-4,#-3,#-2,#-1,#

@<Cases related to identifiers@>=
"A",up_to("Z"),
"a",up_to("z"): begin out_contrib[1]:=cur_char; send_out(ident,1);
  end;
identifier: begin k:=0; j:=byte_start[cur_val]; w:=cur_val mod ww;
  while (k<max_id_length)and(j<byte_start[cur_val+ww]) do
    begin incr(k); out_contrib[k]:=byte_mem[w,j]; incr(j);
    if out_contrib[k]="_" then decr(k);
    end;
  send_out(ident,k);
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [179] make term_in = input
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
% [180] remove term_in reset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
reset(term_in,'TTY:','/I'); {open |term_in| as the terminal, don't do a |get|}
@y

@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [182] write newline just before exit; use value of |history|
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
We have defined plenty of procedures, and it is time to put the last
pieces of the puzzle in place. Here is where \.{TANGLE} starts, and where
it ends.
@^system dependencies@>
@y
We have defined plenty of procedures, and it is time to put the last
pieces of the puzzle in place. Here is where \.{TANGLE} starts, and where
it ends.
@^system dependencies@>

@d UNIXexit==e@&x@&i@&t
@z

@x
@<Print the job |history|@>;
@y
@<Print the job |history|@>;
new_line;
if (history <> spotless) and (history <> harmless_message) then
    UNIXexit(1)
else
    UNIXexit(0);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [188] system dependent changes--the |scan_args| procedure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* System-dependent changes.
This module should be replaced, if necessary, by changes to the program
that are necessary to make \.{TANGLE} work at a particular installation.
It is usually best to design your change file so that all changes to
previous modules preserve the module numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new modules, can be inserted here; then only the index
itself will get a new module number.
@^system dependencies@>
@y
@* System-dependent changes.
@^system dependencies@>

@ The user calls \.{TANGLE} with arguments on the command line.
These are either file names or flags (beginning with '-').
The following globals are for communicating the user's desires to the rest
of the program. The various |file_name| variables contain strings with
the full names of those files, as UNIX knows them.

There are no flags that affect \.{TANGLE} at the moment.

@d max_file_name_length==60

@<Globals...@>=
@!web_name,@!change_name,@!Pascal_name,@!pool_name:
        array[1..max_file_name_length] of char;

@ The |scan_args| procedure looks at the command line arguments and sets
the |file_name| variables accordingly.
At least one file name must be present: the \.{WEB} file.  It may have
an extension, or it may omit it to get |'.web'| added.
The \PASCAL\ output file name is formed by replacing the \.{WEB} file
name extension by |'.p'|.
Similarly, the pool file name is formed using a |'.pool'| extension.

If there is another file name present among the arguments, it is the
change file, again either with an extension or without one to get |'.ch'|
An omitted change file argument means that |'/dev/null'| should be used,
when no changes are desired.

@<Declaration of |scan_args|@>=
procedure scan_args;
var dot_pos,i,a: integer; {indices}
c: char;
@!fname: array[1..max_file_name_length-5] of char; {temporary argument holder}
@!found_web,@!found_change: boolean; {|true| when those file names have
                                        been seen}
begin
found_web:=false;
found_change:=false;
for a:=1 to argc-1 do begin
        argv(a,fname); {put argument number |a| into |fname|}
        if fname[1]<>'-' then begin
                if not found_web then
                        @<Get |web_name|, |Pascal_name|, and
                                | pool_name| variables from |fname|@>
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

The end of a file name is marked with a |' '|, the convention assumed by 
the |reset| and |rewrite| procedures.

@<Get |web_name|...@>=
begin
dot_pos:=-1;
i:=1;
while (fname[i]<>' ') and (i<=max_file_name_length-5) do begin
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
        web_name[dot_pos+4]:=' ';
        end
else web_name[i]:=' ';
for i:=1 to dot_pos do begin
        c:=web_name[i];
        Pascal_name[i]:=c;
        pool_name[i]:=c;
        end;
Pascal_name[dot_pos+1]:='p';
Pascal_name[dot_pos+2]:=' ';
pool_name[dot_pos+1]:='p';
pool_name[dot_pos+2]:='o';
pool_name[dot_pos+3]:='o';
pool_name[dot_pos+4]:='l';
pool_name[dot_pos+5]:=' ';
found_web:=true;
end

@ @<Get |change_name|...@>=
begin
dot_pos:=-1;
i:=1;
while (fname[i]<>' ') and (i<=max_file_name_length-5)
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
        change_name[dot_pos+3]:=' ';
        end
else change_name[i]:=' ';
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
        change_name[10]:=' ';
end

@ There are no flags currently used by \.{TANGLE}, but this module can be
used as a hook to introduce flags.

@<Handle flag...@>=
begin
	@<Print usage error message and quit@>;
end

@ @<Print usage error message and quit@>=
begin
print_nl('! Usage: webfile[.web] [changefile[.ch]]');
error;
jump_out;
end

@z
