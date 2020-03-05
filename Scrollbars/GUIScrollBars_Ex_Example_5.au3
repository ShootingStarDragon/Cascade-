#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>

#include <GUIScrollbars_Ex.au3>

Global $iGUI_1_MinX = 300, $iGUI_1_MinY = 200
Global $iGUI_1_MaxX, $iGUI_1_MaxY

MsgBox($MB_SYSTEMMODAL, "GUI 1", "This GUI is created smaller than the desired scrollable area." & @CRLF & @CRLF & "It also uses the returned array to prevent the GUI being oversized")

_Resizeable(1, 400, False, True)

MsgBox($MB_SYSTEMMODAL, "GUI 2", "This GUI is displayed the same size as the desired scrollable area," & @CRLF & "so the scrollbars are not displayed on creation." & @CRLF & @CRLF & _
									"The GUI is resized to ensure that this is the case" & @CRLF & "even if it was created with other dimensions")

_Resizeable(2, 400, True)

MsgBox($MB_SYSTEMMODAL, "GUI 3", "This GUI is created larger than the desired scrollable area," & @CRLF & "but they will appear when the GUI becomees too small")

_Resizeable(3, 600)

Func _Resizeable($iIndex, $iInitialSize, $bFullClient = False, $bMaxSize = False)

	Local $iMax_Scroll = 500

	Local $hGUI = GUICreate("Resizeable Test " & $iIndex, $iInitialSize, $iInitialSize, Default, Default, $WS_SIZEBOX)
	GUISetBkColor(0xCCFFCC)

	Local $cStart = GUICtrlCreateDummy()
	GUICtrlCreateLabel("", 0, 0, 500, 500)
	GUICtrlSetBkColor(-1, 0xFFCCCC)
	GUICtrlCreateLabel("Use me to check that the scrolled position" & @CRLF & "is maintained if possible during resizing", 50, 50, 300, 50)
	GUICtrlSetBkColor(-1, 0xCCCCFF)
	GUICtrlCreateLabel("", 0, 0, 10, 10)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GUICtrlCreateLabel("", 0, 490, 10, 10)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GUICtrlCreateLabel("", 490, 0, 10, 10)
	GUICtrlSetBkColor(-1, 0xFF0000)
	GUICtrlCreateLabel("", 490, 490, 10, 10)
	GUICtrlSetBkColor(-1, 0xFF0000)
	Local $cEnd = GUICtrlCreateDummy()
	For $i = $cStart To $cEnd
		GUICtrlSetResizing($i, $GUI_DOCKALL)
	Next

	; Generate initial scrollbars - required scrollbar handlers registered
	_GUIScrollbars_Generate($hGUI, $iMax_Scroll, $iMax_Scroll)
	; Intialise for resizing
	Local $aMaxSize = _GUIScrollbars_ReSizer($hGUI, $iMax_Scroll, $iMax_Scroll, $bFullClient)

	GUISetState(@SW_SHOW)

	If $bMaxSize Then
		$iGUI_1_MaxX = $aMaxSize[0]
		$iGUI_1_MaxY = $aMaxSize[1]
		GUIRegisterMsg($WM_GETMINMAXINFO, "_WM_GETMINMAXINFO")
	EndIf

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	GUIRegisterMsg($WM_GETMINMAXINFO, "")
	GUIDelete($hGUI)

EndFunc

Func _WM_GETMINMAXINFO($hWnd, $iMsg, $wParam, $lParam)
	Local $tagMaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
	DllStructSetData($tagMaxinfo, 7, $iGUI_1_MinX)  ; min X
	DllStructSetData($tagMaxinfo, 8, $iGUI_1_MinY)   ; min Y
	DllStructSetData($tagMaxinfo, 9, $iGUI_1_MaxX ) ; max X
	DllStructSetData($tagMaxinfo, 10, $iGUI_1_MaxY ) ; max Y
	Return 0
EndFunc   ;==>_WM_GETMINMAXINFO