unit aros.codesets;

{$MODE OBJFPC}{$H+}

Interface

Uses
  exec;

// http://repo.or.cz/w/AROS.git/blob/HEAD:/workbench/libs/codesets/developer/include/libraries/codesets.h

Type
  pSTRPTR               = ^STRPTR;

const
  CODESETSNAME : pChar  = 'codesets.library';
  CODESETSVER           = 6;

Type
  UTF32                 = ULONG;                    //* at least 32 bits */
  UTF16                 = UWORD;                    //* at least 16 bits */
  UTF8                  = UBYTE;                    //* typically 8 bits */
  
  pUTF32                = ^UTF32;
  ppUTF32               = ^pUTF32;
  
  pUTF16                = ^UTF16;
  ppUTF16               = ^pUTF16;
  
  pUTF8                 = ^UTF8;
  ppUTF8                = ^pUTF8;
  

  Tsingle_convert = record
    code                : Char;                     //* the code in this representation */
    utf8_               : array[0..8-1] of UTF8;    //* the utf8 string, first byte is alway the length of the string */
    ucs4                : LongWord;                 //* the full 32 bit unicode */
  end;

  Pcodeset = ^Tcodeset;
  Tcodeset = record
    node                : TMinNode;
    name                : pchar;
    alt_name            : pchar;
    characterization    : pchar;
    table               : array[0..256-1] of Tsingle_convert;
    table_sorted        : array[0..256-1] of Tsingle_convert;
  end;

  PcodesetList = ^TcodesetList;
  TcodesetList = record
    list                : TMinList;
  end;
  

  TCSR = 
  (
    CSR_ConversionOK        = 0,    //* conversion successful */
    CSR_SourceExhausted,            //* partial character in source, but hit end */
    CSR_TargetExhausted,            //* insuff. room in target for conversion */
    CSR_SourceIllegal               //* source sequence is illegal/malformed */
  );

  TCF =
  (
    CSF_StrictConversion    = 0,
    CSF_LenientConversion
  );


//*
//** Enumerations for CSA_CodesetFamily
//*/
  TCSV = 
  (
    CSV_CodesetFamily_Latin  = 0,     //* Latin Family */
    CSV_CodesetFamily_Cyrillic      //* Cyrillic Family */
  );

const
  CODESETSLIB_TAG            = $fec901f4;

  CSA_Base                   = (CODESETSLIB_TAG + 0);

  CSA_SourceLen              = (CODESETSLIB_TAG + 1);
  CSA_Source                 = (CODESETSLIB_TAG + 2);
  CSA_Dest                   = (CODESETSLIB_TAG + 3);
  CSA_DestLen                = (CODESETSLIB_TAG + 4);
  CSA_DestHook               = (CODESETSLIB_TAG + 5);
  CSA_DestLenPtr             = (CODESETSLIB_TAG + 6);
  CSA_SourceCodeset          = (CODESETSLIB_TAG + 7);
  CSA_Pool                   = (CODESETSLIB_TAG + 8);
  CSA_PoolSem                = (CODESETSLIB_TAG + 9);
  CSA_AllocIfNeeded          = (CODESETSLIB_TAG + 10);
  CSA_Save                   = (CODESETSLIB_TAG + 11);
  CSA_FallbackToDefault      = (CODESETSLIB_TAG + 12);
  CSA_DestCodeset            = (CODESETSLIB_TAG + 13);
  CSA_CodesetDir             = (CODESETSLIB_TAG + 14);
  CSA_CodesetFile            = (CODESETSLIB_TAG + 15);
  CSA_CodesetList            = (CODESETSLIB_TAG + 16);
  CSA_FreeCodesets           = (CODESETSLIB_TAG + 17);
  CSA_CodesetFamily          = (CODESETSLIB_TAG + 18);
  CSA_ErrPtr                 = (CODESETSLIB_TAG + 19);

  CSA_B64SourceString        = (CODESETSLIB_TAG + 20);
  CSA_B64SourceLen           = (CODESETSLIB_TAG + 21);
  CSA_B64SourceFile          = (CODESETSLIB_TAG + 22);
  CSA_B64DestPtr             = (CODESETSLIB_TAG + 23);
  CSA_B64DestFile            = (CODESETSLIB_TAG + 24);
  CSA_B64MaxLineLen          = (CODESETSLIB_TAG + 25);
  CSA_B64Unix                = (CODESETSLIB_TAG + 26);
  CSA_B64FLG_NtCheckErr      = (CODESETSLIB_TAG + 27);

  CSA_MapForeignChars        = (CODESETSLIB_TAG + 28);
  CSA_MapForeignCharsHook    = (CODESETSLIB_TAG + 29);

  CSA_AllowMultibyteCodesets = (CODESETSLIB_TAG + 30);


Type
  TCSR_B64 =
  (
    CSR_B64_ERROR_OK        = 0,
    CSR_B64_ERROR_MEM,
    CSR_B64_ERROR_DOS,
    CSR_B64_ERROR_INCOMPLETE,
    CSR_B64_ERROR_ILLEGAL
  );
  
  
  TconvertMsg = record
    state               : ULONG;
    len                 : ULONG;
  end;

  TCSV2 = 
  (
    CSV_Translating,
    CSV_End
  ); 

  TreplaceMsg = record
    dst                 : ppchar;   //* place the replace string here */
    src                 : pchar;    //* the source UTF8 string */
    srclen              : longint;  //* length of the UTF8 sequence */
  end;

Var
  CodesetsBase          : pLibrary = nil;

  // http://repo.or.cz/w/AROS.git/blob/HEAD:/workbench/libs/codesets/developer/fd/codesets_lib.fd
  // http://repo.or.cz/w/AROS.git/blob/HEAD:/workbench/libs/codesets/developer/include/defines/codesets.h


  function  CodesetsConvertUTF32toUTF16 (const sourceStart: ppUTF32; const sourceEnd: pUTF32; targetStart: ppUTF16; targetEnd: pUTF16; flags: ULONG): ULONG;    syscall CodesetsBase  6;
  function  CodesetsConvertUTF16toUTF32 (const sourceStart: ppUTF16; const sourceEnd: pUTF16; targetStart: ppUTF32; targetEnd: pUTF32; flags: ULONG): ULONG;    syscall CodesetsBase  7;
  function  CodesetsConvertUTF16toUTF8  (const sourceStart: ppUTF16; const sourceEnd: pUTF16; targetStart: ppUTF8;  targetEnd: pUTF8;  flags: ULONG): ULONG;    syscall CodesetsBase  8;
  function  CodesetsIsLegalUTF8         (const source: pUTF8; length: ULONG): BOOL;                                                                             syscall CodesetsBase  9;
  function  CodesetsIsLegalUTF8Sequence (const source: pUTF8; const sourceEnd: pUTF8): BOOL;                                                                    syscall CodesetsBase 10;
  function  CodesetsConvertUTF8toUTF16  (const sourceStart: ppUTF8 ; const sourceEnd: pUTF8;  targetStart: ppUTF16; targetEnd: pUTF16; flags: ULONG): ULONG;    syscall CodesetsBase 11;
  function  CodesetsConvertUTF32toUTF8  (const sourceStart: ppUTF32; const sourceEnd: pUTF32; targetStart: ppUTF8;  targetEnd: pUTF8;  flags: ULONG): ULONG;    syscall CodesetsBase 12;
  function  CodesetsConvertUTF8toUTF32  (const sourceStart: ppUTF8;  const sourceEnd: pUTF8;  targetStart: ppUTF32; targetEnd: pUTF32; flags: ULONG): ULONG;    syscall CodesetsBase 13;
  function  CodesetsSetDefaultA         (name: STRPTR; attrs: pTagItem): pcodeset;                                                                              syscall CodesetsBase 14;
  procedure CodesetsFreeA               (obj: APTR; attrs: pTagItem);                                                                                           syscall CodesetsBase 15;
  function  CodesetsSupportedA          (attrs: pTagItem): pSTRPTR;                                                                                             syscall CodesetsBase 16;
  function  CodesetsFindA               (name: STRPTR; attrs: pTagItem): pcodeset;                                                                              syscall CodesetsBase 17;
  function  CodesetsFindBestA           (attrs: pTagItem): pcodeset;                                                                                            syscall CodesetsBase 18;
  function  CodesetsUTF8Len             (const str: pUTF8): ULONG;                                                                                              syscall CodesetsBase 19;
  function  CodesetsUTF8ToStrA          (attrs: pTagItem): STRPTR;                                                                                              syscall CodesetsBase 20;
  function  CodesetsUTF8CreateA         (attrs: pTagItem): pUTF8;                                                                                               syscall CodesetsBase 21;
  function  CodesetsEncodeB64A          (attrs: pTagItem): ULONG;                                                                                               syscall CodesetsBase 22;
  function  CodesetsDecodeB64A          (attrs: pTagItem): ULONG;                                                                                               syscall CodesetsBase 23;
  function  CodesetsStrLenA             (str: STRPTR; attrs: pTagItem): ULONG;                                                                                  syscall CodesetsBase 24;
  function  CodesetsIsValidUTF8         (str: STRPTR): BOOL;                                                                                                    syscall CodesetsBase 25;
  procedure CodesetsFreeVecPooledA      (pool: APTR; mem: APTR; attrs: pTagItem);                                                                               syscall CodesetsBase 26;
  function  CodesetsConvertStrA         (attrs: pTagItem): STRPTR;                                                                                              syscall CodesetsBase 27;
  function  CodesetsListCreateA         (attrs: pTagItem): pcodesetList;                                                                                        syscall CodesetsBase 28;
  function  CodesetsListDeleteA         (attrs: pTagItem): BOOL;                                                                                                syscall CodesetsBase 29;
  function  CodesetsListAddA            (list: pcodesetList; attrs: pTagItem): BOOL;                                                                            syscall CodesetsBase 30;
  function  CodesetsListRemoveA         (attrs: pTagItem): BOOL;                                                                                                syscall CodesetsBase 31;

  // varargs versions
  function  CodesetsSetDefault      (name: STRPTR; const tags: array of const): pcodeset;
  procedure CodesetsFree            (obj: APTR; const tags: array of const);
  function  CodesetsSupported       (const tags: array of const): pSTRPTR;
  function  CodesetsFind            (name: STRPTR; const tags: array of const): pcodeset;
  function  CodesetsFindBest        (const tags: array of const): pcodeset;
  function  CodesetsUTF8ToStr       (const tags: array of const): STRPTR;
  function  CodesetsUTF8Create      (const tags: array of const): pUTF8;
  function  CodesetsEncodeB64       (const tags: array of const): ULONG;
  function  CodesetsDecodeB64       (const tags: array of const): ULONG;
  function  CodesetsStrLen          (str: STRPTR; const tags: array of const): ULONG;
  procedure CodesetsFreeVecPooled   (pool: APTR; mem: APTR; const tags: array of const);
  function  CodesetsConvertStr      (const tags: array of const): STRPTR;
  function  CodesetsListCreate      (const tags: array of const): pcodesetList;
  function  CodesetsListDelete      (const tags: array of const): BOOL;
  function  CodesetsListAdd         (list: pcodesetList; const tags: array of const): BOOL;
  function  CodesetsListRemove      (const tags: array of const): BOOL;

  
implementation

Uses
  tagsarray;  


function  CodesetsSetDefault(name: STRPTR; const tags: array of const): pcodeset;
begin
  CodesetsSetDefault := CodesetsSetDefaultA(name, ReadInTags(tags));
end;

procedure CodesetsFree(obj: APTR; const tags: array of const);
begin
  CodesetsFreeA(obj, ReadInTags(tags));
end;

function  CodesetsSupported(const tags: array of const): pSTRPTR;
begin
  CodesetsSupported := CodesetsSupportedA(ReadInTags(tags));
end;

function  CodesetsFind(name: STRPTR; const tags: array of const): pcodeset;
begin
  CodesetsFind := CodesetsFindA(name, ReadInTags(tags));
end;

function  CodesetsFindBest(const tags: array of const): pcodeset;
begin
  CodesetsFindBest := CodesetsFindBestA(ReadInTags(tags));
end;

Function  CodesetsUTF8ToStr(const tags: array of const): STRPTR;
begin
  CodesetsUTF8ToStr := CodesetsUTF8ToStrA(ReadInTags(tags));
end;

function  CodesetsUTF8Create(const tags: array of const): pUTF8;
begin
  CodesetsUTF8Create := CodesetsUTF8CreateA(ReadInTags(tags));
end;

function  CodesetsEncodeB64(const tags: array of const): ULONG;
begin
  CodesetsEncodeB64 := CodesetsEncodeB64A(ReadInTags(tags));
end;

function  CodesetsDecodeB64(const tags: array of const): ULONG;
begin
  CodesetsDecodeB64 := CodesetsDecodeB64A(ReadInTags(tags));
end;

function  CodesetsStrLen(str: STRPTR; const tags: array of const): ULONG;
begin
  CodesetsStrLen := CodesetsStrLenA(str, ReadInTags(tags));
end;

procedure CodesetsFreeVecPooled(pool: APTR; mem: APTR; const tags: array of const);
begin
  CodesetsFreeVecPooledA(pool, mem, ReadInTags(tags));
end;

function  CodesetsConvertStr(const tags: array of const): STRPTR;
begin
  CodesetsConvertStr := CodesetsConvertStrA(ReadInTags(tags));
end;

function  CodesetsListCreate(const tags: array of const): pcodesetList;
begin
  CodesetsListCreate := CodesetsListCreateA(ReadInTags(tags));
end;

function  CodesetsListDelete(const tags: array of const): BOOL;
begin
  CodesetsListDelete := CodesetsListDeleteA(ReadInTags(tags));
end;

function  CodesetsListAdd(list: pcodesetList; const tags: array of const): BOOL;
begin
  CodesetsListAdd := CodesetsListAddA(list, ReadInTags(tags));
end;

function  CodesetsListRemove(const tags: array of const): BOOL;
begin
  CodesetsListRemove := CodesetsListRemoveA(ReadInTags(tags));
end;


Initialization
  CodesetsBase := OpenLibrary(CODESETSNAME, CODESETSVER);

Finalization
  CloseLibrary(CodesetsBase);

end.
