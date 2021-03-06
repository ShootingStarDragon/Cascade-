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


;THE ORIGINAL ---> $Listview = _GUICtrlListView_Create($theGUI, "filename", 0, 0, 200, 400);
$weirdListview = GUICtrlCreateListView($theGUI, 0, 0, 200, 400)
$Listview = GUICtrlGetHandle( $weirdListview )    

;_GUICtrlListView_Create ( $hWnd, $sHeaderText, $iX, $iY [, $iWidth = 150 [, $iHeight = 150 [, $iStyle = 0x0000000D [, $iExStyle = 0x00000000 [, $bCoInit = False]]]]] )
_GUICtrlListView_SetExtendedListViewStyle($Listview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES));$LVS_EX_TRACKSELECT

_Create_List()

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_LBUTTONUP, "WM_LBUTTONUP")

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd


Func _Create_List()
    Local $Item
    While $Item <> "XXXXXXXX"
        $Item = $Item & "X"
        _GUICtrlListView_AddItem($Listview, $Item)
    Wend
Endfunc

;this activates only when you drag the mouse heads up so NOT a single solo click
; WM_LBUTTONUP event handler
; ------------------------------------------------------
Func WM_LBUTTONUP($hWndGUI, $iMsgID, $wParam, $lParam)
	;MsgBox($MB_OK, "did i release?", "maybe")
    #forceref $iMsgID, $wParam
    
    Local $aPos = ControlGetPos($hWndGUI, "", $g_hListView)
    Local $x = BitAND($lParam, 0xFFFF) - $aPos[0]
    Local $y = BitShift($lParam, 16) - $aPos[1]
    Local $tStruct_LVHITTESTINFO = DllStructCreate($tagLVHITTESTINFO)
    DllStructSetData($tStruct_LVHITTESTINFO, "X", $x)
    DllStructSetData($tStruct_LVHITTESTINFO, "Y", $y)
	; $g_hListView = _GUICtrlListView_Create
	;the handle to the ListView control.
	
    $g_aIndexX = _SendMessage($Listview, $LVM_HITTEST, 0, DllStructGetPtr($tStruct_LVHITTESTINFO), 0, "wparam", "ptr")
	MsgBox($MB_OK, "start index to end index", $initIndex & "|" & $g_aIndexX)

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
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY