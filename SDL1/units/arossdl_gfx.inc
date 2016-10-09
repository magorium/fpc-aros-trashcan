procedure SDL_initFramerate( manager : PFPSmanager );
cdecl; external;
{$EXTERNALSYM SDL_initFramerate}

function SDL_setFramerate( manager : PFPSmanager; rate : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_setFramerate}

function SDL_getFramerate( manager : PFPSmanager ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_getFramerate}

procedure SDL_framerateDelay( manager : PFPSmanager );
cdecl; external;
{$EXTERNALSYM SDL_framerateDelay}

{

 SDL_gfxPrimitives: graphics primitives for SDL

 LGPL (c) A. Schiffler

}

// Note: all ___Color routines expect the color to be in format 0xRRGGBBAA 

// Pixel 

function pixelColor( dst : PSDL_Surface; x : Sint16; y : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM pixelColor}

function pixelRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM pixelRGBA}

// Horizontal line 

function hlineColor( dst : PSDL_Surface; x1: Sint16; x2 : Sint16; y : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM hlineColor}

function hlineRGBA( dst : PSDL_Surface; x1: Sint16; x2 : Sint16; y : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM hlineRGBA}

// Vertical line 

function vlineColor( dst : PSDL_Surface; x : Sint16; y1 : Sint16; y2 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM vlineColor}

function vlineRGBA( dst : PSDL_Surface; x : Sint16; y1 : Sint16; y2 : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM vlineRGBA}

// Rectangle 

function rectangleColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM rectangleColor}

function rectangleRGBA( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16;
				   x2 : Sint16; y2 : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM rectangleRGBA}

// Filled rectangle (Box) 

function boxColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM boxColor}

function boxRGBA( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16;
			     y2 : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM boxRGBA}

// Line 

function lineColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM lineColor}

function lineRGBA( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16;
			      x2 : Sint16; y2 : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM lineRGBA}

// AA Line 
function aalineColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM aalineColor}

function aalineRGBA( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16;
				x2 : Sint16; y2 : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM aalineRGBA}

// Circle 

function circleColor( dst : PSDL_Surface; x : Sint16; y : Sint16; r : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM circleColor}

function circleRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16; rad : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM circleRGBA}

// AA Circle 

function aacircleColor( dst : PSDL_Surface; x : Sint16; y : Sint16; r : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM aacircleColor}

function aacircleRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16;
				  rad : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM aacircleRGBA}

// Filled Circle 

function filledCircleColor( dst : PSDL_Surface; x : Sint16; y : Sint16; r : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM filledCircleColor}

function filledCircleRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16;
				      rad : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM filledCircleRGBA}

// Ellipse 

function ellipseColor( dst : PSDL_Surface; x : Sint16; y : Sint16; rx : Sint16; ry : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM ellipseColor}

function ellipseRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16;
				 rx : Sint16; ry : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM ellipseRGBA}

// AA Ellipse 

function aaellipseColor( dst : PSDL_Surface; xc : Sint16; yc : Sint16; rx : Sint16; ry : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM aaellipseColor}

function aaellipseRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16;
				   rx : Sint16; ry : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM aaellipseRGBA}

// Filled Ellipse 

function filledEllipseColor( dst : PSDL_Surface; x : Sint16; y : Sint16; rx : Sint16; ry : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM filledEllipseColor}

function filledEllipseRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16;
				       rx : Sint16; ry : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM filledEllipseRGBA}

// Pie

function pieColor( dst : PSDL_Surface; x : Sint16; y : Sint16; rad : Sint16;
			      start : Sint16; finish : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM pieColor}

function pieRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16; rad : Sint16;
			     start : Sint16; finish : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM pieRGBA}

// Filled Pie

function filledPieColor( dst : PSDL_Surface; x : Sint16; y : Sint16; rad : Sint16;
				    start : Sint16; finish : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM filledPieColor}

function filledPieRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16; rad : Sint16;
				   start : Sint16; finish : Sint16; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM filledPieRGBA}

// Trigon

function trigonColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; x3 : Sint16; y3 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM trigonColor}

function trigonRGBA( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; x3 : Sint16; y3 : Sint16;
				 r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM trigonRGBA}

// AA-Trigon

function aatrigonColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; x3 : Sint16; y3 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM aatrigonColor}
function aatrigonRGBA( dst : PSDL_Surface;  x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; x3 : Sint16; y3 : Sint16;
				   r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM aatrigonRGBA}

// Filled Trigon

function filledTrigonColor( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; x3 : Sint16; y3 : Sint16; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM filledTrigonColor}

function filledTrigonRGBA( dst : PSDL_Surface; x1 : Sint16; y1 : Sint16; x2 : Sint16; y2 : Sint16; x3 : Sint16; y3 : Sint16;
				       r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM filledTrigonRGBA}

// Polygon

function polygonColor( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16; n : integer; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM polygonColor}

function polygonRGBA( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16;
				 n : integer; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM polygonRGBA}

// AA-Polygon

function aapolygonColor( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16; n : integer; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM aapolygonColor}

function aapolygonRGBA( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16;
				   n : integer; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM aapolygonRGBA}

// Filled Polygon

function filledPolygonColor( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16; n : integer; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM filledPolygonColor}

function filledPolygonRGBA( dst : PSDL_Surface; const vx : PSint16;
				       const vy : PSint16; n : integer; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM filledPolygonRGBA}

// Bezier
// s = number of steps

function bezierColor( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16; n : integer; s : integer; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM bezierColor}

function bezierRGBA( dst : PSDL_Surface; const vx : PSint16; const vy : PSint16;
				 n : integer; s : integer; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM bezierRGBA}


// Characters/Strings

function characterColor( dst : PSDL_Surface; x : Sint16; y : Sint16; c : char; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM characterColor}

function characterRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16; c : char; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM characterRGBA}

function stringColor( dst : PSDL_Surface; x : Sint16; y : Sint16; const c : PChar; color : Uint32 ) : integer;
cdecl; external;
{$EXTERNALSYM stringColor}

function stringRGBA( dst : PSDL_Surface; x : Sint16; y : Sint16; const c : PChar; r : Uint8; g : Uint8; b : Uint8; a : Uint8 ) : integer;
cdecl; external;
{$EXTERNALSYM stringRGBA}

procedure gfxPrimitivesSetFont(const fontdata : Pointer; cw : integer; ch : integer );
cdecl; external;
{$EXTERNALSYM gfxPrimitivesSetFont}

{

 SDL_imageFilter - bytes-image "filter" routines
 (uses inline x86 MMX optimizations if available)

 LGPL (c) A. Schiffler

}

{ Comments:                                                                           }
{  1.) MMX functions work best if all data blocks are aligned on a 32 bytes boundary. }
{  2.) Data that is not within an 8 byte boundary is processed using the C routine.   }
{  3.) Convolution routines do not have C routines at this time.                      }

// Detect MMX capability in CPU
function SDL_imageFilterMMXdetect : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMMXdetect}

// Force use of MMX off (or turn possible use back on)
procedure SDL_imageFilterMMXoff;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMMXoff}

procedure SDL_imageFilterMMXon;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMMXon}

//
// All routines return:
//   0   OK
//  -1   Error (internal error, parameter error)
//

//  SDL_imageFilterAdd: D = saturation255(S1 + S2)
function SDL_imageFilterAdd(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterAdd}

//  SDL_imageFilterMean: D = S1/2 + S2/2
function SDL_imageFilterMean(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMean}

//  SDL_imageFilterSub: D = saturation0(S1 - S2)
function SDL_imageFilterSub(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterSub}

//  SDL_imageFilterAbsDiff: D = | S1 - S2 |
function SDL_imageFilterAbsDiff(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterAbsDiff}

//  SDL_imageFilterMult: D = saturation(S1 * S2)
function SDL_imageFilterMult(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMult}

//  SDL_imageFilterMultNor: D = S1 * S2   (non-MMX)
function SDL_imageFilterMultNor(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMultNor}

//  SDL_imageFilterMultDivby2: D = saturation255(S1/2 * S2)
function SDL_imageFilterMultDivby2(Src1 : PChar; Src2 : PChar; Dest : PChar;
					       length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMultDivby2}

//  SDL_imageFilterMultDivby4: D = saturation255(S1/2 * S2/2)
function SDL_imageFilterMultDivby4(Src1 : PChar; Src2 : PChar; Dest : PChar;
					       length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMultDivby4}

//  SDL_imageFilterBitAnd: D = S1 & S2
function SDL_imageFilterBitAnd(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterBitAnd}

//  SDL_imageFilterBitOr: D = S1 | S2
function SDL_imageFilterBitOr(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterBitOr}

//  SDL_imageFilterDiv: D = S1 / S2   (non-MMX)
function SDL_imageFilterDiv(Src1 : PChar; Src2 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterDiv}

//  SDL_imageFilterBitNegation: D = !S
function SDL_imageFilterBitNegation(Src1 : PChar; Dest : PChar; length : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterBitNegation}

//  SDL_imageFilterAddByte: D = saturation255(S + C)
function SDL_imageFilterAddByte(Src1 : PChar; Dest : PChar; length : integer; C : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterAddByte}

//  SDL_imageFilterAddUint: D = saturation255(S + (uint)C)
function SDL_imageFilterAddUint(Src1 : PChar; Dest : PChar; length : integer; C : Cardinal ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterAddUint}

//  SDL_imageFilterAddByteToHalf: D = saturation255(S/2 + C)
function SDL_imageFilterAddByteToHalf(Src1 : PChar; Dest : PChar; length : integer;
						  C : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterAddByteToHalf}

//  SDL_imageFilterSubByte: D = saturation0(S - C)
function SDL_imageFilterSubByte(Src1 : PChar; Dest : PChar; length : integer; C : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterSubByte}

//  SDL_imageFilterSubUint: D = saturation0(S - (uint)C)
function SDL_imageFilterSubUint(Src1 : PChar; Dest : PChar; length : integer; C : Cardinal ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterSubUint}

//  SDL_imageFilterShiftRight: D = saturation0(S >> N)
function SDL_imageFilterShiftRight(Src1 : PChar; Dest : PChar; length : integer;  N : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterShiftRight}

//  SDL_imageFilterShiftRightUint: D = saturation0((uint)S >> N)
function SDL_imageFilterShiftRightUint(Src1 : PChar; Dest : PChar; length : integer;  N : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterShiftRightUint}

//  SDL_imageFilterMultByByte: D = saturation255(S * C)
function SDL_imageFilterMultByByte(Src1 : PChar; Dest : PChar; length : integer; C : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterMultByByte}

//  SDL_imageFilterShiftRightAndMultByByte: D = saturation255((S >> N) * C)
function SDL_imageFilterShiftRightAndMultByByte(Src1 : PChar; Dest : PChar; length : integer;
							     N : char; C : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterShiftRightAndMultByByte}

//  SDL_imageFilterShiftLeftByte: D = (S << N)
function SDL_imageFilterShiftLeftByte(Src1 : PChar; Dest : PChar; length : integer;
						   N : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterShiftLeftByte}

//  SDL_imageFilterShiftLeftUint: D = ((uint)S << N)
function SDL_imageFilterShiftLeftUint(Src1 : PChar; Dest : PChar; length : integer;
						   N : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterShiftLeftUint}

//  SDL_imageFilterShiftLeft: D = saturation255(S << N)
function SDL_imageFilterShiftLeft(Src1 : PChar; Dest : PChar; length : integer;  N : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterShiftLeft}

//  SDL_imageFilterBinarizeUsingThreshold: D = S >= T ? 255:0
function SDL_imageFilterBinarizeUsingThreshold(Src1 : PChar; Dest : PChar; length : integer;
							   T : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterBinarizeUsingThreshold}

//  SDL_imageFilterClipToRange: D = (S >= Tmin) & (S <= Tmax) 255:0
function SDL_imageFilterClipToRange(Src1 : PChar; Dest : PChar; length : integer;
						Tmin : Byte; Tmax : Byte ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterClipToRange}

//  SDL_imageFilterNormalizeLinear: D = saturation255((Nmax - Nmin)/(Cmax - Cmin)*(S - Cmin) + Nmin)
function SDL_imageFilterNormalizeLinear(Src1 : PChar; Dest : PChar; length : integer; Cmin : integer;
						    Cmax : integer; Nmin : integer; Nmax : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterClipToRange}

{ !!! NO C-ROUTINE FOR THESE FUNCTIONS YET !!! }

//  SDL_imageFilterConvolveKernel3x3Divide: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel3x3Divide(Src : PChar; Dest : PChar; rows : integer;
							    columns : integer; Kernel : PShortInt; Divisor : Byte ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel3x3Divide}

//  SDL_imageFilterConvolveKernel5x5Divide: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel5x5Divide(Src : PChar; Dest : PChar; rows : integer;
							    columns : integer; Kernel : PShortInt; Divisor : Byte ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel5x5Divide}

//  SDL_imageFilterConvolveKernel7x7Divide: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel7x7Divide(Src : PChar; Dest : PChar; rows : integer;
							    columns : integer; Kernel : PShortInt; Divisor : Byte ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel7x7Divide}

//  SDL_imageFilterConvolveKernel9x9Divide: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel9x9Divide(Src : PChar; Dest : PChar; rows : integer;
							    columns : integer; Kernel : PShortInt; Divisor : Byte ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel9x9Divide}

//  SDL_imageFilterConvolveKernel3x3ShiftRight: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel3x3ShiftRight(Src : PChar; Dest : PChar; rows : integer;
								columns : integer; Kernel : PShortInt;
								 NRightShift : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel3x3ShiftRight}

//  SDL_imageFilterConvolveKernel5x5ShiftRight: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel5x5ShiftRight(Src : PChar; Dest : PChar; rows : integer;
								columns : integer; Kernel : PShortInt;
								 NRightShift : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel5x5ShiftRight}

//  SDL_imageFilterConvolveKernel7x7ShiftRight: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel7x7ShiftRight(Src : PChar; Dest : PChar; rows : integer;
								columns : integer; Kernel : PShortInt;
								 NRightShift : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel7x7ShiftRight}

//  SDL_imageFilterConvolveKernel9x9ShiftRight: Dij = saturation0and255( ... )
function SDL_imageFilterConvolveKernel9x9ShiftRight(Src : PChar; Dest : PChar; rows : integer;
								columns : integer; Kernel : PShortInt;
								 NRightShift : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterConvolveKernel9x9ShiftRight}

//  SDL_imageFilterSobelX: Dij = saturation255( ... )
function SDL_imageFilterSobelX(Src : PChar; Dest : PChar; rows : integer; columns : integer ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterSobelX}

//  SDL_imageFilterSobelXShiftRight: Dij = saturation255( ... )
function SDL_imageFilterSobelXShiftRight(Src : PChar; Dest : PChar; rows : integer; columns : integer;
						      NRightShift : char ) : integer;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterSobelXShiftRight}

// Align/restore stack to 32 byte boundary -- Functionality untested! --
procedure SDL_imageFilterAlignStack;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterAlignStack}

procedure SDL_imageFilterRestoreStack;
cdecl; external;
{$EXTERNALSYM SDL_imageFilterRestoreStack}

{

 SDL_rotozoom - rotozoomer

 LGPL (c) A. Schiffler

}

{ 
 
 rotozoomSurface()

 Rotates and zoomes a 32bit or 8bit 'src' surface to newly created 'dst' surface.
 'angle' is the rotation in degrees. 'zoom' a scaling factor. If 'smooth' is 1
 then the destination 32bit surface is anti-aliased. If the surface is not 8bit
 or 32bit RGBA/ABGR it will be converted into a 32bit RGBA format on the fly.

}

function rotozoomSurface( src : PSDL_Surface; angle : double; zoom : double; smooth : integer ) : PSDL_Surface;
cdecl; external;
{$EXTERNALSYM rotozoomSurface}

function rotozoomSurfaceXY( src : PSDL_Surface; angle : double; zoomx : double; zoomy : double; smooth : integer ) : PSDL_Surface;
cdecl; external;
{$EXTERNALSYM rotozoomSurfaceXY}

{ Returns the size of the target surface for a rotozoomSurface() call }

procedure rotozoomSurfaceSize( width : integer; height : integer; angle : double; zoom : double; var dstwidth : integer;
					  var dstheight : integer );
cdecl; external;
{$EXTERNALSYM rotozoomSurfaceSize}

procedure rotozoomSurfaceSizeXY
    ( width : integer; height : integer; angle : double; zoomx : double; zoomy : double;
     var dstwidth : integer; var dstheight : integer );
cdecl; external;
{$EXTERNALSYM rotozoomSurfaceSizeXY}

{

 zoomSurface()

 Zoomes a 32bit or 8bit 'src' surface to newly created 'dst' surface.
 'zoomx' and 'zoomy' are scaling factors for width and height. If 'smooth' is 1
 then the destination 32bit surface is anti-aliased. If the surface is not 8bit
 or 32bit RGBA/ABGR it will be converted into a 32bit RGBA format on the fly.

}

function zoomSurface(src : PSDL_Surface; zoomx : double; zoomy : double; smooth : integer ) : PSDL_Surface;
cdecl; external;
{$EXTERNALSYM zoomSurface}

{ Returns the size of the target surface for a zoomSurface() call }

procedure zoomSurfaceSize( width : integer; height : integer; zoomx : double; zoomy : double; var dstwidth : integer; var dstheight : integer );
cdecl; external;
{$EXTERNALSYM zoomSurfaceSize}
