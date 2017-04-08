unit amiga.hunk;

{
    ATTENTION:
    Processing the symbol table apparantly takes a shitload of time to do on 
    native Amiga system

    ToDo:
    Add support for HUNK_DEBUG
}


{$MODE OBJFPC}{$H+}

// Next defines enables code that can only be performed on Amiga platform
{$IFDEF AMIGA}
  {$DEFINE AUTO_LOAD_SYMBOLS}   // Auto-load hunks from this program executable
  {$IFDEF AUTO_LOAD_SYMBOLS}
    {$DEFINE AUTO_SAVE_SYMBOLS} // Auto-save hunk info loaded above into .symbol file
    {$DEFINE AUTO_SEGMENTS}     // Auto fill segment information from this process
  {$ENDIF}
{$ENDIF}

// Next defines tells how many (runtime) debug information to produce
{.$DEFINE VERBOSE_DEBUG}         // every routine entry and exit is emitted
{$DEFINE VERBOSE_LOAD}

interface

uses
  classes;

type
  THunkSymbol = record
    Offset : PtrUInt;
    Name   : AnsiString;
  end;

  THunkType = (htUnknown, htCODE, htBSS, htDATA);

  THunkSegment = record
    HunkType : THunkType;
    Size     : LongWord;
    Address  : Pointer;
    Symbols  : array of THunkSymbol;
  end;

  THunkSymTable = class
   private
    FSymTab : array of THunkSegment;
   private
    procedure Dump_Hunk_Info;
    procedure CheckFill_Segments_with_Hunks;
   protected
    function  Read08(strm: TStream): Byte;
    function  Read16(strm: TStream): Word;
    function  Read32(strm: TStream): LongWord;
    function  ReadString(strm: TStream): AnsiString;
    procedure SkipBytes(strm: TStream; amount: integer);
    procedure ReadHunks(strm: TStream);
   protected
    procedure AddSymbol(HunkIndex: Integer; SymbolName: AnsiString; SymbolOffset: LongWord);
    function  AddHunk(HunkType: THunkType; Size: LongWord): integer;
   public
    Constructor Create;
    procedure LoadFromFile(const fn: String);
    procedure LoadFromStream(strm: TStream);
    procedure SaveInfoToFile(const fn: String);
    procedure SaveInfoToStream(strm: TStream);
    Function  GetSymbolName(address: Pointer): AnsiString;
  end;


var
  HunkSymbols : THunkSymTable;



///////////////////////////////////////////////////////////////////////////////
//
//
//          Unit Implementation
//
//
///////////////////////////////////////////////////////////////////////////////



implementation

uses
  amiga.hunk.debug, 
  {$IFDEF HASAMIGA}
  Exec, AmigaDOS,
  {$ENDIF}
  StrUtils, SysUtils;


function Between(Value: Pointer; Bottom: Pointer; Top: Pointer): boolean;
begin
  Result := (Value >= Bottom) and (Value < Top);
end;


// no desire atm to figure out which platform specific includes contains what.
const
  HUNK_UNIT         = $03e7;
  HUNK_NAME         = $03e8;
  HUNK_CODE         = $03e9;
  HUNK_DATA         = $03ea;
  HUNK_BSS          = $03eb;
  HUNK_RELOC32      = $03ec;
  HUNK_RELOC16      = $03ed;
  HUNK_RELOC8       = $03ee;
  HUNK_EXT          = $03ef;
  HUNK_SYMBOL       = $03f0;
  HUNK_DEBUG        = $03f1;
  HUNK_END          = $03f2;
  HUNK_HEADER       = $03f3;
  HUNK_OVERLAY      = $03f5;
  HUNK_BREAK        = $03f6;
  HUNK_DREL32       = $03f7;
  HUNK_DREL16       = $03f8;
  HUNK_DREL8        = $03f9;
  HUNK_LIB          = $03fa;
  HUNK_INDEX        = $03fb;
  HUNK_RELOC32SHORT = $03fc;
  HUNK_RELRELOC32   = $03fd;
  HUNK_ABSRELOC16   = $03fe;
  HUNK_PPC_CODE     = $04e9;
  HUNK_RELRELOC26   = $04ec;


{$IFDEF VERBOSE_LOAD}
procedure Verbose(hunkid: LongWord);
const
  CURRENTROUTINE = 'Verbose';
var
  M: String;
begin
  Enter(CURRENTROUTINE);

  case hunkid of
    HUNK_UNIT         : M := 'HUNK_UNIT';
    HUNK_NAME         : M := 'HUNK_NAME';
    HUNK_CODE         : M := 'HUNK_CODE';
    HUNK_DATA         : M := 'HUNK_DATA';
    HUNK_BSS          : M := 'HUNK_BSS';
    HUNK_RELOC32      : M := 'HUNK_RELOC32';
    HUNK_RELOC16      : M := 'HUNK_RELOC16';
    HUNK_RELOC8       : M := 'HUNK_RELOC8';
    HUNK_EXT          : M := 'HUNK_EXT';
    HUNK_SYMBOL       : M := 'HUNK_SYMBOL';
    HUNK_DEBUG        : M := 'HUNK_DEBUG';
    HUNK_END          : M := 'HUNK_END';
    HUNK_HEADER       : M := 'HUNK_HEADER';
    HUNK_OVERLAY      : M := 'HUNK_OVERLAY';
    HUNK_BREAK        : M := 'HUNK_BREAK';
    HUNK_DREL32       : M := 'HUNK_DREL32';
    HUNK_DREL16       : M := 'HUNK_DREL16';
    HUNK_DREL8        : M := 'HUNK_DREL8';
    HUNK_LIB          : M := 'HUNK_LIB';
    HUNK_INDEX        : M := 'HUNK_INDEX';
    HUNK_RELOC32SHORT : M := 'HUNK_RELOC32SHORT';
    HUNK_RELRELOC32   : M := 'HUNK_RELRELOC32';
    HUNK_ABSRELOC16   : M := 'HUNK_ABSRELOC16';
    HUNK_PPC_CODE     : M := 'HUNK_PPC_CODE';
    HUNK_RELRELOC26   : M := 'HUNK_RELRELOC26';
    OtherWise           M := '<impossible>';
  end;

  WriteLn('Processing ', M);  

  Leave(CURRENTROUTINE);
end;
{$ENDIF}


{$IFDEF AUTO_SEGMENTS}
type
  TSegmentInfoItem = record
    sii_Size  : LongWord;
    sii_Code  : Pointer;
  end;

var
  SegmentInfo : array of TSegmentInfoItem;
{$ENDIF}


{$IFDEF AUTO_SEGMENTS}
type
  PBPTR = ^BPTR;


const
  {$IFDEF AMIGA}
  BNULL = 0;
  {$ENDIF}

type
  PSegListEntry = ^TSegListEntry;
  TSegListEntry = packed record
    sle_Size      : LongInt;
    sle_NextSeg   : BPTR;
    sle_FirstCode : array[0..0] of byte;
  end;

  PSegListArray = ^TSegListArray;
  TSegListArray = array[0..0] of BPTR;


procedure Dump_Segment_Information;
const
  CURRENTROUTINE = 'Dump_Segment_Information';
var
  Segment   : TSegmentInfoItem;
  index     : integer = 0;
begin
  Enter(CURRENTROUTINE);

  if ( Length(SegmentInfo) > 0 ) then
  begin
    WriteLn('-----------------------------------');
    WriteLn('       Segment Information         ');
    WriteLn('-----------------------------------');
    WriteLn('#':2,' Size':10,'   Start':10,'   End':10);
    WriteLn('-----------------------------------');

    for Segment in SegmentInfo do
    begin
      WriteLn
      (
        index:2, 
        ' '  , Segment.sii_Size:10,
        '  $', HexStr(Segment.sii_Code),
        '  $', HexStr(Segment.sii_Code + Segment.sii_Size)
      );
      inc(index);
    end;
  end
  else
    WriteLn('There is no Segment information available');

  Leave(CURRENTROUTINE);
end;


// Convulated and over-documented way of retrieving segment list info from process
procedure Get_Segment_Information(ThisProcess: PProcess);
const
  CURRENTROUTINE = 'Get_Segment_Information';
var
  CLI           : PCommandLineInterface;
  SegList       : PBPTR = nil;
  SegListArray  : PSegListArray;
  SegListEntry  : PSegListEntry;
begin
  Enter(CURRENTROUTINE);

  Forbid();

  // Determine whether or not started from cli
  if ( ThisProcess^.pr_Cli <> BNULL ) then 
  begin
    // Field pr_Cli is a BPTR to struct CommandLineInterface
    CLI := BADDR(ThisProcess^.pr_CLI);
    // Field cli_Module of struct CommandLineInterface is a BPTR to the
    // SegList of the current loaded command
    SegList := BADDR(CLI^.cli_Module);
  end
  else
  if ( ThisProcess^.pr_SegList <> BNULL ) then
  begin
    // pr_SegList is a BPTR to an array of seg lists (an array of BPTR's)
    SegListArray := BADDR(ThisProcess^.pr_SegList);
    // The 4th entry (?) in that array is a BPTR of the current loaded command
    {$PUSH}{$R-}
    SegList := BADDR(SegListArray^[3]); // Note: be explicit
    {$POP}
  end
  else
    WriteLn('Apparantly this program was not started at all. Confused ? So am i');

  (*
    Note that at this point (for OS3, AROS and MOS, not OS4) the SegList
    pointer can still point to an invalid memory address. Therefor scout
    uses the following construct to account for that:
    :::> if (!points2ram((APTR)seg)) seg = NULL;
  *)

  if assigned(SegList) then
  begin
    SegListEntry := Pointer(SegList);
    
    // which segment exactly for the code segment ?
    // do this follow hunk position inside executable ?
    while assigned(SegListEntry) do
    begin
      // Be very explicit in order to 'reposition' the pointer to
      // the new list entry.
      SegListEntry := Pointer(Pointer(SegListEntry) - Pointer(4));
    
      SetLength(SegmentInfo, Succ(Length(SegmentInfo)));
      // A SegListItem is actually a memory allocation's internal structure
      // which includes the size and pointer to the next item in the list
      // Because of that, the size field value includes these 2 longwords, and 
      // which need to be subtracted to get the 'actual' size for the entry
      SegmentInfo[high(SegmentInfo)].sii_size :=  SegListEntry^.sle_Size - 8;
      SegmentInfo[high(SegmentInfo)].sii_Code := @SegListEntry^.sle_FirstCode;

      SegListEntry := BADDR(SegListEntry^.sle_NextSeg);
    end;
    WriteLn('Segment information for this process was retrieved');
  end
  else
    WriteLn('Program was loaded but there were no segments found. Ergo it is impossible to receive this message.. huh ? what ?');

  Permit();

  Leave(CURRENTROUTINE);
end;


procedure Get_Segment_Information;
const
  CURRENTROUTINE = 'Get_Segment_Information';
var
  ThisTask : PTask;
begin
  Enter(CURRENTROUTINE);

  ThisTask := FindTask(nil);

  if Assigned(ThisTask) then
  begin
    {$IFDEF VERBOSE_LOAD}
    WriteLn('TaskName = ', ThisTask^.tc_Node.ln_Name);
    {$ENDIF}

    // we can ony do this when we're actually a process
    if ThisTask^.tc_Node.ln_Type = NT_PROCESS then
    begin
      Get_Segment_Information(PProcess(ThisTask));
    end
    else
      Writeln('Unable to analyze a non process');
  end
  else 
    WriteLn('Unable to find myself : i am serously screwed up');

  Leave(CURRENTROUTINE);
end;
{$ENDIF}



///////////////////////////////////////////////////////////////////////////////
//
//
//          Class THunkSymTable
//
//
///////////////////////////////////////////////////////////////////////////////



constructor THunkSymTable.Create;
const
  CURRENTROUTINE = 'THunkSymTable.Create';
begin
  Enter(CURRENTROUTINE);
  inherited;
  // Once upon a time there used to be code here
  Leave(CURRENTROUTINE);
end;


// search for address in hunk arrays and when found return its symbol name
function  THunkSymTable.GetSymbolName(address: Pointer): AnsiString;
const
  CURRENTROUTINE = 'THunkSymTable.GetSymbolName';
var
  Segment           : THunkSegment;
  Symbol            : THunkSymbol;
  OffSetToLookFor   : PtrUInt;
  i                 : integer = 0;
begin
  Enter(CURRENTROUTINE);

  Result := '<unknown>';

  for Segment in FSymTab do
  begin
    if Between(address, Segment.Address, Segment.Address + Segment.Size) then
    begin
      OffSetToLookFor := address - Segment.Address;
      WriteLn('Looking for offset $', HexStr(OffSetToLookFor,8), ' in segment with index : ', i);
      for Symbol in Segment.Symbols do
      begin
        if Symbol.Offset = OffSetToLookFor then
        begin
          // extra check to circumvent clash with special debug symbols: 
          // skip symbol names prefixed with "DEBUGSTART_"
          if AnsiStartsText('DEBUGSTART_', Symbol.Name) then continue;
          Leave(CURRENTROUTINE);
          exit(Symbol.Name);
        end;
      end;
    end;  
    inc(i);
  end;

  Leave(CURRENTROUTINE);
end;


// add a new hunk to the Symtab, set type as provided and return its (hunkarray) index
function  THunkSymTable.AddHunk(HunkType: THunkType; Size: LongWord): integer;
const
  CURRENTROUTINE = 'THunkSymTable.AddHunk';
begin
  Enter(CURRENTROUTINE);

  SetLength(FSymTab, Succ(Length(FSymTab)));
  FSymTab[High(FSymTab)].HunkType := HunkType;
  FSymTab[High(FSymTab)].Size     := Size;
  FSymTab[High(FSymTab)].Address  := nil;
  Result := High(FSymTab);

  Leave(CURRENTROUTINE);
end;


// Add provided symbolname to corresponding hunkindex array with provided SymbolOffset
procedure THunkSymTable.AddSymbol(HunkIndex: Integer; SymbolName: AnsiString; SymbolOffset: LongWord);
const
  CURRENTROUTINE = 'THunkSymTable.AddSymbol';
var
  SymbolIndex  : Integer;
begin
  Enter(CURRENTROUTINE);

  if ( (HunkIndex > High(FSymTab)) or (HunkIndex < Low(FSymTab)) ) then 
  begin
    Leave(CURRENTROUTINE);
    exit;
  end;

  SetLength(FSymTab[HunkIndex].Symbols, Succ(Length(FSymTab[HunkIndex].Symbols)));

  SymbolIndex := High(FSymTab[HunkIndex].Symbols);

  FSymTab[HunkIndex].Symbols[SymbolIndex].Name   := SymbolName;
  FSymTab[HunkIndex].Symbols[SymbolIndex].Offset := SymbolOffset;

  Leave(CURRENTROUTINE);
end;


// load hunks from provided filename
procedure THunkSymTable.LoadFromFile(const fn: String);
const
  CURRENTROUTINE = 'THunkSymTable.LoadFromFile';
var
  strm : TFileStream;
begin
  Enter(CURRENTROUTINE);

  SetLength(FSymTab, 0);

  strm := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);  
  try
    LoadFromStream(strm);
  finally
    strm.Free;
  end;

  Leave(CURRENTROUTINE);
end;


// load hunks from provided stream
procedure THunkSymTable.LoadFromStream(strm: TStream);
const
  CURRENTROUTINE = 'THunkSymTable.LoadFromStream';
begin
  Enter(CURRENTROUTINE);

  // Process the hunks for the executable, store symbols in symtab
  ReadHunks(strm);
  // Check/Fill the delta between symbol offsets and real loading address
  CheckFill_Segments_with_Hunks;
  {$IFDEF VERBOSE_LOAD}
  Dump_Hunk_Info;
  {$ENDIF}

  Leave(CURRENTROUTINE);
end;


// dump current list of symbols to some readable output on disk
procedure THunkSymTable.SaveInfoToFile(const fn: string);
const
  CURRENTROUTINE = 'THunkSymTable.SaveInfoToFile';
var 
  strm : TFileStream;
begin
  Enter(CURRENTROUTINE);

  strm := TFileStream.Create(fn, fmCreate);
  try
    SaveInfoToStream(strm);
  finally
    strm.Free;
  end;

  Leave(CURRENTROUTINE);
end;


// dump current list of symbols to some readable output to stream
procedure THunkSymTable.SaveInfoToStream(strm: TStream);
const
  CURRENTROUTINE = 'THunkSymTable.SaveInfoToStream';
var
  Segment       : THunkSegment;
  Symbol        : THunkSymbol;
  HunkNr        : integer = 0;
  SymbolIndex   : integer;
  Buffer        : AnsiString;
begin
  Enter(CURRENTROUTINE);

  for Segment in FSymTab do
  begin
    inc(HunkNr);
    SymbolIndex := 0;
    for Symbol in Segment.Symbols do
    begin
      WriteStr
      (
        Buffer, 
        '[', HunkNr, ']', 
        SymbolIndex:5, '  ', 
        '$', HexStr(Symbol.Offset, 8), '  ', 
        Symbol.Name, 
        #13#10
      );
      strm.WriteBuffer(PChar(Buffer)^, Length(Buffer));
      inc(SymbolIndex);
    end;
  end;

  Leave(CURRENTROUTINE);
end;


// very simplistic hunkreader/parser
procedure THunkSymTable.ReadHunks(strm: TStream);
const
  CURRENTROUTINE = 'THunkSymTable.ReadHunks';
var
  hunk      : LongWord;
  HunkIndex : integer = -1;
  S         : AnsiString;
  N         : LongWord;
  SymName   : AnsiString;
  SymOffset : LongWord;
begin
  Enter(CURRENTROUTINE);

  while (strm.position + 4 ) <= strm.size do
  begin
    hunk := Read32(strm);
    hunk := hunk and $3FFFFFFF;
    {$IFDEF VERBOSE_LOAD}
    Verbose(hunk);
    {$ENDIF}
    case hunk of

      HUNK_HEADER :                 // skip as fast as possible
      begin
        while true do
        begin
          S := readString(strm);
          if S = '' then break;
        end;

        N := read32(strm);          // read table size
        SkipBytes(strm, 2 * 4);     // skip first and last hunk slots
        SkipBytes(strm, N * 4);     // skip table
      end;
      
      HUNK_CODE :                   // skip as fast as possible
      begin
        N := read32(strm);          // read size of code in longwords
        {$IFDEF VERBOSE_LOAD}
        WriteLn('Size = ', N * 4);
        {$ENDIF}
        SkipBytes(strm, N * 4);     // skip those code bytes

        HunkIndex := AddHunk(htCODE, N*4);
      end;

      HUNK_RELOC32 :                // skip as fast as possible
      begin
        while true do
        begin
          N := read32(strm);        // read number of offsets
          if N = 0 then break;      // if non then break loop
    
          SkipBytes(strm, 1 * 4);   // skip hunk number
          SkipBytes(strm, N * 4);   // skip number of Offset entries for this hunk
        end;
      end;

      // This is the part we're interrested in
      HUNK_SYMBOL :                 
      begin
        {$IFDEF VERBOSE_LOAD}
        WriteLn('reading symbol table ', '(', HunkIndex + 1 ,')');
        {$ENDIF}
        while true do
        begin
          SymName := readString(strm);  // Read symbol name
          if SymName = '' then break;   // no name, so we're done

          SymOffset := read32(strm);    // read corresponding Symbol Offset
          AddSymbol(HunkIndex, SymName, SymOffSet); // Add this symbol to the table
        end;
        {$IFDEF VERBOSE_LOAD}
        WriteLn('finished symbol table reading');
        {$ENDIF}
        continue;
      end;

      HUNK_END : 
      begin
        continue;
      end;

      HUNK_DATA :
      begin
        N := read32(strm);          // read number of longwords of data
        {$IFDEF VERBOSE_LOAD}
        WriteLn('Size = ', N * 4);
        {$ENDIF}
        SkipBytes(strm, N * 4);     // skip all data

        HunkIndex := AddHunk(htDATA, N*4);
      end;

      HUNK_BSS :
      begin
        N := read32(strm);          // number of longwords to zero memory
        {$IFDEF VERBOSE_LOAD}
        WriteLn('Size = ', N * 4);
        {$ENDIF}
        HunkIndex := AddHunk(htBSS, N*4);
      end;

      HUNK_RELOC32SHORT,
      HUNK_DREL32 :                 // skip as fast as possible
      begin
        while true do
        begin
          N := read16(strm);        // read number of offsets
          if N = 0 then break;      // if non then break loop
    
          SkipBytes(strm, 1 * 2);   // skip hunk number
          SkipBytes(strm, N * 2);   // skip number of Offset entries for this hunk
        end;
        // ensure longword alignment;
        if strm.Position and 2 <> 0
        then SkipBytes(strm, 1 * 2);// strm.Position := strm.Position + 2;
      end;

      otherwise                     // display some error
      begin
        WriteLn('ERROR: unknown hunk type $', HexStr(hunk,8));

        raise exception.create
        (
          'ERROR: unknown hunk type $' + HexStr(hunk,8) + ' at position ' + 
          IntToStr(strm.position) + ' ' + '(' + '$' + HexStr(strm.position,8) + ')'
        ) at get_caller_addr(get_frame), get_caller_frame(get_frame);

      end;
    end;
  end;

  Leave(CURRENTROUTINE);
end;


function  THunkSymTable.Read32(strm: TStream): LongWord;
const
  CURRENTROUTINE = 'THunkSymTable.Read32';
begin
  Enter(CURRENTROUTINE);
  Result := BeToN(strm.ReadDWord);
  Leave(CURRENTROUTINE);
end;


function  THunkSymTable.Read16(strm: TStream): Word;
const
  CURRENTROUTINE = 'THunkSymTable.Read16';
begin
  Enter(CURRENTROUTINE);
  Result := BeToN(strm.ReadWord);
  Leave(CURRENTROUTINE);
end;


function  THunkSymTable.Read08(strm: TStream): Byte;
const
  CURRENTROUTINE = 'THunkSymTable.Read08';
begin
  Enter(CURRENTROUTINE);
  Result := BeToN(strm.ReadByte);
  Leave(CURRENTROUTINE);
end;


procedure THunkSymTable.SkipBytes(strm: TStream; amount: integer);
const
  CURRENTROUTINE = 'THunkSymTable.SkipBytes';
begin
  Enter(CURRENTROUTINE);
  strm.position := strm.position + amount;
  Leave(CURRENTROUTINE);
end;


function  THunkSymTable.ReadString(strm: TStream): AnsiString;
const
  CURRENTROUTINE = 'THunkSymTable.ReadString';
var
  len32   : LongWord;
  S       : AnsiString;
begin
  Enter(CURRENTROUTINE);

  len32 := Read32(strm);
  if len32 = 0 then 
  begin
    Leave(CURRENTROUTINE);
    exit('');
  end;

  // somewhat smarter way to load a string from symbol hunk, instead of per char
  SetLength(S, len32 * 4);
  strm.ReadBuffer(S[1], Length(S));
  RemoveTrailingChars(S, [#0]);
  Result := S;
  S := '';

  Leave(CURRENTROUTINE);
end;


procedure THunkSymTable.Dump_Hunk_Info;
const
  CURRENTROUTINE = 'THunkSymTable.Dump_Hunk_Info';

  function HunkTypeStr(ht: THunkType): String;
  begin
    case ht of
      htUnknown : Result := '<unknown>';
      htCODE    : Result := 'CODE';
      htBSS     : Result := 'BSS';
      htDATA    : Result := 'DATA';
      else        Result := '<error>';
    end;
  end;

var
  Hunk  : THunkSegment;
  index : integer = 0;
begin
  Enter(CURRENTROUTINE);

  if ( Length(FSymTab) > 0 ) then
  begin
    WriteLn('-------------------------------------------');
    WriteLn('             Hunk Information              ');
    WriteLn('-------------------------------------------');
    WriteLn('#':2,' Size':10,'   Start':10,'   #Symbols':10,'   (type)');
    WriteLn('-------------------------------------------');

    for hunk in FSymTab do
    begin
      WriteLn
      (
        index:2, 
        ' '  , Hunk.Size:10,
        '  $', HexStr(Hunk.Address),
        '  ' , Length(Hunk.Symbols):8,
        '  ' , '(' , HunkTypeStr(Hunk.HunkType), ')' 
      );
      inc(index);
    end;
  end
  else
    WriteLn('There is no Hunk information available');

  Leave(CURRENTROUTINE);
end;


procedure THunkSymTable.CheckFill_Segments_with_Hunks;
const
  CURRENTROUTINE = 'THunkSymTable.CheckFill_Segments_with_Hunks';
var
  Index       : Integer;
  {$IFNDEF AUTO_SEGMENTS}
  VirtualAddr : Pointer;
  {$ENDIF}
begin
  Enter(CURRENTROUTINE);

  {$IFDEF AUTO_SEGMENTS}
  if Length(FSymTab) = Length(SegmentInfo) then
  begin
    for Index := Low(FSymTab) to High(FSymTab) do
    begin
      if FSymTab[Index].Size = SegmentInfo[Index].sii_Size then
      begin
        if FSymTab[Index].Address <> SegmentInfo[Index].sii_Code then
        begin
          if FSymTab[Index].Address = nil then
          begin
            FSymTab[Index].Address := SegmentInfo[Index].sii_Code
          end
          else
            WriteLn('Address of item with index ', Index, ' inside SymTab and SegmentInfo do not match')
        end;
      end
      else
        WriteLn('Size of item with index ', Index, ' inside SymTab and SegmentInfo do not match');
    end;
  end
  else
    WriteLn('SymTab and SegmentInfo do not contain the same amount of entries');

  // Segments could not be loaded, either because we're not running on amiga 
  // or because autoload was turned off. Nonetheless we would like to 
  // fill in some defaults and pass the verification.
  {$ELSE}
  for Index := Low(FSymTab) to High(FSymTab) do
  begin
    // Make up some virtual address. Note that the calculated value is total nonsense
    VirtualAddr := Pointer(Index shl 20);
    if FSymTab[Index].Address <> VirtualAddr then
    begin
      if FSymTab[Index].Address = nil then
      begin
        FSymTab[Index].Address := VirtualAddr
      end
      else
        WriteLn('Address of item with index ', Index, ' inside SymTab did not match with invented VirtualAddr')
    end;
  end;  
  {$ENDIF}
  Leave(CURRENTROUTINE);
end;



///////////////////////////////////////////////////////////////////////////////
//
//
//          Unit Initialization & Finalization
//
//
///////////////////////////////////////////////////////////////////////////////



initialization


begin
  {$IF DEFINED(AUTO_SEGMENTS) and DEFINED(VERBOSE_LOAD)}
  WriteLn('Pre-Initialization initiated');
  {$ENDIF}

  {$IFDEF AUTO_SEGMENTS}
  Get_Segment_Information;
  {$IFDEF VERBOSE_LOAD}
  Dump_Segment_Information;
  WriteLn;
  {$ENDIF}
  {$ENDIF}

  HunkSymbols := THunkSymTable.Create;

  {$IFDEF AUTO_LOAD_SYMBOLS}
  HunkSymbols.LoadFromFile(ParamStr(0));
  {$ENDIF}

  {$IFDEF AUTO_SAVE_SYMBOLS}
  HunkSymbols.SaveInfoToFile(ParamStr(0) + '.symbols');
  {$ENDIF}

  {$IF DEFINED(AUTO_SEGMENTS) and DEFINED(VERBOSE_LOAD)}
  WriteLn('Pre-Initialization finished', sLineBreak);
  {$ENDIF}
end;


finalization

  HunkSymbols.Free;

end.
