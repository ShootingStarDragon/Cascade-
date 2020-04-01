#include <Array.au3>
#include <Process.au3>

;Get a list of visable windows with titles.
$aWindows = _GetVisibleWindows()
_ArrayDisplay($aWindows)


Func _GetVisibleWindows()
    ;Retrieve a list of windows.
    Local $aWinList = WinList()
    If Not IsArray($aWinList) Then Return SetError(0, 0, 0)

    ;Loop through the array deleting no title or invisable windows.
    Local $sDeleteRows = ""
    For $i = 1 To $aWinList[0][0]
        If $aWinList[$i][0] = "" Or Not BitAND(WinGetState($aWinList[$i][1]), $WIN_STATE_VISIBLE) Then
            $sDeleteRows &= $i & ";"
        EndIf
    Next
    $sDeleteRows = StringTrimRight($sDeleteRows, 1) ;Remove last ";".
    _ArrayDelete($aWinList, $sDeleteRows)
    $aWinList[0][0] = UBound($aWinList) - 1

    ;Get Window's Processor ID (PID), and add to the array.
    _ArrayColInsert($aWinList, UBound($aWinList, 2))
    For $i = 1 To $aWinList[0][0]
        $aWinList[$i][2] = WinGetProcess($aWinList[$i][1])  
    Next

    ;Get Window's Process Name from PID, and add to the array.
    _ArrayColInsert($aWinList, UBound($aWinList, 2))
    For $i = 1 To $aWinList[0][0]
        $aWinList[$i][3] = _ProcessGetName($aWinList[$i][2])
    Next
    
    ;Get Windows's Position and Size, and add it to the array. 
    ;For Position, -3200,-3200 is minimized window, -8,-8 is maximized window on 1st display, and
    ;x,-8 is maximized windown on the nth display were x is the nth display width plus -8 (W + -8).
    _ArrayColInsert($aWinList, UBound($aWinList, 2)) ;Position (X,Y).
    _ArrayColInsert($aWinList, UBound($aWinList, 2)) ;Dimension (WxH). 
    Local $aWinPosSize
    For $i = 1 To $aWinList[0][0]
        $aWinPosSize = WinGetPos($aWinList[$i][1])
        $aWinList[$i][4] = $aWinPosSize[0] & "," & $aWinPosSize[1]
        $aWinList[$i][5] = $aWinPosSize[2] & "x" & $aWinPosSize[3]
    Next
    
    Return $aWinList
EndFunc   ;==>_GetVisibleWindows