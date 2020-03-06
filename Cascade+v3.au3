#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>

;make a dropdown list of monitors
dim $MonitorArray[1]

$Monitors = _WinAPI_EnumDisplayMonitors()

;MsgBox ( $MB_OK, "title1", $Monitors[0][0])
;MsgBox ( $MB_OK, "title2", _WinAPI_GetMonitorInfo($Monitors[1][0])[3])

For $intmon = 1 To $Monitors[0][0]
	;MsgBox($MB_OK, "title1", $intmon)
	;_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	Next

;remove empty init element in MonitorArray
_ArryRemoveBlanks($MonitorArray)

$hGUI = GUICreate("Cascade+")

; And here we get the elements into a list
$sList = ""
For $i = 0 To UBound($MonitorArray) - 1
	$sList &= "|" & $MonitorArray[$i]
Next

; Create the combo
$hCombo = GUICtrlCreateCombo("", 10, 10, 200, 20)
; And fill it
GUICtrlSetData($hCombo, $sList)

$Label1 = GUICtrlCreateLabel("Current Monitor", 10, 40)
$Label1b = GUICtrlCreateLabel("", 100, 40, 200, 20)
$Label2 = GUICtrlCreateLabel("Mouse X Coord", 10, 60)
$Label3 = GUICtrlCreateLabel("Mouse Y Coord", 10, 80)
;x coord update
$Label4 = GUICtrlCreateLabel("", 100, 60, 20, 20)
;y coord update
$Label5 = GUICtrlCreateLabel("", 100, 80, 20, 20)


Global $time = -1

GUISetState()
While 1
	If $time = -1 Then ; this should only run once
        _StartTimer()
    EndIf
	
	Sleep(10)
    ;If TimerDiff($time) > 5000 Then
	If TimerDiff($time) > 1000 Then
        _UpdateInfo()
        $time = 0
        $time = TimerInit()
    EndIf
	
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func _StartTimer()
    $time = TimerInit()
EndFunc

Func _UpdateInfo()
	;update monitor name
    ;update the x coord label
	GUICtrlSetData($Label4, MouseGetPos()[0])
    GUICtrlSetColor($Label4, 0x00FF00)
	;update the y coord label
	GUICtrlSetData($Label5, MouseGetPos()[1])
    GUICtrlSetColor($Label5, 0x00FF00)
	;_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1])
	GUICtrlSetData($Label1b, _WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))[3])
    GUICtrlSetColor($Label1b, 0x00FF00)
EndFunc

Func _ArryRemoveBlanks(ByRef $arr)
  $idx = 0
  For $i = 0 To UBound($arr) - 1
    If $arr[$i] <> "" Then
      $arr[$idx] = $arr[$i]
      $idx += 1
    EndIf
  Next
  ReDim $arr[$idx]
EndFunc ;==>_ArryRemoveBlanks

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