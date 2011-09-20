procedure exit(x : integer);
 external;
procedure lineread(var f:textfile);
 external;
procedure linewrite(var f:textfile; cnt:integer);
 external;
function testeof(var f:textfile):boolean;
 external;
