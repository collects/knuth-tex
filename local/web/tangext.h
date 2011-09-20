argc:asmname '_p_argc' Integer;

procedure argv(no:Integer;var str:UNIXfilename); external;

procedure flushstdout; external;

procedure exit(x : integer); external;

procedure lineread(var f:text); external;

procedure linewrite(var f:text; cnt:integer); external;

function testeof(var f:text):boolean; external;
