unit sseq;

{$MODE OBJFPC}{$H+}
{$RANGECHECKS ON}

interface

uses
  ctypes;

const
  //* Number of sequencer tracks */
  SSEQ_TRACKS   = 16;


  procedure sseq_open;
  procedure sseq_close;

  function  sseq_load_song(const fn: PChar): cint;
  function  sseq_save_song(const fn: PChar): cint;
  procedure sseq_clear;

  //* Real time control */
  function  sseq_get_tempo: cfloat;
  procedure sseq_set_tempo(bpm: cfloat);
  procedure sseq_pause(pause: boolean);
  function  sseq_get_position: cint;
  function  sseq_get_next_position: cint;
  procedure sseq_set_position(pos: cunsigned);
  procedure sseq_loop(start: cint; ending: cint);
  procedure sseq_play_note(trk: cint; note: Char);
  procedure sseq_mute(trk: cint; do_mute: cint);
  function  sseq_muted(trk: cint): cint;

  //* Editing */
  procedure sseq_add(track: cint; const data: PChar);
  function  sseq_get_note(pos: cunsigned; track: cunsigned): Char;
  procedure sseq_set_note(pos: cunsigned; track: cunsigned; note: Char);


implementation

uses
  chelpers, dtversion, smixer, SDL;

const
  SONG_FILE_VERSION = 1;


type
  //* A sequencer track */
  PSSEQ_track = ^TSSEQ_track;
  TSSEQ_track = 
  record
    data    : PChar;
    length  : cint;
    skip    : cint;
    mute    : cint;
    decay   : cfloat;
    lvol    : cfloat;
    rvol    : cfloat;
  end;


type
  //* A song (file) tag */
  PSSEQ_tag = ^TSSEQ_tag;
  TSSEQ_tag =
  record
    next    : PSSEQ_tag;
    &label  : PChar;
    data    : PChar;
  end;


  //* A simple pattern sequencer */
  PSSEQ_sequencer = ^TSSEQ_sequencer;
  TSSEQ_sequencer =
  record
    tracks          : array[0..Pred(SSEQ_TRACKS)] of TSSEQ_track;
    tags            : PSSEQ_tag;
    last_position   : cint;
    position        : cint;
    interval        : cint;
    loop_start      : cint;
    loop_end        : cint;
  end;


var
  seq       : TSSEQ_sequencer;
  paused    : boolean           = false;


{
* Try to read an integer value.
* Returns -1 if the string does not contain a valid
* decimal integer value.
}
function get_index(const s: PChar; v: pcint): cint;
var
  i : cint;
begin
  if not(s^ <> #0) 
  then exit(-1);    //* Empty string! */

  i := 0;
  while (s[i] <> #0) do
  begin
    if (   ( (s[i] < '0') or (s[i] > '9') ) and ( s[i] <> '-') )
    then exit(-1);
    inc(i);
  end;
  v^ := atoi(s);

  exit( 0 );
end;


procedure _set_tempo(bpm: cfloat);
begin
  if (bpm <= 0.0)
  then seq.interval := 0
  else seq.interval := trunc(44100.0 / bpm * 60.0 / 4.0);
  sm_force_interval(seq.interval);
end;


procedure _set_defaults;
var
  i : cint;
begin
  _set_tempo(120.0);
  for i := 0 to Pred(SSEQ_TRACKS) do
  begin
    seq.tracks[i].decay := 0.0;
    seq.tracks[i].lvol := 1.0;
    seq.tracks[i].rvol := 1.0;
  end;
end;


procedure _play_note(trk: cint; note: char);
var
  vel: cfloat;
begin
  vel := (ord(note) - ord('0')) * (1.0 / 9.0);
  if (vel <> 0.0) 
  then vel := 0.3 + vel * 0.7;
  sm_play(trk, trk, vel * seq.tracks[trk].lvol, vel * seq.tracks[trk].rvol);
  sm_decay(trk, seq.tracks[trk].decay);
end;


procedure sseq_mute(trk: cint; do_mute: cint);
begin
  seq.tracks[trk].mute := do_mute;
end;


function  sseq_muted(trk: cint): cint;
begin
  exit( seq.tracks[trk].mute );
end;


//* Find specified tag by label */
function  find_tag(const &label: PChar): PSSEQ_tag;
var
  tag : PSSEQ_tag;
begin
  tag := seq.tags;
  while assigned(tag) do
  begin
    if not(strcmp(tag^.&label, &label) <> 0)
    then exit(tag);
    tag := tag^.next;
  end;
  exit( nil );
end;


//* Add a new tag, even if there are others with the same label */
function  add_tag(const &label: PChar; const data: PChar): PSSEQ_tag;
var
  tag   : PSSEQ_tag;
  lt    : PSSEQ_tag;
begin
  tag := malloc(sizeof(TSSEQ_tag));

  if not assigned(tag) then exit( nil );

  tag^.&label := strdup(&label);
  tag^.data := strdup(data);
  tag^.next := nil;
  if not assigned(seq.tags)
  then seq.tags := tag
  else
  begin
    lt := seq.tags;
    while assigned(lt^.next)
      do lt := lt^.next;
    lt^.next := tag;
  end;
  exit( tag );
end;


//* Set or create tag 'label' and assign 'data' to it */
function  set_tag(const &label: PChar; const data: PChar): PSSEQ_tag;
var
  tag : PSSEQ_tag;
begin
  tag := find_tag(&label);
  if assigned(tag) then
  begin
    free(tag^.data);
    tag^.data := strdup(data);
    exit( tag );
  end;
  exit( add_tag(&label, data) );
end;


procedure remove_tags;
var
  tag: PSSEQ_tag;
begin
  while assigned(seq.tags) do
  begin
    tag := seq.tags;
    seq.tags := tag^.next;
    free(tag^.&label);
    free(tag^.data);
    free(tag);
  end;
end;


procedure _clear;
var
  i : cint;
begin
  remove_tags();
  _set_defaults();
  for i := 0 to Pred(SSEQ_TRACKS) do 
  begin
    free(seq.tracks[i].data);
    seq.tracks[i].data   := nil;
    seq.tracks[i].length := 0;
    seq.tracks[i].mute   := 0;
    sm_unload(i);
  end;
end;


procedure sseq_clear;
begin
  SDL_LockAudio();
  _clear();
  SDL_UnlockAudio();
end;


function  load_line(const &label: PChar; const data: PChar): cint;
var
  i : cint;
begin
  if (&label[0] = 'I') then
  begin
    //* Instrument file reference? */
    if (get_index(&label + 1, @i) >= 0) then
    begin
      add_tag(&label, data);
      exit( sm_load(i, data) );
    end;
  end
  else 
  
  if (&label[0] = 'S') then
  begin
    //* Synth instrument definition? */
    if (get_index(&label + 1, @i) >= 0) then
    begin
      add_tag(&label, data);
      exit( sm_load_synth(i, data) );
    end;
  end
  else 
  
  if (get_index(&label, @i) >= 0) then
  begin
    sseq_add(i, data);  //* Track data */
    exit( 0 );
  end;

  //* Check for tags */
  i := 0;
  if not(strcmp(&label, 'CREATOR') <> 0)
  then WriteLn('        File creator: ', data)
  else 
  if not(strcmp(&label, 'VERSION') <> 0)
  then WriteLn('File creator version: ', data)
  else 
  if not(strcmp(&label, 'AUTHOR') <> 0)
  then WriteLn('         Song author: ', data)
  else 
  if not(strcmp(&label, 'TITLE') <> 0)
  then WriteLn('          Song title: ', data)
  else
  begin
    WriteLn(stderr, 'WARNING: Unknown tag "', &label, '"');
    i := 1;
  end;

  //* Store the tag, so we can write it back when saving */
  add_tag(&label, data);
  exit( i );
end;


function  _load_song(const fn: PChar): cint;
var
  i      : cint;
  buf    : PChar;
  size   : cint;
  f      : File;
  n      : int64;
  &label : PChar;
  data   : PChar;

begin
  _clear();

  WriteLn('Loading Song "', fn, '"...');

  //* Read file */
  {$I-}
  AssignFile(f, fn);
  Reset(f,1);

  if (IOResult <> 0) then
  begin
    WriteLn(stderr, 'Could not open song "', fn, '": ', strerror(errno));
    exit( -1 );
  end;

  size := filesize(f);
  if (size < 0) then
  begin
    WriteLn(stderr, 'Could not load song "', fn, '": ', strerror(errno));
    CloseFile(f);
    exit(-1);
  end;

  seek(f, 0);
  buf := malloc(size + 1);
  if not assigned(buf) then
  begin
    WriteLn(stderr, 'Could not load song "', fn, '": ', 'Out of memory!');
    CloseFile(f);
    exit(-1);
  end;
  buf[size] := #0;  //* Safety NUL terminator */

  BlockRead(f, buf[0], size, n);
  if (n <> size) then
  begin
    WriteLn(stderr, 'Could not load song "', fn, '": ', strerror(errno));
    CloseFile(f);
    exit(-1);
  end;
  CloseFile(f);
  {$I+}

  //* Check format */
  if (strncmp(buf, 'DT42', 4) <> 0) then
  begin
    WriteLn(stderr, '"', fn, '"', ' is not a DT42 file!');
    free(buf);
    exit( -1 );
  end;

  if (strncmp(@buf[4], 'SONG', 4) <> 0) then
  begin
    WriteLn(stderr, '"', fn, '"', ' is not a SONG file!');
    free(buf);
    exit(-1);
  end;

  if ( atoi(@buf[8]) > SONG_FILE_VERSION ) then
  begin
    WriteLn(stderr, '"', fn, '"', ' was created by a newer version of DT-42!');
    free(buf);
    exit(-1);
  end;

  //* First byte after header */
  i := 8;
  while ( (i < size) and (buf[i] <> #10) ) do inc(i);

  //* Parse! */
  while (i < size) do
  begin
    //* Find start of a label */
    while ( (i < size) and (buf[i] < ' ') ) do inc(i);

    if (i >= size) then break;  //* EOF - Done! */
    &label := buf + i;

    //* Find end of label */
    while ( (i < size) and (buf[i] <> ':') ) do inc(i);

    if (i >= size) then
    begin
      WriteLn(stderr, 'Could not load song "', fn, '": Tag parse error in label!');
      free(buf);
      exit( -1 );
    end;
    buf[i] := #0;   //* Terminate. */

    //* Find start of data */
    inc(i);
    data := buf + i;

    //* Find end of data (EOLN) */
    while ( (i < size) and (buf[i] <> #10) ) do inc(i);

    if (i >= size) then
    begin
      WriteLn(stderr, 'Could not load song "', fn, '": Tag parse error in data!');
      free(buf);
      exit(-1);
    end;
    buf[i] := #0;   //* Terminate. */

    //* Process the tag! */
    if ( load_line(&label, data) < 0) then
    begin
      WriteLn(stderr, 'Could not load song "', fn, '": ', 'Critical parse error!');
      free(buf);
      exit( -1 );
    end;
  end;

  WriteLn('Song "', fn, '" loaded!');
  free(buf);
  exit(0);
end;


function sseq_load_song(const fn: PChar): cint;
var
  res : cint;
begin
  SDL_LockAudio();
  res := _load_song(fn);
  SDL_UnlockAudio();
  exit(res);
end;


function  sseq_save_song(const fn: PChar): cint;
var
  t     : cint;
  errs  : cint;
  tag   : PSSEQ_tag;
  f     : TextFile;
begin
  errs := 0;

  WriteLn('Saving Song "', fn ,'"...');

  //* Open file */
  {$I-}
  AssignFile(f, fn);
  Rewrite(f);

  if (IOResult <> 0) then
  begin
    WriteLn(stderr, 'Could not open/create file "', fn, '": ', strerror(errno));
    exit( -1 );
  end;

  //* Write header */
  WriteLn(f, 'DT42SONG', SONG_FILE_VERSION);
  if (IOResult <> 0) then inc(errs);

  //* Set application metatags */
  set_tag('CREATOR', 'DT-42 DrumToy');
  set_tag('VERSION', VERSION);

  //* Fill in any missing info tags */
  if not assigned(find_tag('AUTHOR')) then set_tag('AUTHOR', 'Unknown');
  if not assigned(find_tag('TITLE'))  then set_tag('TITLE', fn);

  //* Write tags */
  tag := seq.tags;
  while assigned(tag) do
  begin
    WriteLn(f, tag^.&label, ':', tag^.data);
    if (IOResult <> 0) then inc(errs);
    tag := tag^.next;
  end;
  WriteLn(f);
  if (IOResult <> 0) then inc(errs);

  //* Write track data */
  for t := 0 to Pred(SSEQ_TRACKS) do
  begin
    {
    * TODO: Nicer formatting...
    }
    if not assigned(seq.tracks[t].data) then continue;
    WriteLn(f, t, ':', seq.tracks[t].data);
    if (IOResult <> 0) then inc(errs);
  end;    
  {$I+}
  if (errs <> 0) then
  begin
    WriteLn(stderr, 'Error writing "', fn, '": ', strerror(errno));
    CloseFile(f);
    exit(-1);
  end;

  WriteLn('Song "', fn, '" saved!');
  CloseFile(f);
  exit( 0 );
end;


{
* Run the sequencer time for 'frames' sample frames,
* and execute any events for that time period.
}
function  sseq_process: cunsigned;
var
  again     : cint;
  t         : cint;
  newpos    : cint;
  d         : PChar;
  skip      : cint;
  v         : cint;
begin
  seq.last_position := seq.position;
  if ( paused or (not(seq.interval <> 0) ) )
  then exit(16);
  while (true) do
  begin
    again := 0;
    newpos := seq.position + 1;
    if (seq.position = 0)
    then _set_defaults;

    if (seq.loop_end >= 0) then
    begin
      if (newpos >= seq.loop_end) then
      begin
        if (seq.loop_start >= 0)
        then newpos := seq.loop_start
        else newpos := 0;
      end;
    end;

    for t := 0 to Pred(SSEQ_TRACKS) do
    begin
      d := seq.tracks[t].data + seq.position;
      skip := seq.tracks[t].mute;
      if (seq.tracks[t].skip <> 0) then
      begin
        dec(seq.tracks[t].skip);
        skip := 1;
      end;

      if (seq.position >= seq.tracks[t].length)
      then continue;
      case (d^) of
        //* Note */
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9':
        begin
          //* Don't play command arguments! */
          if (skip <> 0)
          then break;
          _play_note(t, d^);
        end;
        //* Cut note */
        'C':
        begin
          sm_decay(t, 0.9);
        end;
        //* Set note decay */
        'D':
        begin
          seq.tracks[t].decay := ( Ord(d[1]) - Ord('0')) * 0.1;
          seq.tracks[t].skip := 1;
        end;
        //* Jump to position */
        'J':
        begin
          v := ( Ord(d[1]) - Ord('0') ) * 100;
          v := v + ( ( Ord(d[2]) - Ord('0') ) * 10 );
          v := v + ( ( Ord(d[3]) - Ord('0') ) );
          newpos := v;
          again := 2;
        end;
        //* Set tempo */
        'T':
        begin
          v := ( Ord(d[1]) - Ord('0') ) * 100;
          v := v + ( ( Ord(d[2]) - Ord('0') ) * 10 );
          v := v + ( ( Ord(d[3]) - Ord('0') ) );
          _set_tempo(v);
          seq.tracks[t].skip := 3;
        end;
        //* Set volume/balance */
        'V':
        begin
          seq.tracks[t].lvol := (Ord(d[1]) - Ord('0')) * (1.0 / 9.0);
          seq.tracks[t].rvol := (Ord(d[2]) - Ord('0')) * (1.0 / 9.0);
          seq.tracks[t].skip := 2;
        end;
        //* Zero time step */
        'Z':
        begin
          again := 1;
        end;
      end;
    end;

    seq.position := newpos;
    if not(again <> 0)
    then break;
    {
    * Prevent the skip feature from killing notes after a jump.
    * Note that this will break if you jump to some place where
    * you land in the middle of the arguments to a command!
    * (But that probably wouldn't play correctly anyway, so who
    * cares?)
    }
    if (again = 2) then
    begin
      for t := 0 to Pred(SSEQ_TRACKS) 
        do seq.tracks[t].skip := 0;
    end;
  end;
  exit( seq.interval );
end;


procedure sseq_pause(pause: boolean);
begin
  paused := pause;
end;


procedure sseq_set_tempo(bpm: cfloat);
begin
  SDL_LockAudio();
  _set_tempo(bpm);
  SDL_UnlockAudio();
end;


function sseq_get_tempo: cfloat;
begin
  exit( 44100.0 / seq.interval * 60.0 / 4.0 );
end;


procedure sseq_play_note(trk: cint; note: Char);
begin
  SDL_LockAudio();
  _play_note(trk, note);
  SDL_UnlockAudio();
end;


function  sseq_get_position: cint;
begin
  {
  * Note: We don't want seq.position, because that's
  * actually the NEXT step in the sequence, whereas
  * we want the CURRENTLY PLAYING step.
  }
  exit( seq.last_position );
end;


function  sseq_get_next_position: cint;
begin
  exit( seq.position );
end;


procedure sseq_set_position(pos: cunsigned);
begin
  seq.position := pos;
end;


procedure sseq_loop(start: cint; ending: cint);
begin
  SDL_LockAudio();
  seq.loop_start := start;
  seq.loop_end := ending;
  SDL_UnlockAudio();
end;


function  sseq_get_note(pos: cunsigned; track: cunsigned): Char;
begin
  if (track >= SSEQ_TRACKS)            then exit(#255);
  if (pos >= seq.tracks[track].length) then exit(#255);
  exit(seq.tracks[track].data[pos]);
end;


procedure sseq_set_note(pos: cunsigned; track: cunsigned; note: Char);
var
  nt: PChar;
begin
  SDL_LockAudio();
  if (track < SSEQ_TRACKS) then
  begin
    if (pos >= seq.tracks[track].length) then
    begin
      nt := realloc(seq.tracks[track].data, pos + 2);
      if not assigned(nt) then
      begin
        SDL_UnlockAudio();
        exit;
      end;
      memset(nt + seq.tracks[track].length, Ord('.'), pos - seq.tracks[track].length);
      seq.tracks[track].data := nt;
      seq.tracks[track].data[pos + 1] := #0;
      seq.tracks[track].length := pos + 1;
    end;
    seq.tracks[track].data[pos] := note;
  end;
  SDL_UnlockAudio();
end;


procedure sseq_open;
begin
  memset(@seq, 0, sizeof(seq));
  sm_set_control_cb(@sseq_process);
  sseq_loop(-1, -1);
  sseq_clear();
end;


procedure sseq_close;
begin
  sm_set_control_cb(nil);
  sseq_clear();
  memset(@seq, 0, sizeof(seq));
end;


procedure sseq_add(track: cint; const data: PChar);
var
  new_track : PChar;
begin
  SDL_LockAudio();
  if not assigned(seq.tracks[track].data)
  then seq.tracks[track].data := strdup(data)
  else
  begin
    new_track := malloc(strlen(seq.tracks[track].data) + strlen(data) + 1);
    strcpy(new_track, seq.tracks[track].data);
    strcat(new_track, data);
    free(seq.tracks[track].data);
    seq.tracks[track].data := new_track;
  end;
  seq.tracks[track].length := strlen(seq.tracks[track].data);
  SDL_UnlockAudio();
end;

end.
