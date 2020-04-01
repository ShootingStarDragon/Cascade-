#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

Opt( "MustDeclareVars", 1 )

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>

Global $idListView, $hListView

Example()

Func Example()
  ; Create GUI
  GUICreate( "Listview with subitem checkboxes", 800, 598+20 )

  ; Create ListView
  $idListView = GUICtrlCreateListView( "", 10, 10, 800-20, 598, $GUI_SS_DEFAULT_LISTVIEW, $WS_EX_CLIENTEDGE )
  _GUICtrlListView_SetExtendedListViewStyle( $idListView, $LVS_EX_DOUBLEBUFFER+$LVS_EX_SUBITEMIMAGES ) ; Subitem images
  $hListView = GUICtrlGetHandle( $idListView )

  ; ImageList
  Local $idListView2 = GUICtrlCreateListView( "", 0, 0, 1, 1 )                  ; 1x1 pixel listview to create state image list with checkbox icons
  _GUICtrlListView_SetExtendedListViewStyle( $idListView2, $LVS_EX_CHECKBOXES ) ; The $LVS_EX_CHECKBOXES style forces the state image list to be created
  Local $hImageList = _GUICtrlListView_GetImageList( $idListView2, 2 )          ; Get the state image list with unchecked and checked checkbox icons
  _GUICtrlListView_SetImageList( $idListView, $hImageList, 1 )                  ; Set the state image list as a normal small icon image list in $idListView
  ; Now the checkboxes can be handled like normal subitem icons

  ; Add 10 columns
  For $i = 0 To 9
    _GUICtrlListView_AddColumn( $idListView, "Col " & $i, 75 )
  Next

  ; Add 100 rows
  For $i = 0 To 100 - 1
    _GUICtrlListView_AddItem( $idListView, $i, 0 )                           ; Image index 0 = unchecked checkbox
    For $j = 1 To 9
      ;_GUICtrlListView_AddSubItem( $idListView, $i, $i & " / " & $j, $j, 0 ) ; Image index 0 = unchecked checkbox
	  _GUICtrlListView_AddSubItem( $idListView, $i, $i & " / " & $j, $j, 1 ) ; Image index 0 = unchecked checkbox
    Next
	;_GUICtrlListView_SetItemState ( $hListView, $i, 1, $LVIS_STATEIMAGEMASK )
  Next

  ; WM_NOTIFY message handler to toggle checkboxes
  GUIRegisterMsg( $WM_NOTIFY, "WM_NOTIFY" )

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

; Message handler to toggle checkboxes
Func WM_NOTIFY( $hWnd, $iMsg, $wParam, $lParam )
  Local $tNMHDR = DllStructCreate( $tagNMHDR, $lParam )

  Switch HWnd( DllStructGetData( $tNMHDR, "hWndFrom" ) )
    Case $hListView
      Switch DllStructGetData( $tNMHDR, "Code" )
        Case $NM_CLICK
          Local $aHit = _GUICtrlListView_SubItemHitTest( $hListView )
          If $aHit[0] >= 0 And $aHit[1] >= 0 Then                                                ; Item and subitem
            Local $iIcon = _GUICtrlListView_GetItemImage( $idListView, $aHit[0], $aHit[1] )      ; Get checkbox icon
            _GUICtrlListView_SetItemImage( $idListView, $aHit[0], $iIcon = 0 ? 1 : 0, $aHit[1] ) ; Toggle checkbox icon
            _GUICtrlListView_RedrawItems( $idListView, $aHit[0], $aHit[0] )                      ; Redraw listview item
          EndIf
      EndSwitch
  EndSwitch

  Return $GUI_RUNDEFMSG
  #forceref $hWnd, $iMsg, $wParam
EndFunc