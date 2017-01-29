program example1;

uses
  NewArgs, StrUtils;

const
  template  = 'NAME,TARGET/M,LIST/S,EXISTS/S,DISMOUNT/S,DEFER/S,PATH/S,ADD/S,REMOVE/S,VOLS/S,DIRS/S,DEVICES/S';
  arguments = 'flipper c:\drumrole d:\knuth defer';
var
  i           : integer;
  TempArgName : string;
begin
  if ParseArgs(template, arguments) = NARGS_ERR_NO_ERROR then
  begin
    for i := 0 to Pred(ArgCount) do
    begin
      TempArgName := ExtractWord(Succ(i), template, [','] );
      TempArgName := ExtractWord(1, TempArgName, ['/'] );
      
      WriteLn('argument ', '[', i:2, ']', '  ', '(' , TempArgName:10, ')', ' = ', '"', ArgStr(i), '"');
    end;
  end
  else
    WriteLn('Error parsing arguments');
end.
