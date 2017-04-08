unit amiga.hunk.debug;

{$MODE OBJFPC}

(*
  The following routines are defined and implemented here 
  because at this point in time ther is no lineinfo yet
*)

{.$DEFINE VERBOSE_DEBUG}         // every routine entry and exit is emitted

interface

  procedure DebugLn(S: String);
  procedure DebugLn(S1, S2: String);
  Procedure DebugLn(S: String; const args: array of const);

  procedure Enter;
  procedure Enter(ProcName: String);
  procedure Leave;
  procedure Leave(ProcName: String);


implementation

uses
  SysUtils;


procedure Enter;
begin
  DebugLn('>>>  ');
end;


procedure Enter(ProcName: String);
begin
  DebugLn('>>>  ' + ProcName + '()');
end;


procedure Leave;
begin
  DebugLn('<<<  ');
end;


procedure Leave(ProcName: String);
begin
  DebugLn('<<<  ' + ProcName + '()');
end;



procedure DebugLn(S: String);
begin
  {$IFDEF VERBOSE_DEBUG}
  WriteLn(S);
  {$ENDIF}
end;


procedure DebugLn(S1, S2: String);
begin
  DebugLn(S1 + S2);
end;


Procedure DebugLn(S: String; const args: array of const);
begin
  DebugLn(Format(S, args));
end;


end.
