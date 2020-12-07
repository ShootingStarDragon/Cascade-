#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

; Create an array to test
Global $aArray[20]
For $i = 0 To 19
    $aArray[$i] = "Element " & $i

Next

$hGUI = GUICreate("Test", 500, 500)

$cLV = GUICtrlCreateListView("Array Elements As Checked", 10, 10, 200, 200)

$cInput = GUICtrlCreateInput("", 10, 250, 200, 20)
GUICtrlSetState($cInput, $GUI_DISABLE)

$cAccept = GUICtrlCreateButton("Accept Edit", 10, 300, 80, 30)
GUICtrlSetState($cAccept, $GUI_DISABLE)
$cCancel = GUICtrlCreateButton("Cancel Edit", 100, 300, 80, 30)
GUICtrlSetState($cCancel, $GUI_DISABLE)

$cStart = GUICtrlCreateButton("Start", 10, 400, 80, 30)

GUISetState()

While 1

    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $cStart

            For $i = 0 To UBound($aArray) - 1
                _TestElement($i)
            Next
    EndSwitch



WEnd



Func _TestElement($iElementIndex)

    $sText = $aArray[$iElementIndex]

    If StringRight($sText, 1) = "7" Then ; A simple test to allow for editing
        GUICtrlSetState($cInput, $GUI_ENABLE)
        GUICtrlSetState($cAccept, $GUI_ENABLE)
        GUICtrlSetState($cCancel, $GUI_ENABLE)

        GUICtrlSetData($cInput, $sText)

        While 1
            Switch GUIGetMsg()
                Case $cAccept

                    $aArray[$iElementIndex] = GUICtrlRead($cInput)
                    ExitLoop

                Case $cCancel

                    ExitLoop

            EndSwitch

        WEnd



        GUICtrlSetState($cInput, $GUI_DISABLE)
        GUICtrlSetState($cAccept, $GUI_DISABLE)
        GUICtrlSetState($cCancel, $GUI_DISABLE)

        GUICtrlSetData($cInput, "")

    EndIf



    GUICtrlCreateListViewItem($aArray[$iElementIndex], $cLV)

EndFunc