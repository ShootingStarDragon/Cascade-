#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
    Local $hGUI = GUICreate('_ControlMove()', 300, 200)
    Local $iLabel = GUICtrlCreateLabel('Move It', 100, 50, 60, 20)
    GUICtrlSetBkColor(-1, 0x00FF00)
    GUISetState(@SW_SHOW, $hGUI)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit

            Case $GUI_EVENT_PRIMARYDOWN
                _ControlMove($iLabel)

        EndSwitch
    WEnd
EndFunc   ;==>Example

Func _ControlMove($iControlID) ; By Melba23
    Local Const $SC_MOVE = 0xF010
    Local $aReturn = GUIGetCursorInfo()
    If @error Then
        Return 0
    EndIf
    If $aReturn[4] = $iControlID Then
        GUICtrlSendMsg($iControlID, $WM_SYSCOMMAND, BitOR($SC_MOVE, $HTCAPTION), 0)
    EndIf
EndFunc   ;==>_ControlMove