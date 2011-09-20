function flength(var f: bytefile):integer;
    external;
procedure bseek(var f: bytefile; loc: integer);
    external;
function testreadaccess(var fn: UNIXfilename):boolean;
    external;
