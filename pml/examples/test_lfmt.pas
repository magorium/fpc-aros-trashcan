program test_lfmt;

{$MODE OBJFPC}{$H+}

uses
  pml.lformat, Sysutils;


function DQuotedStr(S: AnsiString): AnsiString;
begin
  Result := AnsiQuotedStr(S,'"');
end;

var
  Settings: Array[0..9] of TLFormatParameter =
  (
    ( fmtChar: 'A'; fmtValue: 'Archibald'),
    ( fmtChar: 'B'; fmtValue: 'Bello'),
    ( fmtChar: 'C'; fmtValue: 'Cornelius'),
    ( fmtChar: 'D'; fmtValue: 'Dombo'),
    ( fmtChar: 'E'; fmtValue: 'Eduardo'),
    ( fmtChar: 'F'; fmtValue: 'Fitzgerald'),
    ( fmtChar: 'G'; fmtValue: 'Gerard'),
    ( fmtChar: 'H'; fmtValue: 'Harold'),
    ( fmtChar: 'I'; fmtValue: 'Isaac'),
    ( fmtChar: 'Z'; fmtValue: '10')
  );
  fmtString1 : AnsiString = 'hello %A%B%C';
  fmtString2 : AnsiString = 'hello %%%X%C';
  fmtString3 : AnsiString = 'hello %-24.5A%X%C';
  fmtString4 : AnsiString = 'hello %.5.6.7A%X%C';
  fmtString5 : AnsiString = '12345 [%10.5A] -- >%-4Z<';


begin
  WriteLn( DQuotedStr(fmtString1), '  =>  ', DQuotedStr( LFormat(fmtString1, Settings) ) );
  WriteLn( DQuotedStr(fmtString2), '  =>  ', DQuotedStr( LFormat(fmtString2, Settings) ) );
  WriteLn( DQuotedStr(fmtString3), '  =>  ', DQuotedStr( LFormat(fmtString3, Settings) ) );
  WriteLn( DQuotedStr(fmtString4), '  =>  ', DQuotedStr( LFormat(fmtString4, Settings) ) );
  WriteLn( DQuotedStr(fmtString5), '  =>  ', DQuotedStr( LFormat(fmtString5, Settings) ) );
end.
