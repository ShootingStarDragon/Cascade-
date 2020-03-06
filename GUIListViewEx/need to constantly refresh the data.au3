#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Global $time = -1

If @IPAddress1 > 1 Then
    $ipAddress = @IPAddress1
EndIf
If @IPAddress2 > 1 Then
    $ipAddress = @IPAddress1
EndIf
If @IPAddress3 > 1 Then
    $ipAddress = @IPAddress1
EndIf
If @IPAddress4 > 1 Then
    $ipAddress = @IPAddress1
EndIf

$Form1 = GUICreate("Form1", 235, 158)
$Label1 = GUICtrlCreateLabel("Computer Name", 8, 16, 80, 17)
$Label2 = GUICtrlCreateLabel("IP Address", 8, 32, 55, 17)
$Label3 = GUICtrlCreateLabel("Ping Internal Server", 8, 48, 105, 17)
$Label4 = GUICtrlCreateLabel("Ping google.com", 8, 64, 83, 17)
$Label5 = GUICtrlCreateLabel(@ComputerName, 120, 16, 100, 17)
$Label6 = GUICtrlCreateLabel($ipAddress, 120, 32, 100, 17)
$Label7 = GUICtrlCreateLabel("", 120, 48, 100, 17)
$Label8 = GUICtrlCreateLabel("", 120, 64, 100, 17)
$Label9 = GUICtrlCreateLabel("You can try restarting the modem by", 8, 96, 173, 17)
$Label10 = GUICtrlCreateLabel("removing the power, waiting a few seconds,", 8, 112, 219, 17)
$Label11 = GUICtrlCreateLabel("and plugging the power back in", 8, 128, 153, 17)
GUISetState(@SW_SHOW)

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch

    If $time = -1 Then ; this should only run once
        _StartTimer()
    EndIf

    Sleep(10)
    ;If TimerDiff($time) > 5000 Then
	If TimerDiff($time) > 1000 Then
        _Pings()
        $time = 0
        $time = TimerInit()
    EndIf
WEnd

Func _Pings()
    $intServer = 0
    $intServer = Ping("stormyeye01") ; Change this to your internal server's name
    If $intServer > 0 Then
        GUICtrlSetData($Label7, "OK")
        GUICtrlSetColor($Label7, 0x00FF00)
    Else
        GUICtrlSetData($Label7, "Error")
        GUICtrlSetColor($Label7, 0xFF0000)
    EndIf

    $google = 0
    $google = Ping("google.com")
    If $google > 0 Then
        ;GUICtrlSetData($Label8, "OK")
		GUICtrlSetData($Label8, MouseGetPos()[0])
        GUICtrlSetColor($Label8, 0x00FF00)
    Else
        ;GUICtrlSetData($Label8, "Error")
		GUICtrlSetData($Label8, MouseGetPos()[0])
        GUICtrlSetColor($Label8, 0xFF0000)
    EndIf
EndFunc

Func _StartTimer()
    $time = TimerInit()
EndFunc