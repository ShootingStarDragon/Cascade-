#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <Process.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
Example()

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

Func Example()
    ; Retrieve a list of window handles.
    Local $aList = WinList("[REGEXPTITLE:(?i)(.+)]")
	#comments-start
		The array returned is two-dimensional and is made up as follows:
		$aArray[0][0] = Number of windows returned
		$aArray[1][0] = 1st window title
		$aArray[1][1] = 1st window handle (HWND)
		$aArray[2][0] = 2nd window title
		$aArray[2][1] = 2nd window handle (HWND)
	#comments-end

	Local $aListFiltered[0]
	;filtered list is just a 1d array of handles (HWND)
	
	;filter winlist to get rid of windows with no titles and manually remove program manager
	For $i = 1 to $aList[0][0]
		;have to manually remove program manager I think
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) == 2 And $aList[$i][0] <> "Program Manager" Then
			_ArrayAdd($aListFiltered, $aList[$i][1])
		EndIf
	Next
	;let's check it right now by displaying aListFiltered
	;_ArrayDisplay($aListFiltered, "check")
	
	;make the array with info:
	;NAME			HWND 			exe name 		position 	size
	;array size is Ubound of the filtered list and 5 columns
	;make empty array
	Local $aArrayFinal[UBound($aListFiltered, 1)][5]
	;MsgBox ( $MB_OK, "title", UBound($aListFiltered, 1) & "|" &  UBound($aArrayFinal, 0) & "|" & UBound($aArrayFinal, 1) & "|" & UBound($aArrayFinal, 2) )
	
	;populate array
	For $i = 0 to UBound($aListFiltered, 1)-1
		;MsgBox ( $MB_OK, "title", $i & UBound($aListFiltered, 1) & WinGetTitle($aListFiltered[$i]) & $aListFiltered[$i] & _ProcessGetName($aListFiltered[$i]) & WinGetPos ($aListFiltered[$i]) & WinGetClientSize ($aListFiltered[$i]))
		;name
		$aArrayFinal[$i][0] = WinGetTitle($aListFiltered[$i])
		;HWND
		$aArrayFinal[$i][1] = $aListFiltered[$i]
		;exe name
		$aArrayFinal[$i][2] = _ProcessGetName(WinGetProcess($aListFiltered[$i]))
		;pos
		$aArrayFinal[$i][3] = WinGetPos($aListFiltered[$i])[0] & "," & WinGetPos($aListFiltered[$i])[1]
		;size
		$aArrayFinal[$i][4] = WinGetClientSize($aListFiltered[$i])[0] & "," & WinGetClientSize($aListFiltered[$i])[1]
	Next
	
	;display array now
	;_ArrayDisplay($aArrayFinal, "check")
	
	#comments-start
	;probably need a func that tells you which monitor you are on
	;now that we have the data all i need to do is give the user some options:
	;#1: Monitors available to cascade through
	;#2: which windows I should cascade 
	;#3: cascade style
		#3a: size for the box that I should use to cascade (warn if not enough space)
		#3b: input a length and that would be the long side of an isoceles triangle starting from the upper left corner of the chosen monitor( monitorS ideally tho)
		
	#comments-end
	$hGUI = GUICreate("Cascade+")
	
	;make a button for each monitor
	$Monitors = _WinAPI_EnumDisplayMonitors()
	
	dim $Menu[1]
	
	MsgBox ( $MB_OK, "title", _WinAPI_GetMonitorInfo($Monitors[1][0])[3])
	For $i = 0 to _WinAPI_GetSystemMetrics($SM_CMONITORS)-1
		;$Menu[$i] = GUICtrlCreateCheckbox(" Check 1", 10, 10)
		_ArrayAdd($Menu, GUICtrlCreateCheckbox(_WinAPI_GetMonitorInfo($Monitors[$i+1][0])[3], 10, 10 + 40*$i))
		;$hCheck1 = GUICtrlCreateCheckbox(String(_WinAPI_GetMonitorInfo($Monitors[1][0])[3]))
	Next
	
	;_WinOnMonitor($iXPos, $iYPos)
	
	;make a button for each window in aArrayFinal
	;$hCheck1 = GUICtrlCreateCheckbox(, 10, 10, 200, 20)
	GUISetState()
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit
		EndSwitch
	WEnd
	
	#comments-start
    ; Loop through the array displaying only visible windows with a title.
	;blank string
	Local $sFill = ""
    For $i = 1 To $aList[0][0]
		;have to manually remove program manager I think
        ;If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) And $aList[$i][0] <> "Program Manager" Then
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) == 2 And $aList[$i][0] <> "Program Manager" Then
            ;MsgBox($MB_SYSTEMMODAL, "", "Title: " & $aList[$i][0] & @CRLF & "Handle: " & $aList[$i][1])
			$sFill &= $aList[$i][0] & "Handle: " & $aList[$i][1] & "|"
			;$sFill &= $aList[$i][0] & "|"
			;add the passing info then display at the end
        EndIf
    Next
	;so I hope for loop addition to a string automatically delimiters it somehow...?
	_ArrayAdd($aArray, $sFill)
	;get rid of empty guy at the beginning
	;_ArrayDelete($aArray, 0)
	;get rid of empty elements
	_ArryRemoveBlanks($aArray)
	_ArrayDisplay($aArray, "array of all the available windows soon to be (movable?) buttons")
	#comments-end
EndFunc   ;==>Example

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