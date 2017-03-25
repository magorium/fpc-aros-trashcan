unit ilbm2acbm_sub;

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


  function  ILBM_ILBMtoACBM(const inputFilename: PChar; const outputFilename: PChar): LongInt;


implementation

uses
  libiff, libilbm;


function  ILBM_ILBMtoACBM(const inputFilename: PChar; const outputFilename: PChar): LongInt;
var
  chunk         : PIFF_Chunk;
  imageslength  : LongWord;
  images        : PPILBM_Image;
  status        : LongInt;
  i             : LongWord;
  image         : PILBM_Image;
begin
  if (inputFilename = nil)
  then chunk := ILBM_readFd(StdInputHandle)
  else chunk := ILBM_read(inputFilename);
    
  if (chunk = nil) then
  begin
    WriteLn(stderr, 'Error parsing ILBM file!');
    exit(1);
  end
  else
  begin
    images := ILBM_extractImages(chunk, @imagesLength);
    status := 0;
        
    if not (ILBM_checkImages(chunk, images, imagesLength) <> 0) then
    begin
      WriteLn(stderr, 'Invalid ILBM file!');
      status := 1;
    end
    else if (imagesLength = 0) then
    begin
      WriteLn(stderr, 'No ILBM images found in IFF file!');
      status := 1;
    end
    else
    begin
      i := 0;
      while (i < imagesLength) do
      begin
        image := images[i];
                
        if (image^.bitMapHeader^.compression = ILBM_CMP_NONE) then
        begin
          if not (ILBM_convertILBMToACBM(image) <> 0) then
          begin
            WriteLn(stderr, 'Cannot convert ILBM to ACBM image!');
            status := 1;
          end;
        end
        else
          WriteLn(stderr, 'WARNING: image: ', i , ' is compressed! Skipping...');

        inc(i);
      end;
            
      if (outputFilename = nil) then
      begin
        if not (ILBM_writeFd(StdOutputHandle, chunk) <> 0) then
        begin
          WriteLn(stderr, 'Error writing ILBM file!');
          status := 1;
        end;
      end
      else
      begin
        if not (ILBM_write(outputFilename, chunk) <> 0) then
        begin
          WriteLn(stderr, 'Error writing ILBM file!');
          status := 1;
        end;
      end;
            
      ILBM_freeImages(images, imagesLength);
    end;
        
    ILBM_free(chunk);
        
    //* Everything has succeeded */
    result := status;
  end;
end;

end.
