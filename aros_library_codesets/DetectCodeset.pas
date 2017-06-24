program DetectCodeset;

{$MODE OBJFPC}{$H+}

Uses
  exec,
  utility,
  aros.codesets;


const
  ISO8859_1_STR : PChar = 'Schmöre bröd, schmöre bröd, bröd bröd bräd.';
  CP1251_STR    : PChar = '1251 êîäèðîâêà äëÿ ïðèìåðà.';
  ASCII_STR     : PChar = 'latin 1 bla bla bla.';
  KOI8R_STR     : PChar = 'koi îÅ×ÏÚÍÏÖÎÏ ÐÅÒÅËÏÄÉÒÏ×ÁÔØ ÉÚ ËÏÄÉÒÏ×ËÉ';



function Main: Integer;
var
  res       : Integer;
  errNum    : ULONG = 0;
  cs        : pcodeset;
begin
  // CodesetsBase := OpenLibrary(CODESETSNAME, CODESETSVER);
  
  If (CodesetsBase <> nil) then
  begin
  
    cs := CodesetsFindBest
    ([
      CSA_Source, ISO8859_1_STR,
      CSA_ErrPtr, @errNum,
      TAG_DONE
    ]);
    if (cs <> nil) then
    begin
      writeln('Identified ISO8859_1_STR as ', cs^.name, ' with ', errNum, ' of ', strlen(ISO8859_1_STR), ' errors');
    end
    else writeln('couldn''t identify ISO8859_1_STR!');


    cs := CodesetsFindBest
    ([
      CSA_Source, CP1251_STR,
      CSA_ErrPtr, @errNum,
      CSA_CodesetFamily, CSV_CodesetFamily_Cyrillic,
      TAG_DONE
    ]);
    if (cs <> nil) then
    begin
      writeln('Identified CP1251_STR as ', cs^.name, ' with ', errNum, ' of ', strlen(CP1251_STR), ' errors');
    end
    else writeln('couldn''t identify CP1251_STR!');
    
    
    cs := CodesetsFindBest
    ([
      CSA_Source, ASCII_STR,
      CSA_ErrPtr, @errNum,
      CSA_CodesetFamily, CSV_CodesetFamily_Cyrillic,
      TAG_DONE
    ]);
    if (cs <> nil) then
    begin
      writeln('Identified ASCII_STR as ', cs^.name, ' with ', errNum, ' of ', strlen(ASCII_STR), ' errors');
    end
    else writeln('couldn''t identify ASCII_STR!');
  

    cs := CodesetsFindBest
    ([
      CSA_Source, KOI8R_STR,
      CSA_ErrPtr, @errNum,
      CSA_CodesetFamily, CSV_CodesetFamily_Cyrillic,
      TAG_DONE
    ]);
    if (cs <> nil) then
    begin
      writeln('Identified KOI8R_STR as ', cs^.name, ' with ', errNum, ' of ', strlen(KOI8R_STR), ' errors');
    end
    else writeln('couldn''t identify KOI8R_STR!');

    res := 0;

    //  CloseLibrary(CodesetsBase);
  end
  else
  begin
    writeln('can''t open ', CODESETSNAME ,' ', CODESETSVER, '+');
    res := 20;
  end;

  Result := res;
end;



begin
  ExitCode := Main;
end.