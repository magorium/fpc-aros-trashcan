program list;

{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{.$DEFINE SHOWLEAKS}

Uses
  {$IFDEF SHOWLEAKS}heaptrc,{$ENDIF} Classes, fgl, SysUtils, fpMasks, pml.lformat;

Type
  PFileEntry = ^TFileEntry;
  TFileEntry = record
    FModifyStamp : LongInt;
    FSize        : Int64;
    FAttr        : LongInt;
    FName        : AnsiString;
    {$IFDEF LINUX}
    FPermissions : TMode;
    {$ENDIF}
    class operator <>(First: TFileEntry; Second: TFileEntry): Boolean;
  End;

  TFileEntryList = specialize TFPGList<TFileEntry>;


  TFilePop = class
   private
    FPath : String;
    FList : TFileEntryList;
   protected
    Function GetFileEntry(index: LongInt): TFileEntry;
    procedure FileSearcher(const pathname: String; FileMask: TMask; var Matched: TFileEntryList);
    Function GetItemCount: LongInt;
   public
    Constructor Create;
    Destructor  Destroy; override;
    Procedure Populate(Mask: String = '*'); overload;
    Procedure Populate(Folder: String; Mask: String = '*'); overload;
    property  Items[index: LongInt]: TFileEntry Read GetFileEntry;
    property  ItemCount: LongInt read GetItemCount;
  end;

Const
  AllWildMask = '*';


class operator TFileEntry.<>(First: TFileEntry; Second: TFileEntry): Boolean;
begin
  if (First.FModifyStamp <> Second.FModifyStamp) or
     (First.FSize        <> Second.FSize) or
     (First.FAttr        <> Second.FAttr) or
     (First.FName        <> Second.FName)
  then result := True
  else result := false;
end;



Constructor TFilePop.Create;
begin
  Inherited;
  FList := TFileEntryList.Create;
end;


Destructor TFilePop.Destroy;
begin
  FList.Free;
  Inherited;
end;


function TFilePop.GetFileEntry(index: LongInt): TFileEntry;
begin
  Result := FList.Items[index];
end;


Function TFilePop.GetItemCount: LongInt;
begin
  Result := FList.Count;
end;


procedure TFilePop.FileSearcher(const pathname: String; FileMask: TMask; var Matched: TFileEntryList);
var
  SR          : TSearchRec;
  sPath       : String;
  filename    : String;
  isMatch     : Boolean;
  FileEntry   : TFileEntry;
begin
  // FindFirst/FindNext requires proper path ending
  sPath := IncludeTrailingPathDelimiter(pathname);
  FPath := sPath;

  //  Find anyfile on the given Path matching All possible filenames
  if ( FindFirst(sPath + AllWildMask, faAnyFile, SR) = 0 ) then
  repeat
    // Use TSearchRec struct to retrieve the name of the current entry
    Filename := SR.Name;

    // match the mask against the curent filename
    IsMatch := FileMask.Matches(FileName);
 
    // check the result, if matched then add to results list
    if IsMatch then 
    begin
      {$IFDEF WINDOWS}
      // DO not list current and parent directory entries when windows
      if ((SR.Name <> '.') and (SR.name <> '..')) then
      {$ENDIF}
      begin
        FileEntry.FModifyStamp := SR.Time;
        FileEntry.FSize        := SR.Size;
        FileEntry.FAttr        := SR.Attr;
        FileEntry.FName        := SR.Name;
        {$IFDEF LINUX}
        FileEntry.FMode        := SR.Mode;
        {$ENDIF}
        Matched.Add(FileEntry);
      end;
    end;  // isMatch
  until ( FindNext(SR) <> 0 );

  // _Always_ call FindClose() after a call to FindFirst()
  FindClose(SR);
end;


procedure TFilePop.Populate(Mask: String = '*'); overload;
var
  NameMask : TMask;
begin
  NameMask  := TMask.Create(Mask);
  FList.Clear;
  FileSearcher(GetCurrentDir, NameMask, FList);
  NameMask.Free;
end;


procedure TFilePop.Populate(Folder: String; Mask: String = '*'); overload;
var
  NameMask : TMask;
begin
  NameMask  := TMask.Create(Mask);
  FList.Clear;
  FileSearcher(Folder, NameMask, FList);
  NameMask.Free;
end;


// Helper conversion functions

function FileStampToDT(Stamp: LongInt): TDateTime;
begin
  Result := FileDateToDateTime(Stamp);
end;


function IsDirectory(Attributes: LongInt): Boolean;
begin
  Result := ((Attributes and faDirectory) <> 0)
end;


(*
  faAnyFile     Match any file
  faArchive     Archive bit is set
  faDirectory   File is a directory
  faHidden      Hidden file.
  faReadOnly    Read-Only file.
  faSymLink     File is a symlink
  faSysFile     System file (Dos/Windows only)
  faVolumeId    Volume id (Fat filesystem, Dos/Windows only)
*)
function AttributesToStr(Attributes: LongInt): String;
begin
  Result := '';
  if ((Attributes and faDirectory) <> 0) then Result := Result + 'd' else Result := Result + '-';
  if ((Attributes and faArchive)   <> 0) then Result := Result + 'a' else Result := Result + '-';  
  if ((Attributes and faHidden)    <> 0) then Result := Result + 'h' else Result := Result + '-';  
  if ((Attributes and faReadOnly)  <> 0) then Result := Result + 'r' else Result := Result + '-';  
  if ((Attributes and faSymLink)   <> 0) then Result := Result + 'l' else Result := Result + '-';  
  {$IFDEF WINDOWS}
  if ((Attributes and faSysFile)   <> 0) then Result := Result + 's' else Result := Result + '-';  
  if ((Attributes and faVolumeID)  <> 0) then Result := Result + 'v' else Result := Result + '-';
  {$ENDIF}
end;


var
  FL               : TFilePop;
  ListFormatStr1   : String = '%D %A %14S %N';
  ListFormatStr2   : String = '%-30.30N  %14S  %D  [%A]';
  ListFormatParams : array[0..3] of TLFormatParameter = 
  (
    ( fmtChar : 'N'; fmtValue : '' ),
    ( fmtChar : 'S'; fmtValue : '' ),
    ( fmtChar : 'D'; fmtValue : '' ),
    ( fmtChar : 'A'; fmtValue : '' )
  );
  i : integer;
begin
  FL := TFilePop.Create;
  FL.Populate;

  for i := 0 to Pred(FL.ItemCount) do
  begin
    ListFormatParams[0].fmtValue := FL.Items[i].FName;
    if isDirectory(FL.Items[i].FAttr)
    then ListFormatParams[1].fmtValue := '<dir>'
    else ListFormatParams[1].fmtValue := IntToStr(FL.Items[i].FSize);
    ListFormatParams[2].fmtValue := FormatDateTime('DD-MM-YYYY  HH:NN:SS', FileStampToDT(FL.Items[i].FModifyStamp));
    ListFormatParams[3].fmtValue := AttributesToStr(FL.Items[i].FAttr);
    //    WriteLn(i, ' -> ', LFormat(ListFormatStr, ListFormatParams));
    WriteLn(LFormat(ListFormatStr1, ListFormatParams));
  end;
  WriteLn;
  WriteLn('===========================================');
  WriteLn;

  for i := 0 to Pred(FL.ItemCount) do
  begin
    // Note that filling the fmtValues (again) is not necessary but we like 
    // to separate the listings in a clear manner for this example code
    ListFormatParams[0].fmtValue := FL.Items[i].FName;
    if isDirectory(FL.Items[i].FAttr)
    then ListFormatParams[1].fmtValue := '<dir>'
    else ListFormatParams[1].fmtValue := IntToStr(FL.Items[i].FSize);
    ListFormatParams[2].fmtValue := FormatDateTime('DD-MM-YYYY  HH:NN:SS', FileStampToDT(FL.Items[i].FModifyStamp));
    ListFormatParams[3].fmtValue := AttributesToStr(FL.Items[i].FAttr);
    WriteLn(LFormat(ListFormatStr2, ListFormatParams));
  end;
  WriteLn;
  
  FL.Free;  
end.
