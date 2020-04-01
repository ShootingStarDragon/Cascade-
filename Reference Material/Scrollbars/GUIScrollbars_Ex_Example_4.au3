#include <GUIConstantsEx.au3>
#include "GUIScrollbars_Ex.au3"

; Create GUI with red background
$hGUI = GUICreate("Test", 500, 500)
GUISetBkColor(0xFF0000, $hGUI)
; To get cursor keys to scroll GUI, create controls AFTER GUISetState
GUISetState()

; Create labels to show scrolling
GUICtrlCreateLabel("", 0, 0, 500, 500)
GUICtrlSetBkColor(-1, 0x00FF00)
GUICtrlCreateLabel("", 500, 500, 500, 500)
GUICtrlSetBkColor(-1, 0x00FF00)
GUICtrlCreateLabel("", 0, 500, 500, 500)
GUICtrlSetBkColor(-1, 0x0000FF)
GUICtrlCreateLabel("", 500, 0, 500, 500)
GUICtrlSetBkColor(-1, 0x0000FF)

GUICtrlCreateLabel("", 990, 990, 10, 10)
GUICtrlSetBkColor(-1, 0)

; Generate scrollbars and allow keys to scroll
_GUIScrollbars_Generate($hGUI, 1000, 1000, 0, 0, Default, 7)

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_RESTORE
			_GUIScrollbars_Restore($hGUI)
		Case $GUI_EVENT_MINIMIZE
			_GUIScrollbars_Minimize($hGUI)
	EndSwitch
WEnd