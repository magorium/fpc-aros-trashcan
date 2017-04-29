unit libamivideo;

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
  ctypes;



// ###########################################################################
// ###
// ###      type definitions
// ###
// ###########################################################################



//////////////////////////////////////////////////////////////////////////////
//        amivideotypes.h
//////////////////////////////////////////////////////////////////////////////



Type
  //** An unsigned byte */
  TamiVideo_UByte   = Byte;

  //** An unsigned word */
  TamiVideo_UWord   = Word;

  //** An signed word */
  TamiVideo_Word    = Smallint;

  //** A signed 4-bytes type */
  TamiVideo_Long    = LongInt;

  //** An unsigned 4-bytes type */
  TamiVideo_ULong   = LongWord;
  

  PamiVideo_UByte   = ^TamiVideo_UByte;
  PPamiVideo_UByte  = ^PamiVideo_UByte;

  PamiVideo_UWord   = ^TamiVideo_UWord;
  PamiVideo_Word    = ^TamiVideo_Word;
  PamiVideo_Long    = ^TamiVideo_Long;
  PamiVideo_ULong   = ^TamiVideo_ULong;



//////////////////////////////////////////////////////////////////////////////
//        viewportmode.h
//////////////////////////////////////////////////////////////////////////////



Const
  AMIVIDEO_VIDEOPORTMODE_LACE       = $0004;
  AMIVIDEO_VIDEOPORTMODE_EHB        = $80;
  AMIVIDEO_VIDEOPORTMODE_HAM        = $800;
  AMIVIDEO_VIDEOPORTMODE_HIRES      = $8000;
  AMIVIDEO_VIDEOPORTMODE_SUPERHIRES = $8020;


  {**
  * Checks whether the Extra-Halfbrite (EHB) bit is enabled in the viewport mode register.
  *
  * @param viewportMode Amiga viewport register value
  * @return TRUE if Extra-Halfbrite is enabled, else FALSE
  *}
  function  amiVideo_checkExtraHalfbrite(const viewportMode: TamiVideo_Long): cint;

  {**
  * Checks whether the Hold-and-Modify (HAM) bit is enabled in the viewport mode register.
  *
  * @param viewportMode Amiga viewport register value
  * @return TRUE if Extra-Halfbrite is enabled, else FALSE
  *}
  function  amiVideo_checkHoldAndModify(const viewportMode: TamiVideo_Long): cint;

  {**
  * Checks whether the hires bit is enabled in the viewport mode register.
  *
  * @param viewportMode Amiga viewport register value
  * @return TRUE if the hires bit is enabled, else FALSE
  *}
  function  amiVideo_checkHires(const viewportMode: TamiVideo_Long): cint;

  {**
  * Checks whether the super and hires bits are enabled in the viewport mode
  * register.
  *
  * @param viewportMode Amiga viewport register value
  * @return TRUE if the hires and super bits are enabled, else FALSE
  *}
  function  amiVideo_checkSuperHires(const viewportMode: TamiVideo_Long): cint;

  {**
  * Checks whether the hires bit is enabled in the viewport mode register.
  *
  * @param viewportMode Amiga viewport register value
  * @return TRUE if the hires bit is enabled, else FALSE
  *}
  function  amiVideo_checkLaced(const viewportMode: TamiVideo_Long): cint;

  {**
  * Auto selects the most space efficient lowres pixel scale factor capable of
  * retaining the right aspect ratio on non-Amiga displays.
  *
  * @param viewportMode Amiga viewport register value
  * @return The most efficient lowres pixel scale factor
  *}
  function  amiVideo_autoSelectLowresPixelScaleFactor(const viewportMode: TamiVideo_Long): cuint;

  {**
  * Extracts the palette flag values bits (Extra Half Brite and Hold-and Modify)
  * from the viewport mode value.
  *
  * @param viewportMode Amiga viewport register value
  * @return A viewport mode value with only the EHB and HAM flags set
  *}
  function  amiVideo_extractPaletteFlags(const viewportMode: TamiVideo_Long): TamiVideo_Long;

  {**
  * Auto selects the most suitable Amiga resolution viewport flags to display a
  * given screen.
  *
  * @param width Width of the screen
  * @param height Height of the screen
  * @return A viewport mode value with the most suitable resolution flags set
  *}
  function  amiVideo_autoSelectViewportMode(const width: TamiVideo_Word; const height: TamiVideo_Word): TamiVideo_Long;



//////////////////////////////////////////////////////////////////////////////
//        palette.h
//////////////////////////////////////////////////////////////////////////////



Type
  {**
  * @brief Struct storing values of a color channel.
  *}
  PamiVideo_Color = ^TamiVideo_Color;
  amiVideo_Color = 
  record
    //** Defines the intensity of the red color channel */
    r : TamiVideo_UByte;
    
    //** Defines the intensity of the green color channel */
    g : TamiVideo_UByte;
    
    //** Defines the intensity of the blue color channel */
    b : TamiVideo_UByte;
  end;
  TamiVideo_Color = amiVideo_Color;


  {**
  * @brief Struct storing values of a color channel.
  * This struct type has the same structure as the SDL_Color struct.
  *}
  PamiVideo_OutputColor = ^TamiVideo_OutputColor;
  amiVideo_OutputColor =
  record
    //** Defines the intensity of the red color channel */
    r : TamiVideo_UByte;
    
    //** Defines the intensity of the green color channel */
    g : TamiVideo_UByte;
    
    //** Defines the intensity of the blue color channel */
    b : TamiVideo_UByte;

    //** Defines the intensity of the alpha color channel */
    a : TamiVideo_UByte;
  end;
  TamiVideo_OutputColor = amiVideo_OutputColor;


  PamiVideo_Palette = ^TamiVideo_Palette;
  amiVideo_Palette =
  record
    bitplaneFormat : 
    record
      //** Contains the viewport mode settings */
      viewportMode          : TamiVideo_Long;
        
      //** Contains the number of colors in the original Amiga palette */
      numOfColors           : cuint;
	
      //** Stores the color values of the palette */
      color                 : PamiVideo_Color;
	
      //** Contains the number of bits that a color component has (4 = OCS/ECS, 8 = AGA) */
      bitsPerColorChannel   : cuint;
    end;

    chunkyFormat :
    record
      //** Contains the number of colors in the converted chunky graphics palette */
      numOfColors   : cuint;
	
      //** Stores the color values of the palette */
      color         : PamiVideo_OutputColor;
    end;
  end;
  TamiVideo_Palette = amiVideo_Palette;


  {**
  * Initialises the palette with the given bitplane depth, bits per color channel
  * and viewport mode.
  *
  * @param palette Palette conversion structure
  * @param bitplaneDepth Bitplane depth, a value between 1-6 (OCS/ECS) and 1-8 (AGA)
  * @param bitsPerColorChannel The amount of bits for used for a color component (4 = ECS/OCS, 8 = AGA)
  * @param viewportMode The viewport mode value
  *}
  procedure amiVideo_initPalette(palette: PamiVideo_Palette; bitplaneDepth: cuint; bitsPerColorChannel: cuint; viewportMode: TamiVideo_Long);

  {**
  * Frees all the heap allocated members of the palette from memory.
  *
  * @param palette Palette conversion structure
  *}
  procedure amiVideo_cleanupPalette(palette: PamiVideo_Palette);

  {**
  * Sets the palette's bitplane color values to the values in a given array. The
  * remaining colors are set to 0. The color values must be in the Amiga screen's
  * format, i.e. 4 bits or 8 bits per pixel.
  *
  * @param palette Palette conversion structure
  * @param color Array of color values
  * @param numOfColors The amount of colors in the color value array
  *}
  procedure amiVideo_setBitplanePaletteColors(palette: PamiVideo_Palette; color: PamiVideo_Color; numOfColors: cuint);

  {**
  * Sets the palette's chunky color values to the values in a given array. The
  * remaining colors are set to 0. The color values must be in the chunky screen
  * format, i.e. 8 bits per pixel.
  *
  * @param palette Palette conversion structure
  * @param color Array of color values
  * @param numOfColors The amount of colors in the color value array
  *}
  procedure amiVideo_setChunkyPaletteColors(palette: PamiVideo_Palette; color: PamiVideo_OutputColor; numOfColors: cuint);

  {**
  * Converts the original palette used for the bitplanes to the ones used for
  * displaying chunky graphics. This means that a palette in which the color
  * components consist 4 bits are converted to 8 bits.
  *
  * If the viewportMode has the extra halfbrite bit set, then the amount of
  * colors are doubled in which the color values of latter half, are half of the
  * values of the first half of the palette.
  *
  * @param palette Palette conversion structure
  *}
  procedure amiVideo_convertBitplaneColorsToChunkyFormat(palette: PamiVideo_Palette);

  {**
  * Converts the palette used for chunky graphics to a format that can be for
  * displaying bitplanes. If an palette with 4 bit color components is used,
  * then the color components are shifted.
  *
  * @param palette Palette conversion structure
  *}
  procedure amiVideo_convertChunkyColorsToBitplaneFormat(palette: PamiVideo_Palette);

  {**
  * Converts the bitplane palette to an array of word specifications, which can
  * be used by AmigaOS' LoadRGB4() function to set a screen's palette. This
  * function does not support the AGA chipset's capabilities. The resulting array
  * has as many elements as the bitplane palette and is allocated on the heap.
  * Therefore, free() must be invoked when it has become obsolete.
  *
  * @param palette Palette conversion structure
  * @return A word array containing the color specifications for the LoadRGB4() function.
  *}
  function  amiVideo_generateRGB4ColorSpecs(const palette: PamiVideo_Palette): PamiVideo_UWord;

  {**
  * Converts the bitplane palette to an array of long integer color
  * specifications, which can be used by AmigaOS' LoadRGB32() function to set a
  * screen's palette. To use the AGA chipset's abilities, it's required to use
  * this function. The resulting array is allocated on the heap and must be
  * deleted with free() when it has become obsolete.
  *
  * @param palette Palette conversion structure
  * @return An long integer array containing the color specifications for the LoadRGB32() function.
  *}
  function  amiVideo_generateRGB32ColorSpecs(const palette: PamiVideo_Palette): PamiVideo_ULong;



//////////////////////////////////////////////////////////////////////////////
//        screen.h
//////////////////////////////////////////////////////////////////////////////



Const
  AMIVIDEO_MAX_NUM_OF_BITPLANES = 32;


Type
  // typedef struct amiVideo_Screen amiVideo_Screen;

  {**
  * A data structure representing an Amiga screen (or viewport) containing
  * conversion sub structures that store the screen in a different displaying
  * format.
  *}
  PamiVideo_Screen = ^TamiVideo_Screen;
  amiVideo_Screen =
  record
    //** Defines the width of the screen in pixels */
    width           : TamiVideo_Word;
    
    //** Defines the height of the screen in pixels */
    height          : TamiVideo_Word;
    
    //** Defines the bitplane depth */
    bitplaneDepth   : cuint;
    
    //** Contains the viewport mode settings */
    viewportMode    : TamiVideo_Long;
    
    //* Contains the values of the color registers and its converted values */
    palette         : TamiVideo_Palette;
    
    {**
    * Contains all the relevant properties of the current screen to display it
    * in planar format -- the format that Amiga's OCS, ECS and AGA chipsets use.
    * In this format, each bit represents a part of the palette index of a pixel
    * and is stored the amount bitplanes times in memory.
    *
    * For example, a screen with 32 colors has a bitplane depth of 5. In this
    * case the pixels are stored five times in memory in which each bit of a
    * plane represents a pixel.
    * 
    * The bits in first occurence of the bitplane represent the most significant
    * bit and the last the least significant bit of the pixel's index value.
    * By combining all these bits from the most significant bit to the least
    * significant bit we will get the index value of the palette of the pixel.
    *
    * Widths are padded till the nearest word boundary (i.e. multiples of 16).
    *}
    bitplaneFormat : 
    record
      //** Contains pointers to each bitplane section that stores parts of each pixel's color component */
      bitplanes         : array[0..Pred(AMIVIDEO_MAX_NUM_OF_BITPLANES)] of PamiVideo_UByte;
	
      //** Contains the padded width in pixels that is rounded up to the nearest word boundary */
      pitch             : cuint;
	
      //** Indicates whether the pixel memory is allocated and needs to be freed */
//      memoryAllocated   : cint;
      memoryAllocated   : LongBool;
    end;
    
    {**
    * Contains all the relevant properties of the current screen to display it
    * in chunky format -- used by PC displays with 256 colors. In this format,
    * each byte represents a pixel in which the value refers to an index in the
    * palette.
    *
    * The screen width may be padded.
    *}
    uncorrectedChunkyFormat :
    record
      //** Contains the padded screen width in bytes */
      pitch             : cuint;
	
      //** Contains the pixel data in which each byte represents an index in the palette */
      pixels            : PamiVideo_UByte;
	
      //** Indicates whether the pixel memory is allocated and needs to be freed */
      // memoryAllocated   : cint;
      memoryAllocated   : LongBool;
    end;
    
    {** 
    * Contains all the relevant properties of the current screen to display it
    * in RGB format in which every four bytes represent the red, green, blue
    * value of a pixel and a padding byte.
    *
    * The screen width may be padded.
    *}
    uncorrectedRGBFormat :
    record
      //** Contains the padded screen width in bytes (usually rounded up to the nearest 4-byte boundary) */
      pitch             : cuint;
	
      //** Contains the amount of bits that we have to left shift the red color component */
      rshift            : TamiVideo_UByte;

      //** Contains the amount of bits that we have to left shift the green color component */
      gshift            : TamiVideo_UByte;

      //** Contains the amount of bits that we have to left shift the blue color component */
      bshift            : TamiVideo_UByte;

      //** Contains the amount of bits that we have to left shift the alpha color component */
      ashift            : TamiVideo_UByte;
	
      //** Contains the pixel data in which each four bytes represent red, glue, blue values and a padding byte */
      pixels            : PamiVideo_ULong;
	
      //** Indicates whether the pixel memory is allocated and needs to be freed */
      // memoryAllocated   : cint;
      memoryAllocated   : LongBool;
    end;
    
    {**
    * Contains the screen in a format that has the correct aspect ratio, as
    * Amiga displays have only have a horizontal pixel resolution and interlace
    * mode doubling the amount of available scanlines.
    *
    * A lowres pixel is composed of two highres pixels, thus the width of a
    * lowres resolution screen must be scaled at least by a factor 2.
    *}
    correctedFormat :
    record
      //** Contains the width of the corrected screen */
      width                     : cint;
	
      //** Contains the height of the corrected screen */
      height                    : cint;
	
      //** Contains the padded width of the corrected screen (usually rounded up to the nearest 4-byte boundary) */
      pitch                     : cuint;
	
      //** Contains the amount of bytes per pixel (1 = chunky, 4 = RGB) */
      bytesPerPixel             : cuint;
	
      //* Specifies the width of a lowres pixel in real pixels. Usually 2 is sufficient. To support super hires displays, 4 is required. */
      lowresPixelScaleFactor    : cuint;
	
      //** Contains the pixel data */
      pixels                    : pointer;
    end;
  end;
  TamiVideo_Screen = amiVideo_Screen;


  TamiVideo_ColorFormat =
  (
    AMIVIDEO_CHUNKY_FORMAT = 1,
    AMIVIDEO_RGB_FORMAT    = 4
  );


  {**
  * Initializes a screen instance with the given dimensions, bitplane depth,
  * specific size of color components and viewport mode.
  *
  * @param screen Screen conversion structure
  * @param width Width of the screen in pixels
  * @param height Height of the screen in scanlines
  * @param bitplaneDepth Bitplane depth, a value between 1-6 (OCS/ECS) and 1-8 (AGA)
  * @param bitsPerColorChannel The amount of bits for used for a color component (4 = ECS/OCS, 8 = AGA)
  * @param viewportMode The viewport mode value
  *}
  procedure amiVideo_initScreen(screen: PamiVideo_Screen; width: TamiVideo_Word; height: TamiVideo_Word; bitplaneDepth: cuint; bitsPerColorChannel: cuint; viewportMode: TamiVideo_Long);

  {**
  * Creates a screen conversion structure on the heap with the given dimensions,
  * bitplane depth, specific size of color components and viewport mode. The
  * resulting screen must eventually be freed from memory by calling amiVideo_freeScreen()
  *
  * @param width Width of the screen in pixels
  * @param height Height of the screen in scanlines
  * @param bitplaneDepth Bitplane depth, a value between 1-6 (OCS/ECS) and 1-8 (AGA)
  * @param bitsPerColorChannel The amount of bits for used for a color component (4 = ECS/OCS, 8 = AGA)
  * @param viewportMode The viewport mode value
  * @return A screen conversion structure with the given properties
  *}
  function  amiVideo_createScreen(width: TamiVideo_Word; height: TamiVideo_Word; bitplaneDepth: cuint; bitsPerColorChannel: cuint; viewportMode: TamiVideo_Long): PamiVideo_Screen;

  {**
  * Frees the heap allocated members of the given screen structure.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_cleanupScreen(screen: PamiVideo_Screen);

  {**
  * Frees the given screen conversion structure and its members.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_freeScreen(screen: PamiVideo_Screen);

  {**
  * Calculates the width of a surface that has corrected the aspect ratio.
  *
  * @param lowresPixelScaleFactor Specifies the width of a lowres pixel in real pixels. Usually 2 is sufficient. To support super hires displays, 4 is required.
  * @param width Width of the uncorrected surface
  * @param viewportMode The viewport mode value
  *}
  function  amiVideo_calculateCorrectedWidth(lowresPixelScaleFactor: cuint; width: TamiVideo_Long; viewportMode: TamiVideo_Long): cint;

  {**
  * Calculates the height of a surface that has corrected the aspect ratio.
  *
  * @param lowresPixelScaleFactor Specifies the width of a lowres pixel in real pixels. Usually 2 is sufficient. To support super hires displays, 4 is required.
  * @param height Height of the uncorrected surface
  * @param viewportMode The viewport mode value
  *}
  function  amiVideo_calculateCorrectedHeight(lowresPixelScaleFactor: cuint; height: TamiVideo_Long; viewportMode: TamiVideo_Long): cint;

  {**
  * @param screen Screen conversion structure
  * @param lowresPixelScaleFactor Specifies the width of a lowres pixel in real pixels. Usually 2 is sufficient. To support super hires displays, 4 is required.
  *}
  procedure amiVideo_setLowresPixelScaleFactor(screen: PamiVideo_Screen; lowresPixelScaleFactor: cuint);

  {**
  * Sets the bitplane pointers of the conversion structure to the appropriate
  * memory positions. On AmigaOS these may point to a real viewport's bitplane
  * pointers. On different platforms these may point to subsets of a
  * pre-allocated memory area containing planar graphics data.
  *
  * @param screen Screen conversion structure
  * @param bitplanes Pointers to bitplane areas in memory
  *}
  procedure amiVideo_setScreenBitplanePointers(screen: PamiVideo_Screen; bitplanes: PPamiVideo_UByte);

  {**
  * Automatically sets the bitplane pointers of the conversion structure to the
  * right subsets in a given memory area containing planar graphics data. It
  * assumes that planar data for each bitplane level are stored immediately after
  * each other.
  *
  * @param screen Screen conversion structure
  * @param bitplanes A memory area containing planar graphics data
  *}
  procedure amiVideo_setScreenBitplanes(screen: PamiVideo_Screen; bitplanes: PamiVideo_UByte);

  {**
  * Sets the uncorrected chunky sub struct pointer to a memory area capable of
  * storing it.
  *
  * @param screen Screen conversion structure
  * @param pixels Pointer to a memory struct storing chunky pixels
  * @param pitch Padded width of the memory surface in bytes
  *}
  procedure amiVideo_setScreenUncorrectedChunkyPixelsPointer(screen: PamiVideo_Screen; pixels: PamiVideo_UByte; pitch: cuint);

  {**
  * Sets the uncorrected RGB sub struct pointer to a memory area capable of
  * storing it.
  *
  * @param screen Screen conversion structure
  * @param pixels Pointer to a memory area storing RGB pixels
  * @param pitch Padded width of the memory surface in bytes (usually 4 * width, but it may be padded)
  * @param allocateUncorrectedMemory Indicates whether we should allocate memory for a chunky pixels buffer that should be freed
  * @param rshift The amount of bits that we have to left shift the red color component
  * @param gshift The amount of bits that we have to left shift the green color component
  * @param bshift The amount of bits that we have to left shift the blue color component
  * @param ashift The amount of bits that we have to left shift the alpha color component
  *}
  procedure amiVideo_setScreenUncorrectedRGBPixelsPointer(screen: PamiVideo_Screen; pixels: PamiVideo_ULong; pitch: cuint; allocateUncorrectedMemory: cint; rshift: TamiVideo_UByte; gshift: TamiVideo_UByte; bshift: TamiVideo_UByte; ashift: TamiVideo_UByte);

  {**
  * Sets the corrected pixels sub struct pointer to a memory area capable of
  * storing it.
  *
  * @param screen Screen conversion structure
  * @param pixels Pointer to a memory area storing the corrected pixels
  * @param pitch Padded width of the memory surface in bytes (equals witdth for chunky, 4 * width for RGB, but it may be padded)
  * @param bytesPerPixel Specifies of how many bytes a pixel consists (1 = chunky, 4 = RGB)
  * @param allocateUncorrectedMemory Indicates whether we should allocate memory for a chunky or RGB pixel buffer that should be freed
  * @param rshift The amount of bits that we have to left shift the red color component
  * @param gshift The amount of bits that we have to left shift the green color component
  * @param bshift The amount of bits that we have to left shift the blue color component
  * @param ashift The amount of bits that we have to left shift the alpha color component
  *}
  procedure amiVideo_setScreenCorrectedPixelsPointer(screen: PamiVideo_Screen; pixels: pointer; pitch: cuint; bytesPerPixel: cuint; allocateUncorrectedMemory: cint; rshift: TamiVideo_UByte; gshift: TamiVideo_UByte; bshift: TamiVideo_UByte; ashift: TamiVideo_UByte);

  {**
  * Converts the bitplanes to chunky pixels in which every byte represents a
  * pixel and an index value from the palette.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenBitplanesToChunkyPixels(screen: PamiVideo_Screen);

  {**
  * Converts the chunky pixels to RGB pixels in which every four bytes represent
  * the color value of a pixel.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenChunkyPixelsToRGBPixels(screen: PamiVideo_Screen);

  {**
  * Converts chunky pixels to bitplane format in which every bit represents a
  * part of an index value of the palette of a pixel.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenChunkyPixelsToBitplanes(screen: PamiVideo_Screen);

  {**
  * Corrects the chunky or RGB pixel surface into a surface having the correct
  * aspect ratio taking the resolution settings into account.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_correctScreenPixels(screen: PamiVideo_Screen);

  {**
  * Converts the screen bitplane surface to RGB pixel surface and performs all
  * the immediate steps.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenBitplanesToRGBPixels(screen: PamiVideo_Screen);

  {**
  * Converts the screen bitplanes surface to a corrected chunky pixel surface and
  * performs all the immediate steps.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenBitplanesToCorrectedChunkyPixels(screen: PamiVideo_Screen);

  {**
  * Converts the screen bitplanes surface to a corrected RGB pixel surface and
  * performs all the immediate steps.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenBitplanesToCorrectedRGBPixels(screen: PamiVideo_Screen);

  {**
  * Converts the uncorrected chunky pixel surface to a corrected RGB pixel surface
  * and performs all the immediate steps.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_convertScreenChunkyPixelsToCorrectedRGBPixels(screen: PamiVideo_Screen);

  {**
  * Auto selects the most efficient display format for displaying the converted
  * screen. It picks RGB format for HAM displays and when 24 or 32 bitplanes are
  * used. In all other cases, it picks chunky format.
  *
  * @param viewportMode Amiga viewport register value
  * @return The most efficient color format
  *}
  function  amiVideo_autoSelectColorFormat(const screen: PamiVideo_Screen): TamiVideo_ColorFormat;

  {**
  * Reorders the RGB pixels from the 0RGB (for 24 bitplanes) or RGBA (for 32
  * bitplanes) representation to the byte order that is actually used for the
  * display screen.
  *
  * @param screen Screen conversion structure
  *}
  procedure amiVideo_reorderRGBPixels(screen: PamiVideo_Screen);



implementation


Uses
  CHelpers;



//////////////////////////////////////////////////////////////////////////////
//        viewportmode.c
//////////////////////////////////////////////////////////////////////////////



function  amiVideo_checkExtraHalfbrite(const viewportMode: TamiVideo_Long): cint;
begin
  LongBool(result) := ((viewportMode and AMIVIDEO_VIDEOPORTMODE_EHB) = AMIVIDEO_VIDEOPORTMODE_EHB);
end;


function  amiVideo_checkHoldAndModify(const viewportMode: TamiVideo_Long): cint;
begin
  LongBool(result) := ((viewportMode and AMIVIDEO_VIDEOPORTMODE_HAM) = AMIVIDEO_VIDEOPORTMODE_HAM);
end;


function  amiVideo_checkHires(const viewportMode: TamiVideo_Long): cint;
begin
  LongBool(result) := ((viewportMode and AMIVIDEO_VIDEOPORTMODE_HIRES) = AMIVIDEO_VIDEOPORTMODE_HIRES);
end;


function  amiVideo_checkSuperHires(const viewportMode: TamiVideo_Long): cint;
begin
  LongBool(result) := ((viewportMode and AMIVIDEO_VIDEOPORTMODE_SUPERHIRES) = AMIVIDEO_VIDEOPORTMODE_SUPERHIRES);
end;


function  amiVideo_checkLaced(const viewportMode: TamiVideo_Long): cint;
begin
  LongBool(Result) := ((viewportMode and AMIVIDEO_VIDEOPORTMODE_LACE) = AMIVIDEO_VIDEOPORTMODE_LACE);
end;


function  amiVideo_autoSelectLowresPixelScaleFactor(const viewportMode: TamiVideo_Long): cuint;
begin
  if (amiVideo_checkSuperHires(viewportMode) <> 0)
  then exit(4)
  else if ( (amiVideo_checkHires(viewportMode) <> 0) and (amiVideo_checkLaced(viewportMode) <> 0) )
  then exit(1)
  else if ( (amiVideo_checkHires(viewportMode) <> 0) and not(amiVideo_checkLaced(viewportMode) <> 0) )
  then exit(2)
  else if (amiVideo_checkLaced(viewportMode) <> 0)
  then exit(2)
  else
    result := 1;
end;


function  amiVideo_extractPaletteFlags(const viewportMode: TamiVideo_Long): TamiVideo_Long;
begin
  result := viewportMode and (AMIVIDEO_VIDEOPORTMODE_HAM or AMIVIDEO_VIDEOPORTMODE_EHB);
end;


function  amiVideo_autoSelectViewportMode(const width: TamiVideo_Word; const height: TamiVideo_Word): TamiVideo_Long;
var
  viewportMode : TamiVideo_Long = 0;
begin
  //* If the page width is larger than 736 (640 width + max overscan), we use super hi-res screen mode */
  if (width > 736)
  then viewportMode := viewportMode or AMIVIDEO_VIDEOPORTMODE_SUPERHIRES 
  else 
  //* If the page width is larger than 368 (320 width + max overscan), we use hi-res screen mode */
  if (width > 368)
  then viewportMode := viewportMode or AMIVIDEO_VIDEOPORTMODE_HIRES;

  //* If the page height is larger than 290 (256 height + max overscan), we have a laced screen mode */
  if (height > 290)
  then viewportMode := viewportMode or AMIVIDEO_VIDEOPORTMODE_LACE;

  result := viewportMode;
end;



//////////////////////////////////////////////////////////////////////////////
//        palette.c
//////////////////////////////////////////////////////////////////////////////



function  determineNumOfColors(bitplaneDepth: cuint): cint;
begin
  case bitplaneDepth of
    1 :   result :=   2;
    2 :   result :=   4;
    3 :   result :=   8;
    4 :   result :=  16;
    5 :   result :=  32;
    6 :   result :=  64;
    7 :   result := 128;
    8 :   result := 256;
    else  result :=   0;
  end;
end;


procedure amiVideo_initPalette(palette: PamiVideo_Palette; bitplaneDepth: cuint; bitsPerColorChannel: cuint; viewportMode: TamiVideo_Long);
begin
  //* Assign values */
  palette^.bitplaneFormat.viewportMode := viewportMode;
    
  //* Allocate memory for bitplane colors */

  palette^.bitplaneFormat.bitsPerColorChannel := bitsPerColorChannel;
  palette^.bitplaneFormat.numOfColors := determineNumOfColors(bitplaneDepth);
  palette^.bitplaneFormat.color := PamiVideo_Color(AllocMem(palette^.bitplaneFormat.numOfColors * sizeof(amiVideo_Color)));

  //* Allocate memory for chunky colors */
    
  if LongBool(amiVideo_checkExtraHalfbrite(viewportMode))
  then palette^.chunkyFormat.numOfColors := 2 * palette^.bitplaneFormat.numOfColors //* Extra halfbrite screen mode has double the amount of colors */
  else
    palette^.chunkyFormat.numOfColors := palette^.bitplaneFormat.numOfColors;
    
  palette^.chunkyFormat.color := PamiVideo_OutputColor(AllocMem(palette^.chunkyFormat.numOfColors * sizeof(amiVideo_OutputColor)));
end;


procedure amiVideo_cleanupPalette(palette: PamiVideo_Palette);
begin
  FreeMem(palette^.bitplaneFormat.color);
  FreeMem(palette^.chunkyFormat.color);
end;


procedure amiVideo_setBitplanePaletteColors(palette: PamiVideo_Palette; color: PamiVideo_Color; numOfColors: cuint);
var
  numOfRemainingColors : cuint;
begin
  numOfRemainingColors := palette^.bitplaneFormat.numOfColors - numOfColors;
    
  //* Copy the given colors */
  memcpy(palette^.bitplaneFormat.color, color, numOfColors * sizeof(TamiVideo_Color));
    
  if (numOfRemainingColors > 0)
//  then memset(palette^.bitplaneFormat.color + numOfColors, #0, numOfRemainingColors * sizeof(TamiVideo_Color)); //* Set the remaining ones to 0 */
  then memset(palette^.bitplaneFormat.color + ( numOfColors * sizeof(TamiVideo_Color) ), #0, numOfRemainingColors * sizeof(TamiVideo_Color)); //* Set the remaining ones to 0 */

end;

(*
void amiVideo_setBitplanePaletteColors(amiVideo_Palette *palette, amiVideo_Color *color, unsigned int numOfColors)
{
    unsigned int numOfRemainingColors = palette->bitplaneFormat.numOfColors - numOfColors;

    /* Copy the given colors */
    memcpy(palette->bitplaneFormat.color, color, numOfColors * sizeof(amiVideo_Color));

    if(numOfRemainingColors > 0)
	memset(palette->bitplaneFormat.color + numOfColors, '\0', numOfRemainingColors * sizeof(amiVideo_Color)); /* Set the remaining ones to 0 */
}

*)

procedure amiVideo_setChunkyPaletteColors(palette: PamiVideo_Palette; color: PamiVideo_OutputColor; numOfColors: cuint);
var
  numOfRemainingColors : cuint;
begin
  numOfRemainingColors := palette^.chunkyFormat.numOfColors - numOfColors;
    
  //* Copy the given colors */
  memcpy(palette^.chunkyFormat.color, color, numOfColors * sizeof(amiVideo_OutputColor));
    
  if (numOfRemainingColors > 0)
  then memset(palette^.chunkyFormat.color + numOfColors, #0, numOfRemainingColors * sizeof(amiVideo_OutputColor)); //* Set the remaining ones to 0 */
end;


procedure amiVideo_convertBitplaneColorsToChunkyFormat(palette: PamiVideo_Palette);
var
  i             : cuint;
  shift         : cint;
var
  sourceColor   : PamiVideo_Color;
  targetColor   : PamiVideo_OutputColor;
  
  sourceColor2  : PamiVideo_OutputColor;
  targetColor2  : PamiVideo_OutputColor;  
begin
  //* We must convert color channels that consist do not consist of 8 bits */
  shift := 8 - palette^.bitplaneFormat.bitsPerColorChannel;

  i := 0;
  while (i < palette^.bitplaneFormat.numOfColors) do
  begin
    sourceColor := @palette^.bitplaneFormat.color[i];
    targetColor := @palette^.chunkyFormat.color[i];

    targetColor^.r := sourceColor^.r shl shift;
    targetColor^.g := sourceColor^.g shl shift;
    targetColor^.b := sourceColor^.b shl shift;
    targetColor^.a := 0;

    inc(i);
  end;
    
  //* For extra half brite screen modes we must append half of the color values of the original color register values */
    
  if LongBool(amiVideo_checkExtraHalfbrite(palette^.bitplaneFormat.viewportMode)) then
  begin
    i := 0;
    while (i < palette^.bitplaneFormat.numOfColors) do
    begin
      sourceColor2 := @palette^.chunkyFormat.color[i];
      targetColor2 := @palette^.chunkyFormat.color[i + palette^.bitplaneFormat.numOfColors];
	    
      targetColor2^.r := sourceColor2^.r shr 1;
      targetColor2^.g := sourceColor2^.g shr 1;
      targetColor2^.b := sourceColor2^.b shr 1;
      targetColor2^.a := 0;

      inc(i);
    end;
  end;
end;


procedure amiVideo_convertChunkyColorsToBitplaneFormat(palette: PamiVideo_Palette);
var
  shift : cint;
  i     : cuint;
var  
  chunkyColor   : amiVideo_OutputColor;
  color         : PamiVideo_Color;
begin
  shift := 8 - palette^.bitplaneFormat.bitsPerColorChannel;
    
  i := 0;
  while (i < palette^.bitplaneFormat.numOfColors) do
  begin
    chunkyColor := palette^.chunkyFormat.color[i];
    color := @palette^.bitplaneFormat.color[i];
	
    color^.r := chunkyColor.r shr shift;
    color^.g := chunkyColor.g shr shift;
    color^.b := chunkyColor.g shr shift;

    inc(i);
  end;
end;


function  amiVideo_generateRGB4ColorSpecs(const palette: PamiVideo_Palette): PamiVideo_UWord;
var
  shift : cint;
  i     : cuint;
var  
  colorSpecs    : PamiVideo_UWord;
  color         : PamiVideo_Color;  
begin
  shift := palette^.bitplaneFormat.bitsPerColorChannel - 4;
  colorSpecs := PamiVideo_UWord(AllocMem(palette^.bitplaneFormat.numOfColors * sizeof(TamiVideo_UWord)));
    
  i := 0;
  while (i < palette^.bitplaneFormat.numOfColors) do
  begin
    color := @palette^.bitplaneFormat.color[i];
    colorSpecs[i] := ((color^.r shr shift) shl 8) or ((color^.g shr shift) shl 4) or (color^.b shr shift);

    inc(i);
  end;
    
  result := colorSpecs;
end;


function  amiVideo_generateRGB32ColorSpecs(const palette: PamiVideo_Palette): PamiVideo_ULong;
var
  i : cuint;
  index : cuint;
  shift : cint;
  colorSpecs    : PamiVideo_ULong;
  color         : TamiVideo_Color;
begin
  index := 1;
  shift := 32 - palette^.bitplaneFormat.bitsPerColorChannel;
    
  colorSpecs := PamiVideo_ULong(AllocMem((palette^.bitplaneFormat.numOfColors * 3 + 2) * sizeof(TamiVideo_ULong)));
    
  //* First element's first word is number of colors, second word is the first color to be loaded (which is 0) */
  colorSpecs[0] := palette^.bitplaneFormat.numOfColors shl 16;
    
  //* Remaining elements are red, green, blue component values for each color register */
  i := 0;
  while (i < palette^.bitplaneFormat.numOfColors) do
  begin
    color := palette^.bitplaneFormat.color[i];
	
    colorSpecs[index] := color.r shl shift;
    inc(index);
    colorSpecs[index] := color.g shl shift;
    inc(index);
    colorSpecs[index] := color.b shl shift;
    inc(index);

    inc(i);
  end;
    
  //* Add 0 termination at the end */
  colorSpecs[index] := 0;
    
  //* Return the generated color specs */
  result := colorSpecs;
end;



//////////////////////////////////////////////////////////////////////////////
//        screen.c
//////////////////////////////////////////////////////////////////////////////



const
  _TRUE_    = 1;
  _FALSE_   = 0;


procedure amiVideo_initScreen(screen: PamiVideo_Screen; width: TamiVideo_Word; height: TamiVideo_Word; bitplaneDepth: cuint; bitsPerColorChannel: cuint; viewportMode: TamiVideo_Long);
var
  scanLineSizeInWords : cuint;
begin
  //* Assign values */
  screen^.width := width;
  screen^.height := height;
  screen^.bitplaneDepth := bitplaneDepth;
  screen^.viewportMode := viewportMode;
    
  //* Set allocation bits to FALSE */
  screen^.bitplaneFormat.memoryAllocated := FALSE;
  screen^.uncorrectedChunkyFormat.memoryAllocated := FALSE;
  screen^.uncorrectedRGBFormat.memoryAllocated := FALSE;
    
  //* Sets the palette */
  amiVideo_initPalette(@screen^.palette, bitplaneDepth, bitsPerColorChannel, viewportMode);
    
  //* Calculate the pitch of the bitplanes. The width in bytes is rounded to the nearest word boundary */
    
  scanLineSizeInWords := screen^.width div 16;
    
  if (screen^.width mod 16 <> 0)
  then inc(scanLineSizeInWords);

  screen^.bitplaneFormat.pitch := scanLineSizeInWords * 2;
end;


function  amiVideo_createScreen(width: TamiVideo_Word; height: TamiVideo_Word; bitplaneDepth: cuint; bitsPerColorChannel: cuint; viewportMode: TamiVideo_Long): PamiVideo_Screen;
var
  screen : PamiVideo_Screen;
begin
  screen := PamiVideo_Screen(AllocMem(sizeof(TamiVideo_Screen)));
    
  if (screen <> nil)
  then amiVideo_initScreen(screen, width, height, bitplaneDepth, bitsPerColorChannel, viewportMode);
    
  //* Return the allocated screen */
  result := screen;
end;


procedure amiVideo_cleanupScreen(screen: PamiVideo_Screen);
begin
  amiVideo_cleanupPalette(@screen^.palette);

  if (screen^.uncorrectedChunkyFormat.memoryAllocated)
  then FreeMem(screen^.uncorrectedChunkyFormat.pixels);
    
  if (screen^.uncorrectedRGBFormat.memoryAllocated)
  then FreeMem(screen^.uncorrectedRGBFormat.pixels);
end;


procedure amiVideo_freeScreen(screen: PamiVideo_Screen);
begin
  amiVideo_cleanupScreen(screen);
  FreeMem(screen);
end;


function  amiVideo_calculateCorrectedWidth(lowresPixelScaleFactor: cuint; width: TamiVideo_Long; viewportMode: TamiVideo_Long): cint;
begin
  if LongBool(amiVideo_checkSuperHires(viewportMode))
  then exit(lowresPixelScaleFactor * width div 4)
  else if LongBool(amiVideo_checkHires(viewportMode))
  then exit(lowresPixelScaleFactor * width div 2)   //* Hires pixels have double the size of super hires pixels */
  else
    result := lowresPixelScaleFactor * width; //* Lowres pixels have double the size of hi-res pixels */
end;


function  amiVideo_calculateCorrectedHeight(lowresPixelScaleFactor: cuint; height: TamiVideo_Long; viewportMode: TamiVideo_Long): cint;
begin
  if LongBool(amiVideo_checkLaced(viewportMode))
  then exit(lowresPixelScaleFactor * height div 2)
  else
    result := lowresPixelScaleFactor * height;  //* Non-interlaced screens have double the amount of scanlines */
end;


procedure amiVideo_setLowresPixelScaleFactor(screen: PamiVideo_Screen; lowresPixelScaleFactor: cuint);
begin
  screen^.correctedFormat.lowresPixelScaleFactor := lowresPixelScaleFactor;
    
  screen^.correctedFormat.width  := amiVideo_calculateCorrectedWidth(lowresPixelScaleFactor, screen^.width, screen^.viewportMode);
  screen^.correctedFormat.height := amiVideo_calculateCorrectedHeight(lowresPixelScaleFactor, screen^.height, screen^.viewportMode);
end;


procedure amiVideo_setScreenBitplanePointers(screen: PamiVideo_Screen; bitplanes: PPamiVideo_UByte);
begin
//  memcpy(screen^.bitplaneFormat.bitplanes, bitplanes, screen^.bitplaneDepth * sizeof(PamiVideo_UByte));
  memcpy(@screen^.bitplaneFormat.bitplanes, bitplanes, screen^.bitplaneDepth * sizeof(PamiVideo_UByte));
end;


procedure amiVideo_setScreenBitplanes(screen: PamiVideo_Screen; bitplanes: PamiVideo_UByte);
var
  bitplanePointers  : array[0..Pred(AMIVIDEO_MAX_NUM_OF_BITPLANES)] of PamiVideo_UByte; 
  offset            : cuint; // = 0;
  i                 : cuint;
begin
  offset := 0;
  //* Set bitplane pointers */
    
  i := 0;
  while (i < screen^.bitplaneDepth) do
  begin
    bitplanePointers[i] := bitplanes + offset;
    offset := offset + screen^.bitplaneFormat.pitch * screen^.height;

    inc(i);
  end;
    
  //* Set bitplane pointers */
  amiVideo_setScreenBitplanePointers(screen, bitplanePointers);
end;


procedure amiVideo_setScreenUncorrectedChunkyPixelsPointer(screen: PamiVideo_Screen; pixels: PamiVideo_UByte; pitch: cuint);
begin
  screen^.uncorrectedChunkyFormat.pixels := pixels;
  screen^.uncorrectedChunkyFormat.pitch := pitch;
  screen^.uncorrectedChunkyFormat.memoryAllocated := FALSE;
end;


procedure amiVideo_setScreenUncorrectedRGBPixelsPointer(screen: PamiVideo_Screen; pixels: PamiVideo_ULong; pitch: cuint; allocateUncorrectedMemory: cint; rshift: TamiVideo_UByte; gshift: TamiVideo_UByte; bshift: TamiVideo_UByte; ashift: TamiVideo_UByte);
begin
  screen^.uncorrectedRGBFormat.pixels := pixels;
  screen^.uncorrectedRGBFormat.pitch := pitch;
  screen^.uncorrectedRGBFormat.memoryAllocated := FALSE;
  screen^.uncorrectedRGBFormat.rshift := rshift;
  screen^.uncorrectedRGBFormat.gshift := gshift;
  screen^.uncorrectedRGBFormat.bshift := bshift;
  screen^.uncorrectedRGBFormat.ashift := ashift;
    
  if LongBool(allocateUncorrectedMemory) then
  begin
    screen^.uncorrectedChunkyFormat.pitch := screen^.width;
    screen^.uncorrectedChunkyFormat.pixels := 
    PamiVideo_UByte( AllocMem( (screen^.uncorrectedChunkyFormat.pitch * screen^.height) * sizeof(TamiVideo_UByte) ) );
    screen^.uncorrectedChunkyFormat.memoryAllocated := TRUE;
  end;
end;


procedure amiVideo_setScreenCorrectedPixelsPointer(screen: PamiVideo_Screen; pixels: pointer; pitch: cuint; bytesPerPixel: cuint; allocateUncorrectedMemory: cint; rshift: TamiVideo_UByte; gshift: TamiVideo_UByte; bshift: TamiVideo_UByte; ashift: TamiVideo_UByte);
begin
  screen^.correctedFormat.pixels := pixels;
  screen^.correctedFormat.pitch := pitch;
  screen^.correctedFormat.bytesPerPixel := bytesPerPixel;
    
  if LongBool(allocateUncorrectedMemory) then
  begin
    screen^.uncorrectedChunkyFormat.pitch := screen^.width;
    screen^.uncorrectedChunkyFormat.pixels := PamiVideo_UByte(AllocMem( (screen^.uncorrectedChunkyFormat.pitch * screen^.height) * sizeof(TamiVideo_UByte)));
    screen^.uncorrectedChunkyFormat.memoryAllocated := TRUE;
	
    if (bytesPerPixel = 4) then
    begin
      screen^.uncorrectedRGBFormat.pitch := screen^.width * 4;
      screen^.uncorrectedRGBFormat.pixels := PamiVideo_ULong(AllocMem( (screen^.uncorrectedRGBFormat.pitch * screen^.height) * sizeof(TamiVideo_UByte)));
      screen^.uncorrectedRGBFormat.memoryAllocated := TRUE;
      screen^.uncorrectedRGBFormat.rshift := rshift;
      screen^.uncorrectedRGBFormat.gshift := gshift;
      screen^.uncorrectedRGBFormat.bshift := bshift;
      screen^.uncorrectedRGBFormat.ashift := ashift;
    end
    else
      screen^.uncorrectedRGBFormat.memoryAllocated := FALSE;
  end
  else
  begin
    screen^.uncorrectedChunkyFormat.memoryAllocated := FALSE;
    screen^.uncorrectedRGBFormat.memoryAllocated := FALSE;
  end;
end;


procedure convertScreenBitplanesToTarget(screen: PamiVideo_Screen; chunky: cint);
var
  i             : cuint;
var
  count         : cuint;
  indexBit      : TamiVideo_ULong;
  bitplanes     : PamiVideo_UByte;
  vOffset       : cuint;
  j             : cuint;
var
  hOffset       : cuint;
  k             : cuint;
  pixelCount    : cuint;
var
  bitplane      : TamiVideo_UByte;
  bitmask       : byte;
  l             : cuint;
begin    
  i := 0;
  while (i < screen^.bitplaneDepth) do  //* Iterate over each bitplane */
  begin
    count := 0;
    indexBit := 1 shl i;
    bitplanes := screen^.bitplaneFormat.bitplanes[i];
    vOffset := 0;
	
    j := 0;
    while (j < screen^.height) do //* Iterate over each scan line */
    begin
      hOffset := vOffset;
      pixelCount := 0;
	    
      k := 0;
      while (k < screen^.bitplaneFormat.pitch) do //* Iterate over each byte containing 8 pixels */
      begin
        bitplane := bitplanes[hOffset];
        bitmask := $80;
		
        for l := 0 to Pred(8) do //* Iterate over each bit representing a pixel */
        begin
          if (pixelCount < screen^.width) then //* We must skip the padding bits. If we have already converted sufficient pixels on this scanline, ignore the rest */
          begin
            if ((bitplane and bitmask) <> 0) then
            begin
              if LongBool(chunky)
              then screen^.uncorrectedChunkyFormat.pixels[count] := screen^.uncorrectedChunkyFormat.pixels[count] or indexBit
              else
                screen^.uncorrectedRGBFormat.pixels[count] := screen^.uncorrectedRGBFormat.pixels[count] or indexBit;
            end;
            inc(count);
          end;
		    
          inc(pixelCount);
          bitmask := bitmask shr 1;
        end;
		
        inc(hOffset);

        inc(k);
      end;
	    
      //* Skip the padding bytes in the output */
      if LongBool(chunky)
      then count := count + screen^.uncorrectedChunkyFormat.pitch - screen^.width
      else
        count := count + screen^.uncorrectedRGBFormat.pitch div 4 - screen^.width;
	    
      vOffset := vOffset + screen^.bitplaneFormat.pitch;

      inc(j);
    end;

    inc(i);
  end;
end;


procedure amiVideo_convertScreenBitplanesToChunkyPixels(screen: PamiVideo_Screen);
begin
  convertScreenBitplanesToTarget(screen, _TRUE_);
end;


function  convertColorToRGBPixel(const color: PamiVideo_OutputColor; rshift: TamiVideo_UByte; gshift: TamiVideo_UByte; bshift: TamiVideo_UByte; ashift: TamiVideo_UByte): TamiVideo_ULong;
begin
  result := (color^.r shl rshift) or (color^.g shl gshift) or (color^.b shl bshift) or (color^.a shl ashift);
end;


procedure amiVideo_convertScreenChunkyPixelsToRGBPixels(screen: PamiVideo_Screen);
var
  screenWidthInPixels   : cuint;
  i                     : cuint;
  offset                : cuint;
var
  j                     : cuint;
  previousResult        : TamiVideo_OutputColor;
var
  byt                   : TamiVideo_UByte;
  mode                  : TamiVideo_UByte;
  index                 : TamiVideo_UByte;
  res                   : TamiVideo_OutputColor;
begin
  screenWidthInPixels := screen^.uncorrectedRGBFormat.pitch div 4;
    
  if LongBool(amiVideo_checkHoldAndModify(screen^.viewportMode)) then
  begin
    //* HAM mode has its own decompression technique */
    offset := 0;
	
    i := 0;
    while (i < screen^.height) do
    begin
      previousResult := screen^.palette.chunkyFormat.color[0];
	    
      j := 0;
      while (j < screenWidthInPixels) do
      begin
        byt   := screen^.uncorrectedChunkyFormat.pixels[offset + j];
        mode  := (byt and ($3 shl (screen^.bitplaneDepth - 2))) shr (screen^.bitplaneDepth - 2);
        index := byt and not($3 shl (screen^.bitplaneDepth - 2));
		
        if (mode = $0) //* Data bits are an index in the color palette */
        then res := screen^.palette.chunkyFormat.color[index]
        else if (mode = $1) then //* Data bits are blue level */
        begin
          res := previousResult;
          res.b := index shl (8 - screen^.bitplaneDepth + 2);
        end
        else if (mode = $2) then //* Data bits are red level */
        begin
          res := previousResult;
          res.r := index shl (8 - screen^.bitplaneDepth + 2);
        end
        else if (mode = $3) then //* Data bits are green level */
        begin
          res := previousResult;
          res.g := index shl (8 - screen^.bitplaneDepth + 2);
        end;
		
        //* set new pixel on offset + j */
        screen^.uncorrectedRGBFormat.pixels[offset + j] := convertColorToRGBPixel(@res, screen^.uncorrectedRGBFormat.rshift, screen^.uncorrectedRGBFormat.gshift, screen^.uncorrectedRGBFormat.bshift, screen^.uncorrectedRGBFormat.ashift);
		
        previousResult := res;

        inc(j);
      end;
	    
      offset := offset + screenWidthInPixels;

      inc(i);
    end;
  end
  else
  begin
    //* Normal mode */
    i := 0;
    while (i < screenWidthInPixels * screen^.height) do
    begin
      screen^.uncorrectedRGBFormat.pixels[i] := convertColorToRGBPixel(@screen^.palette.chunkyFormat.color[screen^.uncorrectedChunkyFormat.pixels[i]], screen^.uncorrectedRGBFormat.rshift, screen^.uncorrectedRGBFormat.gshift, screen^.uncorrectedRGBFormat.bshift, screen^.uncorrectedRGBFormat.ashift);
      inc(i);
    end;
  end;
end;


procedure amiVideo_convertScreenChunkyPixelsToBitplanes(screen: PamiVideo_Screen);
var
  i             : cuint;
  bitplaneIndex : cuint;
  bit           : cint;
var
  j             : cuint;
  bitmask       : TamiVideo_UByte;
begin
  bitplaneIndex := 0;
  bit := 7;

  i := 0;
  while (i < screen^.width * screen^.height) do
  begin
    bitmask := 1 shl bit;
	
    j := 0;
    while (j < screen^.bitplaneDepth) do
    begin
      if (screen^.uncorrectedChunkyFormat.pixels[i] and (1 shl j) <> 0) //* Check if the current bit of the index value is set */
      then screen^.bitplaneFormat.bitplanes[j][bitplaneIndex] := screen^.bitplaneFormat.bitplanes[j][bitplaneIndex] or bitmask //* Modify the current bit in the bitplane byte to be 1 and leave the others untouched */
      else
        screen^.bitplaneFormat.bitplanes[j][bitplaneIndex] := screen^.bitplaneFormat.bitplanes[j][bitplaneIndex] and not(bitmask); //* Modify the current bit in the bitplane byte to be 0 and leave the others untouched */

      inc(j);
    end;

    dec(bit);
	
    if (bit < 0) then
    begin
      bit := 7; //* Reset the bit counter */
      inc(bitplaneIndex); //* Go to the next byte in the bitplane memory */
    end;

    inc(i);
  end;
end;


procedure amiVideo_correctScreenPixels(screen: PamiVideo_Screen);
var
  i                 : cuint;
  sourceOffset, 
  destOffset        : cuint;
  repeatHorizontal  : cuint;
  repeatVertical    : cuint;
  pixels            : PamiVideo_UByte;
var
  j, k              : cuint;
begin
  sourceOffset := 0;
  destOffset := 0;
    
  //* Calculate how many times we have to horizontally repeat a pixel */
  if (amiVideo_checkSuperHires(screen^.viewportMode) <> 0)
  then repeatHorizontal := screen^.correctedFormat.lowresPixelScaleFactor div 4
  else if (amiVideo_checkHires(screen^.viewportMode) <> 0)
  then repeatHorizontal := screen^.correctedFormat.lowresPixelScaleFactor div 2
  else
    repeatHorizontal := screen^.correctedFormat.lowresPixelScaleFactor;
    
  //* Calculate how many times we have to vertically repeat a scanline */
    
  if (amiVideo_checkLaced(screen^.viewportMode) <> 0)
  then repeatVertical := screen^.correctedFormat.lowresPixelScaleFactor div 2
  else
    repeatVertical := screen^.correctedFormat.lowresPixelScaleFactor;
    
  //* Check which pixels we have to correct */
    
  if (screen^.correctedFormat.bytesPerPixel = 1)
  then pixels := screen^.uncorrectedChunkyFormat.pixels
  else
    pixels := PamiVideo_UByte(screen^.uncorrectedRGBFormat.pixels);
    
  //* Do the correction */
  i := 0;
  while (i < screen^.height) do
  begin

    j := 0;
    while (j < screen^.width) do
    begin
	    
      //* Scale the pixel horizontally */
      k := 0;
      while (k < repeatHorizontal) do
      begin
        memcpy
        (
          PamiVideo_UByte(screen^.correctedFormat.pixels + destOffset), 
          Pointer(pixels + sourceOffset),
          screen^.correctedFormat.bytesPerPixel
        );
        destOffset := destOffset + screen^.correctedFormat.bytesPerPixel;

        inc(k);
      end;
	
      sourceOffset := sourceOffset + screen^.correctedFormat.bytesPerPixel;

      inc(j);
    end;
	
    destOffset := destOffset + screen^.correctedFormat.pitch - screen^.correctedFormat.width * screen^.correctedFormat.bytesPerPixel; //* Skip the padding bytes */
	
    //* Non-interlace screen scanlines must be doubled */
    j := 0;
    while (j < repeatVertical) do
    begin
      memcpy(PamiVideo_UByte(screen^.correctedFormat.pixels + destOffset), PamiVideo_UByte(screen^.correctedFormat.pixels + destOffset - screen^.correctedFormat.pitch), screen^.correctedFormat.pitch);
      destOffset := destOffset + screen^.correctedFormat.pitch;
      inc(j);
    end;

    inc(i);
  end;
end;


procedure amiVideo_convertScreenBitplanesToRGBPixels(screen: PamiVideo_Screen);
begin
  if ( (screen^.bitplaneDepth = 24) or (screen^.bitplaneDepth = 32) ) then //* For true color images we directly convert bitplanes to RGB pixels */
  begin
    convertScreenBitplanesToTarget(screen, _FALSE_);
    amiVideo_reorderRGBPixels(screen);
  end
  else
  begin
    //* For lower bitplane depths we first have to compose chunky pixels to determine the actual color values */
    amiVideo_convertBitplaneColorsToChunkyFormat(@screen^.palette);
    amiVideo_convertScreenBitplanesToChunkyPixels(screen);
    amiVideo_convertScreenChunkyPixelsToRGBPixels(screen);
  end;
end;


procedure amiVideo_convertScreenBitplanesToCorrectedChunkyPixels(screen: PamiVideo_Screen);
begin
  amiVideo_convertScreenBitplanesToChunkyPixels(screen);
  amiVideo_correctScreenPixels(screen);
end;


procedure amiVideo_convertScreenBitplanesToCorrectedRGBPixels(screen: PamiVideo_Screen);
begin
  amiVideo_convertScreenBitplanesToRGBPixels(screen);
  amiVideo_correctScreenPixels(screen);
end;


procedure amiVideo_convertScreenChunkyPixelsToCorrectedRGBPixels(screen: PamiVideo_Screen);
begin
  amiVideo_convertScreenChunkyPixelsToRGBPixels(screen);
  amiVideo_correctScreenPixels(screen);
end;


function  amiVideo_autoSelectColorFormat(const screen: PamiVideo_Screen): TamiVideo_ColorFormat;
begin
  if 
  ( 
    LongBool(amiVideo_checkHoldAndModify(screen^.viewportMode)) or 
    (screen^.bitplaneDepth = 24) or 
    (screen^.bitplaneDepth = 32)
  )
  then exit(AMIVIDEO_RGB_FORMAT)
  else
    result := AMIVIDEO_CHUNKY_FORMAT;
end;


procedure  reorderPixelBytes(screen: PamiVideo_Screen; rshift: TamiVideo_UByte; gshift: TamiVideo_UByte; bshift: TamiVideo_UByte; ashift: TamiVideo_UByte);
var
  i     : cuint;
  pixel : TamiVideo_ULong;
  color : TamiVideo_OutputColor;
begin
  i := 0;
  while (i < screen^.uncorrectedRGBFormat.pitch div 4 * screen^.height) do
  begin
    pixel := screen^.uncorrectedRGBFormat.pixels[i];
       
    color.r := (pixel shr rshift) and $ff;
    color.g := (pixel shr gshift) and $ff;
    color.b := (pixel shr bshift) and $ff;
    color.a := (pixel shr ashift) and $ff;
        
    convertColorToRGBPixel(@color, screen^.uncorrectedRGBFormat.rshift, screen^.uncorrectedRGBFormat.gshift, screen^.uncorrectedRGBFormat.bshift, screen^.uncorrectedRGBFormat.ashift);

    inc(i);
  end;
end;


procedure amiVideo_reorderRGBPixels(screen: PamiVideo_Screen);
begin
  //* Reorder the bytes if the real display uses a different order */
  if 
  ( 
    (screen^.bitplaneDepth = 24) and 
    (screen^.uncorrectedRGBFormat.ashift <> 24) or 
    (screen^.uncorrectedRGBFormat.rshift <> 16) or
    (screen^.uncorrectedRGBFormat.gshift <>  8) or 
    (screen^.uncorrectedRGBFormat.bshift <> 0)
  )
  then reorderPixelBytes(screen, 16, 8, 0, 24)
  else 
  if 
  (
    (screen^.bitplaneDepth = 32) and 
    (screen^.uncorrectedRGBFormat.rshift <> 24) or
    (screen^.uncorrectedRGBFormat.gshift <> 16) or
    (screen^.uncorrectedRGBFormat.bshift <>  8) or 
    (screen^.uncorrectedRGBFormat.ashift <>  0)
  )
  then reorderPixelBytes(screen, 24, 16, 8, 0);
end;



end.
