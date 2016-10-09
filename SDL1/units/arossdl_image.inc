
{ This macro can be used to fill a version structure with the compile-time
  version of the SDL_image library. }
procedure SDL_IMAGE_VERSION( var X : TSDL_Version );
{$EXTERNALSYM SDL_IMAGE_VERSION}

{ This function gets the version of the dynamically linked SDL_image library.
   it should NOT be used to fill a version structure, instead you should
   use the SDL_IMAGE_VERSION() macro.
 }
function IMG_Linked_Version : PSDL_version;
cdecl; external;
{$EXTERNALSYM IMG_Linked_Version}

{ Load an image from an SDL data source.
   The 'type' may be one of: "BMP", "GIF", "PNG", etc.

   If the image format supports a transparent pixel, SDL will set the
   colorkey for the surface.  You can enable RLE acceleration on the
   surface afterwards by calling:
        SDL_SetColorKey(image, SDL_RLEACCEL, image.format.colorkey);
}
function IMG_LoadTyped_RW(src: PSDL_RWops; freesrc: Integer; _type: PChar): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadTyped_RW}
{ Convenience functions }
function IMG_Load(const _file: PChar): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_Load}
function IMG_Load_RW(src: PSDL_RWops; freesrc: Integer): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_Load_RW}

{ Invert the alpha of a surface for use with OpenGL
  This function is now a no-op, and only provided for backwards compatibility. }
function IMG_InvertAlpha(_on: Integer): Integer;
cdecl; external;
{$EXTERNALSYM IMG_InvertAlpha}

{ Functions to detect a file type, given a seekable source }
function IMG_isBMP(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isBMP}

function IMG_isGIF(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isGIF}

function IMG_isJPG(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isJPG}

function IMG_isLBM(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isLBM}

function IMG_isPCX(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isPCX}

function IMG_isPNG(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isPNG}

function IMG_isPNM(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isPNM}

function IMG_isTIF(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isTIF}

function IMG_isXCF(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isXCF}

function IMG_isXPM(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isXPM}

function IMG_isXV(src: PSDL_RWops): Integer;
cdecl; external;
{$EXTERNALSYM IMG_isXV}


{ Individual loading functions }
function IMG_LoadBMP_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadBMP_RW}

function IMG_LoadGIF_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadGIF_RW}

function IMG_LoadJPG_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadJPG_RW}

function IMG_LoadLBM_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadLBM_RW}

function IMG_LoadPCX_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadPCX_RW}

function IMG_LoadPNM_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadPNM_RW}

function IMG_LoadPNG_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadPNG_RW}

function IMG_LoadTGA_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadTGA_RW}

function IMG_LoadTIF_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadTIF_RW}

function IMG_LoadXCF_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadXCF_RW}

function IMG_LoadXPM_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadXPM_RW}

function IMG_LoadXV_RW(src: PSDL_RWops): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_LoadXV_RW}

function IMG_ReadXPMFromArray( xpm : PPChar ): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM IMG_ReadXPMFromArray}
