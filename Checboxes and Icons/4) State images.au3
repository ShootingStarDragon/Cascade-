#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiImageList.au3>
#include "GuiListViewEx.au3"

Opt( "MustDeclareVars", 1 )

Global $iItems = 100

Example()


Func Example()
	; Create GUI
	Local $hGui = GUICreate( "Custom state images", 450, 200 )

	; Create ListView
	Local $idListView = GUICtrlCreateListView( "", 10, 10, 430, 180, $GUI_SS_DEFAULT_LISTVIEW-$LVS_SINGLESEL, $WS_EX_CLIENTEDGE+$LVS_EX_CHECKBOXES+$LVS_EX_DOUBLEBUFFER+$LVS_EX_FULLROWSELECT )
	Local $hListView = GUICtrlGetHandle( $idListView )                                                                                           ; Reduces flicker

	; Get state ImageList
	Local $hStateImageList = _GUICtrlListView_GetImageList( $hListView, 2 ) ; 2 = Image list with state images

	; Delete images of unchecked and checked checkboxes
	_GUIImageList_Remove( $hStateImageList )

	; Add custom images to state ImageList
	_GUIImageList_Add( $hStateImageList, _WinAPI_CreateSolidBitmap( $hGui, 0x00FF00, 16, 16 ) ) ; Index 0, Green
	_GUIImageList_Add( $hStateImageList, _WinAPI_CreateSolidBitmap( $hGui, 0xFFFF00, 16, 16 ) ) ; Index 1, Yellow
	_GUIImageList_Add( $hStateImageList, _WinAPI_CreateSolidBitmap( $hGui, 0xFF0000, 16, 16 ) ) ; Index 2, Red

	; Add columns to ListView
	_GUICtrlListView_AddColumn( $hListView, "Column 1", 124 )
	_GUICtrlListView_AddColumn( $hListView, "Column 2",  94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 3",  94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 4",  94 )

	; Fill ListView
	For $i = 0 To $iItems - 1
		GUICtrlCreateListViewItem( $i & "/Column 1|" & $i & "/Column 2|" & $i & "/Column 3|" & $i & "/Column 4", $idListView )
		_GUICtrlListView_SetItemStateImage( $hListView, $i, 1 ) ; Add green state image
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
