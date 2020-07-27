#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>
#include <Process.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <WinAPI.au3>
#include <WinAPISysWin.au3>
#include <AutoItConstants.au3>
#include <SendMessage.au3>
Example()

Func Example()
	$ColSeq = 0
	$iCol = 5-2
	Local $ColSeq[15]
	For $ColSeqInit = 1 to UBound($ColSeq, 1)-1
		$ColSeq[0] = $iCol
		Switch $ColSeqInit
			Case $ColSeqInit <= $iCol 
				$ColSeq[$ColSeqInit] = $ColSeqInit-1
			Case $ColSeqInit > $iCol 
				$ColSeq[$ColSeqInit] = $ColSeqInit
		EndSwitch
	Next
	_ArrayDisplay($ColSeq)
EndFunc   ;==>Example
