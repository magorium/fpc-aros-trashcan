

function SDL_Init( flags : UInt32 ) : Integer;
cdecl; external;


// This function initializes specific SDL subsystems
function SDL_InitSubSystem( flags : UInt32 ) : Integer;
cdecl; external;


// This function cleans up specific SDL subsystems
procedure SDL_QuitSubSystem( flags : UInt32 );
cdecl; external;


{ This function returns mask of the specified subsystems which have
  been initialized.
  If 'flags' is 0, it returns a mask of all initialized subsystems. }

function SDL_WasInit( flags : UInt32 ): UInt32;
cdecl; external;


{ This function cleans up all initialized subsystems and unloads the
  dynamically linked library.  You should call it upon all exit conditions. }
procedure SDL_Quit;
cdecl; external;


{$IFDEF WINDOWS}
// This should be called from your WinMain() function, if any
function SDL_RegisterApp(name: PChar; style: UInt32; h_Inst: Pointer): Integer;
cdecl; external {$IFNDEF NDS}{$IFDEF __GPC__}name 'SDL_RegisterApp'{$ELSE} SDLLibName{$ENDIF __GPC__}{$ENDIF};
{$EXTERNALSYM SDL_RegisterApp}
{$ENDIF}

{$IFDEF __MACH__}
// This should be called from your main() function, if any
procedure SDL_InitQuickDraw( the_qd: QDGlobals );
cdecl; external {$IFNDEF NDS}{$IFDEF __GPC__}name 'SDL_InitQuickDraw'{$ELSE} SDLLibName{$ENDIF __GPC__}{$ENDIF};
{$EXTERNALSYM SDL_InitQuickDraw}
{$ENDIF}


{------------------------------------------------------------------------------}
{ types }
{------------------------------------------------------------------------------}
// The number of elements in a table
function SDL_TableSize( table: PChar ): Integer;

{------------------------------------------------------------------------------}
{ error-handling }
{------------------------------------------------------------------------------}
// Public functions
function SDL_GetError: PChar;
cdecl; external;

{$IFDEF AROS}
procedure SDL_SetErrorA(fmt: PChar; params: PIPTR); cdecl; external;
procedure SDL_SetError(fmt: PChar); overload;
procedure SDL_SetError(fmt: PChar; const params: array of PtrUInt); overload;
{$ELSE}
procedure SDL_SetError(fmt: PChar);
cdecl; external;
{$ENDIF}

procedure SDL_ClearError;
cdecl; external;


{$IFNDEF WINDOWS}
procedure SDL_Error(Code: TSDL_errorcode);
cdecl; external;
{$ENDIF}

// Private error message function - used internally
procedure SDL_OutOfMemory;

{------------------------------------------------------------------------------}
{ io handling                                                                  }
{------------------------------------------------------------------------------}
// Functions to create SDL_RWops structures from various data sources

function SDL_RWFromFile(filename, mode: PChar): PSDL_RWops;
cdecl; external;
{$EXTERNALSYM SDL_RWFromFile}
procedure SDL_FreeRW(area: PSDL_RWops);
cdecl; external;
{$EXTERNALSYM SDL_FreeRW}

//fp is FILE *fp ???
function SDL_RWFromFP(fp: Pointer; autoclose: Integer): PSDL_RWops;
cdecl; external;
{$EXTERNALSYM SDL_RWFromFP}
function SDL_RWFromMem(mem: Pointer; size: Integer): PSDL_RWops;
cdecl; external;
{$EXTERNALSYM SDL_RWFromMem}
function SDL_RWFromConstMem(const mem: Pointer; size: Integer) : PSDL_RWops;
cdecl; external;
{$EXTERNALSYM SDL_RWFromConstMem}
function SDL_AllocRW: PSDL_RWops;
cdecl; external;
{$EXTERNALSYM SDL_AllocRW}

function SDL_RWSeek(context: PSDL_RWops; offset: Integer; whence: Integer) : Integer;
{$EXTERNALSYM SDL_RWSeek}
function SDL_RWTell(context: PSDL_RWops): Integer;
{$EXTERNALSYM SDL_RWTell}
function SDL_RWRead(context: PSDL_RWops; ptr: Pointer; size: Integer; n : Integer): Integer;
{$EXTERNALSYM SDL_RWRead}
function SDL_RWWrite(context: PSDL_RWops; ptr: Pointer; size: Integer; n : Integer): Integer;
{$EXTERNALSYM SDL_RWWrite}
function SDL_RWClose(context: PSDL_RWops): Integer;
{$EXTERNALSYM SDL_RWClose}

{------------------------------------------------------------------------------}
{ time-handling                                                                }
{------------------------------------------------------------------------------}

{ Get the number of milliseconds since the SDL library initialization. }
{ Note that this value wraps if the program runs for more than ~49 days. }
function SDL_GetTicks: UInt32;
cdecl; external;
{$EXTERNALSYM SDL_GetTicks}

// Wait a specified number of milliseconds before returning
procedure SDL_Delay(msec: UInt32);
cdecl; external;
{$EXTERNALSYM SDL_Delay}

{ Add a new timer to the pool of timers already running. }
{ Returns a timer ID, or NULL when an error occurs.      }
function SDL_AddTimer(interval: UInt32; callback: TSDL_NewTimerCallback; param : Pointer): PSDL_TimerID;
cdecl; external;
{$EXTERNALSYM SDL_AddTimer}

{ Remove one of the multiple timers knowing its ID. }
{ Returns a boolean value indicating success. }
function SDL_RemoveTimer(t: PSDL_TimerID): TSDL_Bool;
cdecl; external;
{$EXTERNALSYM SDL_RemoveTimer}

function SDL_SetTimer(interval: UInt32; callback: TSDL_TimerCallback): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetTimer}

{------------------------------------------------------------------------------}
{ audio-routines                                                               }
{------------------------------------------------------------------------------}

{ These functions are used internally, and should not be used unless you
  have a specific need to specify the audio driver you want to use.
  You should normally use SDL_Init() or SDL_InitSubSystem(). }

function SDL_AudioInit(driver_name: PChar): Integer;
cdecl; external;
{$EXTERNALSYM SDL_AudioInit}
procedure SDL_AudioQuit;
cdecl; external;
{$EXTERNALSYM SDL_AudioQuit}

{ This function fills the given character buffer with the name of the
  current audio driver, and returns a Pointer to it if the audio driver has
  been initialized.  It returns NULL if no driver has been initialized. }

function SDL_AudioDriverName(namebuf: PChar; maxlen: Integer): PChar;
cdecl; external;
{$EXTERNALSYM SDL_AudioDriverName}

{ This function opens the audio device with the desired parameters, and
  returns 0 if successful, placing the actual hardware parameters in the
  structure pointed to by 'obtained'.  If 'obtained' is NULL, the audio
  data passed to the callback function will be guaranteed to be in the
  requested format, and will be automatically converted to the hardware
  audio format if necessary.  This function returns -1 if it failed
  to open the audio device, or couldn't set up the audio thread.

  When filling in the desired audio spec structure,
   'desired->freq' should be the desired audio frequency in samples-per-second.
   'desired->format' should be the desired audio format.
   'desired->samples' is the desired size of the audio buffer, in samples.
      This number should be a power of two, and may be adjusted by the audio
      driver to a value more suitable for the hardware.  Good values seem to
      range between 512 and 8096 inclusive, depending on the application and
      CPU speed.  Smaller values yield faster response time, but can lead
      to underflow if the application is doing heavy processing and cannot
      fill the audio buffer in time.  A stereo sample consists of both right
      and left channels in LR ordering.
      Note that the number of samples is directly related to time by the
      following formula:  ms = (samples*1000)/freq
   'desired->size' is the size in bytes of the audio buffer, and is
      calculated by SDL_OpenAudio().
   'desired->silence' is the value used to set the buffer to silence,
      and is calculated by SDL_OpenAudio().
   'desired->callback' should be set to a function that will be called
      when the audio device is ready for more data.  It is passed a pointer
      to the audio buffer, and the length in bytes of the audio buffer.
      This function usually runs in a separate thread, and so you should
      protect data structures that it accesses by calling SDL_LockAudio()
      and SDL_UnlockAudio() in your code.
   'desired->userdata' is passed as the first parameter to your callback
      function.

  The audio device starts out playing silence when it's opened, and should
  be enabled for playing by calling SDL_PauseAudio(0) when you are ready
  for your audio callback function to be called.  Since the audio driver
  may modify the requested size of the audio buffer, you should allocate
  any local mixing buffers after you open the audio device. }

function SDL_OpenAudio(desired, obtained: PSDL_AudioSpec): Integer;
cdecl; external;
{$EXTERNALSYM SDL_OpenAudio}

{ Get the current audio state: }
function SDL_GetAudioStatus: TSDL_Audiostatus;
cdecl; external;
{$EXTERNALSYM SDL_GetAudioStatus}

{ This function pauses and unpauses the audio callback processing.
  It should be called with a parameter of 0 after opening the audio
  device to start playing sound.  This is so you can safely initialize
  data for your callback function after opening the audio device.
  Silence will be written to the audio device during the pause. }

procedure SDL_PauseAudio(pause_on: Integer);
cdecl; external;
{$EXTERNALSYM SDL_PauseAudio}

{ This function loads a WAVE from the data source, automatically freeing
  that source if 'freesrc' is non-zero.  For example, to load a WAVE file,
  you could do:
  SDL_LoadWAV_RW(SDL_RWFromFile("sample.wav", "rb"), 1, ...);

  If this function succeeds, it returns the given SDL_AudioSpec,
  filled with the audio data format of the wave data, and sets
  'audio_buf' to a malloc()'d buffer containing the audio data,
  and sets 'audio_len' to the length of that audio buffer, in bytes.
  You need to free the audio buffer with SDL_FreeWAV() when you are
  done with it.

  This function returns NULL and sets the SDL error message if the
  wave file cannot be opened, uses an unknown data format, or is
  corrupt.  Currently raw and MS-ADPCM WAVE files are supported. }

function SDL_LoadWAV_RW(src: PSDL_RWops; freesrc: Integer; spec:
  PSDL_AudioSpec; audio_buf: PUInt8; audiolen: PUInt32): PSDL_AudioSpec;
cdecl; external;
{$EXTERNALSYM SDL_LoadWAV_RW}

// Compatibility convenience function -- loads a WAV from a file
function SDL_LoadWAV(filename: PChar; spec: PSDL_AudioSpec; audio_buf:
  PUInt8; audiolen: PUInt32): PSDL_AudioSpec;
{$EXTERNALSYM SDL_LoadWAV}

{ This function frees data previously allocated with SDL_LoadWAV_RW() }

procedure SDL_FreeWAV(audio_buf: PUInt8);
cdecl; external;
{$EXTERNALSYM SDL_FreeWAV}

{ This function takes a source format and rate and a destination format
  and rate, and initializes the 'cvt' structure with information needed
  by SDL_ConvertAudio() to convert a buffer of audio data from one format
  to the other.
  This function returns 0, or -1 if there was an error. }
function SDL_BuildAudioCVT(cvt: PSDL_AudioCVT; src_format: UInt16;
  src_channels: UInt8; src_rate: Integer; dst_format: UInt16; dst_channels: UInt8;
  dst_rate: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_BuildAudioCVT}

{ Once you have initialized the 'cvt' structure using SDL_BuildAudioCVT(),
  created an audio buffer cvt->buf, and filled it with cvt->len bytes of
  audio data in the source format, this function will convert it in-place
  to the desired format.
  The data conversion may expand the size of the audio data, so the buffer
  cvt->buf should be allocated after the cvt structure is initialized by
  SDL_BuildAudioCVT(), and should be cvt->len*cvt->len_mult bytes long. }
function SDL_ConvertAudio(cvt: PSDL_AudioCVT): Integer;
cdecl; external;
{$EXTERNALSYM SDL_ConvertAudio}

{ This takes two audio buffers of the playing audio format and mixes
  them, performing addition, volume adjustment, and overflow clipping.
  The volume ranges from 0 - 128, and should be set to SDL_MIX_MAXVOLUME
  for full audio volume.  Note this does not change hardware volume.
  This is provided for convenience -- you can mix your own audio data. }

procedure SDL_MixAudio(dst, src: PUInt8; len: UInt32; volume: Integer);
cdecl; external;
{$EXTERNALSYM SDL_MixAudio}

{ The lock manipulated by these functions protects the callback function.
  During a LockAudio/UnlockAudio pair, you can be guaranteed that the
  callback function is not running.  Do not call these from the callback
  function or you will cause deadlock. }
procedure SDL_LockAudio;
cdecl; external;
{$EXTERNALSYM SDL_LockAudio}
procedure SDL_UnlockAudio;
cdecl; external;
{$EXTERNALSYM SDL_UnlockAudio}

{ This function shuts down audio processing and closes the audio device. }

procedure SDL_CloseAudio;
cdecl; external;
{$EXTERNALSYM SDL_CloseAudio}

{------------------------------------------------------------------------------}
{ CD-routines }
{------------------------------------------------------------------------------}

{ Returns the number of CD-ROM drives on the system, or -1 if
  SDL_Init() has not been called with the SDL_INIT_CDROM flag. }

function SDL_CDNumDrives: Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDNumDrives}

{ Returns a human-readable, system-dependent identifier for the CD-ROM.
   Example:
   "/dev/cdrom"
   "E:"
   "/dev/disk/ide/1/master" }

function SDL_CDName(drive: Integer): PChar;
cdecl; external;
{$EXTERNALSYM SDL_CDName}

{ Opens a CD-ROM drive for access.  It returns a drive handle on success,
  or NULL if the drive was invalid or busy.  This newly opened CD-ROM
  becomes the default CD used when other CD functions are passed a NULL
  CD-ROM handle.
  Drives are numbered starting with 0.  Drive 0 is the system default CD-ROM. }

function SDL_CDOpen(drive: Integer): PSDL_CD;
cdecl; external;
{$EXTERNALSYM SDL_CDOpen}

{ This function returns the current status of the given drive.
  If the drive has a CD in it, the table of contents of the CD and current
  play position of the CD will be stored in the SDL_CD structure. }

function SDL_CDStatus(cdrom: PSDL_CD): TSDL_CDStatus;
cdecl; external;
{$EXTERNALSYM SDL_CDStatus}

{  Play the given CD starting at 'start_track' and 'start_frame' for 'ntracks'
   tracks and 'nframes' frames.  If both 'ntrack' and 'nframe' are 0, play
   until the end of the CD.  This function will skip data tracks.
   This function should only be called after calling SDL_CDStatus() to
   get track information about the CD.

   For example:
   // Play entire CD:
  if ( CD_INDRIVE(SDL_CDStatus(cdrom)) ) then
    SDL_CDPlayTracks(cdrom, 0, 0, 0, 0);
   // Play last track:
   if ( CD_INDRIVE(SDL_CDStatus(cdrom)) ) then
   begin
    SDL_CDPlayTracks(cdrom, cdrom->numtracks-1, 0, 0, 0);
   end;

   // Play first and second track and 10 seconds of third track:
   if ( CD_INDRIVE(SDL_CDStatus(cdrom)) )
    SDL_CDPlayTracks(cdrom, 0, 0, 2, 10);

   This function returns 0, or -1 if there was an error. }

function SDL_CDPlayTracks(cdrom: PSDL_CD; start_track: Integer; start_frame:
  Integer; ntracks: Integer; nframes: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDPlayTracks}


{  Play the given CD starting at 'start' frame for 'length' frames.
   It returns 0, or -1 if there was an error. }

function SDL_CDPlay(cdrom: PSDL_CD; start: Integer; length: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDPlay}

// Pause play -- returns 0, or -1 on error
function SDL_CDPause(cdrom: PSDL_CD): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDPause}

// Resume play -- returns 0, or -1 on error
function SDL_CDResume(cdrom: PSDL_CD): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDResume}

// Stop play -- returns 0, or -1 on error
function SDL_CDStop(cdrom: PSDL_CD): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDStop}

// Eject CD-ROM -- returns 0, or -1 on error
function SDL_CDEject(cdrom: PSDL_CD): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CDEject}

// Closes the handle for the CD-ROM drive
procedure SDL_CDClose(cdrom: PSDL_CD);
cdecl; external;
{$EXTERNALSYM SDL_CDClose}

// Given a status, returns true if there's a disk in the drive
function SDL_CDInDrive( status : TSDL_CDStatus ) : LongBool;
{$EXTERNALSYM SDL_CDInDrive}

// Conversion functions from frames to Minute/Second/Frames and vice versa
procedure FRAMES_TO_MSF(frames: Integer; var M: Integer; var S: Integer; var
  F: Integer);
{$EXTERNALSYM FRAMES_TO_MSF}
function MSF_TO_FRAMES(M: Integer; S: Integer; F: Integer): Integer;
{$EXTERNALSYM MSF_TO_FRAMES}

{------------------------------------------------------------------------------}
{ JoyStick-routines                                                            }
{------------------------------------------------------------------------------}

{ Count the number of joysticks attached to the system }
function SDL_NumJoysticks: Integer;
cdecl; external;
{$EXTERNALSYM SDL_NumJoysticks}

{ Get the implementation dependent name of a joystick.
  This can be called before any joysticks are opened.
  If no name can be found, this function returns NULL. }
function SDL_JoystickName(index: Integer): PChar;
cdecl; external;
{$EXTERNALSYM SDL_JoystickName}

{ Open a joystick for use - the index passed as an argument refers to
  the N'th joystick on the system.  This index is the value which will
  identify this joystick in future joystick events.

  This function returns a joystick identifier, or NULL if an error occurred. }
function SDL_JoystickOpen(index: Integer): PSDL_Joystick;
cdecl; external;
{$EXTERNALSYM SDL_JoystickOpen}

{ Returns 1 if the joystick has been opened, or 0 if it has not. }
function SDL_JoystickOpened(index: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickOpened}

{ Get the device index of an opened joystick. }
function SDL_JoystickIndex(joystick: PSDL_Joystick): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickIndex}

{ Get the number of general axis controls on a joystick }
function SDL_JoystickNumAxes(joystick: PSDL_Joystick): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickNumAxes}

{ Get the number of trackballs on a joystick
  Joystick trackballs have only relative motion events associated
  with them and their state cannot be polled. }
function SDL_JoystickNumBalls(joystick: PSDL_Joystick): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickNumBalls}


{ Get the number of POV hats on a joystick }
function SDL_JoystickNumHats(joystick: PSDL_Joystick): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickNumHats}

{ Get the number of buttons on a joystick }
function SDL_JoystickNumButtons(joystick: PSDL_Joystick): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickNumButtons}

{ Update the current state of the open joysticks.
  This is called automatically by the event loop if any joystick
  events are enabled. }

procedure SDL_JoystickUpdate;
cdecl; external;
{$EXTERNALSYM SDL_JoystickUpdate;}

{ Enable/disable joystick event polling.
  If joystick events are disabled, you must call SDL_JoystickUpdate()
  yourself and check the state of the joystick when you want joystick
  information.
  The state can be one of SDL_QUERY, SDL_ENABLE or SDL_IGNORE. }

function SDL_JoystickEventState(state: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickEventState}

{ Get the current state of an axis control on a joystick
  The state is a value ranging from -32768 to 32767.
  The axis indices start at index 0. }

function SDL_JoystickGetAxis(joystick: PSDL_Joystick; axis: Integer) : SInt16;
cdecl; external;
{$EXTERNALSYM SDL_JoystickGetAxis}

{ The hat indices start at index 0. }

function SDL_JoystickGetHat(joystick: PSDL_Joystick; hat: Integer): UInt8;
cdecl; external;
{$EXTERNALSYM SDL_JoystickGetHat}

{ Get the ball axis change since the last poll
  This returns 0, or -1 if you passed it invalid parameters.
  The ball indices start at index 0. }

function SDL_JoystickGetBall(joystick: PSDL_Joystick; ball: Integer; var dx: Integer; var dy: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_JoystickGetBall}

{ Get the current state of a button on a joystick
  The button indices start at index 0. }
function SDL_JoystickGetButton( joystick: PSDL_Joystick; Button: Integer): UInt8;
cdecl; external;
{$EXTERNALSYM SDL_JoystickGetButton}

{ Close a joystick previously opened with SDL_JoystickOpen() }
procedure SDL_JoystickClose(joystick: PSDL_Joystick);
cdecl; external;
{$EXTERNALSYM SDL_JoystickClose}

{------------------------------------------------------------------------------}
{ event-handling }
{------------------------------------------------------------------------------}

{ Pumps the event loop, gathering events from the input devices.
  This function updates the event queue and internal input device state.
  This should only be run in the thread that sets the video mode. }

procedure SDL_PumpEvents;
cdecl; external;
{$EXTERNALSYM SDL_PumpEvents;}

{ Checks the event queue for messages and optionally returns them.
  If 'action' is SDL_ADDEVENT, up to 'numevents' events will be added to
  the back of the event queue.
  If 'action' is SDL_PEEKEVENT, up to 'numevents' events at the front
  of the event queue, matching 'mask', will be returned and will not
  be removed from the queue.
  If 'action' is SDL_GETEVENT, up to 'numevents' events at the front
  of the event queue, matching 'mask', will be returned and will be
  removed from the queue.
  This function returns the number of events actually stored, or -1
  if there was an error.  This function is thread-safe. }

function SDL_PeepEvents(events: PSDL_Event; numevents: Integer; action: TSDL_eventaction; mask: UInt32): Integer;
cdecl; external;
{$EXTERNALSYM SDL_PeepEvents}

{ Polls for currently pending events, and returns 1 if there are any pending
   events, or 0 if there are none available.  If 'event' is not NULL, the next
   event is removed from the queue and stored in that area. }

function SDL_PollEvent(event: PSDL_Event): Integer;
cdecl; external;
{$EXTERNALSYM SDL_PollEvent}

{  Waits indefinitely for the next available event, returning 1, or 0 if there
   was an error while waiting for events.  If 'event' is not NULL, the next
   event is removed from the queue and stored in that area. }

function SDL_WaitEvent(event: PSDL_Event): Integer;
cdecl; external;
{$EXTERNALSYM SDL_WaitEvent}

function SDL_PushEvent( event : PSDL_Event ) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_PushEvent}

{ If the filter returns 1, then the event will be added to the internal queue.
  If it returns 0, then the event will be dropped from the queue, but the
  internal state will still be updated.  This allows selective filtering of
  dynamically arriving events.

  WARNING:  Be very careful of what you do in the event filter function, as
            it may run in a different thread!

  There is one caveat when dealing with the SDL_QUITEVENT event type.  The
  event filter is only called when the window manager desires to close the
  application window.  If the event filter returns 1, then the window will
  be closed, otherwise the window will remain open if possible.
  If the quit event is generated by an interrupt signal, it will bypass the
  internal queue and be delivered to the application at the next event poll. }
procedure SDL_SetEventFilter( filter : TSDL_EventFilter );
cdecl; external;
{$EXTERNALSYM SDL_SetEventFilter}

{ Return the current event filter - can be used to "chain" filters.
  If there is no event filter set, this function returns NULL. }

function SDL_GetEventFilter: TSDL_EventFilter;
cdecl; external;
{$EXTERNALSYM SDL_GetEventFilter}

{ This function allows you to set the state of processing certain events.
  If 'state' is set to SDL_IGNORE, that event will be automatically dropped
  from the event queue and will not event be filtered.
  If 'state' is set to SDL_ENABLE, that event will be processed normally.
  If 'state' is set to SDL_QUERY, SDL_EventState() will return the
  current processing state of the specified event. }

function SDL_EventState(type_: UInt8; state: Integer): UInt8;
cdecl; external;
{$EXTERNALSYM SDL_EventState}

{------------------------------------------------------------------------------}
{ Version Routines }
{------------------------------------------------------------------------------}

{ This macro can be used to fill a version structure with the compile-time
  version of the SDL library. }
procedure SDL_VERSION(var X: TSDL_Version);
{$EXTERNALSYM SDL_VERSION}

{ This macro turns the version numbers into a numeric value:
   (1,2,3) -> (1203)
   This assumes that there will never be more than 100 patchlevels }

function SDL_VERSIONNUM(X, Y, Z: Integer): Integer;
{$EXTERNALSYM SDL_VERSIONNUM}

// This is the version number macro for the current SDL version
function SDL_COMPILEDVERSION: Integer;
{$EXTERNALSYM SDL_COMPILEDVERSION}

// This macro will evaluate to true if compiled with SDL at least X.Y.Z
function SDL_VERSION_ATLEAST(X: Integer; Y: Integer; Z: Integer) : LongBool;
{$EXTERNALSYM SDL_VERSION_ATLEAST}

{ This function gets the version of the dynamically linked SDL library.
  it should NOT be used to fill a version structure, instead you should
  use the SDL_Version() macro. }

function SDL_Linked_Version: PSDL_version;
cdecl; external;
{$EXTERNALSYM SDL_Linked_Version}

{------------------------------------------------------------------------------}
{ video                                                                        }
{------------------------------------------------------------------------------}

{ These functions are used internally, and should not be used unless you
  have a specific need to specify the video driver you want to use.
  You should normally use SDL_Init() or SDL_InitSubSystem().

  SDL_VideoInit() initializes the video subsystem -- sets up a connection
  to the window manager, etc, and determines the current video mode and
  pixel format, but does not initialize a window or graphics mode.
  Note that event handling is activated by this routine.

  If you use both sound and video in your application, you need to call
  SDL_Init() before opening the sound device, otherwise under Win32 DirectX,
  you won't be able to set full-screen display modes. }

function SDL_VideoInit(driver_name: PChar; flags: UInt32): Integer;
cdecl; external;
{$EXTERNALSYM SDL_VideoInit}
procedure SDL_VideoQuit;
cdecl; external;
{$EXTERNALSYM SDL_VideoQuit}

{ This function fills the given character buffer with the name of the
  video driver, and returns a pointer to it if the video driver has
  been initialized.  It returns NULL if no driver has been initialized. }

function SDL_VideoDriverName(namebuf: PChar; maxlen: Integer): PChar;
cdecl; external;
{$EXTERNALSYM SDL_VideoDriverName}

{ This function returns a pointer to the current display surface.
  If SDL is doing format conversion on the display surface, this
  function returns the publicly visible surface, not the real video
  surface. }

function SDL_GetVideoSurface: PSDL_Surface;
cdecl; external;
{$EXTERNALSYM SDL_GetVideoSurface}

{ This function returns a read-only pointer to information about the
  video hardware.  If this is called before SDL_SetVideoMode(), the 'vfmt'
  member of the returned structure will contain the pixel format of the
  "best" video mode. }
function SDL_GetVideoInfo: PSDL_VideoInfo;
cdecl; external;
{$EXTERNALSYM SDL_GetVideoInfo}

{ Check to see if a particular video mode is supported.
  It returns 0 if the requested mode is not supported under any bit depth,
  or returns the bits-per-pixel of the closest available mode with the
  given width and height.  If this bits-per-pixel is different from the
  one used when setting the video mode, SDL_SetVideoMode() will succeed,
  but will emulate the requested bits-per-pixel with a shadow surface.

  The arguments to SDL_VideoModeOK() are the same ones you would pass to
  SDL_SetVideoMode() }

function SDL_VideoModeOK(width, height, bpp: Integer; flags: UInt32): Integer;
cdecl; external;
{$EXTERNALSYM SDL_VideoModeOK}

{ Return a pointer to an array of available screen dimensions for the
  given format and video flags, sorted largest to smallest.  Returns
  NULL if there are no dimensions available for a particular format,
  or (SDL_Rect **)-1 if any dimension is okay for the given format.

  if 'format' is NULL, the mode list will be for the format given
  by SDL_GetVideoInfo( ) - > vfmt }

function SDL_ListModes(format: PSDL_PixelFormat; flags: UInt32): PPSDL_Rect;
cdecl; external;
{$EXTERNALSYM SDL_ListModes}


{ Set up a video mode with the specified width, height and bits-per-pixel.

  If 'bpp' is 0, it is treated as the current display bits per pixel.

  If SDL_ANYFORMAT is set in 'flags', the SDL library will try to set the
  requested bits-per-pixel, but will return whatever video pixel format is
  available.  The default is to emulate the requested pixel format if it
  is not natively available.

  If SDL_HWSURFACE is set in 'flags', the video surface will be placed in
  video memory, if possible, and you may have to call SDL_LockSurface()
  in order to access the raw framebuffer.  Otherwise, the video surface
  will be created in system memory.

  If SDL_ASYNCBLIT is set in 'flags', SDL will try to perform rectangle
  updates asynchronously, but you must always lock before accessing pixels.
  SDL will wait for updates to complete before returning from the lock.

  If SDL_HWPALETTE is set in 'flags', the SDL library will guarantee
  that the colors set by SDL_SetColors() will be the colors you get.
  Otherwise, in 8-bit mode, SDL_SetColors() may not be able to set all
  of the colors exactly the way they are requested, and you should look
  at the video surface structure to determine the actual palette.
  If SDL cannot guarantee that the colors you request can be set,
  i.e. if the colormap is shared, then the video surface may be created
  under emulation in system memory, overriding the SDL_HWSURFACE flag.

  If SDL_FULLSCREEN is set in 'flags', the SDL library will try to set
  a fullscreen video mode.  The default is to create a windowed mode
  if the current graphics system has a window manager.
  If the SDL library is able to set a fullscreen video mode, this flag
  will be set in the surface that is returned.

  If SDL_DOUBLEBUF is set in 'flags', the SDL library will try to set up
  two surfaces in video memory and swap between them when you call
  SDL_Flip().  This is usually slower than the normal single-buffering
  scheme, but prevents "tearing" artifacts caused by modifying video
  memory while the monitor is refreshing.  It should only be used by
  applications that redraw the entire screen on every update.

  This function returns the video framebuffer surface, or NULL if it fails. }

function SDL_SetVideoMode(width, height, bpp: Integer; flags: UInt32): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM SDL_SetVideoMode}


{ Makes sure the given list of rectangles is updated on the given screen.
  If 'x', 'y', 'w' and 'h' are all 0, SDL_UpdateRect will update the entire
  screen.
  These functions should not be called while 'screen' is locked. }

procedure SDL_UpdateRects(screen: PSDL_Surface; numrects: Integer; rects: PSDL_Rect);
cdecl; external;
{$EXTERNALSYM SDL_UpdateRects}
procedure SDL_UpdateRect(screen: PSDL_Surface; x, y: SInt32; w, h: UInt32);
cdecl; external;
{$EXTERNALSYM SDL_UpdateRect}


{ On hardware that supports double-buffering, this function sets up a flip
  and returns.  The hardware will wait for vertical retrace, and then swap
  video buffers before the next video surface blit or lock will return.
  On hardware that doesn not support double-buffering, this is equivalent
  to calling SDL_UpdateRect(screen, 0, 0, 0, 0);
  The SDL_DOUBLEBUF flag must have been passed to SDL_SetVideoMode() when
  setting the video mode for this function to perform hardware flipping.
  This function returns 0 if successful, or -1 if there was an error.}

function SDL_Flip(screen: PSDL_Surface): Integer;
cdecl; external;
{$EXTERNALSYM SDL_Flip}

{ Set the gamma correction for each of the color channels.
  The gamma values range (approximately) between 0.1 and 10.0

  If this function isn't supported directly by the hardware, it will
  be emulated using gamma ramps, if available.  If successful, this
  function returns 0, otherwise it returns -1. }

function SDL_SetGamma(redgamma: single; greengamma: single; bluegamma: single ): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetGamma}

{ Set the gamma translation table for the red, green, and blue channels
  of the video hardware.  Each table is an array of 256 16-bit quantities,
  representing a mapping between the input and output for that channel.
  The input is the index into the array, and the output is the 16-bit
  gamma value at that index, scaled to the output color precision.

  You may pass NULL for any of the channels to leave it unchanged.
  If the call succeeds, it will return 0.  If the display driver or
  hardware does not support gamma translation, or otherwise fails,
  this function will return -1. }

function SDL_SetGammaRamp( redtable: PUInt16; greentable: PUInt16; bluetable: PUInt16): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetGammaRamp}

{ Retrieve the current values of the gamma translation tables.

  You must pass in valid pointers to arrays of 256 16-bit quantities.
  Any of the pointers may be NULL to ignore that channel.
  If the call succeeds, it will return 0.  If the display driver or
  hardware does not support gamma translation, or otherwise fails,
  this function will return -1. }

function SDL_GetGammaRamp( redtable: PUInt16; greentable: PUInt16; bluetable: PUInt16): Integer;
cdecl; external;
{$EXTERNALSYM SDL_GetGammaRamp}

{ Sets a portion of the colormap for the given 8-bit surface.  If 'surface'
  is not a palettized surface, this function does nothing, returning 0.
  If all of the colors were set as passed to SDL_SetColors(), it will
  return 1.  If not all the color entries were set exactly as given,
  it will return 0, and you should look at the surface palette to
  determine the actual color palette.

  When 'surface' is the surface associated with the current display, the
  display colormap will be updated with the requested colors.  If
  SDL_HWPALETTE was set in SDL_SetVideoMode() flags, SDL_SetColors()
  will always return 1, and the palette is guaranteed to be set the way
  you desire, even if the window colormap has to be warped or run under
  emulation. }


function SDL_SetColors(surface: PSDL_Surface; colors: PSDL_Color; firstcolor : Integer; ncolors: Integer) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetColors}

{ Sets a portion of the colormap for a given 8-bit surface.
  'flags' is one or both of:
  SDL_LOGPAL  -- set logical palette, which controls how blits are mapped
                 to/from the surface,
  SDL_PHYSPAL -- set physical palette, which controls how pixels look on
                 the screen
  Only screens have physical palettes. Separate change of physical/logical
  palettes is only possible if the screen has SDL_HWPALETTE set.

  The return value is 1 if all colours could be set as requested, and 0
  otherwise.

  SDL_SetColors() is equivalent to calling this function with
  flags = (SDL_LOGPAL or SDL_PHYSPAL). }

function SDL_SetPalette(surface: PSDL_Surface; flags: Integer; colors: PSDL_Color; firstcolor: Integer; ncolors: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetPalette}

{ Maps an RGB triple to an opaque pixel value for a given pixel format }
function SDL_MapRGB(format: PSDL_PixelFormat; r: UInt8; g: UInt8; b: UInt8) : UInt32;
cdecl; external;
{$EXTERNALSYM SDL_MapRGB}

{ Maps an RGBA quadruple to a pixel value for a given pixel format }
function SDL_MapRGBA(format: PSDL_PixelFormat; r: UInt8; g: UInt8; b: UInt8; a: UInt8): UInt32;
cdecl; external;
{$EXTERNALSYM SDL_MapRGBA}

{ Maps a pixel value into the RGB components for a given pixel format }
procedure SDL_GetRGB(pixel: UInt32; fmt: PSDL_PixelFormat; r: PUInt8; g: PUInt8; b: PUInt8);
cdecl; external;
{$EXTERNALSYM SDL_GetRGB}

{ Maps a pixel value into the RGBA components for a given pixel format }
procedure SDL_GetRGBA(pixel: UInt32; fmt: PSDL_PixelFormat; r: PUInt8; g: PUInt8; b: PUInt8; a: PUInt8);
cdecl; external;
{$EXTERNALSYM SDL_GetRGBA}

{ Allocate and free an RGB surface (must be called after SDL_SetVideoMode)
  If the depth is 4 or 8 bits, an empty palette is allocated for the surface.
  If the depth is greater than 8 bits, the pixel format is set using the
  flags '[RGB]mask'.
  If the function runs out of memory, it will return NULL.

  The 'flags' tell what kind of surface to create.
  SDL_SWSURFACE means that the surface should be created in system memory.
  SDL_HWSURFACE means that the surface should be created in video memory,
  with the same format as the display surface.  This is useful for surfaces
  that will not change much, to take advantage of hardware acceleration
  when being blitted to the display surface.
  SDL_ASYNCBLIT means that SDL will try to perform asynchronous blits with
  this surface, but you must always lock it before accessing the pixels.
  SDL will wait for current blits to finish before returning from the lock.
  SDL_SRCCOLORKEY indicates that the surface will be used for colorkey blits.
  If the hardware supports acceleration of colorkey blits between
  two surfaces in video memory, SDL will try to place the surface in
  video memory. If this isn't possible or if there is no hardware
  acceleration available, the surface will be placed in system memory.
  SDL_SRCALPHA means that the surface will be used for alpha blits and
  if the hardware supports hardware acceleration of alpha blits between
  two surfaces in video memory, to place the surface in video memory
  if possible, otherwise it will be placed in system memory.
  If the surface is created in video memory, blits will be _much_ faster,
  but the surface format must be identical to the video surface format,
  and the only way to access the pixels member of the surface is to use
  the SDL_LockSurface() and SDL_UnlockSurface() calls.
  If the requested surface actually resides in video memory, SDL_HWSURFACE
  will be set in the flags member of the returned surface.  If for some
  reason the surface could not be placed in video memory, it will not have
  the SDL_HWSURFACE flag set, and will be created in system memory instead. }

function SDL_AllocSurface(flags: UInt32; width, height, depth: Integer;
  RMask, GMask, BMask, AMask: UInt32): PSDL_Surface;
{$EXTERNALSYM SDL_AllocSurface}

function SDL_CreateRGBSurface(flags: UInt32; width, height, depth: Integer; RMask, GMask, BMask, AMask: UInt32): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM SDL_CreateRGBSurface}

function SDL_CreateRGBSurfaceFrom(pixels: Pointer; width, height, depth, pitch
  : Integer; RMask, GMask, BMask, AMask: UInt32): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM SDL_CreateRGBSurfaceFrom}

procedure SDL_FreeSurface(surface: PSDL_Surface);
cdecl; external;
{$EXTERNALSYM SDL_FreeSurface}

function SDL_MustLock(Surface: PSDL_Surface): Boolean;
{$EXTERNALSYM SDL_MustLock}
{ SDL_LockSurface() sets up a surface for directly accessing the pixels.
  Between calls to SDL_LockSurface()/SDL_UnlockSurface(), you can write
  to and read from 'surface->pixels', using the pixel format stored in
  'surface->format'.  Once you are done accessing the surface, you should
  use SDL_UnlockSurface() to release it.

  Not all surfaces require locking.  If SDL_MUSTLOCK(surface) evaluates
  to 0, then you can read and write to the surface at any time, and the
  pixel format of the surface will not change.  In particular, if the
  SDL_HWSURFACE flag is not given when calling SDL_SetVideoMode(), you
  will not need to lock the display surface before accessing it.

  No operating system or library calls should be made between lock/unlock
  pairs, as critical system locks may be held during this time.

  SDL_LockSurface() returns 0, or -1 if the surface couldn't be locked. }
function SDL_LockSurface(surface: PSDL_Surface): Integer;
cdecl; external;
{$EXTERNALSYM SDL_LockSurface}

procedure SDL_UnlockSurface(surface: PSDL_Surface);
cdecl; external;
{$EXTERNALSYM SDL_UnlockSurface}

{ Load a surface from a seekable SDL data source (memory or file.)
  If 'freesrc' is non-zero, the source will be closed after being read.
  Returns the new surface, or NULL if there was an error.
  The new surface should be freed with SDL_FreeSurface(). }
function SDL_LoadBMP_RW(src: PSDL_RWops; freesrc: Integer): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM SDL_LoadBMP_RW}

// Convenience macro -- load a surface from a file
function SDL_LoadBMP(filename: PChar): PSDL_Surface;
{$EXTERNALSYM SDL_LoadBMP}

{ Save a surface to a seekable SDL data source (memory or file.)
  If 'freedst' is non-zero, the source will be closed after being written.
  Returns 0 if successful or -1 if there was an error. }

function SDL_SaveBMP_RW(surface: PSDL_Surface; dst: PSDL_RWops; freedst: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SaveBMP_RW}

// Convenience macro -- save a surface to a file
function SDL_SaveBMP(surface: PSDL_Surface; filename: PChar): Integer;
{$EXTERNALSYM SDL_SaveBMP}

{ Sets the color key (transparent pixel) in a blittable surface.
  If 'flag' is SDL_SRCCOLORKEY (optionally OR'd with SDL_RLEACCEL),
  'key' will be the transparent pixel in the source image of a blit.
  SDL_RLEACCEL requests RLE acceleration for the surface if present,
  and removes RLE acceleration if absent.
  If 'flag' is 0, this function clears any current color key.
  This function returns 0, or -1 if there was an error. }

function SDL_SetColorKey(surface: PSDL_Surface; flag, key: UInt32) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetColorKey}

{ This function sets the alpha value for the entire surface, as opposed to
  using the alpha component of each pixel. This value measures the range
  of transparency of the surface, 0 being completely transparent to 255
  being completely opaque. An 'alpha' value of 255 causes blits to be
  opaque, the source pixels copied to the destination (the default). Note
  that per-surface alpha can be combined with colorkey transparency.

  If 'flag' is 0, alpha blending is disabled for the surface.
  If 'flag' is SDL_SRCALPHA, alpha blending is enabled for the surface.
  OR:ing the flag with SDL_RLEACCEL requests RLE acceleration for the
  surface; if SDL_RLEACCEL is not specified, the RLE accel will be removed. }


function SDL_SetAlpha(surface: PSDL_Surface; flag: UInt32; alpha: UInt8): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SetAlpha}

{ Sets the clipping rectangle for the destination surface in a blit.

  If the clip rectangle is NULL, clipping will be disabled.
  If the clip rectangle doesn't intersect the surface, the function will
  return SDL_FALSE and blits will be completely clipped.  Otherwise the
  function returns SDL_TRUE and blits to the surface will be clipped to
  the intersection of the surface area and the clipping rectangle.

  Note that blits are automatically clipped to the edges of the source
  and destination surfaces. }
procedure SDL_SetClipRect(surface: PSDL_Surface; rect: PSDL_Rect); 
cdecl; external;
{$EXTERNALSYM SDL_SetClipRect}

{ Gets the clipping rectangle for the destination surface in a blit.
  'rect' must be a pointer to a valid rectangle which will be filled
  with the correct values. }
procedure SDL_GetClipRect(surface: PSDL_Surface; rect: PSDL_Rect); 
cdecl; external;
{$EXTERNALSYM SDL_GetClipRect}

{ Creates a new surface of the specified format, and then copies and maps
  the given surface to it so the blit of the converted surface will be as
  fast as possible.  If this function fails, it returns NULL.

  The 'flags' parameter is passed to SDL_CreateRGBSurface() and has those
  semantics.  You can also pass SDL_RLEACCEL in the flags parameter and
  SDL will try to RLE accelerate colorkey and alpha blits in the resulting
  surface.

  This function is used internally by SDL_DisplayFormat(). }

function SDL_ConvertSurface(src: PSDL_Surface; fmt: PSDL_PixelFormat; flags: UInt32): PSDL_Surface;
cdecl; external;
{$EXTERNALSYM SDL_ConvertSurface}

{
  This performs a fast blit from the source surface to the destination
  surface.  It assumes that the source and destination rectangles are
  the same size.  If either 'srcrect' or 'dstrect' are NULL, the entire
  surface (src or dst) is copied.  The final blit rectangles are saved
  in 'srcrect' and 'dstrect' after all clipping is performed.
  If the blit is successful, it returns 0, otherwise it returns -1.
 
  The blit function should not be called on a locked surface.
 
  The blit semantics for surfaces with and without alpha and colorkey
  are defined as follows:
 
  RGBA->RGB:
      SDL_SRCALPHA set:
   alpha-blend (using alpha-channel).
   SDL_SRCCOLORKEY ignored.
      SDL_SRCALPHA not set:
   copy RGB.
   if SDL_SRCCOLORKEY set, only copy the pixels matching the
   RGB values of the source colour key, ignoring alpha in the
   comparison.
 
  RGB->RGBA:
      SDL_SRCALPHA set:
   alpha-blend (using the source per-surface alpha value);
   set destination alpha to opaque.
      SDL_SRCALPHA not set:
   copy RGB, set destination alpha to opaque.
      both:
   if SDL_SRCCOLORKEY set, only copy the pixels matching the
   source colour key.
 
  RGBA->RGBA:
      SDL_SRCALPHA set:
   alpha-blend (using the source alpha channel) the RGB values;
   leave destination alpha untouched. [Note: is this correct?]
   SDL_SRCCOLORKEY ignored.
      SDL_SRCALPHA not set:
   copy all of RGBA to the destination.
   if SDL_SRCCOLORKEY set, only copy the pixels matching the
   RGB values of the source colour key, ignoring alpha in the
   comparison.
 
  RGB->RGB:
      SDL_SRCALPHA set:
   alpha-blend (using the source per-surface alpha value).
      SDL_SRCALPHA not set:
   copy RGB.
      both:
   if SDL_SRCCOLORKEY set, only copy the pixels matching the
   source colour key.
 
  If either of the surfaces were in video memory, and the blit returns -2,
  the video memory was lost, so it should be reloaded with artwork and
  re-blitted:
  while ( SDL_BlitSurface(image, imgrect, screen, dstrect) = -2 ) do
  begin
  while ( SDL_LockSurface(image) < 0 ) do
   Sleep(10);
  -- Write image pixels to image->pixels --
  SDL_UnlockSurface(image);
 end;

  This happens under DirectX 5.0 when the system switches away from your
  fullscreen application.  The lock will also fail until you have access
  to the video memory again. }

{ You should call SDL_BlitSurface() unless you know exactly how SDL
   blitting works internally and how to use the other blit functions. }

function SDL_BlitSurface(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): Integer;
{$EXTERNALSYM SDL_BlitSurface}

{  This is the public blit function, SDL_BlitSurface(), and it performs
   rectangle validation and clipping before passing it to SDL_LowerBlit() }
function SDL_UpperBlit(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): Integer;
cdecl; external;
{$EXTERNALSYM SDL_UpperBlit}

{ This is a semi-private blit function and it performs low-level surface
  blitting only. }
function SDL_LowerBlit(src: PSDL_Surface; srcrect: PSDL_Rect; dst: PSDL_Surface; dstrect: PSDL_Rect): Integer;
cdecl; external;
{$EXTERNALSYM SDL_LowerBlit}

{ This function performs a fast fill of the given rectangle with 'color'
  The given rectangle is clipped to the destination surface clip area
  and the final fill rectangle is saved in the passed in pointer.
  If 'dstrect' is NULL, the whole surface will be filled with 'color'
  The color should be a pixel of the format used by the surface, and
  can be generated by the SDL_MapRGB() function.
  This function returns 0 on success, or -1 on error. }

function SDL_FillRect(dst: PSDL_Surface; dstrect: PSDL_Rect; color: UInt32) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_FillRect}

{ This function takes a surface and copies it to a new surface of the
  pixel format and colors of the video framebuffer, suitable for fast
  blitting onto the display surface.  It calls SDL_ConvertSurface()

  If you want to take advantage of hardware colorkey or alpha blit
  acceleration, you should set the colorkey and alpha value before
  calling this function.

  If the conversion fails or runs out of memory, it returns NULL }

function SDL_DisplayFormat(surface: PSDL_Surface): PSDL_Surface; cdecl;
external;
{$EXTERNALSYM SDL_DisplayFormat}

{ This function takes a surface and copies it to a new surface of the
  pixel format and colors of the video framebuffer (if possible),
  suitable for fast alpha blitting onto the display surface.
  The new surface will always have an alpha channel.

  If you want to take advantage of hardware colorkey or alpha blit
  acceleration, you should set the colorkey and alpha value before
  calling this function.

  If the conversion fails or runs out of memory, it returns NULL }


function SDL_DisplayFormatAlpha(surface: PSDL_Surface): PSDL_Surface; cdecl;
external;
{$EXTERNALSYM SDL_DisplayFormatAlpha}

//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
//* YUV video surface overlay functions                                       */
//* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

{ This function creates a video output overlay
  Calling the returned surface an overlay is something of a misnomer because
  the contents of the display surface underneath the area where the overlay
  is shown is undefined - it may be overwritten with the converted YUV data. }

function SDL_CreateYUVOverlay(width: Integer; height: Integer; format: UInt32; display: PSDL_Surface): PSDL_Overlay;
cdecl; external;
{$EXTERNALSYM SDL_CreateYUVOverlay}

// Lock an overlay for direct access, and unlock it when you are done
function SDL_LockYUVOverlay(Overlay: PSDL_Overlay): Integer;
cdecl; external;
{$EXTERNALSYM SDL_LockYUVOverlay}

procedure SDL_UnlockYUVOverlay(Overlay: PSDL_Overlay); 
cdecl; external;
{$EXTERNALSYM SDL_UnlockYUVOverlay}


{ Blit a video overlay to the display surface.
  The contents of the video surface underneath the blit destination are
  not defined.
  The width and height of the destination rectangle may be different from
  that of the overlay, but currently only 2x scaling is supported. }

function SDL_DisplayYUVOverlay(Overlay: PSDL_Overlay; dstrect: PSDL_Rect) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_DisplayYUVOverlay}

// Free a video overlay
procedure SDL_FreeYUVOverlay(Overlay: PSDL_Overlay);
cdecl; external;
{$EXTERNALSYM SDL_FreeYUVOverlay}

{------------------------------------------------------------------------------}
{ OpenGL Routines                                                              }
{------------------------------------------------------------------------------}

{ Dynamically load a GL driver, if SDL is built with dynamic GL.

  SDL links normally with the OpenGL library on your system by default,
  but you can compile it to dynamically load the GL driver at runtime.
  If you do this, you need to retrieve all of the GL functions used in
  your program from the dynamic library using SDL_GL_GetProcAddress().

  This is disabled in default builds of SDL. }


function SDL_GL_LoadLibrary(filename: PChar): Integer;
cdecl; external;
{$EXTERNALSYM SDL_GL_LoadLibrary}

{ Get the address of a GL function (for extension functions) }
function SDL_GL_GetProcAddress(procname: PChar) : Pointer;
cdecl; external;
{$EXTERNALSYM SDL_GL_GetProcAddress}

{ Set an attribute of the OpenGL subsystem before intialization. }
function SDL_GL_SetAttribute(attr: TSDL_GLAttr; value: Integer) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_GL_SetAttribute}

{ Get an attribute of the OpenGL subsystem from the windowing
  interface, such as glX. This is of course different from getting
  the values from SDL's internal OpenGL subsystem, which only
  stores the values you request before initialization.

  Developers should track the values they pass into SDL_GL_SetAttribute
  themselves if they want to retrieve these values. }

function SDL_GL_GetAttribute(attr: TSDL_GLAttr; var value: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_GL_GetAttribute}

{ Swap the OpenGL buffers, if double-buffering is supported. }

procedure SDL_GL_SwapBuffers;
cdecl; external;
{$EXTERNALSYM SDL_GL_SwapBuffers;}

{ Internal functions that should not be called unless you have read
  and understood the source code for these functions. }

procedure SDL_GL_UpdateRects(numrects: Integer; rects: PSDL_Rect);
cdecl; external;
{$EXTERNALSYM SDL_GL_UpdateRects}
procedure SDL_GL_Lock;
cdecl; external;
{$EXTERNALSYM SDL_GL_Lock;}
procedure SDL_GL_Unlock;
cdecl; external;
{$EXTERNALSYM SDL_GL_Unlock;}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* These functions allow interaction with the window manager, if any.        *}
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

{ Sets/Gets the title and icon text of the display window }
procedure SDL_WM_GetCaption(var title : PChar; var icon : PChar);
cdecl; external;
{$EXTERNALSYM SDL_WM_GetCaption}
procedure SDL_WM_SetCaption( const title : PChar; const icon : PChar);
cdecl; external;
{$EXTERNALSYM SDL_WM_SetCaption}

{ Sets the icon for the display window.
  This function must be called before the first call to SDL_SetVideoMode().
  It takes an icon surface, and a mask in MSB format.
  If 'mask' is NULL, the entire icon surface will be used as the icon. }
procedure SDL_WM_SetIcon(icon: PSDL_Surface; mask: PUInt8);
cdecl; external;
{$EXTERNALSYM SDL_WM_SetIcon}

{ This function iconifies the window, and returns 1 if it succeeded.
  If the function succeeds, it generates an SDL_APPACTIVE loss event.
  This function is a noop and returns 0 in non-windowed environments. }

function SDL_WM_IconifyWindow: Integer;
cdecl; external;
{$EXTERNALSYM SDL_WM_IconifyWindow}

{ Toggle fullscreen mode without changing the contents of the screen.
  If the display surface does not require locking before accessing
  the pixel information, then the memory pointers will not change.

  If this function was able to toggle fullscreen mode (change from
  running in a window to fullscreen, or vice-versa), it will return 1.
  If it is not implemented, or fails, it returns 0.

  The next call to SDL_SetVideoMode() will set the mode fullscreen
  attribute based on the flags parameter - if SDL_FULLSCREEN is not
  set, then the display will be windowed by default where supported.

  This is currently only implemented in the X11 video driver. }

function SDL_WM_ToggleFullScreen(surface: PSDL_Surface): Integer;
cdecl; external;
{$EXTERNALSYM SDL_WM_ToggleFullScreen}

{ Grabbing means that the mouse is confined to the application window,
  and nearly all keyboard input is passed directly to the application,
  and not interpreted by a window manager, if any. }

function SDL_WM_GrabInput(mode: TSDL_GrabMode): TSDL_GrabMode;
cdecl; external;
{$EXTERNALSYM SDL_WM_GrabInput}

{------------------------------------------------------------------------------}
{ mouse-routines }
{------------------------------------------------------------------------------}

{ Retrieve the current state of the mouse.
  The current button state is returned as a button bitmask, which can
  be tested using the SDL_BUTTON(X) macros, and x and y are set to the
  current mouse cursor position.  You can pass NULL for either x or y. }

function SDL_GetMouseState(var x: Integer; var y: Integer): UInt8;
cdecl; external;
{$EXTERNALSYM SDL_GetMouseState}

{ Retrieve the current state of the mouse.
  The current button state is returned as a button bitmask, which can
  be tested using the SDL_BUTTON(X) macros, and x and y are set to the
  mouse deltas since the last call to SDL_GetRelativeMouseState(). }
function SDL_GetRelativeMouseState(var x: Integer; var y: Integer): UInt8;
cdecl; external;
{$EXTERNALSYM SDL_GetRelativeMouseState}

{ Set the position of the mouse cursor (generates a mouse motion event) }
procedure SDL_WarpMouse(x, y: UInt16);
cdecl; external;
{$EXTERNALSYM SDL_WarpMouse}

{ Create a cursor using the specified data and mask (in MSB format).
  The cursor width must be a multiple of 8 bits.

  The cursor is created in black and white according to the following:
  data  mask    resulting pixel on screen
   0     1       White
   1     1       Black
   0     0       Transparent
   1     0       Inverted color if possible, black if not.

  Cursors created with this function must be freed with SDL_FreeCursor(). }
function SDL_CreateCursor(data, mask: PUInt8; w, h, hot_x, hot_y: Integer): PSDL_Cursor;
cdecl; external;
{$EXTERNALSYM SDL_CreateCursor}

{ Set the currently active cursor to the specified one.
  If the cursor is currently visible, the change will be immediately
  represented on the display. }
procedure SDL_SetCursor(cursor: PSDL_Cursor);
cdecl; external;
{$EXTERNALSYM SDL_SetCursor}

{ Returns the currently active cursor. }
function SDL_GetCursor: PSDL_Cursor;
cdecl; external;
{$EXTERNALSYM SDL_GetCursor}

{ Deallocates a cursor created with SDL_CreateCursor(). }
procedure SDL_FreeCursor(cursor: PSDL_Cursor);
cdecl; external;
{$EXTERNALSYM SDL_FreeCursor}

{ Toggle whether or not the cursor is shown on the screen.
  The cursor start off displayed, but can be turned off.
  SDL_ShowCursor() returns 1 if the cursor was being displayed
  before the call, or 0 if it was not.  You can query the current
  state by passing a 'toggle' value of -1. }
function SDL_ShowCursor(toggle: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_ShowCursor}

function SDL_BUTTON( Button : Integer ) : Integer;

{------------------------------------------------------------------------------}
{ Keyboard-routines                                                            }
{------------------------------------------------------------------------------}

{ Enable/Disable UNICODE translation of keyboard input.
  This translation has some overhead, so translation defaults off.
  If 'enable' is 1, translation is enabled.
  If 'enable' is 0, translation is disabled.
  If 'enable' is -1, the translation state is not changed.
  It returns the previous state of keyboard translation. }
function SDL_EnableUNICODE(enable: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_EnableUNICODE}

{ If 'delay' is set to 0, keyboard repeat is disabled. }
function SDL_EnableKeyRepeat(delay: Integer; interval: Integer): Integer;
cdecl; external;
{$EXTERNALSYM SDL_EnableKeyRepeat}

procedure SDL_GetKeyRepeat(delay : PInteger; interval: PInteger);
cdecl; external;
{$EXTERNALSYM SDL_GetKeyRepeat}

{ Get a snapshot of the current state of the keyboard.
  Returns an array of keystates, indexed by the SDLK_* syms.
  Used:

  UInt8 *keystate = SDL_GetKeyState(NULL);
  if ( keystate[SDLK_RETURN] ) ... <RETURN> is pressed }

function SDL_GetKeyState(numkeys: PInt): PUInt8;
cdecl; external;
{$EXTERNALSYM SDL_GetKeyState}

{ Get the current key modifier state }
function SDL_GetModState: TSDLMod;
cdecl; external;
{$EXTERNALSYM SDL_GetModState}

{ Set the current key modifier state
  This does not change the keyboard state, only the key modifier flags. }
procedure SDL_SetModState(modstate: TSDLMod);
cdecl; external;
{$EXTERNALSYM SDL_SetModState}

{ Get the name of an SDL virtual keysym }
function SDL_GetKeyName(key: TSDLKey): PChar;
cdecl; external;
{$EXTERNALSYM SDL_GetKeyName}

{------------------------------------------------------------------------------}
{ Active Routines                                                              }
{------------------------------------------------------------------------------}

{ This function returns the current state of the application, which is a
  bitwise combination of SDL_APPMOUSEFOCUS, SDL_APPINPUTFOCUS, and
  SDL_APPACTIVE.  If SDL_APPACTIVE is set, then the user is able to
  see your application, otherwise it has been iconified or disabled. }

function SDL_GetAppState: UInt8;
cdecl; external;
{$EXTERNALSYM SDL_GetAppState}


{ Mutex functions }

{ Create a mutex, initialized unlocked }

function SDL_CreateMutex: PSDL_Mutex;
cdecl; external;
{$EXTERNALSYM SDL_CreateMutex}

{ Lock the mutex  (Returns 0, or -1 on error) }

 function SDL_mutexP(mutex: PSDL_mutex): Integer;
 cdecl; external;
{ $ EXTERNALSYM SDL_mutexP}

function SDL_LockMutex(mutex: PSDL_mutex): Integer;
{$EXTERNALSYM SDL_LockMutex}

{ Unlock the mutex  (Returns 0, or -1 on error) }
function SDL_mutexV(mutex: PSDL_mutex): Integer;
cdecl; external;
{$EXTERNALSYM SDL_mutexV}

function SDL_UnlockMutex(mutex: PSDL_mutex): Integer;
{$EXTERNALSYM SDL_UnlockMutex}

{ Destroy a mutex }
procedure SDL_DestroyMutex(mutex: PSDL_mutex);
cdecl; external;
{$EXTERNALSYM SDL_DestroyMutex}

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ Semaphore functions                                           }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ Create a semaphore, initialized with value, returns NULL on failure. }
function SDL_CreateSemaphore(initial_value: UInt32): PSDL_Sem;
cdecl; external;
{$EXTERNALSYM SDL_CreateSemaphore}


{ Destroy a semaphore }
procedure SDL_DestroySemaphore(sem: PSDL_sem);
cdecl; external;
{$EXTERNALSYM SDL_DestroySemaphore}

{ This function suspends the calling thread until the semaphore pointed
  to by sem has a positive count. It then atomically decreases the semaphore
  count. }

function SDL_SemWait(sem: PSDL_sem): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SemWait}

{ Non-blocking variant of SDL_SemWait(), returns 0 if the wait succeeds,
   SDL_MUTEX_TIMEDOUT if the wait would block, and -1 on error. }

function SDL_SemTryWait(sem: PSDL_sem): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SemTryWait}

{ Variant of SDL_SemWait() with a timeout in milliseconds, returns 0 if
   the wait succeeds, SDL_MUTEX_TIMEDOUT if the wait does not succeed in
   the allotted time, and -1 on error.
   On some platforms this function is implemented by looping with a delay
   of 1 ms, and so should be avoided if possible. }

function SDL_SemWaitTimeout(sem: PSDL_sem; ms: UInt32): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SemTryWait}

{ Atomically increases the semaphore's count (not blocking), returns 0,
   or -1 on error. }

function SDL_SemPost(sem: PSDL_sem): Integer;
cdecl; external;
{$EXTERNALSYM SDL_SemTryWait}

{ Returns the current count of the semaphore }

function SDL_SemValue(sem: PSDL_sem): UInt32;
cdecl; external;
{$EXTERNALSYM SDL_SemValue}

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ Condition variable functions                                  }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ Create a condition variable }
function SDL_CreateCond: PSDL_Cond;
cdecl; external;
{$EXTERNALSYM SDL_CreateCond}

{ Destroy a condition variable }
procedure SDL_DestroyCond(cond: PSDL_Cond);
cdecl; external;
{$EXTERNALSYM SDL_DestroyCond}

{ Restart one of the threads that are waiting on the condition variable,
   returns 0 or -1 on error. }

function SDL_CondSignal(cond: PSDL_cond): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CondSignal}

{ Restart all threads that are waiting on the condition variable,
  returns 0 or -1 on error. }

function SDL_CondBroadcast(cond: PSDL_cond): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CondBroadcast}


{ Wait on the condition variable, unlocking the provided mutex.
  The mutex must be locked before entering this function!
  Returns 0 when it is signaled, or -1 on error. }

function SDL_CondWait(cond: PSDL_cond; mut: PSDL_mutex): Integer;
cdecl; external;
{$EXTERNALSYM SDL_CondWait}

{ Waits for at most 'ms' milliseconds, and returns 0 if the condition
  variable is signaled, SDL_MUTEX_TIMEDOUT if the condition is not
  signaled in the allotted time, and -1 on error.
  On some platforms this function is implemented by looping with a delay
  of 1 ms, and so should be avoided if possible. }

function SDL_CondWaitTimeout(cond: PSDL_cond; mut: PSDL_mutex; ms: UInt32) : Integer;
cdecl; external;
{$EXTERNALSYM SDL_CondWaitTimeout}

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ Condition variable functions                                  }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

{ Create a thread }
function SDL_CreateThread(fn: PInt; data: Pointer): PSDL_Thread;
cdecl; external;
{$EXTERNALSYM SDL_CreateThread}

{ Get the 32-bit thread identifier for the current thread }
function SDL_ThreadID: UInt32;
cdecl; external;
{$EXTERNALSYM SDL_ThreadID}

{ Get the 32-bit thread identifier for the specified thread,
  equivalent to SDL_ThreadID() if the specified thread is NULL. }
function SDL_GetThreadID(thread: PSDL_Thread): UInt32;
cdecl; external;
{$EXTERNALSYM SDL_GetThreadID}

{ Wait for a thread to finish.
  The return code for the thread function is placed in the area
  pointed to by 'status', if 'status' is not NULL. }

procedure SDL_WaitThread(thread: PSDL_Thread; var status: Integer);
cdecl; external;
{$EXTERNALSYM SDL_WaitThread}

{ Forcefully kill a thread without worrying about its state }
procedure SDL_KillThread(thread: PSDL_Thread);
cdecl; external;
{$EXTERNALSYM SDL_KillThread}

{------------------------------------------------------------------------------}
{ Get Environment Routines                                                     }
{------------------------------------------------------------------------------}
{$IFDEF WINDOWS}
function _putenv( const variable : Pchar ): integer;
cdecl;
{$ENDIF}

{$IFDEF Unix}
{$IFDEF FPC}
function _putenv( const variable : Pchar ): integer;
cdecl; external 'libc.so' name 'putenv';
{$ENDIF}
{$ENDIF}

{ Put a variable of the form "name=value" into the environment }
//function SDL_putenv(const variable: PChar): integer; cdecl; external {$IFNDEF NDS}{$IFDEF __GPC__}name 'SDL_Init'{$ELSE} SDLLibName{$ENDIF __GPC__}SDLLibName name '';
function SDL_putenv(const variable: PChar): integer;
{$EXTERNALSYM SDL_putenv}

// The following function has been commented out to encourage developers to use
// SDL_putenv as it it more portable
//function putenv(const variable: PChar): integer;
//{$EXTERNALSYM putenv}

{$IFDEF WINDOWS}
{$IFNDEF __GPC__}
function getenv( const name : Pchar ): PChar; cdecl;
{$ENDIF}
{$ENDIF}

{* Retrieve a variable named "name" from the environment }
//function SDL_getenv(const name: PChar): PChar; cdecl; external {$IFNDEF NDS}{$IFDEF __GPC__}name 'SDL_Init'{$ELSE} SDLLibName{$ENDIF __GPC__}SDLLibName name '';
function SDL_getenv(const name: PChar): PChar;
{$EXTERNALSYM SDL_getenv}

// The following function has been commented out to encourage developers to use
// SDL_getenv as it it more portable
//function getenv(const name: PChar): PChar;
//{$EXTERNALSYM getenv}

{*
 * This function gives you custom hooks into the window manager information.
 * It fills the structure pointed to by 'info' with custom information and
 * returns 1 if the function is implemented.  If it's not implemented, or
 * the version member of the 'info' structure is invalid, it returns 0.
 *}
function SDL_GetWMInfo(info : PSDL_SysWMinfo) : integer;
cdecl; external;
{$EXTERNALSYM SDL_GetWMInfo}

{------------------------------------------------------------------------------}

//SDL_loadso.h
{* This function dynamically loads a shared object and returns a pointer
 * to the object handle (or NULL if there was an error).
 * The 'sofile' parameter is a system dependent name of the object file.
 *}
function SDL_LoadObject( const sofile : PChar ) : Pointer;
cdecl; external;
{$EXTERNALSYM SDL_LoadObject}

{* Given an object handle, this function looks up the address of the
 * named function in the shared object and returns it.  This address
 * is no longer valid after calling SDL_UnloadObject().
 *}
function SDL_LoadFunction( handle : Pointer; const name : PChar ) : Pointer;
cdecl; external;
{$EXTERNALSYM SDL_LoadFunction}

{* Unload a shared object from memory *}
procedure SDL_UnloadObject( handle : Pointer );
cdecl; external;
{$EXTERNALSYM SDL_UnloadObject}



{------------------------------------------------------------------------------}

function SDL_Swap32(D: Uint32): Uint32;
{$EXTERNALSYM SDL_Swap32}

