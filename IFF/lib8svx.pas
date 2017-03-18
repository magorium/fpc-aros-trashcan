unit lib8svx;

{*
 * Copyright (c) 2012 Sander van der Burg
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *}

  //   ***   Pascal conversion by magorium, 2015   ***   //

{$MODE OBJFPC}{$H+}

interface

Uses
  ctypes, libiff;



// ###########################################################################
// ###
// ###      type definitions
// ###
// ###########################################################################



//////////////////////////////////////////////////////////////////////////////
//        voice8header.h
//////////////////////////////////////////////////////////////////////////////



type
  T8SVX_Compression = 
  (
    _8SVX_CMP_NONE     = 0,
    _8SVX_CMP_FIBDELTA = 1
  );


  P8SVX_Voice8Header = ^T8SVX_Voice8Header;
  _8SVX_Voice8Header = packed record
    parent              : PIFF_Group;

    chunkId             : TIFF_ID;
    chunkSize           : TIFF_Long;

    oneShotHiSamples, 
    repeatHiSamples, 
    samplesPerHiCycle   : TIFF_ULong;
    samplesPerSec       : TIFF_UWord;
    ctOctave            : TIFF_UByte;
    sCompression        : T8SVX_Compression;
    volume              : TIFF_Long;
  end;
  T8SVX_Voice8Header = _8SVX_Voice8Header;



  function  _8SVX_createVoice8Header: P8SVX_Voice8Header;
  function  _8SVX_readVoice8Header(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeVoice8Header(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkVoice8Header(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeVoice8Header(chunk: PIFF_Chunk);
  procedure _8SVX_printVoice8Header(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareVoice8Header(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        plenvelope.h
//////////////////////////////////////////////////////////////////////////////



Type
  P8SVX_EGPoint = ^T8SVX_EGPoint;
  _8SVX_EGPoint = record
    duration    : TIFF_UWord;
    dest        : TIFF_Long;
  end;
  T8SVX_EGPoint = _8SVX_EGPoint;


  P8SVX_PLEnvelope = ^T8SVX_PLEnvelope;
  _8SVX_PLEnvelope = record
    parent          : PIFF_Group;

    chunkId         : TIFF_ID;
    chunkSize       : TIFF_Long;

    egPointLength   : cuint;
    egPoint         : P8SVX_EGPoint;
  end;
  T8SVX_PLEnvelope = _8SVX_PLEnvelope;



  function  _8SVX_createPLEnvelope(const chunkId: PIFF_ID): P8SVX_PLEnvelope;
  function  _8SVX_addToPLEnvelope(plEnvelope: P8SVX_PLEnvelope): P8SVX_EGPoint;
  function  _8SVX_readPLEnvelope(filehandle: THandle; const chunkSize: TIFF_Long; const chunkId: PIFF_ID): PIFF_Chunk;
  function  _8SVX_writePLEnvelope(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkPLEnvelope(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freePLEnvelope(chunk: PIFF_Chunk);
  procedure _8SVX_printPLEnvelope(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_comparePLEnvelope(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        playbackenvelope.h
//////////////////////////////////////////////////////////////////////////////



type
  P8SVX_PlaybackEnvelope = ^T8SVX_PlaybackEnvelope;
  _8SVX_PlaybackEnvelope = Type T8SVX_PLEnvelope;
  T8SVX_PlaybackEnvelope = _8SVX_PlaybackEnvelope;



  function  _8SVX_createPlaybackEnvelope: P8SVX_PlaybackEnvelope;
  function  _8SVX_addToPlaybackEnvelope(playbackEnvelope: P8SVX_PlaybackEnvelope): P8SVX_EGPoint;
  function  _8SVX_readPlaybackEnvelope(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writePlaybackEnvelope(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkPlaybackEnvelope(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freePlaybackEnvelope(chunk: PIFF_Chunk);
  procedure _8SVX_printPlaybackEnvelope(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_comparePlaybackEnvelope(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        name.h
//////////////////////////////////////////////////////////////////////////////



type
  P8SVX_Name = ^T8SVX_Name;
  _8SVX_Name = Type TIFF_RawChunk;
  T8SVX_Name = _8SVX_Name;



  function  _8SVX_createName: P8SVX_Name;
  function  _8SVX_readName(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeName(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkName(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeName(chunk: PIFF_Chunk);
  procedure _8SVX_printName(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareName(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        copyright.h
//////////////////////////////////////////////////////////////////////////////



type
  P8SVX_Copyright = ^T8SVX_Copyright;
  _8SVX_Copyright = Type TIFF_RawChunk;
  T8SVX_Copyright = _8SVX_Copyright;



  function  _8SVX_createCopyright: P8SVX_Copyright;
  function  _8SVX_readCopyright(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeCopyright(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkCopyright(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeCopyright(chunk: PIFF_Chunk);
  procedure _8SVX_printCopyright(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareCopyright(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;


//////////////////////////////////////////////////////////////////////////////
//        author.h
//////////////////////////////////////////////////////////////////////////////



type
  P8SVX_Author = ^T8SVX_Author;
  _8SVX_Author = Type TIFF_RawChunk;
  T8SVX_Author = _8SVX_Author;



  function  _8SVX_createAuthor: P8SVX_Author;
  function  _8SVX_readAuthor(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeAuthor(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkAuthor(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeAuthor(chunk: PIFF_Chunk);
  procedure _8SVX_printAuthor(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareAuthor(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        annotation.h
//////////////////////////////////////////////////////////////////////////////



type
  PP8SVX_Annotation = ^P8SVX_Annotation;
  P8SVX_Annotation = ^T8SVX_Annotation;
  _8SVX_Annotation = Type TIFF_RawChunk;
  T8SVX_Annotation = _8SVX_Annotation;



  function  _8SVX_createAnnotation: P8SVX_Annotation;
  function  _8SVX_readAnnotation(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeAnnotation(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkAnnotation(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeAnnotation(chunk: PIFF_Chunk);
  procedure _8SVX_printAnnotation(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareAnnotation(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        volumecontrol.h
//////////////////////////////////////////////////////////////////////////////



type
  P8SVX_VolumeControl = ^T8SVX_VolumeControl;
  _8SVX_VolumeControl = Type T8SVX_PLEnvelope;
  T8SVX_VolumeControl = _8SVX_VolumeControl;



  function  _8SVX_createVolumeControl: P8SVX_VolumeControl;
  function  _8SVX_addToVolumeControl(volumeControl: P8SVX_VolumeControl): P8SVX_EGPoint;
  function  _8SVX_readVolumeControl(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeVolumeControl(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkVolumeControl(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeVolumeControl(chunk: PIFF_Chunk);
  procedure _8SVX_printVolumeControl(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareVolumeControl(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        body.h
//////////////////////////////////////////////////////////////////////////////



Type
  P8SVX_Body = ^T8SVX_Body;
  _8SVX_Body = record

    parent      : PIFF_Group;

    chunkId     : TIFF_ID;
    chunkSize   : TIFF_Long;

    chunkData   : PIFF_Byte;
  end;
  T8SVX_Body = _8SVX_Body;



  function  _8SVX_createBody: P8SVX_Body;
  function  _8SVX_readBody(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
  function  _8SVX_writeBody(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_checkBody(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_freeBody(chunk: PIFF_Chunk);
  procedure _8SVX_printBody(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compareBody(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



//////////////////////////////////////////////////////////////////////////////
//        instrument.h
//////////////////////////////////////////////////////////////////////////////



Type
  P8SVX_Sample = ^T8SVX_Sample;
  _8SVX_Sample = record

    sampleSize  : cuint;

    body        : PIFF_Byte;
  end;
  T8SVX_Sample = _8SVX_Sample;


  PP8SVX_Instrument = ^P8SVX_Instrument;
  P8SVX_Instrument = ^T8SVX_Instrument;
  _8SVX_Instrument = record

    voice8Header        : P8SVX_Voice8Header;

    name                : P8SVX_Name;

    copyright           : P8SVX_Copyright;

    author              : P8SVX_Author;

    annotationLength    : cuint;
    annotation          : PP8SVX_Annotation;

    volumeControl       : P8SVX_VolumeControl;

    playbackEnvelope    : P8SVX_PlaybackEnvelope;

    body                : P8SVX_Body;
  end;
  T8SVX_Instrument = _8SVX_Instrument;



  function  _8SVX_createInstrument: P8SVX_Instrument;
  function  _8SVX_extractInstruments(chunk: PIFF_Chunk; instrumentsLength: pcuint): PP8SVX_Instrument;
  function  _8SVX_extractSamples(instrument: P8SVX_Instrument; samplesLength: pcuint): P8SVX_Sample;
  function  _8SVX_convertInstrumentToForm(instrument: P8SVX_Instrument): PIFF_Form;
  procedure _8SVX_freeInstrument(instrument: P8SVX_Instrument);
  procedure _8SVX_freeInstruments(instruments: PP8SVX_Instrument; const instrumentsLength: cuint);
  function  _8SVX_checkInstrument(const instrument: P8SVX_Instrument): cint;
  function  _8SVX_checkInstruments(const chunk: PIFF_Chunk; instruments: PP8SVX_Instrument; const instrumentsLength: cuint): cint;
  procedure _8SVX_addAnnotationToInstrument(instrument: P8SVX_Instrument; annotation: P8SVX_Annotation);



//////////////////////////////////////////////////////////////////////////////
//        fibdelta.h
//////////////////////////////////////////////////////////////////////////////



  procedure _8SVX_unpackFibonacciDelta(instrument: P8SVX_Instrument);
  procedure _8SVX_packFibonacciDelta(instrument: P8SVX_Instrument);



//////////////////////////////////////////////////////////////////////////////
//        8svx.h
//////////////////////////////////////////////////////////////////////////////



  function  _8SVX_readFd(filehandle: THandle): PIFF_Chunk;
  function  _8SVX_read(const filename: PChar): PIFF_Chunk;
  function  _8SVX_writeFd(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  _8SVX_write(const filename: PChar; const chunk: PIFF_Chunk): cint;
  procedure _8SVX_free(chunk: PIFF_Chunk);
  function  _8SVX_check(const chunk: PIFF_Chunk): cint;
  procedure _8SVX_print(const chunk: PIFF_Chunk; const indentlevel: cuint);
  function  _8SVX_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



implementation

uses
  CHelpers;



//////////////////////////////////////////////////////////////////////////////
//        voice8header.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_VHDR  = 'VHDR';



function  _8SVX_createVoice8Header: P8SVX_Voice8Header;
var
  voice8Header : P8SVX_Voice8Header;
begin
  voice8Header := P8SVX_Voice8Header(IFF_allocateChunk(CHUNKID_VHDR, sizeof(T8SVX_Voice8Header)));

  if (voice8Header <> Nil)
  then voice8Header^.chunkSize := 3 * sizeof(TIFF_ULong) + sizeof(TIFF_UWord) + sizeof(TIFF_UByte) + sizeof(TIFF_UByte) + sizeof(TIFF_Long);

  result := voice8Header;
end;


function  _8SVX_readVoice8Header(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
var
  voice8Header  : P8SVX_Voice8Header;
  byt           : TIFF_UByte;
begin
  voice8Header := _8SVX_createVoice8Header();

  if (voice8Header <> Nil) then
  begin
    if not(IFF_readULong(filehandle, @voice8Header^.oneShotHiSamples, CHUNKID_VHDR, 'oneShotHiSamples') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;

    if not(IFF_readULong(filehandle, @voice8Header^.repeatHiSamples, CHUNKID_VHDR, 'repeatHiSamples') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;

    if not(IFF_readULong(filehandle, @voice8Header^.samplesPerHiCycle, CHUNKID_VHDR, 'samplesPerHiCycle') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;

    if not(IFF_readUWord(filehandle, @voice8Header^.samplesPerSec, CHUNKID_VHDR, 'samplesPerSec') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;

    if not(IFF_readUByte(filehandle, @voice8Header^.ctOctave, CHUNKID_VHDR, 'ctOctave') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;

    if not(IFF_readUByte(filehandle, @byt, CHUNKID_VHDR, 'sCompression') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;

    voice8Header^.sCompression := T8SVX_Compression(byt);

    if not(IFF_readLong(filehandle, @voice8Header^.volume, CHUNKID_VHDR, 'volume') <> 0) then
    begin
      _8SVX_free(PIFF_Chunk(voice8Header));
      exit(nil);
    end;
  end;

  result := PIFF_Chunk(voice8Header);
end;


function  _8SVX_writeVoice8Header(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  voice8Header : P8SVX_Voice8Header;
begin
  voice8Header := P8SVX_Voice8Header(chunk);

  if not(IFF_writeULong(filehandle, voice8Header^.oneShotHiSamples, CHUNKID_VHDR, 'oneShotHiSamples') <> 0)
    then exit(_FALSE_);

  if not(IFF_writeULong(filehandle, voice8Header^.repeatHiSamples, CHUNKID_VHDR, 'repeatHiSamples') <> 0)
    then exit(_FALSE_);

  if not(IFF_writeULong(filehandle, voice8Header^.samplesPerHiCycle, CHUNKID_VHDR, 'samplesPerHiCycle') <> 0)
    then exit(_FALSE_);

  if not(IFF_writeUWord(filehandle, voice8Header^.samplesPerSec, CHUNKID_VHDR, 'samplesPerSec') <> 0)
    then exit(_FALSE_);

  if not(IFF_writeUByte(filehandle, voice8Header^.ctOctave, CHUNKID_VHDR, 'ctOctave') <> 0)
    then exit(_FALSE_);

  if not(IFF_writeUByte(filehandle, Byte(voice8Header^.sCompression), CHUNKID_VHDR, 'sCompression') <> 0)
    then exit(_FALSE_);

  if not(IFF_writeLong(filehandle, voice8Header^.volume, CHUNKID_VHDR, 'volume') <> 0)
    then exit(_FALSE_);

  result := _TRUE_;
end;


function  _8SVX_checkVoice8Header(const chunk: PIFF_Chunk): cint;
var
  voice8Header : P8SVX_Voice8Header;
begin
  voice8Header := P8SVX_Voice8Header(chunk);

  if ( (voice8Header^.sCompression < _8SVX_CMP_NONE) or (voice8Header^.sCompression > _8SVX_CMP_FIBDELTA) ) then
  begin
    IFF_error('Invalid "VHDR".sCompression value!');
    exit(_FALSE_);
  end;

  result := _TRUE_;
end;


procedure _8SVX_freeVoice8Header(chunk: PIFF_Chunk);
begin
  { intentionally left blank }
end;


procedure _8SVX_printVoice8Header(const chunk: PIFF_Chunk; const indentlevel: cuint);
var
  voice8Header : P8SVX_Voice8Header;
begin
  voice8Header := P8SVX_Voice8Header(chunk);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'oneShotHiSamples  = %u;' + LineEnding, [voice8Header^.oneShotHiSamples]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'repeatHiSamples   = %u;' + LineEnding, [voice8Header^.repeatHiSamples]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'samplesPerHiCycle = %u;' + LineEnding, [voice8Header^.samplesPerHiCycle]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'samplesPerSec     = %u;' + LineEnding, [voice8Header^.samplesPerSec]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'ctOctave          = %u;' + LineEnding, [voice8Header^.ctOctave]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'sCompression      = %u;' + LineEnding, [voice8Header^.sCompression]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'volume            = %d;' + LineEnding, [voice8Header^.volume]);
end;


function  _8SVX_compareVoice8Header(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  voice8Header1 : P8SVX_Voice8Header;
  voice8Header2 : P8SVX_Voice8Header;
begin
  voice8Header1 := P8SVX_Voice8Header(chunk1);
  voice8Header2 := P8SVX_Voice8Header(chunk2);

  if (voice8Header1^.oneShotHiSamples <> voice8Header2^.oneShotHiSamples)
    then exit(_FALSE_);

  if (voice8Header1^.repeatHiSamples <> voice8Header2^.repeatHiSamples)
    then exit(_FALSE_);

  if (voice8Header1^.samplesPerHiCycle <> voice8Header2^.samplesPerHiCycle)
    then exit(_FALSE_);

  if (voice8Header1^.samplesPerSec <> voice8Header2^.samplesPerSec)
    then exit(_FALSE_);

  if (voice8Header1^.ctOctave <> voice8Header2^.ctOctave)
    then exit(_FALSE_);

  if (voice8Header1^.sCompression <> voice8Header2^.sCompression)
    then exit(_FALSE_);

  if (voice8Header1^.volume <> voice8Header2^.volume)
    then exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        plenvelope.c
//////////////////////////////////////////////////////////////////////////////



function  _8SVX_createPLEnvelope(const chunkId: PIFF_ID): P8SVX_PLEnvelope;
var
  plEnvelope : P8SVX_PLEnvelope;
begin
  plEnvelope := P8SVX_PLEnvelope(IFF_allocateChunk(chunkId, sizeof(T8SVX_PLEnvelope)));

  if (plEnvelope <> Nil) then
  begin
    plEnvelope^.egPointLength := 0;
    plEnvelope^.egPoint := Nil;
  end;

  result := plEnvelope;
end;


function  _8SVX_addToPLEnvelope(plEnvelope: P8SVX_PLEnvelope): P8SVX_EGPoint;
var
  egPoint       : P8SVX_EGPoint;
begin
  plEnvelope^.egPoint := P8SVX_EGPoint(ReAllocMem(plEnvelope^.egPoint, (plEnvelope^.egPointLength + 1) * sizeof(T8SVX_EGPoint)));
  egPoint := @plEnvelope^.egPoint[plEnvelope^.egPointLength];
  inc(plEnvelope^.egPointLength);
  plEnvelope^.chunkSize := plEnvelope^.chunkSize + sizeof(T8SVX_EGPoint);

  result := egPoint;
end;


function  _8SVX_readPLEnvelope(filehandle: THandle; const chunkSize: TIFF_Long; const chunkId: PIFF_ID): PIFF_Chunk;
var
  plEnvelope    : P8SVX_PLEnvelope;
  egPoint       : P8SVX_EGPoint;
begin
  plEnvelope := _8SVX_createPLEnvelope(chunkId);

  if (plEnvelope <> Nil) then
  begin
    while (plEnvelope^.chunkSize < chunkSize) do
    begin
      egPoint := _8SVX_addToPLEnvelope(plEnvelope);

      if not(IFF_readUWord(filehandle, @egPoint^.duration, chunkId^, 'duration') <> 0) then
      begin
        FreeMem(egPoint);
        _8SVX_free(PIFF_Chunk(plEnvelope));
      end;

      if not(IFF_readLong(filehandle, @egPoint^.dest, chunkId^, 'dest') <> 0) then
      begin
        FreeMem(egPoint);
        _8SVX_free(PIFF_Chunk(plEnvelope));
      end;
    end;
  end;

  result := PIFF_Chunk(plEnvelope);
end;


function  _8SVX_writePLEnvelope(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  plEnvelope    : P8SVX_PLEnvelope;
  i             : cuint;
  egPoint       : P8SVX_EGPoint;
begin
  plEnvelope := P8SVX_PLEnvelope(chunk);

  i := 0; 
  while (i < plEnvelope^.egPointLength) do
  begin
    egPoint := @plEnvelope^.egPoint[i];

    if not(IFF_writeUWord(filehandle, egPoint^.duration, plEnvelope^.chunkId, 'duration') <> 0)
      then exit(_FALSE_);

    if not(IFF_writeLong(filehandle, egPoint^.dest, plEnvelope^.chunkId, 'dest') <> 0)
      then exit(_FALSE_);

    inc(i);
  end;

  result := _TRUE_;
end;


function  _8SVX_checkPLEnvelope(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure _8SVX_freePLEnvelope(chunk: PIFF_Chunk);
begin
  { intentionally left blank }
end;


procedure _8SVX_printPLEnvelope(const chunk: PIFF_Chunk; const indentlevel: cuint);
var
  plEnvelope : P8SVX_PLEnvelope;
  i          : cuint;
  egPoint    : P8SVX_EGPoint;
begin
  plEnvelope := P8SVX_PLEnvelope(chunk);

  i := 0;
  while (i < plEnvelope^.egPointLength) do
  begin
    egPoint := @plEnvelope^.egPoint[i];
    IFF_printIndent(GetStdOutHandle, indentLevel, '{ duration = %u, dest = %d }' + LineEnding, [egPoint^.duration, egPoint^.dest]);

    inc(i);
  end;
end;


function  _8SVX_comparePLEnvelope(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  plEnvelope1   : P8SVX_PLEnvelope;
  plEnvelope2   : P8SVX_PLEnvelope;
  i             : cuint;
  egPoint1      : P8SVX_EGPoint;
  egPoint2      : P8SVX_EGPoint;
begin
  plEnvelope1 := P8SVX_PLEnvelope(chunk1);
  plEnvelope2 := P8SVX_PLEnvelope(chunk2);

  if (plEnvelope1^.egPointLength = plEnvelope2^.egPointLength) then
  begin

    i := 0;
    while (i < plEnvelope1^.egPointLength) do
    begin
      egPoint1 := @plEnvelope1^.egPoint[i];
      egPoint2 := @plEnvelope2^.egPoint[i];

      if (egPoint1^.duration <> egPoint2^.duration)
        then exit(_FALSE_);

      if (egPoint1^.dest <> egPoint2^.dest)
        then exit(_FALSE_);

      inc(i);
    end;
  end
  else
    exit(_FALSE_);

  result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        playbackenvelope.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_RLSE  = 'RLSE';



function  _8SVX_createPlaybackEnvelope: P8SVX_PlaybackEnvelope;
begin
  result := P8SVX_PlaybackEnvelope(_8SVX_createPLEnvelope(CHUNKID_RLSE));
end;


function  _8SVX_addToPlaybackEnvelope(playbackEnvelope: P8SVX_PlaybackEnvelope): P8SVX_EGPoint;
begin
// ERROR IN ORIGINAL CODE: result := _8SVX_addToPlaybackEnvelope(P8SVX_PLEnvelope(playbackEnvelope));
  result := _8SVX_addToPLEnvelope(P8SVX_PLEnvelope(playbackEnvelope));
end;


function  _8SVX_readPlaybackEnvelope(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := _8SVX_readPLEnvelope(filehandle, chunkSize, CHUNKID_RLSE);
end;


function  _8SVX_writePlaybackEnvelope(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := _8SVX_writePLEnvelope(filehandle, chunk);
end;


function  _8SVX_checkPlaybackEnvelope(const chunk: PIFF_Chunk): cint;
begin
  result := _8SVX_checkPLEnvelope(chunk);
end;


procedure _8SVX_freePlaybackEnvelope(chunk: PIFF_Chunk);
begin
  _8SVX_freePLEnvelope(chunk);
end;


procedure _8SVX_printPlaybackEnvelope(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  _8SVX_printPLEnvelope(chunk, indentLevel);
end;


function  _8SVX_comparePlaybackEnvelope(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := _8SVX_comparePLEnvelope(chunk1, chunk2);
end;



//////////////////////////////////////////////////////////////////////////////
//        name.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_NAME  = 'NAME';



function  _8SVX_createName: P8SVX_Name;
begin
  result := P8SVX_Name(IFF_createRawChunk(CHUNKID_NAME));
end;


function  _8SVX_readName(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := PIFF_Chunk(IFF_readRawChunk(filehandle, CHUNKID_NAME, chunkSize));
end;


function  _8SVX_writeName(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeRawChunk(filehandle, PIFF_RawChunk(chunk));
end;


function  _8SVX_checkName(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure _8SVX_freeName(chunk: PIFF_Chunk);
begin
  IFF_freeRawChunk(PIFF_RawChunk(chunk));
end;


procedure _8SVX_printName(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  IFF_printText(PIFF_RawChunk(chunk), indentLevel);
end;


function  _8SVX_compareName(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2));
end;



//////////////////////////////////////////////////////////////////////////////
//        copyright.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_C = '(c) ';



function  _8SVX_createCopyright: P8SVX_Copyright;
begin
  result := P8SVX_Copyright(IFF_createRawChunk(CHUNKID_C));
end;


function  _8SVX_readCopyright(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := PIFF_Chunk(IFF_readRawChunk(filehandle, CHUNKID_C, chunkSize));
end;


function  _8SVX_writeCopyright(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeRawChunk(filehandle, PIFF_RawChunk(chunk));
end;


function  _8SVX_checkCopyright(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure _8SVX_freeCopyright(chunk: PIFF_Chunk);
begin
  IFF_freeRawChunk(PIFF_RawChunk(chunk));
end;


procedure _8SVX_printCopyright(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  IFF_printText(PIFF_RawChunk(chunk), indentLevel);
end;


function  _8SVX_compareCopyright(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2));
end;



//////////////////////////////////////////////////////////////////////////////
//        author.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_AUTH  = 'AUTH';



function  _8SVX_createAuthor: P8SVX_Author;
begin
  result := P8SVX_Author(IFF_createRawChunk(CHUNKID_AUTH));
end;


function  _8SVX_readAuthor(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := PIFF_Chunk(IFF_readRawChunk(filehandle, CHUNKID_AUTH, chunkSize));
end;


function  _8SVX_writeAuthor(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeRawChunk(filehandle, PIFF_RawChunk(chunk));
end;


function  _8SVX_checkAuthor(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure _8SVX_freeAuthor(chunk: PIFF_Chunk);
begin
  IFF_freeRawChunk(PIFF_RawChunk(chunk));
end;


procedure _8SVX_printAuthor(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  IFF_printText(PIFF_RawChunk(chunk), indentLevel);
end;


function  _8SVX_compareAuthor(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2));
end;



//////////////////////////////////////////////////////////////////////////////
//        annotation.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_ANNO  = 'ANNO';



function  _8SVX_createAnnotation: P8SVX_Annotation;
begin
  result := P8SVX_Annotation(IFF_createRawChunk(CHUNKID_ANNO));
end;


function  _8SVX_readAnnotation(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := PIFF_Chunk(IFF_readRawChunk(filehandle, CHUNKID_ANNO, chunkSize));
end;


function  _8SVX_writeAnnotation(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeRawChunk(filehandle, PIFF_RawChunk(chunk));
end;


function  _8SVX_checkAnnotation(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure _8SVX_freeAnnotation(chunk: PIFF_Chunk);
begin
  IFF_freeRawChunk(PIFF_RawChunk(chunk));
end;


procedure _8SVX_printAnnotation(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  IFF_printText(PIFF_RawChunk(chunk), indentLevel);
end;


function  _8SVX_compareAnnotation(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2));
end;



//////////////////////////////////////////////////////////////////////////////
//        volumecontrol.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_ATAK  = 'ATAK';



function  _8SVX_createVolumeControl: P8SVX_VolumeControl;
begin
  result := P8SVX_VolumeControl(_8SVX_createPLEnvelope(CHUNKID_ATAK));
end;


function  _8SVX_addToVolumeControl(volumeControl: P8SVX_VolumeControl): P8SVX_EGPoint;
begin
// ERROR IN ORIGINAL CODE:  result := _8SVX_addToVolumeControl(P8SVX_PLEnvelope(volumeControl));
  result := _8SVX_addToPLEnvelope(P8SVX_PLEnvelope(volumeControl));
end;


function  _8SVX_readVolumeControl(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := _8SVX_readPLEnvelope(filehandle, chunkSize, CHUNKID_ATAK);
end;


function  _8SVX_writeVolumeControl(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := _8SVX_writePLEnvelope(filehandle, chunk);
end;


function  _8SVX_checkVolumeControl(const chunk: PIFF_Chunk): cint;
begin
  result := _8SVX_checkPLEnvelope(chunk);
end;


procedure _8SVX_freeVolumeControl(chunk: PIFF_Chunk);
begin
  _8SVX_freePLEnvelope(chunk);
end;


procedure _8SVX_printVolumeControl(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  _8SVX_printPLEnvelope(chunk, indentLevel);
end;


function  _8SVX_compareVolumeControl(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := _8SVX_comparePLEnvelope(chunk1, chunk2);
end;



//////////////////////////////////////////////////////////////////////////////
//        body.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID_BODY  = 'BODY';



function  _8SVX_createBody: P8SVX_Body;
begin
  result := P8SVX_Body(IFF_allocateChunk(CHUNKID_BODY, sizeof(_8SVX_Body)));
end;


function  _8SVX_readBody(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;
begin
  result := PIFF_Chunk(IFF_readRawChunk(filehandle, CHUNKID_BODY, chunkSize));
end;


function  _8SVX_writeBody(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeRawChunk(filehandle, PIFF_RawChunk(chunk));
end;


function  _8SVX_checkBody(const chunk: PIFF_Chunk): cint;
begin
  result := _TRUE_;
end;


procedure _8SVX_freeBody(chunk: PIFF_Chunk);
begin
  IFF_freeRawChunk(PIFF_RawChunk(chunk));
end;


procedure _8SVX_printBody(const chunk: PIFF_Chunk; const indentlevel: cuint);
var
  body  : P8SVX_Body;
  i     : cuint;
  byt   : TIFF_Byte;
begin
  body := P8SVX_Body(chunk);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'values = ' + LineEnding);
  IFF_printIndent(GetStdOutHandle, indentLevel + 1, '');

  i := 0;
  while (i < body^.chunkSize) do
  begin
    if ( (i > 0) and (i mod 10 = 0) ) then
    begin
      WriteLn;
      IFF_printIndent(GetStdOutHandle, indentLevel + 1, '');
    end;

    byt := body^.chunkData[i];

    Write(byt, ' ');

    inc(i);
  end;

  WriteLn;
  IFF_printIndent(GetStdOutHandle, indentLevel, ';' + LineEnding);
end;


function  _8SVX_compareBody(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2));
end;



//////////////////////////////////////////////////////////////////////////////
//        instrument.c
//////////////////////////////////////////////////////////////////////////////



function  _8SVX_createInstrument: P8SVX_Instrument;
begin
  result := P8SVX_Instrument(AllocMem(1 * sizeof(T8SVX_Instrument)));
end;


function  _8SVX_extractInstruments(chunk: PIFF_Chunk; instrumentsLength: pcuint): PP8SVX_Instrument;
var
  _8svxFormsLength  : cuint;
  _8svxForms        : PPIFF_Form;
  instruments       : PP8SVX_Instrument;
  i                 : cuint;
  _8svxForm         : PIFF_Form;
  instrument        : P8SVX_Instrument;
begin
   _8svxForms := IFF_searchForms(chunk, '8SVX', @_8svxFormsLength);
  instrumentsLength^ := _8svxFormsLength;

  if (_8svxFormsLength = 0) then
  begin
    IFF_error('No form with formType: "8SVX" found!' + LineEnding);
    exit(nil);
  end
  else
  begin
    instruments := PP8SVX_Instrument(AllocMem(_8svxFormsLength * sizeof(P8SVX_Instrument)));

    i := 0;
    while (i < _8svxFormsLength) do
    begin
      _8svxForm := _8svxForms[i];
      instrument := P8SVX_Instrument(AllocMem(sizeof(T8SVX_Instrument)));

      instrument^.voice8Header := P8SVX_Voice8Header(IFF_getChunkFromForm(_8svxForm, 'VHDR'));
      instrument^.name := P8SVX_Name(IFF_getChunkFromForm(_8svxForm, 'NAME'));
// ERROR IN ORIGINAL CODE:  instrument^.copyright := P8SVX_Name(IFF_getChunkFromForm(_8svxForm, '(c) '));
      instrument^.copyright := P8SVX_Copyright(IFF_getChunkFromForm(_8svxForm, '(c) '));
      instrument^.author := P8SVX_Author(IFF_getChunkFromForm(_8svxForm, 'AUTH'));
      instrument^.annotation := PP8SVX_Annotation(IFF_getChunksFromForm(_8svxForm, 'ANNO', @instrument^.annotationLength));
      instrument^.volumeControl := P8SVX_VolumeControl(IFF_getChunkFromForm(_8svxForm, 'ATAK'));
      instrument^.playbackEnvelope := P8SVX_PlaybackEnvelope(IFF_getChunkFromForm(_8svxForm, 'RLSE'));
      instrument^.body := P8SVX_Body(IFF_getChunkFromForm(_8svxForm, 'BODY'));

      instruments[i] := instrument;

      inc(i);
    end;

    result := instruments;
  end;
end;


function  _8SVX_extractSamples(instrument: P8SVX_Instrument; samplesLength: pcuint): P8SVX_Sample;
var
  samples       : P8SVX_Sample;
  ctOctave      : TIFF_UByte;
  numOfSamples  : cuint;
  offset        : cuint;
  i             : cuint;
  sample        : P8SVX_Sample;
begin
  if ( (instrument^.voice8Header = Nil) or (instrument^.body = Nil) ) then
  begin
    samplesLength^ := 0;
    samples := Nil;
  end
  else
  begin
    ctOctave := instrument^.voice8Header^.ctOctave;
    numOfSamples := instrument^.voice8Header^.oneShotHiSamples + instrument^.voice8Header^.repeatHiSamples;
    offset := 0;

    samplesLength^ := ctOctave;
    samples := P8SVX_Sample(AllocMem(ctOctave * sizeof(T8SVX_Sample)));

    i := 0;
    while (i < ctOctave) do
    begin
      sample := @samples[i];

      sample^.sampleSize := numOfSamples;
      sample^.body := instrument^.body^.chunkData + offset;

      offset := offset + numOfSamples;
      numOfSamples := numOfSamples * 2;

      inc(i);
    end;
  end;

  result := samples;
end;


function  _8SVX_convertInstrumentToForm(instrument: P8SVX_Instrument): PIFF_Form;
var
  form      : PIFF_Form;
  i         : cuint;
begin
  form := IFF_createForm('8SVX');

  if (instrument^.voice8Header <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.voice8Header));

  if (instrument^.name <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.name));

  if (instrument^.copyright <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.copyright));

  if (instrument^.author <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.author));

  i := 0;;
  while (i < instrument^.annotationLength) do
  begin
    IFF_addToForm(form, PIFF_Chunk(instrument^.annotation[i]));
    inc(i);
  end;

  if (instrument^.volumeControl <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.volumeControl));

  if (instrument^.playbackEnvelope <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.playbackEnvelope));

  if (instrument^.body <> Nil)
    then IFF_addToForm(form, PIFF_Chunk(instrument^.body));

  result := form;
end;


procedure _8SVX_freeInstrument(instrument: P8SVX_Instrument);
begin
  FreeMem(instrument^.annotation);
  FreeMem(instrument);
end;


procedure _8SVX_freeInstruments(instruments: PP8SVX_Instrument; const instrumentsLength: cuint);
var
  i : cuint;
begin
  i := 0;
  while (i < instrumentsLength) do
  begin
    _8SVX_freeInstrument(instruments[i]);
    inc(i);
  end;

  FreeMem(instruments);
end;


function  _8SVX_checkInstrument(const instrument: P8SVX_Instrument): cint;
begin
  if (instrument^.voice8Header = Nil) then
  begin
    IFF_error('Error: no voice8header defined!' + LineEnding);
    exit(_FALSE_);
  end;

  if (instrument^.body = Nil) then
  begin
    IFF_error('Error: no body defined!' + LineEnding);
    exit(_FALSE_);
  end;

  result := _TRUE_;
end;


function  _8SVX_checkInstruments(const chunk: PIFF_Chunk; instruments: PP8SVX_Instrument; const instrumentsLength: cuint): cint;
var
  i : cuint;
begin
  //* First, check the 8SVX file for corectness */
  if not(_8SVX_check(chunk) <> 0)
    then exit(_FALSE_);

  //* Check the individual instruments inside the IFF file */
  i := 0;
  while (i < instrumentsLength) do
  begin
    if not(_8SVX_checkInstrument(instruments[i]) <> 0)
      then exit(_FALSE_);

    inc(i);
  end;

  //* Everything seems to be correct */
  result := _TRUE_;
end;


procedure _8SVX_addAnnotationToInstrument(instrument: P8SVX_Instrument; annotation: P8SVX_Annotation);
begin
  instrument^.annotation := PP8SVX_Annotation(ReAllocMem(instrument^.annotation, (instrument^.annotationLength + 1) * sizeof(P8SVX_Instrument)));
  instrument^.annotation[instrument^.annotationLength] := annotation;
  inc(instrument^.annotationLength);
end;



//////////////////////////////////////////////////////////////////////////////
//        fibdelta.c
//////////////////////////////////////////////////////////////////////////////



const
  CODE_TO_DELTA_SIZE    = 16;

  codeToDelta   : array[0..Pred(CODE_TO_DELTA_SIZE)] of TIFF_Byte = 
              ( -34, -21, -13, -8, -5, -3, -2, -1, 0, 1, 2, 3, 5, 8, 13, 21 );


procedure _8SVX_unpackFibonacciDelta(instrument: P8SVX_Instrument);
var
  body                  : P8SVX_Body;
  bytesToDecompress     : cuint;
  chunkSize             : cuint;
  compressedBodyData    : PIFF_Byte;
  uncompressedBodyData  : PIFF_Byte;
  i                     : cuint;
  compressedByte        : TIFF_UByte;
  code                  : cuint;
begin
  if (instrument^.voice8Header^.sCompression = _8SVX_CMP_FIBDELTA) then
  begin
    body := instrument^.body;
    bytesToDecompress := (body^.chunkSize - 2) * 2;
    chunkSize := bytesToDecompress + 1;
    compressedBodyData := body^.chunkData;
    uncompressedBodyData := PIFF_Byte(AllocMem(chunkSize * sizeof(TIFF_Byte)));

    //* First byte of compressed data is padding, second is not compressed */
    uncompressedBodyData[0] := compressedBodyData[1];

    //* Decompress all the other bytes */
    i := 0;
    while (i < bytesToDecompress) do
    begin
      compressedByte := compressedBodyData[i div 2 + 2];

      if (i mod 2 = 0)
      then 
        code := compressedByte shr 4 //* Take high word for even offsets */
      else
        code := compressedByte and $f; //* Take low word for odd offsets */

      uncompressedBodyData[i + 1] := uncompressedBodyData[i] + codeToDelta[code];

      inc(i);
    end;

    //* Free the compressed data */
    FreeMem(body^.chunkData);

    //* Attach uncompressed data to the body chunk */
    IFF_setRawChunkData(PIFF_RawChunk(body), PIFF_UByte(uncompressedBodyData), chunkSize);

    //* Recursively update the chunk sizes */
    IFF_updateChunkSizes(PIFF_Chunk(body));

    //* Change compression flag, since the body is no longer compressed anymore */
    instrument^.voice8Header^.sCompression := _8SVX_CMP_NONE;
  end;
end;


procedure _8SVX_packFibonacciDelta(instrument: P8SVX_Instrument);
var
  body                  : P8SVX_Body;
  chunkSize             : cuint;
  uncompressedBodyData  : PIFF_Byte;
  compressedBodyData    : PIFF_Byte;
  i                     : cuint;
  count                 : cuint;
  previousValue         : TIFF_Byte;
var
  delta                 : cint;
  code                  : cuint;
  minDifference         : cuint;
  j                     : cint;
  difference            : cuint;
begin
  if (instrument^.voice8Header^.sCompression = _8SVX_CMP_NONE) then
  begin
    body := instrument^.body;
    chunkSize := 2 + (body^.chunkSize - 1) div 2;
    uncompressedBodyData := body^.chunkData;
    compressedBodyData := PIFF_Byte(AllocMem(chunkSize * sizeof(TIFF_Byte)));
    count := 2;

    //* First byte is padding */
    compressedBodyData[0] := 0;

    //* Next byte is the first byte of the uncompressed data */
    compressedBodyData[1] := uncompressedBodyData[0];

    //* Compress the remaining bytes */
    previousValue := uncompressedBodyData[0];

    i := 1;
    while (i < body^.chunkSize) do
    begin
      delta := uncompressedBodyData[i] - previousValue; //* Determine the difference relative to the previous sample */
      code := CODE_TO_DELTA_SIZE div 2;

      if (delta <> 0) then
      begin
        minDifference := abs(delta);

        if (delta < 0) then
        begin
          //* Decide which negative value from the table is closest to the delta */
          j := CODE_TO_DELTA_SIZE div 2 - 1;
          while (j >= 0) do
          begin
            difference := abs(codeToDelta[j] - delta);

            if (difference < minDifference) then
            begin
              minDifference := difference;
              code := j;
            end;

            dec(j);
          end;
        end
        else if (delta > 0) then
        begin
          //* Decide which positive value from the table is closest to the delta */

          j := CODE_TO_DELTA_SIZE div 2 + 1;
          while (j < CODE_TO_DELTA_SIZE) do
          begin
            difference := abs(codeToDelta[j] - delta);

            if (difference < minDifference) then
            begin
              minDifference := difference;
              code := j;
            end;

            inc(j);
          end;
        end;
      end;

      //* Write the code word into the first or second part of the compressed byte */

      if (i mod 2 = 0) then
      begin
        compressedBodyData[count] := compressedBodyData[count] or code;
        inc(count); //* For each even value, raise the compressed chunk counter */
      end
      else
        compressedBodyData[count] := code shl 4;

      previousValue := previousValue + codeToDelta[code]; //* We have to use this in order to determine the next delta */

      inc(i);
    end;

    //* Free the uncompressed data */
    FreeMem(body^.chunkData);

    //* Attach compressed data to the body chunk */
    IFF_setRawChunkData(PIFF_RawChunk(body), PIFF_UByte(compressedBodyData), chunkSize);

    //* Recursively update the chunk sizes */
    IFF_updateChunkSizes(PIFF_Chunk(body));

    //* Change compression flag, since the body is compressed now */
    instrument^.voice8Header^.sCompression := _8SVX_CMP_FIBDELTA;
  end;
end;



//////////////////////////////////////////////////////////////////////////////
//        8svx.c
//////////////////////////////////////////////////////////////////////////////



const
  _8SVX_NUM_OF_FORM_TYPES       = 1;
  _8SVX_NUM_OF_EXTENSION_CHUNKS = 8;


  (*
  static IFF_FormExtension _8svxFormExtension[] = {
    {"(c) ", &_8SVX_readCopyright,        &_8SVX_writeCopyright,        &_8SVX_checkCopyright,        &_8SVX_freeCopyright,         &_8SVX_printCopyright, &_8SVX_compareCopyright},
    {"ANNO", &_8SVX_readAnnotation,       &_8SVX_writeAnnotation,       &_8SVX_checkAnnotation,       &_8SVX_freeAnnotation,        &_8SVX_printAnnotation, &_8SVX_compareAnnotation},
    {"ATAK", &_8SVX_readVolumeControl,    &_8SVX_writeVolumeControl,    &_8SVX_checkVolumeControl,    &_8SVX_freeVolumeControl,     &_8SVX_printVolumeControl, &_8SVX_compareVolumeControl},
    {"AUTH", &_8SVX_readAuthor,           &_8SVX_writeAuthor,           &_8SVX_checkAuthor,           &_8SVX_freeAuthor,            &_8SVX_printAuthor, &_8SVX_compareAuthor},
    {"BODY", &_8SVX_readBody,             &_8SVX_writeBody,             &_8SVX_checkBody,             &_8SVX_freeBody,              &_8SVX_printBody, &_8SVX_compareBody},
    {"NAME", &_8SVX_readName,             &_8SVX_writeName,             &_8SVX_checkName,             &_8SVX_freeName,              &_8SVX_printName, &_8SVX_compareName},
    {"RLSE", &_8SVX_readPlaybackEnvelope, &_8SVX_writePlaybackEnvelope, &_8SVX_checkPlaybackEnvelope, &_8SVX_freePlaybackEnvelope,  &_8SVX_printPlaybackEnvelope, &_8SVX_comparePlaybackEnvelope},
    {"VHDR", &_8SVX_readVoice8Header,     &_8SVX_writeVoice8Header,     &_8SVX_checkVoice8Header,     &_8SVX_freeVoice8Header,      &_8SVX_printVoice8Header, &_8SVX_compareVoice8Header}
  };
  *)
  
  _8svxids : array[0..Pred(_8SVX_NUM_OF_EXTENSION_CHUNKS)] of TIFF_ID =
  (
    '(c) ', 'ANNO', 'ATAK', 'AUTH', 'BODY', 'NAME', 'RLSE', 'VHDR'
  );

  _8svxFormExtension : Array[0..Pred(_8SVX_NUM_OF_EXTENSION_CHUNKS)] of TIFF_FormExtension =
  (
    ( chunkId : @_8svxids[0]; readchunk: @_8SVX_readCopyright;        writechunk: @_8SVX_writeCopyright;        checkchunk: @_8SVX_checkCopyright;        freeChunk: @_8SVX_freeCopyright;        printChunk: @_8SVX_printCopyright;        compareChunk: @_8SVX_compareCopyright),
    ( chunkId : @_8svxids[1]; readchunk: @_8SVX_readAnnotation;       writechunk: @_8SVX_writeAnnotation;       checkchunk: @_8SVX_checkAnnotation;       freeChunk: @_8SVX_freeAnnotation;       printChunk: @_8SVX_printAnnotation;       compareChunk: @_8SVX_compareAnnotation),
    ( chunkId : @_8svxids[2]; readchunk: @_8SVX_readVolumeControl;    writechunk: @_8SVX_writeVolumeControl;    checkchunk: @_8SVX_checkVolumeControl;    freeChunk: @_8SVX_freeVolumeControl;    printChunk: @_8SVX_printVolumeControl;    compareChunk: @_8SVX_compareVolumeControl),
    ( chunkId : @_8svxids[3]; readchunk: @_8SVX_readAuthor;           writechunk: @_8SVX_writeAuthor;           checkchunk: @_8SVX_checkAuthor;           freeChunk: @_8SVX_freeAuthor;           printChunk: @_8SVX_printAuthor;           compareChunk: @_8SVX_compareAuthor),
    ( chunkId : @_8svxids[4]; readchunk: @_8SVX_readBody;             writechunk: @_8SVX_writeBody;             checkchunk: @_8SVX_checkBody;             freeChunk: @_8SVX_freeBody;             printChunk: @_8SVX_printBody;             compareChunk: @_8SVX_compareBody),
    ( chunkId : @_8svxids[5]; readchunk: @_8SVX_readName;             writechunk: @_8SVX_writeName;             checkchunk: @_8SVX_checkName;             freeChunk: @_8SVX_freeName;             printChunk: @_8SVX_printName;             compareChunk: @_8SVX_compareName),
    ( chunkId : @_8svxids[6]; readchunk: @_8SVX_readPlaybackEnvelope; writechunk: @_8SVX_writePlaybackEnvelope; checkchunk: @_8SVX_checkPlaybackEnvelope; freeChunk: @_8SVX_freePlaybackEnvelope; printChunk: @_8SVX_printPlaybackEnvelope; compareChunk: @_8SVX_comparePlaybackEnvelope),
    ( chunkId : @_8svxids[7]; readchunk: @_8SVX_readVoice8Header;     writechunk: @_8SVX_writeVoice8Header;     checkchunk: @_8SVX_checkVoice8Header;     freeChunk: @_8SVX_freeVoice8Header;     printChunk: @_8SVX_printVoice8Header;     compareChunk: @_8SVX_compareVoice8Header)
  );


  (*
    static IFF_Extension extension[] = {
      {"8SVX", _8SVX_NUM_OF_EXTENSION_CHUNKS, _8svxFormExtension}
    };
  *)

  _8svxft : array[0..Pred(_8SVX_NUM_OF_FORM_TYPES)] of TIFF_ID =
  (
    '8SVX'
  );

  extension : Array[0..Pred(_8SVX_NUM_OF_FORM_TYPES)] of TIFF_Extension =
  (
    ( formType : @_8svxft[0]; formExtensionsLength: _8SVX_NUM_OF_EXTENSION_CHUNKS; formExtensions: @_8svxFormExtension)
  );



function  _8SVX_readFd(filehandle: THandle): PIFF_Chunk;
begin
  result := IFF_readFd(filehandle, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


function  _8SVX_read(const filename: PChar): PIFF_Chunk;
begin
  result := IFF_read(filename, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


function  _8SVX_writeFd(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeFd(filehandle, chunk, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


function  _8SVX_write(const filename: PChar; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_write(filename, chunk, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


procedure _8SVX_free(chunk: PIFF_Chunk);
begin
  IFF_free(chunk, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


function  _8SVX_check(const chunk: PIFF_Chunk): cint;
begin
  result := IFF_check(chunk, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


procedure _8SVX_print(const chunk: PIFF_Chunk; const indentlevel: cuint);
begin
  IFF_print(chunk, 0, extension, _8SVX_NUM_OF_FORM_TYPES);
end;


function  _8SVX_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compare(chunk1, chunk2, extension, _8SVX_NUM_OF_FORM_TYPES);
end;



end.
