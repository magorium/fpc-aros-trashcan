program ilbmpp;

{*
 * Copyright (c) 2012 Sander van der Burg
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *}

  //   ***   Pascal conversion by magorium, 2015   ***   //

{$MODE OBJFPC}{$H+}
{.$DEFINE USE_GETOPTS}
{$DEFINE USE_LONGOPTS}

Uses
  {$IFDEF USE_GETOPTS}getopts,{$ENDIF}strings, ilbmpp_pp;


{$IF DECLARED(GetOpt)}
  {$IFDEF USE_LONGOPTS}
    {$DEFINE OPTIONS_LONG}
  {$ELSE}
    {$DEFINE OPTIONS_SHORT}
  {$ENDIF}
{$ELSE}
  {$DEFINE OPTIONS_MS}
{$ENDIF}


{$IFDEF OPTIONS_SHORT} {$NOTE Using getopt short options} {$ENDIF}
{$IFDEF OPTIONS_LONG}  {$NOTE Using getopt long options}  {$ENDIF}
{$IFDEF OPTIONS_MS}    {$NOTE Using MS style options}     {$ENDIF}


Const
  PACKAGE_NAME      = 'ilbm pretty print';
  PACKAGE_VERSION   = 'v2015.12p';



procedure printUsage(const command: PChar);
begin
  WriteLn('Usage: ', command, ' [OPTION] [file.IFF]');
  WriteLn;
  WriteLn('The command "ilbmpp" displays a textual representation of a given IFF file');
  WriteLn('containing ILBM form chunks, which can be used for manual inspection. If no');
  WriteLn('IFF file is specified, it reads an IFF file from the standard input.');
  WriteLn;
  WriteLn('Options:');
  WriteLn;
  {$IFDEF OPTIONS_MS}
  WriteLn('  /c    Do not check the IFF file');
  WriteLn('  /?    Shows the usage of this command to the user');
  WriteLn('  /v    Shows the version of this command to the user');
  {$ELSE}
  WriteLn('  -c, --disable-check    Do not check the IFF file');
  WriteLn('  -h, --help             Shows the usage of this command to the user');
  WriteLn('  -v, --version          Shows the version of this command to the user');
  {$ENDIF}
end;


procedure printVersion(const command: PChar);
begin
  WriteLn(command, ' (', PACKAGE_NAME, ') ', PACKAGE_VERSION);
  WriteLn;
  WriteLn('Copyright (C) 2012-2015 Sander van der Burg');
end;


function  main(argc: Integer; argv: PPChar): Integer;
var
  options   : Integer = 0;
  filename  : PChar;
  {$IFDEF OPTIONS_MS}
  optind    : word  = 1;
  i         : word;  
  {$ELSE}
  c         : Char;
  {$IFDEF OPTIONS_LONG}
  option_index : integer = 0;
  long_options  : array[0..2] of TOption = 
  (
    (Name: 'disable-check'; Has_arg: no_argument; Flag: nil; Value: 'c'),
    (Name: 'help'         ; Has_arg: no_argument; Flag: nil; Value: 'h'),
    (Name: 'version'      ; Has_arg: no_argument; Flag: nil; Value: 'v')
  );
  {$ENDIF}
  {$ENDIF}
begin
  {$IFDEF OPTIONS_MS}
  for i := 1 to Pred(argc) do
  begin
    if (strcomp(argv[i], '/c') = 0) then
    begin
      options := options or ILBMPP_DISABLE_CHECK;
      inc(optind);
    end
    else if (strcomp(argv[i], '/?') = 0) then
    begin
      printUsage(argv[0]);
      exit(0);
    end
    else if (strcomp(argv[i], '/v') = 0) then
    begin
      printVersion(argv[0]);
      exit(0);
    end;
  end;

  {$ELSE}

  //* Parse command-line options */
  while true do
  begin
    {$IFDEF OPTIONS_LONG}
    c := getlongopts('chv', @long_options, option_index);
    {$ELSE}
    c := getopt('chv');
    {$ENDIF}
    if (c = EndOfOptions) then break;

    case c of
      'c': options := options or ILBM_DISABLE_CHECK;
      'h',
      '?': begin printUsage(argv[0]); exit(0); end;
      'v': begin printVersion(argv[0]); exit(0); end;
    end;
  end;
  
  {$ENDIF}

  //* Validate non options */
    
  if (optind >= argc)
  then 
    filename := nil
  else
    filename := argv[optind];

  Result := ILBM_prettyPrint(filename, options);
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
