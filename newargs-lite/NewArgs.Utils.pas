unit NewArgs.Utils;

{$H+}

(*
  copies form unit SysUtils and StrUtils in order to prevent dragging in those 
  units completely.
*)

interface

type
  TStringArray = Array of AnsiString;


  function Trim(const S: string): string;
  function CompareText(const S1, S2: string): SizeInt;


Type
  TSysCharSet = Set of AnsiChar;
  PSysCharSet = ^TSysCharSet;

  function WordCount(const S: string; const WordDelims: TSysCharSet): Integer;
  function WordPosition(const N: Integer; const S: string; const WordDelims: TSysCharSet): Integer;
  function ExtractWordPos(N: Integer; const S: string; const WordDelims: TSysCharSet; var Pos: Integer): string;
  function ExtractWord(N: Integer; const S: string; const WordDelims: TSysCharSet): string;inline;  


implementation


Const 
  WhiteSpace = [#0..' '];

function Trim(const S: string): string;
var Ofs, Len: integer;
begin
  len := Length(S);
  while (Len>0) and (S[Len] in WhiteSpace) do
   dec(Len);
  Ofs := 1;
  while (Ofs<=Len) and (S[Ofs] in WhiteSpace) do
   Inc(Ofs);
  Trim := Copy(S, Ofs, 1 + Len - Ofs);
end;


function CompareText(const S1, S2: string): SizeInt;
var
  c1, c2: Byte;
  i: SizeInt;
  L1, L2, Count: SizeInt;
  P1, P2: PChar;
begin
  L1 := Length(S1);
  L2 := Length(S2);
  if L1 > L2 then
    Count := L2
  else
    Count := L1;
  i := 0;
  P1 := @S1[1];
  P2 := @S2[1];
  while i < count do
  begin
    c1 := byte(p1^);
    c2 := byte(p2^);
    if c1 <> c2 then
    begin
      if c1 in [97..122] then
        Dec(c1, 32);
      if c2 in [97..122] then
        Dec(c2, 32);
      if c1 <> c2 then
        Break;
    end;
    Inc(P1); Inc(P2); Inc(I);
  end;
  if i < count then
    CompareText := c1 - c2
  else
    CompareText := L1 - L2;
end;


function WordCount(const S: string; const WordDelims: TSysCharSet): Integer;
var
  P,PE : PChar;
begin
  WordCount:=0;
  P:=PChar(S);
  PE:=P+Length(S);
  while (P<PE) do
  begin
    while (P<PE) and (P^ in WordDelims) do Inc(P);
    if (P<PE) then inc(WordCount);
    while (P<PE) and not (P^ in WordDelims) do inc(P);
  end;
end;


function WordPosition(const N: Integer; const S: string; const WordDelims: TSysCharSet): Integer;
var
  PS,P,PE : PChar;
  Count: Integer;
begin
  WordPosition:=0;
  Count:=0;
  PS:=PChar(pointer(S));
  PE:=PS+Length(S);
  P:=PS;
  while (P<PE) and (Count<>N) do
  begin
    while (P<PE) and (P^ in WordDelims) do inc(P);
    if (P<PE) then inc(Count);
    if (Count<>N) 
    then
      while (P<PE) and not (P^ in WordDelims) do  inc(P)
    else
      WordPosition:=(P-PS)+1;
  end;
end;


function ExtractWord(N: Integer; const S: string; const WordDelims: TSysCharSet): string;inline;
var
  i: Integer;
begin
  ExtractWord:=ExtractWordPos(N,S,WordDelims,i);
end;


function ExtractWordPos(N: Integer; const S: string; const WordDelims: TSysCharSet; var Pos: Integer): string;
var
  i,j,l: Integer;
begin
  j:=0;
  i:=WordPosition(N, S, WordDelims);
  Pos:=i;
  if (i<>0) then
    begin
    j:=i;
    l:=Length(S);
    while (j<=L) and not (S[j] in WordDelims) do
      inc(j);
    end;
  SetLength(ExtractWordPos,j-i);
  If ((j-i)>0) then
    Move(S[i],ExtractWordPos[1],j-i);
end;


end.
