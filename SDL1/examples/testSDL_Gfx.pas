program testSDL_Gfx;

{$MODE OBJFPC}{$H+}

uses
  {$IFDEF AROS}
  arosc_static_link,
  {$ENDIF}
  SDL, SDL_Gfx;

const
  x_array : array[0..5] of SINT16 = ( 50, 150, 250, 250, 150,  50);
  y_array : array[0..5] of SINT16 = (100,  50, 100, 200, 250, 200);


var
  screen,
  original_image,
  modified_image    : PSDL_Surface;
  angle_value, 
  zoom_value        : double;
  framerate         : PFPSManager;
  calc_width, 
  calc_height       : LongInt;


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

  screen := SDL_SetVideoMode(400, 400, 32, SDL_SWSURFACE);
  if (screen = nil) then 
  begin
    WriteLn('ERROR: SDL_SetVideoMode() failed: ', SDL_GetError);
    SDL_Quit;
    exit;
  end;

  original_image := SDL_LOADBMP('fpsdl.bmp');
  if (original_image = nil) then
  begin
    WriteLn('ERROR: SDL_LoadBmp() failed: ', SDL_GetError);
    SDL_FreeSurface(screen);
    SDL_Quit;
    exit;
  end;

  New(modified_image);
  angle_value := 0.0;
  zoom_value  := 0.0;
 
  New(framerate);
  SDL_InitFrameRate(framerate);
  SDL_SetFrameRate(framerate, 30);
 
  repeat
    angle_value := angle_value + 1.0;
    zoom_value  := zoom_value  + 0.05;
    if (angle_value >= 359) then angle_value := 0.0;
    if (zoom_value  >= 2.0) then zoom_value  := 0.0;
 
    RotoZoomSurfaceSize(400, 400, angle_value, zoom_value, calc_width, calc_height);
    WriteLn('Width: ', calc_width, ' Height: ', calc_height);
    modified_image := RotoZoomSurface(original_image, angle_value, zoom_value, 1);
 
    CircleColor(screen, 200, 200, 100, $FFFF00FF);
    FilledCircleColor(screen, 200, 200, 50, $00FF00FF);
    EllipseColor(screen, 200, 200, 175, 75, $00FFFFFF);
    FilledPieColor(screen, 200, 200, 110, 10, 100, $FF0000FF);
    PolygonCOlor(screen, @x_array[0], @y_array[0], 6, $000000FF);
    BezierColor(screen, @x_array[3], @y_array[3], 3, 2, $FFFFFFFF);
 
    SDL_BlitSurface(modified_image, nil, screen, nil);
    SDL_Flip(screen);
 
    SDL_FrameRateDelay(framerate);
  until keypressed;
 
  SDL_FreeSurface(original_image);
  SDL_FreeSurface(modified_image);
  SDL_FreeSurface(screen);
 
  Dispose(framerate);

  SDL_Quit;
end;


begin
  {$IFDEF AROS}
  AROSC_Init(@test);
  {$ELSE}
  test;
  {$ENDIF}
end.
