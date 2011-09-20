procedure exit(x : integer);
 external;
procedure lineread(var f:textfile);
 external;
procedure linewrite(var f:textfile; cnt:integer);
 external;
function testeof(var f:textfile):boolean;
 external;
(* now, some routines to implement paths for file names.  These are borrowed
   from Howard Trickey's dvitype *)
procedure setpaths;
    external;
function testaccess(accessmode:integer; filepath:integer): boolean;
    external;
function testreadaccess(var f:UNIXfilename):boolean;
    external;
