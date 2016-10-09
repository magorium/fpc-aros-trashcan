unit arosc_static_link;

{$MODE OBJFPC}{$H+}

{$LINK startup.o}
{$LINKLIB libautoinit.a}
{$LINKLIB libarosc.a}


interface


  procedure AROSC_Init(Pascal_Startup_Entry: TProcedure);


implementation

Uses
  Exec, AmigaDOS;


//
//        Exports
//
type
  TAROS_Startup_Function = function(argc: integer; argv: PPChar): integer; cdecl;
var
  SysBase             : Pointer; cvar; export;
  DOSBase             : Pointer; cvar; export;
  __main_function_ptr : TAROS_Startup_Function = nil; cvar; export;


//
//        Exports - AROS startup.o linker options
//
var
  __nocommandline   : Integer; cvar; export;
  __nostdiowin      : integer; cvar; export;
  __nowbsupport     : Integer; cvar; export;  


//
//        Imports
//
Type
  TCProcedure = Procedure; cdecl;
  
procedure __startup_entries_init; cdecl; external;
procedure ___startup_entries_next(SystemBase: Pointer); cdecl; external;


//
//  Wrapper function
//
procedure __startup_entries_next;
begin
  ___startup_entries_next(SysBase);
end;


var
  Pascal_Entry_Proc: TProcedure = nil;


function AROSC_Startup_Entry(argc: integer; argv: PPChar): integer; cdecl;
begin
  DebugLn('ENTER - AROSC_Startup_Entry()');

  if assigned(@Pascal_Entry_Proc) then Pascal_Entry_Proc;

  result := 0;

  DebugLn('LEAVE - AROSC_Startup_Entry()');
end;


procedure AROSC_Init(Pascal_Startup_Entry: TProcedure);
begin
  DebugLn('.');
  DebugLn('ENTER - AROS_Init');

  DebugLn('SysBase := AOS_ExecBase');
  SysBase := AOS_ExecBase;

  DebugLn('DOSBase := AOS_DosBase');
  DOSBase := AOS_DosBase;

  __main_function_ptr := @AROSC_Startup_Entry;

  Pascal_Entry_Proc   := Pascal_Startup_Entry;

  DebugLn('CALL __startup_entries_init()');
  __startup_entries_init;

  DebugLn('CALL __startup_entries_next()');
  __startup_entries_next;

  DebugLn('LEAVE - AROS_Init');
end;


end.
