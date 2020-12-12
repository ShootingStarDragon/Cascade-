#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
    Local $idListview, $idListview1, $aArr, $iNoCols = 10, $iNoItems = 100, $iDataLimit_0To = 5, $sFind, $aArrData[$iNoItems][$iNoCols]
    Local $sCols = "col0"
    GUICreate("ListView Original", 500, 350, 0, 0, $WS_SIZEBOX)
    GUICtrlCreateLabel("Filter", 4, 302)
    Local $idInput = GUICtrlCreateInput("2", 40, 302, 355, 25)
    Local $FilterBut = GUICtrlCreateButton("Go", 400, 302, 30, 25)
    For $m = 1 To $iNoCols - 1
        $sCols &= "|col" & $m
    Next
    $idListview = GUICtrlCreateListView($sCols, 0, 0, 500, 300)

    ; ------- Create data in array for ListView ------------------
    For $j = 0 To $iNoItems - 1
        $sData = "index " & $j
        $aArrData[$j][0] = $sData
        For $k = 1 To $iNoCols - 1
            $aArrData[$j][$k] = Random(0, $iDataLimit_0To, 1) & Random(0, $iDataLimit_0To, 1) & _
                    Random(0, $iDataLimit_0To, 1) & Random(0, $iDataLimit_0To, 1) & Random(0, $iDataLimit_0To, 1)
        Next
    Next
    _GUICtrlListView_AddArray($idListview, $aArrData)
    _GUICtrlListView_SetColumnWidth($idListview, 0, 55)
    GUISetState(@SW_SHOW)

    ; ------- Create 2nd GUI and ListView and fill with same data. ---------------
    GUICreate("ListView Filtered", 500, 330, @DesktopWidth / 2, 0, $WS_SIZEBOX)
    $idListview1 = GUICtrlCreateListView($sCols, 0, 0, 500, 300)
    _GUICtrlListView_AddArray($idListview1, $aArrData)
    _GUICtrlListView_SetColumnWidth($idListview1, 0, 55)
    GUISetState(@SW_SHOW)

    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exitloop
            Case $FilterBut
                $sFind = GUICtrlRead($idInput)
                If $sFind <> "" Then
                    _GUICtrlListView_DeleteAllItems($idListview1)
                    For $i = 0 To _GUICtrlListView_GetItemCount($idListview) - 1
                        $aArr = _GUICtrlListView_GetItemTextArray($idListview, $i)
                        $sData1 = ""
                        For $n = 1 To UBound($aArr) - 1
                            If StringInStr($aArr[$n], $sFind) = 0 Then $aArr[$n] = "---" ; <<<< Apply filter
                            $sData1 &= $aArr[$n] & "|"
                        Next
                        GUICtrlCreateListViewItem($sData1, $idListview1)
                    Next
                Else ; When no filter present.
                    _GUICtrlListView_DeleteAllItems($idListview1)
                    _GUICtrlListView_AddArray($idListview1, $aArrData)
                EndIf
        EndSwitch
    WEnd
    GUIDelete()
EndFunc   ;==>Example