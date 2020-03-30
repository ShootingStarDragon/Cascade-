#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIListView.au3>
#include <Array.au3>

Global $aList_Array[1]
For $i = 1 To 20
    _ArrayAdd($aList_Array, $i & "-----" & $i & "-----" & $i)
    $aList_Array[0] += 1
Next

; Create dialog
Local $hList_Win = GUICreate("UP/Down ListView", 500, 500, Default, Default, BitOr($WS_POPUPWINDOW, $WS_CAPTION))
    GUISetBkColor(0xCECECE)
    
; Create list box with no col headers and permit only 1 selection
Local $hListView = GUICtrlCreateListView ("_", 10, 10, 480, 390, $LVS_NOCOLUMNHEADER + $LVS_SINGLESEL, $LVS_EX_FULLROWSELECT )
; Set up alt line colouring
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_LV_ALTERNATE)
; Set col width
_GUICtrlListView_SetColumnWidth(-1, 0, $LVSCW_AUTOSIZE_USEHEADER)

; Create buttons
Local $hList_Move_Up_Button   = GUICtrlCreateButton("Move Up",   270, 410, 80, 30)
Local $hList_Move_Down_Button = GUICtrlCreateButton("Move Down", 270, 450, 80, 30)
Local $hList_Cancel_Button  = GUICtrlCreateButton("Cancel", 370, 410, 80, 30)

; Fill listbox, list handles indexed on this dummy
Local $hStart_ID = GUICtrlCreateDummy()     

; Fill listbox
; Add placeholders for the list items
    For $i = 1 To 20
        GUICtrlCreateListViewItem($aList_Array[$i], $hListView)
            GUICtrlSetBkColor(-1, 0xCCFFCC)
    Next

; Show dialog
GUISetState(@SW_SHOW, $hList_Win)

While 1

    Local $aMsg = GUIGetMsg(1)
    
    If $aMsg[1] = $hList_Win Then
    
        Switch $aMsg[0]
            Case $GUI_EVENT_CLOSE, $hList_Cancel_Button
                Exit
            Case $hList_Move_Up_Button
                List_Item_Up($aList_Array, $hListView, $hStart_ID)
            Case $hList_Move_Down_Button
                List_Item_Down($aList_Array, $hListView, $hStart_ID)
        EndSwitch
        
    EndIf
            
Wend

; -------

Func List_Item_Up(ByRef $aList_Array, $hListView, $hStart_ID)

If $aList_Array[0] < 2 Then Return

; Get value of listview selection via handle count
$iList_Index = GUICtrlRead($hListView) - $hStart_ID
; If already at top or no selection or out of range
If $iList_Index < 2 Or $iList_Index > $aList_Array[0] Then Return

; Swap array elements
;_ArraySwap ( ByRef $aArray, $iIndex_1, $iIndex_2 [, $bCol = False [, $iStart = -1 [, $iEnd = -1]]] )
;_ArraySwap($aList_Array[$iList_Index],  $aList_Array[$iList_Index - 1])
_ArraySwap($aList_Array, $aList_Array[$iList_Index],  $aList_Array[$iList_Index - 1])

; Rewrite list items
For $i = 1 To $aList_Array[0]
    GUICtrlSetData($hStart_ID + $i, $aList_Array[$i])
Next

; Unselect all items to force selection before next action
_GUICtrlListView_SetItemSelected ($hListView, -1, False)

EndFunc

; -------

Func List_Item_Down(ByRef $aList_Array, $hListView, $hStart_ID)

If $aList_Array[0] < 2 Then Return

; Get value of listview selection via handle count
$iList_Index = GUICtrlRead($hListView) - $hStart_ID
; If already at bottom or no selection or out of range
If $iList_Index < 1 Or $iList_Index > $aList_Array[0] - 1 Then Return

; Swap array elements
_ArraySwap($aList_Array[$iList_Index], $aList_Array[$iList_Index + 1])

; Rewrite list items
For $i = 1 To $aList_Array[0]
    GUICtrlSetData($hStart_ID + $i, $aList_Array[$i])
Next

; Unselect all items to force selection before next action
_GUICtrlListView_SetItemSelected ($hListView, -1, False)

EndFunc