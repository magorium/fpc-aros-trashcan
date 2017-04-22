unit libpref_muicfg_tags;

{$MODE OBJFPC}{$H+}

{
  Current inclusions:
  classname         Serial      Tagbase     classbase   url
  ===========================================================================
  Textinput         $051B       $851B0000   $0712       https://github.com/amiga-mui
  NList             $1D51       $9D510000   0           https://github.com/amiga-mui
  TextEditor        $2D00       $AD000000   0           https://github.com/amiga-mui
  BetterString      $2D00       $AD000000   $0300       https://github.com/amiga-mui
  HTMLview          $2D00       $AD000000   $3000       https://github.com/amiga-mui
  TheBar            $776B       $F76B0000   $0164       https://github.com/amiga-mui
  NListtree         $7EC8       $FCE80000   $1000       https://github.com/amiga-mui/nlist
  toolbar           $FCF7       $FCF70000   0           https://github.com/amiga-mui
  Urltext           $FEC9       $FEC90000   #200
  ---------------------------------------------------------------------------
}


interface


const
  TAG_USER  = $80000000;



//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial $051B
//
//////////////////////////////////////////////////////////////////////////////


const
  MUI_051B_SERIAL               = $051b; // #1307
  MUI_051B_TAGBASE              = ( TAG_USER or (MUI_051B_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class TextInput
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_TEXTINPUT_TAGOFFSET    = $712;
  MUICFG_TEXTINPUT_BASE         = ( MUI_051B_TAGBASE + MUICFG_TEXTINPUT_TAGOFFSET );


  MUICFG_Textinput_ExternalEditor               = ( MUICFG_TEXTINPUT_BASE +   0 );  //* STRPTR */
  MUICFG_Textinput_Cursorstyle                  = ( MUICFG_TEXTINPUT_BASE +   9 );  //* ULONG */
  MUICFG_Textinput_Blinkrate                    = ( MUICFG_TEXTINPUT_BASE +  10 );  //* ULONG */
  MUICFG_Textinput_Font                         = ( MUICFG_TEXTINPUT_BASE +  11 );  //* STRPTR */
  MUICFG_Textinput_ButtonImage                  = ( MUICFG_TEXTINPUT_BASE +  12 );  //* ImageSpec */
  MUICFG_Textinput_EditSync                     = ( MUICFG_TEXTINPUT_BASE +  14 );  //* BOOL */
  MUICFG_Textinput_WordWrapOn                   = ( MUICFG_TEXTINPUT_BASE +  15 );  //* BOOL */
  MUICFG_Textinput_WordWrapAt                   = ( MUICFG_TEXTINPUT_BASE +  16 );  //* ULONG */
  MUICFG_Textinput_SavedVerRev                  = ( MUICFG_TEXTINPUT_BASE +  17 );  //* UWORD/UWORD */
  MUICFG_Textinput_SingleFallback               = ( MUICFG_TEXTINPUT_BASE +  18 );  //* BOOL */
  MUICFG_Textinput_PopupSingle                  = ( MUICFG_TEXTINPUT_BASE +  19 );  //* BOOL */
  MUICFG_Textinput_PopupMulti                   = ( MUICFG_TEXTINPUT_BASE +  20 );  //* BOOL */
  MUICFG_Textinput_CursorSize                   = ( MUICFG_TEXTINPUT_BASE +  21 );  //* ULONG */
  MUICFG_Textinput_MarkQuals                    = ( MUICFG_TEXTINPUT_BASE +  22 );  //* ULONG */
  MUICFG_Textinput_FindURLInput                 = ( MUICFG_TEXTINPUT_BASE +  23 );  //* BOOL */
  MUICFG_Textinput_FindURLNoInput               = ( MUICFG_TEXTINPUT_BASE +  24 );  //* BOOL */
  MUICFG_Textinput_UndoBytesSingle              = ( MUICFG_TEXTINPUT_BASE +  25 );  //* ULONG */
  MUICFG_Textinput_UndoLevelsSingle             = ( MUICFG_TEXTINPUT_BASE +  26 );  //* ULONG */
  MUICFG_Textinput_UndoBytesMulti               = ( MUICFG_TEXTINPUT_BASE +  27 );  //* ULONG */
  MUICFG_Textinput_UndoLevelsMulti              = ( MUICFG_TEXTINPUT_BASE +  28 );  //* ULONG */
  MUICFG_Textinput_ClickableURLInput            = ( MUICFG_TEXTINPUT_BASE +  29 );  //* BOOL */
  MUICFG_Textinput_ClickableURLNoInput          = ( MUICFG_TEXTINPUT_BASE +  30 );  //* BOOL */
  MUICFG_Textinput_FixedFont                    = ( MUICFG_TEXTINPUT_BASE +  31 );  //* STRPTR */
  MUICFG_Textinput_HiliteQuotes                 = ( MUICFG_TEXTINPUT_BASE +  32 );  //* BOOL */
  
  MUICFG_Textinput_KeyCount                     = ( MUICFG_TEXTINPUT_BASE + 330 );
  MUICFG_Textinput_KeyBase                      = ( MUICFG_TEXTINPUT_BASE + 331 );

  MUICFG_Textinput_Pens_Inactive_Foreground     = ( MUICFG_TEXTINPUT_BASE + 100 );    //* PenSpec */
  MUICFG_Textinput_Pens_Inactive_Background     = ( MUICFG_TEXTINPUT_BASE + 101 );    //* PenSpec */
  MUICFG_Textinput_Pens_Active_Foreground       = ( MUICFG_TEXTINPUT_BASE + 102 );    //* PenSpec */
  MUICFG_Textinput_Pens_Active_Background       = ( MUICFG_TEXTINPUT_BASE + 103 );    //* PenSpec */
  MUICFG_Textinput_Pens_Marked_Foreground       = ( MUICFG_TEXTINPUT_BASE + 104 );    //* PenSpec */
  MUICFG_Textinput_Pens_Marked_Background       = ( MUICFG_TEXTINPUT_BASE + 105 );    //* PenSpec */
  MUICFG_Textinput_Pens_Cursor_Foreground       = ( MUICFG_TEXTINPUT_BASE + 106 );    //* PenSpec */
  MUICFG_Textinput_Pens_Cursor_Background       = ( MUICFG_TEXTINPUT_BASE + 107 );    //* PenSpec */
  MUICFG_Textinput_Pens_Style_Foreground        = ( MUICFG_TEXTINPUT_BASE + 108 );    //* PenSpec */
  MUICFG_Textinput_Pens_Style_Background        = ( MUICFG_TEXTINPUT_BASE + 109 );    //* PenSpec */
  MUICFG_Textinput_Pens_URL_Underline           = ( MUICFG_TEXTINPUT_BASE + 110 );    //* PenSpec */
  MUICFG_Textinput_Pens_URL_SelectedUnderline   = ( MUICFG_TEXTINPUT_BASE + 111 );    //* PenSpec */
  MUICFG_Textinput_Pens_Misspell_Underline      = ( MUICFG_TEXTINPUT_BASE + 112 );    //* PenSpec */






(*
/*
20	** Class name, object macros
21	*/
22	
23	#define MUIC_Textinput "Textinput.mcc"
24	#define TextinputObject MUI_NewObject(MUIC_Textinput
25	
26	#define MUIC_Textinputscroll "Textinputscroll.mcc"
27	#define TextinputscrollObject MUI_NewObject(MUIC_Textinputscroll
28	
29	
30	#define MCC_TI_TAGBASE ((TAG_USER)|((1307<<16)+0x712))
31	#define MCC_TI_ID(x) (MCC_TI_TAGBASE+(x))
32	
33	#define MCC_Textinput_Version 29
34	#define MCC_Textinput_Revision 1



#define MUICFG_Textinput_ExternalEditor MCC_TI_ID(0)	/* STRPTR */
6	#define MUICFG_Textinput_Cursorstyle MCC_TI_ID(9) /* ULONG */
7	#define MUICFG_Textinput_Blinkrate MCC_TI_ID(10) /* ULONG */
8	#define MUICFG_Textinput_Font MCC_TI_ID(11) /* STRPTR */
9	#define MUICFG_Textinput_ButtonImage MCC_TI_ID(12) /* ImageSpec */
10	#define MUICFG_Textinput_EditSync MCC_TI_ID(14) /* BOOL */
11	#define MUICFG_Textinput_WordWrapOn MCC_TI_ID(15) /* BOOL */
12	#define MUICFG_Textinput_WordWrapAt MCC_TI_ID(16) /* ULONG */
13	#define MUICFG_Textinput_SavedVerRev MCC_TI_ID(17) /* UWORD/UWORD */
14	#define MUICFG_Textinput_SingleFallback MCC_TI_ID(18) /* BOOL */
15	#define MUICFG_Textinput_PopupSingle MCC_TI_ID(19) /* BOOL */
16	#define MUICFG_Textinput_PopupMulti MCC_TI_ID(20) /* BOOL */
17	#define MUICFG_Textinput_CursorSize MCC_TI_ID(21) /* ULONG */
18	#define MUICFG_Textinput_MarkQuals MCC_TI_ID(22) /* ULONG */
19	#define MUICFG_Textinput_FindURLInput MCC_TI_ID(23) /* BOOL */
20	#define MUICFG_Textinput_FindURLNoInput MCC_TI_ID(24) /* BOOL */
21	#define MUICFG_Textinput_UndoBytesSingle MCC_TI_ID(25) /* ULONG */
22	#define MUICFG_Textinput_UndoLevelsSingle MCC_TI_ID(26) /* ULONG */
23	#define MUICFG_Textinput_UndoBytesMulti MCC_TI_ID(27) /* ULONG */
24	#define MUICFG_Textinput_UndoLevelsMulti MCC_TI_ID(28) /* ULONG */
25	#define MUICFG_Textinput_ClickableURLInput MCC_TI_ID(29) /* BOOL */
26	#define MUICFG_Textinput_ClickableURLNoInput MCC_TI_ID(30) /* BOOL */
27	#define MUICFG_Textinput_FixedFont MCC_TI_ID(31) /* STRPTR */
28	#define MUICFG_Textinput_HiliteQuotes MCC_TI_ID(32) /* BOOL */
29	
30	#define MUICFG_Textinput_KeyCount MCC_TI_ID(330)
31	#define MUICFG_Textinput_KeyBase MCC_TI_ID(331)
32	
33	#define MUICFG_Textinput_Pens_Inactive_Foreground MCC_TI_ID(100) /* PenSpec */
34	#define MUICFG_Textinput_Pens_Inactive_Background MCC_TI_ID(101) /* PenSpec */
35	#define MUICFG_Textinput_Pens_Active_Foreground MCC_TI_ID(102) /* PenSpec */
36	#define MUICFG_Textinput_Pens_Active_Background MCC_TI_ID(103) /* PenSpec */
37	#define MUICFG_Textinput_Pens_Marked_Foreground MCC_TI_ID(104) /* PenSpec */
38	#define MUICFG_Textinput_Pens_Marked_Background MCC_TI_ID(105) /* PenSpec */
39	#define MUICFG_Textinput_Pens_Cursor_Foreground MCC_TI_ID(106) /* PenSpec */
40	#define MUICFG_Textinput_Pens_Cursor_Background MCC_TI_ID(107) /* PenSpec */
41	#define MUICFG_Textinput_Pens_Style_Foreground MCC_TI_ID(108) /* PenSpec */
42	#define MUICFG_Textinput_Pens_Style_Background MCC_TI_ID(109) /* PenSpec */
43	#define MUICFG_Textinput_Pens_URL_Underline MCC_TI_ID(110) /* PenSpec */
44	#define MUICFG_Textinput_Pens_URL_SelectedUnderline MCC_TI_ID(111) /* PenSpec */
45	#define MUICFG_Textinput_Pens_Misspell_Underline MCC_TI_ID(112) /* PenSpec */

*)



//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial $1D51
//
//////////////////////////////////////////////////////////////////////////////


const
  MUI_1D51_SERIAL               = $1D51;
  MUI_1D51_TAGBASE              = ( TAG_USER or (MUI_1D51_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class NList
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_NLIST_TAGOFFSET        = $0000;
  MUICFG_NLIST_BASE             = ( MUI_1D51_TAGBASE + MUICFG_NLIST_TAGOFFSET );


  MUICFG_NList_Pen_Title        = ( $9d510001 );
  MUICFG_NList_Pen_List         = ( $9d510002 );
  MUICFG_NList_Pen_Select       = ( $9d510003 );
  MUICFG_NList_Pen_Cursor       = ( $9d510004 );
  MUICFG_NList_Pen_UnselCur     = ( $9d510005 );
  MUICFG_NList_Pen_Inactive     = ( $9d510104 );

  MUICFG_NList_BG_Title         = ( $9d510006 );
  MUICFG_NList_BG_List          = ( $9d510007 );
  MUICFG_NList_BG_Select        = ( $9d510008 );
  MUICFG_NList_BG_Cursor        = ( $9d510009 );
  MUICFG_NList_BG_UnselCur      = ( $9d51000a );
  MUICFG_NList_BG_Inactive      = ( $9d510105 );

  MUICFG_NList_Font             = ( $9d51000b );
  MUICFG_NList_Font_Little      = ( $9d51000c );
  MUICFG_NList_Font_Fixed       = ( $9d51000d );

  MUICFG_NList_VertInc          = ( $9d51000e );
  MUICFG_NList_DragType         = ( $9d51000f );
  MUICFG_NList_MultiSelect      = ( $9d510010 );

  MUICFG_NListview_VSB          = ( $9d510011 );
  MUICFG_NListview_HSB          = ( $9d510012 );

  MUICFG_NList_DragQualifier    = ( $9d510013 );    //* OBSOLETE */
  MUICFG_NList_Smooth           = ( $9d510014 );
  MUICFG_NList_ForcePen         = ( $9d510015 );
  MUICFG_NList_StackCheck       = ( $9d510016 );    //* OBSOLETE */
  MUICFG_NList_ColWidthDrag     = ( $9d510017 );
  MUICFG_NList_PartialCol       = ( $9d510018 );
  MUICFG_NList_List_Select      = ( $9d510019 );
  MUICFG_NList_Menu             = ( $9d51001A );
  MUICFG_NList_PartialChar      = ( $9d51001B );
  MUICFG_NList_PointerColor     = ( $9d51001C );    //* OBSOLETE */
  MUICFG_NList_SerMouseFix      = ( $9d51001D );
  MUICFG_NList_Keys             = ( $9d51001E );
  MUICFG_NList_DragLines        = ( $9d51001F );
  MUICFG_NList_VCenteredLines   = ( $9d510020 );
  MUICFG_NList_SelectPointer    = ( $9d510106 );

  MUICFG_NList_WheelStep        = ( $9d510101 );
  MUICFG_NList_WheelFast        = ( $9d510102 );
  MUICFG_NList_WheelMMB         = ( $9d510103 );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial $2D00
//
//////////////////////////////////////////////////////////////////////////////


const
  MUI_2D00_SERIAL               = $2D00;
  MUI_2D00_TAGBASE              = ( TAG_USER or (MUI_2D00_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class TextEditor
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_TEXTEDITOR_TAGOFFSET   = $0000;
  MUICFG_TEXTEDITOR_BASE        = ( MUI_2D00_TAGBASE + MUICFG_TEXTEDITOR_TAGOFFSET );


  MUICFG_TextEditor_Background      = ( $ad000051 );
  MUICFG_TextEditor_BlinkSpeed      = ( $ad000052 );
  MUICFG_TextEditor_BlockQual       = ( $ad000053 );
  MUICFG_TextEditor_CheckWord       = ( $ad000050 );
  MUICFG_TextEditor_CursorColor     = ( $ad000054 );
  MUICFG_TextEditor_CursorTextColor = ( $ad000055 );
  MUICFG_TextEditor_CursorWidth     = ( $ad000056 );
  MUICFG_TextEditor_FixedFont       = ( $ad000057 );
  MUICFG_TextEditor_Frame           = ( $ad000058 );
  MUICFG_TextEditor_HighlightColor  = ( $ad000059 );
  MUICFG_TextEditor_MarkedColor     = ( $ad00005a );
  MUICFG_TextEditor_NormalFont      = ( $ad00005b );
  MUICFG_TextEditor_SetMaxPen       = ( $ad00005c );
  MUICFG_TextEditor_Smooth          = ( $ad00005d );
  MUICFG_TextEditor_TabSize         = ( $ad00005e );
  MUICFG_TextEditor_TextColor       = ( $ad00005f );
  MUICFG_TextEditor_UndoSize        = ( $ad000060 );
  MUICFG_TextEditor_TypeNSpell      = ( $ad000061 );
  MUICFG_TextEditor_LookupCmd       = ( $ad000062 );
  MUICFG_TextEditor_SuggestCmd      = ( $ad000063 );
  MUICFG_TextEditor_Keybindings     = ( $ad000064 );
  MUICFG_TextEditor_SuggestKey      = ( $ad000065 ); //* OBSOLETE! */
  MUICFG_TextEditor_SeparatorShine  = ( $ad000066 );
  MUICFG_TextEditor_SeparatorShadow = ( $ad000067 );
  MUICFG_TextEditor_ConfigVersion   = ( $ad000068 );
  MUICFG_TextEditor_InactiveCursor  = ( $ad000069 );
  MUICFG_TextEditor_SelectPointer   = ( $ad00006a );
  MUICFG_TextEditor_InactiveColor   = ( $ad00006b );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class BetterString
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_BETTERSTRING_TAGOFFSET   = $0300;
  MUICFG_BETTERSTRING_BASE        = ( MUI_2D00_TAGBASE + MUICFG_BETTERSTRING_TAGOFFSET );


  MUICFG_BetterString_ActiveBack        = ( $ad000302 );
  MUICFG_BetterString_ActiveText        = ( $ad000303 );
  MUICFG_BetterString_InactiveBack      = ( $ad000300 );
  MUICFG_BetterString_InactiveText      = ( $ad000301 );
  MUICFG_BetterString_Cursor            = ( $ad000304 ); 
  MUICFG_BetterString_MarkedBack        = ( $ad000305 );
  MUICFG_BetterString_MarkedText        = ( $ad000308 );
  MUICFG_BetterString_Font              = ( $ad000306 ); 
  MUICFG_BetterString_Frame             = ( $ad000307 );
  MUICFG_BetterString_SelectOnActive    = ( $ad00030a );
  MUICFG_BetterString_SelectPointer     = ( $ad000309 );

  //MUICFG_BubbleHelp_FirstDelay          = ( $ad00030a );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class HTMLView
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_HTMLVIEW_TAGOFFSET   = $3000;
  MUICFG_HTMLVIEW_BASE        = ( MUI_2D00_TAGBASE + MUICFG_HTMLVIEW_TAGOFFSET );


  MUICFG_HTMLview_SmallFont         = ( MUICFG_HTMLVIEW_BASE +  1 );
  MUICFG_HTMLview_NormalFont        = ( MUICFG_HTMLVIEW_BASE +  2 );
  MUICFG_HTMLview_FixedFont         = ( MUICFG_HTMLVIEW_BASE +  3 );
  MUICFG_HTMLview_LargeFont         = ( MUICFG_HTMLVIEW_BASE +  4 );
  MUICFG_HTMLview_H1                = ( MUICFG_HTMLVIEW_BASE +  5 );
  MUICFG_HTMLview_H2                = ( MUICFG_HTMLVIEW_BASE +  6 );
  MUICFG_HTMLview_H3                = ( MUICFG_HTMLVIEW_BASE +  7 );
  MUICFG_HTMLview_H4                = ( MUICFG_HTMLVIEW_BASE +  8 );
  MUICFG_HTMLview_H5                = ( MUICFG_HTMLVIEW_BASE +  9 );
  MUICFG_HTMLview_H6                = ( MUICFG_HTMLVIEW_BASE + 10 );

  MUICFG_HTMLview_IgnoreDocCols     = ( MUICFG_HTMLVIEW_BASE + 11 );
  MUICFG_HTMLview_Col_Background    = ( MUICFG_HTMLVIEW_BASE + 12 );
  MUICFG_HTMLview_Col_Text          = ( MUICFG_HTMLVIEW_BASE + 13 );
  MUICFG_HTMLview_Col_Link          = ( MUICFG_HTMLVIEW_BASE + 14 );
  MUICFG_HTMLview_Col_VLink         = ( MUICFG_HTMLVIEW_BASE + 15 );
  MUICFG_HTMLview_Col_ALink         = ( MUICFG_HTMLVIEW_BASE + 16 );

  MUICFG_HTMLview_DitherType        = ( MUICFG_HTMLVIEW_BASE + 17 );
  MUICFG_HTMLview_ImageCacheSize    = ( MUICFG_HTMLVIEW_BASE + 18 );

  MUICFG_HTMLview_PageScrollSmooth  = ( MUICFG_HTMLVIEW_BASE + 19 );
  MUICFG_HTMLview_PageScrollKey     = ( MUICFG_HTMLVIEW_BASE + 20 );
  MUICFG_HTMLview_PageScrollMove    = ( MUICFG_HTMLVIEW_BASE + 21 );

  MUICFG_HTMLview_ListItemFile      = ( MUICFG_HTMLVIEW_BASE + 22 );

  MUICFG_HTMLview_GammaCorrection   = ( MUICFG_HTMLVIEW_BASE + 23 );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial $776B
//
//////////////////////////////////////////////////////////////////////////////


const
  MUI_776B_SERIAL               = $776B;
  MUI_776B_TAGBASE              = ( TAG_USER or (MUI_776B_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class TheBar
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_THEBAR_TAGOFFSET   = $0164;
  MUICFG_THEBAR_BASE        = ( MUI_776B_TAGBASE + MUICFG_THEBAR_TAGOFFSET );


  MUICFG_TheBar_GroupBack             = ( MUICFG_THEBAR_BASE +  0 );  //* v11 ImageSpec         */
  MUICFG_TheBar_UseGroupBack          = ( MUICFG_THEBAR_BASE +  1 );  //* v11 ULONG             */
  MUICFG_TheBar_ButtonBack            = ( MUICFG_THEBAR_BASE +  2 );  //* v11 ImageSpec         */
  MUICFG_TheBar_UseButtonBack         = ( MUICFG_THEBAR_BASE +  3 );  //* v11 ULONG             */
  MUICFG_TheBar_FrameShinePen         = ( MUICFG_THEBAR_BASE +  4 );  //* v11 PenSpec           */
  MUICFG_TheBar_FrameShadowPen        = ( MUICFG_THEBAR_BASE +  5 );  //* v11 PenSpec           */
  MUICFG_TheBar_FrameStyle            = ( MUICFG_THEBAR_BASE +  6 );  //* v11 ULONG             */
  MUICFG_TheBar_DisBodyPen            = ( MUICFG_THEBAR_BASE +  7 );  //* v11 PenSpec           */
  MUICFG_TheBar_DisShadowPen          = ( MUICFG_THEBAR_BASE +  8 );  //* v11 PenSpec           */
  MUICFG_TheBar_BarSpacerShinePen     = ( MUICFG_THEBAR_BASE +  9 );  //* v11 PenSpec           */
  MUICFG_TheBar_BarSpacerShadowPen    = ( MUICFG_THEBAR_BASE + 10 );  //* v11 PenSpec           */
  MUICFG_TheBar_BarFrameShinePen      = ( MUICFG_THEBAR_BASE + 11 );  //* v11 PenSpec           */
  MUICFG_TheBar_BarFrameShadowPen     = ( MUICFG_THEBAR_BASE + 12 );  //* v11 PenSpec           */
  MUICFG_TheBar_DragBarShinePen       = ( MUICFG_THEBAR_BASE + 13 );  //* v11 PenSpec           */
  MUICFG_TheBar_DragBarShadowPen      = ( MUICFG_THEBAR_BASE + 14 );  //* v11 PenSpec           */
  MUICFG_TheBar_DragBarFillPen        = ( MUICFG_THEBAR_BASE + 15 );  //* v17 PenSpec           */
  MUICFG_TheBar_UseDragBarFillPen     = ( MUICFG_THEBAR_BASE + 16 );  //* v17 BOOL              */

  MUICFG_TheBar_TextFont              = ( MUICFG_THEBAR_BASE + 20 );  //* v11 STRPTR            */
  MUICFG_TheBar_TextGfxFont           = ( MUICFG_THEBAR_BASE + 21 );  //* v11 STRPTR            */

  MUICFG_TheBar_HorizSpacing          = ( MUICFG_THEBAR_BASE + 30 );  //* v11 ULONG             */
  MUICFG_TheBar_VertSpacing           = ( MUICFG_THEBAR_BASE + 31 );  //* v11 ULONG             */
  MUICFG_TheBar_BarSpacerSpacing      = ( MUICFG_THEBAR_BASE + 32 );  //* v11 ULONG             */
  MUICFG_TheBar_HorizInnerSpacing     = ( MUICFG_THEBAR_BASE + 33 );  //* v11 ULONG             */
  MUICFG_TheBar_TopInnerSpacing       = ( MUICFG_THEBAR_BASE + 34 );  //* v11 ULONG             */
  MUICFG_TheBar_BottomInnerSpacing    = ( MUICFG_THEBAR_BASE + 35 );  //* v11 ULONG             */
  MUICFG_TheBar_LeftBarFrameSpacing   = ( MUICFG_THEBAR_BASE + 36 );  //* v11 ULONG             */
  MUICFG_TheBar_RightBarFrameSpacing  = ( MUICFG_THEBAR_BASE + 37 );  //* v11 ULONG             */
  MUICFG_TheBar_TopBarFrameSpacing    = ( MUICFG_THEBAR_BASE + 38 );  //* v11 ULONG             */
  MUICFG_TheBar_BottomBarFrameSpacing = ( MUICFG_THEBAR_BASE + 39 );  //* v11 ULONG             */
  MUICFG_TheBar_HorizTextGfxSpacing   = ( MUICFG_THEBAR_BASE + 40 );  //* v11 ULONG             */
  MUICFG_TheBar_VertTextGfxSpacing    = ( MUICFG_THEBAR_BASE + 41 );  //* v11 ULONG             */

  MUICFG_TheBar_Precision             = ( MUICFG_THEBAR_BASE + 60 );  //* v11 ULONG             */
  MUICFG_TheBar_Event                 = ( MUICFG_THEBAR_BASE + 61 );  //* v11 ULONG             */
  MUICFG_TheBar_Scale                 = ( MUICFG_THEBAR_BASE + 62 );  //* v11 ULONG             */
  MUICFG_TheBar_SpecialSelect         = ( MUICFG_THEBAR_BASE + 63 );  //* v11 ULONG             */
  MUICFG_TheBar_TextOverUseShine      = ( MUICFG_THEBAR_BASE + 64 );  //* v11 ULONG             */
  MUICFG_TheBar_IgnoreSelImages       = ( MUICFG_THEBAR_BASE + 65 );  //* v12 ULONG             */
  MUICFG_TheBar_IgnoreDisImages       = ( MUICFG_THEBAR_BASE + 66 );  //* v12 ULONG             */
  MUICFG_TheBar_DisMode               = ( MUICFG_THEBAR_BASE + 67 );  //* v12 ULONG             */
  MUICFG_TheBar_DontMove              = ( MUICFG_THEBAR_BASE + 68 );  //* v15 ULONG             */
  MUICFG_TheBar_Gradient              = ( MUICFG_THEBAR_BASE + 80 );  //* v17 ULONG             */
  MUICFG_TheBar_NtRaiseActive         = ( MUICFG_THEBAR_BASE + 81 );  //* v18 BOOL              */
  MUICFG_TheBar_SpacersSize           = ( MUICFG_THEBAR_BASE + 82 );  //* v18 ULONG             */
  MUICFG_TheBar_Appearance            = ( MUICFG_THEBAR_BASE + 83 );  //* v19 struct Appearance */

  MUICFG_TheBar_Frame                 = ( MUICFG_THEBAR_BASE + 84 );  //* v19 struct Framespec  */
  MUICFG_TheBar_ButtonFrame           = ( MUICFG_THEBAR_BASE + 85 );  //* v19 struct Framespec  */



//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial $7EC8
//
//////////////////////////////////////////////////////////////////////////////


const
  MUI_7EC8_SERIAL               = $7EC8;
  MUI_7EC8_TAGBASE              = ( TAG_USER or (MUI_7EC8_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class NListtree
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_NLISTTREE_TAGOFFSET   = $1000;
  MUICFG_NLISTTREE_BASE        = ( MUI_7EC8_TAGBASE + MUICFG_NLISTTREE_TAGOFFSET );


  MUICFG_NListtree_ImageSpecClosed  = ( MUICFG_NLISTTREE_BASE or $0001 );
  MUICFG_NListtree_ImageSpecOpen    = ( MUICFG_NLISTTREE_BASE or $0002 );
  MUICFG_NListtree_ImageSpecFolder  = ( MUICFG_NLISTTREE_BASE or $0003 );

  MUICFG_NListtree_PenSpecLines     = ( MUICFG_NLISTTREE_BASE or $0004 );
  MUICFG_NListtree_PenSpecShadow    = ( MUICFG_NLISTTREE_BASE or $0005 );
  MUICFG_NListtree_PenSpecGlow      = ( MUICFG_NLISTTREE_BASE or $0006 );
 
  MUICFG_NListtree_RememberStatus   = ( MUICFG_NLISTTREE_BASE or $0007 );
  MUICFG_NListtree_IndentWidth      = ( MUICFG_NLISTTREE_BASE or $0008 );
  MUICFG_NListtree_Unknown1         = ( MUICFG_NLISTTREE_BASE or $0009 );
  MUICFG_NListtree_OpenAutoScroll   = ( MUICFG_NLISTTREE_BASE or $000a );
  MUICFG_NListtree_LineType         = ( MUICFG_NLISTTREE_BASE or $000b );
  MUICFG_NListtree_UseFolderImage   = ( MUICFG_NLISTTREE_BASE or $000c );



//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial $FCF7 
//
//////////////////////////////////////////////////////////////////////////////


const
  MUI_FCF7_SERIAL               = $FCF7;
  MUI_FCF7_TAGBASE              = ( TAG_USER or (MUI_FCF7_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class Toolbar
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_TOOLBAR_TAGOFFSET   = $0000; // ????
  MUICFG_TOOLBAR_BASE        = ( MUI_FCF7_TAGBASE + MUICFG_TOOLBAR_TAGOFFSET );


  MUICFG_Toolbar_ToolbarLook            = ( MUICFG_TOOLBAR_BASE or $0030 );
  MUICFG_Toolbar_Separator              = ( MUICFG_TOOLBAR_BASE or $003d );
  MUICFG_Toolbar_FrameSpec              = ( MUICFG_TOOLBAR_BASE or $003b );

  MUICFG_Toolbar_GroupSpace             = ( MUICFG_TOOLBAR_BASE or $0031 );
  MUICFG_Toolbar_GroupSpace_Max         = ( MUICFG_TOOLBAR_BASE or $0031 );
  MUICFG_Toolbar_GroupSpace_Min         = ( MUICFG_TOOLBAR_BASE or $003c );
  MUICFG_Toolbar_ToolSpace              = ( MUICFG_TOOLBAR_BASE or $0032 );
  MUICFG_Toolbar_ImageTextSpace         = ( MUICFG_TOOLBAR_BASE or $003f );

  MUICFG_Toolbar_InnerSpace_Text        = ( MUICFG_TOOLBAR_BASE or $0033 );
  MUICFG_Toolbar_InnerSpace_NoText      = ( MUICFG_TOOLBAR_BASE or $0034 );

  //* Graphics */
  MUICFG_Toolbar_Precision              = ( MUICFG_TOOLBAR_BASE or $0035 );
  MUICFG_Toolbar_GhostEffect            = ( MUICFG_TOOLBAR_BASE or $0036 );
  MUICFG_Toolbar_UseImages              = ( MUICFG_TOOLBAR_BASE or $003a );

  //* Text */
  MUICFG_Toolbar_Placement              = ( MUICFG_TOOLBAR_BASE or $0037 );
  MUICFG_Toolbar_ToolFont               = ( MUICFG_TOOLBAR_BASE or $0038 );
  MUICFG_Toolbar_ToolPen                = ( MUICFG_TOOLBAR_BASE or $0039 );

  MUICFG_Toolbar_Background_Normal      = ( MUICFG_TOOLBAR_BASE or $0040 );
  MUICFG_Toolbar_Background_Selected    = ( MUICFG_TOOLBAR_BASE or $0041 );
  MUICFG_Toolbar_Background_Ghosted     = ( MUICFG_TOOLBAR_BASE or $0042 );

  //* Border Type*/
  MUICFG_Toolbar_BorderType             = ( MUICFG_TOOLBAR_BASE or $0043 );

  //* Selection Mode */
  MUICFG_Toolbar_SelectionMode          = ( MUICFG_TOOLBAR_BASE or $0044 );

  //* AutoActive */ 
  MUICFG_Toolbar_AutoActive             = ( MUICFG_TOOLBAR_BASE or $0045 );



//////////////////////////////////////////////////////////////////////////////
//
//        MUI serial FEC9
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUI_FEC9_SERIAL   = $FEC9;
  MUI_FEC9_TAGBASE  = ( TAG_USER or (MUI_FEC9_SERIAL shl 16) );


//////////////////////////////////////////////////////////////////////////////
//
//        MUI class URLText
//
//////////////////////////////////////////////////////////////////////////////


Const
  MUICFG_URLTEXT_TAGOFFSET   = 200;
  MUICFG_URLTEXT_BASE        = ( MUI_FEC9_TAGBASE + MUICFG_URLTEXT_TAGOFFSET );


  MUICFG_Urltext_MouseOutPen    = ( MUICFG_URLTEXT_BASE + $0001 );  //* [IS..] (struct MUI_PenSpec *) PRIVATE!           */
  MUICFG_Urltext_MouseOverPen   = ( MUICFG_URLTEXT_BASE + $0002 );  //* [IS..] (struct MUI_PenSpec *) PRIVATE!           */
  MUICFG_Urltext_VisitedPen     = ( MUICFG_URLTEXT_BASE + $0003 );  //* [IS..] (struct MUI_PenSpec *) PRIVATE!           */
  MUICFG_Urltext_MouseOver      = ( MUICFG_URLTEXT_BASE + $0004 );  //* [.S.N] (BOOL)                 PRIVATE!           */
  MUICFG_Urltext_PUnderline     = ( MUICFG_URLTEXT_BASE + $0005 );  //* [.S..] (BOOL)                 PRIVATE!           */
  MUICFG_Urltext_PDoVisitedPen  = ( MUICFG_URLTEXT_BASE + $0006 );  //* [.S..] (BOOL)                 PRIVATE!           */
  MUICFG_Urltext_PFallBack      = ( MUICFG_URLTEXT_BASE + $0007 );  //* [.S..] (BOOL)                 PRIVATE!           */
                                    
  MUICFG_Urltext_Url            = ( MUICFG_URLTEXT_BASE + $0008 );  //* [ISGN] (STRPTR)                                  */
  MUICFG_Urltext_Text           = ( MUICFG_URLTEXT_BASE + $0009 );  //* [ISGN] (STRPTR)                                  */
  MUICFG_Urltext_Active         = ( MUICFG_URLTEXT_BASE + $000a );  //* [..G.] (BOOL)                                    */
  MUICFG_Urltext_Visited        = ( MUICFG_URLTEXT_BASE + $000b );  //* [..GN] (BOOL)                                    */
  MUICFG_Urltext_Underline      = ( MUICFG_URLTEXT_BASE + $000c );  //* [I...] (BOOL)                                    */
  MUICFG_Urltext_FallBack       = ( MUICFG_URLTEXT_BASE + $000d );  //* [I...] (BOOL)                                    */
  MUICFG_Urltext_DoVisitedPen   = ( MUICFG_URLTEXT_BASE + $000e );  //* [I...] (BOOL)                                    */
  MUICFG_Urltext_SetMax         = ( MUICFG_URLTEXT_BASE + $000f );  //* [I...] (BOOL)                                    */
  MUICFG_Urltext_DoOpenURL      = ( MUICFG_URLTEXT_BASE + $0010 );  //* [I...] (BOOL)                                    */
  MUICFG_Urltext_NoMenu         = ( MUICFG_URLTEXT_BASE + $0011 );  //* [I...] (BOOL)                                    */
                                    
  MUICFG_Urltext_Font           = ( MUICFG_URLTEXT_BASE + $0012 );  //* PRIVATE!                                         */
  MUICFG_Urltext_Version        = ( MUICFG_URLTEXT_BASE + $0013 );  //* PRIVATE!                                         */
                                    
  MUICFG_Urltext_NoOpenURLPrefs = ( MUICFG_URLTEXT_BASE + $0014 );  //* [I...] (BOOL)                                    */



//////////////////////////////////////////////////////////////////////////////
//
//        .
//
//////////////////////////////////////////////////////////////////////////////



{
  missing:
  - 9D51
  - F76B
  - FEC9
}

{
  35 #define MUISN_Alfie     0xFEC9
  36 #define TAG_MUI_Alfie   (TAG_USER|(MUISN_Alfie<<16))
}


{
  27 /*
  28 ** Class name, object macros
  29 */
  30 
  31 #define MUIC_Textinput "Textinput.mcc"
  32 #define TextinputObject MUI_NewObject(MUIC_Textinput
  33 
  34 #define MUIC_Textinputscroll "Textinputscroll.mcc"
  35 #define TextinputscrollObject MUI_NewObject(MUIC_Textinputscroll
  36 
  37 
  38 #define MCC_TI_TAGBASE ((TAG_USER)|((1307<<16)+0x712))
  39 #define MCC_TI_ID(x) (MCC_TI_TAGBASE+(x))
  40 
  41 #define MCC_Textinput_Version 29
  42 #define MCC_Textinput_Revision 1
}

implementation
end.
