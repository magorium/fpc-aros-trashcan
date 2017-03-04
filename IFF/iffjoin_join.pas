unit iffjoin_join;

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

interface

{**
 * Joins an arbitrary number of IFF input files in a single concatenation chunk.
 *
 * @param inputFilenames An array of input IFF file names
 * @param inputFilenamesLength Contains the length of the inputFilenames array
 * @param outputFilename Specifies the name of the output file containing the resulting concatenation chunk. NULL can be used to write the result to the standard output.
 * @return TRUE if the resulting concatenation has been successfully written, else FALSE
 *}
function  IFF_join(inputFilenames: PPChar; const inputFilenamesLength: LongWord; const outputFilename: PChar): LongInt;


implementation

uses
  libiff;

function  IFF_join(inputFilenames: PPChar; const inputFilenamesLength: LongWord; const outputFilename: PChar): LongInt;
var
  cat       : PIFF_CAT;
  lastType  : TIFF_ID;
  sameIds   : boolean;
  i         : LongWord;
  status    : LongInt;
  chunk     : PIFF_Chunk;
  form      : PIFF_Form;
  cat2      : PIFF_CAT;
  list      : PIFF_List;
begin
  cat := IFF_createCAT('JJJJ');
  sameIds := TRUE;
  status := 0;

  for i := 0 to Pred(inputFilenamesLength) do
  begin
    //* Open each input IFF file */
    chunk := IFF_read(inputFilenames[i], nil, 0);
	
    //* Check whether the IFF file is valid */
	if ( (chunk = nil) or not(IFF_check(chunk, nil, 0) <> 0) ) then
    begin
      IFF_free(PIFF_Chunk(cat), nil, 0);
      exit(1);
    end
    else
    begin
      //* Check whether all the form types and contents types are the same */
	    
      if (sameIds) then
      begin
        if (IFF_compareId(chunk^.chunkId, 'FORM') = 0) then
        begin
          form := PIFF_Form(chunk);
		
          if ( (i > 0) and (IFF_compareId(form^.formType, @lastType) <> 0) )
            then sameIds := false;
		
          IFF_createId(lastType, form^.formType);
        end
        else 
        if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0) then
        begin
          cat2 := PIFF_CAT(chunk);
		    
          if ( (i > 0) and (IFF_compareId(cat2^.contentsType, @lastType) <> 0) ) 
            then sameIds := false;
		
          IFF_createId(lastType, cat2^.contentsType);
        end
        else 
        if (IFF_compareId(chunk^.chunkId, 'LIST') = 0) then
        begin
          list := PIFF_List(chunk);
		    
          if ( (i > 0) and (IFF_compareId(list^.contentsType, @lastType) <> 0) )
            then sameIds := false;
		
          IFF_createId(lastType, list^.contentsType);
        end;
      end;
	    
      //* Add the input IFF chunk to the concatenation */
      IFF_addToCAT(cat, chunk);
    end;
  end;
    
  //* If all form types are the same, then change the contentsType of this CAT to hint about it. Otherwise the contentsType remains 'JJJJ' */
  if (sameIds)
    then IFF_createId(cat^.contentsType, lastType);
    
  //* Write the resulting CAT */
    
  if (outputFilename = nil) then
  begin
    //* Write the CAT to the standard output */
    if not(IFF_writeFd(StdOutputHandle, PIFF_Chunk(cat), nil, 0) <> 0)
      then status := 1;
  end
  else
  begin
    //* Write the CAT to the specified destination filename */
    if not(IFF_write(outputFilename, PIFF_Chunk(cat), nil, 0) <> 0)
      then status := 1;
  end;
    
  //* Free everything */
  IFF_free( PIFF_Chunk(cat), nil, 0);
    
  //* Return whether the join has succeeded */
  exit(status);
end;

end.
