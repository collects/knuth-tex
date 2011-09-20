%   Change file for the PKtype processor, for use on Berkeley UNIX systems.

% created by don on 21 Oct 1989 based on GFtype.ch
% brought up to version 2.3 by don on 18 Nov 89

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{PK$\,$\lowercase{type} changes for Berkeley {\mc UNIX}}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is PKtype, Version 2.3' {printed when the program starts}
@y
@d banner=='This is PKtype, Version 2.3 for SunOS'
                                         {printed when the program starts}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Case statement default feature of SunOS Pascal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {default for cases not listed explicitly}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4] Redirect PKtype output to correct output file
%	depending on pkout_active value (consistent with GFtype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d print_ln(#)==write_ln(output,#)
@d print(#)==write(output,#)
@d t_print_ln(#)==write_ln(typ_file,#)
@d t_print(#)==write(typ_file,#)
@y
@d print_ln(#)==if pkout_active then write_ln(typ_file,#)@+else write_ln(#)
@d print(#)==if pkout_active then write(typ_file,#)@+else write(#)
@d t_print_ln==print_ln
@d t_print==print
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4]  Include external header and parse the command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
var @<Globals in the outer block@>@/
procedure initialize; {this procedure gets things started properly}
  var i:integer; {loop index for initializations}
  begin print_ln(banner);@/
  @<Set initial values@>@/
  end;
@y
var @<Globals in the outer block@>@/
@\@=#include "gftopk_ext.h"@>@\
procedure initialize; {this procedure gets things started properly}
  var i:integer; {loop index for initializations}
  begin @<Set initial values@>@/
  @<Parse command line arguments@>;
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [6] Make name_size match the external C routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!name_length=80; {maximum length of a file name}
@y
@!name_length=100; {maximum length of a file name}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7] Have abort print only once
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d abort(#)==begin print_ln(' ',#); t_print_ln(' ',#); jump_out; end
@y
@d abort(#)==begin print_ln(' ',#); jump_out; end
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [30] Change definition of 'byte_file' to correct subrange
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!byte_file=packed file of eight_bits ; {for packed file words}
@y
@!byte_file=packed file of -128..127; {files that contain binary data}
@!UNIX_file_name=packed array[1..name_length] of char;
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [32] Change to file opening
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
specifies the file name. If |eof(f)| is true immediately after
|reset(f,s)| has acted, we assume that no file named |s| is accessible.
@^system dependencies@>

@p procedure open_pk_file; {prepares the input for reading}
begin reset(pk_file,pk_name);
@y
specifies the file name.

The local /PASCAL/ runtimes will dump core if the file isn't present.
We avoid that by using an external procedure.
@^system dependencies@>

@p procedure open_pk_file; {prepares the input for reading}
begin if testreadaccess(pk_name) then reset(pk_file,pk_name)
else abort('Can''t read the PK file');
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [33] Slight change needed by fussy Pascal compiler
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!pk_name,@!typ_name:packed array[1..name_length] of char; {name of input
    and output files}
@y
@!pk_name,@!typ_name:UNIX_file_name; {name of input and output files}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [34] Use modified routine to access pk_file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p function pk_byte : eight_bits ;
var temp : eight_bits ;
begin
   temp := pk_file^ ;
   get(pk_file) ;
   incr(pk_loc) ;
   pk_byte := temp ;
@y
@p function pk_byte : eight_bits ;
var temp : -128..127;
begin
   temp := pk_file^ ;
   get(pk_file) ;
   incr(pk_loc) ;
   if temp<0 then pk_byte:=temp+256 @+else pk_byte := temp ;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [35] Don't open the output file twice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
open_typ_file ;
t_print_ln(banner) ;
@y
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [53--54] Use command line instead of dialog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* Terminal communication.
We must get the file names and determine whether input is to be in
hexadecimal or binary.  To do this, we use the standard input path
name.  We need a procedure to flush the input buffer.  For most systems,
this will be an empty statement.  For other systems, a |print_ln| will
provide a quick fix.  We also need a routine to get a line of input from
the terminal.  On some systems, a simple |read_ln| will do.  Finally,
a macro to print a string to the first blank is required.

@d flush_buffer == begin end
@d get_line(#) == if eoln(input) then read_ln(input) ;
   i := 1 ;
   while not (eoln(input) or eof(input)) do begin
      #[i] := input^ ;
      incr(i) ;
      get(input) ;
   end ;
   #[i] := ' '

@ @p procedure dialog ;
var i : integer ; {index variable}
buffer : packed array [1..name_length] of char; {input buffer}
begin
   for i := 1 to name_length do begin
      typ_name[i] := ' ' ;
      pk_name[i] := ' ' ;
   end;
   print('Input file name:  ') ;
   flush_buffer ;
   get_line(pk_name) ;
   print('Output file name:  ') ;
   flush_buffer ;
   get_line(typ_name) ;
end ;
@y
@* Command line parsing.
The command line issued to start \.{PKtype} should also contain the
names of the input (PK) file, and optionally, the name of an output
file to receive the output from \.{PKtype}.  This segment decodes
the command line, and saves the file names in the appropriate variables.
@^system dependencies@>

@d dialog== {we omit the dialog}

@<Parse command...@>=
if (argc < 2) or (argc > 3) then
	begin print_ln('Usage: pktype PKfile [outputfile]');@/
	goto final_end; { we will be unstructured just this once }
	end;
argv(1, pk_name);
if argc > 2 then
	begin argv(2, typ_name);@/
	rewrite(typ_file,typ_name);@/
	pkout_active := true;@/
        write_ln(banner); {standard output gets only this}
	end;
print_ln(banner)

@ @<Glob...@>=
@!pkout_active: boolean; {has the |typ_file| been opened?}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [56] Final touchup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* System-dependent changes.
This section should be replaced, if necessary, by changes to the program
that are necessary to make \.{PKtype} work at a particular installation.
Any additional routines should be inserted here.
@^system dependencies@>
@y
@* System-dependent changes.
This section should be replaced, if necessary, by changes to the program
that are necessary to make \.{PKtype} work at a particular installation.
Any additional routines should be inserted here.
@^system dependencies@>

We need to initialize the value of the new boolean variable that
we introduced.

@<Set initial ...@>=
pkout_active:=false;
@z

