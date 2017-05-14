program icon2iff;

{$MODE OBJFPC}{$H+}

uses
  Classes, fpImage, FPWritePNG, SysUtils, StrUtils, 
  Exec, AmigaDOS, WorkBench, Icon, Intuition, icon_native;

(*
    original icontoiff readme:

    This command converts the images found in .info files into IFF ILBMs
    or other write-supporting DataTypes.

    It will cope with any format icon.library is capable of reading,
    including any installed icon modules under OS4, with the exception
    of old-style planar icons.

    It outputs 24-bit or 32-bit IFF ILBMs (or other formats supported by
    DataTypes)

    icontoiff68k is compiled for 68k (OS3.5 & 3.9)
    icontoiff is compiled for PPC (OS4.0 and up)

    Template:
    icontoiff SOURCE/A,DEST/A,NOALPHA/S,ALT=ALTERNATE/S,FORMAT=OUTPUTFORMAT/K

    Source:       Source file (do not include ".info")
    Dest:         Destination (may be overwritten!)
    NoAlpha:      Ignore alpha (create a 24-bit ILBM)
    Alternate:    Convert the alternate (selected) icon image
    OutputFormat: Specify the name of a DataType to use to save the image
    ( * see note below)

    * The only DataType known to work is the OS4 WebP DataType, v1.5 or higher.
    For ILBM *do not* specify an output format ("ILBM" will cause icontoiff to
    use the subclass instead of the superclass and will fail)
    Subclass implementers - please see section at end of this readme.
*)

const
  VERSION_STRING : PChar = #0'$VER: icon2iff 0.1 (13.05.2017) (c)2017 magorium';
const
  //  ARG_TEMPLATE : PChar = 'SOURCE/A,DEST/A,NOALPHA/S,ALT=ALTERNATE/S,FORMAT=OUTPUTFORMAT/K';
  ARG_TEMPLATE : PChar = 'SOURCE/A,DEST/A,NOALPHA/S,ALT=ALTERNATE/S,FORMAT=OUTPUTFORMAT/K,DUMP/S,VERBOSE/S';

  ARG_SOURCE  = 0;
  ARG_DEST    = 1;  
  ARG_NOALPHA = 2;
  ARG_ALT     = 3;
  ARG_FORMAT  = 4;
  ARG_DUMP    = 5;
  ARG_VERBOSE = 6;
  NUM_ARGS    = 7;

const
  OutputFileTypes    : Array[0..1] of String = ('IFF','PNG');

var
  Opt_SourceFilename : String;
  Opt_DestFileName   : String;
  Opt_NoAlpha        : boolean;
  Opt_Alternate      : Boolean;
  Opt_Format         : String;
  Opt_Dump           : boolean;
  Opt_Verbose        : boolean;


type
  TNativeImageStorage = 
  ( 
    nisGadget,    // Classic icon format with old_drawerdata structure 
    nisARGB       // Classic icon format + do_drawer amiga OS2.x extension (these stored directly after xxx) 
  );


type
  TReadStructStates = 
  (
    RSS_OLDDRAWERDATA_READ, 
    RSS_GADGETIMAGE_READ,
    RSS_SELECTIMAGE_READ,
    RSS_DEFAULTTOOL_READ,
    RSS_TOOLWINDOW_READ,
    RSS_TOOLTYPES_READ
  );
  TReadStructState = set of TReadStructStates;


type
  TRGBTriple = packed record
    r,g,b: Byte;
  end;

  PARGBQUAD = ^TARGBQUAD;
  TARGBQUAD = packed record
    a,r,g,b: byte;
  end;

  TPixelRenderInfo = record
    Width        : LongInt;
    Height       : LongInt;
    RenderPixels : PARGBQUAD;
  end;


const
  STD_04_colpal : packed array[0..3] of TRGBTriple =
  (
    (r: $95; g: $95; b: $95),    //* Gray (and transparent!) */
    (r: $00; g: $00; b: $00),    //* Black */
    (r: $FF; g: $FF; b: $FF),    //* White */
    (r: $3b; g: $67; b: $a2)     //* Blue */
  );

  MWB_08_colpal :  packed array[0..7] of TRGBTriple =
  (
    (r: $95; g: $95; b: $95),    //* Gray (and transparent!) */
    (r: $00; g: $00; b: $00),    //* Black */
    (r: $FF; g: $FF; b: $FF),    //* White */
    (r: $3b; g: $67; b: $a2),    //* Blue */
    (r: $7b; g: $7b; b: $7b),    //* Dk. Gray */
    (r: $af; g: $af; b: $af),    //* Lt. Gray */
    (r: $aa; g: $90; b: $7c),    //* Brown */
    (r: $ff; g: $a9; b: $97)     //* Pink */
  );

  SOS_16_colpal :  packed array[0..15] of TRGBTriple =
  (
    (r: $9c; g: $9c; b: $9c),    //*  0 - Gray */
    (r: $00; g: $00; b: $00),    //*  1 - Black */
    (r: $FF; g: $FF; b: $FF),    //*  2 - White */
    (r: $3a; g: $3a; b: $d7),    //*  3 - Blue */
    (r: $75; g: $75; b: $75),    //*  4 - Med. Gray */
    (r: $c4; g: $c4; b: $c4),    //*  5 - Lt. Gray */
    (r: $d7; g: $b0; b: $75),    //*  6 - Peach */
    (r: $eb; g: $62; b: $9c),    //*  7 - Pink */
    (r: $13; g: $75; b: $27),    //*  8 - Dk. Green */
    (r: $75; g: $3a; b: $00),    //*  9 - Brown */
    (r: $ff; g: $d7; b: $13),    //* 10 - Yellow */
    (r: $3a; g: $3a; b: $3a),    //* 11 - Dk. Gray */
    (r: $c4; g: $13; b: $27),    //* 12 - Red */
    (r: $27; g: $b0; b: $3a),    //* 13 - Lt. Green */
    (r: $3a; g: $75; b: $ff),    //* 14 - Lt. Blue */
    (r: $d7; g: $75; b: $27)     //* 15 - Orange */
  );

{$IF DEFINED(AROS) and (FPC_FULLVERSION < 030101)}
function ReadArgs(const Template: STRPTR; Array_: PIPTR; RdArgs: PRDArgs): PRDArgs; syscall AOS_DOSBase 133;
{$ENDIF}


procedure VerBose(S: String);
begin
  if (Opt_Verbose) then WriteLn(S);
end;


procedure Verbose(S: String; const Args: array of const);
begin
  Verbose(SysUtils.Format(S, Args));
end;


function ReadStateStr(State: TReadStructState): String;
var
  retVal : String;
begin
  retVal := '';
  if RSS_OLDDRAWERDATA_READ in State then retVal := retVal + ',RSS_OLDDRAWERDATA_READ';
  if RSS_GADGETIMAGE_READ   in State then retVal := retVal + ',RSS_GADGETIMAGE_READ';
  if RSS_SELECTIMAGE_READ   in State then retVal := retVal + ',RSS_SELECTIMAGE_READ';
  if RSS_DEFAULTTOOL_READ   in State then retVal := retVal + ',RSS_DEFAULTTOOL_READ';
  if RSS_TOOLWINDOW_READ    in State then retVal := retVal + ',RSS_TOOLWINDOW_READ';
  if RSS_TOOLTYPES_READ     in State then retVal := retVal + ',RSS_TOOLTYPES_READ';
  if (Length(retVal) > 1) then Delete(retVal, 1, 1);
  Result := '[' + retVal + ']';
end;


procedure DumpNativeIcon(nico: PNativeIcon);
type
  PID  = ^TID;
  TID  = array[0..3] of char;
var
  Indent : String = '';
  St     : PPChar;
  i      : Integer;

  Function LineUp(S: String): String;
  begin
    Result := AddCharR(' ', S, 35);
  end;

  procedure DumpStruct(S: String);
  begin
    WriteLn(LineUp(Indent+S), '->');
    Indent := Indent + '.';
  end;

  procedure DumpPop;
  begin
    Delete(Indent, 1, 1);
  end;

  procedure DumpSField(S: String; Value: Pointer); overload;
  begin
    WriteLn(LineUp(Indent+S), '= $', HexStr(Value));
  end;

  procedure DumpSField(S: String; Value: Byte); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;

  procedure DumpSField(S: String; Value: Word); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;

  procedure DumpSField(S: String; Value: LongWord); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;

  procedure DumpSField(S: String; Value: ShortInt); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;

  procedure DumpSField(S: String; Value: SmallInt); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;

  procedure DumpSField(S: String; Value: LongInt); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;

  procedure DumpSField(S: String; Value: String); overload;
  begin
    WriteLn(LineUp(Indent+S), '= ', Value);
  end;


begin
  DumpStruct('NativeIcon');
  with nico^ do begin 
  DumpStruct('ni_DiskObject');
  with ni_DiskObject do begin
  DumpSField('do_Magic'         , do_Magic);
  DumpSField('do_Version'       , do_Version);
  DumpStruct('do_Gadget');
  with do_Gadget do begin
  DumpSField('NextGadget'       , NextGadget);
  DumpSField('LeftEdge'         , LeftEdge);
  DumpSField('TopEdge'          , TopEdge);
  DumpSField('Width'            , Width);
  DumpSField('Height'           , Height);
  DumpSField('Flags'            , Flags);
  DumpSField('ActiVation'       , Activation);
  DumpSField('GadgetType'       , GadgetType);
  DumpSField('GadgetRender'     , GadgetRender);
  DumpSField('SelectRender'     , SelectRender);
  DumpSField('GadgetText'       , GadgetText);
  DumpSField('MutualExclude'    , MutualExclude);
  DumpSField('SpecialInfo'      , SpecialInfo);
  DumpSField('GadgetID'         , GadgetID);
  DumpSField('UserData'         , UserData);
  DumpPop;
  end;
  DumpSField('do_Type'          , do_Type);
  DumpSField('do_DefaultTool'   , String(do_DefaultTool));
  DumpSField('do_ToolTypes'     , do_ToolTypes);
  St := do_ToolTypes;
  if Assigned(st) then
  begin
    i := 0;
    while Assigned(St[i]) do 
    begin
      DumpSField(SysUtils.Format('do_ToolTypes[%2d]',[i]), StrPas(St[i]));
      inc(i);
    end;
  end;
  DumpSField('do_CurrentX'      , do_CurrentX);
  DumpSField('do_CurrentY'      , do_CurrentY);
  DumpSField('do_DrawerData'    , do_DrawerData);
  DumpSField('do_ToolWindow'    , String(do_ToolWindow));   // only applies to tools
  DumpSField('do_StackSize'     , do_StackSize);    // only applies to tools
  DumpPop;
  end;
  DumpSField('ni_FreeList'      , '...');
  DumpSField('ni_ReadStruct_State', ReadStateStr(TReadStructState(nico^.ni_ReadStruct_State)));
  DumpStruct('ni_Extra');
  with ni_Extra do begin
  if Assigned(Data) then 
  DumpSField('Data'             , '$' + HexStr(Data) + '  ' + '(' + 'ID = ' + PID(nico^.ni_Extra.Data)^ + ')') else
  DumpSField('Data'             , Data);
  DumpSField('Size'             , Size);
  DumpSField('PNG[0].Offset'    , PNG[0].Offset);
  DumpSField('PNG[0].Size'      , PNG[0].Size);
  DumpSField('PNG[1].Offset'    , PNG[1].Offset);
  DumpSField('PNG[1].Size'      , PNG[1].Size);
  DumpPop;
  end;
  DumpSField('ni_IsDefault'     , ni_IsDefault);
  DumpSField('ni_Frameless'     , ni_Frameless);
  DumpSField('ni_ScaleBox'      , ni_ScaleBox);
  DumpSField('ni_Screen'        , ni_Screen);
  DumpSField('ni_Width'         , ni_Width);
  DumpSField('ni_Height'        , ni_Height);

  for i := Low(ni_Pens) to High(ni_Pens) 
    do DumpSField(SysUtils.Format('ni_Pens[%2d]',[i]), ni_Pens[i]);

  DumpSField('ni_Face.Aspect'   , ni_Face.Aspect);
  DumpSField('ni_Face.Width'    , ni_Face.Width);
  DumpSField('ni_Face.Height'   , ni_Face.Height);

  for i := Low(ni_Image) to High(ni_Image) do
  begin
    DumpSField(SysUtils.Format('ni_image[%d].TransparentColor'   ,[i]), ni_Image[i].TransparentColor);
    DumpSField(SysUtils.Format('ni_image[%d].Pens'               ,[i]), ni_Image[i].Pens);
    DumpSField(SysUtils.Format('ni_image[%d].Palette'            ,[i]), ni_Image[i].Palette);
    DumpSField(SysUtils.Format('ni_image[%d].ImageData'          ,[i]), ni_Image[i].ImageData);
    DumpSField(SysUtils.Format('ni_image[%d].ARGB'               ,[i]), ni_Image[i].ARGB);
    DumpSField(SysUtils.Format('ni_image[%d].Pen'                ,[i]), ni_Image[i].Pen);
    DumpSField(SysUtils.Format('ni_image[%d].BitMap'             ,[i]), ni_Image[i].BitMap);
    DumpSField(SysUtils.Format('ni_image[%d].BitMask'            ,[i]), ni_Image[i].BitMask);
    DumpSField(SysUtils.Format('ni_image[%d].ARGBMap'            ,[i]), ni_Image[i].ARGBMap);
    DumpSField(SysUtils.Format('ni_image[%d].Render.LeftEdge'    ,[i]), ni_Image[i].Render.LeftEdge);
    DumpSField(SysUtils.Format('ni_image[%d].Render.TopEdge'     ,[i]), ni_Image[i].Render.TopEdge);
    DumpSField(SysUtils.Format('ni_image[%d].Render.Width'       ,[i]), ni_Image[i].Render.Width);
    DumpSField(SysUtils.Format('ni_image[%d].Render.Height'      ,[i]), ni_Image[i].Render.Height);
    DumpSField(SysUtils.Format('ni_image[%d].Render.Depth'       ,[i]), ni_Image[i].Render.Depth);
    DumpSField(SysUtils.Format('ni_image[%d].Render.ImageData'   ,[i]), ni_Image[i].Render.ImageData);
    DumpSField(SysUtils.Format('ni_image[%d].Render.PlanePick'   ,[i]), ni_Image[i].Render.PlanePick);
    DumpSField(SysUtils.Format('ni_image[%d].Render.PlaneOnOff'  ,[i]), ni_Image[i].Render.PlaneOnOff);
    DumpSField(SysUtils.Format('ni_image[%d].Render.NextImage'   ,[i]), ni_Image[i].Render.NextImage);
  end;

  DumpPop;
  end;
end;


type
  TBitArray = array[0..31] of boolean;

function FPColor2BitArray(Color: TFPColor): TBitArray;
var
  RGBAPixel : TARGBQUAD;  
  i         : integer;  
begin
  RGBAPixel.r := Color.red   div $101;
  RGBAPixel.g := Color.green div $101;
  RGBAPixel.b := Color.Blue  div $101;
  RGBAPixel.a := 0;
  // bitarray is:
  //  r0,r1,r2,r3,r4,r5,r6,r7
  //  g0,g1,g2,g3,g4,g5,g6,g7
  //  b0,b1,b2,b3,b4,b5,b6,b7
  //  a0,a1,a2,a3,a4,a5,a6,a7
  for i := 0 to 7 do
  begin
    Result[(0 * 8) + i] := ((RGBAPixel.r and (1 shl i)) <> 0);
    Result[(1 * 8) + i] := ((RGBAPixel.g and (1 shl i)) <> 0);
    Result[(2 * 8) + i] := ((RGBAPixel.b and (1 shl i)) <> 0);
    Result[(3 * 8) + i] := ((RGBAPixel.a and (1 shl i)) <> 0);
  end;  
end;


procedure SaveFPImage2PNG(Filename: String; FPImage: TFPCustomImage; BitDepth: Byte = 32);
var 
  FPWriter  : TFPCustomImageWriter;
  x,y       : LongInt;
  Color     : TFPColor;
begin
  FPWriter := TFPWriterPNG.Create;  
  with (FPWriter as TFPWriterPNG) do
  begin
    indexed := false;
    UseAlpha := (BitDepth = 32);
    wordsized := false;    
    GrayScale := false;
  end;

  // in case bitdepth = 32 then we require alpha.
  // We have not set alpha by default, so we use a quick 'n' dirty hack here
  for y := 0 to Pred(FPImage.Height) do
  begin
    for x := 0 to Pred(FPImage.Width) do
    begin
      Color := FPImage.Colors[x,y];
      if ( (Color.Red <> 0) or (Color.Green <> 0) or (Color.Blue <> 0) ) then 
      begin
        Color.Alpha := $FFFF;
        FPImage.Colors[x,y] := Color;
      end;
    end;
  end;

  FPImage.SaveToFile(filename, FPWriter);
  
  FPWriter.Free;
end;


procedure SaveFPImage2IFFILBM(Filename: String; FPImage: TFPCustomImage; BitDepth: Byte = 32);
var
  FS        : TFileStream;
  x,y,z,j   : LongInt;
  Width, 
  Height    : LongInt;
  Depth     : Byte;
  ChunkLen  : LongInt;
  FPColor   : TFPColor;
  BitArray  : TBitArray;
  ThisByte  : Byte;
  alw       : LongInt;                  // aligned width
begin
  FS := TFileStream.Create(filename, fmCreate);
  FS.Position := 0;
  
  Width  := FPImage.Width;
  Height := FPImage.Height;
  Depth  := BitDepth;

  // FORM
  ChunkLen := 12345678;
  FS.WriteBuffer('FORM', 4);
  FS.WriteDWord(NtoBE(ChunkLen));       // chunk lenght

  // ILBM chunk
  FS.WriteBuffer('ILBM', 4);

  // Bitmap header
  FS.WriteBuffer('BMHD', 4);
  FS.WriteDWord(NtoBE(LongWord(20)));   // length of BitmapHeader

  FS.WriteWord(NtoBE(Word(Width)));     // Image Width in pixels
  FS.WriteWord(NtoBE(Word(Height)));    // Image Height in pixels
  FS.WriteWord(NtoBE(0));               // XOrigin
  FS.WriteWord(NtoBE(0));               // YOrigin
  FS.WriteByte(Byte(Depth));            // numplanes
  FS.WriteByte(NtoBE(0));               // Mask
  FS.WriteByte(NtoBE(0));               // Compression 0=unompressed, 1= RLE compressed
  FS.WriteByte(NtoBE(0));               // Formerly pad byte. CMAP flags
  FS.WriteWord(NtoBE(0));               // Tranparant colour. Only usefull when mask >= 2
  FS.WriteByte(1);                      // XAspect
  FS.WriteByte(1);                      // YAspect
  FS.WriteWord(NtoBE(Word(Width)));     // PageWidth, size of the screen the image is to be displayed on, in pixels, usually 320×200
  FS.WriteWord(NtoBE(Word(Height)));    // PageHeight, size of the screen the image is to be displayed on, in pixels, usually 320×200
   

  // Body
  alw := (Width + 15) and not(15);      // Aligned Width
  WriteLn('Aligned width = ', alw);
  ChunkLen := alw * Height * Depth div 8;

  FS.WriteBuffer('BODY', 4);
  FS.WriteDWord(NtoBE(ChunkLen));       // length of Body

  j := 0;

  for y := 0 to Pred(FPImage.Height) do
  begin
    for z := 0 to Pred(Depth) do
    begin
      ThisByte := 0;

      for x := 0 to Pred(FPImage.Width) do
      begin
        FPColor := FPImage.Colors[x,y];
        BitArray := FPColor2BitArray(FPColor);

        if BitArray[z]
        then ThisByte := ThisByte or 1
        else ThisByte := ThisByte or 0;

        if (Succ(x) mod 8 = 0) then
        begin
          FS.WriteByte(ThisByte);
          ThisByte := 0;
          inc(j);
        end
        else ThisByte := ThisByte shl 1;
      end;

      // if width was not multiple of a byte, then we still need to write the last byte
      if (FPImage.Width mod 8) <> 0 then
      begin
        FS.WriteByte(ThisByte);
        inc(j);
      end;
    end;
  end;

  // Write FORM chunk length
  ChunkLen := FS.Size - 4 - 4;
  FS.Position := 4;
  FS.WriteDWord(NtoBE(ChunkLen));  // chunk lenght

  FS.Position := pred(FS.Size);

  // write more chunks here, if wanted
  if odd(chunklen) then FS.WriteByte(0);

  Verbose('Written %d bytes into body, should be %d', [j, alw * Height * Depth div 8]);

  FS.Free;
end;


function RenderImageToFPImage(RenderImage: PImage; var FPImage: TFPCustomImage): boolean;
var
  PlanarData : PByte;
  x,y,z      : Longint;
  mask       : LongInt;
  Offset     : LongInt;
  colindex   : Integer;
  color      : TFPColor;
  bpp        : LongInt;     // Bytes Per Plane
  bpr        : LongInt;     // Bytyes Per Row
  alw        : LongInt;     // aligned width
  colpal     : packed array of TRGBTriple;
begin
  Result := False;

  // Check for supported bitmap depths.
  if not RenderImage^.Depth in [2,3,4] then
  begin
    WriteLn('Error: Unsupported image depth: ', RenderImage^.Depth);
    exit;
  end;

  case RenderImage^.Depth of
    2 : colpal := STD_04_colpal;    // standard 4 colors
    3 : colpal := MWB_08_colpal;    // magicwb 8 colors
    4 : colpal := SOS_16_colpal;    // scalos 16 colors
  end;  

  FPImage  := TFPMemoryImage.Create(RenderImage^.Width, RenderImage^.Height);
  FPImage.UsePalette := false;

  PlanarData := Pointer(Renderimage^.ImageData);
  alw := (RenderImage^.Width + 15) and not(15);     // Aligned Width
  bpr := alw div 8;                                 // Bytes Per Row
  bpp := bpr * RenderImage^.Height;                 // Bytes Per Plane

  for y := 0 to Pred(FPImage.Height) do
  begin
    for x := 0 to Pred(FPImage.Width) do
    begin
      mask      := $80 shr (x and 7);
      offset    := x div 8;
      colindex := 0;
      for z := 0 to Pred(RenderImage^.Depth) do
      begin
        if (PlanarData[(z * bpp) + (y * bpr) + offset] and mask <> 0) 
        then colindex := colindex or (1 shl z);
      end;
      color.Red   := colpal[colindex].r * $101;
      color.Green := colpal[colindex].g * $101;
      color.Blue  := colpal[colindex].b * $101;
      color.Alpha := $0;
      FPImage.Colors[x,y] := color;
    end;
  end;
  Result := true;
end;


function RenderPixelsToFPImage(RenderInfo: TPixelRenderInfo; var FPImage: TFPCustomImage): boolean;
var 
  x, y      : LongInt;
  FPColor   : TFPColor;
  RGBAPixel : TARGBQUAD;
begin
  Result := False;

  FPImage  := TFPMemoryImage.Create(RenderInfo.Width, RenderInfo.Height);
  FPImage.UsePalette := false;
  
  for y := 0 to Pred(FPImage.Height) do
  begin
    for x := 0 to Pred(FPImage.Width) do
    begin
      RGBAPixel := RenderInfo.RenderPixels[(y * FPImage.Width) + x];
      FPColor.Red   := Word(RGBAPixel.r * $101);
      FPColor.Green := Word(RGBAPixel.g * $101);
      FPColor.Blue  := Word(RGBAPixel.b * $101);
      FPColor.Alpha := Word(RGBAPixel.a * $101);
      FPImage.colors[x,y] := FPColor;
    end;
  end;

  Result := True;
end;


procedure SaveIcon2Png(Filename: String; nico: PNativeIcon; ImageStorage: TNativeImageStorage);
var
  FPImage     : TFPCustomImage;
  RenderImage : PImage;
  RenderInfo  : TPixelRenderInfo;
  BitDepth    : LongInt;
begin
  if Opt_NoAlpha then BitDepth := 24 else BitDepth := 32;

  if ImageStorage = nisGadget then
  begin
    if Opt_Alternate 
    then RenderImage := nico^.ni_DiskObject.do_gadget.GadgetRender
    else RenderImage := nico^.ni_DiskObject.do_gadget.SelectRender;

    if Assigned(RenderImage) then
    begin
      try
        if RenderImageToFPImage(RenderImage, FPImage) 
        then SaveFPImage2Png(Filename, FPImage, BitDepth)
        else WriteLn('Error: Unable to render image');
      finally
        FPImage.Free;
      end;
    end
    else WriteLn('Error: Image to render does not exist in memory');
  end

  else

  if ImageStorage = nisARGB then
  begin
    if Opt_Alternate 
    then RenderInfo.RenderPixels := Pointer(nico^.ni_Image[1].ARGB)
    else RenderInfo.RenderPixels := Pointer(nico^.ni_Image[0].ARGB);

    if Assigned(RenderInfo.RenderPixels) then
    begin
      RenderInfo.Width  := nico^.ni_Width;
      RenderInfo.Height := nico^.ni_Height;
      try
        if RenderPixelsToFPImage(RenderInfo, FPImage) 
        then SaveFPImage2Png(Filename, FPImage, BitDepth)
        else WriteLn('Error: Unable to render image pixels');
      finally
        FPImage.Free;
      end;
    end
    else WriteLn('Failure: no ARGB data available');
  end
  else WriteLn('Error: Unsupported storage format');
end;


procedure SaveIcon2Iff(Filename: String; nico: PNativeIcon; ImageStorage: TNativeImageStorage);
var
  FPImage     : TFPCustomImage;
  RenderImage : PImage;
  RenderInfo  : TPixelRenderInfo;
  BitDepth    : LongInt;
begin
  if Opt_NoAlpha then BitDepth := 24 else BitDepth := 32;

  if ImageStorage = nisGadget then
  begin
    if Opt_Alternate 
    then RenderImage := nico^.ni_DiskObject.do_gadget.GadgetRender
    else RenderImage := nico^.ni_DiskObject.do_gadget.SelectRender;

    if Assigned(RenderImage) then
    begin
      try
        if RenderImageToFPImage(RenderImage, FPImage) 
        then SaveFPImage2IFFILBM(Filename, FPImage, BitDepth)
        else WriteLn('Error: Unable to render image');
      finally
        FPImage.Free;
      end;
    end
    else WriteLn('Error: Image to render does not exist in memory');
  end

  else

  if ImageStorage = nisARGB then
  begin
    if Opt_Alternate 
    then RenderInfo.RenderPixels := Pointer(nico^.ni_Image[1].ARGB)
    else RenderInfo.RenderPixels := Pointer(nico^.ni_Image[0].ARGB);

    if Assigned(RenderInfo.RenderPixels) then
    begin
      RenderInfo.Width  := nico^.ni_Width;
      RenderInfo.Height := nico^.ni_Height;
      try
        if RenderPixelsToFPImage(RenderInfo, FPImage) 
        then SaveFPImage2IFFILBM(Filename, FPImage, BitDepth)
        else WriteLn('Error: Unable to render image pixels');
      finally
        FPImage.Free;
      end;
    end
    else WriteLn('Failure: no ARGB data available');
  end
  else WriteLn('Error: Unsupported storage format');
end;


procedure SaveIcon(Filename: String; nico: PNativeIcon; ImageStorage: TNativeImageStorage);
begin
  case opt_Format of
    'IFF' : SaveIcon2Iff(Filename, nico, ImageStorage);
    'PNG' : SaveIcon2Png(Filename, nico, ImageStorage);
    else    WriteLn('Error: Unsupported output format "', opt_Format, '"');
  end;
end;


procedure ProcessSomeFile(SourceFN, DestFN: String; Selected: Boolean);
type
  PID  = ^TID;
  TID  = array[0..3] of char;
var
  dobi : PDiskObject;
  nico : PNativeIcon;
  RSS  : TReadStructState;
begin
  Verbose('Source Filename      = %s.info', [SourceFN]);
  Verbose('Destination Filename = %s'     , [DestFN]);
  Verbose('Output format        = %s'     , [Opt_Format]);
  Verbose('Selected/Alternate   = %s'     , [BoolToStr(Selected   , 'true', 'false')]);
  Verbose('NoAlpha              = %s'     , [BoolToStr(Opt_NoAlpha, 'true', 'false')]);

  dobi := GetDiskObjectNew(PChar(SourceFN));

  nico := NATIVEICON(dobi);
  if Assigned(nico) then
  begin
    try
      if Opt_Dump then
      begin
        WriteLn('--------------- dump ---------------');
        DumpNativeIcon(nico);
        WriteLn('/-------------- dump --------------/');
      end;
      RSS := TReadStructState(nico^.ni_ReadStruct_State);
      VerBose('RSS = %s', [ReadStateStr(RSS)]);

      //
      // Old 1.x/2.x Icon Format
      //
      if RSS_OLDDRAWERDATA_READ in RSS then
      begin
        Verbose('Detected OS 1.x/2.x icon format');
        // if GFLG_GADGIMAGE flag is present then GadgetRender 
        // field is TImage else it's a TBorder
        if (nico^.ni_DiskObject.do_Gadget.Flags and GFLG_GADGIMAGE <> 0) 
        then SaveIcon(DestFN, nico, nisgadget)
        else WriteLn('Error: Gadget does not contain an image. Unable to create output');
      end
      //
      // New icon format
      //
      else
      begin
        //
        // OS 3.5 icon format (iff icon)
        //
        if nico^.ni_DiskObject.do_Version = 1 then
        begin
          Verbose('Detected OS 3.5 icon format');

          // use argb method, for now
          SaveIcon(DestFN, nico, nisARGB);
        end
        else

        //
        // PowerIcon (png icon format)
        //
        if nico^.ni_DiskObject.do_Version = 257 then
        begin
          Verbose('Detected PowerIcon format');

          SaveIcon(DestFN, nico, nisARGB);
        end
        else WriteLn('Error: unrecognized icon format');
      end;
    finally
      FreeDiskObject(dobi);
    end;
  end
  else WriteLn('Error: Unable to load file "', SourceFN, '.info', '"');
end;


function GetArguments: Boolean;
var
  MyArgs    : PRDArgs;
  Args      : Array[0..Pred(NUM_ARGS)] of LongWord;
  i         : integer;
begin
  Result := False;
  for i := Low(Args) To High(Args) do Args[i] := 0;

  myargs := ReadArgs(ARG_TEMPLATE, @args[0], nil);
  if ( myargs <> nil ) then
  begin
    Opt_SourceFilename := StrPas(STRPTR(args[ARG_SOURCE]));
    Opt_DestFileName   := StrPas(STRPTR(args[ARG_DEST]));
    Opt_NoAlpha        := LONGBOOL(args[ARG_NOALPHA]);
    Opt_Alternate      := LONGBOOL(args[ARG_ALT]);
    Opt_Format         := StrPas(STRPTR(args[ARG_FORMAT]));
    Opt_Dump           := LONGBOOL(args[ARG_DUMP]);
    Opt_Verbose        := LONGBOOL(args[ARG_VERBOSE]);


    i := AnsiIndexText(Opt_Format, OutputFileTypes);
    if i = -1 
    then Opt_Format := 'IFF'        // default to IFF output
    else Opt_Format := OutputFileTypes[i];

    FreeArgs(myargs);
    Result := true;
  end
  else WriteLn('Error: Arguments do not match template');
end;


begin
  if GetArguments then
  begin
    Verbose('Processing file');
    ProcessSomeFile(Opt_SourceFilename, Opt_DestFileName, Opt_Alternate);
  end;
end.
