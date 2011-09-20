procedure exit(x : integer);
 external;

procedure closea(var f:text);
 external;

procedure closeb(var f:bytefile);
 external;

procedure closew(var f:wordfile);
 external;

procedure dateandtime(var minutes, day, month, year : integer);
    external;

procedure setpaths;
    external;

function testaccess(accessmode:integer; filepath:integer): boolean;
    external;

function testeof(var f: text): boolean;
    external;
 
procedure lineread(var f: text; lastlim: integer);
    external;

procedure writegf(a,b:integer);
    external;

procedure calledit(var filename: packedASCIIcode; fnlength, linenumber: integer);
    external;

function makefraction(p,q:integer):fraction;
    external;

function takefraction(q:integer;f:fraction):integer;
    external;
