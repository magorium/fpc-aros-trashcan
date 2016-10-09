
function Mix_Linked_Version : PSDL_version;
cdecl; external;
{$EXTERNALSYM Mix_Linked_Version}

{ Open the mixer with a certain audio format }
function Mix_OpenAudio( frequency : integer; format : Uint16; channels :
  integer; chunksize : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_OpenAudio}

{ Dynamically change the number of channels managed by the mixer.
   If decreasing the number of channels, the upper channels are
   stopped.
   This function returns the new number of allocated channels.
 }
function Mix_AllocateChannels( numchannels : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_AllocateChannels}

{ Find out what the actual audio device parameters are.
   This function returns 1 if the audio has been opened, 0 otherwise.
 }
function Mix_QuerySpec( var frequency : integer; var format : Uint16; var channels : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_QuerySpec}

{ Load a wave file or a music (.mod .s3m .it .xm) file }
function Mix_LoadWAV_RW( src : PSDL_RWops; freesrc : integer ) : PMix_Chunk;
cdecl; external;
{$EXTERNALSYM Mix_LoadWAV_RW}

function Mix_LoadWAV( filename : PChar ) : PMix_Chunk;

function Mix_LoadMUS( const filename : PChar ) : PMix_Music;
cdecl; external;
{$EXTERNALSYM Mix_LoadMUS}

(*#if 0 { This hasn't been hooked into music.c yet }
{ Load a music file from an SDL_RWop object (MikMod-specific currently)
   Matt Campbell (matt@campbellhome.dhs.org) April 2000 }
function Mix_LoadMUS_RW(SDL_RWops *rw) : PMix_Music;  cdecl;
#endif*)

{ Load a wave file of the mixer format from a memory buffer }
function Mix_QuickLoad_WAV( mem : PUint8 ) : PMix_Chunk;
cdecl; external;
{$EXTERNALSYM Mix_QuickLoad_WAV}

{ Free an audio chunk previously loaded }
procedure Mix_FreeChunk( chunk : PMix_Chunk );
cdecl; external;
{$EXTERNALSYM Mix_FreeChunk}

procedure Mix_FreeMusic( music : PMix_Music );
cdecl; external;
{$EXTERNALSYM Mix_FreeMusic}

{ Find out the music format of a mixer music, or the currently playing
   music, if 'music' is NULL.}
function Mix_GetMusicType( music : PMix_Music ) : TMix_MusicType;
cdecl; external;
{$EXTERNALSYM Mix_GetMusicType}

{ Set a function that is called after all mixing is performed.
   This can be used to provide real-time visual display of the audio stream
   or add a custom mixer filter for the stream data.
}
procedure Mix_SetPostMix( mix_func : TMixFunction; arg : Pointer );
cdecl; external;
{$EXTERNALSYM Mix_SetPostMix}

{ Add your own music player or additional mixer function.
   If 'mix_func' is NULL, the default music player is re-enabled.
 }
procedure Mix_HookMusic( mix_func : TMixFunction; arg : Pointer );
cdecl; external;
{$EXTERNALSYM Mix_HookMusic}

{ Add your own callback when the music has finished playing.
 }
procedure Mix_HookMusicFinished( music_finished : Pointer );
cdecl; external;
{$EXTERNALSYM Mix_HookMusicFinished}

{ Get a pointer to the user data for the current music hook }
function Mix_GetMusicHookData : Pointer;
cdecl; external;
{$EXTERNALSYM Mix_GetMusicHookData}


(*
procedure Mix_ChannelFinished( channel_finished : TChannel_finished );
cdecl; external;



function Mix_RegisterEffect( chan : integer; f : TMix_EffectFunc; d : TMix_EffectDone; arg : Pointer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_RegisterEffect}


{* You may not need to call this explicitly, unless you need to stop an
 *  effect from processing in the middle of a chunk's playback.
 * Posteffects are never implicitly unregistered as they are for channels,
 *  but they may be explicitly unregistered through this function by
 *  specifying MIX_CHANNEL_POST for a channel.
 * returns zero if error (no such channel or effect), nonzero if removed.
 *  Error messages can be retrieved from Mix_GetError().
 *}
function Mix_UnregisterEffect( channel : integer; f : TMix_EffectFunc ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_UnregisterEffect}

 {* You may not need to call this explicitly, unless you need to stop all
  * effects from processing in the middle of a chunk's playback. Note that
  * this will also shut off some internal effect processing, since
  * Mix_SetPanning( ) and others may use this API under the hood.This is
  * called internally when a channel completes playback.
  * Posteffects are never implicitly unregistered as they are for channels,
  * but they may be explicitly unregistered through this function by
  * specifying MIX_CHANNEL_POST for a channel.
  * returns zero if error( no such channel ), nonzero if all effects removed.
  * Error messages can be retrieved from Mix_GetError( ).
  *}
function Mix_UnregisterAllEffects( channel : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_UnregisterAllEffects}
*)



  function Mix_SetPanning( channel : integer; left : Uint8; right : Uint8  ) : integer;
  cdecl; external;
  {$EXTERNALSYM Mix_SetPanning}

  { * set the position ofa channel.( angle ) is an integer from 0 to 360, that
    * specifies the location of the sound in relation to the listener.( angle )
    * will be reduced as neccesary( 540 becomes 180 degrees, -100 becomes 260 ).
    * Angle 0 is due north, and rotates clockwise as the value increases.
    * for efficiency, the precision of this effect may be limited( angles 1
    * through 7 might all produce the same effect, 8 through 15 are equal, etc ).
    * ( distance ) is an integer between 0 and 255 that specifies the space
    * between the sound and the listener.The larger the number, the further
    * away the sound is .Using 255 does not guarantee that the channel will be
    * culled from the mixing process or be completely silent.For efficiency,
    * the precision of this effect may be limited( distance 0 through 5 might
    * all produce the same effect, 6 through 10 are equal, etc ).Setting( angle )
    * and ( distance ) to 0 unregisters this effect, since the data would be
    * unchanged.
    *
    * if you need more precise positional audio, consider using OpenAL for
    * spatialized effects instead of SDL_mixer.This is only meant to be a
    * basic effect for simple "3D" games.
    *
    * if the audio device is configured for mono output, then you won't get
    * any effectiveness from the angle; however, distance attenuation on the
  * channel will still occur.While this effect will function with stereo
  * voices, it makes more sense to use voices with only one channel of sound,
  * so when they are mixed through this effect, the positioning will sound
  * correct.You can convert them to mono through SDL before giving them to
  * the mixer in the first place if you like.
  *
  * Setting( channel ) to MIX_CHANNEL_POST registers this as a posteffect, and
  * the positioning will be done to the final mixed stream before passing it
  * on to the audio device.
  *
  * This is a convenience wrapper over Mix_SetDistance( ) and Mix_SetPanning( ).
  *
  * returns zero if error( no such channel or Mix_RegisterEffect( )fails ),
  * nonzero if position effect is enabled.
  * Error messages can be retrieved from Mix_GetError( ).
  * }
  function Mix_SetPosition( channel :integer; angle : Sint16; distance : Uint8  ) : integer;
  cdecl; external;
  {$EXTERNALSYM Mix_SetPosition}

  {* set the "distance" of a channel.( distance ) is an integer from 0 to 255
  * that specifies the location of the sound in relation to the listener.
  * Distance 0 is overlapping the listener, and 255 is as far away as possible
  * A distance of 255 does not guarantee silence; in such a case , you might
  * want to try changing the chunk's volume, or just cull the sample from the
  * mixing process with Mix_HaltChannel( ).
    * for efficiency, the precision of this effect may be limited( distances 1
    * through 7 might all produce the same effect, 8 through 15 are equal, etc ).
    * ( distance ) is an integer between 0 and 255 that specifies the space
    * between the sound and the listener.The larger the number, the further
    * away the sound is .
    * Setting( distance ) to 0 unregisters this effect, since the data would be
    * unchanged.
    * if you need more precise positional audio, consider using OpenAL for
    * spatialized effects instead of SDL_mixer.This is only meant to be a
    * basic effect for simple "3D" games.
    *
    * Setting( channel ) to MIX_CHANNEL_POST registers this as a posteffect, and
    * the distance attenuation will be done to the final mixed stream before
    * passing it on to the audio device.
    *
  * This uses the Mix_RegisterEffect( )API internally.
  *
  * returns zero if error( no such channel or Mix_RegisterEffect( )fails ),
  * nonzero if position effect is enabled.
    * Error messages can be retrieved from Mix_GetError( ).
    * }
    function Mix_SetDistance( channel : integer; distance : Uint8 ) : integer;
    cdecl; external;
    {$EXTERNALSYM Mix_SetDistance}
  { *
    * !!! FIXME : Haven't implemented, since the effect goes past the
  * end of the sound buffer.Will have to think about this.
  * - -ryan.
  * /
  { if 0
  { * Causes an echo effect to be mixed into a sound.( echo ) is the amount
  * of echo to mix.0 is no echo, 255 is infinite( and probably not
  * what you want ).
  *
  * Setting( channel ) to MIX_CHANNEL_POST registers this as a posteffect, and
  * the reverbing will be done to the final mixed stream before passing it on
  * to the audio device.
  *
  * This uses the Mix_RegisterEffect( )API internally.If you specify an echo
  * of zero, the effect is unregistered, as the data is already in that state.
  *
  * returns zero if error( no such channel or Mix_RegisterEffect( )fails ),
  * nonzero if reversing effect is enabled.
    * Error messages can be retrieved from Mix_GetError( ).
    *
    extern no_parse_DECLSPEC int Mix_SetReverb( int channel, Uint8 echo );
  #E ndif}
  { * Causes a channel to reverse its stereo.This is handy if the user has his
    * speakers hooked up backwards, or you would like to have a minor bit of
  * psychedelia in your sound code. : )Calling this function with ( flip )
  * set to non - zero reverses the chunks's usual channels. If (flip) is zero,
  * the effect is unregistered.
  *
  * This uses the Mix_RegisterEffect( )API internally, and thus is probably
  * more CPU intensive than having the user just plug in his speakers
  * correctly.Mix_SetReverseStereo( )returns without registering the effect
  * function if the audio device is not configured for stereo output.
  *
  * if you specify MIX_CHANNEL_POST for ( channel ), then this the effect is used
  * on the final mixed stream before sending it on to the audio device( a
  * posteffect ).
  *
  * returns zero if error( no such channel or Mix_RegisterEffect( )fails ),
  * nonzero if reversing effect is enabled.Note that an audio device in mono
  * mode is a no - op, but this call will return successful in that case .
  * Error messages can be retrieved from Mix_GetError( ).
  * }
  function Mix_SetReverseStereo( channel : integer; flip : integer ) : integer;
  cdecl; external;
  {$EXTERNALSYM Mix_SetReverseStereo}
  { end of effects API. - -ryan. *}

{ Reserve the first channels (0 -> n-1) for the application, i.e. don't allocate
   them dynamically to the next sample if requested with a -1 value below.
   Returns the number of reserved channels.
 }
function Mix_ReserveChannels( num : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_ReserveChannels}

{ Channel grouping functions }

{ Attach a tag to a channel. A tag can be assigned to several mixer
   channels, to form groups of channels.
   If 'tag' is -1, the tag is removed (actually -1 is the tag used to
   represent the group of all the channels).
   Returns true if everything was OK.
 }
function Mix_GroupChannel( which : integer; tag : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_GroupChannel}

{ Assign several consecutive channels to a group }
function Mix_GroupChannels( from : integer; to_ : integer; tag : integer ) :
integer;
cdecl; external;
{$EXTERNALSYM Mix_GroupChannels}

{ Finds the first available channel in a group of channels }
function Mix_GroupAvailable( tag : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_GroupAvailable}

{ Returns the number of channels in a group. This is also a subtle
   way to get the total number of channels when 'tag' is -1
 }
function Mix_GroupCount( tag : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_GroupCount}

{ Finds the "oldest" sample playing in a group of channels }
function Mix_GroupOldest( tag : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_GroupOldest}

{ Finds the "most recent" (i.e. last) sample playing in a group of channels }
function Mix_GroupNewer( tag : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_GroupNewer}

{ The same as above, but the sound is played at most 'ticks' milliseconds }
function Mix_PlayChannelTimed( channel : integer; chunk : PMix_Chunk; loops : integer; ticks : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_PlayChannelTimed}

{ Play an audio chunk on a specific channel.
   If the specified channel is -1, play on the first free channel.
   If 'loops' is greater than zero, loop the sound that many times.
   If 'loops' is -1, loop inifinitely (~65000 times).
   Returns which channel was used to play the sound.
}
function Mix_PlayChannel( channel : integer; chunk : PMix_Chunk; loops : integer ) : integer;

function Mix_PlayMusic( music : PMix_Music; loops : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_PlayMusic}

{ Fade in music or a channel over "ms" milliseconds, same semantics as the "Play" functions }
function Mix_FadeInMusic( music : PMix_Music; loops : integer; ms : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_FadeInMusic}

function Mix_FadeInChannelTimed( channel : integer; chunk : PMix_Chunk; loops : integer; ms : integer; ticks : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_FadeInChannelTimed}

function Mix_FadeInChannel( channel : integer; chunk : PMix_Chunk; loops : integer; ms : integer ) : integer;

{ Set the volume in the range of 0-128 of a specific channel or chunk.
   If the specified channel is -1, set volume for all channels.
   Returns the original volume.
   If the specified volume is -1, just return the current volume.
}
function Mix_Volume( channel : integer; volume : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_Volume}

function Mix_VolumeChunk( chunk : PMix_Chunk; volume : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_VolumeChunk}

function Mix_VolumeMusic( volume : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_VolumeMusic}

{ Halt playing of a particular channel }
function Mix_HaltChannel( channel : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_HaltChannel}

function Mix_HaltGroup( tag : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_HaltGroup}

function Mix_HaltMusic : integer;
cdecl; external;
{$EXTERNALSYM Mix_HaltMusic}

{ Change the expiration delay for a particular channel.
   The sample will stop playing after the 'ticks' milliseconds have elapsed,
   or remove the expiration if 'ticks' is -1
}
function Mix_ExpireChannel( channel : integer; ticks : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_ExpireChannel}

{ Halt a channel, fading it out progressively till it's silent
   The ms parameter indicates the number of milliseconds the fading
   will take.
 }
function Mix_FadeOutChannel( which : integer; ms : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_FadeOutChannel}
function Mix_FadeOutGroup( tag : integer; ms : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_FadeOutGroup}
function Mix_FadeOutMusic( ms : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_FadeOutMusic}

{ Query the fading status of a channel }
function Mix_FadingMusic : TMix_Fading;
cdecl; external;
{$EXTERNALSYM Mix_FadingMusic}

function Mix_FadingChannel( which : integer ) : TMix_Fading;
cdecl; external;
{$EXTERNALSYM Mix_FadingChannel}

{ Pause/Resume a particular channel }
procedure Mix_Pause( channel : integer );
cdecl; external;
{$EXTERNALSYM Mix_Pause}

procedure Mix_Resume( channel : integer );
cdecl; external;
{$EXTERNALSYM Mix_Resume}

function Mix_Paused( channel : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_Paused}

{ Pause/Resume the music stream }
procedure Mix_PauseMusic;
cdecl; external;
{$EXTERNALSYM Mix_PauseMusic}

procedure Mix_ResumeMusic;
cdecl; external;
{$EXTERNALSYM Mix_ResumeMusic}

procedure Mix_RewindMusic;
cdecl; external;
{$EXTERNALSYM Mix_RewindMusic}

function Mix_PausedMusic : integer;
cdecl; external;
{$EXTERNALSYM Mix_PausedMusic}

{ Set the current position in the music stream.
  This returns 0 if successful, or -1 if it failed or isn't implemented.
  This function is only implemented for MOD music formats (set pattern
  order number) and for OGG music (set position in seconds), at the
  moment.
}
function Mix_SetMusicPosition( position : double ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_SetMusicPosition}

{ Check the status of a specific channel.
   If the specified channel is -1, check all channels.
}
function Mix_Playing( channel : integer ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_Playing}

function Mix_PlayingMusic : integer;
cdecl; external;
{$EXTERNALSYM Mix_PlayingMusic}

{ Stop music and set external music playback command }
function Mix_SetMusicCMD( const command : PChar ) : integer;
cdecl; external;
{$EXTERNALSYM Mix_SetMusicCMD}

{ Synchro value is set by MikMod from modules while playing }
function Mix_SetSynchroValue( value : integer ) : integer; overload;
cdecl; external;
{$EXTERNALSYM Mix_SetSynchroValue}

function Mix_GetSynchroValue : integer; overload;
cdecl; external;
{$EXTERNALSYM Mix_SetSynchroValue}

{
  Get the Mix_Chunk currently associated with a mixer channel
    Returns nil if it's an invalid channel, or there's no chunk associated.
}
function Mix_GetChunk( channel : integer ) : PMix_Chunk;
cdecl; external;
{$EXTERNALSYM Mix_GetChunk}

{ Close the mixer, halting all playing audio }
procedure Mix_CloseAudio;
cdecl; external;
{$EXTERNALSYM Mix_CloseAudio}
