argc:asmname '_p_argc' Integer;

procedure argv(no:Integer;var str:UNIXfilename); external;

function testreadaccess(var a:UNIXfilename):boolean; external;
