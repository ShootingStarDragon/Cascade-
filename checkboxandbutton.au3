#include <GUIConstantsEx.au3>

$hGUI = GUICreate("Test", 500, 500)

$hCheck1 = GUICtrlCreateCheckbox(" Check 1", 10, 10, 200, 20)
$hCheck2 = GUICtrlCreateCheckbox(" Check 1", 10, 50, 200, 20)
$hButton = GUICtrlCreateButton("Press!", 10, 100, 80, 30)

GUISetState()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $hButton
            If GUICtrlRead($hCheck1) = 1 Then
                If GUICtrlRead($hCheck2) = 1 Then
                    MsgBox(0, "Checked", "Check 1 and Check 2")
                Else
                    MsgBox(0, "Checked", "Check 1")
                EndIf
            ElseIf GUICtrlRead($hCheck2) = 1 Then
                MsgBox(0, "Checked", "Check 2")
            EndIf
    EndSwitch
WEnd