#include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Opt("GUIOnEventMode", 1)

#Region ### START Koda GUI section ### Form=
Global $frmMainForm = GUICreate("A Form", 235, 62, -1, -1)
GUISetOnEvent($GUI_EVENT_CLOSE, "ExitApplication")
Global $txtInput = GUICtrlCreateInput("", 19, 22, 201, 21)
GUICtrlSetFont(-1, 10, 400)
GUISetState(@SW_SHOW, $frmMainForm)
#EndRegion ### END Koda GUI section ###

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

While 1
    Sleep(100)
WEnd


Func ExitApplication()
    Exit
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

    Local $hdlWindowFrom, _
          $intMessageCode, _
          $intControlID_From

    $intControlID_From =  BitAND($wParam, 0xFFFF)
    $intMessageCode = BitShift($wParam, 16)

    Switch $intControlID_From
        Case $txtInput
            Switch $intMessageCode
                Case $EN_CHANGE
                    ;ConsoleWrite("[" & _Now() & "] - The text in the $txtInput control has changed! Text = " & GUICtrlRead($txtInput) & @CRLF)
					MsgBox(0,"?",GUICtrlRead($txtInput))
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG

EndFunc