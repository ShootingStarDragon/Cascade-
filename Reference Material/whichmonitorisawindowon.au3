#include <WinAPIGdi.au3> ;for _WinOnMonitor()

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