unit phelpers;

{$MODE OBJFPC}{$H+}

{
  FPC: quick mock-up for using additional Pascal units, collected inside here
}

interface

uses
  SysUtils, StrUtils;

var
  FormatSettings : TFormatSettings absolute SysUtils.FormatSettings;
var
  WordCount     : function (const S: string; const WordDelims: TSysCharSet): Integer;                = @StrUtils.WordCount;
  ExtractWord   : function (N: Integer; const S: string;  const WordDelims: TSysCharSet): string;    = @StrUtils.ExtractWord;
  StringReplace : Function (const S, OldPattern, NewPattern: string;  Flags: TReplaceFlags): string; = @SysUtils.StringReplace;
  StrToFloat    : Function (Const S: String): Extended;                                              = @SysUtils.StrToFloat;

implementation

end.
