#include <MsgBoxConstants.au3>
#include <Array.au3>

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

	;make empty array
	Global $aArray[1] 
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

EndFunc   ;==>Example