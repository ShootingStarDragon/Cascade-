#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiImageListEx.au3>
#include "GuiListViewEx.au3"

Opt( "MustDeclareVars", 1 )

Global $iItems = 100

Example()


Func Example()
	; Create GUI
	Local $hGui = GUICreate( "Overlay icons", 420, 200 )

	; Create ListView
	Local $idListView = GUICtrlCreateListView( "", 10, 10, 400, 180, $GUI_SS_DEFAULT_LISTVIEW-$LVS_SINGLESEL, $WS_EX_CLIENTEDGE+$LVS_EX_DOUBLEBUFFER+$LVS_EX_FULLROWSELECT )
	Local $hListView = GUICtrlGetHandle( $idListView )                                                                        ; Reduces flicker

	; Create ImageList
	Local $hImageList = _GUIImageList_Create( 16, 16, 5, 1 )

	; Add cyan, green and yellow overlay icons to ImageList
	_GUIImageList_AddIcon( $hImageList, "icons\Overlay\Cyan.ico" )   ; Index 0
	_GUIImageList_AddIcon( $hImageList, "icons\Overlay\Green.ico" )  ; Index 1
	_GUIImageList_AddIcon( $hImageList, "icons\Overlay\Yellow.ico" ) ; Index 2

	; Tell ImageList that this is overlay icons
	ImageList_SetOverlayImage( $hImageList, 0, 1 ) ; First overlay icon
	ImageList_SetOverlayImage( $hImageList, 1, 2 ) ; Second overlay icon
	ImageList_SetOverlayImage( $hImageList, 2, 3 ) ; Third overlay icon

	; Add normal small icons  to ImageList
	_GUIImageList_Add( $hImageList, _WinAPI_CreateSolidBitmap( $hGui, 0xFF0000, 16, 16 ) ) ; Index 3, Red
	_GUIImageList_Add( $hImageList, _WinAPI_CreateSolidBitmap( $hGui, 0xFF00FF, 16, 16 ) ) ; Index 4, Magenta
	_GUIImageList_Add( $hImageList, _WinAPI_CreateSolidBitmap( $hGui, 0x0000FF, 16, 16 ) ) ; Index 5, Blue

	; Add ImageList to ListView
	_GUICtrlListView_SetImageList( $hListView, $hImageList, 1 ) ; 1 = Small icons

	; Add columns to ListView
	_GUICtrlListView_AddColumn( $hListView, "Column 1", 94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 2", 94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 3", 94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 4", 94 )

	; Fill ListView
	For $i = 0 To $iItems - 1
		GUICtrlCreateListViewItem( $i & "/Column 1|" & $i & "/Column 2|" & $i & "/Column 3|" & $i & "/Column 4", $idListView )
		_GUICtrlListView_SetItemState( $hListView, $i, 256 * Mod( $i, 4 ), $LVIS_OVERLAYMASK ) ; Add overlay icon
		_GUICtrlListView_SetItemImage( $hListView, $i, Mod( $i, 3 ) + 3 )
	Next

	; Adjust height of GUI and ListView to fit ten rows
	Local $iLvHeight = _GUICtrlListView_GetHeightToFitRows( $hListView, 10 )
	WinMove( $hGui, "", Default, Default, Default, WinGetPos( $hGui )[3] - WinGetClientSize( $hGui )[1] + $iLvHeight + 20 )
	WinMove( $hListView, "", Default, Default, Default, $iLvHeight )

	; Show GUI
	GUISetState( @SW_SHOW )

	; Message loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	; Cleanup
	GUIDelete()
EndFunc
