#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

; Mouse coords relative to GUI client area
Opt("MouseCoordMode", 2)

; Set target coords
Global $iTgt_Left = 10, $iTgt_Right = 210, $iTgt_Top = 10, $iTgt_Bot = 110

; Create GUI
$hGUI = GUICreate("Test", 300, 200)

$cTarget = GUICtrlCreateLabel("", $iTgt_Left, $iTgt_Top, $iTgt_Right - $iTgt_Left, $iTgt_Bot - $iTgt_Top, $SS_BLACKFRAME)
GUICtrlSetState(-1, $GUI_DISABLE)

$cLabel = GUICtrlCreateLabel("Move me", 10, 150, 60, 20)
GUICtrlSetBkColor(-1, 0x00FF00)

$cButton = GUICtrlCreateButton("Me too", 110, 150, 80, 23)

GUISetState()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $GUI_EVENT_PRIMARYDOWN
            ; If the mouse button is pressed - get info about where
            $cInfo = GUIGetCursorInfo($hGUI)
            ; Is it over a control
            $iControl = $cInfo[4]
            Switch $iControl
                ; If it is a control we want to move
                Case $cLabel, $cButton
                    ; Work out offset of mouse on control
                    $aPos = ControlGetPos($hGUI, "", $iControl)
                    $iSubtractX = $cInfo[0] - $aPos[0]
                    $iSubtractY = $cInfo[1] - $aPos[1]
                    ; And then move the control until the mouse button is released
                    Do
                        $cInfo = GUIGetCursorInfo($hGUI)
                        ControlMove($hGUI, "", $iControl, $cInfo[0] - $iSubtractX, $cInfo[1] - $iSubtractY)
                    Until Not $cInfo[2]
                    ; See if the mouse was released over the target
                    $aMPos = MouseGetPos()
                    If $aMPos[0] > $iTgt_Left And $aMPos[0] < $iTgt_Right Then
                        If $aMPos[1] > $iTgt_Top And $aMPos[1] < $iTgt_Bot Then
                            Switch $iControl
                                Case $cLabel
                                    $sItem = "label"
                                Case $cButton
                                    $sItem = "button"
                            EndSwitch
                            MsgBox(0, "Info", "Over target with " & $sItem)
                        EndIf
                    EndIf

            EndSwitch
    EndSwitch
WEnd