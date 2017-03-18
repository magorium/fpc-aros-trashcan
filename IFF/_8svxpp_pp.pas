unit _8svxpp_pp;

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


Const
  _8SVXPP_DISABLE_CHECK   = $01;


function  _8SVX_prettyPrint(const filename: PChar; const options: Integer): Integer;


implementation


Uses
  libiff, lib8svx;


function  _8SVX_prettyPrint(const filename: PChar; const options: Integer): Integer;
var
  chunk : PIFF_Chunk;
var
  status    : Integer;
begin    

  if (filename = nil)
  then 
    chunk := _8SVX_readFd(StdInputHandle)
  else
    chunk := _8SVX_read(filename);


  if (chunk = nil) then
  begin
    WriteLn(StdErr, 'Cannot open 8SVX file!');
    exit(1);
  end
  else
  begin
    WriteLn('8svx file was opened correctly, now printing');

    //* Check the file */
    if ((options and _8SVXPP_DISABLE_CHECK <> 0) or (_8SVX_check(chunk) <> 0 ) ) then
    begin
      //* Print the file */
      _8SVX_print(chunk, 0);
	    
      status := 0;
    end
    else
      status := 1;
      
    //* Free the chunk structure */
    _8SVX_free(chunk);
	    
    exit(status);
  end;
end;


end.
