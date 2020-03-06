#include <GUIConstants.au3>

GUICreate('Drop Area', 400, 300, -1, -1, -1, $WS_EX_ACCEPTFILES)

; The control to receive information
; Y=-100 to hide text and HEIGHT+100 to cover whole the window

$drop = GUICtrlCreateInput('', 0, -100, 400, 400, $WS_DISABLED + $ES_AUTOHSCROLL, 0)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)

;------------------------
; Create other controls here
;------------------------

GUISetState()

$msg = 0

while $msg <> $GUI_EVENT_CLOSE
  $msg = GUIGetMsg()
    
  if not $msg then
  elseif $msg = $GUI_EVENT_DROPPED then
    if @GUI_DRAGID = -1 then    ; File(s) dropped
      $files = GUICtrlRead($drop)  ; File list in the form: file1|file2|...

      MsgBox(0, 'Dropped', StringReplace($files, '|', @CR))
    endif
  endif
wend
 
GUIDelete()