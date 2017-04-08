program hunktest;

uses
  SysUtils, amiga.hunk;


{$IFDEF AMIGA}
procedure AmigaPlay2;
var
  Name: String;
begin
  WriteLn('function AmigaPlay2() @ : $', HexStr(@AmigaPlay2));
  Name := HunkSymbols.GetSymbolName(@AmigaPlay2);
  WriteLn('symbol = ', Name);
end;

procedure AmigaPlay1;
var
  Name: String;
begin
  WriteLn('function AmigaPlay1() @ : $', HexStr(@AmigaPlay1));
  Name := HunkSymbols.GetSymbolName(@AmigaPlay1);
  WriteLn('symbol = ', Name);
end;
{$ENDIF}


var
  fn: AnsiString = '';

begin
  WriteLn('HunkTest');

  if paramcount = 1 
  then fn := ParamStr(1);

  // load the symbols from given filename
  if fn <> '' then
  begin
    if FileExists(fn) then
    begin
      HunkSymbols.LoadFromFile(fn);
      HunkSymbols.SaveInfoToFile(fn + '.symbols');
    end
    else WriteLn('error: file does not exist');
  end
  else
  begin
    {$IFDEF AMIGA}
    // When compiled for Amiga, the amiga.hunk unit automatically loads
    // this executables hunk information using global HunkSymbols
    // variable and also gathers segment information from its process.
    // This allows for looking up symbols that are part of this executable.
    WriteLn;
    AmigaPlay1;
    AmigaPlay2;
    {$ELSE}
    WriteLn('error: no amiga hunk file (executable) name supplied');
    {$ENDIF}
  end;  
end.
