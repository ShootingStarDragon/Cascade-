#include <GuiConstants.au3>
#include <GuiListView.au3>

$hGui = GUICreate("Test GUI", 300, 200)

$hListView = _GUICtrlListView_Create($hGui, "Items|SubItems", 10, 10, 280, 160, -1, $WS_EX_CLIENTEDGE)

_GUICtrlListView_SetExtendedListViewStyle ($hListView, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))
    
_GUICtrlListView_AddItem ($hListView, "Row 1: Col 1", 0)
_GUICtrlListView_AddSubItem ($hListView, 0, "Row 1: Col 2", 1)
_GUICtrlListView_AddSubItem ($hListView, 0, "Row 1: Col 3", 2)

_GUICtrlListView_AddItem ($hListView, "Row 2: Col 1", 1)
_GUICtrlListView_AddSubItem ($hListView, 1, "Row 2: Col 2", 1)
_GUICtrlListView_AddItem ($hListView, "Row 3: Col 1", 2)

$RemoveButton = GUICtrlCreateButton("Remove checkboxes", 10, 175, 120, 20)
    
GUISetState()

While 1
    $msg = GUIGetMsg()
    
    Switch $msg
    Case $GUI_EVENT_CLOSE
        ExitLoop
    Case $RemoveButton
        _GUICtrlListView_SetExtendedListViewStyle($hListView, $LVS_EX_FULLROWSELECT)
    EndSwitch
WEnd