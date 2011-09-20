argc:asmname '_p_argc' Integer;

procedure argv(no:Integer;var str:UNIXfilename); external;

function testreadaccess(var a:UNIXfilename):boolean; external;

procedure setpaths; external;

function testaccess(accessmode:integer; filepath:integer): boolean; external;

function flength(var f: bytefile):integer; external;

procedure bseek(var f: bytefile; loc: integer); external;

procedure flushstdout; external;

procedure readbyte(var f: bytefile; var v: ByteCard); external;
