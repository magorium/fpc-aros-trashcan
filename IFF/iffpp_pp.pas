unit iffpp_pp;

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
  IFFPP_DISABLE_CHECK   = $01;

{**
 * Displays a textual representation of the given IFF file.
 *
 * @param filename Path to the IFF file, or NULL to read from the standard input
 * @param options An integer in which their bits represent a number of pretty print options
 * @return TRUE if the file has been successfully printed, else FALSE
 *}
function  IFF_prettyPrint(const filename: PChar; const options: Integer): Integer;



implementation


Uses
  libiff;


function  IFF_prettyPrint(const filename: PChar; const options: Integer): Integer;
var
  chunk : PIFF_Chunk;
var
  status    : Integer;
begin    

  //* Parse the chunk */
  if (filename = nil)
  then 
    chunk := IFF_readFd(StdInputHandle, nil, 0)
  else
    chunk := IFF_read(filename, nil, 0);


  if (chunk = nil) then
  begin
    WriteLn(StdErr, 'Cannot open IFF file!');
    exit(1);
  end
  else
  begin

    //* Check the file */
    if ((options and IFFPP_DISABLE_CHECK <> 0) or (IFF_check(chunk, nil, 0) <> 0 ) ) then
    begin
      //* Print the file */
      IFF_print(chunk, 0, Nil, 0);
	    
      status := 0;
    end
    else
      status := 1;
      
    //* Free the chunk structure */
    IFF_free(chunk, nil, 0);
	    
    exit(status);
  end;
end;


end.
