unit _8svxpack_pack;

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

interface


  function pack(const inputFilename: PChar; const outputFilename: PChar; const compress: boolean): integer;


implementation

uses
  libiff, lib8svx;


function pack(const inputFilename: PChar; const outputFilename: PChar; const compress: boolean): integer;
var
  chunk             : PIFF_Chunk;
  instrumentsLength : word;
  instruments       : PP8SVX_Instrument;
  status            : integer = 0;
  i                 : word;
  instrument        : P8SVX_Instrument;
begin    
  if (inputFilename = nil)
  then chunk := _8SVX_readFd(StdInputHandle) // stdin
  else chunk := _8SVX_read(inputFilename);
    
  if (chunk = nil) then
  begin
    WriteLn(stderr, 'Error parsing 8SVX file!');
    exit(1);
  end
  else
  begin
    instruments := _8SVX_extractInstruments(chunk, @instrumentsLength);
	
    if not(_8SVX_checkInstruments(chunk, instruments, instrumentsLength) <> 0) then
    begin
      WriteLn(stderr, 'Invalid 8SVX file!');
      status := 1;
    end
    else if (instrumentsLength = 0) then
    begin
      WriteLn(stderr, 'No 8SVX instruments found in IFF file!');
      status := 1;
    end
    else
    begin
      for i := 0 to Pred(instrumentsLength) do
      begin
        instrument := instruments[i];
		
        if (compress)
        then _8SVX_packFibonacciDelta(instrument)
        else _8SVX_unpackFibonacciDelta(instrument);
      end;
	    
      if (outputFilename = nil) then
      begin
        if not(_8SVX_writeFd(StdOutputHandle, chunk) <> 0) then
        begin
          WriteLn(stderr, 'Error writing 8SVX file!');
          status := 1;
        end;
      end
      else
      begin
        if not(_8SVX_write(outputFilename, chunk) <> 0) then
        begin
          WriteLn(stderr, 'Error writing 8SVX file!');
          status := 1;
        end;
      end;
	    
      _8SVX_freeInstruments(instruments, instrumentsLength);
    end;
	
    _8SVX_free(chunk);
	
    //* Everything has succeeded */
    exit(status);
  end;
end;


end.
