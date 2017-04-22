program prefpp;

{*
 * Copyright (c) 2015 Magorium
 *
 * IFF PREF support based on:
 * - libiff done by Sander van der Burg.
 * - AROS preference files
 * - MUI 3.x documentation
 *}


{$MODE OBJFPC}{$H+}
{.$DEFINE USE_GETOPTS}
{$DEFINE USE_LONGOPTS}

Uses
  {$IFDEF USE_GETOPTS}getopts,{$ENDIF}strings, prefpp_pp;


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
  PACKAGE_NAME      = 'prefpp';
  PACKAGE_VERSION   = 'v2015.12';



procedure printUsage(const command: PChar);
begin
  WriteLn('Usage: ', command, ' [OPTION] [file.IFF]');
  WriteLn;
  WriteLn('The command "prefpp" displays a textual representation of a given IFF file, which');
  WriteLn('can be used for manual inspection of its contents. If no IFF file is specified,');
  WriteLn('it reads an IFF file from the standard input.');
  WriteLn;
  WriteLn('Options:');
  {$IFDEF OPTIONS_MS}
  WriteLn('  /c    Do not check the IFF file for validity');
  WriteLn('  /?    Shows the usage of this command to the user');
  WriteLn('  /v    Shows the version of this command to the user');
  {$ELSE}
  WriteLn('  -c, --disable-check    Do not check the IFF file for validity');
  WriteLn('  -h, --help             Shows the usage of this command to the user');
  WriteLn('  -v, --version          Shows the version of this command to the user');
  {$ENDIF}
end;


procedure printVersion(const command: PChar);
begin
  WriteLn(command, ' (', PACKAGE_NAME, ') ', PACKAGE_VERSION);
  WriteLn;
  WriteLn('Copyright (C) 2015 Magorium');
end;


function  main(argc: Integer; argv: PPChar): Integer;
var
  options   : Integer = 0;
  filename  : PChar;
  {$IFDEF OPTIONS_MS}
  optind    : word  = 1;
  i         : word;
  {$ELSE}
  c         : char;
  {$IFDEF OPTIONS_LONG}
  option_index : integer = 0;
  long_options : array[0..2] of TOption = 
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
      options := options or PREFPP_DISABLE_CHECK;
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

  //* Pretty print the IFF file */
  Result := PREF_prettyPrint(filename, options);
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
