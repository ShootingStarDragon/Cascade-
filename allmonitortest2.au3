; #FUNCTION# ====================================================================================================================
; Name ..........: _DesktopDimensions
; Description ...: Returns an array containing information about the primary and virtual monitors.
; Syntax ........: _DesktopDimensions()
; Return values .: Success - Returns a 6-element array containing the following information:
;                  $aArray[0] = Total number of monitors.
;                  $aArray[1] = Width of the primary monitor.
;                  $aArray[2] = Height of the primary monitor.
;                  $aArray[3] = Total width of the desktop including the width of multiple monitors. Note: If no secondary monitor this will be the same as $aArray[2].
;                  $aArray[4] = Total height of the desktop including the height of multiple monitors. Note: If no secondary monitor this will be the same as $aArray[3].
; Author ........: guinness
; Remarks .......: WinAPI.au3 must be included i.e. #include <WinAPI.au3>
; Related .......: @DesktopWidth, @DesktopHeight, _WinAPI_GetSystemMetrics
; Example .......: Yes
; ===============================================================================================================================
Func _DesktopDimensions()
    Local $aReturn = [_WinAPI_GetSystemMetrics($SM_CMONITORS), _ ; Number of monitors.
            _WinAPI_GetSystemMetrics($SM_CXSCREEN), _ ; Width or Primary monitor.
            _WinAPI_GetSystemMetrics($SM_CYSCREEN), _ ; Height or Primary monitor.
            _WinAPI_GetSystemMetrics($SM_CXVIRTUALSCREEN), _ ; Width of the Virtual screen.
            _WinAPI_GetSystemMetrics($SM_CYVIRTUALSCREEN)] ; Height of the Virtual screen.
    Return $aReturn
EndFunc   ;==>_DesktopDimensions

#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPIMisc.au3>

Local $aScreenResolution = _DesktopDimensions()
$Monitors = _WinAPI_EnumDisplayMonitors()
MsgBox($MB_SYSTEMMODAL, 'Is this window name?', 'Example of _DesktopDimensions:' & @CRLF & _
        'Number of monitors = ' & $aScreenResolution[0] & @CRLF & _
        'Primary Width = ' & $aScreenResolution[1] & @CRLF & _
        'Primary Height = ' & $aScreenResolution[2] & @CRLF & _
        'Secondary (virtual?) Width = ' & $aScreenResolution[3] & @CRLF & _
        'Secondary (virtual?)Height = ' & $aScreenResolution[4] & @CRLF & _
		'total # monitors' & $Monitors[0][0] & @CRLF & _
		'monitor 1 handle' & $Monitors[1][0] & @CRLF & _
		'monitor 2 handle' & $Monitors[2][0] & @CRLF & _
		'monitor 1 rectangle coords:   ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 1) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 2) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 3) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 4) & @CRLF & _
		'Rectangle1 data rawA|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 0) & @CRLF & _
		'structcheck ' 			& DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 0) & @CRLF & _
		DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 1) & @CRLF & _
		DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 2) & @CRLF & _
		DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 3) & @CRLF & _
		DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 4) & @CRLF & _
		'Rectangle1 data rawB|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[1], 0) & '|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[1], 1) & '|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[1], 2) & '|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[1], 3) & '|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[1], 4)  & @CRLF & _
		'Rectangle1 data rawC|' & _WinAPI_GetMonitorInfo($Monitors[1][0])[2]  & @CRLF & _
		'Rectangle1 data rawD|' & _WinAPI_GetMonitorInfo($Monitors[1][0])[3]  & @CRLF & _
		'Rectangle2:   ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 1) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 2) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 3) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 4) & @CRLF & _
		'Rectangle2 data rawA|' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 0) & @CRLF & _
		'Rectangle2 data rawB|' & _WinAPI_GetMonitorInfo($Monitors[2][0])[1] & @CRLF & _
		'Rectangle2 data rawC|' & _WinAPI_GetMonitorInfo($Monitors[2][0])[2] & @CRLF & _
		'Rectangle2 data rawD|' & _WinAPI_GetMonitorInfo($Monitors[2][0])[3] & @CRLF & _
		'GET LIST OF WINDOWS |' & UBound(WinList()))
		;'Rectangle1:   ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 1) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 2) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 3) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[1][0])[0], 4) & @CRLF & _
		;'Rectangle1:   ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 1) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 2) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 3) & ', ' & DllStructGetData(_WinAPI_GetMonitorInfo($Monitors[2][0])[0], 4))
		
		
		
		;'Work area:   ' & DllStructGetData($_WinAPI_GetMonitorInfo($Monitors[2][0])[1], 1) & ', ' & DllStructGetData($_WinAPI_GetMonitorInfo($Monitors[2][0])[1], 2) & ', ' & DllStructGetData($_WinAPI_GetMonitorInfo($Monitors[2][0])[1], 3) & ', ' & DllStructGetData($_WinAPI_GetMonitorInfo($Monitors[2][0])[1], 4) & @CRLF & _
		;'Primary check mon1:' & $_WinAPI_GetMonitorInfo($Monitors[1][0])[2] & @CRLF & _
		;'Device name mon1: ' & $_WinAPI_GetMonitorInfo($Monitors[1][0])[3] & @CRLF & _
		;'Primary check mon2:' & $_WinAPI_GetMonitorInfo($Monitors[2][0])[2] & @CRLF & _
		;'Device name mon2: ' & $_WinAPI_GetMonitorInfo($Monitors[2][0])[3] & @CRLF)
		
		
		;'2nd monitor width = ' & $Monitors[2][0] & @CRLF & _
		;'2nd monitor height = ' & $Monitors[2][1])