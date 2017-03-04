program iffjoin;

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

uses
  {$IFDEF USE_GETOPTS}getopts,{$ENDIF}strings, iffjoin_join;

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
  PACKAGE_NAME      = 'iffjoin';
  PACKAGE_VERSION   = 'v2015.12p';


procedure printUsage(const command: PChar);
begin
  WriteLn('Usage: ', command, ' [OPTION] file1.IFF file2.IFF ...');
  WriteLn;
  WriteLn('The command "iffjoin" joins an aribitrary number of IFF files into a single');
  WriteLn('concatenation IFF file. The result is written to the standard output, or');
  WriteLn('optionally to a given destination file.');
  WriteLn;
  WriteLn('Options:');
  {$IFDEF OPTIONS_MS}
  WriteLn('  /o FILE    Specify an output file name');
  WriteLn('  /?         Shows the usage of this command to the user');
  WriteLn('  /v         Shows the version of this command to the user');
  {$ELSE}
  WriteLn('  -o, --output-file=FILE    Specify an output file name');
  WriteLn('  -h, --help                Shows the usage of this command to the user');
  WriteLn('  -v, --version             Shows the version of this command to the user');
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
  outputFilename : PChar = nil;
  {$IFDEF OPTIONS_MS}
  optind         : word  = 1;
  {$ELSE}
  c              : char;
  s              : String;
  {$IFDEF OPTIONS_LONG}
  option_index   : integer = 0;
  long_options   : array[0..2] of TOption = 
  (
    (Name: 'output-file'; Has_arg: Required_Argument; Flag: nil; Value: 'o'),
    (Name: 'help'       ; Has_arg: no_argument      ; Flag: nil; Value: 'h'),
    (Name: 'version'    ; Has_arg: no_argument      ; Flag: nil; Value: 'v')
  );
  {$ENDIF}
  {$ENDIF}
  inputFilenamesLength  : word;
  inputFilenames        : PPChar;
  i                     : word;
  status                : integer;
begin
  {$IFDEF OPTIONS_MS}

  for i := 1 to Pred(argc) do
  begin
    if (strcomp(argv[i], '/o') = 0) then
    begin
      outputFilename := argv[i];
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
    c := getlongopts('o:hv', @long_options, option_index);
    {$ELSE}
    c := getopt('o:hv');
    {$ENDIF}
    if (c = EndOfOptions) then break;
    case c of
      'o': begin s := optarg; outputFilename := PChar(s); end;
      'h',
      '?': printUsage(argv[0]);
      'v': printVersion(argv[0]);
    end;
  end;    

  {$ENDIF}    
    
  //* Validate non options */
    
  if (optind >= argc) then 
  begin
    WriteLn(stderr, 'ERROR: No IFF input files given!');
    exit(1);
  end
  else
  begin
    inputFilenamesLength := argc - optind;
    inputFilenames := PPChar(GetMem(inputFilenamesLength * sizeof(PChar)));

    //* Create an array of input file names */
    for i := 0 to Pred(inputFilenamesLength) 
      do inputFilenames[i] := argv[optind + i];
        
    //* Join the IFF files */
    status := IFF_join(inputFilenames, inputFilenamesLength, outputFilename);
        
    //* Cleanup */
    FreeMem(inputFilenames);
        
    //* Return whether the join has succeeded or not */
    exit(status);
  end;
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
