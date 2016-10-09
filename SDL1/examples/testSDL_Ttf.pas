program testSDL_Ttf;

{$MODE OBJFPC}{$H+}

uses
  {$IFDEF AROS}
  arosc_static_link,
  {$ENDIF}
  SDL, SDL_TTF;

var
  screen,
  fontface      : PSDL_Surface;
  loaded_font   : pointer;
  colour_font,
  colour_font2  : PSDL_Color;


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

  screen := SDL_SetVideoMode(400, 200, 32, SDL_SWSURFACE);
  if (screen = nil) then 
  begin
    WriteLn('ERROR: SDL_SetVideoMode() failed: ', SDL_GetError);
    SDL_Quit;
    exit;
  end;
 
  if (TTF_Init = -1) then
  begin
    WriteLn('ERROR: TTF_Init() failed: ', SDL_GetError);
    SDL_FreeSurface(screen);
    SDL_Quit;
    exit;
  end; 

//  {$IFDEF WINDOWS}loaded_font := TTF_OpenFont('arial.ttf');{$ENDIF}
//  {$IFDEF AROS}   loaded_font := TTF_OpenFont('veramono.ttf');{$ENDIF}
  loaded_font := TTF_OpenFont('arial.ttf', 40);  
  if (Loaded_font = nil) then
  begin
    WriteLn('ERROR: TTF_OpenFont() failed: ', SDL_GetError);
    TTF_Quit;
    SDL_FreeSurface(screen);
    SDL_Quit;
    exit;
  end;

  New(colour_font);
  New(colour_font2);
  colour_font^.r  := 255; colour_font^.g  :=   0; colour_font^.b  :=   0;
  colour_font2^.r :=   0; colour_font2^.g := 255; colour_font2^.b := 255;
 
  fontface:= TTF_RenderText_Shaded(loaded_font,'HELLO WORLD!', colour_font^, colour_font2^);
 
  SDL_BlitSurface(fontface, nil, screen, nil);
  SDL_Flip(screen);
  //  Repeat Until KeyPressed;
  ReadLn;

  Dispose(colour_font);
  Dispose(colour_font2);

  SDL_FreeSurface(screen);
  SDL_FreeSurface(fontface);

  TTF_CloseFOnt(loaded_font);

  TTF_Quit;
 
  SDL_Quit;
end;


begin
  {$IFDEF AROS}
  AROSC_Init(@test);
  {$ELSE}
  test;
  {$ENDIF}
end.

