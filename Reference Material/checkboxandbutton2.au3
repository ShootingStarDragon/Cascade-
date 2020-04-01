#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>

;$hGUI = GUICreate("Test", 500, 500)
$hGUI = GUICreate("Test")

$hCheck1 = GUICtrlCreateCheckbox(" Check 1", 10, 10, 200, 20)
$hCheck2 = GUICtrlCreateCheckbox(" Check 1", 10, 50, 200, 20)
$hCheck3 = GUICtrlCreateCheckbox(" Check Monitor", 10, 90, 200, 20)
$hButton = GUICtrlCreateButton("Press!", 10, 100, 80, 30)

GUISetState()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $hButton
			If  GUICtrlRead($hCheck3) = 1 Then
				$MonitorHandle = _WinOnMonitor(WinGetPos("[ACTIVE]")[0], WinGetPos("[ACTIVE]")[1])
				 MsgBox(0, "Checked", _WinAPI_GetMonitorInfo($MonitorHandle)[3])
			EndIf
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

Func _WinOnMonitor($iXPos, $iYPos)
    Local $aMonitors = _WinAPI_EnumDisplayMonitors()
    If IsArray($aMonitors) Then
        ReDim $aMonitors[$aMonitors[0][0] + 1][5]
        For $ix = 1 To $aMonitors[0][0]
            $aPos = _WinAPI_GetPosFromRect($aMonitors[$ix][1])
            For $j = 0 To 3
                $aMonitors[$ix][$j + 1] = $aPos[$j]
            Next
        Next
    EndIf
    For $ixMonitor = 1 to $aMonitors[0][0] ; Step through array of monitors
        If $iXPos > $aMonitors[$ixMonitor][1] And $iXPos <  $aMonitors[$ixMonitor][1] + $aMonitors[$ixMonitor][3] Then
            If $iYPos > $aMonitors[$ixMonitor][2] And $iYPos < $aMonitors[$ixMonitor][2] + $aMonitors[$ixMonitor][4] Then
                Return $aMonitors[$ixMonitor][0] ; return handle to monitor coordinate is on
            EndIf
        EndIf
    Next
    Return 0 ;Return 0 if coordinate is on none of the monitors
EndFunc ;==>  _WinOnMonitor