program TestSDL_Mixer;

{$MODE OBJFPC}{$H+}{$HINTS ON}

uses
  {$IFDEF AROS}
  arosc_static_link,
  {$ENDIF}
  SDL, SDL_Mixer_nosmpeg;
 
const
  AUDIO_FREQUENCY   : Integer   = 22050;
  AUDIO_FORMAT      : Word      = AUDIO_S16;
  AUDIO_CHANNELS    : Integer   = 2;
  AUDIO_CHUNKSIZE   : Integer   = 4096;
 
var
  userkey       : Char;
  music         : PMix_Music = Nil;
  sound         : PMix_Chunk = Nil;
  soundchannel  : Integer;


procedure test;
begin
  SDL_Init(SDL_INIT_AUDIO);
 
  if ( MIX_OpenAudio( AUDIO_FREQUENCY, AUDIO_FORMAT, AUDIO_CHANNELS, AUDIO_CHUNKSIZE) <> 0 )
  then halt;
 
  music := MIX_LoadMus('In my mind.ogg');
  MIX_VolumeMusic(20);
 
  sound := MIX_LoadWav('dial.wav');
  MIX_VolumeChunk(sound, 50);
 
  writeln('Music is playing now...');
  MIX_PlayMusic(music,0); //-1 = infinite, 0 = once, 1 = twice,...
 
  WriteLn('"s" - play sound effect');
  WriteLn('"z" - pause sound effect');
  WriteLn('"t" - resume sound effect');
  WriteLn('"p" - pause music');
  WriteLn('"o" - resume music');
  WriteLn('"q" - quit');

  repeat
    read(UserKey);

    case userkey of
      's': soundchannel:= MIX_PlayChannel(-1, sound, 0);
      'z',
      'y': MIX_Pause(soundchannel);
      't': MIX_Resume(soundchannel);
      'p': MIX_PauseMusic;
      'o': MIX_ResumeMusic;
    end;

  until (userkey = 'q');
 
  MIX_HaltMusic;
  MIX_HaltChannel(soundchannel);
 
  MIX_FreeMusic(music);
  MIX_FreeChunk(sound);
 
  MIX_CloseAudio;
  SDL_Quit;
end;


begin
  {$IFDEF AROS}
  AROSC_Init(@test);
  {$ELSE}
  test;
  {$ENDIF}
end.
