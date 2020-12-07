#include <Array.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>

Global $INdirs = IniReadSection("FileTypes.ini","LISTVIEWITEMS")
Global $OUTdirs = IniReadSectionNames("FileTypes.ini")

#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("ListView read from / write to *.ini data test", 739, 448, @DesktopWidth/2-739/2, @DesktopHeight/2-448/2)
$lister = GUICtrlCreateListView("Directory From|Extension|Directory To", 8, 16, 618, 414)

If @error Then
    MsgBox(4000, "", "Error occurred, no ini file.")
Else
    For $i = 1 to $INdirs[0][0]
        GuiCtrlCreateListViewItem($INdirs[$i][1],$lister)
    Next
EndIf

Global $aBackend[100][100] ;100 is just a space holder for 100 values in x and y direction
Global $aTmp, $j, $y = 0
For $i = 1 To UBound($INdirs) - 1
    $aTmp = StringSplit($INdirs[$i][1], "|", 2)
    $y = UBound($aTmp)
    For $j = 0 To UBound($aTmp) - 1
        $aBackend[$i - 1][$j] = $aTmp[$j]
    Next
Next
ReDim $aBackend[$i - 1][$y] ;resize the array to its real dimension
_ArrayDisplay($aBackend)

GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 250)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 100)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 250)
$addButton = GUICtrlCreateButton("Add Filter", 632, 16, 99, 25, $WS_GROUP)
$removeButton = GUICtrlCreateButton("Remove Filter", 632, 48, 99, 25, $WS_GROUP)
$exitButton = GUICtrlCreateButton("Exit", 632, 408, 99, 25, $WS_GROUP)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

TrayTip("Project Tyrion ListView Test", "Activated",10)

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit

        Case $addButton



        Case $removeButton



        Case $exitButton
            Exit

    EndSwitch
WEnd