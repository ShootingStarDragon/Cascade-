#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>

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
$Label1b = GUICtrlCreateLabel("", 100, 40, 20, 20)
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
        _MouseUpdate()
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

Func _MouseUpdate()
	;update monitor name
    ;update the x coord label
	GUICtrlSetData($Label4, MouseGetPos()[0])
    GUICtrlSetColor($Label4, 0x00FF00)
	;update the y coord label
	GUICtrlSetData($Label5, MouseGetPos()[1])
    GUICtrlSetColor($Label5, 0x00FF00)
EndFunc