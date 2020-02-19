;USEFUL FUNCS
;GET WINDOW
;GUI CREATE
;WINMOVE
;_WinAPI_GetMonitorInfo
;print

#include <MsgBoxConstants.au3>
#include <WinAPIGdi.au3>
;Global $tellme
$tellme = _WinAPI_GetMonitorInfo ( $hMonitor )

MsgBox($MB_OK, "Example", "My variable is " & $tellme)