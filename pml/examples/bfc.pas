program bfc;

{$MODE OBJFPC}{$H+}
{$RANGECHECKS ON}
{$OVERFLOWCHECKS ON}

{
  Poor man's binary file compare by magorium in 2017

  I had this code around for years (mine?) and decided to polish it a little
  and also added some comments so that it can be used as a standalone 
  commandline program and/or serve as an example.
  
  ToDo: 
  - use newargs
  - buffersize commandline parameter
}

uses
  Classes, SysUtils, Math;


function DQuote(S: String): String; inline;
begin
  Result := '"' + S + '"';
end;


function FilesDiff(Filename1: String; Filename2: String; var DiffCount: Int64; const BufferSize: Word = 8192): extended;
var
  Stream1            : TFileStream;     // First filestream
  Stream2            : TFileStream;     // Second filestream
  CompareBuffer1     : Array of Byte;   // Buffer used by stream 1
  CompareBuffer2     : Array of Byte;   // Buffer used by stream 2
  BytesRead1         : LongInt;         // Actual bytes read from stream 1
  BytesRead2         : LongInt;         // Actual bytes read from stream 2
  CompareBufferSize  : LongInt;         // Size (in bytes) of comparebuffer
  MaxCount           : Integer;         // Max difference check loop's per buffer
  CompareBufferIndex : LongInt;         // Index used when comparing buffers
begin
  result := 0.000;
  DiffCount := 0;

  // Establish buffersize per available options
  if (BufferSize > 128) 
  then CompareBufferSize := BufferSize
  else ComparebufferSize := 128;

  try
    // Allocate memory for the compare buffers
    SetLength(CompareBuffer1, CompareBufferSize);
    SetLength(CompareBuffer2, CompareBufferSize);

    // Create the file streams
    Stream1 := TFileStream.Create(Filename1, fmOpenRead + fmShareDenyNone);
    Stream2 := TFileStream.Create(Filename2, fmOpenRead + fmShareDenyNone);

    // Initialize the streams for usage
    Stream1.Position := 0;
    Stream2.Position := 0;

    // While (almost) forever
    while True do 
    begin
      // Fill individual buffers by reading from corresponding streams
      BytesRead1 := Stream1.Read(CompareBuffer1[0], CompareBufferSize);
      BytesRead2 := Stream2.Read(CompareBuffer2[0], CompareBufferSize);

      // Set MaxCount to smallest value of bytes that were read from either stream
      MaxCount := Min(BytesRead1, BytesRead2);

      // ... for every byte in the buffer check for differences
      for CompareBufferIndex := 0 to Pred(MaxCount) do
        // ... if a difference was found then increment DifferenceCount variable
        if (CompareBuffer1[CompareBufferIndex] <> CompareBuffer2[CompareBufferIndex]) 
          then Inc(DiffCount);
      // When the number of read bytes from Stream1 is different than the
      // number of read bytes from Stream2 or we haven't read any bytes from
      // a stream, then break the loop, because we're done comparing
      if (BytesRead1 <> BytesRead2) or (BytesRead1 = 0) or (BytesRead2 = 0) 
        then Break; // Break the while loop
    end;

    // Return the number of differences in pct
    Result := (DiffCount * 100) / Max(Stream1.Size, Stream2.Size);

  finally
    FreeAndNil(Stream1);
    FreeAndNil(Stream2);
    SetLength(CompareBuffer1, 0);
    SetLength(CompareBuffer2, 0);
  end;
end;


Var
  Filename1  : String = '';
  Filename2  : String = '';
  File1Valid : Boolean = false;
  File2Valid : Boolean = false;
  DiffPct    : extended;
  DiffCount  : Int64;
begin
  //  DiffPct := 0.00;

  // simple parameter parsing for two filenames
  if (ParamCount = 2) then  
  begin
    // Assume Parameters 1 and 2 are filenames
    Filename1 := ParamStr(1);
    Filename2 := Paramstr(2);
    // determine if these filenames actually exist
    File1Valid := FileExists(Filename1);
    File2Valid := FileExists(Filename2);

    // if both files exist then ... 
    if (File1Valid and File2Valid) then
    begin
      // compare the files ...
      DiffPct := FilesDiff(Filename1, Filename2, DiffCount);
      // ... and inform user about findings
      WriteLn(DQuote(Filename1), ' and ', DQuote(Filename2), ' have ', DiffCount , ' different bytes ', '( ', 100.00-DiffPct:3:4, '% similarity',' )');
    end
    else // ... inform user about missing files
    begin
      if not(File1Valid) then WriteLn('File with name ', DQuote(Filename1), ' does not exist');
      if not(File2Valid) then WriteLn('File with name ', DQuote(Filename2), ' does not exist');
      WriteLn('Error: unable to obtain comparison results');
    end;
  end
  else
    WriteLn('Usage: bfc file1 file2')
end.
