unit icon_native;

{$MODE OBJFPC}{$H+}

interface

uses
  Exec, {DataTypes,} AGraphics, Intuition, WorkBench;


type
  // from exec
  PUBYTE = ^UBYTE;

type
  // from datatypes
  PColorRegister = ^TColorRegister;
  TColorRegister = packed
  record
    red, green, blue : Byte;
  end;  


type
  TNativeIconFace = record
    Aspect  : UBYTE;    //* Source aspect ratio */
    Width   : ULONG;
    Height  : ULONG;
  end;


  TNativeIconImage = record
    {* This data was either allocated during icon load
     * (and is in the ni_FreeList), or was provided by
     * the user via IconControlA().
     *}
    TransparentColor    : LONG;
    Pens                : ULONG;            //* Pens allocated for the layout */
    Palette             : PColorRegister;   //*  one entry per pen */
    ImageData           : PUBYTE;           //* 'ChunkyPixels' image */
    ARGB                : PULONG;           //* RGB+Alpha (A 0=transparent) */

    {* Dynamically allocated by LayoutIconA(), and are
     * _not_ in the ni_FreeList.
     *
     * You must call LayoutIconA(icon, NULL, NULL) or
     * FreeDiskObject() to free this memory.
     *}
    Pen                 : PULONG;           //* Palette n to Pen m mapping */
    BitMap              : PBitMap;          //* 'friend' of the Screen */
    BitMask             : TPLANEPTR;        //* TransparentColor >= 0 bitmask */
    ARGBMap             : APTR;             //* ARGB, rescaled version */

    {* For m68k legacy support, the struct Image render
     * is stored here.
     *}
    Render              : TImage;
  end;


  PNativeIcon = ^TNativeIcon;
  TNativeIcon = record
    ni_node             : TMinNode;
    ni_DiskObject       : TDiskObject;
    ni_FreeList         : TFreeList;
    ni_ReadStruct_State : ULONG;
    
    //* Source icon data */
    ni_Extra            : 
    record
      Data              : APTR;     //* Raw IFF or PNG stream */
      Size              : ULONG;
      PNG               : array[0..1] of
      record
        Offset          : LONG;
        Size            : LONG;
      end;
    end;

    //* Parameters */
    ni_IsDefault        : BOOL;
    ni_Frameless        : BOOL;
    ni_ScaleBox         : ULONG;

    {* The 'laid out' icon. The laid out data will
     * also be resized for the screen's aspect ratio,
     * so the nil_Width and nil_Height will probably
     * be different than the original image on some
     * screens.
     *}
    ni_Screen           : PScreen;  //* Screen for the layout */
    ni_Width            : ULONG;    //* Dimension of the aspect */
    ni_Height           : ULONG;    //* ratio corrected icon */

    //* Pens for drawing the border and frame */
    ni_Pens             : array[0..Pred(NUMDRIPENS)] of UWORD; //* Copied from DrawInfo for the screen */

    ni_Face             : TNativeIconFace;
    ni_Image            : array[0..1] of TNativeIconImage;
  end;


  function NATIVEICON(icon: PDiskObject) : PNativeIcon; 
  

implementation


function NATIVEICON(icon: PDiskObject) : PNativeIcon; 
begin
  NATIVEICON := Pointer(icon) - ( PtrUInt(@(TNativeIcon(nil^).ni_DiskObject))) ;
end;


end.
