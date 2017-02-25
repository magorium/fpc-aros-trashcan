unit gui;

{$MODE OBJFPC}{$H+}
{$RANGECHECKS ON}

interface

uses
  SDL, ctypes, chelpers;

const
  MAXRECTS  = 1024;
  FONT_CW   = 16;
  FONT_CH   = 16;

type
  TGUI_pages =
  (
    GUI_PAGE_MAIN,
    GUI_PAGE_LOG,
    GUI_PAGE_HELP1,
    GUI_PAGE_HELP2,
    GUI_PAGE_HELP3,
    GUI_PAGE_HELP4
  );

const
  GUI_PAGE__FIRST   = GUI_PAGE_MAIN;
  GUI_PAGE__CYCLE   = GUI_PAGE_LOG;

  {
  * Low level GUI stuff
  }

  //* Load and convert image */
  function  gui_load_image(const fn: PChar): PSDL_Surface;

  //* Add a dirtyrect */
  procedure gui_dirty(r: PSDL_Rect);

  //* Update all dirty areas */
  procedure gui_refresh;

  //* Draw a hollow box */
  procedure gui_box(x: cint; y: cint; w: cint; h: cint; c: Uint32; dst: PSDL_Surface);

  //* Draw a black box with a colored outline */
  procedure gui_bar(x: cint; y: cint; w: cint; h: cint; c: Uint32; dst: PSDL_Surface);

  //* Render text */
  procedure gui_text(x: cint; y: cint; txt: PChar; dst: PSDL_Surface);

  //* Render an oscilloscope */
  procedure gui_oscilloscope(buf: PSint32; bufsize: cint; start: cint; x: cint; y: cint; w: cint; h: cint; dst: PSDL_Surface);

  {
  * High level GUI stuff
  }
  function  gui_open(scrn: PSDL_Surface): boolean;
  procedure gui_close;

  procedure gui_tempo(v: cint);
  procedure gui_songpos(v: cint);
  procedure gui_songedit(pos: cint; ppos: cint; track: cint; editing: boolean);
  procedure gui_songselect(x1: cint; y1: cint; x2: cint; y2: cint);
  procedure gui_status(playing: boolean; editing: boolean; looping: boolean);
  procedure gui_message(const msg: PChar; curspos : cint);
  procedure gui_draw_activity(dt: cint);
  procedure gui_activity(trk: cint);

  procedure gui_draw_screen(page: TGUI_pages);


implementation

{
* gui.c - Tracker style GUI
*
* (C) David Olofson, 2006
}

uses
  sseq;


// FPC: quick'n'dirty function that prefixes a string with leading zero's
function LeadZero(value:integer; maxlen: integer=8; pad:char='0'): string;
begin
  Str(value, Result);
  LeadZero := StringOfChar(pad, maxlen - Length(Result) ) + Result;
end;


const
  MAXACTIVITY   = 400;

  dirtyrects    : cint = 0;

var
  dirtytab      : array[0..Pred(MAXRECTS)] of TSDL_Rect;

const
  screen        : PSDL_Surface = nil;
  font          : PSDL_Surface = nil;

  message_text  : PChar = nil;

var
  activity      : array [0..Pred(SSEQ_TRACKS)] of cint;


procedure gui_dirty(r: PSDL_Rect);
begin
  if (dirtyrects < 0) then exit;

  if ((dirtyrects >= MAXRECTS) or not assigned(r) )
  then dirtyrects := -1
  else
  begin
    dirtytab[dirtyrects] := r^;
    inc(dirtyrects);
  end;
end;


procedure gui_refresh;
begin
  if (dirtyrects < 0) then
  begin
    SDL_UpdateRect(screen, 0, 0, 0, 0);
    dirtyrects := 0;
  end
  else SDL_UpdateRects(screen, dirtyrects, dirtytab);
  dirtyrects := 0;
end;


procedure gui_box(x: cint; y: cint; w: cint; h: cint; c: Uint32; dst: PSDL_Surface);
var
  r : TSDL_Rect;
begin
  r.x := x;
  r.y := y;
  r.w := w;
  r.h := 1;
  SDL_FillRect(dst, @r, c);

  r.x := x;
  r.y := y + h - 1;
  r.w := w;
  r.h := 1;
  SDL_FillRect(dst, @r, c);

  r.x := x;
  r.y := y + 1;
  r.w := 1;
  r.h := h - 2;
  SDL_FillRect(dst, @r, c);

  r.x := x + w - 1;
  r.y := y + 1;
  r.w := 1;
  r.h := h - 2;
  SDL_FillRect(dst, @r, c);

  r.x := x;
  r.y := y;
  r.w := w;
  r.h := h;
  gui_dirty(@r);
end;


procedure gui_bar(x: cint; y: cint; w: cint; h: cint; c: Uint32; dst: PSDL_Surface);
var
  r: TSDL_Rect;
begin
  r.x := x;
  r.y := y;
  r.w := w;
  r.h := h;
  SDL_FillRect(dst, @r, SDL_MapRGB(dst^.format, 0, 0, 0));
  gui_box(x, y, w, h, c, dst);
end;


procedure gui_oscilloscope(buf: PSint32; bufsize: cint; start: cint; x: cint; y: cint; w: cint; h: cint; dst: PSDL_Surface);
var
  i         : cint;
  green, 
  red       : Uint32;
  r         : TSDL_Rect;
  xscale    : cint;
  c         : Uint32;
  s         : cint;
begin
  xscale := bufsize div w;
  if (xscale < 1) then xscale := 1
  else
  if (xscale > 8) then xscale := 8;

  r.x := x;
  r.y := y;
  r.w := w;
  r.h := h;
  SDL_FillRect(dst, @r, SDL_MapRGB(dst^.format, 0, 0, 0));
  gui_dirty(@r);

  green := SDL_MapRGB(dst^.format,   0, 200, 0);
  red   := SDL_MapRGB(dst^.format, 255,   0, 0);
  r.w := 1;
  for i := 0 to Pred(w) do
  begin
    c := green;
    // FPC: Use sar
    s := sarLongInt(-buf[(start + i * xscale) mod bufsize], 8);
    s := s * h;
    // FPC: Use sar
    s := sarLongInt(s, 16);

    r.x := x + i;
    if (s < 0) then
    begin
      if (s <= -h div 2) then
      begin
        s := -h div 2;
        c := red;
      end;
      r.y := y + h div 2 + s;
      r.h := -s;
    end
    else
    begin
      s := s + 1;
      if (s >= h div 2) then
      begin
        s := h div 2;
        c := red;
      end;
      r.y := y + h div 2;
      r.h := s;
    end;
    SDL_FillRect(dst, @r, c);
  end;

  r.x := x;
  r.y := y + h div 2;
  r.w := w;
  r.h := 1;
  SDL_FillRect(dst, @r, SDL_MapRGB(dst^.format, 128, 128, 255));
end;



function  gui_load_image(const fn: PChar): PSDL_Surface;
var
  cvt   : PSDL_Surface;
  img   : PSDL_Surface;
begin
  img := SDL_LoadBMP(fn);
  if not assigned(img) then exit(nil);
  cvt := SDL_DisplayFormat(img);
  SDL_FreeSurface(img);
  exit(cvt);
end;


procedure gui_text(x: cint; y: cint; txt: PChar; dst: PSDL_Surface);
var
  sx         : cint;
  sy         : cint;
  stxt       : PChar;
  highlights : cint;
  sr         : TSDL_Rect;
  c          : Char;
var
  r     : TSDL_Rect;
  hlr   : cint;
  hlg   : cint;
  hlb   : cint;
  hlc   : Uint32;
var
  dr    : TSDL_Rect;
  hlw   : cint;
begin
  sx := x;
  sy := y;
  stxt := txt;
  highlights := 0;
  sr.w := FONT_CW;
  sr.h := FONT_CH;
  while (txt^ <> #0) do
  begin
    c := txt^; inc(txt);
    case (c) of
      #0:       //* terminator */
      begin
        // break;
      end;
      #10:      //* newline */
      begin
        x := sx;
        y := y + FONT_CH;
      end;
      #9:       //* tab */
      begin
        x := x - sx;
        x := x + (8 * FONT_CW);
        x := x mod (8 * FONT_CW);
        x := x + sx;
      end;
      #&001,    //* red highlight */
      #&002,    //* green highlight */
      #&003,    //* yellow highlight */
      #&004,    //* blue highlight */
      #&005,    //* purple highlight */
      #&006,    //* cyan highlight */
      #&007:    //* white highlight */
      begin
        highlights := 1;
        if (txt^ = #&001)
        then txt := txt + 2;
      end;
      #&021,    //* red bullet */
      #&022,    //* green bullet */
      #&023,    //* yellow bullet */
      #&024,    //* blue bullet */
      #&025,    //* purple bullet */
      #&026,    //* cyan bullet */
      #&027:    //* white bullet */
      begin
        if ((Ord(c) and 1) <> 0) then hlr := 255 else hlr := 0;
        if ((Ord(c) and 2) <> 0) then hlg := 255 else hlg := 0;
        if ((Ord(c) and 4) <> 0) then hlb := 255 else hlb := 0;
        hlc := SDL_MapRGB(dst^.format, hlr, hlg, hlb);
        r.x := x;
        r.y := y;
        r.w := FONT_CW;
        r.h := FONT_CH;
        SDL_FillRect(dst, @r,SDL_MapRGB(dst^.format, 0, 0, 0));
        gui_dirty(@r);
        r.x := x + 2;
        r.y := y + 2;
        r.w := FONT_CW - 6;
        r.h := FONT_CH - 6;
        SDL_FillRect(dst, @r, hlc);
        x := x + FONT_CW;
      end;
      else      //* printables */
      begin
        if ( (c < ' ') or (c > #127) ) then c := #127;
        c := Char(Ord(c) - 32);
        sr.x := (Ord(c) mod (font^.w div FONT_CW)) * FONT_CW;
        sr.y := (Ord(c) div (font^.w div FONT_CW)) * FONT_CH;
        dr.x := x;
        dr.y := y;
        SDL_BlitSurface(font, @sr, dst, @dr);
        gui_dirty(@dr);
        x := x + FONT_CW;
      end;
    end;
  end;

  if not(highlights <> 0) then exit;

  x := sx;
  y := sy;
  txt := stxt;

  while (txt^ <> #0) do
  begin
    c := txt^; inc(txt);
    case (c) of
      #0:       //* terminator */
      begin
        // nothing
      end;
      #10:      //* newline */
      begin
        x := sx;
        y := y + FONT_CH;
      end;
      #9:       //* tab */
      begin
        x := x - sx;
        x := x + (8 * FONT_CW);
        x := x mod (8 * FONT_CW);
        x := x + sx;
      end;
      #&001,    //* red highlight */
      #&002,    //* green highlight */
      #&003,    //* yellow highlight */
      #&004,    //* blue highlight */
      #&005,    //* purple highlight */
      #&006,    //* cyan highlight */
      #&007:    //* white highlight */
      begin
        if ((Ord(c) and 1) <> 0) then hlr := 255 else hlr := 0;
        if ((Ord(c) and 2) <> 0) then hlg := 255 else hlg := 0;
        if ((Ord(c) and 4) <> 0) then hlb := 255 else hlb := 0;
        hlc := SDL_MapRGB(screen^.format, hlr, hlg, hlb);
        hlw := 1;
        if (txt^ = #&001) then
        begin
          hlw := Ord(txt[1]);
          txt := txt + 2;
        end;
        gui_box(x - 2, y - 2, FONT_CW * hlw + 2, FONT_CH + 2, hlc, dst);
      end;
      else      //* printables */
      begin
        x := x + FONT_CW;
      end;
    end;
  end;
end;


procedure gui_tempo(v: cint);
var
  buf : string[32];
begin
  WriteStr(buf, '  Tempo: ', v:4, #0);

  gui_text(12, 52, @buf[1], screen);
end;


procedure gui_songpos(v: cint);
var
  buf : string[32];
begin
  WriteStr(buf, 'SongPos: ', v:4, #0);
  gui_text(12, 52 + FONT_CH, @buf[1], screen);
end;


procedure gui_songedit(pos: cint; ppos: cint; track: cint; editing: boolean);
var
  t, n  : cint;
  buf   : String[128];
  r     : TSDL_Rect;
  y0    : cint = 146;
  note  : Char;
begin
  //* Clear */
  r.x := 12 - 2;
  r.y := y0 - 2;
  r.w := FONT_CW * 38 + 4;
  r.h := FONT_CH * (SSEQ_TRACKS + 2) + 4 + 5;
  SDL_FillRect(screen, @r, SDL_MapRGB(screen^.format, 0, 0, 0));
  gui_dirty(@r);

  //* Upper time bar */
  WriteStr(buf, #&027'...'#&022'...'#&022'...'#&022'...'#&027'...'#&022'...'#&022'...'#&022'...', #0);
  gui_text(12 + 6 * FONT_CW, y0, @buf[1], screen);

  //* Track names + cursor */
  gui_text
  (
    12, y0 + FONT_CH + 3, 
    'Kick'#10'Clap'#10'Bell'#10'HiHat'#10 +
    'Trk04'#10'Trk05'#10'Trk06'#10'Trk07'#10 +
    'Trk08'#10'Trk09'#10'Trk10'#10'Trk11'#10 +
    'Trk12'#10'Trk13'#10'Trk14'#10'Trk15',
    screen
  );
  gui_text(12, y0 + FONT_CH * (1 + track) + 3, #&003#&001#&005, screen);

  //* Lower time bar */
  WriteStr
  (
    buf, 
    #&007, LeadZero(pos   , 4) , #&022'...', #&007, LeadZero(pos+ 8,4), #&022'...' +
    #&007, LeadZero(pos+16, 4) , #&022'...', #&007, LeadZero(pos+24,4), #&022'...' + #0
  );      
  gui_text(12 + 6 * FONT_CW, y0 + FONT_CH * (SSEQ_TRACKS + 1) + 6, @buf[1], screen);

  //* Notes */
  buf[succ(1)] := #0;
  for t := 0 to Pred(SSEQ_TRACKS) do
  begin
    for n := 0 to Pred(32) do
    begin
      note := sseq_get_note(pos + n, t);
      if (note = #255)
      then continue
      else buf[succ(0)] := note;
      gui_text(12 + FONT_CW * (6 + n), y0 + FONT_CH * (1 + t) + 3, @buf[1], screen);
    end;
  end;

  //* Cursors */
  gui_text(12 + FONT_CW * (6 + (ppos and $1f)), y0, #&003, screen);
  gui_text(12 + FONT_CW * (6 + (ppos and $1f)), y0 + FONT_CH * (SSEQ_TRACKS + 1) + 6, #&003, screen);
  if editing
  then gui_text(12 + FONT_CW * (6 + (ppos and $1f)), y0 + FONT_CH * (1 + track) + 3, #&007, screen);
end;


procedure gui_draw_activity(dt: cint);
var
  t     : cint;
  x0    : cint;
  y0    : cint;
  r     : TSDL_Rect;
  c     : Uint32;
begin
  x0 := 12 + FONT_CW * 5;
  y0 := 146 + FONT_CH + 3;

  r.x := x0 + 1;
  r.y := y0 + 1;
  r.w := FONT_CW - 3;
  r.h := FONT_CH * SSEQ_TRACKS - 3;
  gui_dirty(@r);

  for t := 0 to Pred(SSEQ_TRACKS) do
  begin
    r.x := x0 + 1;
    r.y := y0 + t * FONT_CH + 1;
    r.w := FONT_CW - 3;
    r.h := FONT_CH - 3;

    activity[t] := activity[t] - dt;

    if (activity[t] < 0) then activity[t] := 0;

    c := activity[t] * 255 div MAXACTIVITY;
    c := c * c * c div (255 * 255);

    if (sseq_muted(t) <> 0)
    then c := SDL_MapRGB(screen^.format, c, c, 255)
    else c := SDL_MapRGB(screen^.format, c, c, c);

    SDL_FillRect(screen, @r, c);
  end;
end;


procedure gui_activity(trk: cint);
begin
  activity[trk] := MAXACTIVITY;
end;


procedure gui_status(playing: boolean; editing: boolean; looping: boolean);
var
  buf   : string[64];
  pe, l : PChar;
  r     : TSDL_Rect;
begin
  r.x := 12 - 2;
  r.y := 100 - 2;
  r.w := FONT_CW * 13 + 2;
  r.h := FONT_CH + 2;
  SDL_FillRect(screen, @r, SDL_MapRGB(screen^.format, 0, 0, 0));
  gui_dirty(@r);
  if playing then
  begin
    if editing then pe := #&021#&001#&001#&003'REC' else pe := 'PLAY';
    if looping then l := ' LOOP ' else l := ' SONG ';
  end
  else
  begin
    if editing then pe := #&001#&001#&004'EDIT' else pe := 'STOP';
    if looping then l := '(loop)' else l := '      ';
  end;

  WriteStr(Buf, pe, ' ', l, #0);
  gui_text(12, 100, @buf[1], screen);
end;


procedure gui_select_range(selfrom: cint; selto: cint);
var
  buf : String[32];
begin
  if (selfrom <> selto)
  then WriteStr(buf, 'Sel:', selFrom:4, '-', selto:4, #0)
  else WriteStr(buf, 'No Selection.', #0);
  gui_text(12, 116, @buf[1], screen);
end;


procedure gui_songselect(x1: cint; y1: cint; x2: cint; y2: cint);
var
  i     : cint;
  x0    : cint;
  y0    : cint;
  r     : TSDL_Rect;
  c     : Uint32;
begin
  x0 := 12 + FONT_CW * 6;
  y0 := 146 + FONT_CH + 3;

  c := SDL_MapRGB(screen^.format, 255, 128, 255);

  //* Sort coordinates */
  if (x1 > x2) then
  begin
    i := x1;
    x1 := x2;
    x2 := i;
  end;

  if (y1 > y2) then
  begin
    i := y1;
    y1 := y2;
    y2 := i;
  end;

  y2 := y2 + 1;
  gui_select_range(x1, x2);
  if (x1 = x2) then exit;       //* No selection! */

  //* Draw selection box */
  r.x := x0 - 2;
  r.y := y0 - 2;
  r.w := FONT_CW * 32 + 4;
  r.h := FONT_CH * SSEQ_TRACKS + 4;
  SDL_SetClipRect(screen, @r);

  r.x := x0 + x1 * FONT_CW - 2;
  r.y := y0 + y1 * FONT_CH - 2;
  r.w := (x2 - x1) * FONT_CW + 4;
  r.h := 2;
  SDL_FillRect(screen, @r, c);

  r.x := x0 + x1 * FONT_CW - 2;
  r.y := y0 + y2 * FONT_CH;
  r.w := (x2 - x1) * FONT_CW + 4;
  r.h := 2;
  SDL_FillRect(screen, @r, c);

  r.x := x0 + x1 * FONT_CW - 2;
  r.y := y0 + y1 * FONT_CH;
  r.w := 2;
  r.h := (y2 - y1) * FONT_CW;
  SDL_FillRect(screen, @r, c);

  r.x := x0 + x2 * FONT_CW;
  r.y := y0 + y1 * FONT_CH;
  r.w := 2;
  r.h := (y2 - y1) * FONT_CW;
  SDL_FillRect(screen, @r, c);

  SDL_SetClipRect(screen, nil);
end;


procedure gui_message(const msg: PChar; curspos : cint);
var
  y0 : cint;
  r  : TSDL_Rect;
begin
  y0 := screen^.h - FONT_CH - 12;

  r.x := 10;
  r.y := y0 - 2;
  r.w := screen^.w - 20;
  r.h := FONT_CH + 4;

  SDL_FillRect(screen, @r, SDL_MapRGB(screen^.format, 0, 0, 0));
  gui_dirty(@r);

  if assigned(msg) then
  begin
    free(message_text);
    message_text := strdup(msg);
  end;

  if assigned(message_text)
  then gui_text(12, y0, message_text, screen);

  if (curspos >= 0)
  then gui_text(12 + FONT_CW * curspos, y0, #&007#0, screen);
end;


procedure logo(fwc: Uint32);
begin
  gui_bar(6, 6, 228, 36, fwc, screen);
  gui_text(18, 17, 'DT-42 DrumToy', screen);
  gui_box(6 + 3, 6 + 3, 228 - 6, 36 - 6, fwc, screen);
end;


procedure draw_help(page: TGUI_pages);
var
  fwc   : Uint32;
begin
  fwc := SDL_MapRGB(screen^.format, 128, 64, 128);

  //* Clear */
  SDL_FillRect(screen, nil, SDL_MapRGB(screen^.format, 48, 24, 48));
  gui_dirty(nil);

  logo(fwc);

  gui_bar(232 + 6, 6, screen^.w - 238 - 6, 36, fwc, screen);
  gui_bar(6, 46, screen^.w - 12, screen^.h - 46 - 6, fwc, screen);

  case (page) of
    GUI_PAGE_HELP1:
    begin
      gui_text(232 + 18, 17, '1/4:Keyboard Controls 1', screen);
      gui_text
      (
        12, 52,
        #&027'Escape or Ctrl+Q'#10 +
        '    '#&005'Quit DT-42.'#10#10 +
        #&027'Ctrl+O'#10 +
        '    '#&005'Open song file.'#10#10 +
        #&027'Ctrl+S'#10 +
        '    '#&005'Save current song to file.'#10#10 +
        #&027'Ctrl+N'#10 +
        '    Clear and create '#&005'New song.'#10#10 +
        #&027'Tab'#10 +
        '    Cycle application pages;'#10 +
        '    Main->Messages->',
        screen
      );
    end;
    GUI_PAGE_HELP2:
    begin
      gui_text(232 + 18, 17, '2/4:Keyboard Controls 2', screen);
      gui_text
      (
        12, 52,
        #&027'Space Bar'#10 +
        '    Start/stop.'#10#10 +
        #&027'Left/Right Arrows'#10 +
        '    Prev/next step/note.'#10#10 +
        #&027'PgUp/PgDn'#10 +
        '    Prev/next bar.'#10#10 +
        #&027'Up/Down Arrows'#10 +
        '    Prev/next track.'#10#10 +
        #&027'+/-'#10 +
        '    Tempo up/down 1 BPM.'#10#10 +
        #&027'L'#10 +
        '    Toggle '#&005'Looping.'#10#10 +
        #&027'R'#10 +
        '    Toggle '#&005'Recording/editing.'#10#10 +
        #&027'M'#10 +
        '    '#&005'Mute/Un'#&005'Mute current track.',
        screen
      );
    end;
    GUI_PAGE_HELP3:
    begin
      gui_text(232 + 18, 17, '3/4:Keyboard Controls 3', screen);
      gui_text
      (
        12, 52,
        #&027'F1-F12'#10 +
        '    Select track & play note.'#10#10 +
        #&027'0-9 (Main or NumPad)'#10 +
        '    Play note on current track.'#10#10 +
        #&027'Ctrl+C or Ctrl+Insert'#10 +
        '    '#&005'Copy current selection.'#10#10 +
        #&027'Ctrl+X'#10 +
        '    Copy and delete current selection.'#10#10 +
        #&027'Ctrl+V or Shift+Insert'#10 +
        '    Paste last copied selection.'#10#10 +
        #&027' When Editing/Recording, F1-F12 and'#10 +
        '  0-9 will also insert/record notes.'#10#10 +
        #&027' Moving the cursor while holding the'#10 +
        '  Shift key selects notes.',
        screen
      );
    end;
    GUI_PAGE_HELP4:
    begin
      gui_text(232 + 18, 17, '4/4:Song Commands', screen);
      gui_text
      (
        12, 52,
        #&027'C    '#&005'Cut note. Switches to a volume'#10 +
        '      decay rate corresponding to D9,'#10 +
        '      until the next note is played.'#10#10 +
        #&027'Vlr  Set '#&005'Volumes to l/r.'#10#10 +
        #&027'Dn   Set volume '#&005'Decay rate to n.'#10 +
        '      Applies a volume envelope to'#10 +
        '      subsequent notes. Higher values'#10 +
        '      mean faster decay.'#10#10 +
        #&027'Jnnn '#&005'Jump to song position nnn.'#10#10 +
        #&027'Tnnn Set '#&005'Tempo to nnn BPM'#10#10 +
        #&027'Z    '#&005'Zero duration step. Advances'#10 +
        '      all tracks and plays the next'#10 +
        '      step instantly.'#10#10,
        screen
      );
    end;
  end;
end;


procedure draw_log;
var
  fwc : Uint32;
begin
  fwc := SDL_MapRGB(screen^.format, 128, 64, 0);

  //* Clear */
  SDL_FillRect(screen, nil, SDL_MapRGB(screen^.format, 64, 32, 0));
  gui_dirty(nil);

  logo(fwc);

  gui_bar(232 + 6, 6, screen^.w - 238 - 6, 36, fwc, screen);
  gui_text(232 + 18, 17, 'Message Log', screen);
  gui_bar(6, 46, screen^.w - 12, screen^.h - 46 - 6, fwc, screen);
  gui_text(12, 52, '(Not implemented.)', screen);
end;


procedure draw_main;
var
  fwc: Uint32;
begin
  fwc := SDL_MapRGB(screen^.format, 0, 128, 0);

  //* Clear */
  SDL_FillRect(screen, nil, SDL_MapRGB(screen^.format, 0, 48, 0));
  gui_dirty(nil);

  logo(fwc);

  //* Oscilloscope frames */
  gui_bar(240 - 2, 8 - 2, 192 + 4, 128 + 4, fwc, screen);
  gui_bar(440 - 2, 8 - 2, 192 + 4, 128 + 4, fwc, screen);

  //* Song info panel */
  gui_bar(6, 46, 228, 44, fwc, screen);
  gui_tempo(0);
  gui_songpos(0);

  //* Status box */
  gui_bar(6, 94, 228, 44, fwc, screen);
  gui_status(false, false, false);

  //* Song editor */
  gui_bar(6, 142, 640 - 12, FONT_CH * (SSEQ_TRACKS + 2) + 12, fwc, screen);
  gui_songedit(0, 0, 0, false);

  //* Message bar */
  gui_bar(6, screen^.h - FONT_CH - 12 - 6, 640 - 12, FONT_CH + 12, fwc, screen);
  gui_message(nil, -1);
end;


procedure gui_draw_screen(page: TGUI_pages);
begin
  case (page) of
    GUI_PAGE_MAIN:
    begin
      draw_main();
    end;
    GUI_PAGE_LOG:
    begin
      draw_log();
    end;
    GUI_PAGE_HELP1,
    GUI_PAGE_HELP2,
    GUI_PAGE_HELP3,
    GUI_PAGE_HELP4:
    begin
      draw_help(page);
    end;
  end;
end;


function  gui_open(scrn: PSDL_Surface): boolean;
begin
  screen := scrn;
  font := gui_load_image('font.bmp');
  if not assigned(font) then
  begin
    WriteLn(stderr, 'Couldn''t load font!');
    exit(false);
  end;

  SDL_EnableKeyRepeat(250, 25);
  // PFC: be explicit
  memset(@activity[0], 0, Length(activity) * sizeOf(cint));
  exit(true);
end;


procedure gui_close;
begin
  if assigned(message_text) then free(message_text);
  SDL_FreeSurface(font);
  font := nil;
end;


end.
