#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

#include "GUIListViewEx.au3"

$hGUI = GUICreate("Test", 400, 600)

; Create ListViews
$cLV_Tom = GUICtrlCreateListView("Tom",10, 30, 180, 160)
_GUICtrlListView_SetColumnWidth($cLV_Tom, 0, 140)
$cLV_Dick = GUICtrlCreateListView("Dick",210, 30, 180, 160)
_GUICtrlListView_SetColumnWidth($cLV_Dick, 0, 140)
$cLV_Harry = GUICtrlCreateListView("Harry",10, 230, 180, 160)
_GUICtrlListView_SetColumnWidth($cLV_Harry, 0, 140)
$cLV_Fred = GUICtrlCreateListView("Fred",210, 230, 180, 160)
_GUICtrlListView_SetColumnWidth($cLV_Fred, 0, 140)
$cLV_Dora = GUICtrlCreateListView("Dora",10, 430, 180, 160)
_GUICtrlListView_SetColumnWidth($cLV_Dora, 0, 140)

; Create arrays and fill ListViews
Global $aTom[5], $aDick[5], $aHarry[5], $aFred[5], $aDora[5]
For $i = 0 To 4
    $aTom[$i] = "Tom " & $i
    GUICtrlCreateListViewItem($aTom[$i], $cLV_Tom)
    $aDick[$i] = "Dick " & $i
    GUICtrlCreateListViewItem($aDick[$i], $cLV_Dick)
    $aHarry[$i] = "Harry " & $i
    GUICtrlCreateListViewItem($aHarry[$i], $cLV_Harry)
    $aFred[$i] = "Fred " & $i
    GUICtrlCreateListViewItem($aFred[$i], $cLV_Fred)
	$aDora[$i] = "Dora " & $i
	GUICtrlCreateListViewItem($aDora[$i], $cLV_Dora)
Next

; Initiate ListViews and set differing external drag/drop states
GUICtrlCreateLabel("Normal", 10, 10, 180, 20)
$iLV_Tom = _GUIListViewEx_Init($cLV_Tom, $aTom, 0, 0, True) ; External drag & drop - items deleted on drag
GUICtrlCreateLabel("No external drag", 210, 10, 180, 20)
$iLV_Dick = _GUIListViewEx_Init($cLV_Dick, $aDick, 0, 0, True, 64) ; No external drag, will accept drop
GUICtrlCreateLabel("No external drop", 10, 210, 180, 20)
$iLV_Harry = _GUIListViewEx_Init($cLV_Harry, $aHarry, 0, 0, True, 128) ; No external drop, will drag to others
GUICtrlCreateLabel("No delete && no drop", 210, 210, 180, 20)
$iLV_Fred = _GUIListViewEx_Init($cLV_Fred, $aFred, 0, 0, True, 128 + 256) ; No external drop, will drag to others - items NOT deleted on drag
GUICtrlCreateLabel("No internal or external drag/drop", 10, 410, 180, 20)
$iLV_Dora = _GUIListViewEx_Init($cLV_Dora, $aDora, 0, 0, True, 512) ; No internal or external drag/drop

GUISetState()

_GUIListViewEx_MsgRegister()

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
	EndSwitch

	$vRet = _GUIListViewEx_EventMonitor()
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "Error", "Event error: " & @error)
	EndIf
	Switch @extended
		Case 0
			; No event detected
		Case 4
			MsgBox($MB_SYSTEMMODAL, "Dragged", "From:To" & @CRLF & $vRet & @CRLF)
	EndSwitch

WEnd
