program testSDL_Image;

{$MODE OBJFPC}{$H+}

uses
  {$IFDEF AROS}
  arosc_static_link,
  {$ENDIF}
  SDL, SDL_Image, Strings;

const
  picturepath       : PChar = 'fpsdl.';
var
  screen            : PSDL_Surface;
  picture           : array[0..2] of PSDL_Surface;
  fileextension     : array[0..2] of PChar;
  filepath          : array[0..2] of PChar;
  i                 : Byte;


function keypressed: boolean;
var
 event : TSDL_Event;
begin
  result := false;
  if (SDL_PollEvent(@event) <> 0) then
  begin
    if ( event.type_ = SDL_KEYDOWN) then result := true;
  end;
end;


procedure test;
begin 
  if ( SDL_Init(SDL_INIT_VIDEO) < 0 ) then
  begin
    WriteLn('ERROR: SDL_Init() failed: ', SDL_GetError);
    exit;
  end;

  screen := SDL_SetVideoMode(200, 200, 32, SDL_SWSURFACE);
  if (screen = nil) then 
  begin
    WriteLn('ERROR: SDL_SetVideoMode() failed: ', SDL_GetError);
    SDL_Quit;
    exit;
  end;
 
  fileextension[0] := 'png';
  fileextension[1] := 'jpg';
  fileextension[2] := 'tif';  // AROS libSDL_Image does nto support tiff files
 
  for i := 0 to 2 do
  begin
    filepath[i] := StrNew(picturepath);
    filepath[i] := StrCat(filepath[i], fileextension[i]);

    picture[i] := IMG_Load(filepath[i]);
    if (picture[i] = nil) then
    begin
      WriteLn('ERROR: IMG_Load() failed: ', SDL_GetError);
      WriteLn('uncontrolled exit');
      SDL_FreeSurface(screen);
      SDL_Quit;
      exit;
    end;
 
    SDL_BlitSurface(picture[i], nil, screen, nil);
    SDL_Flip(screen);
    Write('Press enter for next');
    ReadLn;
  end;
  
  for i := 0 to 2 do
  begin
    SDL_FreeSurface(picture[i]);
    StrDispose(filepath[i]);
  end;  

  SDL_FreeSurface(screen);
 
  SDL_Quit;
end;


begin
  {$IFDEF AROS}
  AROSC_Init(@test);
  {$ELSE}
  test;
  {$ENDIF}
end.
