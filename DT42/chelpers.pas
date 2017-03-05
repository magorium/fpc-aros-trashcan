unit chelpers;

// why is this here ? answer: to port quicker :-)

interface

uses
  ctypes;

Type
  SInt32  = LongInt;
  PSInt32 = ^SInt32;
  pvoid   = pointer;

const
  M_PI = 3.14159265358979323846;

var
  errno : cint;

  function  calloc(num: csize_t; size: csize_t): pointer; inline;
  function  malloc(size: csize_t): pointer; inline;
  function  memcpy(destination: pvoid; const source: pvoid; num: csize_t): pvoid; inline;
  function  memmove(destination: pvoid; const source: pvoid; num: csize_t): pvoid; inline;
  function  realloc(ptr: pointer; size: csize_t): pointer; inline;
  procedure free(p: pointer); inline;
  function  memset(ptr: pvoid; value: byte; num: csize_t): pvoid; inline;

  function  strcat(destination: PChar; const source: PChar): PChar; inline;
  function  strchr(str: PChar; character: Char): PChar; inline;
  function  strcmp(const str1: PChar; const str2: PChar): integer; inline;
  function  strcpy(destination: PChar; const source: PChar): PChar; inline;
  function  strdup(const s: PChar): PChar;
  function  strncmp(const str1: PChar; const str2: PChar; num: csize_t): integer; inline;
  function  strncpy(dest: PChar; src: PChar; n: csize_t): PChar;

  // dummy
  function  strerror(errnum: cint): String; inline;

  function  atoi(c: PChar): Integer; inline;

  function  pow(base, exponent : cfloat) : cfloat;


implementation

uses
  SysUtils, Strings {$IFDEF WINDOWS}, windows{$ENDIF};


function intpower(base : cfloat; const exponent : Integer) : cfloat;
var
   i : longint;
begin
  if (base = 0.0) and (exponent = 0) then exit(1)
  else
  begin
    i:=abs(exponent);
    intpower:=1.0;
    while i>0 do
    begin
      while (i and 1)=0 do
      begin
        i:=i shr 1;
        base:=sqr(base);
      end;
      i:=i-1;
      intpower:=intpower*base;
    end;
    if exponent<0 then intpower:=1.0/intpower;
  end;
end;


function pow(base, exponent : cfloat) : cfloat;
begin
  if Exponent=0.0 then exit(1.0)
  else 
  if (base=0.0) and (exponent>0.0) then exit(0.0)
  else 
  if (abs(exponent)<=maxint) and (frac(exponent)=0.0) 
  then pow := intpower(base,trunc(exponent))
  else pow := exp(exponent * ln (base));
end;


function  calloc(num: csize_t; size: csize_t): pointer; inline;
begin
  calloc := System.AllocMem(num * size);
end;


function  malloc(size: csize_t): pointer; inline;
begin
  malloc := System.GetMem(size);
end;


function  memcpy(destination: pvoid; const source: pvoid; num: csize_t): pvoid; inline;
begin
  Move(Source^, Destination^, num);
  memcpy := destination;
end;


function  memmove(destination: pvoid; const source: pvoid; num: csize_t): pvoid; inline;
begin
  Move(Source^, Destination^, num);
  memmove := destination;
end;


function  realloc(ptr: pointer; size: csize_t): pointer; inline;
begin
  realloc := System.ReAllocMem(ptr, size);
end;


procedure free(p: pointer); inline;
begin
  if (p <> nil) then
  begin
    System.FreeMem(p);
  end;
end;


function  memset(ptr: pvoid; value: byte; num: csize_t): pvoid; inline;
begin
  FillChar(ptr^, num, value);
  memset := ptr;
end;


function  strdup(const s: PChar): PChar;
var
  dupe : PChar;
  dptr : PChar;
  sptr : PChar;
begin
  dupe := malloc(strlen(s)+1);
  if (dupe <> nil) then
  begin
    dptr := dupe;
    sptr := s;
    while (sptr^ <> #0) do
    begin
      dptr^ := sptr^;
      inc(dptr);
      inc(sptr);
    end;
    dptr^ := #0;
  end;
  strdup := dupe;
end;


function  strcat(destination: PChar; const source: PChar): PChar; inline;
begin
  strcat := strings.StrCat(destination, source);
end;


function  strchr(str: PChar; character: Char): PChar; inline;
begin
  strchr := Strings.striscan(str, character);
end;


function  strcmp(const str1: PChar; const str2: PChar): integer; inline;
begin
  strcmp := strcomp(str1, str2);
end;


function  strcpy(destination: PChar; const source: PChar): PChar; inline;
begin
  strcpy := SysUtils.StrCopy(destination, source);
end;


function  strncmp(const str1: PChar; const str2: PChar; num: csize_t): integer; inline;
begin
  strncmp := strlcomp(str1, str2, num);
end;


function  strncpy(dest: PChar; src: PChar; n: csize_t): PChar;
var
  ptr : PChar;
begin
  ptr := dest;

  while ( (n <> 0) ) do
  begin
    ptr^ := src^;
    if (ptr^ <> #0) then
    begin
      inc(ptr);
      inc(src);
      dec(n);
    end
    else break;
  end;

  while (n <> 0) do
  begin
    ptr^ := #0;
    inc(ptr);
    dec(n);
  end;

  strncpy := dest;
end;


// dummy
function  strerror(errnum: cint): string; inline;
begin
  WriteStr(strerror, 'error with number ', errnum,' occured');
end;


Function  atoi(c: PChar): Integer; inline;
begin
  atoi := StrToIntDef(c, -1);
end;

end.
