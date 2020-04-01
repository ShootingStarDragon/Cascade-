;;;;;Resizable GUI;;;;;;
HotKeySet("{ESC}", "MyExit")
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
$Gui = GUICreate("Resizable GUI", 250, 250, 350, 200, $WS_SIZEBOX)
GUISetState(@SW_SHOW)
 
 
While 1
$msg = GUIGetMsg(1)
Select
Case $msg[0] = $GUI_EVENT_CLOSE
  Exit
EndSelect
WEnd
 
Func MyExit()
    Exit
EndFunc