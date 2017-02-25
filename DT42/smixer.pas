unit smixer;

{$MODE OBJFPC}{$H+}
{$RANGECHECKS ON}

interface

uses
  ctypes, chelpers;

const
  {
  * Maximum number of sample frames that will ever be
  * processed in one go. Audio processing callbacks
  * rely on never getting a 'frames' argument greater
  * than this value.
  }
  SM_MAXFRAGMENT    = 256;

  //* Number of slots for loaded waveforms */
  SM_SOUNDS         = 16;

  //* Number of playback voices */
  SM_VOICES         = 16;

  SM_C0             = 16.3515978312874;


{*--------------------------------------------------------
    Application Interface
--------------------------------------------------------*}

  function  sm_open(buffer: cint): cint;
  procedure sm_close;
  function  sm_load(sound: cint; const fil: PChar): cint;
  function  sm_load_synth(sound: cint; const def: PChar): cint;
  procedure sm_unload(sound: cint);

  {
  * IMPORTANT! IMPORTANT! IMPORTANT! IMPORTANT! IMPORTANT!
  *
  * The callbacks installed by the functions below
  * will run in the SDL audio callback context!
  * Thus, you must be very careful what you do in
  * these callbacks, and what data you touch.
  *
  * IMPORTANT! IMPORTANT! IMPORTANT! IMPORTANT! IMPORTANT!
  }


type
  {
  * Install a control tick callback. This will be called
  * once as soon as possible, and then the callback's return
  * value determines how many audio samples to process before
  * the callback is called again.
  *    If the callback returns 0, it is uninstalled and never
  * called again.
  *    Use sm_set_control_cb(NULL) to remove any installed
  * callback instantly.
  }
  sm_control_cb = function: cunsigned;
  procedure sm_set_control_cb(cb: sm_control_cb);  

type
  {
  * Install an audio processing callback. This callback runs
  * right after the voice mixer, and may be used to analyze
  * or modify the audio stream before it is converted and
  * passed on to the audio output buffer.
  *    The buffer handed to the callback is in 32 bit signed
  * stereo format, and the 'frames' argument is the number
  * of full stereo samples to process.
  *    Use sm_set_audio_cb(NULL) to remove any installed
  * callback instantly.
  }
  sm_audio_cb = procedure(buf: PSint32; frames: cint);
  procedure sm_set_audio_cb(cb: sm_audio_cb);


{*--------------------------------------------------------
    Real Time Control Interface
    (Use only from inside a control callback,
    or with the SDL audio thread locked!)
--------------------------------------------------------*}

  //* Start playing 'sound' on 'voice' at L/R volumes 'lvol'/'rvol' */
  procedure sm_play(voice: cunsigned; sound: cunsigned; lvol: cfloat; rvol: cfloat);

  //* Set voice decay speed */
  procedure sm_decay(voice: cunsigned; decay: cfloat);

  //* If the pending interval > interval, cut it short. */
  procedure sm_force_interval(interval: cunsigned);

  //* Get the pending interval length */
  function  sm_get_interval: cint;

  //* Get number of frames left to next control callback */
  function  sm_get_next_tick: cint;


implementation

uses
  SDL, phelpers;


type
  //* One sound */
  PSM_Sound = ^TSM_Sound;
  TSM_Sound = record
    data    : PUint8;   //* Waveform or synth definition */
    length  : Uint32;   //* Length in samples (0 for synth) */
    pitch   : cfloat;   //* Pitch (60.0 <==> middle C) */
    decay   : cfloat;   //* Base decay speed */
    fm      : cfloat;   //* Synth FM depth */
  end;

  //* One playback voice */
  PSM_Voice = ^TSM_Voice;
  TSM_Voice = record
    sound   : cint;     //* Index of playing sound, or -1 */
    position: cint;     //* Play position (sample count) */
    lvol    : cint;     //* 8:24 fixed point */
    rvol    : cint;
    decay   : cint;     //* (16):16 fixed point */
  end;


var
  sounds    : array[0..Pred(SM_SOUNDS)] of TSM_Sound;
  voices    : array[0..Pred(SM_VOICES)] of TSM_Voice;
  audiospec : TSDL_AudioSpec;

  //* Internal mixing buffer; 0 dB level is at 24 bits peak. */
  mixbuf    : PSint32 = nil;

  //* Current control interval duration */
  interval  : cint = 0;

  //* Sample frames left until the next control tick */
  next_tick : cint = 0;

  control_callback  : sm_control_cb = nil;
  audio_callback    : sm_audio_cb   = nil;


function  sm_get_interval: cint;
begin
  exit( interval );
end;


function  sm_get_next_tick: cint;
begin
  exit( next_tick );
end;


//* Start playing 'sound' on 'voice' at L/R volumes 'lvol'/'rvol' */
procedure sm_play(voice: cunsigned; sound: cunsigned; lvol: cfloat; rvol: cfloat);
var
  decay : cfloat;
begin
  if ( (voice >= SM_VOICES) or (sound >= SM_SOUNDS) ) then exit;
  voices[voice].sound := sound;
  voices[voice].position := 0;
  lvol := lvol * (lvol * lvol);
  rvol := rvol * (rvol * rvol);
  voices[voice].lvol := trunc(lvol * 16777216.0);
  voices[voice].rvol := trunc(rvol * 16777216.0);
  if not (sounds[sound].length <> 0) then
  begin
    decay := sounds[sound].decay;
    decay := decay * decay;
    decay := decay * 0.00001;
    voices[voice].decay := trunc(decay * 16777216.0);
  end;
end;


procedure sm_decay(voice: cunsigned; decay: cfloat);
var
  sound : cint;
begin
  sound := voices[voice].sound;
  if (sound < 0) then exit;

  if not(sounds[sound].length <> 0)
  then decay := decay + sounds[sound].decay;

  decay := decay * decay;
  decay := decay * 0.00001;
  voices[voice].decay := trunc(decay * 16777216.0);
end;


//* Mix all voices into a 32 bit (8:24) stereo buffer */
procedure sm_mixer(buf: PSint32; frames: cint);
var
  vi, s : cint;
  v     : PSM_voice;
  sound : PSM_sound;
  d     : PSint16;
  v1715 : cint;

  f     : cdouble;
  ff    : cdouble;
  fm    : cdouble;
  modulo : cfloat;
  w     : cint;
begin
  //* Clear the buffer */
  memset(buf, 0, frames * sizeof(Sint32) * 2);

  //* For each voice... */
  for vi := 0 to Pred(SM_VOICES) do
  begin
    v := @voices[vi];

    if (v^.sound < 0) then continue;

    sound := @sounds[v^.sound];
    if (sound^.length <> 0) then
    begin
      //* Sampled waveform */
      d := PSint16(sound^.data);
      for s := 0 to Pred(frames) do
      begin
        if (v^.position >= sound^.length) then
        begin
          v^.sound := -1;
          break;
        end;
        // FPC: Use sar
        v1715 := sarLongInt(v^.lvol, 9);
        // FPC: Use sar
        buf[s * 2] := buf[s * 2] + sarLongInt( d[v^.position] * v1715, 7 );
        // FPC: Use sar
        v1715 := sarLongInt(v^.rvol, 9);
        // FPC: Use sar
        buf[s * 2 + 1] := buf[s * 2 + 1] + sarLongInt( d[v^.position] * v1715, 7);
        // FPC: Use sar
        v^.lvol := v^.lvol - ( sarLongInt( SarLongInt(v^.lvol, 8) * v^.decay, 8 ) );
        // FPC: Use sar
        v^.rvol := v^.rvol - ( sarLongInt( sarLongInt(v^.rvol, 8) * v^.decay, 8 ) );

        inc(v^.position);
      end;
    end
    else
    begin
      //* Synth voice */
      f := SM_C0 * pow(2.0, sound^.pitch / 12.0);
      ff := M_PI * 2.0 * f / 44100.0;
      fm := sound^.fm * 44100.0 / f;
      for s := 0 to Pred(frames) do
      begin
        modulo := sin(v^.position * ff) * fm;
        w := trunc(sin((v^.position + modulo) * ff) * 32767.0);
        // FPC: Use sar
        v1715 := sarLongInt(v^.lvol, 9);
        // FPC: Use sar
        buf[s * 2] := buf[s * 2] + sarLongInt(w * v1715, 7);
        // FPC: Use sar
        v1715 := sarLongInt(v^.rvol, 9);
        // FPC: Use sar
        buf[s * 2 + 1] := buf[s * 2 + 1] + sarLongInt(w * v1715, 7);
        // FPC: Use sar
        v^.lvol := v^.lvol - ( sarLongInt( sarLongInt(v^.lvol, 8) * v^.decay, 8) );
        // FPC: Use sar
        v^.rvol := v^.rvol - ( sarLongInt( sarLongInt(v^.rvol, 8) * v^.decay, 8) );

        inc(v^.position);
      end;

      v^.lvol := v^.lvol - 16;
      if (v^.lvol < 0) then v^.lvol := 0;

      v^.rvol := v^.rvol - 16;
      if (v^.rvol < 0) then v^.rvol := 0;
    end;
  end;
end;


//* Convert from 8:24 (32 bit) to 16 bit (stereo) */
procedure sm_convert(input: PSint32; output: PSint16; frames: cint);
var
  i : cint;
begin
  i := 0;
  frames := frames * 2;  //* Stereo! */
  while (i < frames) do
  begin
    // FPC: Use sar
    output[i] := sarLongInt(input[i], 8);
    inc(i);
    // FPC: Use sar
    output[i] := sarLongInt(input[i], 8);
    inc(i);
  end;
end;


procedure sm_callback(ud: pointer; stream: PUint8; len: cint); cdecl;
var
  frames: cint;
begin
  //* 2 channels, 2 bytes/sample = 4 bytes/frame */
  len := len div 4;
  while (len <> 0) do
  begin
    //* Audio processing */
    frames := next_tick;
    if (frames > SM_MAXFRAGMENT) then frames := SM_MAXFRAGMENT;
    if (frames > len)            then frames := len;

    sm_mixer(mixbuf, frames);

    if assigned(audio_callback) then audio_callback(mixbuf, frames);
    sm_convert(mixbuf, PSint16(stream), frames);
    stream := stream + (frames * sizeof(Sint16) * 2);
    len := len - frames;

    //* Control processing */
    next_tick := next_tick - frames;
    if not(next_tick<>0) then
    begin
        if assigned(control_callback) then
        begin
          next_tick := control_callback();
          interval  := next_tick; 
          if not(next_tick <> 0) then
          begin
            control_callback := nil;
            interval := 10000; next_tick := 10000;
          end;
        end
        else
        begin
          interval := 10000; next_tick := 10000;
        end;
    end;
  end;
end;


function  sm_open(buffer: cint): cint;
var
  asp   : TSDL_AudioSpec;
  i     : cint;
begin
  // FPC: be explicit
  memset(@sounds[0], 0, Length(sounds) * SizeOf(TSM_Sound));
  // FPC: be explicit
  memset(@voices[0], 0, Length(voices) * SizeOf(TSM_Voice));

  for i := 0 to Pred(SM_VOICES)
    do voices[i].sound := -1;

  mixbuf := malloc(SM_MAXFRAGMENT * sizeof(Sint32) * 2);
  if not assigned(mixbuf) then
  begin
    WriteLn(stderr, 'Couldn''t allocate mixing buffer!');
    exit( -1 );
  end;

  if (SDL_InitSubSystem(SDL_INIT_AUDIO) < 0) then
  begin
    WriteLn(stderr, 'Couldn''t init SDL audio: ', SDL_GetError);
    exit( -2 );
  end;

  asp.freq := 44100;
  asp.format := AUDIO_S16SYS;
  asp.channels := 2;
  asp.samples := buffer;
  asp.callback := @sm_callback;
  if (SDL_OpenAudio(@asp, @audiospec) < 0) then
  begin
    WriteLn(stderr, 'Couldn''t open SDL audio: ', SDL_GetError);
    exit( -3 );
  end;

  if (audiospec.format <> AUDIO_S16SYS) then
  begin
    WriteLn(stderr, 'Wrong audio format!');
    exit( -4 );
  end;

  SDL_PauseAudio(0);
  exit( 0 );
end;


procedure sm_close;
var
  i: cint;
begin
  SDL_CloseAudio();
  for i := 0 to Pred(SM_SOUNDS) 
    do sm_unload(i);
  // FPC: be explicit
  memset(@voices[0], 0, Length(voices) * SizeOf(TSM_Sound) );
  free(mixbuf);
end;


procedure flip_endian(data: PUint8; length: cint);
var
  i : cint;
  x : cint;
begin
  i := 0;
  while (i < Length) do
  begin
    x := data[i];
    data[i] := data[i + 1];
    data[i + 1] := x;
    inc(i, 2);
  end;
end;


procedure sm_unload(sound: cint);
begin
  SDL_LockAudio();
  if (sounds[sound].data <> nil) then
  begin
    if (sounds[sound].length <> 0)
      then SDL_FreeWAV(sounds[sound].data)
      else free(sounds[sound].data);
  end;
  memset(@sounds[sound], 0, sizeof(TSM_sound));
  SDL_UnlockAudio();
end;


function  sm_load(sound: cint; const fil: PChar): cint;
var
  failed    : boolean = false;
  spec      : TSDL_AudioSpec;
begin
  sm_unload(sound);
  SDL_LockAudio();

  if (SDL_LoadWAV(fil, @spec, @sounds[sound].data, @sounds[sound].length) = nil) then
  begin
    SDL_UnlockAudio();
    exit( -1 );
  end;

  if (spec.freq <> 44100)
  then WriteLn(stderr, 'WARNING: File "', fil , '" is not 44.1 kHz. Might sound weird...');

  if (spec.channels <> 1) then
  begin
    WriteLn(stderr, 'Only mono sounds are supported!');
    failed := true;
  end;

  case (spec.format) of
    AUDIO_S16LSB,
    AUDIO_S16MSB:
    begin
      if (spec.format <> AUDIO_S16SYS)
        then flip_endian(sounds[sound].data, sounds[sound].length);
    end;
    else
    begin
      WriteLn(stderr, 'Unsupported sample format!');
      failed := true;
    end;
  end;

  if (failed) then
  begin
    SDL_FreeWAV(sounds[sound].data);
    sounds[sound].data := nil;
    sounds[sound].length := 0;
    SDL_UnlockAudio();
    exit( -2 );
  end;

  sounds[sound].length := sounds[sound].length div 2;
  SDL_UnlockAudio();
  exit( 0 );
end;


function sm_load_synth(sound: cint; const def: PChar): cint;
var
  res   : cint = 0;
  n     : integer;
  s, f  : string;
  i     : integer;
begin
  sm_unload(sound);
  SDL_LockAudio();

  sounds[sound].data := pointer(strdup(def));

  if (strncmp(def, 'fm2 ', 4) = 0) then
  begin
    {
    * FPC Note:
    * Due to the incompetence and complete unuserfriendly usefulness of FPC's 
    * sscanf() function, we dumped its use here.
    * This wishy-washy solution might be daft but at least it works.
    }
    // copy PChar over to string
    s := def;
    // determine the number of words separated by a space character
    n := WordCount(s, [' ']);
    // FM sounds require exactly 4 words
    if (n = 4) then 
    begin
      // skip first word "fm2" and proces the other words
      for i := 2 to 4 do
      begin
        f := ExtractWord(i, s, [' ']);
        // *sight* FPC requires decimalseparator for indicating fractions.
        f := StringReplace(f, '.', FormatSettings.DecimalSeparator, []);
        
        if (length(f) > 0) and (f[1] = FormatSettings.DecimalSeparator) then f := '0' + f;
        case i of
          2 : sounds[sound].pitch := StrToFloat(f);  // 2-nd word is the pitch
          3 : sounds[sound].fm    := StrToFloat(f);  // 3-th word is the Frequency Modulation
          4 : sounds[sound].decay := StrToFloat(f);  // 4-th word is the decay
        end;
      end;
    end 
    else
    begin
      WriteLn(stderr, 'fm2: Too few parameters!');
      res := -2;
    end;
  end
  else
  begin
    WriteLn(stderr, 'Unknown instrument type!');
    res := -1;
  end;

  if (res < 0) then
  begin
    free(sounds[sound].data);
    sounds[sound].data := nil;
    sounds[sound].length := 0;
  end;
  SDL_UnlockAudio();
  exit( res );
end;


procedure sm_set_control_cb(cb: sm_control_cb);
begin
  SDL_LockAudio();
  control_callback := cb;
  next_tick := 0;
  SDL_UnlockAudio();
end;


procedure sm_set_audio_cb(cb: sm_audio_cb);
begin
  SDL_LockAudio();
  audio_callback := cb;
  SDL_UnlockAudio();
end;


procedure sm_force_interval(interval: cunsigned);
begin
  if (next_tick > interval) then next_tick := interval;
end;

end.
