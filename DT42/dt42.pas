program dt42;

{$MODE OBJFPC}{$H+}
{$RANGECHECKS ON}
{.$DEFINE TRACE}

  {
  * DT-42 DrumToy - an interactive audio example for SDL.
  *
  * (C) David Olofson, 2003, 2006
  }

  {
    Conversion to Pascal done by Magorium, feb 2017

    Perhaps not so notable changes:
    - Accommodate for enumerators
    - Note has become a char instead of cint
    - As a result of the above, there is no <0 check possible. use char #255
    - Where possible cint's where turned into boolean's 
      (i'm sure i forgot some).
    - Some workarounds that might be percieved as being wierd
    - snprintf's replaced with WriteStr's.
      As a consequence, the buffer needs to be indexed with one when being 
      supplied to other routines and the buffer always needs to be terminated 
      with #0 as the original c-code expects PChars all over the place.
    - File I/O got a overhaul to Pascal. Still somewhat error-prone and 
      incomplete. It's suffice for now.

    ToDo:
    - Remove chelpers and phelpers dependencies
    - More Pascalization
    - OOP
    - Remove bugs
  }

uses
  {$IFDEF TRACE}heaptrc,{$ENDIF} ctypes, chelpers, smixer, sseq, gui, dtversion, SDL;


{*-------------------------------------------------------------------
    Application data types
-------------------------------------------------------------------*}

Const
  //* Maximum length of a file name/path */
  FNLENGTH  = 1024;

Type
  //* Application states */
  DT_dialog_modes = 
  (
    DM_NORMAL,
    DM_ASK_EXIT,
    DM_ASK_NEW,
    DM_ASK_LOADNAME,
    DM_ASK_SAVENAME
  );


{*-------------------------------------------------------------------
    Application variables
-------------------------------------------------------------------*}

//* Application state and control */
var
  dialog_mode   : DT_dialog_modes   = DM_NORMAL;        //* GUI mode */

const
  die           : boolean           = false;            //* Exit application */
  page          : TGUI_pages        = GUI_PAGE_MAIN;    //* Current GUI page */

  //* Audio */
  abuffer       : cint              = 2048;             //* Audio buffer size*/
  {
  * On Linux with the ALSA backend, OSCBUFFER needs to be
  * BUFFER * 3 for the oscilloscopes to be in sync with
  * the output. However, this works only up to 8192 samples.
  * I don't know if this works as intended with other
  * backends, or on other operating systems. If it's
  * important (like in interactive applications...), it
  * should probably be user configurable.
  }
  dbuffer       : cint              = -1;               //* Sync delay buffer size */

  //* Oscilloscopes */
  oscpos        : cint              = 0;                //* Grab buffer position */
  plotpos       : cint              = 0;                //* Plot position */
  osc_left      : PSint32           = nil;              //* Left audio grab buffer */
  osc_right     : PSint32           = nil;              //* Right audio grab buffer */

  //* Sequencer control */
  tempo         : cfloat            = 120.0;            //* Current sequencer tempo */
  playposbuf    : pcshort           = nil;              //* Sequencer pos grab buffer */
  playpos       : cunsigned         = 0;                //* Current pos (calculated) */
  last_playpos  : cunsigned         = cunsigned(-100000);
  playing       : boolean           = false;
  looping       : boolean           = false;

  //* Video */
  sdlflags      : cint              = SDL_SWSURFACE;    //* SDL display init flags */

  //* Song file */
  songfilename  : PChar             = nil;              //* File name of current song */
  must_exist    : boolean           = true;             //* Exit if file does not exist */

  //* Line editor */
  ed_buffer     : PChar             = nil;              //* String buffer */
  ed_pos        : cint              = 0;                //* Cursor position */

  //* Song editor */
  scrollpos     : cunsigned         = 0;                //* Scroll position */
  edtrack       : cint              = 0;                //* Cursor track */
  editing       : boolean           = false;            //* Editing enabled! */
  update_edit   : cint              = 1;                //* Needs updating! */

  //* Selection and copy/paste */
  sel_start_x   : cint              = -1;               //* Start step */
  sel_start_y   : cint              = -1;               //* Start track */
  sel_end_x     : cint              = -1;               //* End step */
  sel_end_y     : cint              = -1;               //* End track */

var
  block         : array[0..Pred(SSEQ_TRACKS)] of PChar; //* Clip board */


function valid_selection: boolean;
begin
  exit( (sel_start_x >= 0) and (sel_start_x <> sel_end_x) );
end;


{*-------------------------------------------------------------------
    Command line interface
-------------------------------------------------------------------*}

function parse_args(argc: cint; argv: PPChar): cint;
var
  i : cint;
var
  len : cint;
begin
  for i := 1 to Pred(argc) do
  begin
    if (strncmp(argv[i], '-f', 2) = 0) then
    begin
      sdlflags := sdlflags or SDL_FULLSCREEN;
      WriteLn('Requesting fullscreen display.');
    end
    else
    if (strncmp(argv[i], '-b', 2) = 0) then
    begin
      abuffer := atoi(argv[i] + 2);
      WriteLn('Requested audio buffer size: ', abuffer);
    end
    else
    if (strncmp(argv[i], '-d', 2) = 0) then
    begin
      dbuffer := atoi(argv[i] + 2);
      WriteLn('Requested delay buffer size: ', dbuffer);
    end
    else
    if (strncmp(argv[i], '-n', 2) = 0) then
    begin
      must_exist := false;
    end
    else
    if (argv[i][0] <> '-') then
    begin
      free(songfilename);
      if (strchr(argv[i], '.') <> nil)
      then songfilename := strdup(argv[i])
      else
      begin
        len := strlen(argv[i]);
        songfilename := malloc(len + 6);
        memcpy(songfilename, argv[i], len);
        memcpy(songfilename + len, PChar('.dt42'#0), 6);
      end;
    end
    else
      exit(-1);
  end;
  exit(0);
end;


procedure usage(const exename: PChar);
begin
  WriteLn(stderr, '.----------------------------------------------------');
  WriteLn(stderr, '| DT-42 DrumToy ' + VERSION);
  WriteLn(stderr, '| Copyright (C) 2006 David Olofson');
  WriteLn(stderr, '|----------------------------------------------------');
  WriteLn(stderr, '| Usage: ', exename, ' [switches] <file>');
  WriteLn(stderr, '| Switches:  -b<x> Audio buffer size');
  WriteLn(stderr, '|            -d<x> Delay buffer size');
  WriteLn(stderr, '|            -f    Fullscreen display');
  WriteLn(stderr, '|            -n    Create new song');
  WriteLn(stderr, '|            -h    Help');
  WriteLn(stderr, '''----------------------------------------------------');
end;


procedure breakhandler(a: cint);
begin
  die := true;
end;


{*-------------------------------------------------------------------
    Audio processing
-------------------------------------------------------------------*}

//* Grab data for the oscilloscopes */
procedure grab_process(buf: PSint32; frames: cint);
var
  i     : cint;
  pp    : cshort;
  ind   : cint;
begin
  pp := sseq_get_position();
  for i := 0 to Pred(frames) do
  begin
    ind := (oscpos + i) mod dbuffer;
    osc_left[ind]  := buf[i * 2];
    osc_right[ind] := buf[i * 2 + 1];
    playposbuf[ind] := pp;
  end;
  oscpos := (oscpos + frames) mod dbuffer;
  plotpos := oscpos;
end;


//* Soft saturation */
procedure saturate_process(buf: PSint32; frames: cint);
var
  i: cint;
  s: cfloat;
begin
  frames := frames * 2;
  for i := 0 to Pred(frames) do 
  begin
    s := cfloat(buf[i] * (1.0 / $800000) );
    buf[i] := trunc((1.5 * s - 0.5 * s*s*s) * $800000);
  end;
end;


//* Clip samples so they don't wrap when converted to 16 bits */
procedure clip_process(buf: PSint32; frames: cint);
var
  i     : cint;
  ind   : cint = 0;
begin
  for i := 0 to Pred(frames) do
  begin
    if (buf[ind] <  -$800000) then buf[ind] := -$800000
    else 
    if (buf[ind] > $007fffff) then buf[ind] := $007fffff;

    if (buf[ind + 1] <  -$800000) then buf[ind + 1] := $800000
    else 
    if (buf[ind + 1] > $007fffff) then buf[ind + 1] := $007fffff;
    ind := ind + 2;
  end;
end;


procedure audio_process(buf: PSint32; frames: cint);
begin
  saturate_process(buf, frames);
  clip_process(buf, frames);
  grab_process(buf, frames);
end;


{*-------------------------------------------------------------------
    Sequencer + GUI synchronized operations
-------------------------------------------------------------------*}

procedure move(notes: cint);
var
 i   : cint;
 pos : cint;
begin
  pos := sseq_get_position();
  pos := pos + notes;
  if (pos < 0) then pos := 0;
  sseq_set_position(pos);
  if playing then
  begin
    {*
      FIXME: This will not do the right thing with looping enabled!
    *}
    playpos := playpos + notes;
    for i := 0 to Pred(dbuffer) do
    begin
      playposbuf[i] := playposbuf[i] + notes;
      if (playposbuf[i] < 0) then playposbuf[i] := 0;
    end;
    if (integer(playpos) < 0) then playpos := 0;
  end
  else
  begin
    playpos := pos;
    for i := 0 to Pred(dbuffer)
      do playposbuf[i] := pos;
  end;
end;


procedure handle_note(trk: cint; note: Char);
begin
  if ( (note >= '0') and (note <= '9') ) then
  begin
    sseq_play_note(trk, note);
    gui_activity(trk);
  end;

  if (editing) then
  begin
    if (note = #127) then
    begin
      if not(playing) then move(-1);
      sseq_set_note(playpos, trk, '.');
    end
    else
    begin
      sseq_set_note(playpos, trk, note);
      if not(playing) then move(1);
    end;
  end;
end;


procedure set_loop;
begin
  if looping then
  begin
    if (valid_selection()) then
    begin
      if (sel_start_x < sel_end_x)
// MAG: Huh ?
      then sseq_loop(sel_start_x, sel_end_x)
      else sseq_loop(sel_start_x, sel_end_x);
    end
    else sseq_loop(scrollpos, scrollpos + 32);
  end
  else sseq_loop(-1, -1);
end;


{*-------------------------------------------------------------------
    Application page handling
-------------------------------------------------------------------*}

procedure switch_page(new_page: TGUI_pages);
begin
  page := new_page;
  LongInt(last_playpos) := -100000;
  update_edit := 1;
  gui_draw_screen(page);
end;


{*-------------------------------------------------------------------
    File I/O
-------------------------------------------------------------------*}

function  load_song(const fn: PChar): cint;
var
  buf   : string[128];
  res   : cint;
begin
  res := sseq_load_song(fn);
  if (res < 0) 
  then WriteStr(buf, 'ERROR Loading "', fn, '"!', #0)
  else WriteStr(buf, 'Loaded "', fn, '"', #0);
  gui_message(@buf[1], -1);
  move(-10000);
  update_edit := 1;
  exit(res);
end;


function  save_song(const fn: PChar): cint;
var
  buf   : String[128];
  res   : cint;
begin
  res := sseq_save_song(fn);
  if (res < 0)
  then WriteStr(buf, 'ERROR Saving "', fn, '"!', #0)
  else WriteStr(buf, 'Saved "', fn, '"', #0);
  gui_message(@buf[1], -1);
  exit(res);
end;


{*-------------------------------------------------------------------
    Application exit query and checking
-------------------------------------------------------------------*}

procedure ask_exit;
begin
  gui_message('Really Exit DT-42? '#&001'Y/'#&002'N', -1);
  dialog_mode := DM_ASK_EXIT;
end;


procedure handle_key_ask_exit(ev: PSDL_Event);
begin
  case (ev^.key.keysym.sym) of
    SDLK_KP_ENTER,
    SDLK_RETURN,
    SDLK_y:
    begin
      dialog_mode := DM_NORMAL;
      gui_message('Bye!', -1);
      die := true;
    end;
    SDLK_ESCAPE,
    SDLK_n:
    begin
      gui_message('Aborted - Not Exiting.', -1);
      dialog_mode := DM_NORMAL;
    end;
  end;
end;


{*-------------------------------------------------------------------
    Ask before clearing song
-------------------------------------------------------------------*}

procedure ask_new;
begin
  gui_message('Really clear and start new song? '#&001'Y/'#&002'N', -1);
  dialog_mode := DM_ASK_NEW;
end;


procedure handle_key_ask_new(ev: PSDL_Event);
begin
  case (ev^.key.keysym.sym) of
    SDLK_KP_ENTER,
    SDLK_RETURN,
    SDLK_y:
    begin
      dialog_mode := DM_NORMAL;
      load_song('default.dt42');
      gui_message('New song - defaults loaded.', -1);
    end;
    SDLK_ESCAPE,
    SDLK_n:
    begin
      gui_message('Aborted.', -1);
      dialog_mode := DM_NORMAL;
    end;
  end;
end;


{*-------------------------------------------------------------------
    File handling
-------------------------------------------------------------------*}

procedure ask_loadname(const orig: PChar);
begin
  SDL_EnableUNICODE(1);
  ed_buffer := calloc(FNLENGTH, 1);
  if assigned(orig) then
  begin
    strncpy(ed_buffer, orig, FNLENGTH - 1);
    ed_pos := strlen(ed_buffer);
  end
  else
  begin
    strncpy(ed_buffer, '.dt42', FNLENGTH - 1);
    ed_pos := 0;
  end;
  gui_message(ed_buffer, ed_pos);
  dialog_mode := DM_ASK_LOADNAME;
end;


procedure ask_savename(const orig: PChar);
begin
  ask_loadname(orig);
  dialog_mode := DM_ASK_SAVENAME;
end;


{*-------------------------------------------------------------------
    Selection and block operations
-------------------------------------------------------------------*}

procedure block_free;
var
  i : cint;
begin
  for i := 0 to Pred(SSEQ_TRACKS) do
  begin
    free(block[i]);
    block[i] := nil;
  end;
end;


procedure block_copy;
var
  i, x, w, y1, y2: cint;
  j  : cint;
  n  : Char;
begin
  if not(valid_selection) then exit;

  block_free();

  //* Select steps exclusively */
  if (sel_start_x <= sel_end_x) then
  begin
    x := sel_start_x;
    w := sel_end_x - sel_start_x;
  end
  else
  begin
    x := sel_end_x;
    w := sel_start_x - sel_end_x;
  end;

  //* Select tracks *inclusively*! */
  if (sel_start_y <= sel_end_y) then
  begin
    y1 := sel_start_y;
    y2 := sel_end_y;
  end
  else
  begin
    y1 := sel_end_y;
    y2 := sel_start_y;
  end;

  //* Copy, filling undefs with '.' */
  for i := y1 to y2 do
  begin
    block[i - y1] := malloc(w + 1);
    block[i - y1][w] := #0;
    for j := 0 to Pred(w) do
    begin
      n := sseq_get_note(x + j, i);
      if (n <> #255)
      then n := '.';
      block[i - y1][j] := n;
    end;
  end;
end;


procedure block_delete;
var
  i, x, w, y1, y2: cint;
  j : cint;
begin
  if not(valid_selection) then exit;

  //* Select steps exclusively */
  if (sel_start_x <= sel_end_x) then
  begin
    x := sel_start_x;
    w := sel_end_x - sel_start_x;
  end
  else
  begin
    x := sel_end_x;
    w := sel_start_x - sel_end_x;
  end;

  //* Select tracks *inclusively*! */
  if (sel_start_y <= sel_end_y) then
  begin
    y1 := sel_start_y;
    y2 := sel_end_y;
  end
  else
  begin
    y1 := sel_end_y;
    y2 := sel_start_y;
  end;

  //* Copy, filling undefs with '.' */
  for i := y1 to y2 do
  begin
    for j := 0 to Pred(w)
      do sseq_set_note(x + j, i, '.');
  end;
end;


procedure block_paste(x: cint; y: cint);
var
  i, w : cint;
  j    : cint = 0;  // FPC: shutup compiler notification
begin
  w := 0;
  for i := 0 to Pred(SSEQ_TRACKS) do
  begin
    if not assigned(block[i])
    then continue;
    w := strlen(block[i]);
    for j := 0 to Pred( ord(block[i][j]) ) 
      do sseq_set_note(x + j, y, block[i][j]);
    y := ((y + 1) mod SSEQ_TRACKS)
  end;
  if (w <> 0) then move(w);
  update_edit := 1;
end;


procedure block_select(x: cint; y: cint);
begin
  if not(editing) then exit;

  if (x < 0) then
  begin
    if (sel_start_x >= 0) then
    begin
      sel_start_x := -1;
      update_edit := 1;
      set_loop();
    end;
    exit;
  end;

  if (sel_start_x < 0) then
  begin
    sel_start_x := x;
    sel_start_y := y;
    update_edit := 1;
    set_loop();
  end
  else
  begin
    sel_end_x := x;
    sel_end_y := y;
    update_edit := 1;
    set_loop();
  end;
end;


{*-------------------------------------------------------------------
    Keyboard input
-------------------------------------------------------------------*}

procedure handle_key_ask_filename(ev: PSDL_Event);
var
  len : cint;
  c   : Char;
begin
  len := strlen(ed_buffer);
  case (ev^.key.keysym.sym) of
    SDLK_HOME:
    begin
      ed_pos := 0;
      gui_message(ed_buffer, ed_pos);
    end;
    SDLK_END:
    begin
      ed_pos := len;
      gui_message(ed_buffer, ed_pos);
    end;
    SDLK_LEFT:
    begin
      if (ed_pos > 0) then dec(ed_pos);
      gui_message(ed_buffer, ed_pos);
    end;
    SDLK_RIGHT:
    begin
      if (ed_pos < len) then inc(ed_pos);
      gui_message(ed_buffer, ed_pos);
    end;
    SDLK_BACKSPACE:
    begin
      // FPC: acomodate for original c-flow (break + fall through)
      if (ed_pos <> 0) then
      begin
        dec(ed_pos);
        //* Fall through to DELETE! */
        // FPC: acomodate for original c-flow (break)
        if (len <> 0) then
        begin
          if not(ed_pos = len) then
          begin
            memmove(ed_buffer + ed_pos, ed_buffer + ed_pos + 1, len - ed_pos);
            gui_message(ed_buffer, ed_pos);
          end;
        end;
      end
      else { nothing } ;
    end;
    SDLK_DELETE:
    begin
      // FPC: acomodate for original c-flow (break)
      if (len <> 0) then
      begin
        if not(ed_pos = len) then
        begin
          memmove(ed_buffer + ed_pos, ed_buffer + ed_pos + 1, len - ed_pos);
          gui_message(ed_buffer, ed_pos);
        end;
      end;
    end;
    SDLK_KP_ENTER,
    SDLK_RETURN:
    begin
      case (dialog_mode) of
        DM_ASK_SAVENAME:
        begin
          if (save_song(ed_buffer) >= 0) then
          begin
            free(songfilename);
            songfilename := strdup(ed_buffer);
          end;
        end;
        DM_ASK_LOADNAME:
        begin
          if (load_song(ed_buffer) >= 0) then
          begin
            free(songfilename);
            songfilename := strdup(ed_buffer);
          end;
        end;
      end;
      free(ed_buffer);
      SDL_EnableUNICODE(0);
      dialog_mode := DM_NORMAL;
    end;
    SDLK_ESCAPE:
    begin
      gui_message('Aborted.', -1);
      free(ed_buffer);
      SDL_EnableUNICODE(0);
      dialog_mode := DM_NORMAL;
    end;
    else
    begin
      if ( (ev^.key.keysym.unicode and $ff80) = 0)
      then c := Char(ev^.key.keysym.unicode and $7f)
      else c := #127;
      if not(c < ' ') then
      begin
        if (len >= FNLENGTH - 1) then
        begin
          if (ed_pos < (FNLENGTH - 2) )
          then memmove(ed_buffer + ed_pos + 1, ed_buffer + ed_pos, FNLENGTH - 1 - ed_pos);
        end
        else memmove(ed_buffer + ed_pos + 1, ed_buffer + ed_pos, len - ed_pos + 1);
        ed_buffer[ed_pos] := c;
        inc(ed_pos);
        gui_message(ed_buffer, ed_pos);
      end;
    end;
  end;
end;


procedure handle_move_keys(ev : PSDL_Event);
var
  pos    : cint;
  newpos : cint;
begin
  case (ev^.key.keysym.sym) of
    SDLK_LEFT:
    begin
      move(-1);
    end;
    SDLK_RIGHT:
    begin
      move(1);
    end;
    SDLK_PAGEUP:
    begin
      pos := sseq_get_position();
      newpos := pos;
      if not( (pos and $f) <> 0) then
      begin
        newpos := newpos - 16;
        if (newpos < 0) then newpos := 0;
      end
      else newpos := newpos and $fffffff0;
      move(newpos - pos);
    end;
    SDLK_PAGEDOWN:
    begin
      pos := sseq_get_position();
      newpos := pos;
      newpos := newpos and $fffffff0;
      newpos := newpos + 16;
      move(newpos - pos);
    end;
    SDLK_UP:
    begin
      dec(edtrack);
      if (edtrack < 0) then edtrack := SSEQ_TRACKS - 1;
      update_edit := 1;
    end;
    SDLK_DOWN:
    begin
      inc(edtrack);
      if (edtrack >= SSEQ_TRACKS) then edtrack := 0;
      update_edit := 1;
    end;
  end;
end;


procedure handle_key_shift(ev: PSDL_Event);
begin
  case (ev^.key.keysym.sym) of
    SDLK_INSERT:
    begin
      block_paste(playpos, edtrack);
    end;
    SDLK_LEFT,
    SDLK_RIGHT,
    SDLK_UP,
    SDLK_DOWN,
    SDLK_PAGEUP,
    SDLK_PAGEDOWN:
    begin
      block_select(playpos, edtrack);
      handle_move_keys(ev);
      block_select(playpos, edtrack);
    end;
  end;
end;


procedure handle_key_ctrl(ev: PSDL_Event);
begin
  case (ev^.key.keysym.sym) of
    SDLK_INSERT,
    SDLK_c:
    begin
      block_copy();
      block_select(-1, -1);
    end;
    SDLK_x:
    begin
      block_copy();
      block_delete();
      block_select(-1, -1);
    end;
    SDLK_v:
    begin
      block_paste(playpos, edtrack);
    end;
    SDLK_o:
    begin
      ask_loadname(songfilename);
    end;
    SDLK_s:
    begin
      ask_savename(songfilename);
    end;
    SDLK_n:
    begin
      ask_new();
    end;
    SDLK_q:
    begin
      ask_exit();
    end;
  end;
end;


procedure handle_key_main(ev: PSDL_Event);
var
  trk : cint;
begin
  case (ev^.key.keysym.sym) of
    SDLK_KP_PLUS,
    SDLK_PLUS:
    begin
      tempo := tempo + 1.0;
      if (tempo > 999.0) then tempo := 999.0;
      sseq_set_tempo(tempo);
      gui_tempo(trunc(tempo));
    end;
    SDLK_KP_MINUS,
    SDLK_MINUS:
    begin
      tempo := tempo - 1.0;
      if (tempo < 0.0) then tempo := 0.0;
      sseq_set_tempo(tempo);
      gui_tempo(trunc(tempo));
    end;
    SDLK_LEFT,
    SDLK_RIGHT,
    SDLK_UP,
    SDLK_DOWN,
    SDLK_PAGEUP,
    SDLK_PAGEDOWN:
    begin
      handle_move_keys(ev);
      block_select(-1, -1);
    end;
    SDLK_F1,
    SDLK_F2,
    SDLK_F3,
    SDLK_F4,
    SDLK_F5,
    SDLK_F6,
    SDLK_F7,
    SDLK_F8,
    SDLK_F9,
    SDLK_F10,
    SDLK_F11,
    SDLK_F12:
    begin
      trk := ev^.key.keysym.sym - SDLK_F1;
      if (edtrack <> trk) then
      begin
        edtrack := trk;
        update_edit := 1;
      end;
      handle_note(edtrack, '9');
    end;
    SDLK_PERIOD,
    SDLK_DELETE:
    begin
      if (sel_start_x >= 0) then
      begin
        block_delete();
        block_select(-1, -1);
      end
      else handle_note(edtrack, '.');
    end;
    SDLK_BACKSPACE:
    begin
      if (sel_start_x >= 0) then
      begin
        block_delete();
        block_select(-1, -1);
      end
      else handle_note(edtrack, #127);
    end;
    SDLK_c:
    begin
      handle_note(edtrack, 'C');
    end;
    SDLK_v:
    begin
      handle_note(edtrack, 'V');
    end;
    SDLK_d:
    begin
      handle_note(edtrack, 'D');
    end;
    SDLK_j:
    begin
      handle_note(edtrack, 'J');
    end;
    SDLK_t:
    begin
      handle_note(edtrack, 'T');
    end;
    SDLK_z:
    begin
      handle_note(edtrack, 'Z');
    end;
    SDLK_0,
    SDLK_1,
    SDLK_2,
    SDLK_3,
    SDLK_4,
    SDLK_5,
    SDLK_6,
    SDLK_7,
    SDLK_8,
    SDLK_9:
    begin
      handle_note(edtrack, Char( Ord('0') + ev^.key.keysym.sym - SDLK_0 ) );
    end;
    SDLK_KP0,
    SDLK_KP1,
    SDLK_KP2,
    SDLK_KP3,
    SDLK_KP4,
    SDLK_KP5,
    SDLK_KP6,
    SDLK_KP7,
    SDLK_KP8,
    SDLK_KP9:
    begin
      handle_note(edtrack, Char( Ord('0') + ev^.key.keysym.sym - SDLK_KP0 ) );
    end;
    SDLK_SPACE:
    begin
      playing := not(playing);
      sseq_pause(not playing);
      gui_status(playing, editing, looping);
    end;
    SDLK_l:
    begin
      looping := not(looping);
      set_loop();
      gui_status(playing, editing, looping);
    end;
    SDLK_r:
    begin
      editing := not(editing);
      update_edit := 1;
      gui_status(playing, editing, looping);
      if not(editing) then block_select(-1, -1);
    end;
    SDLK_m:
    begin
      sseq_mute(edtrack, not(sseq_muted(edtrack)));
    end;
    SDLK_h:
    begin
      switch_page(GUI_PAGE_HELP1);
    end;
    SDLK_TAB:
    begin
      // FPC: acomodate enumerator, circumvent range check error
      if (page = GUI_PAGE__FIRST)
      then page := GUI_PAGE__CYCLE
      else page := GUI_PAGE__FIRST;
      switch_page(page);
    end;
    SDLK_ESCAPE:
    begin
      ask_exit();
    end;
  end;
end;


procedure handle_key_help(ev: PSDL_Event);
begin
  case (ev^.key.keysym.sym) of
    SDLK_ESCAPE:
    begin
      switch_page(GUI_PAGE_MAIN);
    end;
    SDLK_m:
    begin
      switch_page(GUI_PAGE_LOG);
    end;
    SDLK_TAB:
    begin
      // FPC: acomodate enumerator, circumvent range check error
      if page = GUI_PAGE__FIRST 
      then page := GUI_PAGE__CYCLE
      else page := GUI_PAGE__FIRST;
      switch_page(page);
    end;
    else
    begin
      // FPC: acomodate enumerator, circumvent range check error
      if (page = GUI_PAGE_HELP4) 
      then page := GUI_PAGE_HELP1
      else inc(page);
      switch_page(page);
    end;
  end;
end;


procedure handle_key_log(ev: PSDL_Event);
begin
  case (ev^.key.keysym.sym) of
    SDLK_ESCAPE:
    begin
      switch_page(GUI_PAGE_MAIN);
    end;
    SDLK_h:
    begin
      switch_page(GUI_PAGE_HELP1);
    end;
    SDLK_TAB:
    begin
      // FPC: acomodate enumerator, circumvent range check error
      if page = GUI_PAGE__FIRST 
      then page := GUI_PAGE__CYCLE
      else page := GUI_PAGE__FIRST;
      switch_page(page);
    end;
  end;
end;


procedure handle_key(ev: PSDL_Event);
begin
  case (page) of
    GUI_PAGE_MAIN:
    begin
      if ( (ev^.key.keysym.modifier and KMOD_CTRL) <> 0)
      then handle_key_ctrl(ev)
      else 
      if ( (ev^.key.keysym.modifier and KMOD_SHIFT) <> 0)
      then handle_key_shift(ev)
      else handle_key_main(ev);
    end;
    GUI_PAGE_LOG:
    begin
      handle_key_log(ev);
    end;
    GUI_PAGE_HELP1,
    GUI_PAGE_HELP2,
    GUI_PAGE_HELP3,
    GUI_PAGE_HELP4:
    begin
      handle_key_help(ev);
    end;
  end;
end;


{*-------------------------------------------------------------------
    Graphics
-------------------------------------------------------------------*}

procedure update_main(screen: PSDL_Surface; dt: cint);
var
  pos   : cunsigned;
var
  i     : cint;
  n     : Char;
begin
  //* Oscilloscopes */
  gui_oscilloscope(osc_left , dbuffer, plotpos, 240, 8, 192, 128, screen);
  gui_oscilloscope(osc_right, dbuffer, plotpos, 440, 8, 192, 128, screen);

  //* Update song info and editor */
  pos := playpos;
  if (pos <> last_playpos) then
  begin
    gui_tempo(trunc(sseq_get_tempo));
    gui_songpos(pos);
    last_playpos := pos;
    pos := pos and $ffffffe0;
    if ( (pos >= (scrollpos + 32)) or (pos < scrollpos) ) then
    begin
      scrollpos := pos;
      if looping then sseq_loop(scrollpos, scrollpos + 32);
    end;

    update_edit := 1;

    for i := 0 to Pred(SSEQ_TRACKS) do
    begin
      n := sseq_get_note(playpos, i);
      if ( (n >= '0') and (n <= '9') and playing and not(sseq_muted(i) <> 0) )
      then gui_activity(i);
    end;
  end;
  
  if (update_edit <> 0) then
  begin
    gui_songedit(scrollpos, last_playpos, edtrack, editing);
    if (valid_selection) 
    then gui_songselect(sel_start_x - scrollpos, sel_start_y, sel_end_x - scrollpos, sel_end_y)
    else gui_songselect(-1, -1, -1, -1);
    update_edit := 0;
  end;

  gui_draw_activity(dt);
end;


{*-------------------------------------------------------------------
    main()
-------------------------------------------------------------------*}

procedure quit;
begin
  SDL_Quit;
end;


function main(argc: cint; argv: PPChar): cint;
var
  screen    : PSDL_Surface;
  res       : cint;
  last_tick : cint;
var
  ev        : TSDL_Event;
  tick      : cint;
  dt        : cint;
begin
  if (parse_args(argc, argv) < 0) then
  begin
    usage(argv[0]);
    exit(0);
  end;

  if (SDL_Init(0) < 0)
    then exit(-1);

  AddExitProc(@Quit); // atexit(SDL_Quit);
  
//
//  signal(SIGTERM, breakhandler);
//  signal(SIGINT, breakhandler);
//

  if (dbuffer < 0) then dbuffer := abuffer * 3;

  osc_left   := calloc(dbuffer, sizeof(Sint32));
  osc_right  := calloc(dbuffer, sizeof(Sint32));
  playposbuf := calloc(dbuffer, sizeof(cshort));

  if ( not assigned(osc_left) or not assigned(osc_right) or not assigned(playposbuf) ) then
  begin
    WriteLn(stderr, 'Couldn''t allocate delay buffers!');
    SDL_Quit();
    exit(-1);
  end;

  screen := SDL_SetVideoMode(640, 480, 0, sdlflags);
  if not assigned(screen) then
  begin
    WriteLn(stderr, 'Couldn''t open display!');
    SDL_Quit();
    exit(-1);
  end;
  SDL_WM_SetCaption('DT-42 DrumToy', 'DrumToy');

  if not gui_open(screen) then
  begin
    WriteLn(stderr, 'Couldn''t start GUI!');
    SDL_Quit();
    exit(-1);
  end;
  switch_page(GUI_PAGE_MAIN);

  if (sm_open(abuffer) < 0) then
  begin
    WriteLn(stderr, 'Couldn''t start mixer!');
    SDL_Quit();
    exit(-1);
  end;

  sseq_open();
  sm_set_audio_cb(@audio_process);

  //* Try to load song if specified */
  res := -1;

  if assigned(songfilename) then
  begin
    res := load_song(songfilename);
    if ( must_exist and (res < 0) ) then
    begin
      sm_close();
      SDL_Quit();
      WriteLn(stderr, 'Giving up! (Use the -n option to create a new song by name.)');
      exit(-1);
    end;
    if (res >= 0) then
    begin
      playing := true;
      res := 0;
    end;
  end;

  //* If no song was loaded, load default.dt42 instead */
  if (res < 0) then
  begin
    if (load_song('default.dt42') < 0) then
    begin
      sm_close();
      SDL_Quit();
      WriteLn(stderr, 'Couldn''t load default song!');
      exit(-1);
    end;
    gui_message('Welcome to DT-42 ' + VERSION + '.  ('#&005'H for '#&005'Help!)', -1);
  end;

  gui_status(playing, editing, looping);

  sseq_pause(not playing);

  last_tick := SDL_GetTicks();

  while not(die) do
  begin
    tick      := SDL_GetTicks();
    dt        := tick - last_tick;
    last_tick := tick;

    //* Handle GUI events */
    while (SDL_PollEvent(@ev) <> 0) do
    begin
      case (ev.type_) of
        SDL_KEYDOWN:
        begin
          case (dialog_mode) of
            DM_NORMAL       : handle_key(@ev);
            DM_ASK_EXIT     : handle_key_ask_exit(@ev);
            DM_ASK_NEW      : handle_key_ask_new(@ev);
            DM_ASK_LOADNAME,
            DM_ASK_SAVENAME : handle_key_ask_filename(@ev);
          end; // case
        end;
        SDL_QUITEV:
        begin
          ask_exit();
        end;
      end;
    end;

    {
    * Update the calculated current play position.
    *   We know that the mixer generates 44100 samples/s.
    *   Thus, plotpos should advance 44100 samples/s too.
    *   osc_process() will resync plotpos every time it
    *   runs, so it doesn't drift off over time.
    }
    plotpos := plotpos + trunc(44100 * dt / 1000);

    //* Figure out current playback song position */
    playpos := playposbuf[plotpos mod dbuffer];

    //* Update the screen */
    case (page) of
      GUI_PAGE_MAIN: update_main(screen, dt);
      GUI_PAGE_LOG,
      GUI_PAGE_HELP1,
      GUI_PAGE_HELP2,
      GUI_PAGE_HELP3,
      GUI_PAGE_HELP4:
      begin
        { do nothing }
      end;
    end;

    last_playpos := playpos;

    //* Refresh dirty areas of the screen */
    gui_refresh();

    //* Try to look less like a CPU hog */
    SDL_Delay(10);
  end;

  sm_close();
  sseq_close();
  gui_close();
  SDL_Quit();
  free(osc_left);
  free(osc_right);
  free(playposbuf);
  free(songfilename);
  exit(0);
end;


begin
  ExitCode := Main(argc, argv);
end.
