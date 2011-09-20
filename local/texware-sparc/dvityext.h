procedure setpaths;
    external;

function testaccess(accessmode:integer; filepath:integer): boolean;
    external;

function flength(var f: bytefile):integer;
    external;

procedure bseek(var f: bytefile; loc: integer);
    external;
