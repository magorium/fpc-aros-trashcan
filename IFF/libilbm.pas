unit libilbm;

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


Uses
  ctypes, libiff;





// ###########################################################################
// ###
// ###      type definitions
// ###
// ###########################################################################





//////////////////////////////////////////////////////////////////////////////
//        bitmapheader.h
//////////////////////////////////////////////////////////////////////////////



Type
  TILBM_Masking =
  (
    ILBM_MSK_NONE = 0,
    ILBM_MSK_HAS_MASK = 1,
    ILBM_MSK_HAS_TRANSPARENT_COLOR = 2,
    ILBM_MSK_LASSO = 3
  );

  TILBM_Compression =
  (
    ILBM_CMP_NONE = 0,
    ILBM_CMP_BYTE_RUN = 1
  );


  PILBM_BitMapHeader = ^TILBM_BitMapHeader;
  ILBM_BitMapHeader = 
  record
    parent                  : PIFF_Group;
    
    chunkId                 : TIFF_ID;
    chunkSize               : TIFF_Long;
    
    w, h                    : TIFF_UWord;
    x,y                     : TIFF_Word;
    nPlanes                 : TIFF_UByte;
    masking                 : TILBM_Masking;
    compression             : TILBM_Compression;
    pad1                    : TIFF_UByte;
    transparentColor        : TIFF_UWord;
    xAspect, yAspect        : TIFF_UByte;
    pageWidth, pageHeight   : TIFF_Word;
  end;
  TILBM_BitMapHeader = ILBM_BitMapHeader;


  function  ILBM_createBitMapHeader: PILBM_BitMapHeader;
  function  ILBM_readBitMapHeader(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeBitMapHeader(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkBitMapHeader(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeBitMapHeader(chunk: PIFF_Chunk);
  procedure ILBM_printBitMapHeader(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareBitMapHeader(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
  function  ILBM_calculateNumOfColors(const bitMapHeader: PILBM_BitMapHeader): cuint;



//////////////////////////////////////////////////////////////////////////////
//        cmykmap.h
//////////////////////////////////////////////////////////////////////////////



Type
  PILBM_CMYKRegister = ^TILBM_CMYKRegister;
  ILBM_CMYKRegister = 
  record
    cyan, magenta, yellow, black: TIFF_UByte;
  end;
  TILBM_CMYKRegister = ILBM_CMYKRegister;


  PILBM_CMYKMap = ^TILBM_CMYKMap;
  ILBM_CMYKMap = 
  record
    parent              : PIFF_Group;
    
    chunkId             : TIFF_ID ;
    chunkSize           : TIFF_Long ;
    
    cmykRegisterLength  : cuint;
    cmykRegister        : PILBM_CMYKRegister;
  end;
  TILBM_CMYKMap = ILBM_CMYKMap;


  function  ILBM_createCMYKMap: PILBM_CMYKMap;
  function  ILBM_addCMYKRegisterInCMYKMap(cmykMap: PILBM_CMYKMap): PILBM_CMYKRegister;
  function  ILBM_readCMYKMap(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeCMYKMap(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkCMYKMap(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeCMYKMap(chunk: PIFF_Chunk);
  procedure ILBM_printCMYKMap(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareCMYKMap(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        colormap.h
//////////////////////////////////////////////////////////////////////////////



Type
  PILBM_ColorRegister = ^TILBM_ColorRegister;
  ILBM_ColorRegister = 
  record
    red, green, blue    : TIFF_UByte;
  end;
  TILBM_ColorRegister = ILBM_ColorRegister;


  PILBM_ColorMap = ^TILBM_ColorMap;
  ILBM_ColorMap = 
  record
    parent              : PIFF_Group;

    chunkId             : TIFF_ID;
    chunkSize           : TIFF_Long;

    colorRegisterLength : cuint;
    colorRegister       : PILBM_ColorRegister;
  end;
  TILBM_ColorMap = ILBM_ColorMap;


  function  ILBM_createColorMap: PILBM_ColorMap;
  function  ILBM_addColorRegisterInColorMap(colorMap: PILBM_ColorMap): PILBM_ColorRegister;
  function  ILBM_readColorMap(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeColorMap(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkColorMap(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeColorMap(chunk: PIFF_Chunk);
  procedure ILBM_printColorMap(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareColorMap(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        colorrange.h
//////////////////////////////////////////////////////////////////////////////



const
  ILBM_COLORRANGE_60_STEPS_PER_SECOND   = 16384;


Type
  PPILBM_ColorRange = ^PILBM_ColorRange;
  PILBM_ColorRange = ^TILBM_ColorRange;
  ILBM_ColorRange = 
  record
    parent      : PIFF_Group;

    chunkId     : TIFF_ID;
    chunkSize   : TIFF_Long;

    pad1        : TIFF_Word;
    rate        : TIFF_Word;
    active      : TIFF_Word;
    low, high   : TIFF_UByte;
  end;
  TILBM_ColorRange = ILBM_ColorRange;


  function  ILBM_createColorRange: PILBM_ColorRange;
  function  ILBM_readColorRange(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeColorRange(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkColorRange(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeColorRange(chunk: PIFF_Chunk);
  procedure ILBM_printColorRange(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareColorRange(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        cycleinfo.h
//////////////////////////////////////////////////////////////////////////////



Type
  PPILBM_CycleInfo = ^PILBM_CycleInfo;
  PILBM_CycleInfo = ^TILBM_CycleInfo;
  ILBM_CycleInfo = 
  record
    parent          : PIFF_Group;

    chunkId         : TIFF_ID;
    chunkSize       : TIFF_Long;

    direction       : TIFF_Word;
    start, stend    : TIFF_UByte;
    seconds         : TIFF_Long;
    microSeconds    : TIFF_Long;
    pad             : TIFF_Word;
  end;
  TILBM_CycleInfo = ILBM_CycleInfo;


  function  ILBM_createCycleInfo: PILBM_CycleInfo;
  function  ILBM_readCycleInfo(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeCycleInfo(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkCycleInfo(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeCycleInfo(chunk: PIFF_Chunk);
  procedure ILBM_printCycleInfo(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareCycleInfo(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        destmerge.h
//////////////////////////////////////////////////////////////////////////////



Type
  PILBM_DestMerge = ^TILBM_DestMerge;
  ILBM_DestMerge = 
  record
    parent      : PIFF_Group;

    chunkId     : TIFF_ID;
    chunkSize   : TIFF_Long;

    depth       : TIFF_UByte;
    pad1        : TIFF_UByte;
    planePick   : TIFF_UWord;
    planeOnOff  : TIFF_UWord;
    planeMask   : TIFF_UWord;
  end;
  TILBM_DestMerge = ILBM_DestMerge;


  function  ILBM_createDestMerge: PILBM_DestMerge;
  function  ILBM_readDestMerge(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeDestMerge(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkDestMerge(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeDestMerge(chunk: PIFF_Chunk);
  procedure ILBM_printDestMerge(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareDestMerge(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        drange.h
//////////////////////////////////////////////////////////////////////////////



Const
  ILBM_DRANGE_60_STEPS_PER_SECOND   = 16384;


  ILBM_RNG_ACTIVE       = 1;
  ILBM_RNG_DP_RESERVED  = 4;
  ILBM_RNG_FADE         = 8;


Type
  PILBM_DColor = ^TILBM_DColor;
  ILBM_DColor = 
  record
    cell        : TIFF_UByte;
    r, g, b     : TIFF_UByte;
  end;
  TILBM_DColor = ILBM_DColor;


  PILBM_DIndex = ^TILBM_DIndex;
  ILBM_DIndex = 
  record
    cell    : TIFF_UByte;
    index   : TIFF_UByte;
  end;
  TILBM_DIndex = ILBM_DIndex;


  PILBM_DFade = ^TILBM_DFade;
  ILBM_DFade = 
  record
    cell    : TIFF_UByte;
    fade    : TIFF_UByte;
  end;
  TILBM_DFade = ILBM_DFade;


  PPILBM_DRange = ^PILBM_DRange;
  PILBM_DRange = ^TILBM_DRange;
  ILBM_DRange = 
  record
    parent      : PIFF_Group;

    chunkId     : TIFF_ID;
    chunkSize   : TIFF_Long;

    min         : TIFF_UByte;
    max         : TIFF_UByte;
    rate        : TIFF_Word;
    flags       : TIFF_Word;
    ntrue       : TIFF_UByte;
    nregs       : TIFF_UByte;

    dcolor      : PILBM_DColor;
    dindex      : PILBM_DIndex;

    nfades      : TIFF_UByte;
    pad         : TIFF_UByte;
    dfade       : PILBM_DFade;
  end;
  TILBM_DRange = ILBM_DRange;


  function  ILBM_createDRange(flags: TIFF_Word): PILBM_DRange;
  function  ILBM_addDColorToDRange(drange: PILBM_DRange): PILBM_DColor;
  function  ILBM_addDIndexToDRange(drange: PILBM_DRange): PILBM_DIndex;
  function  ILBM_addDFadeToDRange(drange: PILBM_DRange): PILBM_DFade;
  function  ILBM_readDRange(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeDRange(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkDRange(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeDRange(chunk: PIFF_Chunk);
  procedure ILBM_printDRange(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareDRange(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        grab.h
//////////////////////////////////////////////////////////////////////////////



Type
  PILBM_Point2D = ^TILBM_Point2D;
  ILBM_Point2D = 
  record
    parent      : PIFF_Group;

    chunkId     : TIFF_ID;
    chunkSize   : TIFF_Long;

    x, y        : TIFF_Word;
  end;
  TILBM_Point2D = ILBM_Point2D;


  function  ILBM_createGrab: PILBM_Point2D;
  function  ILBM_readGrab(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeGrab(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkGrab(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeGrab(chunk: PIFF_Chunk);
  procedure ILBM_printGrab(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareGrab(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        viewport.h
//////////////////////////////////////////////////////////////////////////////



Type
  PILBM_Viewport = ^TILBM_Viewport;
  ILBM_Viewport = record
    parent          : PIFF_Group;

    chunkId         : TIFF_ID;
    chunkSize       : TIFF_Long;

    viewportMode    : TIFF_Long;
  end;
  TILBM_Viewport = ILBM_Viewport;


  function  ILBM_createViewport: PILBM_Viewport;
  function  ILBM_readViewport(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeViewport(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkViewport(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeViewport(chunk: PIFF_Chunk);
  procedure ILBM_printViewport(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareViewport(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        sprite.h
//////////////////////////////////////////////////////////////////////////////



Type
  PILBM_Sprite = ^TILBM_Sprite;
  ILBM_Sprite = record
    parent              : PIFF_Group;

    chunkId             : TIFF_ID;
    chunkSize           : TIFF_Long;

    spritePrecedence    : TIFF_UWord;
  end;
  TILBM_Sprite = ILBM_Sprite;


  function  ILBM_createSprite: PILBM_Sprite;
  function  ILBM_readSprite(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  ILBM_writeSprite(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_checkSprite(const chunk: PIFF_Chunk): cint;
  procedure ILBM_freeSprite(chunk: PIFF_Chunk);
  procedure ILBM_printSprite(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compareSprite(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        ilbmimage.h
//////////////////////////////////////////////////////////////////////////////



Type
  PPILBM_Image = ^PILBM_Image;
  PILBM_Image = ^TILBM_Image;
  ILBM_Image =
  record
    formType            : TIFF_ID;

    bitMapHeader        : PILBM_BitMapHeader;
    colorMap            : PILBM_ColorMap;
    cmykMap             : PILBM_CMYKMap;
    point2d             : PILBM_Point2D;
    destMerge           : PILBM_DestMerge;
    sprite              : PILBM_Sprite;
    viewport            : PILBM_Viewport;

    colorRangeLength    : cuint;
    colorRange          : PPILBM_ColorRange;

    drangeLength        : cuint;
    drange              : PPILBM_DRange;

    cycleInfoLength     : cuint;
    cycleInfo           : PPILBM_CycleInfo;

    body                : PIFF_RawChunk;
    bitplanes           : PIFF_RawChunk;
  end;
  TILBM_Image = ILBM_Image;


  function  ILBM_createImage(formType: PIFF_ID): PILBM_Image;
  function  ILBM_extractImages(chunk: PIFF_Chunk; imagesLength: pcuint): PPILBM_Image;
  function  ILBM_convertImageToForm(image: PILBM_Image): PIFF_Form;
  procedure ILBM_freeImage(image: PILBM_Image);
  procedure ILBM_freeImages(images: PPILBM_Image; const imagesLength: cuint);
  function  ILBM_checkImage(const image: PILBM_Image): cint;
  function  ILBM_checkImages(const chunk: PIFF_Chunk; images: PPILBM_Image; const imagesLength: cuint): cint;
  procedure ILBM_addColorRangeToImage(image: PILBM_Image; colorRange: PILBM_ColorRange);
  procedure ILBM_addDRangeToImage(image: PILBM_Image; drange: PILBM_DRange);
  procedure ILBM_addCycleInfoToImage(image: PILBM_Image; cycleInfo: PILBM_CycleInfo);
  function  ILBM_imageIsILBM(const image: PILBM_Image): cint;
  function  ILBM_imageIsACBM(const image: PILBM_Image): cint;
  function  ILBM_imageIsPBM(const image: PILBM_Image): cint;
  function  ILBM_calculateRowSize(const image: PILBM_Image): cuint;
  function  ILBM_generateGrayscaleColorMap(const image: PILBM_Image): PILBM_ColorMap;



//////////////////////////////////////////////////////////////////////////////
//        byterun.h
//////////////////////////////////////////////////////////////////////////////



  procedure ILBM_unpackByteRun(image: PILBM_Image);
  procedure ILBM_packByteRun(image: PILBM_Image);



//////////////////////////////////////////////////////////////////////////////
//        interleave.h
//////////////////////////////////////////////////////////////////////////////



  procedure ILBM_deinterleaveToBitplaneMemory(const image: PILBM_Image; bitplanePointers: PPIFF_UByte);
  function  ILBM_deinterleave(const image: PILBM_Image): PIFF_UByte;
  function  ILBM_convertILBMToACBM(image: PILBM_Image): cint;
  function  ILBM_interleaveFromBitplaneMemory(const image: PILBM_Image; bitplanePointers: PPIFF_UByte): PIFF_UByte;
  function  ILBM_interleave(const image: PILBM_Image; bitplanes: PIFF_UByte): PIFF_UByte;
  function  ILBM_convertACBMToILBM(image: PILBM_Image): cint;



//////////////////////////////////////////////////////////////////////////////
//        ilbm.h
//////////////////////////////////////////////////////////////////////////////



  function  ILBM_readFd(filehandle: THandle): PIFF_Chunk;
  function  ILBM_read(const filename: PChar): PIFF_Chunk;
  function  ILBM_writeFd(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  ILBM_write(const filename: PChar; const chunk: PIFF_Chunk): cint;
  procedure ILBM_free(chunk: PIFF_Chunk);
  function  ILBM_check(const chunk: PIFF_Chunk): cint;
  procedure ILBM_print(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  ILBM_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



implementation


uses
  CHelpers;



//////////////////////////////////////////////////////////////////////////////
//        bitmapheader.c
//////////////////////////////////////////////////////////////////////////////



Const
  CHUNKID_BMHD = 'BMHD';


function  ILBM_createBitMapHeader: PILBM_BitMapHeader;
var
  bitMapHeader : PILBM_BitMapHeader;
begin
  bitMapHeader := PILBM_BitMapHeader(IFF_allocateChunk(CHUNKID_BMHD, sizeof(TILBM_BitMapHeader)));

  if (bitMapHeader <> nil) then
  begin
    bitMapHeader^.chunkSize := 2 * sizeof(TIFF_UWord) + 2 * sizeof(TIFF_Word) + 4 * sizeof(TIFF_UByte) + sizeof(TIFF_UWord) + 2 * sizeof(TIFF_UByte) + 2 * sizeof(TIFF_Word);
    bitMapHeader^.pad1 := 0;
  end;

  result := bitMapHeader;
end;


function  ILBM_readBitMapHeader(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  bitMapHeader  : PILBM_BitMapHeader;
var
  byt           : TIFF_UByte;
begin
  bitMapHeader := ILBM_createBitMapHeader();

  if (bitMapHeader <> nil) then
  begin
    if notvalid(IFF_readUWord(filehandle, @bitMapHeader^.w, CHUNKID_BMHD, 'w')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @bitMapHeader^.h, CHUNKID_BMHD, 'h')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @bitMapHeader^.x, CHUNKID_BMHD, 'x')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @bitMapHeader^.y, CHUNKID_BMHD, 'y')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @bitMapHeader^.nPlanes, CHUNKID_BMHD, 'nPlanes')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @byt, CHUNKID_BMHD, 'masking')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    bitMapHeader^.masking := TILBM_Masking(byt);

    if notvalid(IFF_readUByte(filehandle, @byt, CHUNKID_BMHD, 'compression')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    bitMapHeader^.compression := TILBM_Compression(byt);

    if notvalid(IFF_readUByte(filehandle, @bitMapHeader^.pad1, CHUNKID_BMHD, 'pad1')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @bitMapHeader^.transparentColor, CHUNKID_BMHD, 'transparentColor')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @bitMapHeader^.xAspect, CHUNKID_BMHD, 'xAspect')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @bitMapHeader^.yAspect, CHUNKID_BMHD, 'yAspect')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @bitMapHeader^.pageWidth, CHUNKID_BMHD, 'pageWidth')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @bitMapHeader^.pageHeight, CHUNKID_BMHD, 'pageHeight')) then
    begin
      ILBM_free(PIFF_Chunk(bitMapHeader));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(bitMapHeader);
end;


function  ILBM_writeBitMapHeader(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  bitMapHeader : PILBM_BitMapHeader;
begin
  bitMapHeader := PILBM_BitMapHeader(chunk);

  if notvalid(IFF_writeUWord(filehandle, bitMapHeader^.w, CHUNKID_BMHD, 'w'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, bitMapHeader^.h, CHUNKID_BMHD, 'h'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, bitMapHeader^.x, CHUNKID_BMHD, 'x'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, bitMapHeader^.y, CHUNKID_BMHD, 'y'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, bitMapHeader^.nPlanes, CHUNKID_BMHD, 'nPlanes'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, TIFF_UByte(bitMapHeader^.masking), CHUNKID_BMHD, 'masking'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, TIFF_UByte(bitMapHeader^.compression), CHUNKID_BMHD, 'compression'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, bitMapHeader^.pad1, CHUNKID_BMHD, 'pad1'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, bitMapHeader^.transparentColor, CHUNKID_BMHD, 'transparentColor'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, bitMapHeader^.xAspect, CHUNKID_BMHD, 'xAspect'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, bitMapHeader^.yAspect, CHUNKID_BMHD, 'yAspect'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, bitMapHeader^.pageWidth, CHUNKID_BMHD, 'pageWidth'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, bitMapHeader^.pageHeight, CHUNKID_BMHD, 'pageHeight'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkBitMapHeader(const chunk: PIFF_Chunk): cint;
var
  bitMapHeader : PILBM_BitMapHeader;
begin
  bitMapHeader := PILBM_BitMapHeader(chunk);

  if ( (bitMapHeader^.nPlanes > 8) and (bitMapHeader^.nPlanes <> 24) and (bitMapHeader^.nPlanes <> 32) ) then
  begin
    IFF_error('Unsupported "BMHD".nPlanes value: %s' + LineEnding, [bitMapHeader^.nPlanes]);
    exit(_FALSE_);
  end;

  if ( (ord(bitMapHeader^.masking) < 0) or (bitMapHeader^.masking > ILBM_MSK_LASSO) ) then
  begin
    IFF_error('Invalid "BMHD".masking value!' + LineEnding);
    exit(_FALSE_);
  end;

  if ( (ord(bitMapHeader^.compression) < 0) or (bitMapHeader^.compression > ILBM_CMP_BYTE_RUN) ) then
  begin
    IFF_error('Invalid "BMHD".compression value!' + LineEnding);
    exit(_FALSE_);
  end;

  if (bitMapHeader^.pad1 <> 0)
  then IFF_error('WARNING: "BMHD".pad1 is not 0!' + LineEnding);

  result := _TRUE_;
end;


procedure ILBM_freeBitMapHeader(chunk: PIFF_Chunk);
begin
  { intentional left blank }
end;


procedure ILBM_printBitMapHeader(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  bitMapHeader : PILBM_BitMapHeader;
begin
  bitMapHeader := PILBM_BitMapHeader(chunk);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'w = %u;'           + LineEnding , [bitMapHeader^.w]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'h = %u;'           + LineEnding , [bitMapHeader^.h]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'x = %d;'           + LineEnding , [bitMapHeader^.x]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'y = %d;'           + LineEnding , [bitMapHeader^.y]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'nPlanes = %u;'     + LineEnding , [bitMapHeader^.nPlanes]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'masking = %u;'     + LineEnding , [bitMapHeader^.masking]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'compression = %u;' + LineEnding , [bitMapHeader^.compression]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'xAspect = %u;'     + LineEnding , [bitMapHeader^.xAspect]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'yAspect = %u;'     + LineEnding , [bitMapHeader^.yAspect]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'pageWidth = %d;'   + LineEnding , [bitMapHeader^.pageWidth]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'pageHeight = %d;'  + LineEnding , [bitMapHeader^.pageHeight]);
end;


function  ILBM_compareBitMapHeader(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  bitMapHeader1 : PILBM_BitMapHeader;
  bitMapHeader2 : PILBM_BitMapHeader;
begin
  bitMapHeader1 := PILBM_BitMapHeader(chunk1);
  bitMapHeader2 := PILBM_BitMapHeader(chunk2);

  if (bitMapHeader1^.w           <> bitMapHeader2^.w)           then exit(_FALSE_);

  if (bitMapHeader1^.h           <> bitMapHeader2^.h)           then exit(_FALSE_);

  if (bitMapHeader1^.x           <> bitMapHeader2^.x)           then exit(_FALSE_);

  if (bitMapHeader1^.y           <> bitMapHeader2^.y)           then exit(_FALSE_);

  if (bitMapHeader1^.nPlanes     <> bitMapHeader2^.nPlanes)     then exit(_FALSE_);

  if (bitMapHeader1^.masking     <> bitMapHeader2^.masking)     then exit(_FALSE_);

  if (bitMapHeader1^.compression <> bitMapHeader2^.compression) then exit(_FALSE_);

  if (bitMapHeader1^.xAspect     <> bitMapHeader2^.xAspect)     then exit(_FALSE_);

  if (bitMapHeader1^.yAspect     <> bitMapHeader2^.yAspect)     then exit(_FALSE_);

  if (bitMapHeader1^.pageWidth   <> bitMapHeader2^.pageWidth)   then exit(_FALSE_);

  if (bitMapHeader1^.pageHeight  <> bitMapHeader2^.pageHeight)  then exit(_FALSE_);

  Result := _TRUE_;
end;


function  ILBM_calculateNumOfColors(const bitMapHeader: PILBM_BitMapHeader): cuint;
begin
  case (bitMapHeader^.nPlanes) of
    1 :  result :=   2;
    2 :  result :=   4;
    3 :  result :=   8;
    4 :  result :=  16;
    5 :  result :=  32;
    6 :  result :=  64;
    7 :  result := 128;
    8 :  result := 256;
    else result :=   0;
  end;
end;



//////////////////////////////////////////////////////////////////////////////
//        cmykmap.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_CMYK  = 'CMYK';


function  ILBM_createCMYKMap: PILBM_CMYKMap;
var
  cmykMap   : PILBM_CMYKMap;
begin
  cmykMap := PILBM_CMYKMap(IFF_allocateChunk(CHUNKID_CMYK, sizeof(TILBM_CMYKMap)));

  if (cmykMap <> nil) then
  begin
    cmykMap^.chunkSize := 0;

    cmykMap^.cmykRegisterLength := 0;
    cmykMap^.cmykRegister := nil;
  end;

  result := cmykMap;
end;


function  ILBM_addCMYKRegisterInCMYKMap(cmykMap: PILBM_CMYKMap): PILBM_CMYKRegister;
var
  cmykRegister : PILBM_CMYKRegister;
begin
  cmykMap^.cmykRegister := PILBM_CMYKRegister(ReAllocMem(cmykMap^.cmykRegister, (cmykMap^.cmykRegisterLength + 1) * sizeof(TILBM_CMYKRegister)));
  cmykRegister := @cmykMap^.cmykRegister[cmykMap^.cmykRegisterLength];
  inc(cmykMap^.cmykRegisterLength);

  cmykMap^.chunkSize := cmykMap^.chunkSize + sizeof(TILBM_CMYKRegister);

  result := cmykRegister;
end;


function  ILBM_readCMYKMap(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  cmykMap       : PILBM_CMYKMap;
var
  cmykRegister  : PILBM_CMYKRegister;
begin
  cmykMap := ILBM_createCMYKMap();

  if (cmykMap <> Nil) then
  begin
    while(cmykMap^.chunkSize < chunkSize) do
    begin
      cmykRegister := ILBM_addCMYKRegisterInCMYKMap(cmykMap);

      if notvalid(IFF_readUByte(filehandle, @cmykRegister^.cyan, CHUNKID_CMYK, 'cmykRegister.cyan')) then
      begin
        ILBM_free(PIFF_Chunk(cmykMap));
        exit(Nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @cmykRegister^.magenta, CHUNKID_CMYK, 'cmykRegister.magenta')) then
      begin
        ILBM_free(PIFF_Chunk(cmykMap));
        exit(Nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @cmykRegister^.yellow, CHUNKID_CMYK, 'cmykRegister.yellow')) then
      begin
        ILBM_free(PIFF_Chunk(cmykMap));
        exit(Nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @cmykRegister^.black, CHUNKID_CMYK, 'cmykRegister.black')) then
      begin
        ILBM_free(PIFF_Chunk(cmykMap));
        exit(Nil);
      end;
    end;
  end;
    
  result := PIFF_Chunk(cmykMap);
end;


function  ILBM_writeCMYKMap(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  cmykMap       : PILBM_CMYKMap;
  i             : cuint;
  cmykRegister  : PILBM_CMYKRegister;
begin
  cmykMap := PILBM_CMYKMap(chunk);

  i := 0;
  while (i < cmykMap^.cmykRegisterLength) do
  begin
    cmykRegister := @cmykMap^.cmykRegister[i];

    if notvalid(IFF_writeUByte(filehandle, cmykRegister^.cyan, CHUNKID_CMYK, 'cmykRegister.cyan'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, cmykRegister^.magenta, CHUNKID_CMYK, 'cmykRegister.magenta'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, cmykRegister^.yellow, CHUNKID_CMYK, 'cmykRegister.yellow'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, cmykRegister^.black, CHUNKID_CMYK, 'cmykRegister.black'))
    then exit(_FALSE_);

    inc(i);
  end;

  result := _TRUE_;
end;


function  ILBM_checkCMYKMap(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure ILBM_freeCMYKMap(chunk: PIFF_Chunk);
var
  cmykMap : PILBM_CMYKMap;
begin
  cmykMap := PILBM_CMYKMap(chunk);
  Freemem(cmykMap^.cmykRegister);
end;


procedure ILBM_printCMYKMap(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  cmykMap   : PILBM_CMYKMap;
  i         : cuint;
begin
  cmykMap := PILBM_CMYKMap(chunk);

  i := 0;
  while (i < cmykMap^.cmykRegisterLength) do
  begin
    IFF_printIndent(GetstdoutHandle, indentLevel, '{ cyan = %x, magenta = %x, yellow = %x, black = %x };' + LineEnding,
    [ cmykMap^.cmykRegister[i].cyan, cmykMap^.cmykRegister[i].magenta, cmykMap^.cmykRegister[i].yellow, cmykMap^.cmykRegister[i].black]);

    inc(i);
  end;
end;


function  ILBM_compareCMYKMap(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  cmykMap1  : PILBM_CMYKMap;
  cmykMap2  : PILBM_CMYKMap;
  i         : cuint;
begin
  cmykMap1 := PILBM_CMYKMap(chunk1);
  cmykMap2 := PILBM_CMYKMap(chunk2);
    
  if (cmykMap1^.cmykRegisterLength = cmykMap2^.cmykRegisterLength) then
  begin
    i:= 0;
    while (i < cmykMap1^.cmykRegisterLength) do
    begin
      if(cmykMap1^.cmykRegister[i].cyan <> cmykMap2^.cmykRegister[i].cyan)
      then exit(_FALSE_);

      if(cmykMap1^.cmykRegister[i].magenta <> cmykMap2^.cmykRegister[i].magenta)
      then exit(_FALSE_);

      if(cmykMap1^.cmykRegister[i].yellow <> cmykMap2^.cmykRegister[i].yellow)
      then exit(_FALSE_);

      if(cmykMap1^.cmykRegister[i].black <> cmykMap2^.cmykRegister[i].black)
      then exit(_FALSE_);

      inc(i);
    end;
  end
  else
    exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        colormap.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_CMAP =  'CMAP';


function  ILBM_createColorMap: PILBM_ColorMap;
var
  colorMap : PILBM_ColorMap;
begin
  colorMap := PILBM_ColorMap(IFF_allocateChunk(CHUNKID_CMAP, sizeof(TILBM_ColorMap)));

  if (colorMap <> nil) then
  begin
    colorMap^.chunkSize := 0;

    colorMap^.colorRegisterLength := 0;
    colorMap^.colorRegister := nil;
  end;

  result := colorMap;
end;


function  ILBM_addColorRegisterInColorMap(colorMap: PILBM_ColorMap): PILBM_ColorRegister;
var
  colorRegister : PILBM_ColorRegister;
begin
  colorMap^.colorRegister := PILBM_ColorRegister(ReAllocMem(colorMap^.colorRegister, (colorMap^.colorRegisterLength + 1) * sizeof(TILBM_ColorRegister)));
  colorRegister := @colorMap^.colorRegister[colorMap^.colorRegisterLength];
  inc(colorMap^.colorRegisterLength);

  colorMap^.chunkSize := colorMap^.chunkSize + sizeof(TILBM_ColorRegister);

  result := colorRegister;
end;


function  ILBM_readColorMap(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  colorMap      : PILBM_ColorMap;
  colorRegister : PILBM_ColorRegister;
begin
  colorMap := ILBM_createColorMap();

  if (colorMap <> nil) then
  begin
    while (colorMap^.chunkSize < chunkSize) do
    begin
      colorRegister := ILBM_addColorRegisterInColorMap(colorMap);

      if notvalid(IFF_readUByte(filehandle, @colorRegister^.red, CHUNKID_CMAP, 'colorRegister.red')) then
      begin
        ILBM_free(PIFF_Chunk(colorMap));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @colorRegister^.green, CHUNKID_CMAP, 'colorRegister.green')) then
      begin
        ILBM_free(PIFF_Chunk(colorMap));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @colorRegister^.blue, CHUNKID_CMAP, 'colorRegister.blue')) then
      begin
        ILBM_free(PIFF_Chunk(colorMap));
        exit(nil);
      end;
    end;

    if notvalid(IFF_readPaddingByte(filehandle, chunkSize, CHUNKID_CMAP)) then
    begin
      ILBM_free(PIFF_Chunk(colorMap));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(colorMap);
end;


function  ILBM_writeColorMap(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  colorMap      : PILBM_ColorMap;
  i             : cuint;
  colorRegister : PILBM_ColorRegister;
begin
  colorMap := PILBM_ColorMap(chunk);

  i := 0;
  while (i < colorMap^.colorRegisterLength) do
  begin
    colorRegister := @colorMap^.colorRegister[i];

    if notvalid(IFF_writeUByte(filehandle, colorRegister^.red, CHUNKID_CMAP, 'colorRegister.red'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, colorRegister^.green, CHUNKID_CMAP, 'colorRegister.green'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, colorRegister^.blue, CHUNKID_CMAP, 'colorRegister.blue'))
    then exit(_FALSE_);

    inc(i);
  end;

  if notvalid(IFF_writePaddingByte(filehandle, colorMap^.chunkSize, CHUNKID_CMAP))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkColorMap(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure ILBM_freeColorMap(chunk: PIFF_Chunk);
var
  colorMap : PILBM_ColorMap;
begin
  colorMap := PILBM_ColorMap(chunk);
  FreeMem(colorMap^.colorRegister);
end;


procedure ILBM_printColorMap(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  colorMap  : PILBM_ColorMap;
  i         : cuint;
begin
  colorMap := PILBM_ColorMap(chunk);

  i := 0;
  while (i < colorMap^.colorRegisterLength) do
  begin
    IFF_printIndent(getstdouthandle, indentLevel, '{ red = %x, green = %x, blue = %x };' + LineEnding,
    [ colorMap^.colorRegister[i].red, colorMap^.colorRegister[i].green, colorMap^.colorRegister[i].blue ]);
    inc(i);
  end;
end;


function  ILBM_compareColorMap(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  colorMap1 : PILBM_ColorMap;
  colorMap2 : PILBM_ColorMap;
  i         : cuint;
begin
  colorMap1 := PILBM_ColorMap(chunk1);
  colorMap2 := PILBM_ColorMap(chunk2);

  if (colorMap1^.colorRegisterLength = colorMap2^.colorRegisterLength) then
  begin
    i := 0;
    while (i < colorMap1^.colorRegisterLength) do
    begin
      if (colorMap1^.colorRegister[i].red <> colorMap2^.colorRegister[i].red)
      then exit(_FALSE_);

      if (colorMap1^.colorRegister[i].green <> colorMap2^.colorRegister[i].green)
      then exit(_FALSE_);

      if (colorMap1^.colorRegister[i].blue <> colorMap2^.colorRegister[i].blue)
      then exit(_FALSE_);

      Inc(i);
    end;
  end
  else
    exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        colorrange.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_CRNG = 'CRNG';


function  ILBM_createColorRange: PILBM_ColorRange;
var
  colorRange : PILBM_ColorRange;
begin
  colorRange := PILBM_ColorRange(IFF_allocateChunk(CHUNKID_CRNG, sizeof(TILBM_ColorRange)));

  if (colorRange <> nil) then
  begin
    colorRange^.chunkSize := 3 * sizeof(TIFF_Word) + 2 * sizeof(TIFF_UByte);
    colorRange^.pad1 := 0;
  end;

  result := colorRange;
end;


function  ILBM_readColorRange(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  colorRange : PILBM_ColorRange;
begin
  colorRange := ILBM_createColorRange();

  if (colorRange <> nil) then
  begin
    if notvalid(IFF_readWord(filehandle, @colorRange^.pad1, CHUNKID_CRNG, 'pad1')) then
    begin
      ILBM_free(PIFF_Chunk(colorRange));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @colorRange^.rate, CHUNKID_CRNG, 'rate')) then
    begin
      ILBM_free(PIFF_Chunk(colorRange));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @colorRange^.active, CHUNKID_CRNG, 'active')) then
    begin
      ILBM_free(PIFF_Chunk(colorRange));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @colorRange^.low, CHUNKID_CRNG, 'low')) then
    begin
      ILBM_free(PIFF_Chunk(colorRange));
      exit(nil);
    end;
    
    if notvalid(IFF_readUByte(filehandle, @colorRange^.high, CHUNKID_CRNG, 'high')) then
    begin
      ILBM_free(PIFF_Chunk(colorRange));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(colorRange);
end;


function  ILBM_writeColorRange(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  colorRange : PILBM_ColorRange;
begin
  colorRange := PILBM_ColorRange(chunk);

  if notvalid(IFF_writeWord(filehandle, colorRange^.pad1, CHUNKID_CRNG, 'pad1'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, colorRange^.rate, CHUNKID_CRNG, 'rate'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, colorRange^.active, CHUNKID_CRNG, 'active'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, colorRange^.low, CHUNKID_CRNG, 'low'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, colorRange^.high, CHUNKID_CRNG, 'high'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkColorRange(const chunk: PIFF_Chunk): cint;
var
  colorRange : PILBM_ColorRange;
begin
  colorRange := PILBM_ColorRange(chunk);

  if (colorRange^.pad1 <> 0)
  then IFF_error('WARING: "CRNG".pad1 is not 0!' + LineEnding);

  result := _TRUE_;
end;


procedure ILBM_freeColorRange(chunk: PIFF_Chunk);
begin
  { intentional left blank }
end;


procedure ILBM_printColorRange(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  colorRange : PILBM_ColorRange;
begin
  colorRange := PILBM_ColorRange(chunk);

  IFF_printIndent(getstdouthandle, indentLevel, 'pad1 = %d;'  + LineEnding, [colorRange^.pad1]);
  IFF_printIndent(getstdouthandle, indentLevel, 'rate = %d;'  + LineEnding, [colorRange^.rate]);
  IFF_printIndent(getstdouthandle, indentLevel, 'active = %d;'+ LineEnding, [colorRange^.active]);
  IFF_printIndent(getstdouthandle, indentLevel, 'low = %u;'   + LineEnding, [colorRange^.low]);
  IFF_printIndent(getstdouthandle, indentLevel, 'high = %u;'  + LineEnding, [colorRange^.high]);
end;


function  ILBM_compareColorRange(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  colorRange1 : PILBM_ColorRange;
  colorRange2 : PILBM_ColorRange;
begin
  colorRange1 := PILBM_ColorRange(chunk1);
  colorRange2 := PILBM_ColorRange(chunk2);

  if (colorRange1^.pad1 <> colorRange2^.pad1)
  then exit(_FALSE_);

  if (colorRange1^.rate <> colorRange2^.rate)
  then exit(_FALSE_);

  if (colorRange1^.active <> colorRange2^.active)
  then exit(_FALSE_);

  if (colorRange1^.low <> colorRange2^.low)
  then exit(_FALSE_);

  if (colorRange1^.high <> colorRange2^.high)
  then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        cycleinfo.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_CCRT  = 'CCRT';


function  ILBM_createCycleInfo: PILBM_CycleInfo;
var
  cycleInfo : PILBM_CycleInfo;
begin
  cycleInfo := PILBM_CycleInfo(IFF_allocateChunk(CHUNKID_CCRT, sizeof(TILBM_CycleInfo)));

  if (cycleInfo <> nil) then
  begin
    cycleInfo^.chunkSize := sizeof(TIFF_Word) + 2 * sizeof(TIFF_UByte) + 2 * sizeof(TIFF_Long) + sizeof(TIFF_Word);
    cycleInfo^.pad := 0;
  end;
    
  result := cycleInfo;
end;


function  ILBM_readCycleInfo(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  cycleInfo : PILBM_CycleInfo;
begin
  cycleInfo := ILBM_createCycleInfo();

  if (cycleInfo <> nil) then
  begin
    if notvalid(IFF_readWord(filehandle, @cycleInfo^.direction, CHUNKID_CCRT, 'direction')) then
    begin
      ILBM_free(PIFF_Chunk(cycleInfo));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @cycleInfo^.start, CHUNKID_CCRT, 'start')) then
    begin
      ILBM_free(PIFF_Chunk(cycleInfo));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @cycleInfo^.stend, CHUNKID_CCRT, 'end')) then
    begin
      ILBM_free(PIFF_Chunk(cycleInfo));
      exit(nil);
    end;

    if notvalid(IFF_readLong(filehandle, @cycleInfo^.seconds, CHUNKID_CCRT, 'seconds')) then
    begin
      ILBM_free(PIFF_Chunk(cycleInfo));
      exit(nil);
    end;

    if notvalid(IFF_readLong(filehandle, @cycleInfo^.microSeconds, CHUNKID_CCRT, 'microSeconds')) then
    begin
      ILBM_free(PIFF_Chunk(cycleInfo));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @cycleInfo^.pad, CHUNKID_CCRT, 'pad')) then
    begin
      ILBM_free(PIFF_Chunk(cycleInfo));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(cycleInfo);
end;


function  ILBM_writeCycleInfo(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  cycleInfo : PILBM_CycleInfo;
begin
  cycleInfo := PILBM_CycleInfo(chunk);

  if notvalid(IFF_writeWord(filehandle, cycleInfo^.direction, CHUNKID_CCRT, 'direction'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, cycleInfo^.start, CHUNKID_CCRT, 'start'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, cycleInfo^.stend, CHUNKID_CCRT, 'end'))
  then exit(_FALSE_);

  if notvalid(IFF_writeLong(filehandle, cycleInfo^.seconds, CHUNKID_CCRT, 'seconds'))
  then exit(_FALSE_);

  if notvalid(IFF_writeLong(filehandle, cycleInfo^.microSeconds, CHUNKID_CCRT, 'microSeconds'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, cycleInfo^.pad, CHUNKID_CCRT, 'pad'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkCycleInfo(const chunk: PIFF_Chunk): cint;
var
  cycleInfo : PILBM_CycleInfo;
begin
  cycleInfo := PILBM_CycleInfo(chunk);

  if ( (cycleInfo^.direction < -1) or (cycleInfo^.direction > 1) ) then
  begin
    IFF_error('"CCRT".direction must be between -1 and 1' + LineEnding);
    exit(_FALSE_);
  end;

  if (cycleInfo^.pad <> 0)
  then IFF_error('"CCRT".pad is not 0!' + LineEnding);

  result := _TRUE_;
end;


procedure ILBM_freeCycleInfo(chunk: PIFF_Chunk);
begin
  { intentio9nal left blank }
end;


procedure ILBM_printCycleInfo(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  cycleInfo : PILBM_CycleInfo;
begin
  cycleInfo := PILBM_CycleInfo(chunk);

  IFF_printIndent(getstdouthandle, indentLevel, 'direction = %d;'   + LineEnding, [cycleInfo^.direction]);
  IFF_printIndent(getstdouthandle, indentLevel, 'start = %u;'       + LineEnding, [cycleInfo^.start]);
  IFF_printIndent(getstdouthandle, indentLevel, 'end = %u;'         + LineEnding, [cycleInfo^.stend]);
  IFF_printIndent(getstdouthandle, indentLevel, 'seconds = %d;'     + LineEnding, [cycleInfo^.seconds]);
  IFF_printIndent(getstdouthandle, indentLevel, 'microSeconds = %d;'+ LineEnding, [cycleInfo^.microSeconds]);
  IFF_printIndent(getstdouthandle, indentLevel, 'pad = %d;'         + LineEnding, [cycleInfo^.pad]);
end;


function  ILBM_compareCycleInfo(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  cycleInfo1 : PILBM_CycleInfo;
  cycleInfo2 : PILBM_CycleInfo;
begin
  cycleInfo1 := PILBM_CycleInfo(chunk1);
  cycleInfo2 := PILBM_CycleInfo(chunk2);

  if (cycleInfo1^.direction <> cycleInfo2^.direction)
  then exit(_FALSE_);

  if (cycleInfo1^.start <> cycleInfo2^.start)
  then exit(_FALSE_);

  if (cycleInfo1^.stend <> cycleInfo2^.stend)
  then exit(_FALSE_);

  if (cycleInfo1^.seconds <> cycleInfo2^.seconds)
  then exit(_FALSE_);

  if (cycleInfo1^.microSeconds <> cycleInfo2^.microSeconds)
  then exit(_FALSE_);

  if (cycleInfo1^.pad <> cycleInfo2^.pad)
  then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        destmerge.h
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_DEST  = 'DEST';


function  ILBM_createDestMerge: PILBM_DestMerge;
var
  destMerge : PILBM_DestMerge;
begin
  destMerge := PILBM_DestMerge(IFF_allocateChunk(CHUNKID_DEST, sizeof(TILBM_DestMerge)));

  if (destMerge <> nil) then
  begin
    destMerge^.chunkSize := 2 * sizeof(TIFF_UByte) + 3 * sizeof(TIFF_UWord);
    destMerge^.pad1 := 0;
  end;

  result := destMerge;
end;


function  ILBM_readDestMerge(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  destMerge : PILBM_DestMerge;
begin
  destMerge := ILBM_createDestMerge();

  if (destMerge <> nil) then
  begin
    if notvalid(IFF_readUByte(filehandle, @destMerge^.depth, CHUNKID_DEST, 'depth')) then
    begin
      ILBM_free(PIFF_Chunk(destMerge));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @destMerge^.pad1, CHUNKID_DEST, 'pad1')) then
    begin
      ILBM_free(PIFF_Chunk(destMerge));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @destMerge^.planePick, CHUNKID_DEST, 'planePick')) then
    begin
      ILBM_free(PIFF_Chunk(destMerge));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @destMerge^.planeOnOff, CHUNKID_DEST, 'planeOnOff')) then
    begin
      ILBM_free(PIFF_Chunk(destMerge));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @destMerge^.planeMask, CHUNKID_DEST, 'planeMask')) then
    begin
      ILBM_free(PIFF_Chunk(destMerge));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(destMerge);
end;


function  ILBM_writeDestMerge(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  destMerge : PILBM_DestMerge;
begin
  destMerge := PILBM_DestMerge(chunk);

  if notvalid(IFF_writeUByte(filehandle, destMerge^.depth, CHUNKID_DEST, 'depth'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, destMerge^.pad1, CHUNKID_DEST, 'pad1'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, destMerge^.planePick, CHUNKID_DEST, 'planePick'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, destMerge^.planeOnOff, CHUNKID_DEST, 'planeOnOff'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, destMerge^.planeMask, CHUNKID_DEST, 'planeMask'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkDestMerge(const chunk: PIFF_Chunk): cint;
var
  destMerge : PILBM_DestMerge;
begin
  destMerge := PILBM_DestMerge(chunk);

  if (destMerge^.pad1 <> 0)
  then IFF_error('WARNING: "DEST".pad1 is not 0!' + LineEnding);

  result := _TRUE_;
end;


procedure ILBM_freeDestMerge(chunk: PIFF_Chunk);
begin
  { intentional left blank }
end;


procedure ILBM_printDestMerge(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  destMerge : PILBM_DestMerge;
begin
  destMerge := PILBM_DestMerge(chunk);

  IFF_printIndent(getstdouthandle, indentLevel, 'depth = %u;'      + LineEnding, [destMerge^.depth]);
  IFF_printIndent(getstdouthandle, indentLevel, 'pad1 = %u;'       + LineEnding, [destMerge^.pad1]);
  IFF_printIndent(getstdouthandle, indentLevel, 'planePick = %u;'  + LineEnding, [destMerge^.planePick]);
  IFF_printIndent(getstdouthandle, indentLevel, 'planeOnOff = %u;' + LineEnding, [destMerge^.planeOnOff]);
  IFF_printIndent(getstdouthandle, indentLevel, 'planeMask = %u;'  + LineEnding, [destMerge^.planeMask]);
end;


function  ILBM_compareDestMerge(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  destMerge1 : PILBM_DestMerge;
  destMerge2 : PILBM_DestMerge;
begin
  destMerge1 := PILBM_DestMerge(chunk1);
  destMerge2 := PILBM_DestMerge(chunk2);

  if (destMerge1^.depth <> destMerge2^.depth)
  then exit(_FALSE_);

  if(destMerge1^.pad1 <> destMerge2^.pad1)
  then exit(_FALSE_);

  if(destMerge1^.planePick <> destMerge2^.planePick)
  then exit(_FALSE_);

  if(destMerge1^.planeOnOff <> destMerge2^.planeOnOff)
  then exit(_FALSE_);

  if(destMerge1^.planeMask <> destMerge2^.planeMask)
  then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        drange.h
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_DRNG  = 'DRNG';


procedure increaseChunkSizeWithFades(drange: PILBM_DRange);
begin
  drange^.chunkSize := drange^.chunkSize + 2 * sizeof(TIFF_UByte);
end;


function  ILBM_createDRange(flags: TIFF_Word): PILBM_DRange;
var
  drange    : PILBM_DRange;
begin
  drange := PILBM_DRange(IFF_allocateChunk(CHUNKID_DRNG, sizeof(TILBM_DRange)));

  if (drange <> nil) then
  begin
    drange^.chunkSize := 2 * sizeof(TIFF_UByte) + 2 * sizeof(TIFF_Word) + 2 * sizeof(TIFF_UByte);

    drange^.flags := flags;
    drange^.ntrue := 0;
    drange^.nregs := 0;
    drange^.dcolor := nil;
    drange^.dindex := nil;
    drange^.nfades := 0;
    drange^.pad := 0;
    drange^.dfade := nil;

    if ( (flags and ILBM_RNG_FADE) = ILBM_RNG_FADE )
    then increaseChunkSizeWithFades(drange);
  end;

  result := drange;
end;


function  ILBM_addDColorToDRange(drange: PILBM_DRange): PILBM_DColor;
var
  dcolor : PILBM_DColor;
begin
  drange^.dcolor := PILBM_DColor(ReAllocMem(drange^.dcolor, (drange^.ntrue + 1) * sizeof(TILBM_DColor)));
  dcolor := @drange^.dcolor[drange^.ntrue];
  inc(drange^.ntrue);

  drange^.chunkSize := drange^.chunkSize + sizeof(TILBM_DColor);

  result := dcolor;
end;


function  ILBM_addDIndexToDRange(drange: PILBM_DRange): PILBM_DIndex;
var
  dindex    : PILBM_DIndex;
begin
  drange^.dindex := PILBM_DIndex(ReAllocMem(drange^.dindex, (drange^.nregs + 1) * sizeof(TILBM_DIndex)));
  dindex := @drange^.dindex[drange^.nregs];
  inc(drange^.nregs);

  drange^.chunkSize := drange^.chunkSize + sizeof(TILBM_DIndex);

  result := dindex;
end;


function  ILBM_addDFadeToDRange(drange: PILBM_DRange): PILBM_DFade;
var
  dfade : PILBM_DFade;
begin
  drange^.dfade := PILBM_DFade(ReAllocMem(drange^.dfade, (drange^.nfades + 1) * sizeof(TILBM_DFade)));
  dfade := @drange^.dfade[drange^.nfades];
  inc(drange^.nfades);

  drange^.chunkSize := drange^.chunkSize + sizeof(TILBM_DFade);

  result := dfade;
end;


function  ILBM_readDRange(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  drange        : PILBM_DRange;
var
  nregs, ntrue  : TIFF_UByte;
  i             : cuint;
  dcolor        : PILBM_DColor;
  dindex        : PILBM_DIndex;
  nfades        : TIFF_UByte;
  dfade         : PILBM_DFade;
begin
  drange := ILBM_createDRange(0);

  if (drange <> nil) then
  begin
    if notvalid(IFF_readUByte(filehandle, @drange^.min, CHUNKID_DRNG, 'min')) then
    begin
      ILBM_free(PIFF_Chunk(drange));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @drange^.max, CHUNKID_DRNG, 'max')) then
    begin
      ILBM_free(PIFF_Chunk(drange));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @drange^.rate, CHUNKID_DRNG, 'rate')) then
    begin
      ILBM_free(PIFF_Chunk(drange));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @drange^.flags, CHUNKID_DRNG, 'flags')) then
    begin
      ILBM_free(PIFF_Chunk(drange));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @ntrue, CHUNKID_DRNG, 'ntrue')) then
    begin
      ILBM_free(PIFF_Chunk(drange));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @nregs, CHUNKID_DRNG, 'nregs')) then
    begin
      ILBM_free(PIFF_Chunk(drange));
      exit(nil);
    end;

    i := 0;
    while (i < ntrue) do
    begin
      dcolor := ILBM_addDColorToDRange(drange);

      if notvalid(IFF_readUByte(filehandle, @dcolor^.cell, CHUNKID_DRNG, 'dcolor.cell')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @dcolor^.r, CHUNKID_DRNG, 'dcolor.r')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @dcolor^.g, CHUNKID_DRNG, 'dcolor.g')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @dcolor^.b, CHUNKID_DRNG, 'dcolor.b')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      inc(i);
    end;

    i := 0;
    while (i < nregs) do
    begin
      dindex := ILBM_addDIndexToDRange(drange);

      if notvalid(IFF_readUByte(filehandle, @dindex^.cell, CHUNKID_DRNG, 'dindex.cell')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @dindex^.index, CHUNKID_DRNG, 'dindex.index')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      inc(i);
    end;

    if ( (drange^.flags and ILBM_RNG_FADE) = ILBM_RNG_FADE ) then
    begin

      increaseChunkSizeWithFades(drange);

      if notvalid(IFF_readUByte(filehandle, @nfades, CHUNKID_DRNG, 'nfades')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      if notvalid(IFF_readUByte(filehandle, @drange^.pad, CHUNKID_DRNG, 'pad')) then
      begin
        ILBM_free(PIFF_Chunk(drange));
        exit(nil);
      end;

      i := 0;
      while (i < nfades) do
      begin
        dfade := ILBM_addDFadeToDRange(drange);

        if notvalid(IFF_readUByte(filehandle, @dfade^.cell, CHUNKID_DRNG, 'dfade.cell')) then
        begin
          ILBM_free(PIFF_Chunk(drange));
          exit(nil);
        end;

        if notvalid(IFF_readUByte(filehandle, @dfade^.fade, CHUNKID_DRNG, 'dfade.fade')) then
        begin
          ILBM_free(PIFF_Chunk(drange));
          exit(nil);
        end;

        inc(i);
      end;
    end;
  end;

  result := PIFF_Chunk(drange);
end;


function  ILBM_writeDRange(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  drange    : PILBM_DRange;
  i         : cuint;
var
  dcolor    : PILBM_DColor;
  dindex    : PILBM_DIndex;
  dfade     : PILBM_DFade;
begin
  drange := PILBM_DRange(chunk);

  if notvalid(IFF_writeUByte(filehandle, drange^.min, CHUNKID_DRNG, 'min'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, drange^.max, CHUNKID_DRNG, 'max'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, drange^.rate, CHUNKID_DRNG, 'rate'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, drange^.flags, CHUNKID_DRNG, 'flags'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, drange^.ntrue, CHUNKID_DRNG, 'ntrue'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUByte(filehandle, drange^.nregs, CHUNKID_DRNG, 'nregs'))
  then exit(_FALSE_);

  i := 0;
  while (i < drange^.ntrue) do
  begin
    dcolor := @drange^.dcolor[i];

    if notvalid(IFF_writeUByte(filehandle, dcolor^.cell, CHUNKID_DRNG, 'dcolor.cell'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, dcolor^.r, CHUNKID_DRNG, 'dcolor.r'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, dcolor^.g, CHUNKID_DRNG, 'dcolor.g'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, dcolor^.b, CHUNKID_DRNG, 'dcolor.b'))
    then exit(_FALSE_);

    inc(i);
  end;

  i := 0;
  while (i < drange^.nregs) do
  begin
    dindex := @drange^.dindex[i];

    if notvalid(IFF_writeUByte(filehandle, dindex^.cell, CHUNKID_DRNG, 'dindex.cell'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, dindex^.index, CHUNKID_DRNG, 'dindex.index'))
    then exit(_FALSE_);

    inc(i);
  end;

  if ( (drange^.flags and ILBM_RNG_FADE) = ILBM_RNG_FADE) then
  begin
    if notvalid(IFF_writeUByte(filehandle, drange^.nfades, CHUNKID_DRNG, 'nfades'))
    then exit(_FALSE_);

    if notvalid(IFF_writeUByte(filehandle, drange^.pad, CHUNKID_DRNG, 'pad'))
    then exit(_FALSE_);

    i := 0;
    while (i < drange^.nfades) do
    begin
      dfade := @drange^.dfade[i];

      if notvalid(IFF_writeUByte(filehandle, dfade^.cell, CHUNKID_DRNG, 'dfade.cell'))
      then exit(_FALSE_);

      if notvalid(IFF_writeUByte(filehandle, dfade^.fade, CHUNKID_DRNG, 'dfade.fade'))
      then exit(_FALSE_);

      inc(i);
    end;
  end;

  result := _TRUE_;
end;


function  ILBM_checkDRange(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure ILBM_freeDRange(chunk: PIFF_Chunk);
var
  drange    : PILBM_DRange;
begin
  drange := PILBM_DRange(chunk);

  FreeMem(drange^.dcolor);
  FreeMem(drange^.dindex);
  FreeMem(drange^.dfade);
end;


procedure ILBM_printDRange(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  drange    : PILBM_DRange;
  i         : cuint;
begin
  drange := PILBM_DRange(chunk);

  IFF_printIndent(GetstdoutHandle, indentLevel, 'min = %u;'  + LineEnding, [drange^.min]);
  IFF_printIndent(GetstdoutHandle, indentLevel, 'max = %u;'  + LineEnding, [drange^.max]);
  IFF_printIndent(GetstdoutHandle, indentLevel, 'rate = %d;' + LineEnding, [drange^.rate]);
  IFF_printIndent(GetstdoutHandle, indentLevel, 'flags = %d;'+ LineEnding, [drange^.flags]);
  IFF_printIndent(GetstdoutHandle, indentLevel, 'ntrue = %u;'+ LineEnding, [drange^.ntrue]);
  IFF_printIndent(GetstdoutHandle, indentLevel, 'nregs = %u;'+ LineEnding, [drange^.nregs]);

  i := 0;
  while (i < drange^.ntrue) do
  begin
    IFF_printIndent(GetstdoutHandle, indentLevel, '{ cell = %u, r = %u, g = %u, b = %u }' + LineEnding, [drange^.dcolor[i].cell, drange^.dcolor[i].r, drange^.dcolor[i].g, drange^.dcolor[i].b]);
    inc(i);
  end;

  i := 0;
  while (i < drange^.nregs) do
  begin
    IFF_printIndent(GetstdoutHandle, indentLevel, '{ cell = %u, index = %u }' + LineEnding, [drange^.dindex[i].cell, drange^.dindex[i].index]);
    inc(i);
  end;

  if ( (drange^.flags and ILBM_RNG_FADE) = ILBM_RNG_FADE ) then
  begin
    IFF_printIndent(GetstdoutHandle, indentLevel, 'nfades = %u;' + LineEnding, [drange^.nfades]);
    IFF_printIndent(GetstdoutHandle, indentLevel, 'pad = %u;' + LineEnding, [drange^.pad]);

    i := 0;
    while (i < drange^.nfades) do
    begin
      IFF_printIndent(GetstdoutHandle, indentLevel, '{ cell = %u, fade = %u }' + LineEnding, [drange^.dfade[i].cell, drange^.dfade[i].fade]);
      inc(i);
    end;
  end;
end;


function  ILBM_compareDRange(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  drange1   : PILBM_DRange;
  drange2   : PILBM_DRange;
  i         : cuint;
var
  dcolor1   : PILBM_DColor;
  dcolor2   : PILBM_DColor;
  dindex1   : PILBM_DIndex;
  dindex2   : PILBM_DIndex;
  dfade1    : PILBM_DFade;
  dfade2    : PILBM_DFade;
begin
  drange1 := PILBM_DRange(chunk1);
  drange2 := PILBM_DRange(chunk2);

  if (drange1^.min <> drange2^.min)
  then exit(_FALSE_);

  if(drange1^.max <> drange2^.max)
  then exit(_FALSE_);

  if(drange1^.rate <> drange2^.rate)
  then exit(_FALSE_);

  if(drange1^.flags <> drange2^.flags)
  then exit(_FALSE_);

  if(drange1^.ntrue <> drange2^.ntrue)
  then exit(_FALSE_);

  if(drange1^.nregs <> drange2^.nregs)
  then exit(_FALSE_);

  i := 0;
  while (i < drange1^.ntrue) do
  begin
    dcolor1 := @drange1^.dcolor[i];
    dcolor2 := @drange2^.dcolor[i];

    if(dcolor1^.cell <> dcolor2^.cell)
    then exit(_FALSE_);

    if(dcolor1^.r <> dcolor2^.r)
    then exit(_FALSE_);

    if(dcolor1^.g <> dcolor2^.g)
    then exit(_FALSE_);

    if(dcolor1^.b <> dcolor2^.b)
    then exit(_FALSE_);

    inc(i);
  end;

  i := 0;
  while (i < drange1^.nregs) do
  begin
    dindex1 := @drange1^.dindex[i];
    dindex2 := @drange2^.dindex[i];

    if(dindex1^.cell <> dindex2^.cell)
    then exit(_FALSE_);

    if(dindex1^.index <> dindex2^.index)
    then exit(_FALSE_);

    inc(i);
  end;

  if ( (drange1^.flags and ILBM_RNG_FADE) = ILBM_RNG_FADE) then
  begin
    if(drange1^.nfades <> drange2^.nfades)
    then exit(_FALSE_);

    i := 0;
    while (i < drange1^.nfades) do
    begin
      dfade1 := @drange1^.dfade[i];
      dfade2 := @drange2^.dfade[i];

      if (dfade1^.cell <> dfade2^.cell)
      then exit(_FALSE_);

      if(dfade1^.fade <> dfade2^.fade)
      then exit(_FALSE_);

      inc(i);
    end;
  end;

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        grab.h
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_GRAB  = 'GRAB';


function  ILBM_createGrab: PILBM_Point2D;
var
  point2d   : PILBM_Point2D;
begin
  point2d := PILBM_Point2D(IFF_allocateChunk(CHUNKID_GRAB, sizeof(TILBM_Point2D)));

  if (point2d <> nil)
  then point2d^.chunkSize := 2 * sizeof(TIFF_Word);

  result := point2d;
end;


function  ILBM_readGrab(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  point2d   : PILBM_Point2D;
begin
  point2d := ILBM_createGrab();

  if (point2d <> nil) then
  begin
    if notvalid(IFF_readWord(filehandle, @point2d^.x, CHUNKID_GRAB, 'x')) then
    begin
      ILBM_free(PIFF_Chunk(point2d));
      exit(nil);
    end;

    if notvalid(IFF_readWord(filehandle, @point2d^.y, CHUNKID_GRAB, 'y')) then
    begin
      ILBM_free(PIFF_Chunk(point2d));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(point2d);
end;


function  ILBM_writeGrab(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  point2d   : PILBM_Point2D;
begin
  point2d := PILBM_Point2D(chunk);

  if notvalid(IFF_writeWord(filehandle, point2d^.x, CHUNKID_GRAB, 'x'))
  then exit(_FALSE_);

  if notvalid(IFF_writeWord(filehandle, point2d^.y, CHUNKID_GRAB, 'y'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkGrab(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure ILBM_freeGrab(chunk: PIFF_Chunk);
begin
  { Intentional left blank }
end;


procedure ILBM_printGrab(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  point2d   : PILBM_Point2D;
begin
  point2d := PILBM_Point2D(chunk);

  IFF_printIndent(getstdouthandle, indentLevel, 'x = %d;' + LineEnding, [point2d^.x]);
  IFF_printIndent(getstdouthandle, indentLevel, 'y = %d;' + LineEnding, [point2d^.y]);
end;


function  ILBM_compareGrab(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  point2d1   : PILBM_Point2D;
  point2d2   : PILBM_Point2D;
begin
  point2d1 := PILBM_Point2D(chunk1);
  point2d2 := PILBM_Point2D(chunk2);

  if (point2d1^.x <> point2d2^.x)
  then exit(_FALSE_);

  if(point2d1^.y <> point2d2^.y)
  then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        viewport.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_CAMG = 'CAMG';


function  ILBM_createViewport: PILBM_Viewport;
var
  viewport : PILBM_Viewport;
begin
  viewport := PILBM_Viewport(IFF_allocateChunk(CHUNKID_CAMG, sizeof(TILBM_Viewport)));

  if (viewport <> nil)
  then viewport^.chunkSize := sizeof(TIFF_Long);

  result := viewport;
end;


function  ILBM_readViewport(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  viewport : PILBM_Viewport;
begin
  viewport := ILBM_createViewport();

  if (viewport <> nil) then
  begin
    if notvalid(IFF_readLong(filehandle, @viewport^.viewportMode, CHUNKID_CAMG, 'viewportMode')) then
    begin
      ILBM_free(PIFF_Chunk(viewport));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(viewport);
end;


function  ILBM_writeViewport(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  viewport : PILBM_Viewport;
begin
  viewport := PILBM_Viewport(chunk);

  if notvalid(IFF_writeLong(filehandle, viewport^.viewportMode, CHUNKID_CAMG, 'viewportMode')) 
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkViewport(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure ILBM_freeViewport(chunk: PIFF_Chunk);
begin
  { intentionally left blank }
end;


procedure ILBM_printViewport(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  viewport : PILBM_Viewport;
begin
  viewport := PILBM_Viewport(chunk);

  IFF_printIndent(getstdouthandle, indentLevel, 'viewportMode = %x;' + LineEnding, [viewport^.viewportMode]);
end;


function  ILBM_compareViewport(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  viewport1 : PILBM_Viewport;
  viewport2 : PILBM_Viewport;
begin
  viewport1 := PILBM_Viewport(chunk1);
  viewport2 := PILBM_Viewport(chunk2);

  if (viewport1^.viewportMode <> viewport2^.viewportMode)
  then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        sprite.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_SPRT = 'SPRT';


function  ILBM_createSprite: PILBM_Sprite;
var
  sprite    : PILBM_Sprite;
begin
  sprite := PILBM_Sprite(IFF_allocateChunk(CHUNKID_SPRT, sizeof(TILBM_Sprite)));

  if (sprite <> nil)
  then sprite^.chunkSize := sizeof(TIFF_UWord);

  result := sprite;
end;


function  ILBM_readSprite(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  sprite    : PILBM_Sprite;
begin
  sprite := ILBM_createSprite();

  if (sprite <> nil) then
  begin
    if notvalid(IFF_readUWord(filehandle, @sprite^.spritePrecedence, CHUNKID_SPRT, 'spritePrecedence')) then
    begin
      ILBM_free(PIFF_Chunk(sprite));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(sprite);
end;


function  ILBM_writeSprite(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  sprite    : PILBM_Sprite;
begin
  sprite := PILBM_Sprite(chunk);

  if notvalid(IFF_writeUWord(filehandle, sprite^.spritePrecedence, CHUNKID_SPRT, 'spritePrecedence'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  ILBM_checkSprite(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure ILBM_freeSprite(chunk: PIFF_Chunk);
begin
  { intentional left blank }
end;


procedure ILBM_printSprite(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  sprite    : PILBM_Sprite;
begin
  sprite := PILBM_Sprite(chunk);

  IFF_printIndent(getstdouthandle, indentLevel, 'spritePrecedence = %u;' + LineEnding, [sprite^.spritePrecedence]);
end;


function  ILBM_compareSprite(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  sprite1    : PILBM_Sprite;
  sprite2    : PILBM_Sprite;
begin
  sprite1 := PILBM_Sprite(chunk1);
  sprite2 := PILBM_Sprite(chunk2);

  if (sprite1^.spritePrecedence <> sprite2^.spritePrecedence)
  then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        ilbmimage.c
//////////////////////////////////////////////////////////////////////////////



function  ILBM_createImage(formType: PIFF_ID): PILBM_Image;
var
  image : PILBM_Image;
begin
{.$WARNING TODO}
//  image := PILBM_Image(AllocMem(1, sizeof(TILBM_Image)));
  image := PILBM_Image(AllocMem(1 * sizeof(TILBM_Image)));

  if (image <> nil)
  then IFF_createId(image^.formType, formType);

  result := image;
end;


function  createImageFromForm(form: PIFF_Form; formType: PIFF_ID): PILBM_Image;
var
  image : PILBM_Image;
begin
  image := PILBM_Image(AllocMem(sizeof(TILBM_Image)));

  if (image <> nil) then
  begin
    IFF_createId(image^.formType, formType);
    image^.bitMapHeader := PILBM_BitMapHeader( IFF_getChunkFromForm(form, 'BMHD'));
    image^.colorMap     := PILBM_ColorMap    ( IFF_getChunkFromForm(form, 'CMAP'));
    image^.cmykMap      := PILBM_CMYKMap     ( IFF_getChunkFromForm(form, 'CMYK'));
    image^.point2d      := PILBM_Point2D     ( IFF_getChunkFromForm(form, 'GRAB'));
    image^.destMerge    := PILBM_DestMerge   ( IFF_getChunkFromForm(form, 'DEST'));
    image^.sprite       := PILBM_Sprite      ( IFF_getChunkFromForm(form, 'SPRT'));
    image^.viewport     := PILBM_Viewport    ( IFF_getChunkFromForm(form, 'CAMG'));
    image^.colorRange   := PPILBM_ColorRange ( IFF_getChunksFromForm(form, 'CRNG', @image^.colorRangeLength));
    image^.drange       := PPILBM_DRange     ( IFF_getChunksFromForm(form, 'DRNG', @image^.drangeLength));
    image^.cycleInfo    := PPILBM_CycleInfo  ( IFF_getChunksFromForm(form, 'CCRT', @image^.cycleInfoLength));
    image^.body         := PIFF_RawChunk     ( IFF_getChunkFromForm(form, 'BODY'));
    image^.bitplanes    := PIFF_RawChunk     ( IFF_getChunkFromForm(form, 'ABIT'));
  end;

  result := image;
end;


function  ILBM_extractImages(chunk: PIFF_Chunk; imagesLength: pcuint): PPILBM_Image;
var
  ilbmFormsLength   : cuint;
  ilbmForms         : PPIFF_Form;
  pbmFormsLength    : cuint;
  pbmForms          : PPIFF_Form;
  acbmFormsLength   : cuint;
  acbmForms         : PPIFF_Form;

  images            : PPILBM_Image;
  i, offset         : cuint;

  ilbmForm          : PIFF_Form;
  pbmForm           : PIFF_Form;
  acbmForm          : PIFF_Form;
begin
  ilbmForms := IFF_searchForms(chunk, 'ILBM', @ilbmFormsLength);
  pbmForms  := IFF_searchForms(chunk, 'PBM ', @pbmFormsLength);
  acbmForms := IFF_searchForms(chunk, 'ACBM', @acbmFormsLength);

  imagesLength^ := ilbmFormsLength + pbmFormsLength + acbmFormsLength;

  if ( imagesLength^ = 0) then
  begin
    IFF_error('No form with formType: "ILBM", "PBM " or "ACBM" found!' + LineEnding);
    exit(nil);
  end
  else
  begin
    images := PPILBM_Image(AllocMem(imagesLength^ * sizeof(PILBM_Image)));

    if (images <> nil) then
    begin
      //* Extract all ILBM images */
      i := 0;
      while (i < ilbmFormsLength) do
      begin
        ilbmForm := ilbmForms[i];
        images[i] := createImageFromForm(ilbmForm, 'ILBM');
        inc(i);
      end;

      offset := ilbmFormsLength;

      //* Extract all PBM images */
      i := 0;
      while (i < pbmFormsLength) do
      begin
        pbmForm := pbmForms[i];
        images[offset + i] := createImageFromForm(pbmForm, 'PBM ');
        inc(i);
      end;

      offset := offset + pbmFormsLength;

      //* Extract all ACBM images */
      i := 0;
      while (i < acbmFormsLength) do
      begin
        acbmForm := acbmForms[i];
        images[offset + i] := createImageFromForm(acbmForm, 'ACBM');
        inc(i);
      end;

      //* Clean up stuff */
      FreeMem(ilbmForms);
      FreeMem(pbmForms);
      FreeMem(acbmForms);
    end;

    //* Return generated images array */
    exit(images);
  end;
end;


function  ILBM_convertImageToForm(image: PILBM_Image): PIFF_Form;
var
  form  : PIFF_Form;
  i     : cuint;
begin
  form := IFF_createForm(@image^.formType);

  if (form <> nil) then
  begin
    if(image^.bitMapHeader <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.bitMapHeader));

    if(image^.colorMap <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.colorMap));

    if(image^.cmykMap <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.cmykMap));

    if (image^.point2d <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.point2d));

    if (image^.destMerge <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.destMerge));

    if (image^.sprite <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.sprite));

    if (image^.viewport <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.viewport));

    i := 0;
    while (i < image^.colorRangeLength) do
    begin
      IFF_addToForm(form, PIFF_Chunk(image^.colorRange[i]));
      inc(i);
    end;

    i := 0;
    while (i < image^.drangeLength) do
    begin
      IFF_addToForm(form, PIFF_Chunk(image^.drange[i]));
      inc(i);
    end;

    i := 0;
    while (i < image^.cycleInfoLength) do
    begin
      IFF_addToForm(form, PIFF_Chunk(image^.cycleInfo[i]));
      inc(i);
    end;

    if (image^.body <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.body));
        
    if (image^.bitplanes <> nil)
    then IFF_addToForm(form, PIFF_Chunk(image^.bitplanes));
  end;

  result := form;
end;


procedure ILBM_freeImage(image: PILBM_Image);
begin
  FreeMem(image^.colorRange);
  FreeMem(image^.drange);
  FreeMem(image^.cycleInfo);
  FreeMem(image);
end;


procedure ILBM_freeImages(images: PPILBM_Image; const imagesLength: cuint);
var
  i : cuint;
begin
  i := 0;
  while (i < imagesLength) do
  begin
    ILBM_freeImage(images[i]);
    inc(i);
  end;

  FreeMem(images);
end;


function  ILBM_checkImage(const image: PILBM_Image): cint;
begin
  if (image^.bitMapHeader = nil) then
  begin
    IFF_error('Error: no bitmap header defined!' + LineEnding);
    exit(_FALSE_);
  end;

  result := _TRUE_;
end;


function  ILBM_checkImages(const chunk: PIFF_Chunk; images: PPILBM_Image; const imagesLength: cuint): cint;
var
  i : cuint;
begin
  //* First, check the ILBM file for corectness */
  if notvalid(ILBM_check(chunk))
  then exit(_FALSE_);

  //* Check the individual images inside the IFF file */
  i := 0;
  while (i < imagesLength) do
  begin
    if notvalid(ILBM_checkImage(images[i]))
    then exit(_FALSE_);

    inc(i);
  end;

  //* Everything seems to be correct */
  result := _TRUE_;
end;


procedure ILBM_addColorRangeToImage(image: PILBM_Image; colorRange: PILBM_ColorRange);
begin
  image^.colorRange := PPILBM_ColorRange(ReAllocMem(image^.colorRange, (image^.colorRangeLength + 1) * sizeof(PILBM_ColorRange)));
  image^.colorRange[image^.colorRangeLength] := colorRange;
  inc(image^.colorRangeLength);
end;


procedure ILBM_addDRangeToImage(image: PILBM_Image; drange: PILBM_DRange);
begin
  image^.drange := PPILBM_DRange(ReAllocMem(image^.drange, (image^.drangeLength + 1) * sizeof(PILBM_DRange)));
  image^.drange[image^.drangeLength] := drange;
  inc(image^.drangeLength);
end;


procedure ILBM_addCycleInfoToImage(image: PILBM_Image; cycleInfo: PILBM_CycleInfo);
begin
  image^.cycleInfo := PPILBM_CycleInfo(ReAllocMem(image^.cycleInfo, (image^.cycleInfoLength + 1) * sizeof(PILBM_CycleInfo)));
  image^.cycleInfo[image^.cycleInfoLength] := cycleInfo;
  inc(image^.cycleInfoLength);
end;


function  ILBM_imageIsILBM(const image: PILBM_Image): cint;
begin
  Result := Ord(IFF_compareId(image^.formType, 'ILBM') = 0);
end;


function  ILBM_imageIsACBM(const image: PILBM_Image): cint;
begin
  result := Ord(IFF_compareId(image^.formType, 'ACBM') = 0);
end;


function  ILBM_imageIsPBM(const image: PILBM_Image): cint;
begin
  result := Ord(IFF_compareId(image^.formType, 'PBM ') = 0);
end;


function  ILBM_calculateRowSize(const image: PILBM_Image): cuint;
var
  rowSizeInWords  : cuint;
begin
  rowSizeInWords := image^.bitMapHeader^.w div 16;

  if (image^.bitMapHeader^.w mod 16 <> 0)
  then inc(rowSizeInWords);

  result := (rowSizeInWords * 2);
end;


function  ILBM_generateGrayscaleColorMap(const image: PILBM_Image): PILBM_ColorMap;
var
  colorMap      : PILBM_ColorMap;
  numOfColors   : cuint;
  i             : cuint;
  colorRegister : PILBM_ColorRegister;
  value         : cuint;
begin
  colorMap := ILBM_createColorMap();

  if (colorMap <> nil) then
  begin
    numOfColors := ILBM_calculateNumOfColors(image^.bitMapHeader);

    i := 0;
    while (i < numOfColors) do
    begin
      colorRegister := ILBM_addColorRegisterInColorMap(colorMap);
      value := i * $ff div (numOfColors - 1);

      colorRegister^.red   := value;
      colorRegister^.green := value;
      colorRegister^.blue  := value;

      inc(i);
    end;
  end;

  result := colorMap;
end;



//////////////////////////////////////////////////////////////////////////////
//        byterun.c
//////////////////////////////////////////////////////////////////////////////



procedure ILBM_unpackByteRun(image: PILBM_Image);
var
  body                  : PIFF_RawChunk;
  count                 : cuint;
  readBytes             : cuint;
  chunkSize             : TIFF_ULONG;
  decompressedChunkData : PIFF_UByte;
  byt                   : cint;
  i                     : cint;
  ubyt                  : TIFF_UByte;
begin
  body := image^.body;

  //* Only perform decompression if the body is compressed and present */
  if ( (image^.bitMapHeader^.compression = ILBM_CMP_BYTE_RUN) and (body <> nil) ) then
  begin
    //* Counters */

    count := 0;
    readBytes := 0;

    //* Allocate decompressed chunk attributes */

    chunkSize := ILBM_calculateRowSize(image) * image^.bitMapHeader^.h * image^.bitMapHeader^.nPlanes;
    decompressedChunkData := PIFF_UByte(AllocMem(chunkSize * sizeof(TIFF_UByte)));

    //* Perform RLE decompression */

    while (readBytes < body^.chunkSize) do
    begin
      byt := TIFF_Byte(body^.chunkData[readBytes]);
      inc(readBytes);

      if ( (byt >= 0) and (byt <= 127)) then //* Take the next byte bytes + 1 literally */
      begin
        for i := 0 to Pred(byt) + 1 do
        begin
          decompressedChunkData[count] := body^.chunkData[readBytes];
          inc(readBytes);
          inc(count);
        end;
      end
      else if ( (byt >= -127) and (byt <= -1)) then //* Replicate the next byte, -byte + 1 times */
      begin
        ubyt := body^.chunkData[readBytes];
        inc(readBytes);

        for i := 0 to Pred(-byt) + 1 do
        begin
          decompressedChunkData[count] := ubyt;
          inc(count);
        end;
      end
      else
        IFF_error('Unknown byte run encoding byte!' + LineEnding);
    end;

    //* Free the compressed chunk data */
    FreeMem(body^.chunkData);

    //* Add decompressed chunk data to the body chunk */
    IFF_setRawChunkData(body, decompressedChunkData, chunkSize);

    //* Recursively update the chunk sizes */
    IFF_updateChunkSizes(PIFF_Chunk(body));

    //* Change compression flag, since the body is no longer compressed anymore */
    image^.bitMapHeader^.compression := ILBM_CMP_NONE;
  end;
end;


Type
  TPackMode =
  (
    MODE_UNKNOWN = 0,
    MODE_RUN = 1,
    MODE_DUMP = 2,
    MODE_MAYBE_RUN = 3
  );


function  addRun(equalCount: cuint; compressedChunkData: PIFF_UByte; count: cuint; previousByte: TIFF_UByte): cint;
var
  byt : ShortInt;
begin
  byt := 1 - equalCount;

  compressedChunkData[count] := byt;
  inc(count);

  compressedChunkData[count] := previousByte;
  Inc(count);

  result := count;
end;


function addDump(equalCount: cuint; compressedChunkData: PIFF_UByte; count: cuint; uncompressedChunkData: PIFF_UByte; readBytes: cuint): cint;
var
  i : cuint;
begin
  compressedChunkData[count] := equalCount - 1;
  inc(count);

  for i := (readBytes - equalCount) to Pred(readBytes) do
  begin
    compressedChunkData[count] := uncompressedChunkData[i];
    inc(count);
  end;

  result := count;
end;


function  packRow(uncompressedChunkData: PIFF_UByte; compressedChunkData: PIFF_UByte; uncompressedOffset: cuint; compressedOffset: cuint; const rowSize: cuint): cint;
var
  previousByte, 
  currentByte   : TIFF_UByte;
  mode          : TPackMode;
  equalCount    : cuint;
  readBytes     : cuint;
  count         : cuint;
begin    
  mode := MODE_UNKNOWN;
  equalCount := 1;

  readBytes := uncompressedOffset;
  count := compressedOffset;

  //* Read first byte */
  currentByte := uncompressedChunkData[readBytes];
  inc(readBytes);

  while (readBytes < uncompressedOffset + rowSize) do
  begin
    //* Shift previous byte */
    previousByte := currentByte;

    //* Read next byte */
    currentByte := uncompressedChunkData[readBytes];
    inc(readBytes);

    case (mode) of
      MODE_UNKNOWN:
      begin
        inc(equalCount);

        if (previousByte = currentByte)
        then mode := MODE_RUN
        else mode := MODE_DUMP;
      end;

      MODE_RUN:
      begin
        if (previousByte = currentByte)
        then inc(equalCount)
        else
        begin
          count := addRun(equalCount, compressedChunkData, count, previousByte);

          equalCount := 1;
          mode := MODE_UNKNOWN;
        end;
      end;

      MODE_DUMP:
      begin
        if (previousByte = currentByte)
        then mode := MODE_MAYBE_RUN
        else inc(equalCount);
      end;

      MODE_MAYBE_RUN:
      begin
        if (previousByte = currentByte) then
        begin
          inc(equalCount);

          count := addDump(equalCount, compressedChunkData, count, uncompressedChunkData, readBytes - 3);

          equalCount := 3;
          mode := MODE_RUN;
        end
        else
        begin
          equalCount := equalCount + 2;
          mode := MODE_DUMP;
        end;
      end;
    end;  // case
  end;

  //* Write remaining bytes */

  case (mode) of
    MODE_RUN:
    begin
      count := addRun(equalCount, compressedChunkData, count, previousByte);
    end;
    MODE_DUMP,
    MODE_UNKNOWN:
    begin
      count := addDump(equalCount, compressedChunkData, count, uncompressedChunkData, readBytes);
    end;
    MODE_MAYBE_RUN:
    begin
      inc(equalCount);
      count := addDump(equalCount, compressedChunkData, count, uncompressedChunkData, readBytes);
    end;
  end; // case

  result := count;
end;


procedure ILBM_packByteRun(image: PILBM_Image);
var
  body      : PIFF_RawChunk;
  readBytes : cuint;
  rowSize   : cuint;
  compressedChunkData   : PIFF_UByte;
  count     : cuint;
begin
  body := image^.body;

  //* Only perform decompression if the body is decompressed and present */
  if ( (image^.bitMapHeader^.compression = ILBM_CMP_NONE) and (body <> nil) ) then
  begin
    readBytes := 0;
    rowSize := ILBM_calculateRowSize(image);
    compressedChunkData := PIFF_UByte(AllocMem(body^.chunkSize * sizeof(TIFF_UByte)));  //* Scanline + 1 * height */
    count := 0;

    while (readBytes < body^.chunkSize) do
    begin
      count := packRow(body^.chunkData, compressedChunkData, readBytes, count, rowSize);
      readBytes := readBytes + rowSize;
    end;

    //* We can shrink the size of the data, because compression makes it in most cases smaller */
    compressedChunkData := PIFF_UByte(ReAllocMem(compressedChunkData, count * sizeof(TIFF_UByte)));

    //* Free the decompressed body data */
    FreeMem(body^.chunkData);

    //* Attach compressed chunk data to the chunk */
    IFF_setRawChunkData(body, compressedChunkData, count);

    //* Recursively update the chunk sizes */
    IFF_updateChunkSizes(PIFF_Chunk(body));

    //* Change compression flag, since the body is compressed now */
    image^.bitMapHeader^.compression := ILBM_CMP_BYTE_RUN;
  end;
end;



//////////////////////////////////////////////////////////////////////////////
//        interleave.c
//////////////////////////////////////////////////////////////////////////////



const
  MAX_NUM_OF_BITPLANES = 32;


procedure ILBM_deinterleaveToBitplaneMemory(const image: PILBM_Image; bitplanePointers: PPIFF_UByte);
var
  i, j      : cuint;
  count     : cint;
  hOffset   : cint;
  rowSize   : cuint;
begin
  if (image^.body <> nil) then
  begin
    count := 0;     //* Offset in the interleaved source */
    hOffset := 0;   //* Horizontal offset in resulting bitplanes */
    rowSize := ILBM_calculateRowSize(image);

    i := 0;
    while (i < image^.bitMapHeader^.h) do
    begin
      j := 0;
      while (j < image^.bitMapHeader^.nPlanes) do
      begin
        memcpy(bitplanePointers[j] + hOffset, image^.body^.chunkData + count, rowSize);
        count := count + rowSize;

        inc(j);
      end;

      hOffset := hOffset + rowSize;

      inc(i);
    end;
  end;
end;


function  ILBM_deinterleave(const image: PILBM_Image): PIFF_UByte;
var
  nPlanes       : TIFF_UByte;
  bitplaneSize  : cuint;
  res           : PIFF_UByte;
var
  i, offset     : cuint;
  bitplanePointers : array[0..Pred(MAX_NUM_OF_BITPLANES)] of PIFF_UByte;
begin
  nPlanes := image^.bitMapHeader^.nPlanes;
  bitplaneSize := ILBM_calculateRowSize(image) * image^.bitMapHeader^.h;
  res := PIFF_UByte(AllocMem(bitplaneSize * nPlanes * sizeof(TIFF_UByte)));

  if (res = nil)
  then exit(nil)
  else
  begin
    offset := 0;

    //* Set bitplane pointers */

    i := 0;
    while (i < nPlanes) do
    begin
      bitplanePointers[i] := res + offset;
      offset := offset + bitplaneSize;

      inc(i);
    end;

    //* Deinterleave and write results to the bitplane addresses */
    ILBM_deinterleaveToBitplaneMemory(image, bitplanePointers);

    //* Return result */
    result := res;
  end;
end;


function  ILBM_convertILBMToACBM(image: PILBM_Image): cint;
Var
  bitplaneData : PIFF_UByte;
begin
  if ( (IFF_compareId(image^.formType, 'ILBM') = 0) and (image^.bitMapHeader^.compression = ILBM_CMP_NONE) ) then
  begin
    if (image^.body <> nil) then
    begin
      //* Deinterleave the body */
      bitplaneData := ILBM_deinterleave(image);
      if (bitplaneData = nil)
      then exit(_FALSE_);

      //* The body chunk becomes a bitplanes chunk */
      IFF_createId(image^.body^.chunkId, 'ABIT');
      FreeMem(image^.body^.chunkData);
      image^.body^.chunkData := bitplaneData;

      //* The reference in the image to bitplanes is updated as well */
      image^.bitplanes := image^.body;
      image^.body := nil;
    end;

    //* Update form type to ACBM */
    IFF_createId(image^.formType, 'ACBM');
    IFF_createId(image^.bitMapHeader^.parent^.groupType, 'ACBM');

//    IFF_createId(image^.formType^, 'ACBM');
//    IFF_createId(image^.bitMapHeader^.parent^.groupType, 'ACBM');

    exit(_TRUE_);
  end
  else
    result := _FALSE_;
end;


function  ILBM_interleaveFromBitplaneMemory(const image: PILBM_Image; bitplanePointers: PPIFF_UByte): PIFF_UByte;
var
  rowSize                 : cuint;
  interleavedScanLineSize : cuint;
  chunkSize               : cuint;
  res                     : PIFF_UByte;
var
  i                       : cuint;
  bOffset                 : cuint;
  j, hOffset, count       : cuint;
begin
  rowSize := ILBM_calculateRowSize(image);
  interleavedScanLineSize := image^.bitMapHeader^.nPlanes * rowSize;
  chunkSize := interleavedScanLineSize * image^.bitMapHeader^.h;
  res := PIFF_UByte(AllocMem(chunkSize * sizeof(TIFF_UByte)));

  if (res = nil)
  Then exit(nil)
  else
  begin
    bOffset := 0;   //* Base offset in the interleaved bitplane data array */

    i := 0;
    while (i < image^.bitMapHeader^.nPlanes) do
    begin
      hOffset := bOffset;
      count   := 0;     //* Offset in the non-interleaved bitplane data array */

      j := 0;
      while (j < image^.bitMapHeader^.h) do
      begin
//        memcpy(result + hOffset, bitplanePointers[i] + count, rowSize);
        memcpy(res + hOffset, bitplanePointers[i] + count, rowSize);

        count := count + rowSize;
        hOffset := hOffset + interleavedScanLineSize;
        inc(j);
      end;

      bOffset := bOffset + rowSize;
      inc(i);
    end;

    //* Return the interleaved bitplane surface */
    result := res;
  end;
end;


function  ILBM_interleave(const image: PILBM_Image; bitplanes: PIFF_UByte): PIFF_UByte;
var
  bitplaneSize  : cuint;
  i             : cuint;
  offset        : cuint;
  bitplanePointers : array[0..Pred(MAX_NUM_OF_BITPLANES)] of PIFF_UByte;
begin
  bitplaneSize := ILBM_calculateRowSize(image) * image^.bitMapHeader^.h;
  offset := 0;

  //* Set bitplane pointers */
  i := 0;
  while (i < image^.bitMapHeader^.nPlanes) do
  begin
    bitplanePointers[i] := bitplanes + offset;
    offset := offset + bitplaneSize;

    inc(i);
  end;

  //* Deinterleave the bitplanes */
  result := ILBM_interleaveFromBitplaneMemory(image, bitplanePointers);
//  result := ILBM_interleaveFromBitplaneMemory(image, @bitplanePointers);
end;


function  ILBM_convertACBMToILBM(image: PILBM_Image): cint;
var
  bitplaneData : PIFF_UByte;
begin
  if ( (IFF_compareId(image^.formType, 'ACBM') = 0) and (image^.bitMapHeader^.compression = ILBM_CMP_NONE)) then
  begin
    if (image^.bitplanes <> nil) then
    begin
      //* Deinterleave the body */
      bitplaneData := ILBM_interleave(image, image^.bitplanes^.chunkData);
      if (bitplaneData = nil)
      then exit(_FALSE_);

      //* The bitplanes chunk becomes a body chunk */
      IFF_createId(image^.bitplanes^.chunkId, 'BODY');
      FreeMem(image^.bitplanes^.chunkData);
      image^.bitplanes^.chunkData := bitplaneData;

      //* The reference in the image to bitplanes is updated as well */
      image^.body := image^.bitplanes;
      image^.bitplanes := nil;
    end;

    //* Update form type to ILBM */
// ---- here bitmapHeader is perfectly ok and image structure is ok.
    IFF_createId(image^.formType, 'ILBM');  // <- fuck up BitmapHeader
// ---- here bitmapHeader is completely screwed up, image structure is ok.
    IFF_createId(image^.bitMapHeader^.parent^.groupType, 'ILBM');

    exit(_TRUE_);
  end
  else
    result := _FALSE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        ilbm.c
//////////////////////////////////////////////////////////////////////////////



const
  ILBM_NUM_OF_FORM_TYPES        =  3;
  ILBM_NUM_OF_EXTENSION_CHUNKS  = 10;

  ilbmids : array[0..Pred(ILBM_NUM_OF_EXTENSION_CHUNKS)] of TIFF_ID =
  (
    'BMHD', 'CAMG', 'CCRT', 'CMAP', 'CMYK', 'CRNG', 'DEST', 'DRNG', 'GRAB', 'SPRT'
  );

  ilbmFormExtension : Array[0..Pred(ILBM_NUM_OF_EXTENSION_CHUNKS)] of TIFF_FormExtension =
  (
    ( chunkId : @ilbmids[0]; readchunk: @ILBM_readBitMapHeader; writechunk: @ILBM_writeBitMapHeader; checkchunk: @ILBM_checkBitMapHeader; freeChunk: @ILBM_freeBitMapHeader; printChunk: @ILBM_printBitMapHeader; compareChunk: @ILBM_compareBitMapHeader),
    ( chunkId : @ilbmids[1]; readchunk: @ILBM_readViewport;     writechunk: @ILBM_writeViewport;     checkchunk: @ILBM_checkViewport;     freeChunk: @ILBM_freeViewport;     printChunk: @ILBM_printViewport;     compareChunk: @ILBM_compareViewport),
    ( chunkId : @ilbmids[2]; readchunk: @ILBM_readCycleInfo;    writechunk: @ILBM_writeCycleInfo;    checkchunk: @ILBM_checkCycleInfo;    freeChunk: @ILBM_freeCycleInfo;    printChunk: @ILBM_printCycleInfo;    compareChunk: @ILBM_compareCycleInfo),
    ( chunkId : @ilbmids[3]; readchunk: @ILBM_readColorMap;     writechunk: @ILBM_writeColorMap;     checkchunk: @ILBM_checkColorMap;     freeChunk: @ILBM_freeColorMap;     printChunk: @ILBM_printColorMap;     compareChunk: @ILBM_compareColorMap),
    ( chunkId : @ilbmids[4]; readchunk: @ILBM_readCMYKMap;      writechunk: @ILBM_writeCMYKMap;      checkchunk: @ILBM_checkCMYKMap;      freeChunk: @ILBM_freeCMYKMap;      printChunk: @ILBM_printCMYKMap;      compareChunk: @ILBM_compareCMYKMap),
    ( chunkId : @ilbmids[5]; readchunk: @ILBM_readColorRange;   writechunk: @ILBM_writeColorRange;   checkchunk: @ILBM_checkColorRange;   freeChunk: @ILBM_freeColorRange;   printChunk: @ILBM_printColorRange;   compareChunk: @ILBM_compareColorRange),
    ( chunkId : @ilbmids[6]; readchunk: @ILBM_readDestMerge;    writechunk: @ILBM_writeDestMerge;    checkchunk: @ILBM_checkDestMerge;    freeChunk: @ILBM_freeDestMerge;    printChunk: @ILBM_printDestMerge;    compareChunk: @ILBM_compareDestMerge),
    ( chunkId : @ilbmids[7]; readchunk: @ILBM_readDRange;       writechunk: @ILBM_writeDRange;       checkchunk: @ILBM_checkDRange;       freeChunk: @ILBM_freeDRange;       printChunk: @ILBM_printDRange;       compareChunk: @ILBM_compareDRange),
    ( chunkId : @ilbmids[8]; readchunk: @ILBM_readGrab;         writechunk: @ILBM_writeGrab;         checkchunk: @ILBM_checkGrab;         freeChunk: @ILBM_freeGrab;         printChunk: @ILBM_printGrab;         compareChunk: @ILBM_compareGrab),
    ( chunkId : @ilbmids[9]; readchunk: @ILBM_readSprite;       writechunk: @ILBM_writeSprite;       checkchunk: @ILBM_checkSprite;       freeChunk: @ILBM_freeSprite;       printChunk: @ILBM_printSprite;       compareChunk: @ILBM_compareSprite)
  );

(*
static IFF_FormExtension ilbmFormExtension[] = {
    {"BMHD", &ILBM_readBitMapHeader, &ILBM_writeBitMapHeader, &ILBM_checkBitMapHeader, &ILBM_freeBitMapHeader, &ILBM_printBitMapHeader, &ILBM_compareBitMapHeader},
    {"CAMG", &ILBM_readViewport, &ILBM_writeViewport, &ILBM_checkViewport, &ILBM_freeViewport, &ILBM_printViewport, &ILBM_compareViewport},
    {"CCRT", &ILBM_readCycleInfo, &ILBM_writeCycleInfo, &ILBM_checkCycleInfo, &ILBM_freeCycleInfo, &ILBM_printCycleInfo, &ILBM_compareCycleInfo},
    {"CMAP", &ILBM_readColorMap, &ILBM_writeColorMap, &ILBM_checkColorMap, &ILBM_freeColorMap, &ILBM_printColorMap, &ILBM_compareColorMap},
    {"CMYK", &ILBM_readCMYKMap, &ILBM_writeCMYKMap, &ILBM_checkCMYKMap, &ILBM_freeCMYKMap, &ILBM_printCMYKMap, &ILBM_compareCMYKMap},
    {"CRNG", &ILBM_readColorRange, &ILBM_writeColorRange, &ILBM_checkColorRange, &ILBM_freeColorRange, &ILBM_printColorRange, &ILBM_compareColorRange},
    {"DEST", &ILBM_readDestMerge, &ILBM_writeDestMerge, &ILBM_checkDestMerge, &ILBM_freeDestMerge, &ILBM_printDestMerge, &ILBM_compareDestMerge},
    {"DRNG", &ILBM_readDRange, &ILBM_writeDRange, &ILBM_checkDRange, &ILBM_freeDRange, &ILBM_printDRange, &ILBM_compareDRange},
    {"GRAB", &ILBM_readGrab, &ILBM_writeGrab, &ILBM_checkGrab, &ILBM_freeGrab, &ILBM_printGrab, &ILBM_compareGrab},
    {"SPRT", &ILBM_readSprite, &ILBM_writeSprite, &ILBM_checkSprite, &ILBM_freeSprite, &ILBM_printSprite, &ILBM_compareSprite}
};
*)
  ilbmft : array[0..Pred(ILBM_NUM_OF_FORM_TYPES)] of TIFF_ID =
  (
    'ACBM', 'ILBM', 'PBM '
  );

  extension : Array[0..Pred(ILBM_NUM_OF_FORM_TYPES)] of TIFF_Extension =
  (
    ( formType : @ilbmft[0]; formExtensionsLength: ILBM_NUM_OF_EXTENSION_CHUNKS; formExtensions: @ilbmFormExtension),
    ( formType : @ilbmft[1]; formExtensionsLength: ILBM_NUM_OF_EXTENSION_CHUNKS; formExtensions: @ilbmFormExtension),
    ( formType : @ilbmft[2]; formExtensionsLength: ILBM_NUM_OF_EXTENSION_CHUNKS; formExtensions: @ilbmFormExtension)  
  );

(*
static IFF_Extension extension[] = {
    {"ACBM", ILBM_NUM_OF_EXTENSION_CHUNKS, ilbmFormExtension},
    {"ILBM", ILBM_NUM_OF_EXTENSION_CHUNKS, ilbmFormExtension},
    {"PBM ", ILBM_NUM_OF_EXTENSION_CHUNKS, ilbmFormExtension}
};
*)


function  ILBM_read(const filename: PChar): PIFF_Chunk;
begin
  result := IFF_read(filename, extension, ILBM_NUM_OF_FORM_TYPES);
end;


function  ILBM_readFd(filehandle: THandle): PIFF_Chunk;
begin
  result := IFF_readFd(filehandle, extension, ILBM_NUM_OF_FORM_TYPES);
end;


function  ILBM_writeFd(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeFd(filehandle, chunk, extension, ILBM_NUM_OF_FORM_TYPES);
end;


function  ILBM_write(const filename: PChar; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_write(filename, chunk, extension, ILBM_NUM_OF_FORM_TYPES);
end;


function  ILBM_check(const chunk: PIFF_Chunk): cint;
begin
  result := IFF_check(chunk, extension, ILBM_NUM_OF_FORM_TYPES);
end;


procedure ILBM_free(chunk: PIFF_Chunk);
begin
  IFF_free(chunk, extension, ILBM_NUM_OF_FORM_TYPES);
end;


procedure ILBM_print(const chunk: PIFF_Chunk; const indentLevel: cuint);
begin
  IFF_print(chunk, 0, extension, ILBM_NUM_OF_FORM_TYPES);
end;


function  ILBM_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compare(chunk1, chunk2, extension, ILBM_NUM_OF_FORM_TYPES);
end;



end.
