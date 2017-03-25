program ilbmpack;

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
  {$IFDEF USE_GETOPTS}getopts,{$ENDIF}strings, ilbmpack_pack;


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
  PACKAGE_NAME      = 'ilbm chunk packer';
  PACKAGE_VERSION   = 'v2015.12';


procedure printUsage(const command: PChar);
begin
  {$IFDEF OPTIONS_MS}
  WriteLn('Usage: ', command, ' /c [OPTION] [/i file.IFF] [/o file.IFF]');
  WriteLn('  or: ', command, ' /d [OPTION] [/i file.IFF] [/o file.IFF]');
  WriteLn;
  {$ELSE}
  WriteLn('Usage: ', command, ' -c [OPTION] [-i file.IFF] [-o file.IFF]');
  WriteLn('  or: ', command, ' -d [OPTION] [-i file.IFF] [-o file.IFF]');
  WriteLn;
  {$ENDIF}

  WriteLn('The command "ilbmpack" compresses or decompresses all the BODY chunks of all');
  WriteLn('ILBM forms in the given IFF file using the byte run (packbits) algorithm. If no');
  WriteLn('IFF file is specified, it reads an IFF file from the standard input.');
  WriteLn;

  WriteLn('Options:');
  WriteLn;
  {$IFDEF OPTIONS_MS}
  WriteLn('  /c       Compress the ILBM images');
  WriteLn('  /d       Decompress the ILBM images');
  WriteLn('  /i FILE  Specifies the input IFF file. If no input file is given,');
  WriteLn('           then data will be read from the standard input');
  WriteLn('  /o FILE  Specifies the output IFF file. If no output file is');
  WriteLn('           given, then data will be written to the standard output');
  WriteLn('  /?       Shows the usage of this command to the user');
  WriteLn('  /v       Shows the version of this command to the user');
  {$ELSE}
  WriteLn('  -c, --compress          Compress the ILBM images');
  WriteLn('  -d, --decompress        Decompress the ILBM images');
  WriteLn('  -i, --input-file=FILE   Specifies the input IFF file. If no input file is');
  WriteLn('                          given, then data will be read from the standard input');
  WriteLn('  -o, --output-file=FILE  Specifies the output IFF file. If no output file is');
  WriteLn('                          given, then data will be written to the standard');
  WriteLn('                          output');
  WriteLn('  -h, --help              Shows the usage of this command to the user');
  WriteLn('  -v, --version           Shows the version of this command to the user');
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
  compress          : boolean = false;
  inputFilename     : PChar = nil;
  outputFilename    : PChar = nil;
  
  {$IFDEF OPTIONS_MS}
var
  optind    : word  = 1;
  i         : word;  
  inputFilenameFollows  : boolean = FALSE;
  outputFilenameFollows : boolean = FALSE;
  {$ELSE}
  c         : Char;
  {$IFDEF OPTIONS_LONG}
  option_index          : integer = 0;
  long_options          : array[0..5] of TOption = 
  (
    (Name: 'compress'   ; Has_arg: no_argument; Flag: nil; Value: 'c'),
    (Name: 'decompress' ; Has_arg: no_argument; Flag: nil; Value: 'd'),
    (Name: 'input-file' ; Has_arg: Required_Argument; Flag: nil; Value: 'i'),
    (Name: 'output-file'; Has_arg: Required_Argument; Flag: nil; Value: 'o'),
    (Name: 'help'       ; Has_arg: no_argument      ; Flag: nil; Value: 'h'),
    (Name: 'version'    ; Has_arg: no_argument      ; Flag: nil; Value: 'v')
  );
  {$ENDIF}
  {$ENDIF}
begin
  {$IFDEF OPTIONS_MS}
  for i := 1 to Pred(argc) do
  begin
    if (inputFilenameFollows) then
    begin
      inputFilename := argv[i];
      inputFilenameFollows := FALSE;
      inc(optind);
    end
    else if (outputFilenameFollows) then
    begin
      outputFilename := argv[i];
      outputFilenameFollows := FALSE;
      inc(optind);
    end
    else if (strcomp(argv[i], '/i') = 0) then
    begin
      inputFilenameFollows := TRUE;
      inc(optind);
    end
    else if (strcomp(argv[i], '/o') = 0) then
    begin
      outputFilenameFollows := TRUE;
      inc(optind);
    end
    else if (strcomp(argv[i], '/c') = 0) then
    begin
      compress := TRUE;
      inc(optind);
    end
    else if (strcomp(argv[i], '/d') = 0) then
    begin
      compress := FALSE;
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
    c := getlongopts('i:o:cdhv', @long_options, option_index);
    {$ELSE}
    c := getopt('i:o:cdhv');
    {$ENDIF}
    if (c = EndOfOptions) then break;
    case c of
      'i': begin si := optarg; inputFilename  := PChar(si); end;
      'o': begin so := optarg; outputFilename := PChar(so); end;
      'c': compress := TRUE;
      'd': compress := FALSE;
      'h',
      '?': begin printUsage(argv[0]); exit(0); end;
      'v': begin printVersion(argv[0]); exit(0); end;
    end;
  end;    

  {$ENDIF}  

  //* Check Parameters */

  if ( (inputFilename = nil) and (outputFilename = nil) ) then
  begin
    WriteLn(stderr, 'ERROR: At least an input file or output file must be specified!');
    exit(1);
  end
  else
    Result := pack(inputFilename, outputFilename, compress);
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
