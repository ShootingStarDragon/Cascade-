#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <AutoItConstants.au3>
#include <StaticConstants.au3>
#include <UpDownConstants.au3>
#include <EditConstants.au3>

#include <File.au3>
#include <Misc.au3>
#include <String.au3>
#include <Array.au3>

#include "GUIListViewEx.au3"

Global  $iYellow = "0xFFFF00", _
		$iLtBlue = "0xCCCCFF", _
		$iGreen = "0x00FF00", _
		$iBlack = "0x000000", _
		$iRed = "0xFF0000", _
		$iBlue = "0x0000FF", _
		$iWhite = "0xFFFFFF"

Global $sRet

$hGUI = GUICreate("Coloured ListView Example", 1000, 510)

; Create ListView
GUICtrlCreateLabel("Full row select - right click item for colour options", 10, 10, 400, 20)
$cLV_1 = GUICtrlCreateListView("Zero Column|One Column|Two Column|Three Column", 10, 30, 480, 260, BitOR($LVS_SINGLESEL, $LVS_SHOWSELALWAYS))

_GUICtrlListView_SetExtendedListViewStyle($cLV_1, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_HEADERDRAGDROP))
For $i = 0 To 3
	_GUICtrlListView_SetColumnWidth($cLV_1, $i, 100)
Next

; Create array and fill listview
Global $aLVArray_1[6][4]
For $i = 0 To 5
	$sData = "Item " & $i & "-0"
	$aLVArray_1[$i][0] = $sData
	For $j = 1 To 3
		$sData &= "|SubItem " & $i & "-" & $j
		$aLVArray_1[$i][$j] = "SubItem " & $i & "-" & $j
	Next
	GUICtrlCreateListViewItem($sData, $cLV_1)
Next

; Initiate ListView = sort on column click - editable headers - header colours - user colours
$iLVIndex_1 = _GUIListViewEx_Init($cLV_1, $aLVArray_1, 0, 0, True, 1 + 8 + 32) ; + 16

; Set column edit status
_GUIListViewEx_SetEditStatus($iLVIndex_1, 1)                   ; Default = standard text edit
_GUIListViewEx_SetEditStatus($iLVIndex_1, 2, 2, "1|2|3", True) ; 2 = Read-only combo
_GUIListViewEx_SetEditStatus($iLVIndex_1, 3, 3)				   ; 3 = DTP

; Create colour array - 0-based to fit ListView content
Global $aLVCol_1[6][4] = [[$iYellow & ";" & $iBlue], _			; Format TxtCol;BkCol
						  ["", ";" & $iGreen, $iRed & ";"], _	; Use leading/trailing ; to indicate if single colour is TxtCol or BkCol
						  [";", "",  $iWhite & ";" & $iBlack]]	; Default (or no change) can be ";" or ""
; Load colour array into ListView
_GUIListViewEx_LoadColour($iLVIndex_1, $aLVCol_1)

; Set header data
;Global $aHdrData[][] = [["Tom",               "Dick",              "Harry",           "Fred"], _ 				; As colour is enabled, these will replace original titles
;						 ["0xFF8080;0x8888FF", "0xFEFEFE;0x000000", "",                "0xFFFF00;0x00FF80"], _	; Col 2 will use default colours
;						 ["",                  "",                  @TAB & "H1|H2|H3", ""], _	 				; Col 2 readonly combo; Col 1 & 3 text
;						 [0,                   0,                   100,               0]]						; Col 2 not resizeable - fixed 100 pixel width

Global $aHdrData[][] = [[Default, "", "",  ""], _
						["", Default, "",  ""], _
						["", "", "",  Default], _
						[0,  0,  Default, 0]]
_GUIListViewEx_LoadHdrData($iLVIndex_1, $aHdrData)

; Create context menu for native ListView
$mContextmenu = GUICtrlCreateContextMenu($cLV_1)
$mWhtTxt = GUICtrlCreateMenuItem("White text", $mContextmenu)
$mYelTxt = GUICtrlCreateMenuItem("Yellow text", $mContextmenu)
$mBluTxt = GUICtrlCreateMenuItem("Cyan text", $mContextmenu)
$mGrnTxt = GUICtrlCreateMenuItem("Green text", $mContextmenu)
$mBlkTxt = GUICtrlCreateMenuItem("Black text", $mContextmenu)
GUICtrlCreateMenuItem("", $mContextmenu)
$mWhtFld = GUICtrlCreateMenuItem("White field", $mContextmenu)
$mRedFld = GUICtrlCreateMenuItem("Red field", $mContextmenu)
$mBluFld = GUICtrlCreateMenuItem("Blue field", $mContextmenu)
$mGrnFld = GUICtrlCreateMenuItem("Green field", $mContextmenu)
$mBlkFld = GUICtrlCreateMenuItem("Black field", $mContextmenu)
GUICtrlCreateMenuItem("", $mContextmenu)
$mDefTxt = GUICtrlCreateMenuItem("Default txt", $mContextmenu)
$mDefFld = GUICtrlCreateMenuItem("Default field", $mContextmenu)
$mDefBoth = GUICtrlCreateMenuItem("Default both", $mContextmenu)

; Create empty UDF ListView
GUICtrlCreateLabel("Single cell select - use controls below for colour options", 510, 10, 400, 20)
$cLV_2 = _GUICtrlListView_Create($hGUI, "", 510, 30, 480, 260, BitOr($LVS_REPORT, $LVS_SINGLESEL, $LVS_SHOWSELALWAYS, $WS_BORDER))
_GUICtrlListView_SetExtendedListViewStyle($cLV_2, $LVS_EX_FULLROWSELECT)
; Initiate to get index - empty array passed with no cols so initially set for 1D return array - user coloured items and headers + single cell select
$iLVIndex_2 = _GUIListViewEx_Init($cLV_2, "", 0, 0, True, 32 + 1024) ; 16 +
; Set required colours for ListView elements - change = pink field
Local $aSelCol[4] = [Default, "0xFFCCCC", Default, Default]
_GUIListViewEx_SetDefColours($iLVIndex_2, $aSelCol)

; Create buttons for LH ListView

GUICtrlCreateGroup("", 10, 300, 480, 160)

GUICtrlCreateLabel("Up/Down", 25, 320, 80, 20, $SS_CENTER)
$cUp = GUICtrlCreateButton("Up", 25, 340, 80, 30)
$cDown = GUICtrlCreateButton("Down", 25, 380, 80, 30)

GUICtrlCreateLabel("Ins/Del", 150, 320, 80, 20, $SS_CENTER)
$cIns = GUICtrlCreateButton("Ins", 150, 340, 80, 30)
$cDel = GUICtrlCreateButton("Del", 150, 380, 80, 30)

GUICtrlCreateLabel("Ins/Del Spec", 275, 320, 80, 20, $SS_CENTER)
$cInsSpec = GUICtrlCreateButton("Insert Spec", 275, 340, 80, 30)
$cDelSpec = GUICtrlCreateButton("Delete Spec", 275, 380, 80, 30)

GUIStartGroup()
$cRad_Row = GUICtrlCreateRadio(" Row", 160, 425, 40, 20)
GUICtrlSetState($cRad_Row, $GUI_CHECKED)
$cRad_Col = GUICtrlCreateRadio(" Col", 220, 425, 40, 20)
$cSpecChoose = GUICtrlCreateInput(0, 275, 420, 80, 30)
GUICtrlSetFont($cSpecChoose, 18)
GUICtrlCreateUpdown($cSpecChoose, BitOr($UDS_WRAP, $UDS_ALIGNRIGHT))
GUICtrlSetLimit(-1, 9, 0)

GUICtrlCreateLabel("Read", 400, 320, 80, 20, $SS_CENTER)
$cContent = GUICtrlCreateButton("Content", 400, 340, 80, 30)
$cColour = GUICtrlCreateButton("Colour", 400, 380, 80, 30)
$cHeaders = GUICtrlCreateButton("Headers", 400, 420, 80, 30)

; Create colour controls for UDF ListView

GUICtrlCreateGroup("", 510, 300, 480, 160)

GUICtrlCreateLabel("Row", 525, 320, 80, 20, $SS_CENTER)
$cColRow = GUICtrlCreateInput(0, 525, 340, 80, 30, $ES_READONLY)
GUICtrlSetFont($cColRow, 18)
GUICtrlCreateUpdown($cColRow, BitOr($UDS_WRAP, $UDS_ALIGNRIGHT))
GUICtrlSetLimit(-1, 9, 0)

GUICtrlCreateLabel("Column", 640, 320, 80, 20, $SS_CENTER)
$cColCol = GUICtrlCreateInput(0, 640, 340, 80, 30, $ES_READONLY)
GUICtrlSetFont($cColCol, 18)
GUICtrlCreateUpdown($cColCol, BitOr($UDS_WRAP, $UDS_ALIGNRIGHT))
GUICtrlSetLimit(-1, 9, 0)

GUICtrlCreateLabel("Colour", 770, 320, 80, 20, $SS_CENTER)
$cColVal = GUICtrlCreateInput("0x000000", 770, 340, 80, 30, $ES_READONLY)
GUICtrlSetFont($cColVal, 11)
$cColChoose = GUICtrlCreateButton("Select Colour", 770, 380, 80, 30)

GUICtrlCreateLabel("Text/Field", 900, 320, 80, 20)
GUIStartGroup()
$cRad_Txt = GUICtrlCreateRadio(" Text", 900, 340, 80, 20)
GUICtrlSetState($cRad_Txt, $GUI_CHECKED)
$cRad_Fld = GUICtrlCreateRadio(" Field", 900, 380, 80, 20)
GUIStartGroup()

$cSetCol = GUICtrlCreateButton("Set Colour", 525, 380, 195, 30)

$cNewSel = GUICtrlCreateButton("Selected Cell in Orange", 525, 420, 150, 30)
$cDefSel = GUICtrlCreateButton("Selected Cell in  Blue", 700, 420, 150, 30)

; Create additional buttons
$cSave = GUICtrlCreateButton("Save LH ListView", 340, 470, 150, 30)
$cLoad = GUICtrlCreateButton("Load RH ListView", 510, 470, 150, 30)
GUICtrlSetState($cLoad, $GUI_DISABLE)
$cExit = GUICtrlCreateButton("Exit", 880, 470, 110, 30)

; If colours used then this function must be run BEFORE GUISetState
_GUIListViewEx_MsgRegister()

GUISetState()

;_GUIListViewEx_SetEditKey("^2D")

MsgBox(0, "Dragging", "You can drag and reorder the headers on the left-hand ListView" & @CRLF & "<----------------------------")

While 1

	$iMsg = GUIGetMsg()
	Switch $iMsg
		Case $GUI_EVENT_CLOSE, $cExit
			Exit

		Case $cSave
			_GUIListViewEx_SaveListView($iLVIndex_1, "Save.lvs")
			GUICtrlSetState($cLoad, $GUI_ENABLE)
		Case $cLoad
			_GUIListViewEx_LoadListView($iLVIndex_2, "Save.lvs") ; But return now forced to 2D

		Case $cUp
			_GUIListViewEx_SetActive($iLVIndex_1)
			_GUIListViewEx_Up()

		Case $cDown
			_GUIListViewEx_SetActive($iLVIndex_1)
			_GUIListViewEx_Down()

		Case $cIns
			; Insert row/col
			_GUIListViewEx_SetActive($iLVIndex_1)
			If GUICtrlRead($cRad_Row) = $GUI_CHECKED Then
				_GUIListViewEx_Insert("New Row")
			Else
				_GUIListViewEx_InsertCol("New Col")
			EndIf
		Case $cDel
			; Delete row/col
			_GUIListViewEx_SetActive($iLVIndex_1)
			If GUICtrlRead($cRad_Row) = $GUI_CHECKED Then
				_GUIListViewEx_Delete()
			Else
				_GUIListViewEx_DeleteCol()
			EndIf

		Case $cInsSpec
			; Insert spec row/col
			$iValue = GUICtrlRead($cSpecChoose)
			If GUICtrlRead($cRad_Row) = $GUI_CHECKED Then
				_GUIListViewEx_InsertSpec($iLVIndex_1, $iValue, "")
			Else
				_GUIListViewEx_InsertColSpec($iLVIndex_1, $iValue, "New Col")
			EndIf
		Case $cDelSpec
			; Delete spec row/col
			$iValue = GUICtrlRead($cSpecChoose)
			If GUICtrlRead($cRad_Row) = $GUI_CHECKED Then
				_GUIListViewEx_DeleteSpec($iLVIndex_1, $iValue)
			Else
				_GUIListViewEx_DeleteColSpec($iLVIndex_1, $iValue)
			EndIf

		Case $cContent
			$aRet = _GUIListViewEx_ReturnArray($iLVIndex_1)
			_ArrayDisplay($aRet, "", Default, 8)
		Case $cColour
			$aRet = _GUIListViewEx_ReturnArray($iLVIndex_1, 2)
			_ArrayDisplay($aRet, "", Default, 8)
		Case $cHeaders
			$aRet = _GUIListViewEx_ReturnArray($iLVIndex_1, 4)
			_ArrayDisplay($aRet, "", Default, 8)

		Case $cColChoose
			$sRet = _ChooseColor(2 , 0, 0, $hGUI)
			GUICtrlSetData($cColVal, $sRet)
		Case $cSetCol
			; Read colour
			$sColSet = GUICtrlRead($cColVal)
			; Set as text or field
			If GUICtrlRead($cRad_Txt) = $GUI_CHECKED Then
				$sColSet &= ";"
			Else
				$sColSet = ";" & $sColSet
			EndIf
			; Read location
			$iRow = GUICtrlRead($cColRow)
			$iCol = GUICtrlRead($cColCol)
			; Set colour
			_GUIListViewEx_SetColour($iLVIndex_2, $sColSet, $iRow, $iCol)

		Case $cNewSel
			; Set orange field & black text for single cell selection = other colours unchanged
			Local $aSelCol[4] = ["", "", "0x000000", "0xFF8000"]
			_GUIListViewEx_SetDefColours($iLVIndex_2, $aSelCol)
		Case $cDefSel
			; Reset default white on blue for single cell selection - other colours unchanged
			Local $aSelCol[4] = ["", "", Default, Default]
			_GUIListViewEx_SetDefColours($iLVIndex_2, $aSelCol)

		Case $mWhtTxt To $mDefBoth
			; Check context menu items
			_SetColour($iMsg)

	EndSwitch

	$vRet = _GUIListViewEx_EventMonitor()
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "Error", "Event error: " & @error)
	EndIf
	Switch @extended
		Case 0
			; No event detected
		Case 1
			If $vRet = "" Then
				MsgBox($MB_SYSTEMMODAL, "Edit", "Edit aborted" & @CRLF)
			Else
				_ArrayDisplay($vRet, "ListView " & _GUIListViewEx_GetActive() & " content edited", Default, 8)
			EndIf
		Case 2
			If $vRet = "" Then
				MsgBox($MB_SYSTEMMODAL, "Header edit", "Header edit aborted" & @CRLF)
			Else
				_ArrayDisplay($vRet, "ListView " & _GUIListViewEx_GetActive() & " header edited", Default, 8)
			EndIf
		Case 3
			MsgBox($MB_SYSTEMMODAL, "Sorted", "ListView: " & $vRet & @CRLF)
		Case 4
			Local $aRet = StringSplit($vRet, ":")
			MsgBox($MB_SYSTEMMODAL, "Dragged", "From ListView " & $aRet[1] & @CRLF & "To ListView " & $aRet[2])
	EndSwitch

WEnd

Func _SetColour($iCID)

	; Get information on where last right click occurred within ListView
	Local $aContext = _GUIListViewEx_ContextPos()

	; Set new colour required
	Local $sColSet = "", $aColArray, $aSplit, $fDef = False
	Switch $iCID
		Case $mWhtTxt
			$sColSet = $iWhite & ";" ; Text colour followed by ";"
		Case $mYelTxt
			$sColSet = $iYellow & ";"
		Case $mBluTxt
			$sColSet = $iLtBlue & ";"
		Case $mGrnTxt
			$sColSet = $iGreen & ";"
		Case $mBlkTxt
			$sColSet = $iBlack & ";"
		Case $mWhtFld
			$sColSet = ";" & $iWhite ; Field colour preceded by ";"
		Case $mRedFld
			$sColSet = ";" & $iRed
		Case $mBluFld
			$sColSet = ";" & $iBlue
		Case $mGrnFld
			$sColSet = ";" & $iGreen
		Case $mBlkFld
			$sColSet = ";" & $iBlack
		Case $mDefTxt
			; Get current colours
			$aColArray = _GUIListViewEx_ReturnArray($aContext[0], 2)
			; Extract current colours
			$aSplit = StringSplit($aColArray[$aContext[1]][$aContext[2]], ";")
			; Create required setting
			$sColSet = ";" & $aSplit[2]
			; Set default flag
			$fDef = True
		Case $mDefFld
			$aColArray = _GUIListViewEx_ReturnArray($aContext[0], 2)
			$aSplit = StringSplit($aColArray[$aContext[1]][$aContext[2]], ";")
			$sColSet = $aSplit[1] & ";"
			$fDef = True
		Case $mDefBoth
			$sColSet = ";"
	EndSwitch

	If $sColSet Then
		; Reset to default if needed
		If $fDef Then
			_GUIListViewEx_SetColour($aContext[0], ";", $aContext[1], $aContext[2])
		EndIf
		; Set required item colour
		_GUIListViewEx_SetColour($aContext[0], $sColSet, $aContext[1], $aContext[2])
	EndIf

EndFunc