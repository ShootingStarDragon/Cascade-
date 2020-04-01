#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiImageList.au3>
#include "GuiListViewEx.au3"

Opt( "MustDeclareVars", 1 )

Global $hListView, $iItems = 100

Example()


Func Example()
	; Create GUI
	Local $hGui = GUICreate( "Remove some checkboxes", 450, 200 )

	; Create ListView
	Local $idListView = GUICtrlCreateListView( "", 10, 10, 430, 180, $GUI_SS_DEFAULT_LISTVIEW, $WS_EX_CLIENTEDGE+$LVS_EX_CHECKBOXES+$LVS_EX_DOUBLEBUFFER+$LVS_EX_SUBITEMIMAGES )
	$hListView = GUICtrlGetHandle( $idListView )                                                                                  ; Reduces flicker

	; Get state ImageList
	Local $hStateImageList = _GUICtrlListView_GetImageList( $hListView, 2 ) ; 2 = Image list with state images

	; Add state ImageList as a normal ImageList
	_GUICtrlListView_SetImageList( $hListView, $hStateImageList, 1 ) ; 1 = Image list with small icons

	; Add columns to ListView
	_GUICtrlListView_AddColumn( $hListView, "Column 1", 124 )
	_GUICtrlListView_AddColumn( $hListView, "Column 2",  94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 3",  94 )
	_GUICtrlListView_AddColumn( $hListView, "Column 4",  94 )

	; Register WM_NOTIFY message handler
	GUIRegisterMsg( $WM_NOTIFY, "WM_NOTIFY" )

	; Fill ListView
	For $i = 0 To $iItems - 1
		GUICtrlCreateListViewItem( $i & "/Column 1|" & $i & "/Column 2|" & $i & "/Column 3|", $idListView )
		_GUICtrlListView_AddSubItem( $hListView, $i, $i & "/Column 4", 3, Mod( $i, 4 ) = 3 ? 0 : 100 ) ; Unchecked checkbox in column 4
		_GUICtrlListView_SetItemImage( $hListView, $i, Not Mod( Mod( $i, 4 ), 2 ) ? 0 : 100 )          ; Unchecked checkbox for item
	Next                                                                            ; 100 = illegal image index => no image displayed

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

; WM_NOTIFY message handler
Func WM_NOTIFY( $hWnd, $iMsg, $wParam, $lParam )
	#forceref $hWnd, $iMsg, $wParam
	Local $tNMHDR = DllStructCreate( $tagNMHDR, $lParam )
	Local $hWndFrom = HWnd( DllStructGetData( $tNMHDR, "hWndFrom" ) )
	Local $iCode = DllStructGetData( $tNMHDR, "Code" )
	Local $tNMLISTVIEW, $iItem

	Switch $hWndFrom
		Case $hListView
			Switch $iCode
				Case $LVN_ITEMCHANGED
					$tNMLISTVIEW = DllStructCreate( $tagNMLISTVIEW, $lParam )
					$iItem = DllStructGetData( $tNMLISTVIEW, "Item" )
					_GUICtrlListView_SetItemSelected( $hListView, $iItem, False )         ; Remove selected state
					_GUICtrlListView_SetItemState( $hListView, $iItem, 0, $LVIS_FOCUSED ) ; Remove focused state

				Case $LVN_ITEMCHANGING
					$tNMListView = DllStructCreate( $tagNMLISTVIEW, $lParam )
					$iItem = DllStructGetData( $tNMListView, "Item" )
					Local $iNewState = DllStructGetData( $tNMListView, "NewState" )
					If Mod( $iItem, 4 ) > 1 And BitAND( $iNewState, $LVIS_STATEIMAGEMASK ) Then Return True ; Remove checkbox

				Case $NM_CLICK
					Local $aHit = _GUICtrlListView_SubItemHitTest( $hListView )
					If $aHit[6] Then                         ; On item?
						If $aHit[3] Then                       ; On icon?
							If $aHit[1] = 0 Or $aHit[1] = 3 Then ; On subitem 0 or 3?
								Local $iImage = _GUICtrlListView_GetItemImage( $hListView, $aHit[0], $aHit[1] )                         ; Image index 0 or 1
								If $iImage <> 100 Then _GUICtrlListView_SetItemImage( $hListView, $aHit[0], $iImage ? 0 : 1, $aHit[1] ) ; Switch image index
							EndIf                                                             ; $iItem    $iImage          $iSubItem
						EndIf
					EndIf
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc
