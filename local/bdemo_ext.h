{names of external C routines to include in GNU Pascal binarydemo program}

function argv(no:Integer;var str:UNIXfilename):boolean; external;

procedure bread(var a:bytefile; var x:byte); external;

function testeof(var f:bytefile):boolean; external;

function testreadaccess(var a:UNIXfilename):boolean; external;

function testwriteaccess(var a:UNIXfilename):boolean; external;

function flength(var f:bytefile):integer; external;

procedure movetobyte(var f:bytefile; n:integer); external;
