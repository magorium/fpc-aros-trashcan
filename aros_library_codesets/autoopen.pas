program autoopen;

{$MODE OBJFPC}{$H+}

Uses
  aros.codesets;


function Main: Integer;
var
  cs: pcodeset;
begin
  if (CodeSetsBase = nil) then
  begin
    writeln('Autoopen failed!');
    exit(1);
  end;

  cs := CodesetsFindA(nil, nil);

  if (cs <> nil)
  then writeln('Default codeset for your system is ', cs^.name)
  else writeln('Unable to query default codeset');

  exit(0);
end;



begin
  ExitCode := Main;
end.