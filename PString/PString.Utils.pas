unit PString.Utils;

interface

const
//  DigitChars = ['0'..'9'];
  Brackets = ['(',')','[',']','{','}'];
  StdWordDelims = [#0..' ',',','.',';','/','\',':','''','"','`'] + Brackets;

Type
  TCharSet = Set of Char;

  // http://delphidabbler.com/tips/234
  function StringToCharSet(const Txt: AnsiString): TCharSet;
  Function CharSetToString(const Chars: TCharSet): AnsiString;

  // from FPC sysutils.pas
  function StrToIntDef(const S: string; Default: Longint): Longint;


implementation


function StringToCharSet(const Txt: AnsiString): TCharSet;
var
  CP: PChar;
begin
  StringToCharSet := [];
  if Txt = '' then
    Exit;
  CP := PChar(Txt);
  while CP^ <> #0 do 
  begin
    Include(StringToCharSet, CP^);
    Inc(CP);
  end;
end;
 
function CharSetToString(const Chars: TCharSet): AnsiString;
var
  I: Integer;
begin
  CharSetToString := '';
  for I := 0 to 255 do
    if Chr(I) in Chars then
      CharSetToString := CharSetToString + Chr(I);
end;

{   StrToIntDef converts the string S to an integer value,
    Default is returned in case S does not represent a valid integer value  }

function StrToIntDef(const S: string; Default: Longint): Longint;
var 
  Error: word;
begin
  Val(S, StrToIntDef, Error);
  if Error <> 0 then StrToIntDef := Default;
end;

end.
