unit pml.lformat.utils;

{$H+}

interface


  function TryStrToInt(const s: string; var i : Longint) : boolean;


implementation


function TryStrToInt(const s: string; var i : Longint) : boolean;
var Error : word;
begin
  Val(s, i, Error);
  TryStrToInt:=Error=0
end;


end.