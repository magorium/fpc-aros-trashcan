unit pml.lformat;

(*
  LFormat - a poor man's LFormat implementation

  Given provided AnsiString S, replace each 'escaped' character that occurs in 
  S and replace its occurence with its fully qualified provided representation
  and return the resulting string.
  
  A list of escape characters (and their full representation) should be 
  provided with the params parameter.
  
  No check for escape character duplication (in the provided list) is made, 
  which means that first comes first serves.
  
  escape symbol is the percent sign. Use %% to output the percent sign itself.

  Additionally, the following (optional) modifiers are recognized inside
  the provided string s and escaped characters:
  - minus sign           : left-justify (also known as flush left).
                           By default (no sign) right justification is applied 
                           (also known as flush right).
  - decimal digit        : minimum full parameter representation width
  - dotted decimal digit : maximum full parameter representation width

  Since all parameters should be provided in AnsiString representation, there 
  are hypothetically no limits other then those that applies to (ansi) strings.
  
  examples:
  for practical examples see example programs.
  
  Some example LFormat strings:
  - 'hello %A%B%C'
  - 'hello %%%X%C'
  - 'hello %-24.5A%X%C'
  - 'hello %.5.6.7A%X%C'
  - '12345 [%10.5A] -- >%-4Z<'
  where A, B, C and Z represent the (provided) escape characters
  
  Current lformat interpretation requires re-evaluation of the format for each 
  entry.
*)

(*
        Additionally, the following modifiers, each optional, can be used,
        in this order, following the % character:

        left-justify         --  minus sign
        field width minimum  --  value
        value width maximum  --  dot value

        Value width maximum is not available for all numeric fields.

    RESULT

        Standard DOS return codes.

    EXAMPLE

        1> List C:
        Directory "c:" on Wednesday 12/18/14:
        Assign                      6548 ---rwed Saturday    01:12:16
        Copy                       17772 ---rwed Saturday    01:12:24
        AddBuffers                  5268 ---rwed Saturday    01:14:46
        Avail                       8980 ---rwed Saturday    01:14:51
        Delete                      8756 ---rwed Saturday    01:14:59
        Install                    13024 ---rwed Saturday    01:15:09
        List                       20228 ---rwed Today       12:06:38
        Which                       7840 ---rwed Saturday    01:16:09
        8 file - 167 blocks used
        1>
        1> List C: lformat "[%10.5M] -- >%-4b<"
         1234567890
        [     Assig] -- >13  <
        [      Copy] -- >35  <
        [     AddBu] -- >11  <
        [     Avail] -- >18  <
        [     Delet] -- >18  <
        [     Insta] -- >26  <
        [      List] -- >40  <
        [     Which] -- >16  <
        1> 
*)

interface

type
  TLFormatParameter = record
    fmtChar  : AnsiChar;
    fmtValue : AnsiString;
  end;

  TLFormatParameters = array of TLFormatParameter;

  function LFormat(LFmt: AnsiString; Parameters: TLFormatParameters): AnsiString;


implementation

uses
  SysUtils, StrUtils;

{$DEFINE ENABLE_LFMT_ESCAPE}
{$DEFINE ENABLE_LFMT_MODIFIERS}


// shameful plug of PrintLFormat() from List command in AROS source-tree
function LFormat(LFmt: AnsiString; Parameters: TLFormatParameters): AnsiString;
type
  TModifierType  = (mtJust, mtMax);
var
  ModifierString : Array[0..255] of Char;
  Modifiers      : Set of TModifierType;
  i              : LongInt;
  Ch             : Char;
  AttributeValue : AnsiString;
  Justification  : LongInt;
  maxlen         : LongInt;
var
  bufindex       : integer;
  dot            : integer;
  tmp            : AnsiString;

  function FindAttributeValue(Attribute: Char; var Value: AnsiString): boolean; inline;
  var
    ParameterIndex: integer;
  begin
    FindAttributeValue := false;
    Value  := '';
    for ParameterIndex := Low(Parameters) to High(Parameters) do
    begin
      if (Parameters[ParameterIndex].fmtChar = Attribute) then
      begin
        Value := Parameters[ParameterIndex].fmtValue;
        FindAttributeValue := true;
        Break;
      end;
    end;
  end;

  procedure GetModifiers; inline;
  var
    tmp : AnsiString;
    j,m : AnsiString;
  begin
    Modifiers := [];

    tmp := ModifierString;
    RemoveLeadingChars(tmp, ['%']);    

    if (Length(tmp) > 0) then
    begin
      j := Copy2SymbDel(tmp, '.');
      if (Length(J) > 0) then
      begin
        if TryStrToInt(J, Justification) 
        then include(modifiers, mtJust);
      end
      else
      begin
        exclude(modifiers, mtJust);
      end;
    end;

    if (Length(tmp) > 0) then
    begin
      if pos('.', tmp) = 1 then RemoveLeadingChars(tmp, ['%']);
    end;

    if (Length(tmp) > 0) then
    begin
      m := tmp;

      if (Length(m) > 0) then
      begin
        if TryStrToInt(m, maxlen) 
        then include(modifiers, mtMax);
      end
      else
      begin
        exclude(modifiers, mtMax);
      end;
    end;
  end;


begin
  LFormat := '';

  i := 1;
  while (i <= Length(LFmt)) do
  begin
    Ch := LFmt[i];
    Inc(i);

    {$IFDEF ENABLE_LFMT_ESCAPE}
    if (Ch = '%') then
    begin

      {$IFDEF ENABLE_LFMT_MODIFIERS}
      // Try for modifiers
      bufindex := 0;
      dot      := 0;
      FillChar(ModifierString, SizeOf(ModifierString), #0);
      ModifierString[bufindex] := '%';
      inc(bufindex);

      while (i <= Length(LFmt)) do
      begin
        Ch := LFmt[i]; 
        inc(i);
        
        if (Ch = '-') then
        begin
          bufindex := 1;
          dot      := 0;
        end
        else if (Ch = '.') then
        begin
          if (dot <> 0) then
          begin
            bufindex := dot;
          end
          else
          begin
            dot := bufIndex;
          end;
        end
        else if not(Ch in ['0'..'9']) then
        begin
          // Actual conversion from modifierstring to actual values and
          // modifier detection done in getmodifier routine
          break;
        end;
        // Always add any other char
        if (bufindex < 255) then
        begin
          ModifierString[bufindex] := Ch;
          inc(bufIndex);
        end;
      end;
      {$ENDIF}

      // interpret arguments
      if FindAttributeValue(Ch, AttributeValue) then
      begin
        tmp := ModifierString;
        
        if (Length(tmp) > 1) then
        begin
          GetModifiers;
          // if maxlen provided then apply
          if (mtMax in modifiers) then 
          begin
            AttributeValue := LeftStr(AttributeValue, maxLen);
          end;
          // if justification provided ten apply
          if (mtJust in modifiers) then
          begin
            if (justification < 0) then 
            begin                           // pad to right (left justify)
              AttributeValue := PadRight(AttributeValue, abs(justification));
            end
            else 
            if (justification > 0) then
            begin                           // pad to left (right justify)
              AttributeValue := PadLeft(AttributeValue, justification);
            end
            else                            // justification = 0
            begin
              // we can actually skip this line...
              AttributeValue := AttributeValue;
            end;
          end;
          LFormat := LFormat + AttributeValue;
        end
        else
          LFormat := LFormat + AttributeValue;
      end
      else
      begin
        LFormat := LFormat + Ch;
      end;
    end
    else
    {$ENDIF}
      LFormat := LFormat + Ch;
  end;  // while
end;

end.
