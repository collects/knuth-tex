argc:asmname '_p_argc' Integer;

procedure argv(no:Integer;var str:UNIXfilename); external;

procedure flushstdout; external;

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
 
