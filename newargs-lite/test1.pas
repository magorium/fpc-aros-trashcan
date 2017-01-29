program test1;

{$H+}

uses
  NewArgs,
  NewArgs.Utils;

type
  TStringArray = Array of String;

  TTestData = record
    name: String;   // name of the test
    t   : String;   // template
    a   : String;   // arguments
    rc  : integer;  // newargs return code
    ra  : String;   // resulting arguments in template order. Arguments are 
                    // separated by newline character #10, while multiargs by 
                    // itself are separated by horizontal tab charcater #9.
  end;


var
  TestData : array[0..20] of TTestData =
  (
    ( name: 'Test1a'; t: 'SomeOption'   ;       a: '';                              rc: NARGS_ERR_NO_ERROR;         ra: ''    ),
    // Following entry only works on parsing the commandline
    //    ( name: 'Test1b'; t: 'SomeOption'   ;       a: '?';                             rc: NARGS_ERR_HELP_REQUESTED;   ra: ''  ),
    ( name: 'Test1b'; t: 'SomeOption/A' ;       a: '';                              rc: NARGS_ERR_REQUIRED;         ra: ''    ),
    ( name: 'Test1c'; t: 'SomeOption/A' ;       a: '1';                             rc: NARGS_ERR_NO_ERROR;         ra: '1'   ),
    ( name: 'Test1d'; t: 'SomeOption/K' ;       a: '1';                             rc: NARGS_ERR_TOO_MANY_ARGS;    ra: ''    ),  // should return too many parameters
    ( name: 'Test1e'; t: 'SomeOption/K' ;       a: 'SomeOption';                    rc: NARGS_ERR_KEY_NEEDS_ARG;    ra: 'n/a' ),
    ( name: 'Test1f'; t: 'SomeOption/K' ;       a: 'SomeOption=1';                  rc: NARGS_ERR_NO_ERROR;         ra: '1'   ),
    ( name: 'Test1g'; t: 'SomeOption/K/A' ;     a: 'SomeOption';                    rc: NARGS_ERR_KEY_NEEDS_ARG;    ra: 'n/a' ),  // err might become NARGS_ERR_REQUIRED
    ( name: 'Test1h'; t: 'SomeOption/K/A' ;     a: 'SomeOption=1';                  rc: NARGS_ERR_NO_ERROR;         ra: '1'   ),
    // taken from aros http://repo.or.cz/w/AROS.git/blob/HEAD:/test/dos/readargs.c
    // Note, inputstream request is not implemented so those examples are omitted.
    ( name: 'Test2a'; t: 'KEYA' ;               a: 'val1';                          rc: NARGS_ERR_NO_ERROR;         ra: 'val1' ),
    ( name: 'Test2b'; t: 'KEYA' ;               a: 'keya val1';                     rc: NARGS_ERR_NO_ERROR;         ra: 'val1' ),
    ( name: 'Test2c'; t: 'KEYA,KEYB' ;          a: 'val1 keyb ';                    rc: NARGS_ERR_KEY_NEEDS_ARG;    ra: 'n/a'  ),

    ( name: 'Test3a'; t: 'KEYA' ;               a: 'keya=val1';                     rc: NARGS_ERR_NO_ERROR;         ra: 'val1' ),
    ( name: 'Test3b'; t: 'KEYA,KEYB' ;          a: 'val1 val2';                     rc: NARGS_ERR_NO_ERROR;         ra: 'val1'#10'val2' ),
    ( name: 'Test3c'; t: 'KEYA,KEYB' ;          a: 'keya=val1 keyb=val2';           rc: NARGS_ERR_NO_ERROR;         ra: 'val1'#10'val2' ),
    ( name: 'Test3d'; t: 'KEYA,KEYB' ;          a: 'keya val1 keyb val2';           rc: NARGS_ERR_NO_ERROR;         ra: 'val1'#10'val2' ),
    ( name: 'Test3e'; t: 'KEYA,KEYB' ;          a: 'keyb val2 val1';                rc: NARGS_ERR_NO_ERROR;         ra: 'val1'#10'val2' ),
    ( name: 'Test3f'; t: 'KEYA,KEYB' ;          a: 'keyb val2 keya val1';           rc: NARGS_ERR_NO_ERROR;         ra: 'val1'#10'val2' ),

    // examples using "/F" in the template are omitted as support for it is not implemented

    ( name: 'Test4a'; t: 'KEYA,KEYB/M' ;        a: 'val1 val2 val3';                rc: NARGS_ERR_NO_ERROR;         ra: 'val1'#10'val2'#9'val3'),
    ( name: 'Test4b'; t: 'KEYA,KEYB/M' ;        a: 'keyb=val1 keya=val2 keyb=val3'; rc: NARGS_ERR_NO_ERROR;         ra: 'val2'#10'val1'#9'val3'),
    ( name: 'Test4c'; t: 'KEYA,KEYB/M,KEYC' ;   a: 'keyb=val1 keya=val2 val3 val4'; rc: NARGS_ERR_NO_ERROR;         ra: 'val2'#10'val1'#9'val3'#9'val4' ),
    ( name: 'Test4d'; t: 'KEYA/S,KEYB,KEYC' ;   a: 'keyb=val1 keya val3';           rc: NARGS_ERR_NO_ERROR;         ra: 'true'#10'val1'#10'val3' )
  );

  // sofar two AROS' test fails with some oddity encounter (as reported on 
  // aros-exec forums).


procedure TestCases;
var
  i,j: integer;
  retval: integer;
  TemplateArg: String;
  ExpectedArg: String;
  StatusOK: boolean;
  StatusLines: String;
begin
  for i := low(TestData) to High(TestData) do
  begin
    Write('Performing ', TestData[i].Name, ': ');
    StatusOK   := true;
    StatusLines := '';

    retval := ParseArgs( TestData[i].t, TestData[i].a );

    if ( retval = TestData[i].rc ) then
    begin
      // only if return code is ERR_NO_ERR we can check the parameters
      if ( retval = NARGS_ERR_NO_ERROR ) then
      begin
        for j := 0 to Pred(ArgCount) do
        begin
          TemplateArg := ArgStr(j);
          ExpectedArg := ExtractWord(succ(j), TestData[i].ra, [#10]);

          // This check also includes multi arg arguments, arguments separated
          // with #9 character
          if ( TemplateArg = ExpectedArg ) then
          begin
            { intentionally do nothing }
          end
          else
          begin
            StatusOk := false;
            WriteStr(StatusLines, StatusLines, 'failed: argument ', succ(j), ' did not match up. got: "', TemplateArg, '" expected: "', ExpectedArg, '"', LineEnding);
          end;
        end;
      end;
    end
    else
    begin
      StatusOk := false;
      WriteStr(StatusLines, StatusLines, 'failed: erraneous return code from ParseArgs() : ', retval, LineEnding);
    end;


    if StatusOk then
    begin
      WriteLn('OK');
    end
    else
    begin
      WriteLn('Failure');
      Write(StatusLines);
    end;    
  end;
  WriteLn;
end;


begin
  TestCases;
end.
