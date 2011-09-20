% $Header: gftopk.ch,v 1.4  87/12/05  10:40:15  mackay Released $

%   Change file for the GFtoPK processor, for use on Berkeley UNIX systems.

% History:
%
% don upped max_rows on 90/8/30
% don upgraded to version 2.3 on 90/8/6
% don upgraded to version 2.2 on 89/11/21
%
% don made changes for version 2 and SunOS on 89/8/12
% (I simplified things by borrowing from texware change files)
%
% $Log:	gftopk.ch,v $
% Revision 1.4  87/12/05  10:40:15  mackay
% Released for GFtoPK 1.4;
% 
% Revision 1.3  86/12/08  20:20:15  mackay
% Released for GFtoPK 1.3;
% 
% Revision 1.2  86/02/01  14:45:21  richards
% Released for GFtoPK 1.2;
% 
% 
% Revision 1.1  86/01/30  19:56:05  richards
% Initial revision
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [0] WEAVE: print changes only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
\pageno=\contentspagenumber \advance\pageno by 1
@y
\pageno=\contentspagenumber \advance\pageno by 1
\let\maybe=\iffalse
\def\title{GF\lowercase{to}PK changes for Berkeley {\mc UNIX}}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] Change banner string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d banner=='This is GFtoPK, Version 2.3' {printed when the program starts}
@y
@d banner=='This is GFtoPK, Version 2.3 for SunOS'
                                         {printed when the program starts}
@z
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [3] Fix others:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d othercases == others: {default for cases not listed explicitly}
@y
@d othercases == otherwise {SunOS Pascal default cases}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [4] Redefine program header, eliminate gf_file and pxl_file
%	add <Parse command line> section to initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p program GFtoPK(@!gf_file,@!pk_file,@!output);
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
@p program GFtoPK(@!input,@!output);
label @<Labels in the outer block@>@/
const @<Constants in the outer block@>@/
type @<Types in the outer block@>@/
var @<Globals in the outer block@>@/
@\@=#include "gftopk_ext.h"@>@\
procedure initialize; {this procedure gets things started properly}
  var i:integer; {loop index for initializations}
  begin print_ln(banner);@/
  @<Set initial values@>;@/
  @<Parse command line arguments@>@/
  end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [6] add file_name_size to constants in the outer block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!line_length=79; {bracketed lines of output will be at most this long}
@!max_row=16000; {largest index in the main |row| array}
@y
@!line_length=79; {bracketed lines of output will be at most this long}
@!max_row=60000; {largest index in the main |row| array}
@!file_name_size=256; {maximum length of a file name}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [8] have abort() add <nl> to end of message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@d abort(#)==begin print(' ',#); jump_out;
@y
@d abort(#)==begin print_ln(' ',#); jump_out;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [37] Add UNIX_file_name type, redefine byte_file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!eight_bits=0..255; {unsigned one-byte quantity}
@!byte_file=packed file of eight_bits; {files that contain binary data}
@y
@!eight_bits=0..255; {unsigned one-byte quantity}
@!UNIX_file_name=packed array [1..file_name_size] of char;
@!byte_file=packed file of -128..127;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [38] add gf_name and pk_name to global vars
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@!gf_file:byte_file; {the stuff we are \.{GFtoPK}ing}
@!pk_file:byte_file; {the stuff we have \.{GFtoPK}ed}
@y
@!gf_file:byte_file; {the stuff we are \.{GFtoPK}ing}
@!gf_name: UNIX_file_name; {the name of |gf_file|}
@!pk_file:byte_file; {the stuff we have \.{GFtoPK}ed}
@!pk_name: UNIX_file_name; {the name of |pk_file|}
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [39] open_gf_file with extended reset command (can dump core!)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
begin reset(gf_file);
@y
begin if testreadaccess(gf_name) then reset(gf_file,gf_name)
else abort('Can''t open the GF file');
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [40] and open_pk_file...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
begin rewrite(pk_file);
@y
var j,k,size:integer; startednumber:boolean;
begin
if argc < 3 then begin@/
    @<Generate |pk_name| from |gf_name| and |h_mag|@>@/
    end;
rewrite(pk_file,pk_name);
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [43] replace gf_byte and gf_signed_quad
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p function gf_byte:integer; {returns the next byte, unsigned}
var b:eight_bits;
begin if eof(gf_file) then bad_gf('Unexpected end of file!')
@.Unexpected end of file@>
else  begin read(gf_file,b); gf_byte:=b;
  end;
incr(gf_loc);
end;
@#
function gf_signed_quad:integer; {returns the next four bytes, signed}
var a,@!b,@!c,@!d:eight_bits;
begin read(gf_file,a); read(gf_file,b); read(gf_file,c); read(gf_file,d);
if a<128 then gf_signed_quad:=((a*256+b)*256+c)*256+d
else gf_signed_quad:=(((a-256)*256+b)*256+c)*256+d;
gf_loc := gf_loc + 4 ;
end;
@y
@p function gf_byte:integer; {returns the next byte, unsigned}
var b:-128..127;
begin if eof(gf_file) then bad_gf('Unexpected end of file!')
else  begin read(gf_file,b);
            if b < 0 then gf_byte := b + 256 else gf_byte:=b;
  end;
incr(gf_loc);
end;
@#
function gf_signed_quad:integer; {returns the next four bytes, signed}
var a,@!b,@!c,@!d:integer;
begin read(gf_file,a); b := gf_byte; c := gf_byte; d := gf_byte;
gf_signed_quad:=((a*256+b)*256+c)*256+d
end;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [44] redefine pk_byte, pk_halfword, pk_three_bytes, and pk_word
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure pk_byte(a:integer) ;
begin
   if pk_open then begin
      if a < 0 then a := a + 256 ;
      write(pk_file, a) ;
      incr(pk_loc) ;
   end ;
end ;
@#
procedure pk_halfword(a:integer) ;
begin
   if a < 0 then a := a + 65536 ;
   write(pk_file, a div 256) ;
   write(pk_file, a mod 256) ;
   pk_loc := pk_loc + 2 ;
end ;
@#
procedure pk_three_bytes(a:integer);
begin
   write(pk_file, a div 65536 mod 256) ;
   write(pk_file, a div 256 mod 256) ;
   write(pk_file, a mod 256) ;
   pk_loc := pk_loc + 3 ;
end ;
@#
procedure pk_word(a:integer) ;
var b : integer ;
begin
   if pk_open then begin
      if a < 0 then begin
         a := a + @'10000000000 ;
         a := a + @'10000000000 ;
         b := 128 + a div 16777216 ;
      end else b := a div 16777216 ;
      write(pk_file, b) ;
      write(pk_file, a div 65536 mod 256) ;
      write(pk_file, a div 256 mod 256) ;
      write(pk_file, a mod 256) ;
      pk_loc := pk_loc + 4 ;
   end ;
end ;
@y
@p procedure pk_byte(a:integer) ;
begin
   if pk_open then begin
      if a < 0 then a := a + 256 ;
      if a > 127 then a := a-256;
      write(pk_file, a) ;
      incr(pk_loc) ;
   end ;
end ;
@#
procedure pk_halfword(a:integer) ;
begin
   if a < 0 then a := a + 65536 ;
 pk_byte(a div 256); pk_byte(a mod 256);
end ;
@#
procedure pk_three_bytes(a:integer);
begin
 pk_byte(a div 65536 mod 256) ;
 pk_byte(a div 256 mod 256) ;
 pk_byte(a mod 256) ;
 end ;
@#
procedure pk_word(a:integer) ;
var b : integer ;
begin
       if a < 0 then begin
         a := a + @'10000000000 ;
         a := a + @'10000000000 ;
         b := 128 + a div 16777216 ;
      end else b := a div 16777216 ;
      pk_byte(b) ;
      pk_byte(a div 65536 mod 256) ;
      pk_byte(a div 256 mod 256) ;
      pk_byte(a mod 256) ;
 end ;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [46] redefine find_gf_length and move_to_byte
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@p procedure find_gf_length ;
begin
   set_pos(gf_file, -1) ; gf_len := cur_pos(gf_file) ;
end ;
@#
procedure move_to_byte(@!n : integer) ;
begin
   set_pos(gf_file, n); gf_loc := n ;
end ;
@y
@p procedure find_gf_length ;
begin
   gf_len := flength(gf_file);
end ;
@#
procedure move_to_byte(@!n : integer) ;
begin
   b_seek(gf_file, n); gf_loc := n ;
end ;
@z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [88+] add <Parse command line arguments> section and needed subsections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
@x
@* System-dependent changes.
This section should be replaced, if necessary, by changes to the program
that are necessary to make \.{GFtoPK} work at a particular installation.
It is usually best to design your change file so that all changes to
previous sections preserve the section numbering; then everybody's version
will be consistent with the printed program. More extensive changes,
which introduce new sections, can be inserted here; then only the index
itself will get a new section number.
@^system dependencies@>
@y
@* System-dependent changes.
This section contains additions needed to make \.{GFtoPK} work under
{\mc UNIX}.  The additions all deal with obtaining file names from
the invoking command line and if not all arguments are provided,
devising defaults for them.
@^system dependencies@>

@<Parse command line arguments@>=
if (argc < 2) or (argc > 3) then begin@/
    write_ln('Usage: gftopk GF-file [PK-file]');@/
    goto final_end;@/
    end;
argv(1, gf_name);@/
if (argc > 2) then@/
   argv(2, pk_name);@/

@ Here's a section to construct |pk_name| from |gf_name|, tacking on the
right extension from the magnification of the file.

@<Generate |pk_name| ...@>=
j:=file_name_size;@/
while (j > 1) and (gf_name[j] <> '/') do@/
   decr(j);
i:=j;
while (j > 1) do begin@/
   decr(j); pk_name[j] := gf_name[j];
 end;
while (i < file_name_size) and (gf_name[i] <> '.') and (gf_name[i] <> ' ') do begin@/
   pk_name[i] := gf_name[i];@/
   incr(i);@/
   end;
pk_name[i]:='.'; incr(i);@/
size:=h_mag;@/
j :=10000;@/
startednumber:=false;@/
while (j > 0) do begin@/
   k:=size div j;@/
   size := size mod j;@/
   j:=j div 10;
   if startednumber or (k <> 0) or (j = 0) then begin@/
      pk_name[i] := chr(ord('0') + k); incr(i);@/
      startednumber := true;@/
      end;@/
   end;@/
pk_name[i] := 'p'; incr(i);@/
pk_name[i] := 'k'; incr(i);@/
pk_name[i] := ' ';@/
print_ln('[Output file named ''', pk_name:i-1, ''']');@/

@z

