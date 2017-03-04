unit libiff;

{*
 * Copyright (c) 2012 Sander van der Burg
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *}

  //   ***   Pascal conversion by magorium, 2015   ***   //

{$MODE OBJFPC}{$H+}{$UNITPATH .}


interface


Uses
  ctypes;



// ###########################################################################
// ###
// ###      type definitions
// ###
// ###########################################################################



//////////////////////////////////////////////////////////////////////////////
//        ifftypes.h
//////////////////////////////////////////////////////////////////////////////



Const
  IFF_ID_SIZE   = 4;

Const
  _TRUE_        = 1;
  _FALSE_       = 0;


Type
  //** A signed byte */
  TIFF_Byte     = cschar;

  //** An unsigned byte */
  TIFF_UByte    = cuchar;

  //** A 16-bit signed type */
  TIFF_Word     = csshort;

  //** A 16-bit unsigned type */
  TIFF_UWord    = cushort;

  //** A 32-bit signed type */
  TIFF_Long     = cint;

  //** A 32-bit unsigned type */
  TIFF_ULong    = cuint;

  //** A 4 byte ID type */
  TIFF_ID       = packed array [0..IFF_ID_SIZE-1] of char;

  // 
  //
  //

  //** Pointer to a signed byte */
  PIFF_Byte     = ^TIFF_Byte;

  //** Pointer to a unsigned byte */
  PIFF_UByte    = ^TIFF_UByte;

  //** Pointer to pointer to a unsigned byte */
  PPIFF_UByte   = ^PIFF_UByte;

  //** Pointer to a 16-bit signed type */
  PIFF_Word     = ^TIFF_Word;

  //** Pointer to a 16-bit unsigned type */
  PIFF_UWord    = ^TIFF_UWord;

  //** Pointer to a 32-bit signed type */
  PIFF_Long     = ^TIFF_Long;

  //** Pointer to a 32-bit unsigned type */
  PIFF_ULong    = ^TIFF_ULong;

  //** Pointer to a 4 byte ID type */
  PIFF_ID       = ^TIFF_ID;

{$IFDEF ENDIAN_BIG}
  {$DEFINE IFF_BIG_ENDIAN}
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//        chunk.h
//////////////////////////////////////////////////////////////////////////////



  PIFF_GROUP = ^TIFF_GROUP;

  {**
  * @brief An abstract chunk containing the common properties of all chunk types
  *}
  PPIFF_Chunk = ^PIFF_Chunk;
  PIFF_Chunk = ^TIFF_Chunk;
  IFF_Chunk = 
  record
    //** Pointer to the parent group chunk, in which this chunk is located. The parent points to NULL if there is no parent. */
    parent      : PIFF_Group;

    //** Contains a 4 character ID of this chunk */
    chunkId     : TIFF_ID;

    //** Contains the size of the chunk data in bytes */
    chunkSize   : TIFF_Long;
  end;
  TIFF_Chunk = IFF_Chunk;



//////////////////////////////////////////////////////////////////////////////
//        extension.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * @brief Defines how a particular application chunk within a FORM should be handled.
  }
  PIFF_FormExtension = ^TIFF_FormExtension;
  IFF_FormExtension =
  record
    //** A 4 character chunk id */
    chunkId      : PIFF_ID;

    //** Function resposible for reading the given chunk */
    readchunk    : function(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk;

    //** Function resposible for writing the given chunk */
    writechunk   : function(filehandle: THandle; const chunk: PIFF_Chunk): cint;

    //** Function resposible for checking the given chunk */
    checkchunk   : function(const chunk: PIFF_Chunk): cint;

    //** Function resposible for freeing the given chunk */
    freeChunk    : procedure(chunk: PIFF_Chunk);

    //** Function responsible for printing the given chunk */
    printChunk   : procedure(const chunk: PIFF_Chunk; const indentLevel: cuint);

    //** Function responsible for comparing the given chunk */
    compareChunk : function(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
  end;
  TIFF_FormExtension = IFF_FormExtension;

  {**
  * @brief Defines how application chunks in a FORM with a particular formType should be handled.
  *}
  PIFF_Extension = ^IFF_Extension;
  IFF_Extension =
  record
    //** A 4 character form type id */
    formType                : PIFF_ID;

    //** Specifies the number of application chunks in the form that should be handled by external functions */
    formExtensionsLength    : cuint;

    //** An array specifying how application chunks within the form context should be handled */
    formExtensions          : PIFF_FormExtension;
  end;
  TIFF_Extension = IFF_Extension;



//////////////////////////////////////////////////////////////////////////////
//        group.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * @brief An abstract group chunk, which contains all common properties of the compound chunk types. This chunk type should never be used directly.
  *}
  PPIFF_Group = ^PIFF_Group;    // for PIFF_Group, see above
  IFF_Group =
  record

    //** Pointer to the parent group chunk, in which this chunk is located. The parent points to NULL if there is no parent. */
    parent      : PIFF_Group;

    //** Contains a 4 character ID of this chunk */
    chunkId     : TIFF_ID;

    //** Contains the size of the chunk data in bytes */
    chunkSize   : TIFF_Long;

    //** Could be either a formType or a contentsType */
    groupType   : TIFF_ID;

    //** Contains the number of sub chunks stored in this group chunk */
    chunkLength : cuint;

    //** An array of chunk pointers referring to the sub chunks */
    chunk       : PPIFF_Chunk;
  end;
  TIFF_Group = IFF_Group;



//////////////////////////////////////////////////////////////////////////////
//        form.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * @brief A special group chunk, which contains an arbitrary number of group chunks and data chunks.
  *}
  PPIFF_Form = ^PIFF_Form;
  PIFF_Form = ^TIFF_Form;
  IFF_Form = 
  record

    //** Pointer to the parent group chunk, in which this chunk is located. The parent points to NULL if there is no parent. */
    parent      : PIFF_Group;

    //** Contains the ID of this chunk, which equals to 'FORM' */
    chunkId     : TIFF_ID;

    //** Contains the size of the chunk data in bytes */
    chunkSize   : TIFF_Long;

    {**
     * Contains a form type, which is used for most application file formats as an
     * application file format identifier
     *}
    formType    : TIFF_ID;

    //** Contains the number of sub chunks stored in this form chunk */
    chunkLength : cuint;

    //** An array of chunk pointers referring to the sub chunks */
    chunk       : PPIFF_Chunk;
  end;
  TIFF_Form  = IFF_Form;



//////////////////////////////////////////////////////////////////////////////
//        cat.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * @brief A special group chunk, which contains one or more FORM, LIST or CAT chunks.
  *}
  PIFF_CAT = ^TIFF_CAT;
  IFF_CAT = 
  record
    //** Pointer to the parent group chunk, in which this chunk is located. The parent points to NULL if there is no parent. */
    parent          : PIFF_Group;

    //** Contains a 4 character ID of this chunk, which equals to 'CAT ' */
    chunkId         : TIFF_ID;

    //** Contains the size of the chunk data in bytes */
    chunkSize       : TIFF_Long;

    {**
     * Contains a type ID which hints about the contents of this concatenation.
     * 'JJJJ' is used if this concatenation stores forms of multiple form types.
     * If only one form type is used in this concatenation, this contents type
     * should be equal to that form type.
     *}
    contentsType    : TIFF_ID;

    //** Contains the number of sub chunks stored in this concatenation chunk */
    chunkLength     : cuint;

    //** An array of chunk pointers referring to the sub chunks */
    chunk           : PPIFF_Chunk;
  end;
  TIFF_CAT  = IFF_CAT;



//////////////////////////////////////////////////////////////////////////////
//        prop.h
//////////////////////////////////////////////////////////////////////////////

 

  PPIFF_Prop    = ^PIFF_Prop;
  PIFF_Prop     = ^TIFF_Prop;
  IFF_Prop      = TIFF_Form;
  TIFF_Prop     = IFF_Form;



//////////////////////////////////////////////////////////////////////////////
//        list.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * @brief A special group chunk, which contains one or more FORM, LIST or CAT chunks and PROP chunks which share common data chunks with the nested group chunks.
  *}
  PIFF_LIST = ^TIFF_LIST;
  IFF_List =
  record
    //** Pointer to the parent group chunk, in which this chunk is located. The parent points to NULL if there is no parent. */
    parent          : PIFF_Group;

    //** Contains the ID of this chunk, which equals to 'LIST' */
    chunkId         : TIFF_ID;

    //** Contains the size of the chunk data in bytes */
    chunkSize       : TIFF_Long;

    {**
     * Contains a type ID which hints about the contents of this list.
     * 'JJJJ' is used if this concatenation stores forms of multiple form types.
     * If only one form type is used in this concatenation, this contents type
     * should be equal to that form type.
     *}
    contentsType    : TIFF_ID;

    //** Contains the number of sub chunks stored in this list chunk */
    chunkLength     : cuint;

    //** An array of chunk pointers referring to the sub chunks */
    chunk           : PPIFF_Chunk;

    //** Contains the number of PROP chunks stored in this list chunk */
    propLength      : cuint;

    //** An array of chunk pointers referring to the PROP chunks */
    prop            : PPIFF_Prop;
  end;
  TIFF_LIST = IFF_LIST;



//////////////////////////////////////////////////////////////////////////////
//        rawchunk.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * @brief A raw chunk, which contains an arbitrary number of bytes.
  *}
  PIFF_RawChunk = ^TIFF_RawChunk;
  IFF_RawChunk =
  record

    //** Pointer to the parent group chunk, in which this chunk is located. The parent points to NULL if there is no parent. */
    parent      : PIFF_Group;

    //** Contains a 4 character ID of this chunk */
    chunkId     : TIFF_ID;

    //** Contains the size of the chunk data in bytes */
    chunkSize   : TIFF_Long;

    //** An array of bytes representing raw chunk data */
    chunkData   : PIFF_UByte;
  end;
  TIFF_RawChunk = IFF_RawChunk;





// ###########################################################################
// ###
// ###      function declarations
// ###
// ###########################################################################





//////////////////////////////////////////////////////////////////////////////
//        ifftypes.h
//////////////////////////////////////////////////////////////////////////////



// empty



//////////////////////////////////////////////////////////////////////////////
//        error.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * A function pointer specifying which error callback function should be used.
  *}
//var
//  IFF_errorCallback: Procedure(const char *formatString, va_list ap);

  {**
  * An error callback function printing errors to the standard error.
  *
  * @param formatString A format specifier for fprintf()
  * @param ap A list of command-line parameters
  *}
//  void IFF_errorCallbackStderr(const char *formatString, va_list ap);

  {**
  * The error callback function used by the IFF library and derivatives.
  *
  * @param formatString A format specifier for fprintf()
  *}
  procedure IFF_error(const formatString: PChar);
  procedure IFF_error(const formatString: PChar; const Arguments: Array of const);


  {**
  * Prints a 4 character IFF id on the standard error
  *
  * @param id A 4 character IFF id
  *}
  procedure IFF_errorId(const id: TIFF_ID);

  {**
  * Prints a standard read error message.
  *
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  *}
  procedure IFF_readError(const chunkId: TIFF_ID; const attributeName: PChar);

  {**
  * Prints a standard write error message.
  *
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  *}
  procedure IFF_writeError(const chunkId: TIFF_ID; const attributeName: PChar);



//////////////////////////////////////////////////////////////////////////////
//        iff.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Reads an IFF file from a given file descriptor. The resulting chunk must be freed using IFF_free().
  *
  * @param file File descriptor of the file
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return A chunk hierarchy derived from the IFF file, or NULL if an error occurs
  *}
  function  IFF_readFd(filehandle: THandle; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Chunk;

  {**
  * Reads an IFF file from a file with the given filename. The resulting chunk must be freed using IFF_free().
  *
  * @param filename Filename of the file
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return A chunk hierarchy derived from the IFF file, or NULL if an error occurs
  *}
  function  IFF_read(const filename: PChar; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Chunk;

  {**
  * Writes an IFF file to a given file descriptor.
  *
  * @param file File descriptor of the file
  * @param chunk A chunk hierarchy representing an IFF file
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the file has been successfully written, else FALSE
  *}
  function  IFF_writeFd(filehandle: THandle; const chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Writes an IFF file to a file with the given filename.
  *
  * @param filename Filename of the file
  * @param chunk A chunk hierarchy representing an IFF file
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the file has been successfully written, else FALSE
  *}
  function  IFF_write(const filename: PChar; const chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Frees an IFF chunk hierarchy from memory.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_free(chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether an IFF file conforms to the IFF specification.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the IFF file conforms to the IFF specification, else FALSE
  *}
  function  IFF_check(const chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Displays a textual representation of an IFF file on the standard output.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param indentLevel Indent level of the textual representation
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_print(const chunk: PIFF_Chunk; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether two given IFF files are equal.
  *
  * @param chunk1 Chunk hierarchy to compare
  * @param chunk2 Chunk hierarchy to compare
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given chunk hierarchies are equal, else FALSE
  *}
  function  IFF_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;



//////////////////////////////////////////////////////////////////////////////
//        util.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Prints a formatted string to the given file descriptor using a certain indent
  * level.
  *
  * @param file File descriptor of the file
  * @param indentLevel Indent level
  * @param formatString A format specifier for fprintf()
  *}
  procedure IFF_printIndent(filehandle: THandle; indentlevel: cint; const formatString: PChar);
  procedure IFF_printIndent(filehandle: THandle; indentlevel: cint; const formatString: PChar; const arguments: array of const);



//////////////////////////////////////////////////////////////////////////////
//        chunk.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Allocates memory for a chunk with the given chunk ID and chunk size.
  * The resulting chunk must be freed using IFF_free()
  *
  * @param chunkId A 4 character id
  * @param chunkSize Size of the chunk in bytes
  * @return A generic chunk with the given chunk Id and size, or NULL if the memory can't be allocated.
  *}
  function  IFF_allocateChunk(const chunkId: PIFF_ID; const chunkSize: csize_t): PIFF_Chunk;

  {**
  * Reads a chunk hierarchy from a given file descriptor. The resulting chunk must be freed using IFF_free()
  *
  * @param file File descriptor of the file
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return A chunk hierarchy derived from the IFF file, or NULL if an error occurs
  *}
  function  IFF_readChunk(filehandle: THandle; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Chunk;

  {**
  * Writes a chunk hierarchy to a given file descriptor.
  *
  * @param file File descriptor of the file
  * @param chunk A chunk hierarchy representing an IFF file
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the file has been successfully written, else FALSE
  *}
  function  IFF_writeChunk(filehandle: THandle; const chunk: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Checks whether a chunk hierarchy conforms to the IFF specification.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the IFF file conforms to the IFF specification, else FALSE
  *}
  function  IFF_checkChunk(const chunk: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Frees an IFF chunk hierarchy from memory.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_freeChunk(chunk: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength : cuint);

  {/**
  * Displays a textual representation of an IFF chunk hierarchy on the standard output.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param indentLevel Indent level of the textual representation
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printChunk(const chunk: PIFF_Chunk; const indentLevel: cuint; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether two given chunk hierarchies are equal.
  *
  * @param chunk1 Chunk hierarchy to compare
  * @param chunk2 Chunk hierarchy to compare
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given chunk hierarchies are equal, else FALSE
  *}
  function  IFF_compareChunk(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recursively searches for all FORMs with the given form type in a chunk hierarchy.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  * @param formType A 4 character form identifier
  * @param formsLength An integer in which the length of the resulting array is stored
  * @return An array of forms having the given form type
  *}
  function  IFF_searchForms(chunk: PIFF_Chunk; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;

  {**
  * Increments the given chunk size by the size of the given chunk.
  * Additionally, it takes the padding byte into account if the chunk size is odd.
  *
  * @param chunkSize Chunk size of a group chunk
  * @param chunk A sub chunk
  * @return The incremented chunk size with an optional padding byte
  *}
  function  IFF_incrementChunkSize(const chunkSize: TIFF_Long; const chunk: PIFF_Chunk): TIFF_Long;

  {**
  * Recalculates the chunk size of the given chunk and recursively updates the chunk sizes of the parent group chunks.
  *
  * @param chunk A chunk hierarchy representing an IFF file
  *}
  procedure IFF_updateChunkSizes(chunk: PIFF_Chunk);



//////////////////////////////////////////////////////////////////////////////
//        extension.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Searches for a form extension that can deal with a chunk in a given form with a form type and a given chunk id
  *
  * @param formType A 4 character form type id. If the formType is NULL, the function will always return NULL
  * @param chunkId A 4 character chunk id
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return The form extension that handles the specified chunk or NULL if it does not exists
  *}
  function IFF_findFormExtension(const formType: PIFF_ID; const chunkId: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_FormExtension;



//////////////////////////////////////////////////////////////////////////////
//        group.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Initializes the members of the group chunk instances with default values.
  *
  * @param group A group chunk instance
  * @param groupType A group type ID
  *}
  procedure IFF_initGroup(group: PIFF_Group; const groupType: PIFF_ID);

  {**
  * Creates a new group chunk instance with the chunk id and group type.
  * The resulting chunk must be freed by using IFF_free().
  *
  * @param chunkId A 4 character chunk id.
  * @param groupType Type describing the purpose of the sub chunks.
  * @return Group chunk or NULL, if the memory for the struct can't be allocated
  *}
  function  IFF_createGroup(const chunkId: PIFF_ID; const groupType: PIFF_ID): PIFF_Group;

  {**
  * Adds a chunk to the body of the given group. This function also increments the
  * chunk size and chunk length counter.
  *
  * @param group An instance of a group chunk
  * @param chunk An arbitrary group or data chunk
  *}
  procedure IFF_addToGroup(group: PIFF_Group; chunk: PIFF_Chunk);

  {**
  * Reads a group chunk and its sub chunks from a file. The resulting chunk must be
  * freed by using IFF_free().
  *
  * @param file File descriptor of the file
  * @param chunkId A 4 character chunk id
  * @param chunkSize Size of the chunk data
  * @param groupTypeName Specifies what the group type is called. Could be 'formType' or 'contentsType'
  * @param groupTypeIsFormType Indicates whether the groupType represents a formType
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return The group struct derived from the file, or NULL if an error has occured
  *}
  function  IFF_readGroup(filehandle: THandle; const chunkId: PIFF_ID; const chunkSize: TIFF_Long; const groupTypeName: PIFF_ID; const groupTypeIsFormType: cint; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Group;

  {**
  * Writes all sub chunks inside a group to a file.
  *
  * @param file File descriptor of the file
  * @param group An instance of a group chunk
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the sub chunks have been successfully written, else FALSE
  *}
  function  IFF_writeGroupSubChunks(filehandle: THandle; const group: PIFF_Group; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Writes a group chunk and its sub chunks to a file.
  *
  * @param file File descriptor of the file
  * @param group An instance of a group chunk
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param groupTypeName Specifies what the group type is called. Could be 'formType' or 'contentsType'
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the group has been successfully written, else FALSE
  *}
  function  IFF_writeGroup(filehandle: THandle; const group: PIFF_Group; const formType: PIFF_ID; const groupTypeName: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Checks whether the given chunk size matches the chunk size of the group
  *
  * @param group An instance of a group chunk
  * @param chunkSize A chunk size
  * @return TRUE if the chunk sizes are equal, else FALSE
  *}
  function IFF_checkGroupChunkSize(const group: PIFF_Group; const chunkSize: TIFF_Long): cint;

  {**
  * Checks whether the group sub chunks are valid
  *
  * @param group An instance of a group chunk
  * @param subChunkCheck Pointer to a function, which checks an individual sub chunk for its validity
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return The size of the sub chunks together, or -1 if a failure has occured
  *}
  type
  TIFF_checkGroupSubChunksFunc = function(const group: PIFF_Group; const subChunk: PIFF_Chunk): cint;

  function  IFF_checkGroupSubChunks(const group: PIFF_Group; subChunkCheck: TIFF_checkGroupSubChunksFunc; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): TIFF_Long;

  {**
  * Checks whether the group chunk and its sub chunks conform to the IFF specification.
  *
  * @param group An instance of a group chunk
  * @param groupTypeCheck Pointer to a function, which checks the groupType for its validity
  * @param subChunkCheck Pointer to a function, which checks an individual sub chunk for its validity
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the form is valid, else FALSE.
  *}
  type
//  TIFF_groupTypeCheckFunc = function(const groupType: PChar): cint;
  TIFF_groupTypeCheckFunc = function(const groupType: PIFF_ID): cint;
  TIFF_subChunkCheckFunc = function(const group: PIFF_Group; const subChunk: PIFF_Chunk): cint;

  function  IFF_checkGroup(const group: PIFF_Group; groupTypeCheck: TIFF_groupTypeCheckFunc; subChunkCheck: TIFF_subChunkCheckFunc; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recursively frees the memory of the sub chunks of the given group chunk.
  *
  * @param group An instance of a group chunk
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_freeGroup(group: PIFF_Group; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Displays the group type on the standard output.
  *
  * @param groupTypeName Specifies what the group type is called. Could be 'formType' or 'contentsType'
  * @param groupType A group type ID
  * @param indentLevel Indent level of the textual representation
  *}
  procedure IFF_printGroupType(const groupTypeName: PIFF_ID; const groupType: PIFF_ID; const indentLevel: cuint);

  {**
  * Displays a textual representation of the sub chunks on the standard output.
  *
  * @param group An instance of a group chunk
  * @param indentLevel Indent level of the textual representation
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printGroupSubChunks(const group: PIFF_Group; const indentLevel: cuint; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Displays a textual representation of the group chunk and its sub chunks on the standard output.
  *
  * @param group An instance of a group chunk
  * @param indentLevel Indent level of the textual representation
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param groupTypeName Specifies what the group type is called. Could be 'formType' or 'contentsType'
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printGroup(const group: PIFF_Group; const indentLevel: cuint; const formType: PIFF_ID; const groupTypeName: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether the given group chunks' contents is equal to each other.
  *
  * @param group1 Group to compare
  * @param group2 Group to compare
  * @param formType Form type id describing in which FORM the sub chunk is located. NULL is used for sub chunks in other group chunks.
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given groups are equal, else FALSE
  *}
  function  IFF_compareGroup(const group1: PIFF_Group; const group2: PIFF_Group; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Returns an array of form structs of the given formType, which are recursively retrieved from the given group.
  *
  * @param group An instance of a group chunk
  * @param formType A 4 character form type ID
  * @param formsLength Returns the length of the resulting array
  * @return An array of form structs
  *}
  function  IFF_searchFormsInGroup(group: PIFF_Group; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;

  {**
  * Recalculates the chunk size of the given group chunk.
  *
  * @param group An instance of a group chunk
  *}
  procedure IFF_updateGroupChunkSizes(group: PIFF_Group);



//////////////////////////////////////////////////////////////////////////////
//        form.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Creates a new form chunk instance with the given form type.
  * The resulting chunk must be freed by using IFF_free().
  *
  * @param formType Form type describing the purpose of the sub chunks.
  * @return FORM chunk or NULL, if the memory for the struct can't be allocated
  *}
  function  IFF_createForm(const formType: PIFF_ID): PIFF_Form;

  {**
  * Adds a chunk to the body of the given FORM. This function also increments the
  * chunk size and chunk length counter.
  *
  * @param form An instance of a FORM chunk
  * @param chunk An arbitrary group or data chunk
  *}
  procedure IFF_addToForm(form: PIFF_Form; chunk: PIFF_Chunk);

  {**
  * Reads a form chunk and its sub chunks from a file. The resulting chunk must be
  * freed by using IFF_free().
  *
  * @param file File descriptor of the file
  * @param chunkSize Size of the chunk data
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return The form struct derived from the file, or NULL if an error has occured
  *}
  function  IFF_readForm(filehandle: THandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Form;

  {**
  * Writes a form chunk and its sub chunks to a file.
  *
  * @param file File descriptor of the file
  * @param form An instance of a form chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the FORM has been successfully written, else FALSE
  *}
  function IFF_writeForm(filehandle: THandle; const form: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Checks whether the given form type conforms to the IFF specification.
  *
  * @param formType A 4 character form identifier
  * @return TRUE if the form type is valid, else FALSE
  *}
//  function  IFF_checkFormType(const formType: TIFF_ID): cint;
  function  IFF_checkFormType(const formType: PIFF_ID): cint;

  {**
  * Checks whether the form chunk and its sub chunks conform to the IFF specification.
  *
  * @param form An instance of a form chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the form is valid, else FALSE.
  *}
  function  IFF_checkForm(const form: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recursively frees the memory of the sub chunks of the given form chunk.
  *
  * @param form An instance of a form chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure  IFF_freeForm(form: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Displays a textual representation of the form chunk and its sub chunks on the standard output.
  *
  * @param form An instance of a form chunk
  * @param indentLevel Indent level of the textual representation
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printForm(const form: PIFF_Form; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether the given forms' contents is equal to each other.
  *
  * @param form1 Form to compare
  * @param form2 Form to compare
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given forms are equal, else FALSE
  *}
  function  IFF_compareForm(const form1: PIFF_Form; const form2: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Merges two given IFF form arrays in the target array.
  *
  * @param target Target form array
  * @param targetLength Length of the target form array
  * @param source Source form array
  * @param sourceLength Length of the source form array
  * @return A reallocated target form array containing the forms of both the source and target arrays
  *}
  function  IFF_mergeFormArray(target: PPIFF_Form; targetLength: pcuint; source: PPIFF_Form; const sourceLength: cuint): PPIFF_Form;

  {**
  * Returns an array of form structs of the given formType, which are recursively retrieved from the given form.
  *
  * @param form An instance of a form chunk
  * @param formType A 4 character form type ID
  * @param formsLength Returns the length of the resulting array
  * @return An array of form structs
  *}
  function  IFF_searchFormsInForm(form: PIFF_Form; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;

  {**
  * Recalculates the chunk size of the given form chunk.
  *
  * @param form An instance of a form chunk
  *}
  procedure IFF_updateFormChunkSizes(form: PIFF_Form);

  {**
  * Retrieves the chunk with the given chunk ID from the given form.
  *
  * @param form An instance of a form chunk
  * @param chunkId An arbitrary chunk ID
  * @return The chunk with the given chunk ID, or NULL if the chunk can't be found
  *}
  function  IFF_getDataChunkFromForm(const form: PIFF_Form; const chunkId: PIFF_ID): PIFF_Chunk;

  {**
  * Retrieves the chunk with the given chunk ID from the given form.
  * If the chunk does not exist and the form is member of a list with shared
  * properties, this function will recursively lookup the chunk from the
  * shared list properties.
  *
  * @param form An instance of a form chunk
  * @param chunkId An arbitrary chunk ID
  * @return The chunk with the given chunk ID, or NULL if the chunk can't be found
  *}
  function  IFF_getChunkFromForm(const form: PIFF_Form; const chunkId: PIFF_ID): PIFF_Chunk;

  {**
  * Retrieves all the chunks with the given chunk ID from the given form. The resulting array must be freed by using free().
  *
  * @param form An instance of a form chunk
  * @param chunkId An arbitrary chunk ID
  * @param chunksLength A pointer to a variable in which the length of the array is stored
  * @return An array with pointers to the chunks with the requested chunk ID, or NULL if there can't be any chunk found
  *}
  function IFF_getChunksFromForm(const form: PIFF_Form; const chunkId: PIFF_ID; chunksLength: pcuint): PPIFF_Chunk;



//////////////////////////////////////////////////////////////////////////////
//        cat.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Creates a new concatentation chunk instance with the given contents type.
  * The resulting chunk must be freed by using IFF_free().
  *
  * @param contentsType Contents type hinting what the contents of the CAT is.
  * @return CAT chunk or NULL, if the memory for the struct can't be allocated
  *}
  function  IFF_createCAT(const contentsType: PIFF_ID): PIFF_CAT;

  {**
  * Adds a chunk to the body of the given CAT. This function also increments the
  * chunk size and chunk length counter.
  *
  * @param cat An instance of a CAT struct
  * @param chunk A FORM, CAT or LIST chunk
  *}
  procedure IFF_addToCAT(cat: PIFF_CAT; chunk: PIFF_Chunk);

  {**
  * Reads a concatenation chunk and its sub chunks from a file. The resulting chunk must be
  * freed by using IFF_free().
  *
  * @param file File descriptor of the file
  * @param chunkSize Size of the chunk data
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return The concation struct derived from the file, or NULL if an error has occured
  *}
  function  IFF_readCAT(filehandle: THandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_CAT;

  {**
  * Writes a concatenation chunk and its sub chunks to a file.
  *
  * @param file File descriptor of the file
  * @param cat An instance of a concatenation chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the CAT has been successfully written, else FALSE
  *}
  function  IFF_writeCAT(filehandle: THandle; const cat: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Checks a sub chunk in a CAT for its validity.
  *
  * @param group An instance of a concatenation chunk
  * @param subChunk A sub chunk member of this concatenation chunk
  * @return TRUE if the sub chunk is valid, else FALSE
  *}
  function  IFF_checkCATSubChunk(const group: PIFF_Group; const subChunk: PIFF_Chunk): cint;

  {**
  * Checks whether the concatenation chunk and its sub chunks conform to the IFF specification.
  *
  * @param cat An instance of a concatenation chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the CAT is valid, else FALSE.
  *}
  function  IFF_checkCAT(const cat: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recursively frees the memory of the sub chunks of the given concatenation chunk.
  *
  * @param cat An instance of a concatenation chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_freeCAT(cat: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Displays a textual representation of the concatenation chunk and its sub chunks on the standard output.
  *
  * @param cat An instance of a concatenation chunk
  * @param indentLevel Indent level of the textual representation
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printCAT(const cat: PIFF_CAT; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether the given concatenations' contents is equal to each other.
  * 
  * @param cat1 Concatenation to compare
  * @param cat2 Concatenation to compare
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given concatenations are equal, else FALSE
  *}
  function  IFF_compareCAT(const cat1: PIFF_CAT; const cat2: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint): csint;

  {**
  * Returns an array of form structs of the given formType, which are recursively retrieved from the given CAT.
  *
  * @param cat An instance of a concatenation chunk
  * @param formType A 4 character form type ID
  * @param formsLength Returns the length of the resulting array
  * @return An array of form structs
  *}
  function  IFF_searchFormsInCAT(cat: PIFF_CAT; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;

  {/**
  * Recalculates the chunk size of the given concatentation chunk.
  *
  * @param cat An instance of a concatenation chunk
  *}
  procedure IFF_updateCATChunkSizes(cat: PIFF_CAT);



//////////////////////////////////////////////////////////////////////////////
//        id.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Creates a 4 character ID from a string.
  *
  * @param id A 4 character IFF id
  * @param idString String containing a 4 character ID
  *}
  procedure IFF_createId(var id: TIFF_ID; const idString: TIFF_ID);
  procedure IFF_createId(var id: TIFF_ID; const idString: PIFF_ID);

  {**
  * Compares two IFF ids
  *
  * @param id1 An IFF ID to compare
  * @param id2 An IFF ID to compare
  * @return 0 if the IDs are equal, a value lower than 0 if id1 is lower than id2, a value higher than 1 if id1 is higher than id2
  *}
  function  IFF_compareId(const id1: TIFF_ID; const id2: PIFF_ID): cint;

  {**
  * Reads an IFF id from a file
  *
  * @param file File descriptor of the file
  * @param id A 4 character IFF id
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the ID is succesfully read, else FALSE
  *}
  function  IFF_readId(filehandle: THandle; Out id: TIFF_ID; const chunkId: TIFF_ID; const attributeName: PIFF_ID): cint;

  {**
  * Writes an IFF id to a file
  *
  * @param file File descriptor of the file
  * @param id A 4 character IFF id
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the ID is succesfully written, else FALSE
  *}
  function  IFF_writeId(filehandle: THandle; const id: TIFF_ID; const chunkId: TIFF_ID; const attributeName: PIFF_ID): cint;

  {**
  * Checks whether an IFF id is valid
  *
  * @param id A 4 character IFF id
  * @return TRUE if the IFF id is valid, else FALSE
  *}
  function  IFF_checkId(const id: PIFF_ID): cint;
  {
    FPC NOTE:
    Because c uses PChar and depends on the automatic dereferencing of the id
    parameter, we chose to use another variant for FPC. Unfortunately that
    also means the need of an overloaded function.
    NOTE: that switching the placements of these declarations will cause havoc.
  }
  function  IFF_checkId(const id: TIFF_ID): cint; overload;

  {**
  * Prints an IFF id
  *
  * @param id A 4 character IFF id
  *}
  procedure IFF_printId(const id: TIFF_ID);



//////////////////////////////////////////////////////////////////////////////
//        io.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Reads an unsigned byte from a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully read, else FALSE
  *}
  function  IFF_readUByte(filehandle: THandle; value: PIFF_UByte; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Writes an unsigned byte to a file.
  *
  * @param file File descriptor of the file
  * @param value Value written to the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully written, else FALSE
  *}
  function  IFF_writeUByte(filehandle: THandle; const value: TIFF_UByte; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Reads an unsigned word from a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully read, else FALSE
  *}
  function  IFF_readUWord(filehandle: THandle; value: PIFF_UWord; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Writes an unsigned word to a file.
  *
  * @param file File descriptor of the file
  * @param value Value written to the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully written, else FALSE
  *}
  function  IFF_writeUWord(filehandle: THandle; const value: TIFF_UWord; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Reads a signed word from a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully read, else FALSE
  *}
  function  IFF_readWord(filehandle: THandle; value: PIFF_Word; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Writes a signed word to a file.
  *
  * @param file File descriptor of the file
  * @param value Value written to the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully written, else FALSE
  *}
  function  IFF_writeWord(filehandle: THandle; const value: TIFF_Word; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Reads an unsigned long from a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully read, else FALSE
  *}
  function  IFF_readULong(filehandle: THandle; value: PIFF_ULong; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Writes an unsigned long to a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully written, else FALSE
  *}
  function  IFF_writeULong(filehandle: THandle; const value: TIFF_ULong; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Reads a signed long from a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully read, else FALSE
  *}
  function  IFF_readLong(filehandle: THandle; value: PIFF_Long; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Writes a signed long to a file.
  *
  * @param file File descriptor of the file
  * @param value Value read from the file
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @param attributeName The name of the attribute that is examined (used for error reporting)
  * @return TRUE if the value has been successfully written, else FALSE
  *}
  function  IFF_writeLong(filehandle: THandle; const value: TIFF_Long; const chunkId: TIFF_ID; const attributeName: PChar): cint;

  {**
  * Reads a padding byte from a chunk with an odd size.
  *
  * @param file File descriptor of the file
  * @param chunkSize Size of the chunk in bytes
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @return TRUE if the byte has been successfully read, else FALSE
  *}
  function  IFF_readPaddingByte(filehandle: THandle; const chunkSize: TIFF_Long; const chunkId: TIFF_ID): cint;

  {**
  * Writes a padding byte to a chunk with an odd size.
  *
  * @param file File descriptor of the file
  * @param chunkSize Size of the chunk in bytes
  * @param chunkId A 4 character chunk id in which the operation takes place (used for error reporting)
  * @return TRUE if the byte has been successfully written, else FALSE
  *}
  function  IFF_writePaddingByte(filehandle: THandle; const chunkSize: TIFF_Long; const chunkId: TIFF_ID): cint;



//////////////////////////////////////////////////////////////////////////////
//        prop.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Creates a new PROP chunk instance with the given form type.
  * The resulting chunk must be freed by using IFF_free().
  *
  * @param formType Form type describing the purpose of the sub chunks.
  * @return FORM chunk or NULL, if the memory for the struct can't be allocated
  *}
  function  IFF_createProp(const formType: PIFF_ID): PIFF_Prop;

  {**
  * Adds a chunk to the body of the given PROP. This function also increments the
  * chunk size and chunk length counter.
  *
  * @param prop An instance of a PROP chunk
  * @param chunk A data chunk
  *}
  procedure IFF_addToProp(prop: PIFF_Prop; chunk: PIFF_Chunk);

  {**
  * Reads a PROP chunk and its sub chunks from a file. The resulting chunk must be
  * freed by using IFF_free().
  *
  * @param file File descriptor of the file
  * @param chunkSize Size of the chunk data
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return The PROP struct derived from the file, or NULL if an error has occured
  *}
  function  IFF_readProp(filehandle: Thandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Prop;

  {**
  * Writes a PROP chunk and its sub chunks to a file.
  *
  * @param file File descriptor of the file
  * @param prop An instance of a PROP chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the PROP has been successfully written, else FALSE
  *}
  function  IFF_writeProp(filehandle: THandle; const prop: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Checks whether the PROP chunk and its sub chunks conform to the IFF specification.
  *
  * @param prop An instance of a PROP chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the PROP is valid, else FALSE.
  *}
  function  IFF_checkProp(const prop: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recursively frees the memory of the sub chunks of the given PROP chunk.
  *
  * @param prop An instance of a PROP chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_freeProp(prop: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Displays a textual representation of the PROP chunk and its sub chunks on the standard output.
  *
  * @param prop An instance of a PROP chunk
  * @param indentLevel Indent level of the textual representation
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printProp(const prop: PIFF_Prop; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether the given PROP chunks' contents is equal to each other.
  *
  * @param prop1 PROP chunk to compare
  * @param prop2 PROP chunk to compare
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given forms are equal, else FALSE
  *}
  function  IFF_compareProp(const prop1: PIFF_Prop; const prop2: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recalculates the chunk size of the given PROP chunk.
  *
  * @param prop An instance of a PROP chunk
  *}
  procedure IFF_updatePropChunkSizes(prop: PIFF_Prop);

  {**
  * Retrieves the chunk with the given chunk ID from the given PROP chunk. 
  *
  * @param prop An instance of a PROP chunk
  * @param chunkId An arbitrary chunk ID
  * @return The chunk with the given chunk ID, or NULL if the chunk can't be found
  *}
  function  IFF_getChunkFromProp(const prop: PIFF_Prop; const chunkId: PIFF_ID): PIFF_Chunk;



//////////////////////////////////////////////////////////////////////////////
//        list.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Creates a new list chunk instance with the given contents type.
  * The resulting chunk must be freed by using IFF_free().
  *
  * @param contentsType Contents type hinting what the contents of the list is.
  * @return A list chunk or NULL, if the memory for the struct can't be allocated
  *}
  function  IFF_createList(const contentsType: PIFF_ID): PIFF_List;

  {**
  * Adds a PROP chunk to the body of the given list. This function also increments the
  * chunk size and PROP length counter.
  *
  * @param list An instance of a list struct
  * @param prop A PROP chunk
  *}
  procedure IFF_addPropToList(list: PIFF_List; prop: PIFF_Prop);

  {**
  * Adds a chunk to the body of the given list. This function also increments the
  * chunk size and chunk length counter.
  *
  * @param list An instance of a list struct
  * @param chunk A FORM, CAT or LIST chunk
  *}
  procedure IFF_addToList(list: PIFF_List; chunk: PIFF_Chunk);

  {**
  * Reads a list chunk and its sub chunks from a file. The resulting chunk must be
  * freed by using IFF_free().
  *
  * @param file File descriptor of the file
  * @param chunkSize Size of the chunk data
  * @param extension Extension array which specifies how application file format chunks can be handled
  * @param extensionLength Length of the extension array
  * @return The list struct derived from the file, or NULL if an error has occured
  *}
  function  IFF_readList(filehandle: Thandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_List;

  {**
  * Writes a list chunk and its sub chunks to a file.
  *
  * @param file File descriptor of the file
  * @param list An instance of a list chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the list has been successfully written, else FALSE
  *}
  function  IFF_writeList(filehandle: Thandle; const list: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Checks whether the list chunk and its sub chunks conform to the IFF specification.
  *
  * @param list An instance of a list chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the list is valid, else FALSE.
  *}
  function  IFF_checkList(const list: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Recursively frees the memory of the sub chunks and PROP chunks of the given list chunk.
  *
  * @param list An instance of a list chunk
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_freeList(list: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Displays a textual representation of the list chunk and its sub chunks on the standard output.
  *
  * @param list An instance of a list chunk
  * @param indentLevel Indent level of the textual representation
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  *}
  procedure IFF_printList(const list: PIFF_List; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);

  {**
  * Checks whether the given lists' contents is equal to each other.
  *
  * @param list1 List to compare
  * @param list2 List to compare
  * @param extension Extension array which specifies how application file format chunks should be handled
  * @param extensionLength Length of the extension array
  * @return TRUE if the given concatenations are equal, else FALSE
  *}
  function  IFF_compareList(const list1: PIFF_List; const list2: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint): cint;

  {**
  * Returns an array of form structs of the given formType, which are recursively retrieved from the given list.
  *
  * @param list An instance of a list chunk
  * @param formType A 4 character form type ID
  * @param formsLength Returns the length of the resulting array
  * @return An array of form structs
  *}
  function  IFF_searchFormsInList(list: PIFF_List; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;

  {**
  * Recalculates the chunk size of the given list chunk.
  *
  * @param list An instance of a list chunk
  *}
  procedure IFF_updateListChunkSizes(list: PIFF_List);

  {**
  * Retrieves a PROP chunk with the given form type from a list.
  *
  * @param list An instance of a list chunk
  * @param formType Form type describing the purpose of the sub chunks.
  * @return The requested PROP chunk, or NULL if the PROP chunk does not exists.
  *}
  function  IFF_getPropFromList(const list: PIFF_List; const formType: PIFF_ID): PIFF_Prop;



//////////////////////////////////////////////////////////////////////////////
//        rawchunk.h
//////////////////////////////////////////////////////////////////////////////



  {**
  * Creates a raw chunk with the given chunk ID. The resulting chunk must be freed using IFF_free().
  * 
  * @param chunkId A 4 character id
  * @return A raw chunk with the given chunk Id, or NULL if the memory can't be allocated
  *}
  function  IFF_createRawChunk(const chunkId: PIFF_ID): PIFF_RawChunk;

  {**
  * Attaches chunk data to a given chunk. It also increments the chunk size.
  *
  * @param rawChunk A raw chunk
  * @param chunkData An array of bytes
  * @param chunkSize Length of the bytes array.
  *}
  procedure IFF_setRawChunkData(rawChunk: PIFF_RawChunk; chunkData: PIFF_UByte; chunkSize: TIFF_Long );

  {**
  * Copies the given string into the data of the chunk. Additionally, it makes
  * the chunk size equal to the given string.
  *
  * @param rawChunk A raw chunk
  * @param text Text to store in the body
  *}
  procedure IFF_setTextData(rawChunk: PIFF_RawChunk; const txt: PChar);

  {**
  * Reads a raw chunk with the given chunk id and chunk size from a file. The resulting chunk must be freed using IFF_free().
  *
  * @param file File descriptor of the file
  * @param chunkId A 4 character chunk id
  * @param chunkSize Size of the chunk data
  * @return The raw chunk struct derived from the file, or NULL if an error has occured
  *}
  function  IFF_readRawChunk(filehandle: THandle; const chunkId: PIFF_ID; const chunkSize: TIFF_Long): PIFF_RawChunk;

  {**
  * Writes the given raw chunk to a file descriptor.
  *
  * @param file File descriptor of the file
  * @param rawChunk A raw chunk instance
  * @return TRUE if the chunk has been successfully written, else FALSE
  *}
  function  IFF_writeRawChunk(filehandle: THandle; const rawChunk: PIFF_RawChunk): cint;

  {**
  * Frees the raw chunk data of the given raw chunk.
  *
  * @param rawChunk A raw chunk instance
  *}
  procedure IFF_freeRawChunk(rawChunk: PIFF_RawChunk);

  {**
  * Prints the data of the raw chunk as text
  *
  * @param rawChunk A raw chunk instance
  * @param indentLevel Indent level of the textual representation
  *}
  procedure IFF_printText(const rawChunk: PIFF_RawChunk; const indentLevel: cuint);

  {**
  * Prints the data of the raw chunk as numeric values
  *
  * @param rawChunk A raw chunk instance
  * @param indentLevel Indent level of the textual representation
  *}
  procedure IFF_printRaw(const rawChunk: PIFF_RawChunk; const indentLevel: cuint);

  {**
  * Displays a textual representation of the raw chunk data on the standard output.
  *
  * @param rawChunk A raw chunk instance
  * @param indentLevel Indent level of the textual representation
  *}
  procedure IFF_printRawChunk(const rawChunk: PIFF_RawChunk; indentLevel: cuint);

  {**
  * Checks whether two given raw chunks are equal.
  *
  * @param rawChunk1 Raw chunk to compare
  * @param rawChunk2 Raw chunk to compare
  * @return TRUE if the raw chunks are equal, else FALSE
  *}
  function  IFF_compareRawChunk(const rawChunk1: PIFF_RawChunk; const rawChunk2: PIFF_RawChunk): cint;



implementation


uses
  SysUtils, Strings, CHelpers;



// ###########################################################################
// ###
// ###  some temp helper function for debugging purposes
// ###
// ###########################################################################



function HexedID(idPChar: PChar): String;
Var
  P : PChar;
begin
  If not assigned(idPChar) then exit('<nil>');

  Result := '';
  P := idPChar;

  while (P^ <> #0) and (length(Result) < 4*4) do
  begin
    Result := Result + '$' + IntToHex(Byte(P^), 2) + ' ';
    inc(P);
  end;
  Result := Result + '.. .. ..';
end;


function HexedID(pid: PIFF_ID): String;
Var
  P : PChar;
begin
  If not assigned(pid) then exit('<nil>');

  Result := '';
  P := PChar(pid);
  
  while (P^ <> #0) and (length(Result) < 4*4) do
  begin
    Result := Result + '$' + IntToHex(Byte(P^), 2) + ' ';
    inc(P);
  end;
  Result := Result + '.. .. ..';
end;


function HexedID2(idPChar: PChar; size: longint): String;
Var
  P : PChar;
  S1, S2: String;
  i : LongInt;
begin
  If not assigned(idPChar) then exit('<nil>');
  If (size = 0) then exit('<empty>');

  Result := ''; S1 := ''; S2 := '';
  P := idPChar;
  For i := 0 to Pred(Size) do
  begin
    S1 := S1 + '$' + IntToHex(Byte(P^), 2) + ' ';
    If (Length(S2) < 4) then S2 := S2 + P^;
    inc(P);
  end;
  Result := S1 + ' ( ' + S2 + ')';
end;


function HexedID2(pid: PIFF_ID; size: longint): String;
Var
  P : PChar;
  S1, S2: String;
  i : LongInt;
begin
  If not assigned(pid) then exit('<nil>');
  If (size = 0) then exit('<empty>');

  Result := ''; S1 := ''; S2 := '';
  P := PChar(pid);
  For i := 0 to Pred(Size) do
  begin
    S1 := S1 + '$' + IntToHex(Byte(P^), 2) + ' ';
    If (Length(S2) < 4) then S2 := S2 + P^;
    inc(P);
  end;
  Result := S1 + ' ( ' + S2 + ')';
end;





// ###########################################################################
// ###
// ###      function implementations
// ###
// ###########################################################################





//////////////////////////////////////////////////////////////////////////////
//        ifftypes.c
//////////////////////////////////////////////////////////////////////////////



// there's no ifftypes.c



//////////////////////////////////////////////////////////////////////////////
//        error.c
//////////////////////////////////////////////////////////////////////////////



//var
//  IFF_errorCallback: Procedure(const char *formatString, va_list ap);

//  void IFF_errorCallbackStderr(const char *formatString, va_list ap);

Type
  TErrorCallbackFunc = Procedure(const S: PChar);


// void (*IFF_errorCallback) (const char *formatString, va_list ap) = &IFF_errorCallbackStderr;

procedure IFF_errorCallbackStderr(const formatString : PChar);
begin
  //Write(StdErr, formatString);
  //    vfprintf(stderr, formatString, ap);
  Write(formatString);
end;



Var
  IFF_errorCallback : TErrorCallbackFunc = @IFF_errorCallbackStderr;



procedure IFF_error(const formatString: PChar);
begin
  IFF_errorCallback(formatString);
end;


procedure IFF_error(const formatString: PChar; const Arguments: Array of const);
begin
  IFF_Error(PChar(Format(formatString, Arguments)));
end;


procedure IFF_errorId(const id: TIFF_ID);
var
  i: cuint;
begin
  for i := 0 to Pred(IFF_ID_SIZE) do
    IFF_error('%s', [id[i]]);
end;


procedure IFF_readError(const chunkId: TIFF_ID; const attributeName: PChar);
begin
  IFF_error('Error reading "');
  IFF_errorId(chunkId);
  IFF_error('".%s' + LineEnding, [attributeName]);
end;


procedure IFF_writeError(const chunkId: TIFF_ID; const attributeName: PChar);
begin
  IFF_error('Error writing "');
  IFF_errorId(chunkId);
  IFF_error('".%s' + LineEnding, [attributeName]);
end;



//////////////////////////////////////////////////////////////////////////////
//        iff.c
//////////////////////////////////////////////////////////////////////////////



function  IFF_readFd(filehandle: THandle; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Chunk;
var
  chunk : PIFF_Chunk;
  byt   : Byte;
begin

  //* Read the chunk */
  chunk := IFF_readChunk(filehandle, nil, extension, extensionLength);

  if (chunk = nil) then
  begin
    IFF_error('ERROR: cannot open main chunk!' + LineEnding);
    exit(nil);
  end;

  //* We should have reached the EOF now */

  if (FileRead(filehandle, byt, SizeOf(byt)) = SizeOf(byt))
    then IFF_error('WARNING: Trailing IFF contents found: %d!' + LineEnding, [byt]);

  //* Return the parsed main chunk */
  exit(chunk);
end;


function  IFF_read(const filename: PChar; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Chunk;
var
  chunk      : PIFF_Chunk;
  filehandle : THandle;
begin
  filehandle := FileOpen(filename, fmOpenRead);

  //* Open the IFF file */
  if (filehandle = feInvalidHandle) then
  begin
    IFF_error('ERROR: cannot open file: %s', [filename]);
    exit(nil);
  end;

  //* Parse the main chunk */
  chunk := IFF_readFd(filehandle, extension, extensionLength);

  //* Close the file */
  FileClose(filehandle);

  //* Return the chunk */
  result := chunk;
end;


function  IFF_writeFd(filehandle: THandle; const chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  result := IFF_writeChunk(filehandle, chunk, nil, extension, extensionLength);
end;


function  IFF_write(const filename: PChar; const chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  status        : cint;
  filehandle    : THandle;
begin
//  filehandle := FileOpen(filename, fmOpenWrite);
  filehandle := FileCreate(filename);

  if (filehandle = feInvalidHandle) then
  begin
    IFF_error('ERROR: cannot open file: %s' + LineEnding, [filename]);
    exit(_FALSE_);
  end;

  status := IFF_writeFd(filehandle, chunk, extension, extensionLength);
  FileClose(filehandle);
  result := status;
end;


procedure IFF_free(chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_freeChunk(chunk, nil, extension, extensionLength);
end;


function  IFF_check(const chunk: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  //* The main chunk must be of ID: FORM, CAT or LIST */
  if 
  (
    ( IFF_compareId(chunk^.chunkId, 'FORM') <> 0 ) and
    ( IFF_compareId(chunk^.chunkId, 'CAT ') <> 0 ) and
    ( IFF_compareId(chunk^.chunkId, 'LIST') <> 0 )
  ) then
  begin
    IFF_error('Not a valid IFF-85 file: First bytes should start with either: "FORM", "CAT " or "LIST"' + LineEnding);
    exit(_FALSE_);
  end
  else
  begin
    exit(IFF_checkChunk(chunk, nil, extension, extensionLength));
  end;
end;


procedure IFF_print(const chunk: PIFF_Chunk; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_printChunk(chunk, indentLevel, nil, extension, extensionLength);
end;


function  IFF_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  result := IFF_compareChunk(chunk1, chunk2, nil, extension, extensionLength);
end;



//////////////////////////////////////////////////////////////////////////////
//        util.c
//////////////////////////////////////////////////////////////////////////////



procedure IFF_printIndent(filehandle: THandle; indentlevel: cint; const formatString: PChar);
var
  i: Integer;
begin
  for i:= 0 to Pred(indentLevel)
//    do Write(filehandle, '  ');
    do Write('  ');

//  Write(filehandle, formatString);
  Write(formatString);
end;


procedure IFF_printIndent(filehandle: THandle; indentlevel: cint; const formatString: PChar; const arguments: array of const);
begin
  IFF_printIndent(filehandle, indentlevel, PChar(Format(formatString, arguments)));
end;



//////////////////////////////////////////////////////////////////////////////
//        chunk.c
//////////////////////////////////////////////////////////////////////////////



function  IFF_allocateChunk(const chunkId: PIFF_ID; const chunkSize: csize_t): PIFF_Chunk;
var
  chunk : PIFF_Chunk;
begin
  chunk := PIFF_Chunk(AllocMem(chunkSize));

  chunk^.parent := nil;
  IFF_createId(chunk^.chunkId, chunkId);
  chunk^.chunkSize := 0;

  result := chunk;
end;


function  IFF_readChunk(filehandle: THandle; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Chunk;
var
  chunkId   : TIFF_ID;
  chunkSize : TIFF_Long;
var
  formExtension : PIFF_FormExtension;
begin
  //* Read chunk id */
  if notValid(IFF_readId(filehandle, chunkId, '', @chunkId))
  then exit(nil);

  //* Read chunk size */
  if notValid(IFF_readLong(filehandle, @chunkSize, chunkId, 'chunkSize'))
  then exit(nil);

  //* Read remaining bytes (procedure depends on chunk id type) */
  if (IFF_compareId(chunkId, 'FORM') = 0)
  then exit(PIFF_Chunk(IFF_readForm(filehandle, chunkSize, extension, extensionLength)))
  else if (IFF_compareId(chunkId, 'CAT ') = 0)
  then exit(PIFF_Chunk(IFF_readCAT(filehandle, chunkSize, extension, extensionLength)))
  else if (IFF_compareId(chunkId, 'LIST') = 0)
  then exit(PIFF_Chunk(IFF_readList(filehandle, chunkSize, extension, extensionLength)))
  else if (IFF_compareId(chunkId, 'PROP') = 0)
  then exit(PIFF_Chunk(IFF_readProp(filehandle, chunkSize, extension, extensionLength)))
  else
  begin
    formExtension := IFF_findFormExtension(formType, @chunkId, extension, extensionLength);

    if (formExtension = nil)
    then exit(PIFF_Chunk(IFF_readRawChunk(filehandle, @chunkId, chunkSize)))
    else exit (formExtension^.readChunk(filehandle, chunkSize));
  end;
end;


function  IFF_writeChunk(filehandle: THandle; const chunk: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  formExtension : PIFF_FormExtension;
begin
  if notValid(IFF_writeId(filehandle, chunk^.chunkId, chunk^.chunkId, 'chunkId'))
  then exit(_FALSE_);

  if notValid(IFF_writeLong(filehandle, chunk^.chunkSize, chunk^.chunkId, 'chunkSize'))
  then exit(_FALSE_);

  if (IFF_compareId(chunk^.chunkId, 'FORM') = 0) then
  begin
    if notValid(IFF_writeForm(filehandle, PIFF_Form(chunk), extension, extensionLength))
    then exit(_FALSE_);
  end
  else if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0) then
  begin
    if notValid(IFF_writeCAT(filehandle, PIFF_CAT(chunk), extension, extensionLength))
    then exit(_FALSE_);
  end
  else if (IFF_compareId(chunk^.chunkId, 'LIST') = 0) then
  begin
    if notValid(IFF_writeList(filehandle, PIFF_List(chunk), extension, extensionLength))
    then exit(_FALSE_);
  end
  else if (IFF_compareId(chunk^.chunkId, 'PROP') = 0) then
  begin
    if notValid(IFF_writeProp(filehandle, PIFF_Prop(chunk), extension, extensionLength))
    then exit(_FALSE_);
  end
  else
  begin
    formExtension := IFF_findFormExtension(formType, @chunk^.chunkId, extension, extensionLength);

    if (formExtension = nil)
    then exit ( IFF_writeRawChunk ( filehandle, PIFF_RawChunk(chunk) ) )
    else exit(formExtension^.writeChunk(filehandle, chunk));
  end;

  result := (_TRUE_);
end;


function  IFF_checkChunk(const chunk: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  formExtension : PIFF_FormExtension;
begin
  if notValid(IFF_checkId(chunk^.chunkId))
  then exit(_FALSE_)
  else
  begin
    if (IFF_compareId(chunk^.chunkId, 'FORM') = 0)
    then exit( IFF_checkForm(PIFF_Form(chunk), extension, extensionLength) )
    else if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0)
    then exit( IFF_checkCAT(PIFF_CAT(chunk), extension, extensionLength) )
    else if (IFF_compareId(chunk^.chunkId, 'LIST') = 0)
    then exit( IFF_checkList( PIFF_List(chunk), extension, extensionLength) )
    else if (IFF_compareId(chunk^.chunkId, 'PROP') = 0)
    then exit( IFF_checkProp(PIFF_Prop(chunk), extension, extensionLength) )
    else
    begin
      formExtension := IFF_findFormExtension(formType, @chunk^.chunkId, extension, extensionLength);

      if (formExtension = nil)
      then exit(_TRUE_)
      else
        exit(formExtension^.checkChunk(chunk));
    end;
  end;
end;


procedure IFF_freeChunk(chunk: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength : cuint);
var
  formExtension : PIFF_FormExtension;
begin
  //* Free nested sub chunks */
  if (IFF_compareId(chunk^.chunkId, 'FORM') = 0)
  then IFF_freeForm(PIFF_Form(chunk), extension, extensionLength)
  else if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0)
  then IFF_freeCAT(PIFF_CAT(chunk), extension, extensionLength)
  else if (IFF_compareId(chunk^.chunkId, 'LIST') = 0)
  then IFF_freeList(PIFF_List(chunk), extension, extensionLength)
  else if (IFF_compareId(chunk^.chunkId, 'PROP') = 0)
  then IFF_freeProp(PIFF_Prop(chunk), extension, extensionLength)
  else
  begin
    formExtension := IFF_findFormExtension(formType, @chunk^.chunkId, extension, extensionLength);

    if (formExtension = nil)
    then IFF_freeRawChunk(PIFF_RawChunk(chunk))
    else
      formExtension^.freeChunk(chunk);
  end;

  //* Free the chunk itself */
  FreeMem(chunk);
end;


procedure IFF_printChunk(const chunk: PIFF_Chunk; const indentLevel: cuint; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);
var
  formExtension : PIFF_FormExtension;
begin
  IFF_printIndent(GetStdOutHandle, indentLevel, '"');
  IFF_printId(chunk^.chunkId);
  WriteLn('" = {');

  IFF_printIndent(GetStdOutHandle, indentLevel + 1, 'chunkSize = %d;' + LineEnding, [chunk^.chunkSize]);

  if (IFF_compareId(chunk^.chunkId, 'FORM') = 0)
  then IFF_printForm(PIFF_Form(chunk), indentLevel + 1, extension, extensionLength)
  else if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0)
  then IFF_printCAT(PIFF_CAT(chunk), indentLevel + 1, extension, extensionLength)
  else if (IFF_compareId(chunk^.chunkId, 'LIST') = 0)
  then IFF_printList(PIFF_List(chunk), indentLevel + 1, extension, extensionLength)
  else if (IFF_compareId(chunk^.chunkId, 'PROP') = 0)
  then IFF_printProp(PIFF_Prop(chunk), indentLevel + 1, extension, extensionLength)
  else
  begin
    formExtension := IFF_findFormExtension(formType, @chunk^.chunkId, extension, extensionLength);

    if (formExtension = nil)
    then IFF_printRawChunk(PIFF_RawChunk(chunk), indentLevel + 1)
    else
      formExtension^.printChunk(chunk, indentLevel + 1);
  end;

  IFF_printIndent(GetStdOutHandle, indentLevel, '}' + LineEnding + LineEnding);
end;


function  IFF_compareChunk(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  formExtension : PIFF_FormExtension;
begin
  if (IFF_compareId(chunk1^.chunkId, @chunk2^.chunkId) = 0) then
  begin
    if (chunk1^.chunkSize = chunk2^.chunkSize) then
    begin
      if (IFF_compareId(chunk1^.chunkId, 'FORM') = 0)
      then exit( IFF_compareForm(PIFF_Form(chunk1), PIFF_Form(chunk2), extension, extensionLength) )
      else if (IFF_compareId(chunk1^.chunkId, 'CAT ') = 0)
      then exit( IFF_compareCAT(PIFF_CAT(chunk1), PIFF_CAT(chunk2), extension, extensionLength) )
      else if (IFF_compareId(chunk1^.chunkId, 'LIST') = 0)
      then exit( IFF_compareList(PIFF_List(chunk1), PIFF_List(chunk2), extension, extensionLength) )
      else if (IFF_compareId(chunk1^.chunkId, 'PROP') = 0)
      then exit( IFF_compareProp(PIFF_Prop(chunk1), PIFF_Prop(chunk2), extension, extensionLength) )
      else
      begin
        formExtension := IFF_findFormExtension(formType, @chunk1^.chunkId, extension, extensionLength);

        if (formExtension = nil)
        then exit( IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2)) )
        else
          exit( formExtension^.compareChunk(chunk1, chunk2) );
      end;
    end
    else
      exit(_FALSE_);
  end
  else
    exit(_FALSE_);
end;


function  IFF_searchForms(chunk: PIFF_Chunk; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;
begin
  if (IFF_compareId(chunk^.chunkId, 'FORM') = 0)
  then exit( IFF_searchFormsInForm(PIFF_Form(chunk), formType, formsLength) )
  else if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0)
  then exit( IFF_searchFormsInCAT(PIFF_CAT(chunk), formType, formsLength) )
  else if (IFF_compareId(chunk^.chunkId, 'LIST') = 0)
  then exit( IFF_searchFormsInList(PIFF_List(chunk), formType, formsLength) )
  else
  begin
    formsLength^ := 0;
    exit(nil);
  end;
end;


function  IFF_incrementChunkSize(const chunkSize: TIFF_Long; const chunk: PIFF_Chunk): TIFF_Long;
var
  returnValue : TIFF_Long;
begin
  returnValue := chunkSize + IFF_ID_SIZE + sizeof(TIFF_Long) + chunk^.chunkSize;

  //* If the size of the nested chunk size is odd, we have to count the padding byte as well */
  if (chunk^.chunkSize mod 2 <> 0)
  then inc(returnValue);

  result := returnValue;
end;


procedure IFF_updateChunkSizes(chunk: PIFF_Chunk);
begin
  //* Check whether the given chunk is a group chunk and update the sizes */
  if (IFF_compareId(chunk^.chunkId, 'FORM') = 0)
  then IFF_updateFormChunkSizes(PIFF_Form(chunk))
  else if (IFF_compareId(chunk^.chunkId, 'PROP') = 0)
  then IFF_updatePropChunkSizes(PIFF_Prop(chunk))
  else if (IFF_compareId(chunk^.chunkId, 'CAT ') = 0)
  then IFF_updateCATChunkSizes(PIFF_CAT(chunk))
  else if (IFF_compareId(chunk^.chunkId, 'LIST') = 0)
  then IFF_updateListChunkSizes(PIFF_List(chunk));

  //* If the given type has a parent, recursively update these as well */
  if (chunk^.parent <> nil)
  then IFF_updateChunkSizes(PIFF_Chunk(chunk^.parent));
end;



//////////////////////////////////////////////////////////////////////////////
//        extension.c
//////////////////////////////////////////////////////////////////////////////



function  compareExtension(const a: Pointer; const b: Pointer): cint;
var
  l,r: PIFF_Extension;
begin
  l := PIFF_Extension(a);
  r := PIFF_Extension(b);

  result := IFF_compareId(l^.formType^, r^.formType);
end;


function  getFormExtensions(const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint; formExtensionsLength: pcuint): PIFF_FormExtension;
var
  key   : TIFF_Extension;
  res   : PIFF_Extension;
begin    
  key.formType := formType;

  res := bsearch(@key, extension, extensionLength, sizeof(IFF_Extension), @compareExtension);

  if (res = nil) then
  begin
    formExtensionsLength^ := 0;
    exit(nil);
  end
  else
  begin
    formExtensionsLength^ := res^.formExtensionsLength;
    exit(res^.formExtensions);
  end;
end;


function  compareFormExtension(const a: Pointer; const b: Pointer): cint;
var
  l,r: PIFF_FormExtension;
begin
  l := PIFF_FormExtension(a);
  r := PIFF_FormExtension(b);

  result := IFF_compareId(l^.chunkId^, r^.chunkId);
end;


function  getFormExtension(const chunkId: PIFF_ID; const formExtension: PIFF_FormExtension; const formExtensionLength: cuint): PIFF_FormExtension;
var
  key   : TIFF_FormExtension;
begin
  key.chunkId := chunkId;

  result := bsearch(@key, formExtension, formExtensionLength, sizeof(IFF_FormExtension), @compareFormExtension);
end;


function  IFF_findFormExtension(const formType: PIFF_ID; const chunkId: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_FormExtension;
var
  formExtensionsLength  : cuint;
  formExtensions        : PIFF_FormExtension;
  formExtension         : PIFF_FormExtension;
begin
  if (formType = nil)
  then exit(nil)
  else
  begin

    //* Search the given form extensions array */
    formExtensions := getFormExtensions(formType, extension, extensionLength, @formExtensionsLength);

    //* Search for the extension that handles the a chunk with the given chunk id */
    formExtension := getFormExtension(chunkId, formExtensions, formExtensionsLength);

    //* Return the form extension we have found */
    result := formExtension;
  end;
end;



//////////////////////////////////////////////////////////////////////////////
//        group.c
//////////////////////////////////////////////////////////////////////////////



procedure IFF_initGroup(group: PIFF_Group; const groupType: PIFF_ID);
begin
  group^.chunkSize := IFF_ID_SIZE; //* We have the group type */
  IFF_createId(group^.groupType, groupType);
  group^.chunkLength := 0;
  group^.chunk := nil;
end;


function  IFF_createGroup(const chunkId: PIFF_ID; const groupType: PIFF_ID): PIFF_Group;
var
  group : PIFF_Group;
begin
  group := PIFF_Group(IFF_allocateChunk(chunkId, sizeof(TIFF_Group)));

  if (group <> nil)
  then IFF_initGroup(group, groupType);

  result := group;
end;


procedure IFF_addToGroup(group: PIFF_Group; chunk: PIFF_Chunk);
begin
  group^.chunk := PPIFF_Chunk(ReAllocMem(group^.chunk, (group^.chunkLength + 1) * sizeof(PIFF_Chunk)));
  group^.chunk[group^.chunkLength] := chunk;
  inc(group^.chunkLength);
  group^.chunkSize := IFF_incrementChunkSize(group^.chunkSize, chunk);

  chunk^.parent := group;
end;


function  IFF_readGroup(filehandle: THandle; const chunkId: PIFF_ID; const chunkSize: TIFF_Long; const groupTypeName: PIFF_ID; const groupTypeIsFormType: cint; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Group;
var
  groupType : TIFF_ID;
  group     : PIFF_Group;
  formType  : PIFF_ID;      //  formType  : PChar;
var
  chunk     : PIFF_Chunk;
begin

  //* Read group type */
  if notValid(IFF_readId(filehandle, groupType, chunkId^, groupTypeName))
  then exit(nil);

  //* Create new group */
  group := IFF_createGroup(chunkId, @groupType);

  //* Determine form type */
  if (groupTypeIsFormType <> 0)
  then formType := @groupType
  else
    formType := nil;


  //* Keep parsing sub chunks until we have read all bytes */

  while (group^.chunkSize < chunkSize) do
  begin
    //* Read sub chunk */
    chunk := IFF_readChunk(filehandle, formType, extension, extensionLength);

    if (chunk = nil) then
    begin
      IFF_error('Error while reading chunk!' + LineEnding);
      IFF_freeChunk(PIFF_Chunk(group), formType, extension, extensionLength);
      exit(nil);
    end;

    //* Add chunk to the group */
    IFF_addToGroup(group, chunk);
  end;

  {*
   * Set the chunk size to what we have read. This is mandatory according to
   * the IFF specification, because we must respect this even when it's
   * truncated
   *}
  group^.chunkSize := chunkSize;

  //* Return the resulting group */
  result := group;
end;


function  IFF_writeGroupSubChunks(filehandle: THandle; const group: PIFF_Group; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  i: cuint;
begin
  i := 0;
  while (i < group^.chunkLength) do
  begin
    if notValid(IFF_writeChunk(filehandle, group^.chunk[i], formType, extension, extensionLength)) then
    begin
      IFF_error('Error writing chunk!' + LineEnding);
      exit(_FALSE_);
    end;
    inc(i);
  end;

  result := _TRUE_;
end;


function  IFF_writeGroup(filehandle: THandle; const group: PIFF_Group; const formType: PIFF_ID; const groupTypeName: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  if notValid(IFF_writeId(filehandle, group^.groupType, group^.chunkId, groupTypeName))
  then exit(_FALSE_);

  if notValid(IFF_writeGroupSubChunks(filehandle, group, formType, extension, extensionLength))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  IFF_checkGroupChunkSize(const group: PIFF_Group; const chunkSize: TIFF_Long): cint;
begin
  if (chunkSize = group^.chunkSize)
  then exit(_TRUE_)
  else
  begin
    IFF_error('Chunk size mismatch! ');
    IFF_errorId(group^.chunkId);
    IFF_error(' size: %d, while body has: %d' + LineEnding, [group^.chunkSize, chunkSize]);
    exit(_FALSE_);
  end;
end;


function  IFF_checkGroupSubChunks(const group: PIFF_Group; subChunkCheck: TIFF_checkGroupSubChunksFunc; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): TIFF_Long;
var
  i         : cuint;
  chunksize : TIFF_Long = 0;
var
  subChunk  : PIFF_Chunk;
begin
  i := 0;
  while (i < group^.chunkLength) do
  begin
    subChunk := group^.chunk[i];

    if notValid(subChunkCheck(group, subChunk))
    then exit(-1);

    //* Check validity of the sub chunk */
    if notValid(IFF_checkChunk(subChunk, formType, extension, extensionLength))
    then exit(-1);

    chunkSize := IFF_incrementChunkSize(chunkSize, subChunk);
    inc(i);
  end;

  result := chunkSize;
end;


function  IFF_checkGroup(const group: PIFF_Group; groupTypeCheck: TIFF_groupTypeCheckFunc; subChunkCheck: TIFF_subChunkCheckFunc; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  chunkSize : TIFF_Long;
begin
  if notValid(groupTypeCheck(@group^.groupType))
  then exit(_FALSE_);

  chunkSize := IFF_checkGroupSubChunks(group, subChunkCheck, formType, extension, extensionLength);
  if (chunkSize = -1)
  then exit(_FALSE_);

  chunkSize := chunksize + IFF_ID_SIZE;

  if notValid(IFF_checkGroupChunkSize(group, chunkSize))
  then exit(_FALSE_);

  result := _TRUE_;
end;


procedure IFF_freeGroup(group: PIFF_Group; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);
var
  i: cuint;
begin
  i := 0;
  while (i < group^.chunkLength) do
  begin
    IFF_freeChunk(group^.chunk[i], formType, extension, extensionLength);
    inc(i);
  end;

  FreeMem(group^.chunk);
end;


procedure IFF_printGroupType(const groupTypeName: PIFF_ID; const groupType: PIFF_ID; const indentLevel: cuint);
begin
  IFF_printIndent(GetStdoutHandle, indentLevel, '%s = "', [groupTypeName]);
  IFF_printId(groupType^);
  WriteLn('";');
end;


procedure IFF_printGroupSubChunks(const group: PIFF_Group; const indentLevel: cuint; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);
var
  i: cuint;
begin
  IFF_printIndent(GetStdOutHandle, indentLevel, '[' + LineEnding);
  i := 0;
  while (i < group^.chunkLength) do
  begin
    IFF_printChunk( PIFF_Chunk(group^.chunk[i]), indentLevel + 1, formType, extension, extensionLength);
    inc(i);
  end;

  IFF_printIndent(GetStdOutHandle, indentLevel, '];' + LineEnding);
end;


procedure IFF_printGroup(const group: PIFF_Group; const indentLevel: cuint; const formType: PIFF_ID; const groupTypeName: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_printGroupType(groupTypeName, @group^.groupType, indentLevel);
  IFF_printGroupSubChunks(group, indentLevel, formType, extension, extensionLength);
end;


function  IFF_compareGroup(const group1: PIFF_Group; const group2: PIFF_Group; const formType: PIFF_ID; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  i: cuint;
begin
  if ( (IFF_compareId(group1^.groupType, @group2^.groupType) = 0) and  (group1^.chunkLength = group2^.chunkLength) ) then
  begin
    i := 0;
    while (i < group1^.chunkLength) do
    begin
      if notValid(IFF_compareChunk(group1^.chunk[i], group2^.chunk[i], formType, extension, extensionLength))
      then exit(_FALSE_);
      inc(i);
    end;

    Exit(_TRUE_);
  end
  else
    result := _FALSE_;
end;


function  IFF_searchFormsInGroup(group: PIFF_Group; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;
var
  forms         : PPIFF_Form; // = nil;
  i             : cuint;
  resultLength  : cuint;
  res           : PPIFF_Form;
begin
  forms := nil;
  formsLength^ := 0;

  i := 0;
  while (i < group^.chunkLength) do
  begin
    res := IFF_searchForms(group^.chunk[i], formType, @resultLength);

    forms := IFF_mergeFormArray(forms, formsLength, res, resultLength);
    inc(i);
  end;

  result := forms;
end;


procedure IFF_updateGroupChunkSizes(group: PIFF_Group);
var
  i : cuint;
begin
  group^.chunkSize := IFF_ID_SIZE;

  i := 0;
  while (i < group^.chunkLength) do
  begin
    group^.chunkSize := IFF_incrementChunkSize(group^.chunkSize, group^.chunk[i]);
    inc(i);
  end;
end;



//////////////////////////////////////////////////////////////////////////////
//        form.c
//////////////////////////////////////////////////////////////////////////////



Const
  FORM_CHUNKID          = 'FORM';
  FORM_GROUPTYPENAME    = 'formType';


function  IFF_createForm(const formType: PIFF_ID): PIFF_Form;
begin
  result := PIFF_Form(IFF_createGroup(FORM_CHUNKID, formType));
end;


procedure IFF_addToForm(form: PIFF_Form; chunk: PIFF_Chunk);
begin
  IFF_addToGroup(PIFF_Group(form), chunk);
end;


function  IFF_readForm(filehandle: THandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Form;
begin
  result := PIFF_Form(IFF_readGroup(filehandle, FORM_CHUNKID, chunkSize, FORM_GROUPTYPENAME, _TRUE_, extension, extensionLength));
end;


function  IFF_writeForm(filehandle: THandle; const form: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  Result := IFF_writeGroup(filehandle, PIFF_Group(form), @form^.formType, FORM_GROUPTYPENAME, extension, extensionLength);
end;


// TIFF_groupTypeCheckFunc
//  TIFF_groupTypeCheckFunc = function(const groupType: PChar): cint;
//function  IFF_checkFormType(const formType: TIFF_ID): cint;
function  IFF_checkFormType(const formType: PIFF_ID): cint;
var
  i : cuint;
begin
  //* A form type must be a valid ID */
  if notValid(IFF_checkId(formType^))
  then exit(_FALSE_);

  //* A form type is not allowed to have lowercase or puntuaction marks */
  i := 0;
  while (i < IFF_ID_SIZE) do
  begin
    if  ( ( (formType^[i] >= #$61) and (formType^[i] <= #$7a) ) or (formType^[i] = '.') ) then
    begin
      IFF_error('No lowercase characters or punctuation marks allowed in a form type ID!' + LineEnding);
      exit(_FALSE_);
    end;
    inc(i);
  end;

  //* A form ID is not allowed to be equal to a group chunk ID */
  if
  (
    ( IFF_compareId(formType^, 'LIST') = 0 ) or
    ( IFF_compareId(formType^, 'FORM') = 0 ) or
    ( IFF_compareId(formType^, 'PROP') = 0 ) or
    ( IFF_compareId(formType^, 'CAT ') = 0 ) or
    ( IFF_compareId(formType^, 'JJJJ') = 0 ) or
    ( IFF_compareId(formType^, 'LIS1') = 0 ) or
    ( IFF_compareId(formType^, 'LIS2') = 0 ) or
    ( IFF_compareId(formType^, 'LIS3') = 0 ) or
    ( IFF_compareId(formType^, 'LIS4') = 0 ) or
    ( IFF_compareId(formType^, 'LIS5') = 0 ) or
    ( IFF_compareId(formType^, 'LIS6') = 0 ) or
    ( IFF_compareId(formType^, 'LIS7') = 0 ) or
    ( IFF_compareId(formType^, 'LIS8') = 0 ) or
    ( IFF_compareId(formType^, 'LIS9') = 0 ) or
    ( IFF_compareId(formType^, 'FOR1') = 0 ) or
    ( IFF_compareId(formType^, 'FOR1') = 0 ) or
    ( IFF_compareId(formType^, 'FOR2') = 0 ) or
    ( IFF_compareId(formType^, 'FOR3') = 0 ) or
    ( IFF_compareId(formType^, 'FOR4') = 0 ) or
    ( IFF_compareId(formType^, 'FOR5') = 0 ) or
    ( IFF_compareId(formType^, 'FOR6') = 0 ) or
    ( IFF_compareId(formType^, 'FOR7') = 0 ) or
    ( IFF_compareId(formType^, 'FOR8') = 0 ) or
    ( IFF_compareId(formType^, 'FOR9') = 0 ) or
    ( IFF_compareId(formType^, 'CAT1') = 0 ) or
    ( IFF_compareId(formType^, 'CAT2') = 0 ) or
    ( IFF_compareId(formType^, 'CAT3') = 0 ) or
    ( IFF_compareId(formType^, 'CAT4') = 0 ) or
    ( IFF_compareId(formType^, 'CAT5') = 0 ) or
    ( IFF_compareId(formType^, 'CAT6') = 0 ) or
    ( IFF_compareId(formType^, 'CAT7') = 0 ) or
    ( IFF_compareId(formType^, 'CAT8') = 0 ) or
    ( IFF_compareId(formType^, 'CAT9') = 0 )
  ) then
  begin
    IFF_error('Form type: "');
    IFF_errorId(formType^);
    IFF_error('" not allowed!');

    exit(_FALSE_);
  end;

  Result := _TRUE_;
end;


function form_subChunkCheck(const group: PIFF_Group; const subChunk: PIFF_Chunk): cint; 
begin
  if (IFF_compareId(subChunk^.chunkId, 'PROP') = 0) then
  begin
    IFF_error('ERROR: Element with chunk Id: "');
    IFF_errorId(subChunk^.chunkId);
    IFF_error('" not allowed in FORM chunk!' + LineEnding);

    exit(_FALSE_);
  end
  else
    result := _TRUE_;
end;


function  IFF_checkForm(const form: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
//  Result := IFF_checkGroup( PIFF_Group(form), TIFF_groupTypeCheckFunc(@IFF_checkFormType), @form_subChunkCheck, @form^.formType, extension, extensionLength);
  Result := IFF_checkGroup( PIFF_Group(form), @IFF_checkFormType, @form_subChunkCheck, @form^.formType, extension, extensionLength);
end;


procedure IFF_freeForm(form: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_freeGroup( PIFF_Group(form), @form^.formType, extension, extensionLength);
end;


procedure IFF_printForm(const form: PIFF_Form; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_printGroup( PIFF_Group(form), indentLevel, @form^.formType, FORM_GROUPTYPENAME, extension, extensionLength);
end;


function  IFF_compareForm(const form1: PIFF_Form; const form2: PIFF_Form; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  Result := IFF_compareGroup( PIFF_Group(form1), PIFF_Group(form2), @form1^.formType, extension, extensionLength);
end;


function  IFF_mergeFormArray(target: PPIFF_Form; targetLength: pcuint; source: PPIFF_Form; const sourceLength: cuint): PPIFF_Form;
var
  i         : cuint;
  newLength : cuint;
begin
  newLength := targetLength^ + sourceLength;

  target := PPIFF_Form(ReAllocMem(target, newLength * sizeof(PIFF_Form)));

  i := 0;
  while (i < sourceLength) do
  begin
    target[i + targetLength^] := source[i];
    inc(i);
  end;

  targetLength^ := newLength;

  Result := target;
end;


function  IFF_searchFormsInForm(form: PIFF_Form; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;
Var
  forms : PPIFF_Form;
begin
  if (IFF_compareId(form^.formType, formType) = 0) then
  begin

    //* If the given form is what we look for, return it */
    forms := PPIFF_Form(AllocMem(sizeof(PIFF_Form)));
    forms[0] := form;
    formsLength^ := 1;

    exit(forms);
  end
  else 
    Result := IFF_searchFormsInGroup(PIFF_Group(form), formType, formsLength); //* Search into the nested forms in this form */
end;


procedure IFF_updateFormChunkSizes(form: PIFF_Form);
begin
  IFF_updateGroupChunkSizes(PIFF_Group(form));
end;



{**
 * Searches the list in which the given chunk is (indirectly) a member from.
 *
 * @param chunk An arbitrary chunk, which could be (indirectly) a member of a list
 * @return List instance of which the given chunk is (indirectly) a member, or NULL if the chunk is not a member of a list
 *}
function searchList(const chunk: PIFF_Chunk): PIFF_List;
var
  parent    : PIFF_Group;
begin
  parent := chunk^.parent;

  if (parent = nil)
  then exit(nil)
  else
  begin
    if (IFF_compareId(parent^.chunkId, 'LIST') = 0)
    then exit(PIFF_List(parent))
    else
      exit(searchList(PIFF_Chunk(parent)));
  end;
end;


{**
 * Recursively searches for a shared list property with the given chunk ID.
 *
 * @param chunk An arbitrary chunk, which could be (indirectly) a member of a list
 * @param formType A 4 character form id
 * @param chunkId A 4 character chunk id
 * @return The chunk with the given chunk id, or NULL if the chunk can't be found
 *}
//function  searchProperty(const chunk: PIFF_Chunk; const formType: PChar; const chunkId: PIFF_ID): PIFF_Chunk;
function  searchProperty(const chunk: PIFF_Chunk; const formType: PIFF_ID; const chunkId: PIFF_ID): PIFF_Chunk;
var
  list  : PIFF_List;
var
  prop  : PIFF_Prop;
  chunky : PIFF_Chunk;   { FPC NOTE: No two variables with the exact same name }
begin
  list := searchList(chunk);

  if (list = nil)
  then exit(nil) //* If the chunk is not (indirectly) in a list, we have no shared properties at all */
  else
  begin
    //* Try requesting the PROP chunk for the given form type */
    prop := IFF_getPropFromList(list, formType);

    if (prop = nil)
    then exit(searchProperty(PIFF_Chunk(list), formType, chunkId))  //* If we can't find a shared property chunk with the given form type, try searching for a list higher in the hierarchy */
    else
    begin
      //* Try requesting the chunk from the shared property chunk */
      chunky := IFF_getChunkFromProp(prop, chunkId);

      if (chunky = nil)
      then exit(searchProperty(PIFF_Chunk(list), formType, chunkId))    //* If the requested chunk is not in the PROP chunk, try searching for a list higher in the hierarchy */
      else
        Result := chunky;    //* We have found the requested shared property chunk */
    end;
  end;
end;


function  IFF_getDataChunkFromForm(const form: PIFF_Form; const chunkId: PIFF_ID): PIFF_Chunk;
var
  i : cuint;
begin
  i := 0;
  while (i < form^.chunkLength) do
  begin
    if (IFF_compareId(form^.chunk[i]^.chunkId, chunkId) = 0)
      then exit(form^.chunk[i]);
    inc(i);
  end;

  Result := nil;
end;


function  IFF_getChunkFromForm(const form: PIFF_Form; const chunkId: PIFF_ID): PIFF_Chunk;
var
  chunk     : PIFF_Chunk;
begin
  //* Retrieve the chunk with the given id from the given form */
  chunk := IFF_getDataChunkFromForm(form, chunkId);

  //* If the chunk is not in the form, try to find it in a higher located PROP */
  if (chunk = nil)
  then exit(searchProperty(PIFF_Chunk(form), @form^.formType, chunkId))
  else
    result := chunk;
end;


function  IFF_getChunksFromForm(const form: PIFF_Form; const chunkId: PIFF_ID; chunksLength: pcuint): PPIFF_Chunk;
var
  res   : PPIFF_Chunk = nil;
  i     : cuint;
begin
  chunksLength^ := 0;

  i := 0;
  while (i < form^.chunkLength) do
  begin
    if (IFF_compareId(form^.chunk[i]^.chunkId, chunkId) = 0) then
    begin
      res := PPIFF_Chunk(ReAllocMem(res, (chunksLength^ + 1) * sizeof(PIFF_Chunk)));
      res[chunksLength^] := form^.chunk[i];
      chunksLength^ := chunksLength^ + 1;
    end;
    inc(i);
  end;
    
  Result := res;
end;



//////////////////////////////////////////////////////////////////////////////
//        cat.c
//////////////////////////////////////////////////////////////////////////////



const
  CAT_CHUNKID       = 'CAT ';
  CAT_GROUPTYPENAME = 'contentsType';


function  IFF_createCAT(const contentsType: PIFF_ID): PIFF_CAT;
begin
  Result := PIFF_CAT(IFF_createGroup(CAT_CHUNKID, contentsType));
end;


procedure IFF_addToCAT(cat: PIFF_CAT; chunk: PIFF_Chunk);
begin
  IFF_addToGroup(PIFF_Group(cat), chunk);
end;


function  IFF_readCAT(filehandle: THandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_CAT;
begin
  Result := PIFF_CAT(IFF_readGroup(filehandle, CAT_CHUNKID, chunkSize, CAT_GROUPTYPENAME, _FALSE_, extension, extensionLength));
end;


function  IFF_writeCAT(filehandle: THandle; const cat: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  Result := IFF_writeGroup(filehandle, PIFF_Group(cat), nil, CAT_GROUPTYPENAME, extension, extensionLength);
end;


function  IFF_checkCATSubChunk(const group: PIFF_Group; const subChunk: PIFF_Chunk): cint;
var
  cat       : PIFF_Cat;
  form      : PIFF_Form;
  list      : PIFF_List;
  subCat    : PIFF_CAT; 
begin
  cat := PIFF_CAT(group);

  //* A concatenation chunk may only contain other group chunks (except a PROP) */
  if 
  (
    ( IFF_compareId(subChunk^.chunkId, 'FORM') <> 0 ) and
    ( IFF_compareId(subChunk^.chunkId, 'LIST') <> 0 ) and
    ( IFF_compareId(subChunk^.chunkId, 'CAT ') <> 0 ) 
  ) then
  begin
    IFF_error('ERROR: Element with chunk Id: "');
    IFF_errorId(subChunk^.chunkId);
    IFF_error('" not allowed in CAT chunk!' + LineEnding);
    exit(_FALSE_);
  end;

  if (IFF_compareId(cat^.contentsType, 'JJJJ') <> 0) then
  begin
    //* Check whether form type or contents type matches the contents type of the CAT */

    if (IFF_compareId(subChunk^.chunkId, 'FORM') = 0) then
    begin
      form := PIFF_Form(subChunk);

      if (IFF_compareId(form^.formType, @cat^.contentsType) <> 0) then
      begin
        IFF_error('Sub form does not match contentsType of the CAT!' + LineEnding);
        exit(_FALSE_);
      end;
    end
    else if (IFF_compareId(subChunk^.chunkId, 'LIST') = 0) then
    begin
      list := PIFF_List(subChunk);

      if (IFF_compareId(list^.contentsType, @cat^.contentsType) <> 0) then
      begin
        IFF_error('Sub list does not match contentsType of the CAT!' + LineEnding);
        exit(_FALSE_);
      end;
    end
    else if (IFF_compareId(subChunk^.chunkId, 'CAT ') = 0) then
    begin
      subCat := PIFF_CAT(subChunk);

      if (IFF_compareId(subCat^.contentsType, @cat^.contentsType) <> 0) then
      begin
        IFF_error('Sub cat does not match contentsType of the CAT!' + LineEnding);
        exit(_FALSE_);
      end;
    end;
  end;

  Result := _TRUE_;
end;


function  IFF_checkCAT(const cat: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
//  result := IFF_checkGroup(PIFF_Group(cat), TIFF_groupTypeCheckFunc(@IFF_checkId), @IFF_checkCATSubChunk, nil, extension, extensionLength);
  result := IFF_checkGroup(PIFF_Group(cat), @IFF_checkId, @IFF_checkCATSubChunk, nil, extension, extensionLength);
end;


procedure IFF_freeCAT(cat: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_freeGroup(PIFF_Group(cat), nil, extension, extensionLength);
end;


procedure IFF_printCAT(const cat: PIFF_CAT; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_printGroup(PIFF_Group(cat), indentLevel, Nil, CAT_GROUPTYPENAME, extension, extensionLength);
end;


function  IFF_compareCAT(const cat1: PIFF_CAT; const cat2: PIFF_CAT; const extension: PIFF_Extension; const extensionLength: cuint): csint;
begin
  result := IFF_compareGroup(PIFF_Group(cat1), PIFF_Group(cat2), Nil, extension, extensionLength);
end;


function  IFF_searchFormsInCAT(cat: PIFF_CAT; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;
begin
  result := IFF_searchFormsInGroup(PIFF_Group(cat), formType, formsLength);
end;


procedure IFF_updateCATChunkSizes(cat: PIFF_CAT);
begin
  IFF_updateGroupChunkSizes(PIFF_Group(cat));
end;



//////////////////////////////////////////////////////////////////////////////
//        id.c
//////////////////////////////////////////////////////////////////////////////



procedure IFF_createId(var id: TIFF_ID; const idString: PIFF_ID);
var i : integer;
begin
  {$WARNING TODO}
  // strlcopy(id, PChar(idString), IFF_ID_SIZE);
  for i := 0 to Pred(IFF_ID_SIZE)
    do id[i] := idString^[i];
end;


procedure IFF_createId(var id: TIFF_ID; const idString: TIFF_ID);
var i : integer;
begin
  for i := 0 to Pred(IFF_ID_SIZE)
    do id[i] := idString[i];
end;


function  IFF_compareId(const id1: TIFF_ID; const id2: PIFF_ID): cint;
begin
  result := ComparememRange(@id1, id2, IFF_ID_SIZE);
end;


function  IFF_readId(filehandle: THandle; Out id: TIFF_ID; const chunkId: TIFF_ID; const attributeName: PIFF_ID): cint;
//var
//  x: Longint;
begin
  (*
  if (fread(id, IFF_ID_SIZE, 1, file) == 1)
    return TRUE;
    else
    {
    IFF_readError(chunkId, attributeName);
    return FALSE;
    }  
  *)

  if FileRead(filehandle, id, IFF_ID_SIZE * 1) = (IFF_ID_SIZE * 1)
  then exit(_TRUE_)
  else
  begin
    IFF_readError(chunkId, PChar(attributeName));
    Result := _FALSE_;
  end;
end;


function  IFF_writeId(filehandle: THandle; const id: TIFF_ID; const chunkId: TIFF_ID; const attributeName: PIFF_ID): cint;
begin
  (*
    if(fwrite(id, IFF_ID_SIZE, 1, file) == 1)
    return TRUE;
    else
    {
    IFF_writeError(chunkId, attributeName);
    return FALSE;
    }  
  *)
  if FileWrite(filehandle, id, (IFF_ID_SIZE * 1)) = (IFF_ID_SIZE * 1)
  then exit(_TRUE_)
  else
  begin
    IFF_writeError(chunkId, PChar(attributeName));
    result := _FALSE_;
  end;
end;


function  IFF_checkId(const id: PIFF_ID): cint;
begin
  Result := IFF_checkId(id^);
end;


function  IFF_checkId(const id: TIFF_ID): cint;
var
  i     : cuint;
begin
  //* ID characters must be between 0x20 and 0x7e */
  i := 0;
  while (i < IFF_ID_SIZE) do
  begin
    if ( (id[i] < #$20) or (id[i] > #$7e) ) then
    begin
      IFF_error('Illegal character: $%x in ID!' + LineEnding, [Ord(id[i])]);
      exit(_FALSE_);
    end;
    inc(i);
  end;

  //* Spaces may not precede an ID, trailing spaces are ok */

  if (id[0] = ' ') then
  begin
    IFF_error('Spaces may not precede an ID!' + LineEnding);
    Exit(_FALSE_);
  end;

  result := _TRUE_;
end;


procedure IFF_printId(const id: TIFF_ID);
var
  i     : cuint;
begin
  for i := 0 to Pred(IFF_ID_SIZE)
    do Write(id[i]);
end;



//////////////////////////////////////////////////////////////////////////////
//        io.c
//////////////////////////////////////////////////////////////////////////////



function  IFF_readUByte(filehandle: THandle; value: PIFF_UByte; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  byt : Byte;
  res : LongInt;
begin
  res := FileRead(filehandle, byt, SizeOf(byt));

  if (res = -1) then
  begin
    IFF_readError(chunkId, attributeName);
    exit(_FALSE_);
  end
  else
  begin
    value^ := byt;
    exit(_TRUE_);
  end;
end;


function  IFF_writeUByte(filehandle: THandle; const value: TIFF_UByte; const chunkId: TIFF_ID; const attributeName: PChar): cint;
begin
  If ( FileWrite(filehandle, value, SizeOf(Value)) = -1 ) then
  begin
    IFF_writeError(chunkId, attributeName);
    exit(_FALSE_);
  end
  else
    result := _TRUE_;
end;


function  IFF_readUWord(filehandle: THandle; value: PIFF_UWord; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  readUWord : TIFF_UWord;
begin
  if ( FileRead(filehandle, readUWord, (sizeof(TIFF_UWord) * 1)) = (sizeof(TIFF_UWord) * 1) ) then
  begin
    {$IFDEF IFF_BIG_ENDIAN}
    value^ := readUWord;
    {$ELSE}
    //* Byte swap it */
    value^ := ((readUWord and $ff) shl 8) or ((readUWord and $ff00) shr 8);
    {$ENDIF}

    exit(_TRUE_);
  end
  else
  begin
    IFF_readError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_writeUWord(filehandle: THandle; const value: TIFF_UWord; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  writeUWord : TIFF_UWord;
begin
  {$IFDEF IFF_BIG_ENDIAN}
  writeUWord := value;
  {$ELSE}
  //* Byte swap it */
  writeUWord := ( (value and $ff) shl 8 ) or ( (value and $ff00) shr 8);
  {$ENDIF}

  if ( FileWrite(filehandle, writeUWord, (sizeof(TIFF_UWord) * 1)) = (sizeof(TIFF_UWord) * 1) )
  then exit(_TRUE_)
  else
  begin
    IFF_writeError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_readWord(filehandle: THandle; value: PIFF_Word; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  readWord : TIFF_Word;
begin
  if ( FileRead(filehandle, readWord, (sizeof(TIFF_Word) * 1)) = (sizeof(TIFF_Word) * 1) ) then
  begin
    {$IFDEF IFF_BIG_ENDIAN}
    value^ := readWord;
    {$ELSE}
    //* Byte swap it */
    value^ := ((readWord and $ff) shl 8) or ((readWord and $ff00) shr 8);
    {$ENDIF}

    exit(_TRUE_);
  end
  else
  begin
    IFF_readError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_writeWord(filehandle: THandle; const value: TIFF_Word; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  writeWord : TIFF_Word;
begin
  {$IFDEF IFF_BIG_ENDIAN}
  writeWord := value;
  {$ELSE}
  //* Byte swap it */
  writeWord := ( (value and $ff) shl 8 ) or ( (value and $ff00) shr 8);
  {$ENDIF}

  if ( FileWrite(filehandle, writeWord, (sizeof(TIFF_Word) * 1)) = (sizeof(TIFF_Word) * 1) )
  then exit(_TRUE_)
  else
  begin
    IFF_writeError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_readULong(filehandle: THandle; value: PIFF_ULong; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  readValue : TIFF_ULong;
begin
  if ( FileRead(filehandle, readValue, (sizeof(TIFF_ULong) * 1)) = (sizeof(TIFF_ULong) * 1) ) then
  begin
    {$IFDEF IFF_BIG_ENDIAN}
    value^ := readValue;
    {$ELSE}
    //* Byte swap it */
    value^ := ((readValue and $ff) shl 24) or ((readValue and $ff00) shl 8) or ((readValue and $ff0000) shr 8) or ((readValue and $ff000000) shr 24);
    {$ENDIF}
    exit(_TRUE_);
  end
  else
  begin
    IFF_readError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_writeULong(filehandle: THandle; const value: TIFF_ULong; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  writeValue : TIFF_ULong;
begin
  {$IFDEF IFF_BIG_ENDIAN}
  writeValue := value;
  {$ELSE}
  //* Byte swap it */
  writeValue := ((value and $ff) shl 24) or ((value and $ff00) shl 8) or ((value and $ff0000) shr 8) or ((value and $ff000000) shr 24);
  {$ENDIF}

  if ( FileWrite(filehandle, writeValue, (sizeof(TIFF_ULong) * 1)) = (sizeof(TIFF_ULong) * 1) )
  then exit(_TRUE_)
  else
  begin
    IFF_writeError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_readLong(filehandle: THandle; value: PIFF_Long; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  readValue : TIFF_Long;
begin
  if ( FileRead(filehandle, readValue, (sizeof(TIFF_Long) * 1)) = (sizeof(TIFF_Long) * 1) ) then
  begin
    {$IFDEF IFF_BIG_ENDIAN}
    value^ := readValue;
    {$ELSE}
    //* Byte swap it */
    value^ := ((readValue and $ff) shl 24) or ((readValue and $ff00) shl 8) or ((readValue and $ff0000) shr 8) or ((readValue and $ff000000) shr 24);
    {$ENDIF}
    exit(_TRUE_);
  end
  else
  begin
    IFF_readError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_writeLong(filehandle: THandle; const value: TIFF_Long; const chunkId: TIFF_ID; const attributeName: PChar): cint;
var
  writeValue : TIFF_Long;
begin
  {$IFDEF IFF_BIG_ENDIAN}
  writeValue := value;
  {$ELSE}
  //* Byte swap it */
  writeValue := ((value and $ff) shl 24) or ((value and $ff00) shl 8) or ((value and $ff0000) shr 8) or ((value and $ff000000) shr 24);
  {$ENDIF}

  if ( FileWrite(filehandle, writeValue, (sizeof(TIFF_Long) * 1)) = (sizeof(TIFF_Long) * 1) )
  then exit(_TRUE_)
  else
  begin
    IFF_writeError(chunkId, attributeName);
    exit(_FALSE_);
  end;
end;


function  IFF_readPaddingByte(filehandle: THandle; const chunkSize: TIFF_Long; const chunkId: TIFF_ID): cint;
var
  byt   : Byte;
  res   : LongInt;
begin
  if (chunkSize mod 2 <> 0) then    //* Check whether the chunk size is an odd number */
  begin
    res := FileRead(filehandle, byt, SizeOf(byt)); //* Read padding byte */

    if (res = -1) then      //* We shouldn't have reached the EOF yet */
    begin
      IFF_error('Unexpected end of file, while reading padding byte of "');
      IFF_errorId(chunkId);
      IFF_error('"' + LineEnding);
      exit(_FALSE_);
    end
    else if(byt <> 0) //* Normally, a padding byte is 0, warn if this is not the case */
    then IFF_error('WARNING: Padding byte is non-zero!' + LineEnding);
  end;
  result := _TRUE_;
end;


function  IFF_writePaddingByte(filehandle: THandle; const chunkSize: TIFF_Long; const chunkId: TIFF_ID): cint;
Var
  padByte : Byte = 0;
begin
  if (chunkSize mod 2 <> 0) then //* Check whether the chunk size is an odd number */
  begin
    if ( FileWrite(filehandle, PadByte, SizeOf(PadByte)) = -1 ) then
    begin
      IFF_error('Cannot write padding byte of "');
      IFF_errorId(chunkId);
      IFF_error('"' + LineEnding);
      exit(_FALSE_);
    end
    else
      exit(_TRUE_);
  end;

  Result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        prop.c
//////////////////////////////////////////////////////////////////////////////



Const
  PROP_CHUNKID          = 'PROP';
  PROP_GROUPTYPENAME    = 'formType';


function  IFF_createProp(const formType: PIFF_ID): PIFF_Prop;
begin
  Result := PIFF_Prop(IFF_createGroup(PROP_CHUNKID, formType));
end;


procedure IFF_addToProp(prop: PIFF_Prop; chunk: PIFF_Chunk);
begin
  IFF_addToForm(PIFF_Form(prop), chunk);
end;


function  IFF_readProp(filehandle: Thandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_Prop;
begin
  result := PIFF_Prop(IFF_readGroup(filehandle, PROP_CHUNKID, chunkSize, PROP_GROUPTYPENAME, _TRUE_, extension, extensionLength));
end;


function  IFF_writeProp(filehandle: THandle; const prop: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  result := IFF_writeForm(filehandle, PIFF_Form(prop), extension, extensionLength);
end;


function prop_subChunkCheck(const group: PIFF_Group; const subChunk: PIFF_Chunk): cint;
begin
  if
  (
    ( IFF_compareId(subChunk^.chunkId, 'FORM') = 0 ) or
    ( IFF_compareId(subChunk^.chunkId, 'LIST') = 0 ) or
    ( IFF_compareId(subChunk^.chunkId, 'CAT ') = 0 ) or
    ( IFF_compareId(subChunk^.chunkId, 'PROP') = 0 )
  ) then
  begin
    IFF_error('ERROR: Element with chunk Id: "');
    IFF_errorId(subChunk^.chunkId);
    IFF_error('" not allowed in PROP chunk!' + LineEnding);

    exit(_FALSE_);
  end
  else
    Result := _TRUE_;
end;


function  IFF_checkProp(const prop: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  // TIFF_groupTypeCheckFunc = function(const groupType: PChar): cint;
  // result := IFF_checkGroup(PIFF_Group(prop), @IFF_checkFormType, @prop_subChunkCheck, prop^.formType, extension, extensionLength);
//  result := IFF_checkGroup(PIFF_Group(prop), TIFF_groupTypeCheckFunc(@IFF_checkFormType), @prop_subChunkCheck, @prop^.formType, extension, extensionLength);
  result := IFF_checkGroup(PIFF_Group(prop), @IFF_checkFormType, @prop_subChunkCheck, @prop^.formType, extension, extensionLength);
end;


procedure IFF_freeProp(prop: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_freeForm(PIFF_Form(prop), extension, extensionLength);
end;


procedure IFF_printProp(const prop: PIFF_Prop; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);
begin
  IFF_printForm(PIFF_Form(prop), indentLevel, extension, extensionLength);
end;


function  IFF_compareProp(const prop1: PIFF_Prop; const prop2: PIFF_Prop; const extension: PIFF_Extension; const extensionLength: cuint): cint;
begin
  result := IFF_compareForm(PIFF_Form(prop1), PIFF_Form(prop2), extension, extensionLength);
end;


procedure IFF_updatePropChunkSizes(prop: PIFF_Prop);
begin
  IFF_updateFormChunkSizes(PIFF_Form(prop));
end;


function  IFF_getChunkFromProp(const prop: PIFF_Prop; const chunkId: PIFF_ID): PIFF_Chunk;
begin
  result := IFF_getDataChunkFromForm(PIFF_Form(prop), chunkId);
end;



//////////////////////////////////////////////////////////////////////////////
//        list.c
//////////////////////////////////////////////////////////////////////////////



const
  CHUNKID   = 'LIST';


function  IFF_createList(const contentsType: PIFF_ID): PIFF_List;
var
  list: PIFF_List;
begin
  list := PIFF_List(IFF_allocateChunk(CHUNKID, sizeof(TIFF_List)));

  if (list <> nil) then
  begin
    IFF_initGroup(PIFF_Group(list), contentsType);

    list^.prop := nil;
    list^.propLength := 0;
  end;

  result := list;
end;


procedure IFF_addPropToList(list: PIFF_List; prop: PIFF_Prop);
begin
  list^.prop := PPIFF_Prop(ReAllocMem(list^.prop, (list^.propLength + 1) * sizeof(PIFF_Prop)));
  list^.prop[list^.propLength] := prop;
  list^.propLength := list^.propLength + 1;
  list^.chunkSize := IFF_incrementChunkSize(list^.chunkSize, PIFF_Chunk(prop));

  prop^.parent := PIFF_Group(list);
end;


procedure IFF_addToList(list: PIFF_List; chunk: PIFF_Chunk);
begin
  IFF_addToCAT(PIFF_CAT(list), chunk);
end;


function  IFF_readList(filehandle: Thandle; const chunkSize: TIFF_Long; const extension: PIFF_Extension; const extensionLength: cuint): PIFF_List;
var
  contentsType  : TIFF_ID;
  list          : PIFF_List;
var
  chunk         : PIFF_Chunk;
begin
  //* Read the contentsType id */
  if notValid(IFF_readId(filehandle, contentsType, CHUNKID, 'contentsType'))
  then exit(nil);

  //* Create new list */
  list := IFF_createList(@contentsType);

  //* Read the remaining nested sub chunks */

  while (list^.chunkSize < chunkSize) do
  begin
    //* Read sub chunk */
    chunk := IFF_readChunk(filehandle, Nil, extension, extensionLength);

    if (chunk = nil) then
    begin
      IFF_error('Error reading chunk in list!' + LineEnding);
      IFF_freeChunk(PIFF_Chunk(list), Nil, extension, extensionLength);
      exit(Nil);
    end;

    //* Add the prop or chunk */
    if (IFF_compareId(chunk^.chunkId, 'PROP') = 0)
    then IFF_addPropToList(list, PIFF_Prop(chunk))
    else
      IFF_addToList(list, chunk);
  end;

  //* Set the chunk size to what we have read */
  list^.chunkSize := chunkSize;

  //* Return the resulting list */
  result := list;
end;


function  IFF_writeList(filehandle: Thandle; const list: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  i  : cuint;
begin

  if notValid(IFF_writeId(filehandle, list^.contentsType, CHUNKID, 'contentsType')) then
  begin
    IFF_error('Error writing contentsType!' + LineEnding);
    exit(_FALSE_);
  end;

  i := 0;
  while (i < list^.propLength) do
  begin
    if notValid(IFF_writeChunk(filehandle, PIFF_Chunk(list^.prop[i]), nil, extension, extensionLength)) then
    begin
      IFF_error('Error writing PROP!' + LineEnding);
      exit(_FALSE_);
    end;
    inc(i);
  end;

  if notValid(IFF_writeGroupSubChunks(filehandle, PIFF_Group(list), nil, extension, extensionLength))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  IFF_checkList(const list: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  i             : cuint;
  chunkSize     : TIFF_Long;
  subChunkSize  : TIFF_Long;
var
  propChunk     : PIFF_Chunk;
begin
  chunkSize := IFF_ID_SIZE;

  if notValid(IFF_checkId(list^.contentsType))
  then exit(_FALSE_);

  //* Check validity of PROP chunks */

  i := 0;
  while (i < list^.propLength) do
  begin
    propChunk := PIFF_Chunk(list^.prop[i]);

    if notValid(IFF_checkChunk(propChunk, Nil, extension, extensionLength))
    then exit(_FALSE_);

    chunkSize := IFF_incrementChunkSize(chunkSize, propChunk);
    inc(i);
  end;

  //* Check validity of other sub chunks */
  subChunkSize := IFF_checkGroupSubChunks(PIFF_Group(list), @IFF_checkCATSubChunk, nil, extension, extensionLength);
  if (subChunkSize = -1)
    then exit(_FALSE_);

  chunkSize := chunkSize + subChunkSize;

  //* Check whether the calculated chunk size matches the chunks' chunk size */
  if notValid(IFF_checkGroupChunkSize(PIFF_Group(list), chunkSize))
  then exit(_FALSE_);

  result := _TRUE_;
end;


procedure IFF_freeList(list: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint);
var
  i : cuint;
begin

  IFF_freeCAT(PIFF_CAT(list), extension, extensionLength);

  i := 0;
  while (i < list^.propLength) do
  begin
    IFF_freeChunk(PIFF_Chunk(list^.prop[i]), nil, extension, extensionLength);
    inc(i);
  end;

  FreeMem(list^.prop);
end;


procedure IFF_printList(const list: PIFF_List; const indentLevel: cuint; const extension: PIFF_Extension; const extensionLength: cuint);
var
  i : cuint;
begin

  IFF_printGroupType('contentsType', @list^.contentsType, indentLevel);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'prop = [' + LineEnding);

  //* Print shared properties */
  i := 0;
  while (i < list^.propLength) do
  begin
    IFF_printChunk(PIFF_Chunk(list^.prop[i]), indentLevel + 1, nil, extension, extensionLength);
    inc(i);
  end;

  IFF_printIndent(GetStdOutHandle, indentLevel, '];' + LineEnding);

  //* Print sub chunks */
  IFF_printGroupSubChunks(PIFF_Group(list), indentLevel, Nil, extension, extensionLength);
end;


function  IFF_compareList(const list1: PIFF_List; const list2: PIFF_List; const extension: PIFF_Extension; const extensionLength: cuint): cint;
var
  i : cuint;
begin
  if (list1^.propLength = list2^.propLength) then
  begin

    i := 0;
    while (i < list1^.propLength) do
    begin
      if notValid(IFF_compareProp(list1^.prop[i], list2^.prop[i], extension, extensionLength))
      then exit(_FALSE_);
      inc(i);
    end;

    exit(IFF_compareCAT(PIFF_CAT(list1), PIFF_CAT(list2), extension, extensionLength));
  end
  else
    result := _FALSE_;
end;


function  IFF_searchFormsInList(list: PIFF_List; const formType: PIFF_ID; formsLength: pcuint): PPIFF_Form;
begin
  result := IFF_searchFormsInCAT(PIFF_CAT(list), formType, formsLength);
end;


procedure IFF_updateListChunkSizes(list: PIFF_List);
var
  i : cuint;
begin
  IFF_updateCATChunkSizes(PIFF_CAT(list));

  i := 0;
  while (i < list^.propLength) do
  begin
    list^.chunkSize := IFF_incrementChunkSize(list^.chunkSize, PIFF_Chunk(list^.prop[i]));
    inc(i);
  end;
end;


function  IFF_getPropFromList(const list: PIFF_List; const formType: PIFF_ID): PIFF_Prop;
var
  i : cuint;
begin
  i := 0;
  while (i < list^.propLength) do
  begin
    if (IFF_compareId(list^.prop[i]^.formType, formType) = 0)
      then exit(list^.prop[i]);
    inc(i);
  end;

  Result := nil;
end;



//////////////////////////////////////////////////////////////////////////////
//        rawchunk.c
//////////////////////////////////////////////////////////////////////////////



function  IFF_createRawChunk(const chunkId: PIFF_ID): PIFF_RawChunk;
var
  rawChunk  : PIFF_RawChunk;
begin
  rawChunk := PIFF_RawChunk(IFF_allocateChunk(chunkId, sizeof(TIFF_RawChunk)));

  if (rawChunk <> nil)
  then rawChunk^.chunkData := nil;

  result := rawChunk;
end;


procedure IFF_setRawChunkData(rawChunk: PIFF_RawChunk; chunkData: PIFF_UByte; chunkSize: TIFF_Long );
begin
  rawChunk^.chunkData := chunkData;
  rawChunk^.chunkSize := chunkSize;
end;


procedure IFF_setTextData(rawChunk: PIFF_RawChunk; const txt: PChar);
var
  textLength    : csize_t;
  chunkData     : PIFF_UByte;
begin
  textLength := strlen(txt);
  chunkData := PIFF_UByte(AllocMem(textLength * sizeof(TIFF_UByte)));

  memcpy(chunkData, txt, textLength);
  IFF_setRawChunkData(rawChunk, chunkData, textLength);
end;


function  IFF_readRawChunk(filehandle: THandle; const chunkId: PIFF_ID; const chunkSize: TIFF_Long): PIFF_RawChunk;
var
  chunkData : PIFF_UByte;
  rawChunk  : PIFF_RawChunk;
begin
  chunkData := PIFF_UByte(AllocMem(chunkSize * sizeof(TIFF_UByte)));

  rawChunk := IFF_createRawChunk(chunkId);

  //* Read remaining bytes verbatim */
  If ( FileRead(filehandle, chunkData^, (sizeof(TIFF_UByte) * chunkSize)) < (sizeof(TIFF_UByte) * chunkSize) ) then
  begin
    IFF_error('Error reading raw chunk body of chunk: "');
    IFF_errorId(chunkId^);
    IFF_error('"' + LineEnding);
    IFF_freeChunk(PIFF_Chunk(rawChunk), nil, nil, 0);
    exit(nil);
  end;

  //* If the chunk size is odd, we have to read the padding byte */
  if notValid(IFF_readPaddingByte(filehandle, chunkSize, chunkId^)) then
  begin
    IFF_freeChunk(PIFF_Chunk(rawChunk), nil, nil, 0);
    exit(nil)
  end;

  //* Add data to the created chunk */
  IFF_setRawChunkData(rawChunk, chunkData, chunkSize);

  //* Return the resulting raw chunk */
  result := rawChunk;
end;


function  IFF_writeRawChunk(filehandle: THandle; const rawChunk: PIFF_RawChunk): cint;
begin
//  if ( FileWrite(filehandle, rawChunk^.chunkData, (sizeof(TIFF_UByte) * rawChunk^.chunkSize)) < (sizeof(TIFF_UByte) * rawChunk^.chunkSize) ) then
  if ( FileWrite(filehandle, rawChunk^.chunkData^, (sizeof(TIFF_UByte) * rawChunk^.chunkSize)) < (sizeof(TIFF_UByte) * rawChunk^.chunkSize) ) then
  begin
    IFF_error('Error writing raw chunk body of chunk "');
    IFF_errorId(rawChunk^.chunkId);
    IFF_error('"');
    exit(_FALSE_);
  end;

  //* If the chunk size is odd, we have to write the padding byte */
  if notValid(IFF_writePaddingByte(filehandle, rawChunk^.chunkSize, rawChunk^.chunkId))
  then exit(_FALSE_);

  result := _TRUE_;
end;


procedure IFF_freeRawChunk(rawChunk: PIFF_RawChunk);
begin
  FreeMem(rawChunk^.chunkData);
end;


procedure IFF_printText(const rawChunk: PIFF_RawChunk; const indentLevel: cuint);
var
  i : cuint;
begin

  IFF_printIndent(GetStdOuthandle, indentLevel, 'text = "' + LineEnding);
  IFF_printIndent(GetStdOutHandle, indentLevel + 1, '');

  i := 0;
  while (i < rawChunk^.chunkSize) do
  begin
    // FPC NOTE: break loop when string end is encountered.
    // todo: what to do with non printable characters ?
    if rawChunk^.chunkData[i] = 0 then break;
    Write(Char(rawChunk^.chunkData[i]));
    inc(i);
  end;

  WriteLn;
  IFF_printIndent(GetStdOuthandle, indentLevel, '";' + LineEnding);
end;


procedure IFF_printRaw(const rawChunk: PIFF_RawChunk; const indentLevel: cuint);
var
  i   : cuint;
  byt : TIFF_UByte;
begin
  IFF_printIndent(GetStdOutHandle, indentLevel, 'bytes = ' + LineEnding);
  IFF_printIndent(GetStdOutHandle, indentLevel + 1, '');

  for i := 0 to Pred(rawChunk^.chunkSize) do
  begin
    if ( (i > 0) and (i mod 10 = 0) ) then
    begin
      WriteLn;
      IFF_printIndent(GetStdOutHandle, indentLevel + 1, '');
    end;

    byt := rawChunk^.chunkData[i];

    //* Print extra 0 for small numbers */
    // FPC Note: we can skip this for FPC as inttohex already takes care
    //    if (byt <= $f)
    //      then Write('0');

    Write(IntToHex(byt, 2),' ');
  end;

  WriteLn;
  IFF_printIndent(GetStdOuthandle, indentLevel, ';' + LineEnding);
end;


procedure IFF_printRawChunk(const rawChunk: PIFF_RawChunk; indentLevel: cuint);
begin
  if (IFF_compareId(rawChunk^.chunkId, 'TEXT') = 0)
  then IFF_printText(rawChunk, indentLevel)
  else
    IFF_printRaw(rawChunk, indentLevel);
end;


function  IFF_compareRawChunk(const rawChunk1: PIFF_RawChunk; const rawChunk2: PIFF_RawChunk): cint;
begin
  If ( memcmp(rawChunk1^.chunkData, rawChunk2^.chunkData, rawChunk1^.chunkSize) = 0)
  then result := _TRUE_
  else result := _FALSE_;
end;


end.
