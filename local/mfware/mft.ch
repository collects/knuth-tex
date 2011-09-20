% Change file for the MFT processor, for use on Berkeley UNIX systems.
%   This file was created by Pierre MacKay, and is based on the 
%   change file for WEAVE written by Howard Trickey and Pavel Curtis.

% History:
%   6/09/86--WEAVE change file copied in entirety and renamed to
%            refer to MFT.
%
%   10/16/89 modified by don for SunOS, brought up to version 2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] MFT: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{MFT changes for Berkeley {\mc UNIX}}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Change banner message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is MFT, Version 2.0'
@y
@d banner=='This is MFT, Version 2.0 for SunOS'
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] add input and output, remove other files, add ref to scan_args,
% [3]       and #include external definition for exit(), etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
program MFT(@!mf_file,@!change_file,@!style_file,@!tex_file);
label end_of_MFT; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@<Error handling procedures@>@/
@y
program MFT(@!input,@!output);
label end_of_MFT; {go here to finish}
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@\
@=#include "mft_ext.h"@>
@\@/
@<Error handling procedures@>@/
@<|scan_args| procedure@>@/
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4] compiler options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@{@&$C+,A+,D-@} {range check, catch arithmetic overflow, no debug overhead}
@y
@=(*$C-*)@> {no range check}
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
% [13] declare UNIX_file_name type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!text_file=packed file of text_char;
@y
@!text_file=packed file of text_char;
@!UNIX_file_name = packed array[1..max_file_name_length] of char;
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
on the \PASCAL\ system that was used in \.{WEAVE}'s initial development:
@^system dependencies@>

@<Set init...@>=
rewrite(term_out,'TTY:'); {send |term_out| output to the terminal}
@y
@ Different systems have different ways of specifying that the output on a
certain file will appear on the user's terminal.
@^system dependencies@>

@<Set init...@>=
; {nothing need be done}
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

@p procedure open_input; {prepare to read the inputs}
begin reset(mf_file); reset(change_file); reset(style_file);
end;
@y
@ The following code opens the input files.
This is called after |scan_args| has filled the file name variables
appropriately.
We use this opportunity, to define some constants related to file opening
and the use of paths.  These constants are repeated in mft_ext.c and
must match the values given there.

@d read_access_mode=4  {``read'' mode for |test_access|}
@d write_access_mode=2 {``write'' mode for |test_access|}

@d no_file_path=0    {no path searching should be done}
@d good_file_path=3  {path specifier for style files}

@^system dependencies@>@^changes for Berkeley {\mc UNIX}@>

@p procedure open_input; {prepare to read inputs}
var i:integer;
begin if test_read_access(mf_name) then
  begin reset(mf_file,mf_name);
  if test_read_access(change_name) then
    begin reset(change_file,change_name);
    if test_access(read_access_mode,good_file_path) then
          reset(style_file,real_name_of_file)
    else begin i:=1;
      while real_name_of_file[i]<>chr(0) do incr(i);
      print_nl('! Can''t open the style file ',real_name_of_file:i);
      mark_fatal;
      jump_out;
      end;
    end
  else begin i:=1; change_name[max_file_name_length]:=' ';
    while change_name[i]<>' ' do incr(i);
    print_nl('! Can''t open the change file ',change_name:i);
    mark_fatal; jump_out;
    end;
  end
else begin i:=1; mf_name[max_file_name_length]:=' ';
  while mf_name[i]<>' ' do incr(i);
  print_nl('! Can''t open the METAFONT source file ',mf_name:i);
  mark_fatal; jump_out;
  end;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [26] opening \TeX\ file
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
% [87] faster flush_buffer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
done: for k:=1 to j do write(tex_file,xchr[out_buf[k]]);
@y
done: linewrite(tex_file,j);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [112] print newline at end of run and exit based upon value of history
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
Let's put it all together now: \.{MFT} starts and ends here.
@^system dependencies@>

@y
Let's put it all together now: \.{MFT} starts and ends here.
@^system dependencies@>

@d UNIXexit==e@&x@&i@&t

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
% [114] system dependent changes--the scan_args procedure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* System-dependent changes.
This module should be replaced, if necessary, by changes to the program
that are necessary to make \.{MFT} work at a particular installation.
It is usually best to design your change file so that all changes to
previous modules preserve the module numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new modules, can be inserted here; then only the index
itself will get a new module number.
@^system dependencies@>
@y
@* System-dependent changes.
The user calls \.{MFT} with arguments on the command line.
These are either file names or flags (beginning with '-').
The following globals are for communicating the user's desires to the rest
of the program. The various |file_name| variables contain strings with
the full names of those files, as UNIX knows them.

The only flags that affect \.{MFT} are |'-c'| and |'-s'| whose 
status is kept in |no_change| and |no_style|.

@d max_file_name_length==100

@<Globals...@>=
@!mf_name,@!change_name,@!style_name,@!tex_name,
        @!real_name_of_file: UNIX_file_name;
@!no_change,no_style:boolean;

@ The |scan_args| procedure looks at the command line arguments and sets
the |file_name| variables accordingly.

At least one file name must be present as the first argument: 
the \.{mf} file.  It may have
an extension, or it may omit it to get |'.mf'| added.
If there is only one file name, the output file name is formed by replacing 
the \.{mf} file name extension by |'.tex'|.
Thus, the command line \.{mft foo} implies the use of the \METAFONT\
input file \.{foo.mf} and the output file \.{foo.tex}.
If this style of command line, with only one argument is used,
the default style file, |plain.mft|, will be used to provide
minimal formatting.

An argument beginning with a minus sign is a flag.
Any letters following the minus sign may cause global 
flag variables to be set.
Currently, a |c| means that there is a change file, and an |s| means
that there is a style file.  The auxiliary files must
of course appear in the same order as the flags.  For example,
the flag -sc must be followed by the name of the |style_file| first,
and then the name of the |change_file|.

@<|scan_args|...@>=
procedure scan_args;
var dot_pos,i,a: integer; {indices}
@!which_file_next: char;
@!fname: array[1..max_file_name_length-5] of char; {temporary argument holder}
@!found_mf,@!found_change,found_style: boolean; {|true| when those 
                                                 file names have been seen}
begin
setpaths; {Get path for style file from \.{MFINPUTS}}
found_mf:=false;
@<Set up null change file@>; found_change:=true; {Default to no change file}
@<Set up plain style file@>; found_style:=true; {Default to plain style file}
for a:=1 to argc-1 do begin
  argv(a,fname); {put argument number |a| into |fname|}
  if fname[1]<>'-' then begin
    if not found_mf then
      @<Get |mf_name| from |fname|, and set up |tex_name@>
    else 
      if not found_change then begin
        if which_file_next <> 's' then begin
                @<Get |change_name| from |fname|@>;
                which_file_next := 's'
                end
        else @<Get |style_name| from |fname|@>
        end
      else if not found_style then begin
        if which_file_next = 's' then begin
                @<Get |style_name| from |fname|@>; 
                which_file_next := 'c'
                end;
        end
    else  @<Print usage error message and quit@>;
    end
  else @<Handle flag argument in |fname|@>;
  end;
if not found_mf then @<Print usage error message and quit@>;
end;

@ Use all of |fname| for the |mf_name| if there is a |'.'| in it,
otherwise add |'.mf'|.
The \TeX\ file name comes from adding things after the dot.
The |argv| procedure will not put more than |max_file_name_length-5|
characters into |fname|, and this leaves enough room in the |file_name|
variables to add the extensions.

The end of a file name is marked with a |' '|, the convention assumed by 
the |reset| and |rewrite| procedures.

@<Get |mf_name|...@>=
begin
dot_pos:=-1;
i:=1;
while (fname[i]<>' ') and (i<=max_file_name_length-5) do begin
        mf_name[i]:=fname[i];
        if fname[i]='.' then dot_pos:=i;
        incr(i);
        end;
if dot_pos=-1 then begin
        dot_pos:=i;
        mf_name[dot_pos]:='.';
        mf_name[dot_pos+1]:='m';
        mf_name[dot_pos+2]:='f';
        mf_name[dot_pos+3]:=' ';
        end
else mf_name[i]:=' ';
for i:=1 to dot_pos do begin
        tex_name[i]:=mf_name[i];
        end;
tex_name[dot_pos+1]:='t';
tex_name[dot_pos+2]:='e';
tex_name[dot_pos+3]:='x';
tex_name[dot_pos+4]:=' ';
which_file_next := 'z';
found_mf:=true;
end

@ Use all of |fname| for the |change_name| if there is a |'.'| in it,
otherwise add |'.ch'|.

@<Get |change_name|...@>=
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
which_file_next := 'z';
found_change:=true;
end

@ Use all of |fname| for the |style_name| if there is a |'.'| in it,
otherwise add |'.mft'|.


@<Get |style_name|...@>=
begin
dot_pos:=-1;
i:=1;
while (fname[i]<>' ') and (i<=max_file_name_length-5)
do begin
        style_name[i]:=fname[i];
        if fname[i]='.' then dot_pos:=i;
        incr(i);
        end;
if dot_pos=-1 then begin
        dot_pos:=i;
        style_name[dot_pos]:='.';
        style_name[dot_pos+1]:='m';
        style_name[dot_pos+2]:='f';
        style_name[dot_pos+3]:='t';
        style_name[dot_pos+4]:=' ';
        end
else style_name[i]:=' ';
which_file_next := 'z';
found_style:=true;
end

@

@<Set up null change file@>=
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

@

@<Set up plain style file@>=
begin
        style_name[1]:='p';
        style_name[2]:='l';
        style_name[3]:='a';
        style_name[4]:='i';
        style_name[5]:='n';
        style_name[6]:='.';
        style_name[7]:='m';
        style_name[8]:='f';
        style_name[9]:='t';
        style_name[10]:=' ';
end

@

@<Handle flag...@>=
begin
i:=2;
while (fname[i]<>' ') and (i<=max_file_name_length-5) do begin
        if fname[i]='c' then begin found_change:=false;
                if which_file_next <> 's' then which_file_next := 'c'
                end
        else if fname[i]='s' then begin found_style:=false;
                  if which_file_next <> 'c' then which_file_next := 's'
                  end
	        else print_nl('Invalid flag ',xchr[xord[fname[i]]]);
        incr(i);
        end;
end

@

@<Print usage error message and quit@>=
begin
print_nl('! Usage: mft file[.mf] [-cs] [change[.ch]] [style[.mft]] ');
error; mark_fatal;
jump_out;
end

@z
