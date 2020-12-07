#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <Array.au3>

Local $aArray = StringRegExp("Gatchaman Insight  - I n s i g h t _ Full Opening.mp3|0", "^(.+?)\|", 1)
Local $aMatch = 0
;_ArrayDisplay ($aArray)
MsgBox($MB_SYSTEMMODAL,"?", $aArray[0])
For $i = 0 To UBound($aArray) - 1
    $aMatch = $aArray[$i]
    ;For $j = 0 To UBound($aMatch) - 1
    ;    MsgBox($MB_SYSTEMMODAL, "RegExp Test with Option 4 - " & $i & ',' & $j, $aMatch[$j])
    ;Next
Next
