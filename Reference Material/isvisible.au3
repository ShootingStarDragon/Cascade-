#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiScrollBars.au3>
#include <GUIListViewEx.au3>
#include <EditConstants.au3>

Local $List1, $List2, $List3, $List4, $lp_Buffer = 0
Local $List1Ex, $List2Ex, $List3Ex

Global $GUIhandle, $cLabel_1, $cLabel_2, $cLabel_3

GUI()

GUIRegisterMsg($WM_SIZE, "WM_SIZE")

_GUIScrollBars_EnableScrollBar(ControlGetHandle("", "", $List2), $SB_BOTH, $ESB_DISABLE_BOTH)
_GUIScrollBars_EnableScrollBar(ControlGetHandle("", "", $List3), $SB_BOTH, $ESB_DISABLE_BOTH)


While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            Quit()
    EndSwitch
WEnd

;END MAIN LINE


Func Quit()
    Exit
EndFunc   ;==>Quit


Func GUI()
    Local $Index, $LV1, $LV2, $LV3
    $GUIhandle = GUICreate("tester", 680, 575, -1, -1, $WS_SIZEBOX + $WS_SYSMENU + $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX) ;creates the parent window
    ;GUICtrlSetResizing(-1, $GUI_DOCKAUTO) ;;allows resizing of full window
    $List1 = _GUICtrlListView_Create($GUIhandle, "Computer Name", 20, 35, 300, 448, -1, $LVS_EX_DOUBLEBUFFER) ;;$ES_READONLY incase you don't want to be able to select text
    _GUICtrlListView_SetExtendedListViewStyle($List1, $LVS_EX_TWOCLICKACTIVATE)
    $cLabel_1 = GUICtrlCreateLabel("", 20, 35, 300, 448)
    GUICtrlSetState($cLabel_1, $GUI_DISABLE)
    GUICtrlSetResizing($cLabel_1,$GUI_DOCKAUTO )
    GUICtrlSetBkColor($cLabel_1, $GUI_BKCOLOR_TRANSPARENT)
    $List2 = _GUICtrlListView_Create($GUIhandle, "Date/Time", 355, 35, 190, 450, -1, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_FLATSB))
    $cLabel_2 = GUICtrlCreateLabel("", 355, 35, 190, 450)
    GUICtrlSetState($cLabel_2, $GUI_DISABLE)
    GUICtrlSetResizing($cLabel_2,$GUI_DOCKAUTO )
    GUICtrlSetBkColor($cLabel_2, $GUI_BKCOLOR_TRANSPARENT)
    $List3 = _GUICtrlListView_Create($GUIhandle, "Speed", 574, 35, 95, 450, -1, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_FLATSB))
    $cLabel_3 = GUICtrlCreateLabel("", 574, 35, 95, 450)
    GUICtrlSetState($cLabel_3, $GUI_DISABLE)
    GUICtrlSetResizing($cLabel_3,$GUI_DOCKAUTO )
    GUICtrlSetBkColor($cLabel_3, $GUI_BKCOLOR_TRANSPARENT)

    GUICtrlCreateLabel("Additional Info", 20, 489) ;creates the label for $List4
    GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
    $List4 = GUICtrlCreateList("", 20, 512, 635, 40, BitOR($WS_BORDER, $WS_VSCROLL), $ES_READONLY)
    GUICtrlSetResizing($List4, $GUI_DOCKAUTO)
    GUICtrlCreateLabel("Active Connections: ", 525, 487) ;creates the label for the active connections
    GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
    GUISetState(@SW_SHOW) ;shows the GUI window

    For $Index = 0 To 100 Step 1
        $LV1 = _GUICtrlListView_AddItem($List1, " ") ;adds a default value into $List1
        $LV2 = _GUICtrlListView_AddItem($List2, " ") ;adds a default value into $List2
        $LV3 = _GUICtrlListView_AddItem($List3, " ") ;adds a default value into $List3
    Next
EndFunc   ;==>GUI


Func WM_SIZE($hWnd, $msg, $wParam, $lParam)

    $aRet = ControlGetPos($GUIhandle, "", $cLabel_1)
    WinMove($List1, "", $aRet[0], $aRet[1], $aRet[2], $aRet[3])
    $aRet = ControlGetPos($GUIhandle, "", $cLabel_2)
    WinMove($List2, "", $aRet[0], $aRet[1], $aRet[2], $aRet[3])
    $aRet = ControlGetPos($GUIhandle, "", $cLabel_3)
    WinMove($List3, "", $aRet[0], $aRet[1], $aRet[2], $aRet[3])

    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE