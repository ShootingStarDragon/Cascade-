#include <GuiConstants.au3>
#include <GuiListView.au3>

Opt('MustDeclareVars', 1)
Dim $listview, $Btn_Get, $Btn_Exit, $msg, $Status, $ret, $x
GUICreate("ListView Get Item Text", 392, 322)

$listview = GUICtrlCreateListView("col1|col2|col3", 40, 30, 310, 149)
GUICtrlCreateListViewItem("line1|data1|more1", $listview)
GUICtrlCreateListViewItem("line2|data2|more2", $listview)
GUICtrlCreateListViewItem("line3|data3|more3", $listview)
GUICtrlCreateListViewItem("line4|data4|more4", $listview)
GUICtrlCreateListViewItem("line5|data5|more5", $listview)
$Btn_Get = GUICtrlCreateButton("Get All", 75, 200, 90, 40)
$Btn_Exit = GUICtrlCreateButton("Exit", 300, 260, 70, 30)
$Status = GUICtrlCreateLabel("", 0, 302, 392, 20, BitOR($SS_SUNKEN, $SS_CENTER))

GUISetState()
While 1
    $msg = GUIGetMsg()
    Select
        Case $msg = $GUI_EVENT_CLOSE Or $msg = $Btn_Exit
            ExitLoop
        Case $msg = $Btn_Get
            For $x = 0 To _GUICtrlListView_GetItemCount($listview) - 1
                $ret = MsgBox(1, "item: " & $x, _GUICtrlListView_GetItemText($listview, $x, 1))
                If $ret = 2 Then ExitLoop ; user selected cancel
            Next
    EndSelect
WEnd
Exit