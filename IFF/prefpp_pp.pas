unit prefpp_pp;

{*
 * Copyright (c) 2015 Magorium
 *
 * IFF PREF support based on:
 * - libiff done by Sander van der Burg.
 * - AROS preference files
 * - MUI 3.x documentation
 *}

{$MODE OBJFPC}{$H+}

interface


Const
  PREFPP_DISABLE_CHECK   = $01;


  function  PREF_prettyPrint(const filename: PChar; const options: Integer): Integer;


implementation


Uses
  libiff, libpref;


function  PREF_prettyPrint(const filename: PChar; const options: Integer): Integer;
var
  chunk : PIFF_Chunk;
var
  status    : Integer;
begin    

  //* Parse the chunk */
  if (filename = nil)
  then 
    chunk := PREF_readFd(StdInputHandle)
  else
    chunk := PREF_read(filename);


  if (chunk = nil) then
  begin
    WriteLn(StdErr, 'Cannot open PREF file!');
    exit(1);
  end
  else
  begin
    //* Check the file */
    if ((options and PREFPP_DISABLE_CHECK <> 0) or (PREF_check(chunk) <> 0 ) ) then
    begin
      //* Print the file */
      PREF_print(chunk, 0);
	    
      status := 0;
    end
    else
      status := 1;
      
    //* Free the chunk structure */
    PREF_free(chunk);
	    
    exit(status);
  end;
end;


end.
