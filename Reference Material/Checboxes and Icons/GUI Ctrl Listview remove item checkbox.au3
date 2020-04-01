#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global $Debug_LV = False ; Check ClassName being passed to ListView functions, set to True and use a handle to another control to see it work

Global $hListView, $iIndex, $iIndex2, $iIndex3, $aIndexList[1]

_Main()

Func _Main()

    Local $GUI
    $GUI = GUICreate("(UDF Created) ListView Create", 400, 300)

    $hListView = _GUICtrlListView_Create($GUI, "", 2, 2, 394, 268)
    _GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES, $LVS_EX_CHECKBOXES))
    GUISetState()
    
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

    ; Add columns
    _GUICtrlListView_InsertColumn($hListView, 0, "Column 1", 100)
    _GUICtrlListView_InsertColumn($hListView, 1, "Column 2", 100)
    _GUICtrlListView_InsertColumn($hListView, 2, "Column 3", 100)

    ; Add items
    $iIndex = _GUICtrlListView_AddItem($hListView, "Row 1: Col 1")
    _GUICtrlListView_SetItemState($hListView, $iIndex, 0, $LVIS_STATEIMAGEMASK)
	$aIndexList[0] = $iIndex
    ;_WinAPI_RedrawWindow($hListView)
    _GUICtrlListView_AddSubItem($hListView, 0, "Row 1: Col 2", 1)
    _GUICtrlListView_AddSubItem($hListView, 0, "Row 1: Col 3", 2)
    $iIndex2 = _GUICtrlListView_AddItem($hListView, "Row 2: Col 1")
	_ArrayAdd ( $aIndexList, $iIndex2)
	_GUICtrlListView_SetItemState($hListView, $iIndex2, 0, $LVIS_STATEIMAGEMASK)
    _GUICtrlListView_AddSubItem($hListView, 1, "Row 2: Col 2", 1)
    $iIndex3 = _GUICtrlListView_AddItem($hListView, "Row 3: Col 1", 2)
	_ArrayAdd ( $aIndexList, $iIndex3)
	_GUICtrlListView_SetItemState($hListView, $iIndex3, 0, $LVIS_STATEIMAGEMASK)
	_WinAPI_RedrawWindow($hListView)

	;_ArrayDisplay ($aIndexList )
    ; Loop until user exits
    Do
    Until GUIGetMsg() = $GUI_EVENT_CLOSE
    GUIDelete()
EndFunc   ;==>_Main

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
    $hWndListView = $hListView

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					;HUGE HINT: convert "= $iIndex" into a search of an index list
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then 
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
							;
                        ;Return 1
						EndIf
						;MsgBox ( $MB_OK, "title", "click")
						;just need to Return 1 for some reason....
						Return 1
                    EndIf
                    
                Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
                        Return 1
						MsgBox ( $MB_OK, "title", "click2")
                    EndIf
                    
                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
                        Return 1
						MsgBox ( $MB_OK, "title", "click3")
                    EndIf

                Case $NM_RDBLCLK ; Sent by a list-view control when the user double-clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
                        Return 1
						MsgBox ( $MB_OK, "title", "click4")
                    EndIf
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
;    #forceref $hWnd, $iMsg, $iwParam
;    Local $hWndFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
;    $hWndListView = $hListView
;
;    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
;    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
;    $iCode = DllStructGetData($tNMHDR, "Code")
;    Switch $hWndFrom
;        Case $hWndListView
;            Switch $iCode
;                Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
;                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
;					;HUGE HINT: convert "= $iIndex" into a search of an index list
;                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
;					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
;                        If Not _GUICtrlListView_GetItemSelected($hListView, $iIndex) Then _
;                            _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
;                        Return 1
;                    EndIf
;                    
;                Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
;                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
;                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
;					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
;                        If Not _GUICtrlListView_GetItemSelected($hListView, $iIndex) Then _
;                            _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
;                        Return 1
;                    EndIf
;                    
;                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
;                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
;                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
;					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
;                        _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
;                        Return 1
;                    EndIf
;
;                Case $NM_RDBLCLK ; Sent by a list-view control when the user double-clicks an item with the right mouse button
;                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
;                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
;					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
;                        If Not _GUICtrlListView_GetItemSelected($hListView, $iIndex) Then _
;                            _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
;                        Return 1
;                    EndIf
;            EndSwitch
;    EndSwitch
;    Return $GUI_RUNDEFMSG
;EndFunc   ;==>WM_NOTIFY