#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <SendMessage.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

#Region Globals *************************************************************************
Global $g_ahDragImageList, $g_hListView, $g_bDragging = False, $g_iLV_Height, $initIndex
Global $g_aIndex[2] ; from and to

Global Const $g_iDebugIt = 1

#EndRegion Globals *************************************************************************


$theGUI = GUICreate("", 200, 400)
GUISetState(@SW_SHOW)

;$Listview = GUICtrlCreateListView("filename", 0, 0, 200, 400);
;GUICtrlCreateListView ( "text", left, top [, width [, height [, style = -1 [, exStyle = -1]]]] )
$Listview = _GUICtrlListView_Create($theGUI, "filename", 0, 0, 200, 400);
;_GUICtrlListView_Create ( $hWnd, $sHeaderText, $iX, $iY [, $iWidth = 150 [, $iHeight = 150 [, $iStyle = 0x0000000D [, $iExStyle = 0x00000000 [, $bCoInit = False]]]]] )
_GUICtrlListView_SetExtendedListViewStyle($Listview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES));$LVS_EX_TRACKSELECT

;GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")
;GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,_Arrange_List())

_Create_List()

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_LBUTTONUP, "WM_LBUTTONUP")


While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_PRIMARYDOWN
			_Arrange_List()
	EndSwitch
WEnd



;MsgBox($MB_SYSTEMMODAL, "Information", "Hot Cursor Handle: 0x" & Hex(_GUICtrlListView_GetHotCursor($idListview)) & @CRLF & _
;            "IsPtr = " & IsPtr(_GUICtrlListView_GetHotCursor($idListview)) & " IsHWnd = " & IsHWnd(_GUICtrlListView_GetHotCursor($idListview)))

Func _Create_List()
    Local $Item
    While $Item <> "XXXXXXXX"
        $Item = $Item & "X"
        ;GUICtrlCreateListViewItem($Item, $Listview)
        _GUICtrlListView_AddItem($Listview, $Item)
    Wend
Endfunc

Func _Arrange_List()
    $Selected = _GUICtrlListView_GetHotItem($Listview)
	;_GUICtrlListView_CreateDragImage ( $Listview, $Selected )
	;hotitem is the index of the selected item (starts from 0)
	;MsgBox($MB_OK, "what is hotitem?", $Selected)
    If $Selected = -1 then Return
    While _IsPressed(1)
    WEnd
	;MsgBox($MB_OK, "did i release?", "maybe")
    $Dropped = _GUICtrlListView_GetHotItem($Listview)
	;MsgBox($MB_OK, "new hot item index?", $Dropped)
	;MsgBox($MB_OK, "hot tracking work or no?", _GUICtrlListView_GetHotCursor($Listview) & "|" & _GUICtrlListView_GetHotItem(_GUICtrlListView_GetHotCursor($Listview)))
    If $Dropped > -1 then
        _GUICtrlListView_BeginUpdate($Listview)
        If $Selected < $Dropped Then
            _GUICtrlListView_InsertItem($Listview, _GUICtrlListView_GetItemTextString($Listview, $Selected), $Dropped + 1)
            _GUICtrlListView_SetItemChecked($Listview, $Dropped + 1, _GUICtrlListView_GetItemChecked($Listview, $Selected))
            _GUICtrlListView_DeleteItem($Listview, $Selected)
        ElseIf $Selected > $Dropped Then
            _GUICtrlListView_InsertItem($Listview, _GUICtrlListView_GetItemTextString($Listview, $Selected), $Dropped)
            _GUICtrlListView_SetItemChecked($Listview, $Dropped, _GUICtrlListView_GetItemChecked($Listview, $Selected + 1))
            _GUICtrlListView_DeleteItem($Listview, $Selected + 1)
        EndIf
        _GUICtrlListView_EndUpdate($Listview)
    EndIf
	_WinAPI_RedrawWindow($Listview)
EndFunc



;this activates only when you drag the mouse heads up so NOT a single solo click
; WM_LBUTTONUP event handler
; ------------------------------------------------------
Func WM_LBUTTONUP($hWndGUI, $iMsgID, $wParam, $lParam)
	;MsgBox($MB_OK, "did i release?", "maybe")
    #forceref $iMsgID, $wParam
    $g_bDragging = False
    Local $aPos = ControlGetPos($hWndGUI, "", $g_hListView)
    Local $x = BitAND($lParam, 0xFFFF) - $aPos[0]
    Local $y = BitShift($lParam, 16) - $aPos[1]
    ;------------------------------------------------------
    ; done dragging
    ;------------------------------------------------------
    _GUIImageList_DragLeave($g_hListView)
		;Unlocks the specified window and hides the drag image, allowing the window to be updated
    _GUIImageList_EndDrag()
		;Ends a drag operation
    ;_GUIImageList_Destroy($g_ahDragImageList[0])
		;Destroys an image list
    _WinAPI_ReleaseCapture()
		;Releases the mouse capture from a window in the current thread and restores normal mouse input processing
    ;------------------------------------------------------
    ; do hit test see if drag ended in the listview
    ;------------------------------------------------------
    Local $tStruct_LVHITTESTINFO = DllStructCreate($tagLVHITTESTINFO)

    DllStructSetData($tStruct_LVHITTESTINFO, "X", $x)
    DllStructSetData($tStruct_LVHITTESTINFO, "Y", $y)
	; $g_hListView = _GUICtrlListView_Create
	;the handle to the ListView control.
	
    $g_aIndex[1] = _SendMessage($Listview, $LVM_HITTEST, 0, DllStructGetPtr($tStruct_LVHITTESTINFO), 0, "wparam", "ptr")
	MsgBox($MB_OK, "start index to end index", $initIndex & "|" & $g_aIndex[1])
    Local $iFlags = DllStructGetData($tStruct_LVHITTESTINFO, "Flags")
    ;------------------------------------------------------
    ; // Out of the ListView?
    ;------------------------------------------------------
    If $g_aIndex[1] == -1 Then Return $GUI_RUNDEFMSG
    ;------------------------------------------------------
    ; // Not in an item?
    ;------------------------------------------------------
    If BitAND($iFlags, $LVHT_ONITEMLABEL) == 0 And BitAND($iFlags, $LVHT_ONITEMSTATEICON) == 0 And BitAND($iFlags, $LVHT_ONITEMICON) = 0 Then Return $GUI_RUNDEFMSG
    ;------------------------------------------------------
    ; make sure insert is at least 2 items above or below, don't want to create a duplicate
    ;------------------------------------------------------
	#comments-start
    If $g_aIndex[0] < $g_aIndex[1] - 1 Or $g_aIndex[0] > $g_aIndex[1] + 1 Then
        Local $i_NewIndex = _LVInsertItem($g_aIndex[0], $g_aIndex[1])
        If @error Then Return SetError(-1, -1, $GUI_RUNDEFMSG)
        Local $iFrom_index = $g_aIndex[0]
        If $g_aIndex[0] > $g_aIndex[1] Then $iFrom_index = $g_aIndex[0] + 1
        ;------------------------------------------------------
        ; copy item and subitem(s) images, text, and state
        ;------------------------------------------------------
        For $x = 1 To _GUICtrlListView_GetColumnCount($g_hListView) - 1
            _LVCopyItem($iFrom_index, $i_NewIndex, $x)
            If @error Then Return SetError(-1, -1, $GUI_RUNDEFMSG)
        Next
        ;------------------------------------------------------
        ; delete from
        ;------------------------------------------------------
        _GUICtrlListView_DeleteItem($g_hListView, $iFrom_index)
    EndIf
	#comments-end
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_LBUTTONUP

; WM_NOTIFY event handler
; ------------------------------------------------------
Func WM_NOTIFY($hWndGUI, $iMsgID, $wParam, $lParam)
    #forceref $hWndGUI, $iMsgID, $wParam
    Local $tNMHDR, $iCode, $x, $y, $tNMLISTVIEW, $hWndFrom, $tDraw, $iDrawStage, $iItemSpec
    $tNMHDR = DllStructCreate($tagNMHDR, $lParam) ;NMHDR (hwndFrom, idFrom, code)
    ;If @error Then Return
    $iCode = DllStructGetData($tNMHDR, "Code")
    $hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
    Switch $hWndFrom
        Case $Listview
            Switch $iCode
                Case $LVN_BEGINDRAG
					$initIndex = _GUICtrlListView_GetHotItem($Listview)
					;MsgBox($MB_OK, "is this an index or what??", $initIndex)
					;MsgBox($MB_OK, "is this an index or what??", "test")
                    
                    $x = BitAND($lParam, 0xFFFF)
                    $y = BitShift($lParam, 16)
                    $tNMLISTVIEW = DllStructCreate($tagNMLISTVIEW, $lParam)
                    $g_aIndex[0] = DllStructGetData($tNMLISTVIEW, "Item")
                    $g_ahDragImageList = _GUICtrlListView_CreateDragImage($g_hListView, $g_aIndex[0])
                    If @error Then Return SetError(-1, -1, $GUI_RUNDEFMSG)

                    _GUIImageList_BeginDrag($g_ahDragImageList[0], 0, 0, 0)

                    If @error Then Return SetError(-1, -1, $GUI_RUNDEFMSG)
                    
                    _GUIImageList_DragEnter($g_hListView, $x, $y)
                    _WinAPI_SetCapture($hWndGUI)
                    $g_bDragging = True
                Case $NM_CUSTOMDRAW
                    $tDraw = DllStructCreate($tagNMLVCUSTOMDRAW, $lParam)
                    $iDrawStage = DllStructGetData($tDraw, "dwDrawStage")
                    $iItemSpec = DllStructGetData($tDraw, "dwItemSpec")
                    Switch $iDrawStage
                        Case $CDDS_PREPAINT
                    
                            Return $CDRF_NOTIFYITEMDRAW
                        Case $CDDS_ITEMPREPAINT
                    
                            If BitAND($iItemSpec, 1) = 1 Then
                                DllStructSetData($tDraw, "clrTextBk", $CLR_AQUA)
                            Else
                                DllStructSetData($tDraw, "clrTextBk", $CLR_WHITE)
                            EndIf
                            Return $CDRF_NEWFONT
                    EndSwitch
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY