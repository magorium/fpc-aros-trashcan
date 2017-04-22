unit libpref;

{$MODE OBJFPC}{$H+}


interface

uses
  ctypes, libiff;

  function  PREF_read(const filename: PChar): PIFF_Chunk;
  function  PREF_readFd(filehandle: THandle): PIFF_Chunk;
  function  PREF_writeFd(filehandle: THandle; const chunk: PIFF_Chunk): cint;
  function  PREF_write(const filename: PChar; const chunk: PIFF_Chunk): cint;
  function  PREF_check(const chunk: PIFF_Chunk): cint;
  procedure PREF_free(chunk: PIFF_Chunk);
  procedure PREF_print(const chunk: PIFF_Chunk; const indentLevel: cuint);
  function  PREF_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;



implementation

uses
  CHelpers, SysUtils, 
  libpref_muicfg_tags;  // <- for the MUIC serial MUICFG tag numbers.



//////////////////////////////////////////////////////////////////////////////
//        empty.pas
//////////////////////////////////////////////////////////////////////////////


(*

*)



//////////////////////////////////////////////////////////////////////////////
//        muiconfig.pas
//////////////////////////////////////////////////////////////////////////////

// list of recognized MUICFG_xxx ID's
Type
  TIDEntry = record
    IDnum : LongWord;
    Idnam : PChar;
  end;  

Const
  IDList : Array
  [ 0..158      // Basic MUI configuration tags
    + 39        // TextInput
    + 38        // NList
    + 28        // TextEditor
    + 11        // BetterString
    + 23        // HTMLView
    + 46        // TheBar
    + 12        // NListtree
    + 22        // toolbar
    + 20        // UrlText
  ] of TIDEntry = 
  (
    ( IDnum: $00000001; IDNam: 'MUICFG_Window_Spacing_Left' ),
    ( IDnum: $00000002; IDNam: 'MUICFG_Window_Spacing_Right' ),
    ( IDnum: $00000003; IDNam: 'MUICFG_Window_Spacing_Top' ),
    ( IDnum: $00000004; IDNam: 'MUICFG_Window_Spacing_Bottom' ),
    ( IDnum: $00000005; IDNam: 'MUICFG_Radio_HSpacing' ),
    ( IDnum: $00000006; IDNam: 'MUICFG_Radio_VSpacing' ),
    ( IDnum: $00000007; IDNam: 'MUICFG_Group_HSpacing' ),
    ( IDnum: $00000008; IDNam: 'MUICFG_Group_VSpacing' ),
    ( IDnum: $00000009; IDNam: 'MUICFG_Scrollbar_Arrangement' ),
    ( IDnum: $0000000a; IDNam: 'MUICFG_Listview_Refresh' ),
    ( IDnum: $0000000b; IDNam: 'MUICFG_Listview_Font_Leading' ),
    ( IDnum: $0000000c; IDNam: 'MUICFG_Listview_SmoothVal' ),
    ( IDnum: $0000000d; IDNam: 'MUICFG_Listview_Multi' ),
    ( IDnum: $0000000f; IDNam: 'MUICFG_GroupTitle_Position' ),
    ( IDnum: $00000010; IDNam: 'MUICFG_GroupTitle_Color' ),
    ( IDnum: $00000011; IDNam: 'MUICFG_Cycle_MenuCtrl_Level' ),
    ( IDnum: $00000012; IDNam: 'MUICFG_Cycle_MenuCtrl_Position' ),
    ( IDnum: $00000018; IDNam: 'MUICFG_Frame_Drag               ' ),
    ( IDnum: $00000019; IDNam: 'MUICFG_Cycle_Menu_Recessed' ),
    ( IDnum: $0000001a; IDNam: 'MUICFG_Cycle_MenuCtrl_Speed' ),
    ( IDnum: $0000001b; IDNam: 'MUICFG_Listview_Smoothed' ),
    ( IDnum: $0000001d; IDNam: 'MUICFG_Window_Redraw' ),
    ( IDnum: $0000001e; IDNam: 'MUICFG_Font_Normal              ' ),
    ( IDnum: $0000001f; IDNam: 'MUICFG_Font_List                ' ),
    ( IDnum: $00000020; IDNam: 'MUICFG_Font_Tiny                ' ),
    ( IDnum: $00000021; IDNam: 'MUICFG_Font_Fixed               ' ),
    ( IDnum: $00000022; IDNam: 'MUICFG_Font_Title               ' ),
    ( IDnum: $00000023; IDNam: 'MUICFG_Font_Big                 ' ),
    ( IDnum: $00000024; IDNam: 'MUICFG_PublicScreen             ' ),
    ( IDnum: $0000002b; IDNam: 'MUICFG_Frame_Button             ' ),
    ( IDnum: $0000002c; IDNam: 'MUICFG_Frame_ImageButton        ' ),
    ( IDnum: $0000002d; IDNam: 'MUICFG_Frame_Text               ' ),
    ( IDnum: $0000002e; IDNam: 'MUICFG_Frame_String             ' ),
    ( IDnum: $0000002f; IDNam: 'MUICFG_Frame_ReadList           ' ),
    ( IDnum: $00000030; IDNam: 'MUICFG_Frame_InputList          ' ),
    ( IDnum: $00000031; IDNam: 'MUICFG_Frame_Prop               ' ),
    ( IDnum: $00000032; IDNam: 'MUICFG_Frame_Gauge              ' ),
    ( IDnum: $00000033; IDNam: 'MUICFG_Frame_Group              ' ),
    ( IDnum: $00000034; IDNam: 'MUICFG_Frame_PopUp              ' ),
    ( IDnum: $00000035; IDNam: 'MUICFG_Frame_Virtual            ' ),
    ( IDnum: $00000036; IDNam: 'MUICFG_Frame_Slider             ' ),
    ( IDnum: $00000037; IDNam: 'MUICFG_Background_Window        ' ),
    ( IDnum: $00000038; IDNam: 'MUICFG_Background_Requester     ' ),
    ( IDnum: $00000039; IDNam: 'MUICFG_Background_Button        ' ),
    ( IDnum: $0000003a; IDNam: 'MUICFG_Background_List          ' ),
    ( IDnum: $0000003b; IDNam: 'MUICFG_Background_Text          ' ),
    ( IDnum: $0000003c; IDNam: 'MUICFG_Background_Prop          ' ),
    ( IDnum: $0000003d; IDNam: 'MUICFG_Background_PopUp         ' ),
    ( IDnum: $0000003e; IDNam: 'MUICFG_Background_Selected      ' ),
    ( IDnum: $0000003f; IDNam: 'MUICFG_Background_ListCursor    ' ),
    ( IDnum: $00000040; IDNam: 'MUICFG_Background_ListSelect    ' ),
    ( IDnum: $00000041; IDNam: 'MUICFG_Background_ListSelCur    ' ),
    ( IDnum: $00000042; IDNam: 'MUICFG_Image_ArrowUp            ' ),
    ( IDnum: $00000043; IDNam: 'MUICFG_Image_ArrowDown          ' ),
    ( IDnum: $00000044; IDNam: 'MUICFG_Image_ArrowLeft          ' ),
    ( IDnum: $00000045; IDNam: 'MUICFG_Image_ArrowRight         ' ),
    ( IDnum: $00000046; IDNam: 'MUICFG_Image_CheckMark          ' ),
    ( IDnum: $00000047; IDNam: 'MUICFG_Image_RadioButton        ' ),
    ( IDnum: $00000048; IDNam: 'MUICFG_Image_Cycle              ' ),
    ( IDnum: $00000049; IDNam: 'MUICFG_Image_PopUp              ' ),
    ( IDnum: $0000004a; IDNam: 'MUICFG_Image_PopFile            ' ),
    ( IDnum: $0000004b; IDNam: 'MUICFG_Image_PopDrawer          ' ),
    ( IDnum: $0000004c; IDNam: 'MUICFG_Image_PropKnob           ' ),
    ( IDnum: $0000004d; IDNam: 'MUICFG_Image_Drawer             ' ),
    ( IDnum: $0000004e; IDNam: 'MUICFG_Image_HardDisk           ' ),
    ( IDnum: $0000004f; IDNam: 'MUICFG_Image_Disk               ' ),
    ( IDnum: $00000050; IDNam: 'MUICFG_Image_Chip               ' ),
    ( IDnum: $00000051; IDNam: 'MUICFG_Image_Volume             ' ),
    ( IDnum: $00000052; IDNam: 'MUICFG_Image_Network            ' ),
    ( IDnum: $00000053; IDNam: 'MUICFG_Image_Assign             ' ),
    ( IDnum: $00000054; IDNam: 'MUICFG_Background_Register      ' ),
    ( IDnum: $00000055; IDNam: 'MUICFG_Image_TapePlay           ' ),
    ( IDnum: $00000056; IDNam: 'MUICFG_Image_TapePlayBack       ' ),
    ( IDnum: $00000057; IDNam: 'MUICFG_Image_TapePause          ' ),
    ( IDnum: $00000058; IDNam: 'MUICFG_Image_TapeStop           ' ),
    ( IDnum: $00000059; IDNam: 'MUICFG_Image_TapeRecord         ' ),
    ( IDnum: $0000005a; IDNam: 'MUICFG_Background_Framed        ' ),
    ( IDnum: $0000005b; IDNam: 'MUICFG_Background_Slider        ' ),
    ( IDnum: $0000005c; IDNam: 'MUICFG_Background_SliderKnob    ' ),
    ( IDnum: $0000005d; IDNam: 'MUICFG_Image_TapeUp             ' ),
    ( IDnum: $0000005e; IDNam: 'MUICFG_Image_TapeDown           ' ),
    ( IDnum: $0000005f; IDNam: 'MUICFG_Keyboard_Press           ' ),
    ( IDnum: $00000060; IDNam: 'MUICFG_Keyboard_Toggle          ' ),
    ( IDnum: $00000061; IDNam: 'MUICFG_Keyboard_Up              ' ),
    ( IDnum: $00000062; IDNam: 'MUICFG_Keyboard_Down            ' ),
    ( IDnum: $00000063; IDNam: 'MUICFG_Keyboard_PageUp          ' ),
    ( IDnum: $00000064; IDNam: 'MUICFG_Keyboard_PageDown        ' ),
    ( IDnum: $00000065; IDNam: 'MUICFG_Keyboard_Top             ' ),
    ( IDnum: $00000066; IDNam: 'MUICFG_Keyboard_Bottom          ' ),
    ( IDnum: $00000067; IDNam: 'MUICFG_Keyboard_Left            ' ),
    ( IDnum: $00000068; IDNam: 'MUICFG_Keyboard_Right           ' ),
    ( IDnum: $00000069; IDNam: 'MUICFG_Keyboard_WordLeft        ' ),
    ( IDnum: $0000006a; IDNam: 'MUICFG_Keyboard_WordRight       ' ),
    ( IDnum: $0000006b; IDNam: 'MUICFG_Keyboard_LineStart       ' ),
    ( IDnum: $0000006c; IDNam: 'MUICFG_Keyboard_LineEnd         ' ),
    ( IDnum: $0000006d; IDNam: 'MUICFG_Keyboard_NextGadget      ' ),
    ( IDnum: $0000006e; IDNam: 'MUICFG_Keyboard_PrevGadget      ' ),
    ( IDnum: $0000006f; IDNam: 'MUICFG_Keyboard_GadgetOff       ' ),
    ( IDnum: $00000070; IDNam: 'MUICFG_Keyboard_CloseWindow     ' ),
    ( IDnum: $00000071; IDNam: 'MUICFG_Keyboard_NextWindow      ' ),
    ( IDnum: $00000072; IDNam: 'MUICFG_Keyboard_PrevWindow      ' ),
    ( IDnum: $00000073; IDNam: 'MUICFG_Keyboard_Help            ' ),
    ( IDnum: $00000074; IDNam: 'MUICFG_Keyboard_Popup           ' ),
    ( IDnum: $0000007a; IDNam: 'MUICFG_Window_Positions         ' ),
    ( IDnum: $0000007b; IDNam: 'MUICFG_Balance_Look' ),
    ( IDnum: $00000080; IDNam: 'MUICFG_Font_Button              ' ),
    ( IDnum: $00000083; IDNam: 'MUICFG_Scrollbar_Type' ),
    ( IDnum: $00000084; IDNam: 'MUICFG_String_Background        ' ),
    ( IDnum: $00000085; IDNam: 'MUICFG_String_Text              ' ),
    ( IDnum: $00000086; IDNam: 'MUICFG_String_ActiveBackground  ' ),
    ( IDnum: $00000087; IDNam: 'MUICFG_String_ActiveText        ' ),
    ( IDnum: $00000088; IDNam: 'MUICFG_Font_Knob                ' ),
    ( IDnum: $00000089; IDNam: 'MUICFG_Drag_LeftButton' ),
    ( IDnum: $0000008a; IDNam: 'MUICFG_Drag_MiddleButton' ),
    ( IDnum: $0000008b; IDNam: 'MUICFG_Drag_LMBModifier' ),
    ( IDnum: $0000008c; IDNam: 'MUICFG_Drag_MMBModifier' ),
    ( IDnum: $0000008d; IDNam: 'MUICFG_Drag_Autostart' ),
    ( IDnum: $0000008e; IDNam: 'MUICFG_Drag_Autostart_Length' ),
    ( IDnum: $0000008f; IDNam: 'MUICFG_ActiveObject_Color' ),
    ( IDnum: $00000090; IDNam: 'MUICFG_Frame_Knob               ' ),
    ( IDnum: $00000094; IDNam: 'MUICFG_Dragndrop_Look' ),
    ( IDnum: $00000095; IDNam: 'MUICFG_Background_Page          ' ),
    ( IDnum: $00000096; IDNam: 'MUICFG_Background_ReadList      ' ),

    ( IDnum: $00000400; IDNam: 'MUICFG_String_Cursor            ' ),
    ( IDnum: $00000401; IDNam: 'MUICFG_String_MarkedBackground  ' ),
    ( IDnum: $00000402; IDNam: 'MUICFG_String_MarkedText        ' ),
    ( IDnum: $00000403; IDNam: 'MUICFG_Register_TruncateTitles  ' ),
    ( IDnum: $00000404; IDNam: 'MUICFG_Window_Refresh           ' ),

    ( IDnum: $00000505; IDNam: 'MUICFG_Screen_Mode              ' ),
    ( IDnum: $00000506; IDNam: 'MUICFG_Screen_Mode_ID           ' ),
    ( IDnum: $00000507; IDNam: 'MUICFG_Screen_Width             ' ),
    ( IDnum: $00000508; IDNam: 'MUICFG_Screen_Height            ' ),
    ( IDnum: $00000509; IDNam: 'MUICFG_WindowPos                ' ),
    ( IDnum: $0000050a; IDNam: 'MUICFG_Window_Buttons           ' ),

    ( IDnum: $00000600; IDNam: 'MUICFG_CustomFrame_1            ' ),
    ( IDnum: $00000601; IDNam: 'MUICFG_CustomFrame_2            ' ),
    ( IDnum: $00000602; IDNam: 'MUICFG_CustomFrame_3            ' ),
    ( IDnum: $00000603; IDNam: 'MUICFG_CustomFrame_4            ' ),
    ( IDnum: $00000604; IDNam: 'MUICFG_CustomFrame_5            ' ),
    ( IDnum: $00000605; IDNam: 'MUICFG_CustomFrame_6            ' ),
    ( IDnum: $00000606; IDNam: 'MUICFG_CustomFrame_7            ' ),
    ( IDnum: $00000607; IDNam: 'MUICFG_CustomFrame_8            ' ),
    ( IDnum: $00000608; IDNam: 'MUICFG_CustomFrame_9            ' ),
    ( IDnum: $00000609; IDNam: 'MUICFG_CustomFrame_10           ' ),
    ( IDnum: $0000060a; IDNam: 'MUICFG_CustomFrame_11           ' ),
    ( IDnum: $0000060b; IDNam: 'MUICFG_CustomFrame_12           ' ),
    ( IDnum: $0000060c; IDNam: 'MUICFG_CustomFrame_13           ' ),
    ( IDnum: $0000060d; IDNam: 'MUICFG_CustomFrame_14           ' ),
    ( IDnum: $0000060e; IDNam: 'MUICFG_CustomFrame_15           ' ),
    ( IDnum: $0000060f; IDNam: 'MUICFG_CustomFrame_16           ' ),

    ( IDnum: $00000700; IDNam: 'MUICFG_PublicScreen_PopToFront  ' ),
    ( IDnum: $00000701; IDNam: 'MUICFG_Iconification_Hotkey     ' ),
    ( IDnum: $00000702; IDNam: 'MUICFG_Iconification_ShowIcon   ' ),
    ( IDnum: $00000703; IDNam: 'MUICFG_Iconification_ShowMenu   ' ),
    ( IDnum: $00000704; IDNam: 'MUICFG_Iconification_OnStartup  ' ),
    ( IDnum: $00000705; IDNam: 'MUICFG_Interfaces_EnableARexx   ' ),
    ( IDnum: $00000706; IDNam: 'MUICFG_BubbleHelp_FirstDelay    ' ),
    ( IDnum: $00000707; IDNam: 'MUICFG_BubbleHelp_NextDelay     ' ),

    //
    // textinput  (39 entries)
    //
    ( IDnum: MUICFG_Textinput_ExternalEditor               ;  IDnam: 'MUICFG_Textinput_ExternalEditor' ),
    ( IDnum: MUICFG_Textinput_Cursorstyle                  ;  IDnam: 'MUICFG_Textinput_Cursorstyle' ),
    ( IDnum: MUICFG_Textinput_Blinkrate                    ;  IDnam: 'MUICFG_Textinput_Blinkrate' ),
    ( IDnum: MUICFG_Textinput_Font                         ;  IDnam: 'MUICFG_Textinput_Font' ),
    ( IDnum: MUICFG_Textinput_ButtonImage                  ;  IDnam: 'MUICFG_Textinput_ButtonImage' ),
    ( IDnum: MUICFG_Textinput_EditSync                     ;  IDnam: 'MUICFG_Textinput_EditSync' ),
    ( IDnum: MUICFG_Textinput_WordWrapOn                   ;  IDnam: 'MUICFG_Textinput_WordWrapOn' ),
    ( IDnum: MUICFG_Textinput_WordWrapAt                   ;  IDnam: 'MUICFG_Textinput_WordWrapAt' ),
    ( IDnum: MUICFG_Textinput_SavedVerRev                  ;  IDnam: 'MUICFG_Textinput_SavedVerRev' ),
    ( IDnum: MUICFG_Textinput_SingleFallback               ;  IDnam: 'MUICFG_Textinput_SingleFallback' ),
    ( IDnum: MUICFG_Textinput_PopupSingle                  ;  IDnam: 'MUICFG_Textinput_PopupSingle' ),
    ( IDnum: MUICFG_Textinput_PopupMulti                   ;  IDnam: 'MUICFG_Textinput_PopupMulti' ),
    ( IDnum: MUICFG_Textinput_CursorSize                   ;  IDnam: 'MUICFG_Textinput_CursorSize' ),
    ( IDnum: MUICFG_Textinput_MarkQuals                    ;  IDnam: 'MUICFG_Textinput_MarkQuals' ),
    ( IDnum: MUICFG_Textinput_FindURLInput                 ;  IDnam: 'MUICFG_Textinput_FindURLInput' ),
    ( IDnum: MUICFG_Textinput_FindURLNoInput               ;  IDnam: 'MUICFG_Textinput_FindURLNoInput' ),
    ( IDnum: MUICFG_Textinput_UndoBytesSingle              ;  IDnam: 'MUICFG_Textinput_UndoBytesSingle' ),
    ( IDnum: MUICFG_Textinput_UndoLevelsSingle             ;  IDnam: 'MUICFG_Textinput_UndoLevelsSingle' ),
    ( IDnum: MUICFG_Textinput_UndoBytesMulti               ;  IDnam: 'MUICFG_Textinput_UndoBytesMulti' ),
    ( IDnum: MUICFG_Textinput_UndoLevelsMulti              ;  IDnam: 'MUICFG_Textinput_UndoLevelsMulti' ),
    ( IDnum: MUICFG_Textinput_ClickableURLInput            ;  IDnam: 'MUICFG_Textinput_ClickableURLInput' ),
    ( IDnum: MUICFG_Textinput_ClickableURLNoInput          ;  IDnam: 'MUICFG_Textinput_ClickableURLNoInput' ),
    ( IDnum: MUICFG_Textinput_FixedFont                    ;  IDnam: 'MUICFG_Textinput_FixedFont' ),
    ( IDnum: MUICFG_Textinput_HiliteQuotes                 ;  IDnam: 'MUICFG_Textinput_HiliteQuotes' ),

    ( IDnum: MUICFG_Textinput_KeyCount                     ;  IDnam: 'MUICFG_Textinput_KeyCount' ),
    ( IDnum: MUICFG_Textinput_KeyBase                      ;  IDnam: 'MUICFG_Textinput_KeyBase' ),

    ( IDnum: MUICFG_Textinput_Pens_Inactive_Foreground     ;  IDnam: 'MUICFG_Textinput_Pens_Inactive_Foreground' ),
    ( IDnum: MUICFG_Textinput_Pens_Inactive_Background     ;  IDnam: 'MUICFG_Textinput_Pens_Inactive_Background' ),
    ( IDnum: MUICFG_Textinput_Pens_Active_Foreground       ;  IDnam: 'MUICFG_Textinput_Pens_Active_Foreground' ),
    ( IDnum: MUICFG_Textinput_Pens_Active_Background       ;  IDnam: 'MUICFG_Textinput_Pens_Active_Background' ),
    ( IDnum: MUICFG_Textinput_Pens_Marked_Foreground       ;  IDnam: 'MUICFG_Textinput_Pens_Marked_Foreground' ),
    ( IDnum: MUICFG_Textinput_Pens_Marked_Background       ;  IDnam: 'MUICFG_Textinput_Pens_Marked_Background' ),
    ( IDnum: MUICFG_Textinput_Pens_Cursor_Foreground       ;  IDnam: 'MUICFG_Textinput_Pens_Cursor_Foreground' ),
    ( IDnum: MUICFG_Textinput_Pens_Cursor_Background       ;  IDnam: 'MUICFG_Textinput_Pens_Cursor_Background' ),
    ( IDnum: MUICFG_Textinput_Pens_Style_Foreground        ;  IDnam: 'MUICFG_Textinput_Pens_Style_Foreground' ),
    ( IDnum: MUICFG_Textinput_Pens_Style_Background        ;  IDnam: 'MUICFG_Textinput_Pens_Style_Background' ),
    ( IDnum: MUICFG_Textinput_Pens_URL_Underline           ;  IDnam: 'MUICFG_Textinput_Pens_URL_Underline' ),
    ( IDnum: MUICFG_Textinput_Pens_URL_SelectedUnderline   ;  IDnam: 'MUICFG_Textinput_Pens_URL_SelectedUnderline' ),
    ( IDnum: MUICFG_Textinput_Pens_Misspell_Underline      ;  IDnam: 'MUICFG_Textinput_Pens_Misspell_Underline' ),

    //
    // Nlist (38 entries)
    //
    ( IDnum: MUICFG_NList_Pen_Title           ;     IDnam: 'MUICFG_NList_Pen_Title' ), 
    ( IDnum: MUICFG_NList_Pen_List            ;     IDnam: 'MUICFG_NList_Pen_List' ), 
    ( IDnum: MUICFG_NList_Pen_Select          ;     IDnam: 'MUICFG_NList_Pen_Select' ), 
    ( IDnum: MUICFG_NList_Pen_Cursor          ;     IDnam: 'MUICFG_NList_Pen_Cursor' ), 
    ( IDnum: MUICFG_NList_Pen_UnselCur        ;     IDnam: 'MUICFG_NList_Pen_UnselCur' ), 
    ( IDnum: MUICFG_NList_Pen_Inactive        ;     IDnam: 'MUICFG_NList_Pen_Inactive' ), 

    ( IDnum: MUICFG_NList_BG_Title            ;     IDnam: 'MUICFG_NList_BG_Title' ), 
    ( IDnum: MUICFG_NList_BG_List             ;     IDnam: 'MUICFG_NList_BG_List' ), 
    ( IDnum: MUICFG_NList_BG_Select           ;     IDnam: 'MUICFG_NList_BG_Select' ), 
    ( IDnum: MUICFG_NList_BG_Cursor           ;     IDnam: 'MUICFG_NList_BG_Cursor' ), 
    ( IDnum: MUICFG_NList_BG_UnselCur         ;     IDnam: 'MUICFG_NList_BG_UnselCur' ), 
    ( IDnum: MUICFG_NList_BG_Inactive         ;     IDnam: 'MUICFG_NList_BG_Inactive' ), 

    ( IDnum: MUICFG_NList_Font                ;     IDnam: 'MUICFG_NList_Font' ), 
    ( IDnum: MUICFG_NList_Font_Little         ;     IDnam: 'MUICFG_NList_Font_Little' ), 
    ( IDnum: MUICFG_NList_Font_Fixed          ;     IDnam: 'MUICFG_NList_Font_Fixed' ), 

    ( IDnum: MUICFG_NList_VertInc             ;     IDnam: 'MUICFG_NList_VertInc' ), 
    ( IDnum: MUICFG_NList_DragType            ;     IDnam: 'MUICFG_NList_DragType' ), 
    ( IDnum: MUICFG_NList_MultiSelect         ;     IDnam: 'MUICFG_NList_MultiSelect' ), 

    ( IDnum: MUICFG_NListview_VSB             ;     IDnam: 'MUICFG_NListview_VSB' ), 
    ( IDnum: MUICFG_NListview_HSB             ;     IDnam: 'MUICFG_NListview_HSB' ), 

    ( IDnum: MUICFG_NList_DragQualifier       ;     IDnam: 'MUICFG_NList_DragQualifier' ),   //* OBSOLETE */
    ( IDnum: MUICFG_NList_Smooth              ;     IDnam: 'MUICFG_NList_Smooth' ), 
    ( IDnum: MUICFG_NList_ForcePen            ;     IDnam: 'MUICFG_NList_ForcePen' ), 
    ( IDnum: MUICFG_NList_StackCheck          ;     IDnam: 'MUICFG_NList_StackCheck' ),   //* OBSOLETE */
    ( IDnum: MUICFG_NList_ColWidthDrag        ;     IDnam: 'MUICFG_NList_ColWidthDrag' ), 
    ( IDnum: MUICFG_NList_PartialCol          ;     IDnam: 'MUICFG_NList_PartialCol' ), 
    ( IDnum: MUICFG_NList_List_Select         ;     IDnam: 'MUICFG_NList_List_Select' ), 
    ( IDnum: MUICFG_NList_Menu                ;     IDnam: 'MUICFG_NList_Menu' ), 
    ( IDnum: MUICFG_NList_PartialChar         ;     IDnam: 'MUICFG_NList_PartialChar' ), 
    ( IDnum: MUICFG_NList_PointerColor        ;     IDnam: 'MUICFG_NList_PointerColor' ),   //* OBSOLETE */
    ( IDnum: MUICFG_NList_SerMouseFix         ;     IDnam: 'MUICFG_NList_SerMouseFix' ), 
    ( IDnum: MUICFG_NList_Keys                ;     IDnam: 'MUICFG_NList_Keys' ), 
    ( IDnum: MUICFG_NList_DragLines           ;     IDnam: 'MUICFG_NList_DragLines' ), 
    ( IDnum: MUICFG_NList_VCenteredLines      ;     IDnam: 'MUICFG_NList_VCenteredLines' ), 
    ( IDnum: MUICFG_NList_SelectPointer       ;     IDnam: 'MUICFG_NList_SelectPointer' ), 

    ( IDnum: MUICFG_NList_WheelStep           ;     IDnam: 'MUICFG_NList_WheelStep' ), 
    ( IDnum: MUICFG_NList_WheelFast           ;     IDnam: 'MUICFG_NList_WheelFast' ), 
    ( IDnum: MUICFG_NList_WheelMMB            ;     IDnam: 'MUICFG_NList_WheelMMB' ), 

    //
    // TextEditor (28 entries) = $AD00xxxx
    //
    ( IDnum: MUICFG_TextEditor_Background      ;    IDnam: 'MUICFG_TextEditor_Background' ),
    ( IDnum: MUICFG_TextEditor_BlinkSpeed      ;    IDnam: 'MUICFG_TextEditor_BlinkSpeed' ),
    ( IDnum: MUICFG_TextEditor_BlockQual       ;    IDnam: 'MUICFG_TextEditor_BlockQual' ),
    ( IDnum: MUICFG_TextEditor_CheckWord       ;    IDnam: 'MUICFG_TextEditor_CheckWord' ),
    ( IDnum: MUICFG_TextEditor_CursorColor     ;    IDnam: 'MUICFG_TextEditor_CursorColor' ),
    ( IDnum: MUICFG_TextEditor_CursorTextColor ;    IDnam: 'MUICFG_TextEditor_CursorTextColor' ),
    ( IDnum: MUICFG_TextEditor_CursorWidth     ;    IDnam: 'MUICFG_TextEditor_CursorWidth' ),
    ( IDnum: MUICFG_TextEditor_FixedFont       ;    IDnam: 'MUICFG_TextEditor_FixedFont' ),
    ( IDnum: MUICFG_TextEditor_Frame           ;    IDnam: 'MUICFG_TextEditor_Frame' ),
    ( IDnum: MUICFG_TextEditor_HighlightColor  ;    IDnam: 'MUICFG_TextEditor_HighlightColor' ),
    ( IDnum: MUICFG_TextEditor_MarkedColor     ;    IDnam: 'MUICFG_TextEditor_MarkedColor' ),
    ( IDnum: MUICFG_TextEditor_NormalFont      ;    IDnam: 'MUICFG_TextEditor_NormalFont' ),
    ( IDnum: MUICFG_TextEditor_SetMaxPen       ;    IDnam: 'MUICFG_TextEditor_SetMaxPen' ),
    ( IDnum: MUICFG_TextEditor_Smooth          ;    IDnam: 'MUICFG_TextEditor_Smooth' ),
    ( IDnum: MUICFG_TextEditor_TabSize         ;    IDnam: 'MUICFG_TextEditor_TabSize' ),
    ( IDnum: MUICFG_TextEditor_TextColor       ;    IDnam: 'MUICFG_TextEditor_TextColor' ),
    ( IDnum: MUICFG_TextEditor_UndoSize        ;    IDnam: 'MUICFG_TextEditor_UndoSize' ),
    ( IDnum: MUICFG_TextEditor_TypeNSpell      ;    IDnam: 'MUICFG_TextEditor_TypeNSpell' ),
    ( IDnum: MUICFG_TextEditor_LookupCmd       ;    IDnam: 'MUICFG_TextEditor_LookupCmd' ),
    ( IDnum: MUICFG_TextEditor_SuggestCmd      ;    IDnam: 'MUICFG_TextEditor_SuggestCmd' ),
    ( IDnum: MUICFG_TextEditor_Keybindings     ;    IDnam: 'MUICFG_TextEditor_Keybindings' ),
    ( IDnum: MUICFG_TextEditor_SuggestKey      ;    IDnam: 'MUICFG_TextEditor_SuggestKey' ), //* OBSOLETE! */
    ( IDnum: MUICFG_TextEditor_SeparatorShine  ;    IDnam: 'MUICFG_TextEditor_SeparatorShine' ),
    ( IDnum: MUICFG_TextEditor_SeparatorShadow ;    IDnam: 'MUICFG_TextEditor_SeparatorShadow' ),
    ( IDnum: MUICFG_TextEditor_ConfigVersion   ;    IDnam: 'MUICFG_TextEditor_ConfigVersion' ),
    ( IDnum: MUICFG_TextEditor_InactiveCursor  ;    IDnam: 'MUICFG_TextEditor_InactiveCursor' ),
    ( IDnum: MUICFG_TextEditor_SelectPointer   ;    IDnam: 'MUICFG_TextEditor_SelectPointer' ),
    ( IDnum: MUICFG_TextEditor_InactiveColor   ;    IDnam: 'MUICFG_TextEditor_InactiveColor' ),

    //
    // BetterString (12 entries) = $AD00xxxx
    //
    ( IDnum: MUICFG_BetterString_ActiveBack;        IDNam: 'MUICFG_BetterString_ActiveBack      ' ),
    ( IDnum: MUICFG_BetterString_ActiveText;        IDNam: 'MUICFG_BetterString_ActiveText      ' ),
    ( IDnum: MUICFG_BetterString_InactiveBack;      IDNam: 'MUICFG_BetterString_InactiveBack    ' ),
    ( IDnum: MUICFG_BetterString_InactiveText;      IDNam: 'MUICFG_BetterString_InactiveText    ' ),
    ( IDnum: MUICFG_BetterString_Cursor;            IDNam: 'MUICFG_BetterString_Cursor          ' ),
    ( IDnum: MUICFG_BetterString_MarkedBack;        IDNam: 'MUICFG_BetterString_MarkedBack      ' ),
    ( IDnum: MUICFG_BetterString_MarkedText;        IDNam: 'MUICFG_BetterString_MarkedText      ' ),
    ( IDnum: MUICFG_BetterString_Font;              IDNam: 'MUICFG_BetterString_Font            ' ),
    ( IDnum: MUICFG_BetterString_Frame;             IDNam: 'MUICFG_BetterString_Frame           ' ),
    ( IDnum: MUICFG_BetterString_SelectOnActive;    IDNam: 'MUICFG_BetterString_SelectOnActive  ' ),
    ( IDnum: MUICFG_BetterString_SelectPointer;     IDNam: 'MUICFG_BetterString_SelectPointer   ' ),
    // ( IDnum: MUICFG_BubbleHelp_FirstDelay;          IDNam: 'MUICFG_BubbleHelp_FirstDelay        ' ),

    //
    // HTMLView (23 entries)
    //
    ( IDnum: MUICFG_HTMLview_SmallFont         ; IDnam: 'MUICFG_HTMLview_SmallFont' ),
    ( IDnum: MUICFG_HTMLview_NormalFont        ; IDnam: 'MUICFG_HTMLview_NormalFont' ),
    ( IDnum: MUICFG_HTMLview_FixedFont         ; IDnam: 'MUICFG_HTMLview_FixedFont' ),
    ( IDnum: MUICFG_HTMLview_LargeFont         ; IDnam: 'MUICFG_HTMLview_LargeFont' ),
    ( IDnum: MUICFG_HTMLview_H1                ; IDnam: 'MUICFG_HTMLview_H1' ),
    ( IDnum: MUICFG_HTMLview_H2                ; IDnam: 'MUICFG_HTMLview_H2' ),
    ( IDnum: MUICFG_HTMLview_H3                ; IDnam: 'MUICFG_HTMLview_H3' ),
    ( IDnum: MUICFG_HTMLview_H4                ; IDnam: 'MUICFG_HTMLview_H4' ),
    ( IDnum: MUICFG_HTMLview_H5                ; IDnam: 'MUICFG_HTMLview_H5' ),
    ( IDnum: MUICFG_HTMLview_H6                ; IDnam: 'MUICFG_HTMLview_H6' ),

    ( IDnum: MUICFG_HTMLview_IgnoreDocCols     ; IDnam: 'MUICFG_HTMLview_IgnoreDocCols' ),
    ( IDnum: MUICFG_HTMLview_Col_Background    ; IDnam: 'MUICFG_HTMLview_Col_Background' ),
    ( IDnum: MUICFG_HTMLview_Col_Text          ; IDnam: 'MUICFG_HTMLview_Col_Text' ),
    ( IDnum: MUICFG_HTMLview_Col_Link          ; IDnam: 'MUICFG_HTMLview_Col_Link' ),
    ( IDnum: MUICFG_HTMLview_Col_VLink         ; IDnam: 'MUICFG_HTMLview_Col_VLink' ),
    ( IDnum: MUICFG_HTMLview_Col_ALink         ; IDnam: 'MUICFG_HTMLview_Col_ALink' ),

    ( IDnum: MUICFG_HTMLview_DitherType        ; IDnam: 'MUICFG_HTMLview_DitherType' ),
    ( IDnum: MUICFG_HTMLview_ImageCacheSize    ; IDnam: 'MUICFG_HTMLview_ImageCacheSize' ),

    ( IDnum: MUICFG_HTMLview_PageScrollSmooth  ; IDnam: 'MUICFG_HTMLview_PageScrollSmooth' ),
    ( IDnum: MUICFG_HTMLview_PageScrollKey     ; IDnam: 'MUICFG_HTMLview_PageScrollKey' ),
    ( IDnum: MUICFG_HTMLview_PageScrollMove    ; IDnam: 'MUICFG_HTMLview_PageScrollMove' ),

    ( IDnum: MUICFG_HTMLview_ListItemFile      ; IDnam: 'MUICFG_HTMLview_ListItemFile' ),

    ( IDnum: MUICFG_HTMLview_GammaCorrection   ; IDnam: 'MUICFG_HTMLview_GammaCorrection' ),

    //
    // TheBar  (46 entries)
    //
    ( IDnum: MUICFG_TheBar_GroupBack             ;  IDnam: 'MUICFG_TheBar_GroupBack' ), 
    ( IDnum: MUICFG_TheBar_UseGroupBack          ;  IDnam: 'MUICFG_TheBar_UseGroupBack' ), 
    ( IDnum: MUICFG_TheBar_ButtonBack            ;  IDnam: 'MUICFG_TheBar_ButtonBack' ), 
    ( IDnum: MUICFG_TheBar_UseButtonBack         ;  IDnam: 'MUICFG_TheBar_UseButtonBack' ), 
    ( IDnum: MUICFG_TheBar_FrameShinePen         ;  IDnam: 'MUICFG_TheBar_FrameShinePen' ), 
    ( IDnum: MUICFG_TheBar_FrameShadowPen        ;  IDnam: 'MUICFG_TheBar_FrameShadowPen' ), 
    ( IDnum: MUICFG_TheBar_FrameStyle            ;  IDnam: 'MUICFG_TheBar_FrameStyle' ), 
    ( IDnum: MUICFG_TheBar_DisBodyPen            ;  IDnam: 'MUICFG_TheBar_DisBodyPen' ), 
    ( IDnum: MUICFG_TheBar_DisShadowPen          ;  IDnam: 'MUICFG_TheBar_DisShadowPen' ), 
    ( IDnum: MUICFG_TheBar_BarSpacerShinePen     ;  IDnam: 'MUICFG_TheBar_BarSpacerShinePen' ), 
    ( IDnum: MUICFG_TheBar_BarSpacerShadowPen    ;  IDnam: 'MUICFG_TheBar_BarSpacerShadowPen' ), 
    ( IDnum: MUICFG_TheBar_BarFrameShinePen      ;  IDnam: 'MUICFG_TheBar_BarFrameShinePen' ), 
    ( IDnum: MUICFG_TheBar_BarFrameShadowPen     ;  IDnam: 'MUICFG_TheBar_BarFrameShadowPen' ), 
    ( IDnum: MUICFG_TheBar_DragBarShinePen       ;  IDnam: 'MUICFG_TheBar_DragBarShinePen' ), 
    ( IDnum: MUICFG_TheBar_DragBarShadowPen      ;  IDnam: 'MUICFG_TheBar_DragBarShadowPen' ), 
    ( IDnum: MUICFG_TheBar_DragBarFillPen        ;  IDnam: 'MUICFG_TheBar_DragBarFillPen' ), 
    ( IDnum: MUICFG_TheBar_UseDragBarFillPen     ;  IDnam: 'MUICFG_TheBar_UseDragBarFillPen' ), 

    ( IDnum: MUICFG_TheBar_TextFont              ;  IDnam: 'MUICFG_TheBar_TextFont' ), 
    ( IDnum: MUICFG_TheBar_TextGfxFont           ;  IDnam: 'MUICFG_TheBar_TextGfxFont' ), 

    ( IDnum: MUICFG_TheBar_HorizSpacing          ;  IDnam: 'MUICFG_TheBar_HorizSpacing' ), 
    ( IDnum: MUICFG_TheBar_VertSpacing           ;  IDnam: 'MUICFG_TheBar_VertSpacing' ), 
    ( IDnum: MUICFG_TheBar_BarSpacerSpacing      ;  IDnam: 'MUICFG_TheBar_BarSpacerSpacing' ), 
    ( IDnum: MUICFG_TheBar_HorizInnerSpacing     ;  IDnam: 'MUICFG_TheBar_HorizInnerSpacing' ), 
    ( IDnum: MUICFG_TheBar_TopInnerSpacing       ;  IDnam: 'MUICFG_TheBar_TopInnerSpacing' ), 
    ( IDnum: MUICFG_TheBar_BottomInnerSpacing    ;  IDnam: 'MUICFG_TheBar_BottomInnerSpacing' ), 
    ( IDnum: MUICFG_TheBar_LeftBarFrameSpacing   ;  IDnam: 'MUICFG_TheBar_LeftBarFrameSpacing' ), 
    ( IDnum: MUICFG_TheBar_RightBarFrameSpacing  ;  IDnam: 'MUICFG_TheBar_RightBarFrameSpacing' ), 
    ( IDnum: MUICFG_TheBar_TopBarFrameSpacing    ;  IDnam: 'MUICFG_TheBar_TopBarFrameSpacing' ), 
    ( IDnum: MUICFG_TheBar_BottomBarFrameSpacing ;  IDnam: 'MUICFG_TheBar_BottomBarFrameSpacing' ), 
    ( IDnum: MUICFG_TheBar_HorizTextGfxSpacing   ;  IDnam: 'MUICFG_TheBar_HorizTextGfxSpacing' ), 
    ( IDnum: MUICFG_TheBar_VertTextGfxSpacing    ;  IDnam: 'MUICFG_TheBar_VertTextGfxSpacing' ), 

    ( IDnum: MUICFG_TheBar_Precision             ;  IDnam: 'MUICFG_TheBar_Precision' ), 
    ( IDnum: MUICFG_TheBar_Event                 ;  IDnam: 'MUICFG_TheBar_Event' ), 
    ( IDnum: MUICFG_TheBar_Scale                 ;  IDnam: 'MUICFG_TheBar_Scale' ), 
    ( IDnum: MUICFG_TheBar_SpecialSelect         ;  IDnam: 'MUICFG_TheBar_SpecialSelect' ), 
    ( IDnum: MUICFG_TheBar_TextOverUseShine      ;  IDnam: 'MUICFG_TheBar_TextOverUseShine' ), 
    ( IDnum: MUICFG_TheBar_IgnoreSelImages       ;  IDnam: 'MUICFG_TheBar_IgnoreSelImages' ), 
    ( IDnum: MUICFG_TheBar_IgnoreDisImages       ;  IDnam: 'MUICFG_TheBar_IgnoreDisImages' ), 
    ( IDnum: MUICFG_TheBar_DisMode               ;  IDnam: 'MUICFG_TheBar_DisMode' ), 
    ( IDnum: MUICFG_TheBar_DontMove              ;  IDnam: 'MUICFG_TheBar_DontMove' ), 
    ( IDnum: MUICFG_TheBar_Gradient              ;  IDnam: 'MUICFG_TheBar_Gradient' ), 
    ( IDnum: MUICFG_TheBar_NtRaiseActive         ;  IDnam: 'MUICFG_TheBar_NtRaiseActive' ), 
    ( IDnum: MUICFG_TheBar_SpacersSize           ;  IDnam: 'MUICFG_TheBar_SpacersSize' ), 
    ( IDnum: MUICFG_TheBar_Appearance            ;  IDnam: 'MUICFG_TheBar_Appearance' ), 

    ( IDnum: MUICFG_TheBar_Frame                 ;  IDnam: 'MUICFG_TheBar_Frame' ), 
    ( IDnum: MUICFG_TheBar_ButtonFrame           ;  IDnam: 'MUICFG_TheBar_ButtonFrame' ), 

    //
    // NListtree (11+1 entries) = $FEC8xxxx
    //
    ( IDnum: MUICFG_NListtree_ImageSpecClosed;      IDnam: 'MUICFG_NListtree_ImageSpecClosed' ),
    ( IDnum: MUICFG_NListtree_ImageSpecOpen;        IDnam: 'MUICFG_NListtree_ImageSpecOpen'   ), 
    ( IDnum: MUICFG_NListtree_ImageSpecFolder;      IDnam: 'MUICFG_NListtree_ImageSpecFolder' ), 
    ( IDnum: MUICFG_NListtree_PenSpecLines;         IDnam: 'MUICFG_NListtree_PenSpecLines'    ),
    ( IDnum: MUICFG_NListtree_PenSpecShadow;        IDnam: 'MUICFG_NListtree_PenSpecShadow'   ),
    ( IDnum: MUICFG_NListtree_PenSpecGlow;          IDnam: 'MUICFG_NListtree_PenSpecGlow'     ),
    ( IDnum: MUICFG_NListtree_RememberStatus;       IDnam: 'MUICFG_NListtree_RememberStatus'  ),
    ( IDnum: MUICFG_NListtree_IndentWidth;          IDnam: 'MUICFG_NListtree_IndentWidth'     ),
    ( IDnum: MUICFG_NListtree_Unknown1;             IDnam: 'MUICFG_NListtree_???????????????' ),
    ( IDnum: MUICFG_NListtree_OpenAutoScroll;       IDnam: 'MUICFG_NListtree_OpenAutoScroll'  ),
    ( IDnum: MUICFG_NListtree_LineType;             IDnam: 'MUICFG_NListtree_LineType'        ),
    ( IDnum: MUICFG_NListtree_UseFolderImage;       IDnam: 'MUICFG_NListtree_UseFolderImage'  ),

    //
    // ToolBar ( 22 entries )
    //
    ( IDnum:  MUICFG_Toolbar_ToolbarLook            ; IDnam: 'MUICFG_Toolbar_ToolbarLook' ),
    ( IDnum:  MUICFG_Toolbar_Separator              ; IDnam: 'MUICFG_Toolbar_Separator' ),
    ( IDnum:  MUICFG_Toolbar_FrameSpec              ; IDnam: 'MUICFG_Toolbar_FrameSpec' ),

    ( IDnum:  MUICFG_Toolbar_GroupSpace             ; IDnam: 'MUICFG_Toolbar_GroupSpace' ),
    ( IDnum:  MUICFG_Toolbar_GroupSpace_Max         ; IDnam: 'MUICFG_Toolbar_GroupSpace_Max' ),
    ( IDnum:  MUICFG_Toolbar_GroupSpace_Min         ; IDnam: 'MUICFG_Toolbar_GroupSpace_Min' ),
    ( IDnum:  MUICFG_Toolbar_ToolSpace              ; IDnam: 'MUICFG_Toolbar_ToolSpace' ),
    ( IDnum:  MUICFG_Toolbar_ImageTextSpace         ; IDnam: 'MUICFG_Toolbar_ImageTextSpace' ),

    ( IDnum:  MUICFG_Toolbar_InnerSpace_Text        ; IDnam: 'MUICFG_Toolbar_InnerSpace_Text' ),
    ( IDnum:  MUICFG_Toolbar_InnerSpace_NoText      ; IDnam: 'MUICFG_Toolbar_InnerSpace_NoText' ),
    //* Graphics */
    ( IDnum:  MUICFG_Toolbar_Precision              ; IDnam: 'MUICFG_Toolbar_Precision' ),
    ( IDnum:  MUICFG_Toolbar_GhostEffect            ; IDnam: 'MUICFG_Toolbar_GhostEffect' ),
    ( IDnum:  MUICFG_Toolbar_UseImages              ; IDnam: 'MUICFG_Toolbar_UseImages' ),
    //* Text */
    ( IDnum:  MUICFG_Toolbar_Placement              ; IDnam: 'MUICFG_Toolbar_Placement' ),
    ( IDnum:  MUICFG_Toolbar_ToolFont               ; IDnam: 'MUICFG_Toolbar_ToolFont' ),
    ( IDnum:  MUICFG_Toolbar_ToolPen                ; IDnam: 'MUICFG_Toolbar_ToolPen' ),

    ( IDnum:  MUICFG_Toolbar_Background_Normal      ; IDnam: 'MUICFG_Toolbar_Background_Normal' ),
    ( IDnum:  MUICFG_Toolbar_Background_Selected    ; IDnam: 'MUICFG_Toolbar_Background_Selected' ),
    ( IDnum:  MUICFG_Toolbar_Background_Ghosted     ; IDnam: 'MUICFG_Toolbar_Background_Ghosted' ),
    //* Border Type*/
    ( IDnum:  MUICFG_Toolbar_BorderType             ; IDnam: 'MUICFG_Toolbar_BorderType' ),
    //* Selection Mode */
    ( IDnum:  MUICFG_Toolbar_SelectionMode          ; IDnam: 'MUICFG_Toolbar_SelectionMode' ),
    //* AutoActive */
    ( IDnum:  MUICFG_Toolbar_AutoActive             ; IDnam: 'MUICFG_Toolbar_AutoActive' ),

    //
    // UrlText (20 entries) = 
    //   
    ( IDnum: MUICFG_Urltext_MouseOutPen    ;        IDnam: 'MUICFG_Urltext_MouseOutPen' ), 
    ( IDnum: MUICFG_Urltext_MouseOverPen   ;        IDnam: 'MUICFG_Urltext_MouseOverPen' ), 
    ( IDnum: MUICFG_Urltext_VisitedPen     ;        IDnam: 'MUICFG_Urltext_VisitedPen' ), 
    ( IDnum: MUICFG_Urltext_MouseOver      ;        IDnam: 'MUICFG_Urltext_MouseOver' ), 
    ( IDnum: MUICFG_Urltext_PUnderline     ;        IDnam: 'MUICFG_Urltext_PUnderline' ), 
    ( IDnum: MUICFG_Urltext_PDoVisitedPen  ;        IDnam: 'MUICFG_Urltext_PDoVisitedPen' ), 
    ( IDnum: MUICFG_Urltext_PFallBack      ;        IDnam: 'MUICFG_Urltext_PFallBack' ), 

    ( IDnum: MUICFG_Urltext_Url            ;        IDnam: 'MUICFG_Urltext_Url' ), 
    ( IDnum: MUICFG_Urltext_Text           ;        IDnam: 'MUICFG_Urltext_Text' ), 
    ( IDnum: MUICFG_Urltext_Active         ;        IDnam: 'MUICFG_Urltext_Active' ), 
    ( IDnum: MUICFG_Urltext_Visited        ;        IDnam: 'MUICFG_Urltext_Visited' ), 
    ( IDnum: MUICFG_Urltext_Underline      ;        IDnam: 'MUICFG_Urltext_Underline' ), 
    ( IDnum: MUICFG_Urltext_FallBack       ;        IDnam: 'MUICFG_Urltext_FallBack' ), 
    ( IDnum: MUICFG_Urltext_DoVisitedPen   ;        IDnam: 'MUICFG_Urltext_DoVisitedPen' ), 
    ( IDnum: MUICFG_Urltext_SetMax         ;        IDnam: 'MUICFG_Urltext_SetMax' ), 
    ( IDnum: MUICFG_Urltext_DoOpenURL      ;        IDnam: 'MUICFG_Urltext_DoOpenURL' ), 
    ( IDnum: MUICFG_Urltext_NoMenu         ;        IDnam: 'MUICFG_Urltext_NoMenu' ), 

    ( IDnum: MUICFG_Urltext_Font           ;        IDnam: 'MUICFG_Urltext_Font' ), 
    ( IDnum: MUICFG_Urltext_Version        ;        IDnam: 'MUICFG_Urltext_Version' ), 

    ( IDnum: MUICFG_Urltext_NoOpenURLPrefs ;        IDnam: 'MUICFG_Urltext_NoOpenURLPrefs' ), 

    //
    // end tag
    //
    ( IDnum: $FFFFFFFF; IDNam: 'MUICFG_Invalid                  ' )
  );


Const
  CHUNKID_MUIC  = 'MUIC';

Type
  PPREF_MUIConfig = ^TPREF_MUIConfig;
  PREF_MUIConfig = packed
  record
    parent          : PIFF_Group;
    
    chunkId         : TIFF_ID;
    chunkSize       : TIFF_Long;

    chunkData       : PIFF_Byte;
  end;
  TPREF_MUIConfig = PREF_MUIConfig;


function  PREF_createMUIConfig: PPREF_MUIConfig;
begin
  result := PPREF_MUIConfig(IFF_allocateChunk(CHUNKID_MUIC, sizeof(TPREF_MUIConfig)));
end;


function  PREF_readMUIConfig(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk; 
begin
  result := PIFF_Chunk(IFF_readRawChunk(filehandle, CHUNKID_MUIC, chunkSize));
end;


function  PREF_writeMUIConfig(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeRawChunk(filehandle, PIFF_RawChunk(chunk));
end;


function  PREF_checkMUIConfig(const chunk: PIFF_Chunk): cint;
begin
  // no idea what would be needed to check here. The dimensions perhaps ?
  result := _TRUE_;
end;


procedure PREF_freeMUIConfig(chunk: PIFF_Chunk);
begin
  IFF_freeRawChunk(PIFF_RawChunk(chunk));
end;


// we need this on platforms that does not allow (or penalize)
// reading on odd addresses.
Function GetTIFF_ULong(p: PByte): TIFF_ULong;
type
  TLongBytes = packed array[0..3] of byte;
var 
  i : integer;
begin
  For i := 0 to Pred(SizeOf(Result)) do 
  begin
    TLongBytes(Result)[i] := p^;
    inc(p);
  end;
  Result := BEtoN(Result);
end;


// convert an GUICFG_ID into a textual representation by searching
// through table. Can return invalid if not listed in the table.
function MUICID2string(ID: LongWord): String;
var i: integer;
begin
  Result := '<unrecognized>';
  for i := low(IDList) to High(IDList) do
  begin
    if IDList[i].IDnum = ID then
    begin
      Result := IDList[i].IDnam;
      break;
    end;
  end;
end;


procedure PREF_printMUIConfig(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  MUIConfig : PPREF_MUIConfig;
  i, j      : cuint;
  byt       : TIFF_Byte;

  LBytes    : packed Array[0..3] of Byte;

  CFG_ID    : TIFF_ULong;
  CFG_Len   : TIFF_ULong;
begin
  MUIConfig := PPREF_MUIConfig(chunk);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'values = ' + LineEnding);

  i := 0;
  while true do
  begin
    // read the id + length of data
    If ( (i + 8) < MUIConfig^.chunkSize) then
    begin
      CFG_ID  := GetTIFF_ULong(@MUIConfig^.chunkData[i]);
      inc(i, 4);

      CFG_Len := GetTIFF_ULong(@MUIConfig^.chunkData[i]);
      inc(i, 4);

      IFF_printIndent(GetStdOutHandle, indentLevel + 1, '');
//      Write('ID$ = ', MUICID2string(CFG_ID), '  ID = (', HexStr(CFG_ID, 8), ')/(', CFG_Len, ')');
      Write('  ID [0x', HexStr(CFG_ID, 8), ', ', CFG_Len:3, '] = ', MUICID2string(CFG_ID) );
    
    end
    else break; 
    // print the actual data
    If ( (i + CFG_Len) < MUIConfig^.chunkSize) then
    begin    
      j := 0;
      while (j < CFG_Len) do
      begin
        // just skip the actual data for now
        inc(j);
      end;
      WriteLn;
      // update global index accordingly to bytes that have been 'read'
      inc(i, CFG_Len);
    end
    else break;
  end;
  
  WriteLn;
  IFF_printIndent(GetStdOutHandle, indentLevel, ';' + LineEnding);
end;


function  PREF_compareMUIConfig(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compareRawChunk(PIFF_RawChunk(chunk1), PIFF_RawChunk(chunk2));
end;



//////////////////////////////////////////////////////////////////////////////
//        font.pas
//////////////////////////////////////////////////////////////////////////////

Const
  FONTNAMESIZE      = (128);

  CHUNKID_FONT      = 'FONT';

Type
(*
struct TextAttr {
    STRPTR  ta_Name;		/* name of the font */
    UWORD   ta_YSize;		/* height of the font */
    UBYTE   ta_Style;		/* intrinsic font style */
    UBYTE   ta_Flags;		/* font preferences and flags */
};


/*------ Font Styles ------------------------------------------------*/
#define	FS_NORMAL	0	/* normal text (no style bits set) */
#define	FSB_UNDERLINED	0	/* underlined (under baseline) */
#define	FSF_UNDERLINED	0x01
#define	FSB_BOLD	1	/* bold face text (ORed w/ shifted) */
#define	FSF_BOLD	0x02
#define	FSB_ITALIC	2	/* italic (slanted 1:2 right) */
#define	FSF_ITALIC	0x04
#define	FSB_EXTENDED	3	/* extended face (wider than normal) */
#define	FSF_EXTENDED	0x08

#define	FSB_COLORFONT	6	/* this uses ColorTextFont structure */
#define	FSF_COLORFONT	0x40
#define	FSB_TAGGED	7	/* the TextAttr is really an TTextAttr, */
#define	FSF_TAGGED	0x80

/*------ Font Flags -------------------------------------------------*/
#define	FPB_ROMFONT	0	/* font is in rom */
#define	FPF_ROMFONT	0x01
#define	FPB_DISKFONT	1	/* font is from diskfont.library */
#define	FPF_DISKFONT	0x02
#define	FPB_REVPATH	2	/* designed path is reversed (e.g. left) */
#define	FPF_REVPATH	0x04
#define	FPB_TALLDOT	3	/* designed for hires non-interlaced */
#define	FPF_TALLDOT	0x08
#define	FPB_WIDEDOT	4	/* designed for lores interlaced */
#define	FPF_WIDEDOT	0x10
#define	FPB_PROPORTIONAL 5	/* character sizes can vary from nominal */
#define	FPF_PROPORTIONAL 0x20
#define	FPB_DESIGNED	6	/* size explicitly designed, not constructed */
				/* note: if you do not set this bit in your */
				/* textattr, then a font may be constructed */
				/* for you by scaling an existing rom or disk */
				/* font (under V36 and above). */
#define	FPF_DESIGNED	0x40
    /* bit 7 is always clear for fonts on the graphics font list */
#define	FPB_REMOVED	7	/* the font has been removed */
#define	FPF_REMOVED	(1<<7)
*)
  TTextAttr = packed 
  record
    ta_Name         : pointer;
    ta_YSize        : TIFF_UWord;
    ta_Style        : TIFF_UByte;
    ta_Flags        : TIFF_UByte;
  end;

(*
/* constants for FontPrefs.fp_Type */
#define FP_WBFONT     0
#define FP_SYSFONT    1
#define FP_SCREENFONT 2
*)

  TFontPrefs = packed
  record
    fp_Reserved     : packed array[0..Pred(3)] of TIFF_Long;
    fp_Reserved2    : TIFF_UWord;
    fp_Type         : TIFF_UWord;
    fp_FrontPen     : TIFF_UByte;
    fp_BackPen      : TIFF_UByte;
    fp_DrawMode     : TIFF_UByte;
    pad1            : TIFF_UByte;
    fp_TextAttr     : TTextAttr;
    fp_Name         : packed array[0..Pred(FONTNAMESIZE)] of char;
  end;

Type
  PPREF_FontPrefs = ^TPREF_FontPrefs;
  PREF_FontPrefs = packed
  record
    parent          : PIFF_Group;
    
    chunkId         : TIFF_ID;
    chunkSize       : TIFF_Long;

    data            : TFontPrefs;
  end;
  TPREF_FontPrefs = PREF_FontPrefs;


function  PREF_createFontPrefs: PPREF_FontPrefs;
var
  FontPrefs : PPREF_FontPrefs;
begin
  FontPrefs := PPREF_FontPrefs(IFF_allocateChunk(CHUNKID_FONT, sizeof(TPREF_FontPrefs)));
  // FontPrefs := PPREF_FontPrefs(IFF_allocateChunk(CHUNKID_FONT, 156));
    
  if (FontPrefs <> nil) then
  begin
    FontPrefs^.chunkSize := sizeof(FontPrefs^.data);
    // do i need to zero out every field manuallly ?
  end;
    
  result := FontPrefs;
end;


function  PREF_readFontPrefs(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk; 
var
  FontPrefs  : PPREF_FontPrefs;
  i          : cuint;
  //  byt        : Byte;
begin
  FontPrefs := PREF_createFontPrefs();
    
  if (FontPrefs <> nil) then
  begin
    if notvalid(IFF_readULong(filehandle, @FontPrefs^.Data.fp_Reserved[0], CHUNKID_FONT, 'fp_Reserved[0]')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;
    if notvalid(IFF_readULong(filehandle, @FontPrefs^.Data.fp_Reserved[1], CHUNKID_FONT, 'fp_Reserved[1]')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;
    if notvalid(IFF_readULong(filehandle, @FontPrefs^.Data.fp_Reserved[2], CHUNKID_FONT, 'fp_Reserved[2]')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @FontPrefs^.Data.fp_Reserved2, CHUNKID_FONT, 'fp_Reserved2')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @FontPrefs^.Data.fp_Type, CHUNKID_FONT, 'fp_Type')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.fp_FrontPen, CHUNKID_FONT, 'fp_FrontPen')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.fp_BackPen, CHUNKID_FONT, 'fp_BackPen')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;
    
    if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.fp_DrawMode, CHUNKID_FONT, 'fp_DrawMode')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.Pad1, CHUNKID_FONT, 'Pad1')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readULong(filehandle, @FontPrefs^.Data.fp_TextAttr.ta_Name, CHUNKID_FONT, 'fp_TextAttr.ta_Name')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @FontPrefs^.Data.fp_TextAttr.ta_YSize, CHUNKID_FONT, 'fp_TextAttr.ta_YSize')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.fp_TextAttr.ta_Style, CHUNKID_FONT, 'fp_TextAttr.ta_Style')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.fp_TextAttr.ta_Flags, CHUNKID_FONT, 'fp_TextAttr.ta_Flags')) then
    begin
      PREF_free(PIFF_Chunk(FontPrefs));
      exit(nil);
    end;

    for i := low(FontPrefs^.Data.fp_Name) to high(FontPrefs^.Data.fp_Name) do
    begin
      if notvalid(IFF_readUByte(filehandle, @FontPrefs^.Data.fp_Name[i], CHUNKID_FONT, PChar('fp_Name[' + IntToStr(i) + ']'))) then
      begin
        PREF_free(PIFF_Chunk(FontPrefs));
        exit(nil);
      end;
    end;

  end;
  result := PIFF_Chunk(FontPrefs);
end;


function  PREF_writeFontPrefs(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  FontPrefs : PPREF_FontPrefs;
begin
  FontPrefs := PPREF_FontPrefs(chunk);

  {$WARNING TODO}
  (*    
  if notvalid(IFF_writeULong(filehandle, FontPrefs^.fieldname, CHUNKID_FONT, 'fieldname'))
  then exit(_FALSE_);

  < repeat for every field in the structure >

    fp_Reserved     : packed array[0..Pred(3)] of TIFF_Long;
    fp_Reserved2    : TIFF_UWord;
    fp_Type         : TIFF_UWord;
    fp_FrontPen     : TIFF_UByte;
    fp_BackPen      : TIFF_UByte;
    fp_DrawMode     : TIFF_UByte;
    fp_TextAttr     : TTextAttr;
    fp_Name         : packed array[0..Pred(FONTNAMESIZE)] of char;

    ta_Name         : pointer;
    ta_YSize        : TIFF_UWord;
    ta_Style        : TIFF_UByte
    ta_Flags        : TIFF_UByte
  *)

  result := _TRUE_;
end;


function  PREF_checkFontPrefs(const chunk: PIFF_Chunk): cint;
begin
  // no idea what would be needed to check here. The dimensions perhaps ?
  result := _TRUE_;
end;


procedure PREF_freeFontPrefs(chunk: PIFF_Chunk);
begin
  { intentionally left blank becauae ScreenModePrefs was allocated with allocatechunk ? }
end;


procedure PREF_printFontPrefs(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  FontPrefs : PPREF_FontPrefs;
  i : cuint;
  S : String;
begin
  FontPrefs := PPREF_FontPrefs(chunk);
    
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_Reserved[0]       = %u;' + LineEnding, [FontPrefs^.Data.fp_Reserved[0]]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_Reserved[1]       = %u;' + LineEnding, [FontPrefs^.Data.fp_Reserved[1]]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_Reserved[2]       = %u;' + LineEnding, [FontPrefs^.Data.fp_Reserved[2]]);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_Reserved2         = %u;' + LineEnding, [FontPrefs^.Data.fp_Reserved2]);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_Type              = %u;' + LineEnding, [FontPrefs^.Data.fp_Type]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_FrontPen          = %u;' + LineEnding, [FontPrefs^.Data.fp_FrontPen]);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_BackPen           = %u;' + LineEnding, [FontPrefs^.Data.fp_BackPen]);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_DrawMode          = %u;' + LineEnding, [FontPrefs^.Data.fp_DrawMode]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'Pad1                 = %u;' + LineEnding, [FontPrefs^.Data.Pad1]);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_TextAttr.ta_Name  = %p;' + LineEnding, [FontPrefs^.Data.fp_TextAttr.ta_Name]);

  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_TextAttr.ta_YSize = %u;' + LineEnding, [FontPrefs^.Data.fp_TextAttr.ta_YSize]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_TextAttr.ta_Style = %u;' + LineEnding, [FontPrefs^.Data.fp_TextAttr.ta_Style]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_TextAttr.ta_Flags = %u;' + LineEnding, [FontPrefs^.Data.fp_TextAttr.ta_Flags]);

  S := '';
  for i := Low(FontPrefs^.Data.fp_Name) to High(FontPrefs^.Data.fp_Name) do
  begin
    if FontPrefs^.Data.fp_Name[i] = #0 then break;
    S := S + FontPrefs^.Data.fp_Name[i];
  end;
  If not(Length(S) > 0) then S := '<empty>';
  IFF_printIndent(GetStdOutHandle, indentLevel, 'fp_Name              = %s;' + LineEnding , [S]);

end;


function  PREF_compareFontPrefs(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  FontPrefs1 : PPREF_FontPrefs;
  FontPrefs2 : PPREF_FontPrefs;
begin
  FontPrefs1 := PPREF_FontPrefs(chunk1);
  FontPrefs2 := PPREF_FontPrefs(chunk2);
  {$WARNING TODO}
  // reserved items intentionally left out of comparison
    
  //  if (FontPrefs^.fieldname   <> FontPrefs2^.fieldname) then exit(_FALSE_);

  //  < repeat for every field in the structure >

  Result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        screenmode.pas
//////////////////////////////////////////////////////////////////////////////



Const
  CHUNKID_SCRM = 'SCRM';


Type
  PPREF_ScreenModePrefs = ^TPREF_ScreenModePrefs;
  PREF_ScreenModePrefs = 
  record
    parent          : PIFF_Group;
    
    chunkId         : TIFF_ID;
    chunkSize       : TIFF_Long;
    
    smp_Reserved    : Array[0..Pred(4)] of TIFF_ULong;
    smp_DisplayID   : TIFF_ULong;
    smp_Width       : TIFF_UWord;
    smp_Height      : TIFF_UWord;
    smp_Depth       : TIFF_UWord;
    smp_Control     : TIFF_UWord;
  end;
  TPREF_ScreenModePrefs = PREF_ScreenModePrefs;


function  PREF_createScreenModePrefs: PPREF_ScreenModePrefs;
var
  screenModePrefs : PPREF_ScreenModePrefs;
begin
  screenModePrefs := PPREF_ScreenModePrefs(IFF_allocateChunk(CHUNKID_SCRM, sizeof(TPREF_ScreenModePrefs)));
    
  if (screenModePrefs <> nil) then
  begin
    ScreenModePrefs^.chunkSize := sizeof(ScreenModePrefs^.smp_Reserved) + sizeof(ScreenModePrefs^.smp_DisplayID) + sizeof(ScreenModePrefs^.smp_Width) + sizeof(ScreenModePrefs^.smp_Height) + sizeof(ScreenModePrefs^.smp_Depth) + sizeof(ScreenModePrefs^.smp_Control);
    // do i need to zero out every field manuallly ?
  end;
    
  result := screenModePrefs;
end;


function  PREF_readScreenModePrefs(filehandle: THandle; const chunkSize: TIFF_Long): PIFF_Chunk; 
var
  screenModePrefs  : PPREF_ScreenModePrefs;
begin
  screenModePrefs := PREF_createScreenModePrefs();
    
  if (screenModePrefs <> nil) then
  begin
    if notvalid(IFF_readULong(filehandle, @screenModePrefs^.smp_Reserved[0], CHUNKID_SCRM, 'smp_Reserved[0]')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;
    if notvalid(IFF_readULong(filehandle, @screenModePrefs^.smp_Reserved[1], CHUNKID_SCRM, 'smp_Reserved[1]')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;
    if notvalid(IFF_readULong(filehandle, @screenModePrefs^.smp_Reserved[2], CHUNKID_SCRM, 'smp_Reserved[2]')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;
    if notvalid(IFF_readULong(filehandle, @screenModePrefs^.smp_Reserved[3], CHUNKID_SCRM, 'smp_Reserved[3]')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;
    
    if notvalid(IFF_readULong(filehandle, @screenModePrefs^.smp_DisplayID, CHUNKID_SCRM, 'smp_DisplayID')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @screenModePrefs^.smp_Width, CHUNKID_SCRM, 'smp_Width')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @screenModePrefs^.smp_Height, CHUNKID_SCRM, 'smp_Height')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @screenModePrefs^.smp_Depth, CHUNKID_SCRM, 'smp_Depth')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;

    if notvalid(IFF_readUWord(filehandle, @screenModePrefs^.smp_Control, CHUNKID_SCRM, 'smp_Control')) then
    begin
      PREF_free(PIFF_Chunk(screenModePrefs));
      exit(nil);
    end;

  end;

  result := PIFF_Chunk(screenModePrefs);
end;


function  PREF_writeScreenModePrefs(filehandle: THandle; const chunk: PIFF_Chunk): cint;
var
  screenModePrefs : PPREF_ScreenModePrefs;
begin
  screenModePrefs := PPREF_ScreenModePrefs(chunk);
    
  if notvalid(IFF_writeULong(filehandle, screenModePrefs^.smp_Reserved[0], CHUNKID_SCRM, 'smp_Reserved[0]'))
  then exit(_FALSE_);
  if notvalid(IFF_writeULong(filehandle, screenModePrefs^.smp_Reserved[1], CHUNKID_SCRM, 'smp_Reserved[1]'))
  then exit(_FALSE_);
  if notvalid(IFF_writeULong(filehandle, screenModePrefs^.smp_Reserved[2], CHUNKID_SCRM, 'smp_Reserved[2]'))
  then exit(_FALSE_);
  if notvalid(IFF_writeULong(filehandle, screenModePrefs^.smp_Reserved[3], CHUNKID_SCRM, 'smp_Reserved[3]'))
  then exit(_FALSE_);

  if notvalid(IFF_writeULong(filehandle, screenModePrefs^.smp_DisplayID, CHUNKID_SCRM, 'smp_DisplayID'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, screenModePrefs^.smp_Width, CHUNKID_SCRM, 'smp_Width'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, screenModePrefs^.smp_Height, CHUNKID_SCRM, 'smp_Height'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, screenModePrefs^.smp_Depth, CHUNKID_SCRM, 'smp_Depth'))
  then exit(_FALSE_);

  if notvalid(IFF_writeUWord(filehandle, screenModePrefs^.smp_Control, CHUNKID_SCRM, 'smp_Control'))
  then exit(_FALSE_);

  result := _TRUE_;
end;


function  PREF_checkScreenModePrefs(const chunk: PIFF_Chunk): cint;
begin
  // no idea what would be needed to check here. The dimensions perhaps ?
  result := _TRUE_;
end;


procedure PREF_freeScreenModePrefs(chunk: PIFF_Chunk);
begin
  { intentionally left blank becauae ScreenModePrefs was allocated with allocatechunk ? }
end;


procedure PREF_printScreenModePrefs(const chunk: PIFF_Chunk; const indentLevel: cuint);
var
  screenModePrefs : PPREF_ScreenModePrefs;
begin
  screenModePrefs := PPREF_ScreenModePrefs(chunk);
    
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Reserved[0] = %u;' + LineEnding , [ScreenModePrefs^.smp_Reserved[0]]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Reserved[1] = %u;' + LineEnding , [ScreenModePrefs^.smp_Reserved[1]]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Reserved[2] = %u;' + LineEnding , [ScreenModePrefs^.smp_Reserved[2]]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Reserved[3] = %u;' + LineEnding , [ScreenModePrefs^.smp_Reserved[3]]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_DisplayID   = %u;' + LineEnding , [ScreenModePrefs^.smp_Width]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Width       = %u;' + LineEnding , [ScreenModePrefs^.smp_Width]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Height      = %u;' + LineEnding , [ScreenModePrefs^.smp_Height]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Depth       = %u;' + LineEnding , [ScreenModePrefs^.smp_Depth]);
  IFF_printIndent(GetStdOutHandle, indentLevel, 'smp_Control     = %u;' + LineEnding , [ScreenModePrefs^.smp_Control]);
end;


function  PREF_compareScreenModePrefs(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
var
  screenModePrefs1 : PPREF_ScreenModePrefs;
  screenModePrefs2 : PPREF_ScreenModePrefs;
begin
  screenModePrefs1 := PPREF_ScreenModePrefs(chunk1);
  screenModePrefs2 := PPREF_ScreenModePrefs(chunk2);

  // reserved items intentionally left out of comparison
   
  if (screenModePrefs1^.smp_DisplayID   <> screenModePrefs2^.smp_DisplayID) then exit(_FALSE_);

  if (screenModePrefs1^.smp_Width       <> screenModePrefs2^.smp_Width)     then exit(_FALSE_);
  if (screenModePrefs1^.smp_Height      <> screenModePrefs2^.smp_Height)    then exit(_FALSE_);
  if (screenModePrefs1^.smp_Depth       <> screenModePrefs2^.smp_Depth)     then exit(_FALSE_);
  if (screenModePrefs1^.smp_Control     <> screenModePrefs2^.smp_Control)   then exit(_FALSE_);

  Result := _TRUE_;
end;



//////////////////////////////////////////////////////////////////////////////
//        prefs.pas
//////////////////////////////////////////////////////////////////////////////



const
  PREF_NUM_OF_FORM_TYPES       =  1;
  PREF_NUM_OF_EXTENSION_CHUNKS  = 3;

  prefids : array[0..Pred(PREF_NUM_OF_EXTENSION_CHUNKS)] of TIFF_ID =
  (
   'FONT', 'MUIC', 'SCRM'
  );

  prefFormExtension : Array[0..Pred(PREF_NUM_OF_EXTENSION_CHUNKS)] of TIFF_FormExtension =
  (
    ( chunkId : @prefids[0]; readchunk: @PREF_readFontPrefs;       writechunk: @PREF_writeFontPrefs;       checkchunk: @PREF_checkFontPrefs;       freeChunk: @PREF_freeFontPrefs;       printChunk: @PREF_printFontPrefs;       compareChunk: @PREF_compareFontPrefs ),
    ( chunkId : @prefids[1]; readchunk: @PREF_readMUIConfig;       writechunk: @PREF_writeMUIConfig;       checkchunk: @PREF_checkMUIConfig;       freeChunk: @PREF_freeMUIConfig;       printChunk: @PREF_printMUIConfig;       compareChunk: @PREF_compareMUIConfig ),
    ( chunkId : @prefids[2]; readchunk: @PREF_readScreenModePrefs; writechunk: @PREF_writeScreenModePrefs; checkchunk: @PREF_checkScreenModePrefs; freeChunk: @PREF_freeScreenModePrefs; printChunk: @PREF_printScreenModePrefs; compareChunk: @PREF_compareScreenModePrefs )
  );

  prefft : array[0..Pred(PREF_NUM_OF_FORM_TYPES)] of TIFF_ID =
  (
    'PREF'
  );

  extension : Array[0..Pred(PREF_NUM_OF_FORM_TYPES)] of TIFF_Extension =
  (
    ( formType : @prefft[0]; formExtensionsLength: PREF_NUM_OF_EXTENSION_CHUNKS; formExtensions: @prefFormExtension)
  );



function  PREF_read(const filename: PChar): PIFF_Chunk;
begin
  result := IFF_read(filename, extension, PREF_NUM_OF_FORM_TYPES);
end;


function  PREF_readFd(filehandle: THandle): PIFF_Chunk;
begin
  result := IFF_readFd(filehandle, extension, PREF_NUM_OF_FORM_TYPES);
end;


function  PREF_writeFd(filehandle: THandle; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_writeFd(filehandle, chunk, extension, PREF_NUM_OF_FORM_TYPES);
end;


function  PREF_write(const filename: PChar; const chunk: PIFF_Chunk): cint;
begin
  result := IFF_write(filename, chunk, extension, PREF_NUM_OF_FORM_TYPES);
end;


function  PREF_check(const chunk: PIFF_Chunk): cint;
begin
  result := IFF_check(chunk, extension, PREF_NUM_OF_FORM_TYPES);
end;


procedure PREF_free(chunk: PIFF_Chunk);
begin
  IFF_free(chunk, extension, PREF_NUM_OF_FORM_TYPES);
end;


procedure PREF_print(const chunk: PIFF_Chunk; const indentLevel: cuint);
begin
  IFF_print(chunk, 0, extension, PREF_NUM_OF_FORM_TYPES);
end;


function  PREF_compare(const chunk1: PIFF_Chunk; const chunk2: PIFF_Chunk): cint;
begin
  result := IFF_compare(chunk1, chunk2, extension, PREF_NUM_OF_FORM_TYPES);
end;


end.
