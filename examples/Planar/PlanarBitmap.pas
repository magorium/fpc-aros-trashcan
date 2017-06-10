program PlanarBitmap;

{$MODE OBJFPC}{$H+}

{
  Topic     : Simple dumb planar bitmap blit example
  See also  : https://en.wikipedia.org/wiki/Planar_(computer_graphics)

  Bitplane data, declared in source, is manually copied into a (planar) bitmap 
  that was created using Graphics API. Once done, a window is opened and the 
  (planar) bitmap is being blitted to the current window.
}


uses
  Exec, AGraphics, Intuition;

const
  PlanarWidthInPixels            = 32;
  PlanarHeightInPixels           = 16;
  PlanarWidthInBytes             = PlanarWidthInPixels shr 3;  // 32 pixels / 8 pixels per byte
  TotalNumberOfBytesPerPlane     = PlanarWidthInBytes * PlanarHeightInPixels;
  NumberOfPlanes                 = 4;

  Plane3 : array[0..Pred(TotalNumberOfBytesPerPlane)] of Byte =
  (
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111
  );

  Plane2 : array[0..Pred(TotalNumberOfBytesPerPlane)] of Byte =
  (
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %00000000, %00000000, %00000000, %00000000,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111,
    %11111111, %11111111, %11111111, %11111111
  );
  
  Plane1 : array[0..Pred(TotalNumberOfBytesPerPlane)] of Byte =
  (  
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111,
    %00000000, %00000000, %11111111, %11111111
  );

  Plane0 : array[0..Pred(TotalNumberOfBytesPerPlane)] of Byte =
  (  
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111,
    %00000000, %11111111, %00000000, %11111111
  );

Var
  MyPlanarBitmap : PBitMap;
  Window         : PWindow;


function  SetAndTest(Out OldValue: pointer; NewValue: pointer): boolean;
begin
  OldValue := NewValue;
  result := (NewValue <> nil)
end;


Function  CreateMyBitmap(out bm: PBitMap): Boolean;
begin
  // Allocate bitmap
  bm := AllocBitmap
  (
    PlanarWidthInPixels,
    PlanarHeightInPixels,
    NumberOfPlanes,
    BMF_CLEAR,
    nil
  );
  Result := Assigned(bm);
end;


Procedure CopyDataToMyBitmap(bm: PBitmap);
Var
  bpr           : Integer;
  rows          : Integer;
  ByteIndex     : Integer;
  RowIndex      : integer;
  PlaneIndex    : Integer;
  RawPlaneData  : PByte;
begin
  bpr  := bm^.BytesPerRow;
  rows := bm^.rows;

  // for every plane
  for PlaneIndex := 0 to NumberOfPlanes-1 do
  begin
    Case PlaneIndex of
      0 : RawPlaneData := @Plane0;
      1 : RawPlaneData := @Plane1;
      2 : RawPlaneData := @Plane2;
      3 : RawPlaneData := @Plane3;
    end;
    // for every row
    for RowIndex := 0 to rows-1 do
    begin
      // for every byte
      for ByteIndex := 0 to bpr-1 do
      begin
        // Copy byte from our constants into Bitmap using the (individual) 
        // Plane Pointers
        (bm^.Planes[PlaneIndex] + (RowIndex * bpr) + ByteIndex)^ := 
        (          RawPlaneData + (rowIndex * bpr) + ByteIndex)^;
      end;
    end;
  end;
end;


procedure Main;
Var
  Terminated : boolean;
  IMsg       : pIntuiMessage;
begin
  If CreateMyBitmap(MyPlanarBitmap) then
  begin
    CopyDataToMyBitmap(MyPlanarBitMap);

    // Open a intuition window
    window := OpenWindowTags( nil,
    [
        LongInt(WA_Left)    , 50,
        LongInt(WA_Top)     , 70,
        LongInt(WA_Width)   , 400,
        LongInt(WA_Height)  , 350,
        LongInt(WA_Title)   , (PChar('Planar bitmap')),
        LongInt(WA_Flags)   , 
        (
          WFLG_ACTIVATE      or WFLG_SMART_REFRESH or WFLG_NOCAREREFRESH or 
          WFLG_GIMMEZEROZERO or WFLG_CLOSEGADGET   or WFLG_DRAGBAR       or 
          WFLG_DEPTHGADGET
        ),
        LongInt(WA_IDCMP)   , (IDCMP_CLOSEWINDOW),
        TAG_END
    ]);

    if assigned(window) then
    begin
      // Blit planar bitmap to current screen 
      // Could just as well blit into an off-screen friendly bitmap's rastport
      BltBitMapRastPort
      (
        MyPlanarBitmap, 0, 0, 
        window^.RPort, 50, 50, PlanarWidthInPixels, PlanarHeightInPixels, $C0
      );

      Terminated := FALSE;
      repeat
        WaitPort(window^.UserPort);
        while SetAndTest(Imsg, GetMsg(window^.UserPort)) do
        begin
          case (IMsg^.IClass) of
            IDCMP_CLOSEWINDOW : terminated := true;
          end;

          ReplyMsg(PMessage(IMsg));
        end;
      until Terminated;

      CloseWindow (window);      
    end
    else Writeln('unable to open window');

    FreeBitMap(MyPlanarBitmap);
  end
  else WriteLn('Creation of MyPlanarBitmap failed');
end;


begin
  WriteLn('NOTE: set pens 0-15, otherwise some colours turn up "black"');

  Main;  
  WriteLn('Done');
end.
