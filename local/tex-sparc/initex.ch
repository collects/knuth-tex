% Change file for Berkeley UNIX, for a hacked version of the pc pascal
% compiler (with the others: clause in case statements).
%
% Distant relation of David Fuchs' Sep 13, 1982 TOPS20 version, greatly
%   modified by Howard Trickey and Pavel Curtis

% Modification History:
%
% (10/9) HWT 	Brought up to version 0.1
% (10/13) HWT	Fixed bug in hpack
% (10/17) HWT	Changed to version 0.3
% (10/22) HWT	Brought up to version 0.4
% (10/26) HWT	Changed to use version 0.5 source
% (11/19) HWT	Changed to use version 0.8 source; fixed glue_ratios to use
%		external C procedures
% (11/30) HWT	Changed to use new tangle, with verbatim Pascal mode, to avoid
%		need for editing in the #include statement
%               (changed modules 4,9)
% (1/15/83) HWT	Changed to use version 0.94 source; added Pavel's changes to
%		allow undumping; added Grim's fix for grtofl, etc.;
%		modified for Knuth's new tangle.
% (2/1/83) PC   Consolidated with Pavel's version, changed the fl<->gr
%               routines to avoid slow and messy union type.
% (3/18/83) HWT Changed to use version 0.96 source (means changing fltogr and
%		grtofl to unfloat and float, then getting rid of a lot of
%		changes); made TeX print a newline
%		at the end of the run.
% (4/2/83) PC   Added call to exit() at end of run, with exit-value dependent
%               upon the value of `history'.
% (4/16/83) PC  Brought up to version 0.97 of TeX.
% (5/23/83) HWT Changed mem_max to 30000 for initex (because of latex)
% (6/2/83) HWT	Brought up to version 0.98 of TeX.  Changed some of the
%		string-related constants to match the latest tops20
%		change file.  Modified input_ln and write_dvi to use external
%		C procedures, for speed increase.  Changed file opening 
%		procedures to use external C procedure to test for
%		accessibility, so that now none of the pc runtime library
%		programs need to be modified (though close1 is still needed)
% (6/28/83) HWT Brought up to 0.99, with new change file format.
% (7/17/83) HWT Brought up to 0.999.  Added switch-to-editor stuff.
% (7/29/83) HWT Brought up to 0.9999.
% (11/4/83) HWT Brought up to 0.999999.
% (11/16/83) HWT Brought up to 1.0.  Upped max_strings, string_vacancies,
%		pool_size, hash_size, and hash_prime, to agree with
%		TOPS20-changes constants.
% (1/4/84) HWT	Again, upped pool_size to 40000 for LaTeX.
% (2/18/84) HWT Made changes to use search path stuff in new ext.c.  Now all
%		the path specific stuff is localized to texpaths.h
% (6/6/84) HWT  Brought up to 1.1. Upped pool_size and hash_size for LaTeX.
% (31/7/84) HWT  Removed the forgetting of the full file name, so that
%		switch-to-editor works for non-primary file.
% (11/16/84) RKF Brought up to 1.2
% (12/26/84) RKF Brought up to 1.3, consulting changes already done by
%		SVB@Purdue, rusty@sdcarl, and a related file from HWT
% (3/11/85) RKF Brought up to 1.3b
% (9/2/85)  RKF	Brought up to 1.5 (yep, missed 1.4)
% (1/30/86) PAM brought up to 2.0
% (12/11/86) PAM commented out the patch which turns on debug.  This is
%  	partly since debug is no longer necessary at this point of development
%	but also because debug turns on range checking in the pc, and in
%	recent months the pc range check has been giving bogus error
%	messages.
% (2/27/87) PAM No change in working code, but noted places where SUNMakefile
%	makes alterations for more efficient SUN code.
% (3/7/87) PAM Changed version number for TeX 2.1
% (9/23/87) PAM Changed version number for TeX 2.3
% (10/25/87) PAM Changed version number for TeX 2.5
% (12/5/87) PAM Changed version number for TeX 2.7
% (1/15/88) PAM Changed version number for TeX 2.9
% (8/9/89) don SunOS changes for TeX 2.991; decreased some constants
% (9/10/89) don Major changes for 8-bit TeX beta test (version 2.992-eps)
% (10/6/89) don Now uptodate with TeX version 2.992 (\approx 3.0)
% (10/29/89) don Upped fontmax to 127 and fontmemsize to 40000
% (1/23/90) don Fixed max_buf_stack logic (it was one too high)
% (9/6/90) don to Version 3.1
% (1/30/91) don to Version 3.14
% (9/19/91) don to Version 3.14a
% (1/25/92) don to Version 3.14b
% (3/15/92) don to Version 3.141
% (6/15/92) don reversed the UNIXexit values (0 is success)(cf make)
% (2/26/93) don to Version 3.1415
% (3/8/95)  don to Version 3.14159
% (4/2/97)  don increased pool_size from 50000 to 60000
%             (and max_strings from 4000 to 6000 in ini_to_vir)
% (9/16/97) don increased buf_size from 500 to 5000 (without bothering
%         to see why the implementation doesn't overflow buf_size gracefully)

% Use this file as is to make an INITEX.  To get production TeX, use the 
% shell script ``ini_to_vir'' and re-TANGLE.

% NOTE: the module numbers in this change file refer to Volume B.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: only print changes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\def\botofcontents{\vskip 0pt plus 1fil minus 1.5in}
@y
\def\botofcontents{\vskip 0pt plus 1fil minus 1.5in}
\let\maybe=\iffalse
\def\title{\TeX82 changes for SunOS}
\def\glob{13}\def\gglob{20, 26} % these are defined in module 1
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.2] banner line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is TeX, Version 3.14159' {printed when \TeX\ starts}
@y
@d banner=='This is TeX, Version 3.14159 for SunOS' {printed when \TeX\ starts}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.4] program header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
Actually the heading shown here is not quite normal: The |program| line
does not mention any |output| file, because \ph\ would ask the \TeX\ user
to specify a file name if |output| were specified here.
@^system dependencies@>

@d mtype==t@&y@&p@&e {this is a \.{WEB} coding trick:}
@y
@d mtype==t@&y@&p@&e {this is a \.{WEB} coding trick:}
@d standard_input==i@&n@&p@&u@&t {and another}
@z
@x
program TEX; {all file names are defined dynamically}
@y
program TEX(standard_input,output); {other file names are defined dynamically}
@z
@x
var @<Global variables@>@/
@y
var @<Global variables@>@/
@#
@\@=#include "ext.h"@>@\ {declarations for external C procedures}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.7] debug..gubed, stat..tats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d debug==@{ {change this to `$\\{debug}\equiv\null$' when debugging}
@d gubed==@t@>@} {change this to `$\\{gubed}\equiv\null$' when debugging}
@y
@d debug==@{ {the trip test will use debugging}
@d gubed==@t@>@}
@z
@x
@d stat==@{ {change this to `$\\{stat}\equiv\null$' when gathering
  usage statistics}
@d tats==@t@>@} {change this to `$\\{tats}\equiv\null$' when gathering
  usage statistics}
@y
@d stat==
@d tats==
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.8] init..tini
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d init== {change this to `$\\{init}\equiv\.{@@\{}$' in the production version}
@d tini== {change this to `$\\{tini}\equiv\.{@@\}}$' in the production version}
@y
@d init==
@d tini==
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.9] compiler directives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@{@&$C-,A+,D-@} {no range check, catch arithmetic overflow, no debug overhead}
@!debug @{@&$C+,D+@}@+ gubed {but turn everything on when debugging}
@y
@=(*$C-*)@> {no range check}
@!debug @=(*$C+*)@> @+ gubed {debug with range check (may cause bogus errors)}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.10] othercases, feature of Sun Pascal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {default for cases not listed explicitly}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.11] compile-time constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!mem_max=30000; {greatest index in \TeX's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INITEX}, otherwise |>=mem_top|}
@!mem_min=0; {smallest index in \TeX's internal |mem| array;
  must be |min_halfword| or more;
  must be equal to |mem_bot| in \.{INITEX}, otherwise |<=mem_bot|}
@!buf_size=500; {maximum number of characters simultaneously present in
  current lines of open files and in control sequences between
  \.{\\csname} and \.{\\endcsname}; must not exceed |max_halfword|}
@!error_line=72; {width of context lines on terminal error messages}
@!half_error_line=42; {width of first lines of contexts in terminal
  error messages; should be between 30 and |error_line-15|}
@!max_print_line=79; {width of longest text lines output; should be at least 60}
@!stack_size=200; {maximum number of simultaneous input sources}
@!max_in_open=6; {maximum number of input files and error insertions that
  can be going on simultaneously}
@!font_max=75; {maximum internal font number; must not exceed |max_quarterword|
  and must be at most |font_base+256|}
@!font_mem_size=20000; {number of words of |font_info| for all fonts}
@!param_size=60; {maximum number of simultaneous macro parameters}
@!nest_size=40; {maximum number of semantic levels simultaneously active}
@!max_strings=3000; {maximum number of strings; must not exceed |max_halfword|}
@!string_vacancies=8000; {the minimum number of characters that should be
  available for the user's control sequences and font names,
  after \TeX's own error messages are stored}
@!pool_size=32000; {maximum number of characters in strings, including all
  error messages and help texts, and the names of all fonts and
  control sequences; must exceed |string_vacancies| by the total
  length of \TeX's own strings, which is currently about 23000}
@!save_size=600; {space for saving values outside of current group; must be
  at most |max_halfword|}
@!trie_size=8000; {space for hyphenation patterns; should be larger for
  \.{INITEX} than it is in production versions of \TeX}
@!trie_op_size=500; {space for ``opcodes'' in the hyphenation patterns}
@!dvi_buf_size=800; {size of the output buffer; must be a multiple of 8}
@!file_name_size=40; {file names shouldn't be longer than this}
@!pool_name='TeXformats:TEX.POOL                     ';
  {string of length |file_name_size|; tells where the string pool appears}
@y
@!mem_max=30000; {greatest index in \TeX's internal |mem| array;
  must be strictly less than |max_halfword|;
  must be equal to |mem_top| in \.{INITEX}, otherwise |>=mem_top|}
@!mem_min=-32767; {smallest index in \TeX's internal |mem| array;
  must be |min_halfword| or more;
  must be equal to |mem_bot| in \.{INITEX}, otherwise |<=mem_bot|}
@!buf_size=5000; {maximum number of characters simultaneously present in
  current lines of open files and in control sequences between
  \.{\\csname} and \.{\\endcsname}; must not exceed |max_halfword|}
@!error_line=79; {width of context lines on terminal error messages}
@!half_error_line=50; {width of first lines of contexts in terminal
  error messages; should be between 30 and |error_line-15|}
@!max_print_line=79; {width of longest text lines output; should be at least 60}
@!stack_size=200; {maximum number of simultaneous input sources}
@!max_in_open=15; {maximum number of input files and error insertions that
  can be going on simultaneously}
@!font_max=127; {maximum internal font number; must not exceed |max_quarterword|
  and must be at most |font_base+256|}
@!font_mem_size=40000; {number of words of |font_info| for all fonts}
@!param_size=60; {maximum number of simultaneous macro parameters}
@!nest_size=40; {maximum number of semantic levels simultaneously active}
@!max_strings=3000; {maximum number of strings; must not exceed |max_halfword|}
@!string_vacancies=8000; {the minimum number of characters that should be
  available for the user's control sequences and font names,
  after \TeX's own error messages are stored}
@!pool_size=60000; {maximum number of characters in strings, including all
  error messages and help texts, and the names of all fonts and
  control sequences; must exceed |string_vacancies| by the total
  length of \TeX's own strings, which is currently about 23000}
@!save_size=600; {space for saving values outside of current group; must be
  at most |max_halfword|}
@!trie_size=8000; {space for hyphenation patterns; should be larger for
  \.{INITEX} than it is in production versions of \TeX}
@!trie_op_size=500; {space for ``opcodes'' in the hyphenation patterns}
@!dvi_buf_size=800; {size of the output buffer; must be a multiple of 8}
@!file_name_size=1024; {file names shouldn't be longer than this}
@!pool_name='tex.pool';
  {string of length |file_name_size|; the string pool name}
@.TeXformats@>
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1.12] sensitive compile-time constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d mem_bot=0 {smallest index in the |mem| array dumped by \.{INITEX};
  must not be less than |mem_min|}
@d mem_top==30000 {largest index in the |mem| array dumped by \.{INITEX};
  must be substantially larger than |mem_bot|
  and not greater than |mem_max|}
@d font_base=0 {smallest internal font number; must not be less
  than |min_quarterword|}
@d hash_size=2100 {maximum number of control sequences; it should be at most
  about |(mem_max-mem_min)/10|}
@d hash_prime=1777 {a prime number equal to about 85\pct! of |hash_size|}
@d hyph_size=307 {another prime; the number of \.{\\hyphenation} exceptions}
@y
@d mem_bot=-32767 {smallest index in the |mem| array dumped by \.{INITEX};
  must not be less than |mem_min|}
@d mem_top==30000 {largest index in the |mem| array dumped by \.{INITEX};
  must be substantially larger than |mem_bot|
  and not greater than |mem_max|}
@d font_base=0 {smallest internal font number; must not be less
  than |min_quarterword|}
@d hash_size=4000 {maximum number of control sequences; it should be at most
  about |(mem_max-mem_min)/10|}
@d hash_prime=3443 {a prime number equal to about 85\pct! of |hash_size|}
@d hyph_size=307 {another prime; the number of \.{\\hyphenation} exceptions}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [2.23] allow any character that we can input to get in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
for i:=0 to @'37 do xchr[i]:=' ';
for i:=@'177 to @'377 do xchr[i]:=' ';
@y
for i:=0 to @'37 do xchr[i]:=chr(i);
for i:=@'177 to @'377 do xchr[i]:=chr(i);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.25] file types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
The program actually makes use also of a third kind of file, called a
@y
The pc compiler on Berkeley {\mc UNIX} won't pack a range into one byte unless
the lower bound is |-128| or more, and the upper bound is |127| or less.
This applies to files, too.  To make the program work with compiler range
checking turned on, we'll have to adjust |eight_bits| codes by sometimes
adding or subtracting |256|.
Note that |eight_bits| really takes 16 bits here.

The program actually makes use also of a third kind of file, called a
@z
@x
@!alpha_file=packed file of text_char; {files that contain textual data}
@!byte_file=packed file of eight_bits; {files that contain binary data}
@y
@!alpha_file=t@&e@&x@&t; {files that contain textual data}
@!byte_file=packed file of -128..127; {files that contain binary data}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.26] add real_name_of_file array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
is crucial for our purposes. We shall assume that |name_of_file| is a variable
of an appropriate type such that the \PASCAL\ run-time system being used to
implement \TeX\ can open a file whose external name is specified by
|name_of_file|.
@^system dependencies@>

@<Glob...@>=
@!name_of_file:packed array[1..file_name_size] of char;@;@/
  {on some systems this may be a \&{record} variable}
@!name_length:0..file_name_size;@/{this many characters are actually
  relevant in |name_of_file| (the rest are blank)}
@y
is crucial for our purposes. We shall assume that |name_of_file| is a variable
of an appropriate type such that the \PASCAL\ run-time system being used to
implement \TeX\ can open a file whose external name is specified by
|name_of_file|.
The Berkeley {\mc UNIX} version uses search paths to look for files to open.
We use |real_name_of_file| to hold the |name_of_file| with a directory
name from the path in front of it.
@^system dependencies@>

@<Glob...@>=
@!name_of_file,@!real_name_of_file:packed array[1..file_name_size] of char;
@;@/
@!name_length:0..file_name_size;@/{this many characters are actually
  relevant in |name_of_file| (the rest are blank)}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.27] file opening
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The \ph\ compiler with which the present version of \TeX\ was prepared has
extended the rules of \PASCAL\ in a very convenient way. To open file~|f|,
we can write
$$\vbox{\halign{#\hfil\qquad&#\hfil\cr
|reset(f,@t\\{name}@>,'/O')|&for input;\cr
|rewrite(f,@t\\{name}@>,'/O')|&for output.\cr}}$$
The `\\{name}' parameter, which is of type `{\bf packed array
$[\langle\\{any}\rangle]$ of \\{char}}', stands for the name of
the external file that is being opened for input or output.
Blank spaces that might appear in \\{name} are ignored.

The `\.{/O}' parameter tells the operating system not to issue its own
error messages if something goes wrong. If a file of the specified name
cannot be found, or if such a file cannot be opened for some other reason
(e.g., someone may already be trying to write the same file), we will have
|@!erstat(f)<>0| after an unsuccessful |reset| or |rewrite|.  This allows
\TeX\ to undertake appropriate corrective action.
@:PASCAL H}{\ph@>
@^system dependencies@>

\TeX's file-opening procedures return |false| if no file identified by
|name_of_file| could be opened.

@d reset_OK(#)==erstat(#)=0
@d rewrite_OK(#)==erstat(#)=0

@p function a_open_in(var f:alpha_file):boolean;
  {open a text file for input}
begin reset(f,name_of_file,'/O'); a_open_in:=reset_OK(f);
end;
@#
function a_open_out(var f:alpha_file):boolean;
  {open a text file for output}
begin rewrite(f,name_of_file,'/O'); a_open_out:=rewrite_OK(f);
end;
@#
function b_open_in(var f:byte_file):boolean;
  {open a binary file for input}
begin reset(f,name_of_file,'/O'); b_open_in:=reset_OK(f);
end;
@#
function b_open_out(var f:byte_file):boolean;
  {open a binary file for output}
begin rewrite(f,name_of_file,'/O'); b_open_out:=rewrite_OK(f);
end;
@#
function w_open_in(var f:word_file):boolean;
  {open a word file for input}
begin reset(f,name_of_file,'/O'); w_open_in:=reset_OK(f);
end;
@#
function w_open_out(var f:word_file):boolean;
  {open a word file for output}
begin rewrite(f,name_of_file,'/O'); w_open_out:=rewrite_OK(f);
end;
@y
@ The \ph\ compiler with which the present version of \TeX\ was prepared has
extended the rules of \PASCAL\ in a very convenient way for file opening.
Berkeley {\mc UNIX} \PASCAL\ isn't nearly as nice as \ph.
Normally, it bombs out if a file open fails.
An external C procedure, |test_access| is used to check whether or not the
open will work.  It is declared in the ``ext.h'' include file, and it returns
|true| or |false|. The |name_of_file| global holds the file name whose access
is to be tested.
The first parameter for |test_access| is the access mode,
one of |read_access_mode| or |write_access_mode|.

We also implement path searching in |test_access|:  its second parameter is
one of the ``file path'' constants defined below.  If |name_of_file|
doesn't start with |'/'| then |test_access| tries prepending pathnames
from the appropriate path list until success or the end of path list
is reached.
On return, |real_name_of_file| contains the original name with the path
that succeeded (if any) prepended.  It is the name used in the various
open procedures.

Note that |a_open_in| has been redefined to take an additional argument,
which should be one of the ``file path'' specifiers.
Since |b_open_in| is only used for \.{TFM} files, and
|w_open_in| is only used for format files, we don't need a path specifying
argument for them.
Path searching is not done for output files.

@d read_access_mode=4  {``read'' mode for |test_access|}
@d write_access_mode=2 {``write'' mode for |test_access|}

@d no_file_path=0    {no path searching should be done}
@d input_file_path=1 {path specifier for \.{\\input} files}
@d read_file_path=2  {path specifier for \.{\\read} files}
@d font_file_path=3  {path specifier for \.{TFM} files}
@d format_file_path=4 {path specifier for format files}
@d pool_file_path=5  {path specifier for the pool file}

@p function a_open_in(var f:alpha_file;@!path_specifier:integer):boolean;
  {open a text file for input}
var @!ok:boolean;
begin
if test_access(read_access_mode,path_specifier) then
    begin reset(f,real_name_of_file); ok:=true@+end
else
    ok:=false;
a_open_in:=ok;
end;
@#
function a_open_out(var f:alpha_file):boolean;
  {open a text file for output}
var @!ok:boolean;
begin
if test_access(write_access_mode,no_file_path) then
    begin rewrite(f,real_name_of_file); ok:=true @+end
else ok:=false;
a_open_out:=ok;
end;
@#
function b_open_in(var f:byte_file):boolean;
  {open a binary file for input}
var @!ok:boolean;
begin
if test_access(read_access_mode,font_file_path) then
    begin reset(f,real_name_of_file); ok:=true @+end
else ok:=false;
b_open_in:=ok;
end;
@#
function b_open_out(var f:byte_file):boolean;
  {open a binary file for output}
var @!ok:boolean;
begin
if test_access(write_access_mode,no_file_path) then
    begin rewrite(f,real_name_of_file); ok:=true @+end
else ok:=false;
b_open_out:=ok;
end;
@#
function w_open_in(var f:word_file):boolean;
  {open a word file for input}
var @!ok:boolean;
begin
if test_access(read_access_mode,format_file_path) then
    begin reset(f,real_name_of_file); ok:=true @+end
else ok:=false;
w_open_in:=ok;
end;
@#
function w_open_out(var f:word_file):boolean;
  {open a word file for output}
var @!ok:boolean;
begin
if test_access(write_access_mode,no_file_path) then
    begin rewrite(f,name_of_file); ok:=true @+end
else ok:=false;
w_open_out:=ok;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.28] file closing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
This makes |f| available to be opened again, if desired; and if |f| was used for
output, the |close| operation makes the corresponding external file appear
on the user's area, ready to be read.

These procedures should not generate error messages if a file is
being closed before it has been successfully opened.

@p procedure a_close(var f:alpha_file); {close a text file}
begin close(f);
end;
@#
procedure b_close(var f:byte_file); {close a binary file}
begin close(f);
end;
@#
procedure w_close(var f:word_file); {close a word file}
begin close(f);
end;
@y
This makes |f| available to be opened again, if desired; and if |f| was used for
output, the |close| operation makes the corresponding external file appear
on the user's area, ready to be read.

With the pc library, files will be automatically closed when the program stops
and when one reopens them.
There is, however, the problem of opening a file and writing it, and then
wanting to read it again, but from a different file variable.
For this purpose we use external procedures |close_a|, |close_b|, and
|close_w|.

@p procedure a_close(var f:alpha_file); {close a text file}
begin close_a(f);
end;
@#
procedure b_close(var f:byte_file); {close a binary file}
begin close_b(f);
end;
@#
procedure w_close(var f:word_file); {close a word file}
begin close_w(f);
end;

@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.31] faster version of input_ln
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
Since the inner loop of |input_ln| is part of \TeX's ``inner loop''---each
character of input comes in at this place---it is wise to reduce system
overhead by making use of special routines that read in an entire array
of characters at once, if such routines are available. The following
code uses standard \PASCAL\ to illustrate what needs to be done, but
finer tuning is often possible at well-developed \PASCAL\ sites.
@^inner loop@>

@p function input_ln(var f:alpha_file;@!bypass_eoln:boolean):boolean;
  {inputs the next line or returns |false|}
var last_nonblank:0..buf_size; {|last| with trailing blanks removed}
begin if bypass_eoln then if not eof(f) then get(f);
  {input the first character of the line into |f^|}
last:=first; {cf.\ Matthew 19\thinspace:\thinspace30}
if eof(f) then input_ln:=false
else  begin last_nonblank:=first;
  while not eoln(f) do
    begin if last>=max_buf_stack then
      begin max_buf_stack:=last+1;
      if max_buf_stack=buf_size then
        @<Report overflow of the input buffer, and abort@>;
      end;
    buffer[last]:=xord[f^]; get(f); incr(last);
    if buffer[last-1]<>" " then last_nonblank:=last;
    end;
  last:=last_nonblank; input_ln:=true;
  end;
end;
@y
Since the inner loop of |input_ln| is part of \TeX's ``inner loop''---each
character of input comes in at this place---it is wise to reduce system
overhead by making use of special routines that read in an entire array
of characters at once.

With Berkeley {\mc UNIX} we call an external C procedure, |line_read|.
That routine fills |buffer| from |first| onwards with the |xord|'ed values
of the next line, setting |last| appropriately.  It will stop if
|last=buf_size|, and the following will cause an ``overflow'' abort.
We ignore the |bypass_eoln| argument, since the |line_read| procedure
will have handled bypassing the end-of-line in its previous call, if
there was one.

If one uses |input_ln| on a file, the normal |read|
and |get| routines shouldn't be used, nor the |eof| and |eoln| tests.
End of file can be tested with the external function |test_eof|.
@^inner loop@>


@p function input_ln(var f:alpha_file;@!bypass_eoln:boolean):boolean;
  {inputs the next line or returns |false|}
label done;
begin
last:=first; {cf.\ Matthew 19\thinspace:\thinspace30}
if test_eof(f) then input_ln:=false
else  begin last:=first;
  line_read(f,buf_size);
  if last>max_buf_stack then begin
    max_buf_stack:=last;
    if max_buf_stack>=buf_size then
        @<Report overflow of the input buffer, and abort@>;
    end;
  loop@+  begin if last=first then goto done;
    if buffer[last-1]<>" " then goto done;
    decr(last);
    end;
done:  input_ln:=true;
  end;
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.32] term_in/out are input,output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The user's terminal acts essentially like other files of text, except
that it is used both for input and for output. When the terminal is
considered an input file, the file variable is called |term_in|, and when it
is considered an output file the file variable is |term_out|.
@^system dependencies@>

@<Glob...@>=
@!term_in:alpha_file; {the terminal as an input file}
@!term_out:alpha_file; {the terminal as an output file}
@y
@ The user's terminal acts essentially like other files of text, except
that it is used both for input and for output. When the terminal is
considered an input file, the file is called |term_in|, and when it
is considered an output file the file is |term_out|.
For Berkeley {\mc UNIX} we use |standard_input| and |output| for these
files, as were declared in the program header.   The former name
|standard_input| was defined using a .{WEB} trick so that `input' is
produced in the Pascal file.

@d term_in==standard_input {the terminal as an input file}
@d term_out==output {the terminal as an output file}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.33] don't need to open terminal files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ Here is how to open the terminal files
in \ph. The `\.{/I}' switch suppresses the first |get|.
@^system dependencies@>

@d t_open_in==reset(term_in,'TTY:','/O/I') {open the terminal for text input}
@d t_open_out==rewrite(term_out,'TTY:','/O') {open the terminal for text output}
@y
@ Here is how to open the terminal files---do nothing.

@d t_open_in == {input already open for text input}
@d t_open_out == {output already open for text output}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.34] flushing output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
these operations can be specified in \ph:
@^system dependencies@>

@d update_terminal == break(term_out) {empty the terminal output buffer}
@d clear_terminal == break_in(term_in,true) {clear the terminal input buffer}
@d wake_up_terminal == do_nothing {cancel the user's cancellation of output}
@y
these operations can be specified with Berkeley {\mc UNIX}:
@^system dependencies@>

@d update_terminal == flush(output)
@d clear_terminal == {nothing necessary on UNIX}
@d wake_up_terminal == {nothing necessary on UNIX}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3.37] rescanning the command line 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The following program does the required initialization
without retrieving a possible command line.
It should be clear how to modify this routine to deal with command lines,
if the system permits them.
@^system dependencies@>

@p function init_terminal:boolean; {gets the terminal input started}
label exit;
begin t_open_in;
loop@+begin wake_up_terminal; write(term_out,'**'); update_terminal;
@.**@>
  if not input_ln(term_in,true) then {this shouldn't happen}
    begin write_ln(term_out);
    write(term_out,'! End of file on the terminal... why?');
@.End of file on the terminal@>
    init_terminal:=false; return;
    end;
  loc:=first;
  while (loc<last)and(buffer[loc]=" ") do incr(loc);
  if loc<last then
    begin init_terminal:=true;
    return; {return unless the line was all blank}
    end;
  write_ln(term_out,'Please type the name of your input file.');
  end;
exit:end;
@y
@ The following program does the required initialization
and also retrieves a possible command line.
@^system dependencies@>

@p
function init_terminal:boolean; {gets the terminal input started}
label exit;

var
    dummy, i, j, k: integer;
    arg: packed array[1..100] of char;

begin
    t_open_in;
    if argc > 1 then begin
        last := first;
        for i := 1 to argc - 1 do begin
	    argv(i, arg);
	    j := 1;
	    k := 100; {find last non-blank char in arg}
	    while (k > 1) and (arg[k] = ' ') do@/
		decr(k);
	    while (j <= k) do begin
	        buffer[last] := xord[arg[j]];
		incr(j); incr(last);
            end;
	    if k > 1 then begin
	        buffer[last] := xord[' '];
	        incr(last);
            end;
	end;
	if last > first then begin
	    loc := first;
            init_terminal := true;
            return;
	end;
    end;
    loop@+begin
        wake_up_terminal; write(term_out, '**'); update_terminal;
@.**@>
        if not input_ln(term_in,true) then begin {this shouldn't happen}
            write_ln(term_out);
            write_ln(term_out, '! End of file on the terminal... why?');
@.End of file on the terminal@>
            init_terminal:=false;
	    return;
        end;

        loc:=first;
        while (loc<last)and(buffer[loc]=" ") do
            incr(loc);

        if loc<last then begin
           init_terminal:=true;
           return; {return unless the line was all blank}
        end;
        write_ln(term_out, 'Please type the name of your input file.');
@.Please type the name...@>
    end;
exit:
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4.38] string data to be offset -128 for packing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d si(#) == # {convert from |ASCII_code| to |packed_ASCII_code|}
@d so(#) == # {convert from |packed_ASCII_code| to |ASCII_code|}

@<Types...@>=
@!pool_pointer = 0..pool_size; {for variables that point into |str_pool|}
@!str_number = 0..max_strings; {for variables that point into |str_start|}
@!packed_ASCII_code = 0..255; {elements of |str_pool| array}
@y
@d si(#) == #-128 {convert from |ASCII_code| to |packed_ASCII_code|}
@d so(#) == #+128 {convert from |packed_ASCII_code| to |ASCII_code|}

@<Types...@>=
@!pool_pointer = 0..pool_size; {for variables that point into |str_pool|}
@!str_number = 0..max_strings; {for variables that point into |str_start|}
@!packed_ASCII_code = -128..127; {elements of |str_pool| array}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4.51] a_open_in of pool file needs path specifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
if a_open_in(pool_file) then
@y
if a_open_in(pool_file,pool_file_path) then
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4.51,52,53] make TEX.POOL lowercase in messages
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
else  bad_pool('! I can''t read TEX.POOL.')
@y
else  bad_pool('! I can''t read tex.pool.')
@z
@x
begin if eof(pool_file) then bad_pool('! TEX.POOL has no check sum.');
@y
begin if eof(pool_file) then bad_pool('! tex.pool has no check sum.');
@z
@x
    bad_pool('! TEX.POOL line doesn''t begin with two digits.');
@y
    bad_pool('! tex.pool line doesn''t begin with two digits.');
@z
@x
  bad_pool('! TEX.POOL check sum doesn''t have nine digits.');
@y
  bad_pool('! tex.pool check sum doesn''t have nine digits.');
@z
@x
done: if a<>@$ then bad_pool('! TEX.POOL doesn''t match; TANGLE me again.');
@y
done: if a<>@$ then bad_pool('! tex.pool doesn''t match; tangle me again.');
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [6.84] switch-to-editor option
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
line ready to be edited. But such an extension requires some system
wizardry, so the present implementation simply types out the name of the
file that should be
edited and the relevant line number.
@^system dependencies@>

There is a secret `\.D' option available when the debugging routines haven't
been commented~out.
@^debugging@>
@y
line ready to be edited.
We do this by calling the external procedure |calledit| with a pointer to
the filename, its length, and the line number.
However, here we just set up the variables that will be used as arguments,
since we don't want to do the switch-to-editor until after \TeX\ has closed
its files.
@^system dependencies@>

There is a secret `\.D' option available when the debugging routines haven't
been commented~out.
@^debugging@>
@d edit_file==input_stack[base_ptr]
@z
@x
"E": if base_ptr>0 then
  begin print_nl("You want to edit file ");
@.You want to edit file x@>
  slow_print(input_stack[base_ptr].name_field);
  print(" at line "); print_int(line);
  interaction:=scroll_mode; jump_out;
@y
"E": if base_ptr>0 then
    begin
    ed_name_start:=str_start[edit_file.name_field];
    ed_name_length:=str_start[edit_file.name_field+1] -
    		      str_start[edit_file.name_field];
    edit_line:=line;
    jump_out;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [7.109] glue_ratio 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!glue_ratio=real; {one-word representation of a glue expansion factor}
@y
@!glue_ratio=shortreal; {one-word representation of a glue expansion factor}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [8.110] ranges for quarter,half words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
if the subrange is `|-128..127|'.

The present implementation tries to accommodate as many variations as possible,
so it makes few assumptions. If integers having the subrange
`|min_quarterword..max_quarterword|' can be packed into a quarterword,
and if integers having the subrange `|min_halfword..max_halfword|'
can be packed into a halfword, everything should work satisfactorily.

It is usually most efficient to have |min_quarterword=min_halfword=0|,
so one should try to achieve this unless it causes a severe problem.
The values defined here are recommended for most 32-bit computers.

@d min_quarterword=0 {smallest allowable value in a |quarterword|}
@d max_quarterword=255 {largest allowable value in a |quarterword|}
@d min_halfword==0 {smallest allowable value in a |halfword|}
@d max_halfword==65535 {largest allowable value in a |halfword|}
@y
if the subrange is `|-128..127|'.

For Berkeley {\mc UNIX} (SunOS) we need to do the |-128..127| kind of range.

@d min_quarterword=-128 {smallest allowable value in a |quarterword|}
@d max_quarterword=127 {largest allowable value in a |quarterword|}
@d min_halfword==-32768 {smallest allowable value in a |halfword|}
@d max_halfword==32767 {largest allowable value in a |halfword|}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [11.165] fix the word "free" so that it doesn't conflict with a runtime proc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
been included. (You may want to decrease the size of |mem| while you
@^debugging@>
are debugging.)
@y
been included. (You may want to decrease the size of |mem| while you
@^debugging@>
are debugging.)

@d free==free_arr
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [12.186] glue_ratio fix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
floating point underflow on the author's computer.
@^system dependencies@>
@^dirty \PASCAL@>

@<Display the value of |glue_set(p)|@>=
g:=float(glue_set(p));
if (g<>float_constant(0))and(glue_sign(p)<>normal) then
  begin print(", glue set ");
  if glue_sign(p)=shrinking then print("- ");
  if abs(mem[p+glue_offset].int)<@'4000000 then print("?.?")
  else if abs(g)>float_constant(20000) then
    begin if g>float_constant(0) then print_char(">")
    else print("< -");
    print_glue(20000*unity,glue_order(p),0);
    end
  else print_glue(round(unity*g),glue_order(p),0);
@^real multiplication@>
  end
@y
floating point underflow on the author's computer.
For the {\mc VAX}, the only possible random value that could hurt is
a reserved value with 1 in the sign bit and 0 for the (excess) exponent.
Because the sign-plus-exponent is in the middle of the word, the chances
of this happening are miniscule, and ignored here.
@^system dependencies@>
@^dirty \PASCAL@>

@<Display the value of |glue_set(p)|@>=
g:=float(glue_set(p));
if (g<>float_constant(0))and(glue_sign(p)<>normal) then
  begin print(", glue set ");
  if glue_sign(p)=shrinking then print("- ");
  if abs(float(glue_set(p)))>20000.0 then
     begin if float(glue_set(p))>0 then print_char(">")
     else print("< -");
     print_glue(20000*unity,glue_order(p),0);
     end
  else print_glue(round(float(glue_set(p))*unity),glue_order(p),0);
@^real multiplication@>
  end
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [17.241] fix_date_and_time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The following procedure, which is called just before \TeX\ initializes its
input and output, establishes the initial values of the date and time.
@^system dependencies@>
Since standard \PASCAL\ cannot provide such information, something special
is needed. The program here simply specifies July 4, 1776, at noon; but
users probably want a better approximation to the truth.

@p procedure fix_date_and_time;
begin time:=12*60; {minutes since midnight}
day:=4; {fourth day of the month}
month:=7; {seventh month of the year}
year:=1776; {Anno Domini}
end;
@y
@ The following procedure, which is called just before \TeX\ initializes its
input and output, establishes the initial values of the date and time.
It is calls an externally defined |date_and_time|, even though it could
be done from Pascal.
The external procedure also sets up interrupt catching.
@^system dependencies@>

@p procedure fix_date_and_time;
begin
    date_and_time(time,day,month,year);
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.513] area and extension rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ The file names we shall deal with for illustrative purposes have the
following structure:  If the name contains `\.>' or `\.:', the file area
consists of all characters up to and including the final such character;
otherwise the file area is null.  If the remaining file name contains
`\..', the file extension consists of all such characters from the first
remaining `\..' to the end, otherwise the file extension is null.
@^system dependencies@>

We can scan such file names easily by using two global variables that keep track
of the occurrences of area and extension delimiters:

@<Glob...@>=
@!area_delimiter:pool_pointer; {the most recent `\.>' or `\.:', if any}
@!ext_delimiter:pool_pointer; {the relevant `\..', if any}
@y
@ The file names we shall deal with for SunOS have the
following structure:  If the name contains `\./', the file area
consists of all characters up to and including the final such character;
otherwise the file area is null.  If the remaining file name contains
`\..', the file extension consists of all such characters from the first
remaining `\..' to the end, otherwise the file extension is null.
@^system dependencies@>

We can scan such file names easily by using two global variables that keep
track of the occurrences of area and extension delimiters:

@<Glob...@>=
@!area_delimiter:pool_pointer; {the most recent `\./', if any}
@!ext_delimiter:pool_pointer; {the most recent `\..', if any}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.514] TeX area directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d TEX_area=="TeXinputs:"
@.TeXinputs@>
@d TEX_font_area=="TeXfonts:"
@.TeXfonts@>
@y
Under Berkeley {\mc UNIX}, the default paths are specified in a separate
file, `\.{texpaths.h}'.  The file opening procedures do path searching
based either on those default paths, or on paths given by the user
in ``environment'' variables.
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.516] more_name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
  if (c=">")or(c=":") then
@y
  if c="/" then
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.520] default format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d format_default_length=20 {length of the |TEX_format_default| string}
@d format_area_length=11 {length of its area part}
@d format_ext_length=4 {length of its `\.{.fmt}' part}
@y
Under Berkeley {\mc UNIX} we don't give the area part, instead depending
on the path searching that will happen during file opening.

@d format_default_length=9 {length of the |TEX_format_default| string}
@d format_area_length=0 {length of its area part}
@d format_ext_length=4 {length of its `\.{.fmt}' part}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.521] plain format location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
TEX_format_default:='TeXformats:plain.fmt';
@y
TEX_format_default:='plain.fmt';
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.524] format file opening: only try once, with path search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
  pack_buffered_name(0,loc,j-1); {try first without the system file area}
  if w_open_in(fmt_file) then goto found;
  pack_buffered_name(format_area_length,loc,j-1);
    {now try the system format file area}
  if w_open_in(fmt_file) then goto found;
@y
  pack_buffered_name(0,loc,j-1);
  if w_open_in(fmt_file) then goto found;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.525] make_name_string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
which simply makes a \TeX\ string from the value of |name_of_file|, should
ideally be changed to deduce the full name of file~|f|, which is the file
most recently opened, if it is possible to do this in a \PASCAL\ program.
@^system dependencies@>

This routine might be called after string memory has overflowed, hence
we dare not use `|str_room|'.

@p function make_name_string:str_number;
var k:1..file_name_size; {index into |name_of_file|}
begin if (pool_ptr+name_length>pool_size)or(str_ptr=max_strings)or
 (cur_length>0) then
  make_name_string:="?"
else  begin for k:=1 to name_length do append_char(xord[name_of_file[k]]);
  make_name_string:=make_string;
  end;
end;
@y
which simply makes a \TeX\ string from the value of |name_of_file|, should
ideally be changed to deduce the full name of file~|f|, which is the file
most recently opened, if it is possible to do this in a \PASCAL\ program.
With the Berkeley {\mc UNIX} version, we know that |real_name_of_file|
contains |name_of_file| prepended with the directory name that was found
by path searching.
If |real_name_of_file| starts with |'./'|, we don't use that part of the
name, since {\mc UNIX} users understand that.
@^system dependencies@>

This routine might be called after string memory has overflowed, hence
we dare not use `|str_room|'.

@p function make_name_string:str_number;
var k,@!kstart:1..file_name_size; {index into |name_of_file|}
begin
k:=1;
while (k<file_name_size) and (xord[real_name_of_file[k]]<>" ") do
    incr(k);
name_length:=k-1; {the real |name_length|}
if (pool_ptr+name_length>pool_size)or(str_ptr=max_strings)or
 (cur_length>0) then
  make_name_string:="?"
else begin
  if (xord[real_name_of_file[1]]=".") and (xord[real_name_of_file[2]]="/") then
      kstart:=3
  else
      kstart:=1;
  for k:=kstart to name_length do append_char(xord[real_name_of_file[k]]);
  make_name_string:=make_string;
  end
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.537] a_open_in of \input file needs path selector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
  if a_open_in(cur_file) then goto done;
  if cur_area="" then
    begin pack_file_name(cur_name,TEX_area,cur_ext);
    if a_open_in(cur_file) then goto done;
    end;
@y
  if a_open_in(cur_file,input_file_path) then goto done;
  if cur_ext=".tex" then
    begin pack_file_name(cur_name,cur_area,"");
    if a_open_in(cur_file,input_file_path) then goto done;
    end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [29.537] get rid of return of name to string pool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
if name=str_ptr-1 then {we can conserve string pool space now}
  begin flush_string; name:=cur_name;
  end;
@y
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [30.557] optimize kern_base_offset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d kern_base_offset==256*(128+min_quarterword)
@y
@d kern_base_offset==0 {our |kern_flag| is zero}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [30.563] opening tfm file: now path searching is done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set temp_int to value of first byte
@x
@ @<Open |tfm_file| for input@>=
file_opened:=false;
if aire="" then pack_file_name(nom,TEX_font_area,".tfm")
else pack_file_name(nom,aire,".tfm");
if not b_open_in(tfm_file) then abort;
file_opened:=true
@y
@ Here we have to ``prime the pump'' for the |temp_int| trick explained below.

 @<Open |tfm_file| for input@>=
file_opened:=false;
pack_file_name(nom,aire,".tfm");
if not b_open_in(tfm_file) then abort;
begin  temp_int:=tfm_file^;
      if temp_int<0 then temp_int:=temp_int+256;
end;
file_opened:=true
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [30.564] reading the tfm file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d fget==get(tfm_file)
@d fbyte==tfm_file^
@y
For Berkeley {\mc UNIX} we had to make the |byte_file| type have data in the
range |-128..127|.
If the file byte contains |@'377|, we want to regard this as 255 in decimal.
However if we do |i:=tfm_file^| on that byte, where i is a signed integer,
then the result is |i=-1|.
File bytes with values |<@'200| are read properly.
The solution is to do the assignment as shown, and then add 256 to values
less than 0.
We could also assign to |eight_bits| values, but this causes an error if
runtime checking is turned on.
The integer |temp_int| will be added to global variables at the end,
where it won't disturb module numbering.

@d fget==begin get(tfm_file);
		temp_int:=tfm_file^;
		if temp_int<0 then temp_int:=temp_int+256;
		end
@d fbyte==temp_int
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [32.597] write_dvi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure write_dvi(@!a,@!b:dvi_index);
var k:dvi_index;
begin for k:=a to b do write(dvi_file,dvi_buf[k]);
end;
@y
For Berkeley {\mc UNIX}, this is going to be handled by an external procedure,
|writedvi|, which will do the output using |fwrite|.
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [49.1275] a_open_in of \read file needs path specifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
  if a_open_in(read_file[n]) then read_open[n]:=just_open;
@y
  if a_open_in(read_file[n],read_file_path) then read_open[n]:=just_open;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [51.1332] Delete ready_already; also add call to set_paths;
%	    also add call to exit() depending upon value of `history'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@ Now this is really it: \TeX\ starts and ends here.

The initial test involving |ready_already| should be deleted if the
\PASCAL\ runtime system is smart enough to detect such a ``mistake.''
@y
@ Now this is really it: \TeX\ starts and ends here.

Instead of testing |ready_already|, we give up the idea of a preloaded
core image in favor of silently loading a format file based on the
name by which this program has been invoked. For example, if the
program is being called \.{tex}, we will load \.{plain} format;
if \.{latex}, we will load \.{latex} format. On my machine the
loading of a format isn't too slow. (I use the new string capabilities
of Sun Pascal here; |my_name| will be declared {\bf varying} [100]
{\bf of\/} |char|.)

At the end of the job, we look at |history| to decide the correct
exit code.  We use 1 if |history <= warning_issued| and 0 otherwise.

@d UNIXexit==e@&x@&i@&t
@z

@x
t_open_out; {open the terminal for output}
if ready_already=314159 then goto start_of_TEX;
@y
t_open_out; {open the terminal for output}
set_paths;
@z

@x
start_of_TEX: @<Initialize the output routines@>;
@y
start_of_TEX: argv(0,my_name);
if (my_name<>'initex')and(my_name<>'triptex') then
  begin if my_name = 'tex' then name_of_file:='plain.fmt'
  else name_of_file:=my_name+'.fmt';
  if w_open_in(fmt_file) then
    if not load_fmt_file then
      begin w_close(fmt_file); goto final_end;
      end
    else w_close(fmt_file);
  end;
@<Initialize the output routines@>;
@z

@x
final_end: ready_already:=0;
@y
final_end: ready_already:=0;
if (history <= warning_issued) then
    UNIXexit(0)
else
    UNIXexit(1);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [51.1333] print new line before termination; switch to editor if nec.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
    slow_print(log_name); print_char(".");
    end;
  end;
@y
    slow_print(log_name); print_char(".");
    end;
  end;
print_ln;
if (ed_name_start<>0) and (interaction>batch_mode) then
    calledit(str_pool[ed_name_start],ed_name_length,edit_line);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [54.1376] add temp_int and editor-switch variables to globals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* \[54] System-dependent changes.
This section should be replaced, if necessary, by any special
modifications of the program
that are necessary to make \TeX\ work at a particular installation.
It is usually best to design your change file so that all changes to
previous sections preserve the section numbering; then everybody's version
will be consistent with the published program. More extensive changes,
which introduce new sections, can be inserted here; then only the index
itself will get a new section number.
@^system dependencies@>
@y
@* \[54] System-dependent changes.
Here is a temporary integer, used as a holder during reading and writing of
TFM files.
Also, the variable used omphaloskeptically.
Also, the variables that holds ``switch-to-editor'' information.
@^system dependencies@>

@f varying == array

@<Global...@>=
@!temp_int:integer;
@!my_name:varying [100] of char;
@!ed_name_start: pool_pointer;
@!ed_name_length,@!edit_line: integer;

@ The |ed_name_start| will be set to point into |str_pool| somewhere after
its beginning if \TeX\ is supposed to switch to an editor on exit.

@<Set init...@>=
ed_name_start:=0;
    
@z
