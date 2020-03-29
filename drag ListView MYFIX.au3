#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>
#include <Process.au3>
#include "GUIListViewEx\GUIListViewEx.au3"
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <WinAPI.au3>
#include <WinAPISysWin.au3>
#include <AutoItConstants.au3>
#include <misc.au3>

GUICreate("", 200, 400)
GUISetState(@SW_SHOW)


$Listview = GUICtrlCreateListView("filename", 0, 0, 200, 400);
_GUICtrlListView_SetExtendedListViewStyle($Listview, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))

;GUISetOnEvent($GUI_EVENT_CLOSE, "_Close")
;GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,_Arrange_List())

_Create_List()


While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_PRIMARYDOWN
			_Arrange_List()
	EndSwitch
WEnd

Func _Create_List()
    Local $Item
    While $Item <> "XXXXXXXX"
        $Item = $Item & "X"
        GUICtrlCreateListViewItem($Item, $Listview)
    Wend
Endfunc

Func _Arrange_List()
    $Selected = _GUICtrlListView_GetHotItem($Listview)
	;hotitem is the index of the selected item (starts from 0)
	;MsgBox($MB_OK, "what is hotitem?", $Selected)
    If $Selected = -1 then Return
    While _IsPressed(1)
    WEnd
	MsgBox($MB_OK, "did i release?", "maybe")
    $Dropped = _GUICtrlListView_GetHotItem($Listview)
    If $Dropped > -1 then
        _GUICtrlListView_BeginUpdate($Listview)
        If $Selected < $Dropped Then
            _GUICtrlListView_InsertItem($Listview, _GUICtrlListView_GetItemTextString($Listview, $Selected), $Dropped + 1)
            _GUICtrlListView_SetItemChecked($Listview, $Dropped + 1, _GUICtrlListView_GetItemChecked($Listview, $Selected))
            _GUICtrlListView_DeleteItem($Listview, $Selected)
        ElseIf $Selected > $Dropped Then
            _GUICtrlListView_InsertItem($Listview, _GUICtrlListView_GetItemTextString($Listview, $Selected), $Dropped)
            _GUICtrlListView_SetItemChecked($Listview, $Dropped, _GUICtrlListView_GetItemChecked($Listview, $Selected + 1))
            _GUICtrlListView_DeleteItem($Listview, $Selected + 1)
        EndIf
        _GUICtrlListView_EndUpdate($Listview)
    EndIf
	_WinAPI_RedrawWindow($Listview)
EndFunc

;Func _Close()
;    Exit(0)
;EndFunc