#include <MsgBoxConstants.au3>
#include <Array.au3>

Example()

Func Example()
    ; Retrieve a list of window handles.
    Local $aList = WinList()

	;make empty array
	Dim $aArray[1] 
    ; Loop through the array displaying only visible windows with a title.
	;blank string
	Local $sFill = ""
    For $i = 1 To $aList[0][0]
        If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
            ;MsgBox($MB_SYSTEMMODAL, "", "Title: " & $aList[$i][0] & @CRLF & "Handle: " & $aList[$i][1])
			$sFill &= "New Item " & "Title: " & $aList[$i][0] & "Handle: " & $aList[$i][1] & "|"
			;add the passing info then display at the end
        EndIf
    Next
	;so I hope for loop addition to a string automatically delimiters it somehow...?
	_ArrayAdd($aArray, $sFill)
	;get rid of empty guy at the beginning
	;_ArrayDelete($aArray, 0)
	_ArrayDisplay($aArray, "array of all the available windows soon to be (movable?) buttons")

EndFunc   ;==>Example