unit NewArgs;

{.$H+}
{.$DEFINE DEBUG_NEWARGS}
{
  ---------------------------------------------------------------------------
  Title     : NewArgs
  Author    : Magorium
  Date      : 28-jan-2016
  ---------------------------------------------------------------------------
  A unit that provides means to add Amiga-style argument handling to your
  projects.
  
  This code is heavily inspired on the argument parsing routines that are
  part of the Amiga Foundation Classes (AFC) which is developed by Fabio 
  Rotondo and published under the GNU LESSER GENERAL PUBLIC LICENSE.

  The original idea and concept found in the AFC was ported to and modified
  heavily for Free Pascal.

  As of the reason why: 
  Amiga argument parsing simply beats every other solution out there and 
  allows both the end-user and developer much freedom and simplicity without 
  the need for cryptic commandlines and/or unclear code.

  Unfamiliar with Amiga-Style commandline parsing ?
  - a commandline is described using a template, see below for explanation.
  - a template is simply passed to the ParseArgs() function
  - each argument (whether supplied or not) corresponds with its place
    defined inside the template.
  - Errors (if any) are reported (back) automaticlly
  - Arguments can be placed anywhere on the commandline by means of using 
    their respective keyword otherwise arguments should be provided in the 
    correct order.
    (actually that is one of the major pro features, as i often find myself
    providing tens of arguments, only to be confronted that a command 
    expects them in a different order. This way, in case you forgot an 
    argument, you can always add it to the end of your commandline using its 
    keyword).
    
  Once getting the hang of this you'll never want to go back to using 
  uncomfortable slashes and minus signs used by other implementations.
  ---------------------------------------------------------------------------
  differences to the original amiga implementation:
  - /F template option Fill modifier unsupported
  - /T template option toggle modifier unsupported
  - Interactive mode is not implemented. It simply returns an error-code
    on non amiga systems, indicating tha help was requested
  ---------------------------------------------------------------------------
  This version is the lite edition of newargs and realize that this still 
  doesn't call native API when compiled for/on Amiga/AROS/MorphOS.

  The lite version also uses additional usintParseArg.Utils in order to not 
  drag in units sysutils and strutils (this code was manuafqactured before 
  optmization was present in Aros/Amiga/MorphOS targets for Free Pascal).

  The normal version uses object mode and classes and didn't include error 
  reporting as implemented in this version.
  
  Note that funcion ParseArgs() can not be used nested.
  
  TODO: better documentation

  For use of template see AmigaDOS/AROS/MorphOS api for function ReadArgs().
}


interface



(*
relevant AROS' SDK original errors:
===============================================================================
#define ERROR_NO_FREE_STORE		    103 /* Out of memory. */
#define ERROR_BAD_TEMPLATE		    114 /* Supplied template is broken */
#define ERROR_BAD_NUMBER		    115 /* A supplied argument that was expected 
                                        /* to be numeric, was not numeric.
#define ERROR_REQUIRED_ARG_MISSING	116 /* An argument that has to be supplied 
                                        /* (ie signed with the '/A' flag) was not supplied. */
#define ERROR_KEY_NEEDS_ARG		    117 /* Keyword was specified, but not its contents. */
#define ERROR_TOO_MANY_ARGS		    118 /* There were more arguments than the template needs. */
#define ERROR_UNMATCHED_QUOTES		119 /* An odd number of quotation marks was supplied. */
#define ERROR_LINE_TOO_LONG         120 /* Either the command-line was longer 
                                        /* than hardcoded line length limit or the
                                        /* maximum number of multiple arguments 
                                        /* (flag '/M') was exceeded. This can
                                        /* also indicate that some argument is 
                                        /* too long or a supplied buffer is too
                                        /* small.
===============================================================================
*)

const
  NARGS_ERR_NO_ERROR            = 0;    // all processed ok
  NARGS_ERR_MISSING_KEYWORD     = 1;    // even possible ?
  NARGS_ERR_REQUIRED            = 2;    // equals amigados error 116
  NARGS_ERR_NO_NUMERIC_FIELD    = 3;    // redundant ?
  NARGS_ERR_NOT_A_NUMBER        = 4;    // equals amigados error 115
  NARGS_ERR_HELP_REQUESTED      = 5;    // given argument requested for help
  NARGS_ERR_TOO_MANY_ARGS       = 6;    // equals amigados error 118
  NARGS_ERR_BAD_TEMPLATE        = 7;    // equals amigados error 114
  NARGS_ERR_KEY_NEEDS_ARG       = 8;    // equals amigados error 117


  function  ParseArgs(const Template: AnsiString): integer; overload;
  function  ParseArgs(const Template: AnsiString; Arguments: AnsiString): integer; overload;
  function  ArgStr(index: integer): AnsiString; overload;
  function  ArgStr(ArgName: AnsiString): AnsiString; overload;
  function  ArgCount: integer;

  {$IFDEF DEBUG_NEWARGS}
  procedure DumpParsedTemplate;
  {$ENDIF}


implementation

uses
  NewArgs.Utils;
  

Type  
  TTemplateOptionProp =
  (
    tffIsSwitch,
    tffIsRequired,
    tffIsNumeric,
    tffIsKeyWord,
    tffIsMulti,
    tffNeedKeyWord  
  );

  TTemplateOptionProps = Set of TTemplateOptionProp;

  PTemplateOption = ^TTemplateOption;
  TTemplateOption = record
    Ident     : AnsiString;
    Props     : TTemplateOptionProps;
    Value     : AnsiString;
    Provided  : boolean;
  end;

  TTemplateOptions = array of TTemplateOption;

Type
  NARGS_MODES =
  (
    NARGS_MODE_REQUIRED,
    NARGS_MODE_KEYWORD,
    NARGS_MODE_NUMERIC,
    NARGS_MODE_SWITCH,
    NARGS_MODE_MULTI
  );


const
  NARGS_SWITCHES : array[NARGS_MODES] of AnsiChar = 'AKNSM';


var
  global_split      : TStringArray;
  local_split       : TStringArray;
  arg_strings       : TStringArray;
  template_options  : TTemplateOptions;


(*
  Delete an item from the array based on provided index
*)
Procedure  DeleteArrayItem(Var A: TStringArray; const index: Integer);
var
  ALength   : Cardinal;
  i         : Integer;
begin
  ALength := Length(A);
  Assert(ALength > 0);
  Assert(Index < ALength);
  for i := Index + 1 to ALength - 1 do
    A[i - 1] := A[i];
  SetLength(A, Pred(ALength));
end;


(*
  Delete an item from the array based on provided item (text)
*)
Procedure  DeleteArrayItem(Var A: TStringArray; const Item: AnsiString);
var
  index     : Integer;
begin
  for index := Low(A) to High(A) do
  begin
    if A[index] = Item then
    begin
      DeleteArrayItem(A, index);
      break;
    end;
  end;
end;


{$IFDEF DEBUG_NEWARGS}
function  TemplatePropsToString(Props: TTemplateOptionProps): AnsiString;
var
  i         : TTemplateOptionProp;
  retval    : AnsiString;
  propname  : AnsiString;
begin
  retval := '';
  for i := Low(TTemplateOptionProp) to High(TTemplateOptionProp) do
  begin
    if i in Props then
    begin
      case i of
        tffIsSwitch     : propname := 'isSwitch';
        tffIsRequired   : propname := 'isRequired';
        tffIsNumeric    : propname := 'isNumeric';
        tffIsKeyWord    : propname := 'isKeyWord';
        tffIsMulti      : propname := 'isMulti';
        tffNeedKeyWord  : propname := 'KeyWordRequired';
        else              propname := '';
      end;
      if i = Low(TTemplateOptionProp) 
      then retval := retval + propname
      else retval := retval + ' | ' + propname;
    end;
  end;
  TemplatePropsToString := retval;
end;
{$ENDIF}

{$IFDEF DEBUG_NEWARGS}
procedure DumpParsedTemplate;
var
  i: Integer;
begin
  WriteLn('dump of parse template:');
  for i := low(template_options) to High(template_options) do
  begin
    Writeln('Template[', i, '].Identifier = ', template_options[i].Ident);
    WriteLn('Template[', i, '].Props      = ', TemplatePropsToString(template_options[i].Props));
    Writeln('Template[', i, '].Value      = ', template_options[i].Value);
    Writeln('Template[', i, '].Provided   = ', template_options[i].Provided);
  end;
end;
{$ENDIF}


{$IFDEF DEBUG_NEWARGS}
function  GetArgsInfo: AnsiString;
var
  retval : AnsiString;
  i      : integer;
begin
  WriteStr(retval, Length(arg_strings));
  retval := retval + ' ->';
  for i := low(arg_strings) to high(arg_strings) do
    retval := retval + ' "' + arg_strings[i] + '"';
  GetArgsInfo := retval;  
end;
{$ENDIF}


(*
  Splits given string ToSplit using provided delims and store each part
  into variable Split.
*)
function SplitString(var Split: TStringArray; ToSplit: AnsiString; Delims: TSysCharSet): integer;
var
  i, n : Integer;
begin
  if ToSplit = '' then exit(-1);
  
  if Delims = [] then exit(-2);
  
  SetLength(Split, 0); // make sure the split is cleared
  
  n := WordCount(ToSplit, Delims);
  SetLength(Split, n);

  for i := Low(Split) to High(Split) do
    Split[i] := ExtractWord(succ(i), ToSplit, Delims);

  SplitString := 0;
end;


function nargs_add_template(Option: AnsiString): integer;
var
  retval    : integer;
  OptionID  : AnsiString;   // Option identifier
  OptionMod : AnsiString;   // Option Modifier
  Modifier  : AnsiChar;     // Modifier character
  Props     : TTemplateOptionProps;
  i,v       : integer;
begin
  retval := SplitString(local_split, Option, ['/']);
  if (retval <> 0) then exit(retval);
  
  OptionID := local_split[0];
  Props := [];
  
  for i := 1 to High(local_split) do
  begin
    OptionMod := local_split[i];
    if ( Length(OptionMod) > 1 ) then exit(NARGS_ERR_BAD_TEMPLATE);  // bad template, _must_ be a single char or less

    If ( Length(OptionMod) = 1 )
    then Modifier := OptionMod[1]
    else Modifier := #255; // Perhaps direct return with error when modifier has len zero ?

    v := IndexChar(NARGS_SWITCHES, Length(NARGS_SWITCHES), Modifier);
    {$IFDEF DEBUG_NEWARGS}
    WriteLn('modifier = ', Modifier, '  index = ', v, ' ord(NARGS_MODE_REQUIRED) = ', ord(NARGS_MODE_REQUIRED)  );
    {$ENDIF}

    if (v >= 0) then  // option modifier was recognized, act accordingly
    begin
      case NARGS_MODES(v) of
        NARGS_MODE_REQUIRED  : begin
                                 {$IFDEF DEBUG_NEWARGS}writeln('argument required');{$ENDIF}
                                 include(Props, tffIsRequired);
                               end;
        NARGS_MODE_KEYWORD   : begin include(Props, tffIsKeyWord); include(Props, tffNeedKeyWord); end;
        NARGS_MODE_NUMERIC   : include(Props, tffIsNumeric);
        NARGS_MODE_SWITCH    : include(Props, tffIsSwitch);
        NARGS_MODE_MULTI     : include(Props, tffIsMulti);
      end; // skip all other results
    end
    else // unrecognized/unsupported modifier used = bad template
      exit(NARGS_ERR_BAD_TEMPLATE);
  end;
  
  // we survived everything, so now would be a good moment to
  // add the entry to the template list.
  SetLength(template_options, Succ(Length(template_options)));

  // Initialize newly created template entry with its default values
  template_options[High(template_options)].Ident    := OptionID;
  template_options[High(template_options)].Props    := Props;
  template_options[High(template_options)].Value    := '';
  template_options[High(template_options)].Provided := false;

  exit(NARGS_ERR_NO_ERROR);
end;


function  nargs_parse_template(Template: AnsiString): Integer;
var
  retval : integer;
  i      : integer;
  Option : Ansistring;
begin
  // Use small trick to 'clean' out whitespace at same time
  retval := SplitString(global_split, Template, [' ', ',', #9]);
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);

  for i := Low(global_split) to high(global_split) do
  begin
    Option := global_split[i];
    {$IFDEF DEBUG_NEWARGS}Writeln('adding option ', Option);{$ENDIF}
    retval := nargs_add_template(Option);
    if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  end;
  exit(NARGS_ERR_NO_ERROR);    
end;


procedure Handle_Quotes(var S: AnsiString);
Var 
  t     : Integer; 
  inside: boolean;
begin
  inside := false;              // for starters, assume we are outside a quote

  for t := 1 to Length(S) do
  case inside of                // are we inside q quote ??
    true :                      // yes, we are inside a quote
      begin
        If (S[t] = '"') then    // is quote to be ended ?
        begin
          inside := false;      // make sure we know that we are not inside quote anymore
          S[t] := ' ';          // change endquote with space
        end
        else if (S[t] = ' ')    // is it a space
        then S[t] := #1;        // change spaces in quotes to #1
      end;
    false :                     // no, we are not inside a quote
      begin
        If (S[t] = '"') then    // is quote to be started ?
        begin
          inside := true;       // make sure we know we are inside a quote
          S[t] := ' ';          // change startquote with space
        end;
        If (S[t] = #9) 
        then S[t] := ' ';       // Change tab to spaces
      end;
  end; // case
end;


(*
  sinply replace all replacechars in S with replacementchar results in
  s being stripped from replacechar
*)
procedure Replace_Chars(var S: AnsiString; ReplaceChar: AnsiChar; ReplacementChar: AnsiChar);
var 
  i: integer;
begin
  // check if we have nothing to do
  if (S = '') then exit;

  // for each and every character in the string
  for i := 1 to length(S) do
  begin
    If (S[i] = ReplaceChar) then S[i] := ReplacementChar;
  end;
end;


procedure nargs_parse_string(Buffer: AnsiString);
var
  token : AnsiString;
  i     : Integer;
begin
  Handle_Quotes(Buffer);

  if (SplitString(global_split, Buffer, [' ','=']) <> NARGS_ERR_NO_ERROR)
  then exit;

  for i := Low(global_split) to High(global_split) do
  begin
    Token := global_split[i];
    if (Length(Token) > 0) then
    begin
      SetLength(arg_strings, Succ(Length(arg_strings)));
      arg_strings[High(arg_strings)] := Token;
    end;
  end;
end;


(*    
  ****
  NOTE:
  ****
  By default, the original AFC class does not support the definition of 
  multiple keywords in a template field.

  Splitting these multiple keywords up in FStr node is not viable as there 
  would be no way of telling which keywords belong to eachother. Ergo 
  duplication errors will occur.
  
  The easiest way to implement is by allowing for multiple keywords using the 
  '=' sign, but instead of using a simple comparison in the get_keyword 
  routine, to implement a specialised compare that retrieves the fieldnames
  (as is), splitting them up and do a compare for each splitted word.
  
  In FPC this is easy enough by using the wordcount and extractword routines
  to aid us. As is implemented below in function.
  
  Pro: easy to implement
  Con: bit stupid to split up each and everytime because things could be 
       implemented by splitting keywords only once during the lifetime.
  Conclusion: Because we only parse once, the Args routines are non time 
  critical in practise.
*)
function CompareAgainstTemplateKeys(String1, keys: AnsiString): Integer;
Var v, n, x: Integer; s: AnsiString;
begin
  // comparision. String 1 _might_ contain '=' token
  x := Wordcount(keys, ['=']);
  for n := 1 to x do
  begin
    s := ExtractWord(n, keys, ['=']);
    {$IFDEF BE_CASE_SENSITIVE}
    v := compareStr(string1, s);
    {$ELSE}
    v := compareText(string1, s);
    {$ENDIF}
    CompareAgainstTemplateKeys := v;
    if v = 0 then break;  
  end;
end;


{$PUSH}{$NOTES OFF}
function nargs_get_first_element(is_Numeric: boolean; var retElement: AnsiString): integer;
var
  ThisArg : AnsiString;
  V       : LongInt = 0;
  Code    : Word;
begin
  retElement := '';
  
  if (Length(arg_strings) < 1) then exit(NARGS_ERR_NO_ERROR);

  ThisArg := arg_strings[0];

  DeleteArrayItem(arg_strings, 0);
  Replace_Chars(ThisArg, #1, ' ');
  
  // Original code returned pointer to type specific storage, converting
  // the element to required type.
  if (is_Numeric) then
  begin
    Val(ThisArg, V, Code);
    if (code <> 0) then exit(NARGS_ERR_NOT_A_NUMBER);
    retElement := ThisArg;
  end
  else
  begin
    retElement := ThisArg;
  end;
  
  nargs_get_first_element := NARGS_ERR_NO_ERROR;;
end;
{$POP}


(*
  Search for the given key in the internal constructed argument array.
  If the key is found then delete it from the array but in case of non switches
  also get the corresponding keyvalue (returned in retKeyValue), which (if 
  existing) is also deleted from the argument array.
*)
{$PUSH}{$NOTES OFF}
function  nargs_get_keyword(key: AnsiString; is_Switch, is_numeric: boolean; var retKeyValue: AnsiString): integer;
var
  ThisArg   : Ansistring;
  i         : integer;
  V         : LongInt;
  Code      : Word;
begin
  // Clear returning string
  retKeyValue := '';    

  // for every argument in arg_strings
  for i := Low(arg_strings) to High(arg_strings) do
  begin
    // retrieve current argument from array
    ThisArg := arg_strings[i];

    // if arg taken from array equals the key we are looking for
    if (CompareAgainstTemplateKeys(ThisArg, key) = 0) then
    begin
      // remove recognized key from the arguments array
      DeleteArrayItem(arg_strings, i);

      // if there is still an argument left in the array (it could be empty at
      // this point) then retrieve this Arg. In case there isn't any left then
      // return an empty string.
      if (i < Length(arg_strings)) then ThisArg := arg_strings[i] else ThisArg := '';

      if (not(is_Switch) and (ThisArg = '')) then
      begin
        // Key was found but no matching keyvalue
        exit(NARGS_ERR_KEY_NEEDS_ARG);
      end;

      // If found key is a switch, we simply return a TRUE value
      // as data for that switch because we found it. A Switch does not have
      // a follow-up keyvalue only a keyname.
      if (is_Switch) then
      begin
        // return true, stating that the switch was present
        // retval := 'true';
        // exit(retval);
        retKeyValue := 'true';
        exit(NARGS_ERR_NO_ERROR);
      end
      else // recognized key is not a switch so has to be taken litteraly
      begin
        // if the keyvalue was not empty then we must parse it
        if (ThisArg <> '') then
        begin
          // Remove the key value argument from the argument array
          // so that it doesn't occur anymore
          DeleteArrayItem(arg_strings, i);

          // Convert char #1 to space in case we need it
          Replace_Chars(ThisArg, #1, ' ');
        end;
      end; // else if switch

      // if found key is a numeric value
      if (is_numeric) then
      begin
        // if it's sure that that the keyvalue is not empty then
        if (ThisArg <> '') then
        begin
          // We get the numeric representation of this arg, which is the 
          // key value for this found key word.
          Val(ThisArg, V, Code);
          if (Code <> 0) then exit(NARGS_ERR_NOT_A_NUMBER);
          retKeyValue := ThisArg;
          exit(NARGS_ERR_NO_ERROR);
        end;
        // in all other cases the keyword is missing an argument
        exit(NARGS_ERR_KEY_NEEDS_ARG);
      end; // if numeric

      // in all other cases we return the string. So keyvalue is anything but 
      // numeric
      retKeyValue := ThisArg;
      exit(NARGS_ERR_NO_ERROR);
    end;
  end;

  // If we haven't found anything, and the arg was a SWITCH, then
  // the switch was undetermined. we have to set the value for the switch to 
  // match something so we assign "false" to it.
  if (is_Switch) then
  begin
    retKeyValue := 'false';
    exit(NARGS_ERR_NO_ERROR); // no error occured. The switch was simply not provided
  end;

  // for all non switches, the value was (also) not provided, so we return an 
  // empty value.
  retKeyValue := '';
  nargs_get_keyword := NARGS_ERR_NO_ERROR;
end;
{$POP}


function  nargs_fill_names: integer;
var
  i         : Integer;
  Entry     : PTemplateOption;
  retVal    : Integer;
  Data      : AnsiString;
begin
  for i := Low(template_options) to High(template_options) do
  begin
    Entry := @template_options[i];
    if ( not(Entry^.Provided) and not(tffIsMulti in Entry^.Props) ) then
    begin
      retval := nargs_get_keyWord(Entry^.Ident, tffIsSwitch in Entry^.Props, tffIsNumeric in Entry^.Props, Data);
      if ( retval = NARGS_ERR_NO_ERROR ) then
      begin
        if ( Data <> '' ) then
        begin
          Entry^.Value := Data;
          Entry^.Provided := true;
        end;
      end
      else exit(retval);
    end;
  end;
  nargs_fill_names := NARGS_ERR_NO_ERROR;
end;


function  nargs_fill_keyword: integer;
var
  i         : Integer;
  Entry     : PTemplateOption;
  Data      : AnsiString;
  retVal    : integer;
begin
  for i := Low(template_options) to High(template_options) do
  begin
    Entry := @template_options[i];

    // if there is no active data and it needs a keyword then
    // if this currently examined field:
    // - is of the kind need keyword
    // - is not filled already
    // then:

    if ( (tffNeedKeyWord in Entry^.Props) and not(Entry^.Provided) ) then
    begin
      // get and remove the keyword 
      retVal := nargs_get_keyWord(Entry^.Ident, tffIsSwitch in Entry^.Props, tffIsNumeric in Entry^.Props, Data);
      if ( retVal = NARGS_ERR_NO_ERROR ) then
      begin
        if ( Data <> '' ) then
        begin
          Entry^.Value    := Data;
          Entry^.Provided := true;
        end;
      end
      else exit(retVal);
    end;
  end;
  nargs_fill_keyword := NARGS_ERR_NO_ERROR;
end;


function  nargs_fill_switch: integer;
var
  i         : Integer;
  Entry     : PTemplateOption;
  Data      : AnsiString;
  retVal    : integer;
begin
  for i := Low(template_options) to High(template_options) do
  begin
    Entry := @template_options[i];

    if ( (tffIsSwitch in Entry^.Props) and not(Entry^.Provided) ) then
    begin
      retVal := nargs_get_keyWord(Entry^.Ident, tffIsSwitch in Entry^.Props, false, Data);
      if ( retVal = NARGS_ERR_NO_ERROR ) then
      begin
        if ( Data <> '' ) then
        begin
          Entry^.Value    := Data;
          Entry^.Provided := true;
        end;
      end
      else exit(retVal);
    end;
  end;
  nargs_fill_switch := NARGS_ERR_NO_ERROR;
end;


{$PUSH}{$NOTES OFF}
function  nargs_fill_required: integer;
var
  i         : Integer;
  Entry     : PTemplateOption;
  Data      : AnsiString;
  ThisArg   : AnsiString;
  retVal    : integer;
  V         : LongInt;
  code      : Word;
begin
  for i := Low(template_options) to High(template_options) do
  begin
    Entry := @template_options[i];
    {$IFDEF DEBUG_NEWARGS}WriteLn('checking entry : ', i, ' = ', Entry^.Ident);{$ENDIF}
    if ( (tffIsRequired in Entry^.Props) and not(Entry^.Provided) and not(tffIsMulti in Entry^.Props) ) then
    begin
      {$IFDEF DEBUG_NEWARGS}WriteLn('entry : isRequired and not(processed) and not(isMulti)');{$ENDIF}
      retval := nargs_get_keyWord(Entry^.Ident, tffIsSwitch in Entry^.Props, tffIsNumeric in Entry^.Props, Data);
      {$IFDEF DEBUG_NEWARGS}WriteLn('get keyword returned : ', Data);{$ENDIF}
      if ( retval = NARGS_ERR_NO_ERROR ) then
      begin
        if (Data = '') then
        begin
          {$IFDEF DEBUG_NEWARGS}WriteLn('Data keyword was empty');{$ENDIF}
          RetVal := nargs_get_first_element(tffIsNumeric in Entry^.Props, ThisArg);
          if (retVal <> NARGS_ERR_NO_ERROR) then exit(retVal);
          {$IFDEF DEBUG_NEWARGS}WriteLn('ThisArg = ', ThisArg);{$ENDIF}
          if ThisArg = '' then
          begin
            {$IFDEF DEBUG_NEWARGS}WriteLn('LOG: Element required but nil ', Entry^.Ident);{$ENDIF}
            exit(NARGS_ERR_REQUIRED);
          end;
      
          if (tffIsNumeric in Entry^.Props) then
          begin
            Val(ThisArg, V, Code);
            If (Code <> 0) then exit(NARGS_ERR_NOT_A_NUMBER);
            Entry^.Value := ThisArg;
          end
          else    // not numeric -> so is string
          begin
            Entry^.Value := ThisArg;
          end;
          Entry^.Provided := true;
        end;
      end
      else exit(retval);
    end;
  end;
  nargs_fill_required := NARGS_ERR_NO_ERROR;
end;
{$POP}


function  nargs_fill_all_the_rest: integer;
var
  i     : Integer;
  Entry : PTemplateOption;
  Data  : AnsiString;
  retVal: integer;
begin
  for i := Low(template_options) to High(template_options) do
  begin
    Entry := @template_options[i];

    if ( not(Entry^.Provided) and not(tffIsMulti in Entry^.Props) and not(tffIsKeyWord in Entry^.Props) ) then
    begin
      retval := nargs_get_first_element(tffIsNumeric in Entry^.Props, Data);
      if (retVal <> NARGS_ERR_NO_ERROR) then exit(retVal);

      if (Data = '') then
      begin
        exit(NARGS_ERR_NO_ERROR);
      end
      else
      begin
        Entry^.Value    := Data;
        Entry^.Provided := true;
      end;
    end;
  end;
  nargs_fill_all_the_rest := NARGS_ERR_NO_ERROR;
end;


function  nargs_fill_multi: integer;
var
  i       : Integer;
  Entry   : PTemplateOption;
  Data    : AnsiString;
  ThisArg : AnsiString;
  retVal  : integer;
begin
  for i := Low(template_options) to High(template_options) do
  begin
    Entry := @template_options[i];
    Data := '';

    if ( tffIsMulti in Entry^.Props ) then
    begin
      retVal := nargs_get_first_element(tffIsNumeric in Entry^.Props, ThisArg);
      if (retVal <> NARGS_ERR_NO_ERROR) then exit(retVal);

      while (ThisArg <> '') do
      begin
        // 'correct' for first entry.
        if Data = '' 
        then Data := Data + ThisArg
        else Data := Data + #9 + ThisArg;
        retVal := nargs_get_first_element(tffIsNumeric in Entry^.Props, ThisArg);
        if (retVal <> NARGS_ERR_NO_ERROR) then exit(retVal);
      end;

      if (Data <> '') then
      begin
        Entry^.Value    := Data;
        Entry^.Provided := true;
      end;
      exit(NARGS_ERR_NO_ERROR);
    end;
  end;
  nargs_fill_multi := NARGS_ERR_NO_ERROR;
end;


procedure  nargs_clear;
begin
  SetLength(template_options, 0);
  SetLength(arg_strings, 0);
  SetLength(global_split, 0);
  SetLength(local_split, 0);
end;


function  ParseArgs(const Template: AnsiString): integer;
var
  Arguments : AnsiString;
  i         : integer;
  s         : AnsiString;
  res       : integer;
begin
  // Check if help was requested and act accordingly.
  for i := 0 to Pred(ParamCount) do
  begin
    s := LowerCase(ParamStr(i));
    if 
    ( 
      (s = '-h') or (s = '--help') or (s = '-help') or (s = '?') or (s = '-?') 
      or
      (s = '/h') or                   (s = '/help') or              (s = '/?')
    ) 
    then exit(NARGS_ERR_HELP_REQUESTED);
  end;

  // 'construct' commandline arguments. ToDo: figure out if this is enough
  // or that we need to do our own quotation.
  Arguments := cmdLine;
  // Parse supplied arguments with provided template.
  res := ParseArgs(Template, Arguments);
  // Return the result returned by ParseArgs().
  parseArgs := res;
end;


function  ParseArgs(const Template: AnsiString; Arguments: AnsiString): integer;
var
  Buffer    : AnsiString = '';
  retval    : integer;
begin
  nargs_clear;

  Buffer := Arguments;
  Buffer := Trim(Buffer);

  // i personally did not agree with the original implementation. So i've 
  // added checking for return values and act accordingly.

  retval := nargs_parse_template(Template);
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}

  nargs_parse_string(Buffer);

  {$IFDEF DEBUG_NEWARGS}WriteLn('1. ', GetArgsInfo);{$ENDIF}
  retval := nargs_fill_names;
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}  

  {$IFDEF DEBUG_NEWARGS}WriteLn('2. ', GetArgsInfo);{$ENDIF}
  if (nargs_fill_keyword <> NARGS_ERR_NO_ERROR)
  then exit(NARGS_ERR_MISSING_KEYWORD);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}

  {$IFDEF DEBUG_NEWARGS}WriteLn('3. ', GetArgsInfo);{$ENDIF}
  retval := nargs_fill_switch;
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}

  {$IFDEF DEBUG_NEWARGS}WriteLn('4. ', GetArgsInfo);{$ENDIF}
  retval := nargs_fill_required;
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}

  {$IFDEF DEBUG_NEWARGS}WriteLn('5. ', GetArgsInfo);{$ENDIF}
  retval := nargs_fill_all_the_rest;
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}

  {$IFDEF DEBUG_NEWARGS}WriteLn('6. ', GetArgsInfo);{$ENDIF}
  retval := nargs_fill_multi;
  if (retval <> NARGS_ERR_NO_ERROR) then exit(retval);
  {$IFDEF DEBUG_NEWARGS}DumpParsedTemplate;{$ENDIF}

  // In case there are still arguments left, then return error
  if ( Length(arg_strings) > 0 ) 
  then exit(NARGS_ERR_TOO_MANY_ARGS);

  exit( NARGS_ERR_NO_ERROR );
end;


function  ArgStr(index: integer): AnsiString;
begin
  // explicitly do not use index range checking and let the error happen
  // on purpose as it really is users fault and user should know this.
  ArgStr := template_options[index].Value;
end;


function  ArgStr(ArgName: AnsiString): AnsiString;
var
  index: integer;
begin
  for index := Low(template_options) to High(template_options) do
  begin
    if (CompareAgainstTemplateKeys(ArgName, template_options[index].Ident ) = 0) then
    begin
      exit( ArgStr(index) );
    end;
  end;
  // What ToDo: ? return error ? raise error ? return empty value ?
  ArgStr := '';
end;


function  ArgCount: integer;
begin
  ArgCount := Length(template_options);
end;


finalization
  nargs_clear;
end.
