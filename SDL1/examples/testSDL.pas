program testSDL;

{$MODE OBJFPC}{$H+}

uses
  {$IFDEF AROS}
  arosc_static_link,
  {$ENDIF}
  SDL;

var
  screen,
  picture           : PSDL_Surface;
  source_rect,
  destination_rect  : PSDL_Rect;


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
 
  picture := SDL_LoadBMP('fpsdl.bmp');
  if (picture = nil) then 
  begin
    WriteLn('ERROR: SDL_LoadBMP() failed: ', SDL_GetError);
    SDL_FreeSurface(screen);
    SDL_Quit;
    exit;
  end;
 
  New(source_rect);
  source_rect^.x :=   0;
  source_rect^.y :=   0;
  source_rect^.w := 200;
  source_rect^.h := 200;

  New(destination_rect);
  destination_rect^.x :=   0;
  destination_rect^.y :=   0;
  destination_rect^.w := 200;
  destination_rect^.h := 200;
 
  repeat
    SDL_BlitSurface(picture, source_rect, screen, destination_rect);
    SDL_Flip(screen);

    dec(source_rect^.w);
    dec(source_rect^.h);
    inc(destination_rect^.x);
    inc(destination_rect^.y);
    dec(destination_rect^.w);
    dec(destination_rect^.h);
    SDL_Delay(30);

    if (source_rect^.w = 1) then
    begin
      source_rect^.x :=   0;
      source_rect^.y :=   0;
      source_rect^.w := 200;
      source_rect^.h := 200;
      destination_rect^.x :=   0;
      destination_rect^.y :=   0;
      destination_rect^.w := 200;
      destination_rect^.h := 200;
    end;
  until keypressed;
 
  SDL_FreeSurface(picture);
  SDL_FreeSurface(screen);
 
  Dispose(source_rect);
  Dispose(destination_rect);
 
  SDL_Quit;
end;


begin
  {$IFDEF AROS}
  AROSC_Init(@test);
  {$ELSE}
  test;
  {$ENDIF}
end.
