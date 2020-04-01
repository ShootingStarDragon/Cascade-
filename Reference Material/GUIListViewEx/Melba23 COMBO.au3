#include <GUIConstantsEx.au3>

; Here is the array
Global $aArray[5] = ["A", "B", "C", "D", "E"]

; And here we get the elements into a list
$sList = ""
For $i = 0 To UBound($aArray) - 1
    $sList &= "|" & $aArray[$i]
Next

; Create a GUI
#include <GUIConstantsEx.au3>

$hGUI = GUICreate("Test", 500, 500)

; Create the combo
$hCombo = GUICtrlCreateCombo("", 10, 10, 200, 20)
; And fill it
GUICtrlSetData($hCombo, $sList)

GUISetState()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
WEnd