unit CHelpers;

{$MODE OBJFPC}{$H+}


interface

Uses
  CTypes, SysUtils;
  

type
  Tbsearchcomparefunc = function(const a: pointer; const b: pointer): cint;

  
  // some c routines
  function  bsearch(const key: pointer; base: pointer; num: csize_t; size: csize_t; compar: Tbsearchcomparefunc): pointer;
  function  memcpy(dest: pointer; const src: pointer; num: int64): pointer;
  function  memcmp(const ptr1: pointer; const ptr2: pointer; num: Int64): Integer;

  function  memset(ptr: pointer; value: byte; num: int64): pointer; overload; inline;
  function  memset(ptr: pointer; value: char; num: int64): pointer; overload; inline;
  

  // additional helper routines
  Function  notValid(x: Integer): boolean;
  Function  notValid(x: Pointer): boolean;

  Function  GetStdOutHandle: Thandle;



implementation



Function  notValid(x: Integer): boolean;
begin
  result := (x = 0);
end;


Function  notValid(x: Pointer): boolean;
begin
  result := (x = nil);
end;


function  GetStdOutHandle: Thandle;
begin
  result := TTextRec(StdOut).handle;
end;


function  bsearch(const key: pointer; base: pointer; num: csize_t; size: csize_t; compar: Tbsearchcomparefunc): pointer;
var
  base2 : PChar;
  a,b,c : csize_t;
  d     : cint;
begin
  base2 := PChar(base);
  a     := 0;
  b     := num;
  
  //* Any elements to search ? */
  If (num <> 0) then
  begin
    While true do
    begin
      //* Find the middle element between a and b */
      c := (a + b) div 2;

      //* Look if key is equal to this element */    
      d := compar(key, @base2[size * c]);
      if (d = 0)
      then exit(@base2[size * c]);

      {*
        If the middle element equals the lower seach bounds, then
        there are no more elements in the array which could be
        searched (c wouldn't change anymore).
      *}
      if (c = a)
        then break;

      {*
        The middle element is not equal to the key. Is it smaller
        or larger than the key ? If it's smaller, then c is our
        new lower bounds, otherwise c is our new upper bounds.
      *}
      if (d < 0)
      then b := c
      else
        a := c;
    end;
  end;

  //* Nothing found */
  Result := nil;  
end;


function  memcpy(dest: pointer; const src: pointer; num: int64): pointer;
var 
  Index : integer;
begin
  for Index := 0 to Pred(num) do 
    PByteArray(dest)^[Index] := PByteArray(src)^[Index];
  result := dest;
end;


function  memcmp(const ptr1: pointer; const ptr2: pointer; num: Int64): Integer; 
var 
  Index : integer;
begin 
  Result := 0; 
  for Index := 0 to Pred(num) do 
    if PByteArray(ptr1)^[Index] <> PByteArray(ptr2)^[Index] then
    begin 
      if ( PByteArray(ptr1)^[Index] < PByteArray(ptr2)^[Index] )
      then Result := -1
      else Result := 1;
      break;
    end; 
end;


function  memset(ptr: pointer; value: char; num: int64): pointer; overload; inline;
begin
  FillChar(ptr^, num, value);
  Result := ptr;
end;


function  memset(ptr: pointer; value: byte; num: int64): pointer; overload;
begin
  FillByte(ptr^, num, value);
  Result := ptr;
end;


end.
