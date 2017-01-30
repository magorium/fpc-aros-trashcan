program PString;

{
  Commandline tool to extract information from given string.
  Can also use input stream
}

{$MODE OBJFPC}{$H+}

Uses
  {$IFDEF HASAMIGA}AmigaDos,{$ENDIF} NewArgs, NewArgs.Utils, PString.Utils;


procedure PrintHelp;
begin
  WriteLn('PString (experimental) by magorium');
  WriteLn;
  WriteLn('Usage: PString command <parameter(s)>');
  WriteLn;
  WriteLn('Where command can be one of the following:');
  WriteLn;
  WriteLn('EXTRACTWORD/A   N=NUMBER/K/N,S=STRING/K,D=DELIMS/K');
  WriteLn('?=HELP/A');
  WriteLn;
end;


procedure HandleExtractWord;
Var
  p_wordNumber   : Integer;
  p_SearchString : AnsiString;
  s_Delims       : AnsiString;
  p_Delims       : set of char;
  res            : AnsiString;
begin
  // by default if no parameters are given defaults to
  // 1 for the word number
  // 2 an empty string to search in
  // 3 default set of delimiters

  if ArgStr(1) = '' 
  then p_wordNumber := 1
  else p_wordNumber := StrToIntDef(ArgStr(1), 1);
  
  if ArgStr(2) = ''  then
  begin
    ReadLn(p_SearchString);
  end
  else p_SearchString := ArgStr(2);

  if ArgStr(3) = ''
  then p_Delims := StdWordDelims
  else 
  begin
    s_Delims := ArgStr(3);
    p_Delims := StringToCharSet(s_Delims);
  end;
  // actually execute the command
  res := ExtractWord(p_WordNumber, p_SearchString, p_Delims);
  // write result to standard output
  WriteLn(res);
end;


{$IFDEF WINDOWS}
   function GetCommandLine : PChar; stdcall; external 'kernel32' name 'GetCommandLineA';
{$ENDIF}

{$IFDEF WINDOWS}
Function GetSystemCommandLine: AnsiString;
var
  n: integer;
  retval : string;
begin
  RetVal := GetCommandLine;
  { WARNING this will not work if exe name contains a space }
  n := pos(' ', Retval);
  Delete(Retval, 1, n);
  GetSystemCommandLine := RetVal;
end;
{$ENDIF}

{$IFDEF HASAMIGA}
Function GetSystemCommandLine: AnsiString;
var
  Args   : PChar;
begin
  Args := GetArgStr; 
  GetSystemCommandLine := Args;
end;
{$ENDIF}

Const
  Templates : Array[0..1] of string =
  (
    'COMMAND/A',                                      // 0 = help
    'COMMAND/A,N=NUMBER/K/N,S=STRING/K,D=DELIMS/K'    // 1 = extractword, keywords required
  );

  
Var
  CommandStr : AnsiString;
  CommandNr  : Integer;  
  S          : AnsiString;

begin
  if ParamCount = 0 
  then CommandStr := ''
  else CommandStr := ParamStr(1);

  case UpCase(CommandStr) of
    'HELP', '-HELP', '/HELP',
    'H', '-H', '/H',
    '?', '-?', '/?' : CommandNr := 0;
    'EXTRACTWORD'   : CommandNr := 1;
     else CommandNr := 0;
  end;

  if CommandNr = 0 then
  begin
    PrintHelp;
    exit;
  end
  else
  begin
    S := GetSystemCommandLine;
//    WriteLn('params = ', S);
    if ( ParseArgs(Templates[CommandNr], S) = NARGS_ERR_NO_ERROR ) then
    begin
      case CommandNr of
        1 : HandleExtractWord;
      end;
    end;
  end;
end.
