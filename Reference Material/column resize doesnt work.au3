#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
 
GUICreate("ListView Set Column Width", 400, 300)
$MusicListView = GUICtrlCreateListView("Column 1|Column 2|Column 3|Column 4", 2, 2, 394, 268)
GUISetState()
 
; Change column 1 width
;MsgBox(4160, "Information", "Column 1 Width: " & _GUICtrlListView_GetColumnWidth($hListView, 0))
;_GUICtrlListView_SetColumnWidth($hListView, 0, 0)
;MsgBox(4160, "Information", "Column 1 Width: " & _GUICtrlListView_GetColumnWidth($hListView, 0))
 
If FileExists("MusicList.ini") Then
	$MusicINI = FileRead ("MusicList.ini")
	;add to listview:
	$MusicIniData = IniReadSection ( "MusicList.ini", "MusicData" )
	$MusicTotal = UBound($MusicIniData,1)
	For $x = 1 to $MusicTotal -1 
		GUICtrlCreateListViewItem ($MusicIniData[$x][0] & "|" & "|", $MusicListView)
		;GUICtrlSetData ( $Label9, ($x/$MusicTotal)*100  & '%' & " done" & ", " & "Working on " & $MusicIniData[$x][0])
	Next
Else
	$MusicINI = FileOpen ("MusicList.ini",2 )
EndIf
GUISetState()
While 1
	$nMsg = GUIGetMsg()
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		
	EndSwitch
WEnd