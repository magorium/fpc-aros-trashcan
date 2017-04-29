program chunky;

{$MODE OBJFPC}{$H+}{$HINTS ON}

Uses
  libamivideo, CHelpers;

const
  WIDTH             = 32;
  HEIGHT            = 20;
  BITPLANE_DEPTH    =  4;

Var
  pixels            : array[0..Pred(WIDTH * HEIGHT)] of TamiVideo_UByte =
  (
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $0, $0, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $0, $0, $0, $0, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $0, $0, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0,
    $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
    $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $4, $4, $4, $4, $4, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $6, $6, $6, $6, $6, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $8, $8, $8, $8, $8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $a, $a, $a, $a, $a, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $b, $b, $b, $b, $b, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $c, $c, $c, $c, $c, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $d, $d, $d, $d, $d, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5,
    $5, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $f, $f, $f, $f, $f, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $5
  );


function main(argc: integer; argv: PPChar): integer;
var
  newPixels : PamiVideo_UByte;
  bitplanes : PamiVideo_UByte;
  screen    : TamiVideo_Screen;
  status    : Integer;
begin
  newPixels := PamiVideo_UByte(AllocMem(WIDTH * HEIGHT * sizeof(TamiVideo_UByte)));
  bitplanes := PamiVideo_UByte(AllocMem(WIDTH * HEIGHT * sizeof(TamiVideo_UByte)));

  memcpy(newPixels, @pixels, WIDTH * HEIGHT * sizeof(TamiVideo_UByte));
    
  amiVideo_initScreen(@screen, WIDTH, HEIGHT, BITPLANE_DEPTH, 8, 0);
  amiVideo_setScreenUncorrectedChunkyPixelsPointer(@screen, newPixels, WIDTH);
  amiVideo_setScreenBitplanes(@screen, bitplanes);
    
  amiVideo_convertScreenChunkyPixelsToBitplanes(@screen);
  amiVideo_convertScreenBitplanesToChunkyPixels(@screen);
    
  if ( memcmp(@pixels, newPixels, WIDTH * HEIGHT) = 0 )
  then status := 0
  else
  begin
    WriteLn(StdErr, 'The pixel areas are not identical!');
    status := 1;
  end;
    
  FreeMem(bitplanes);
  amiVideo_cleanupScreen(@screen);
    
  Result := status;
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
