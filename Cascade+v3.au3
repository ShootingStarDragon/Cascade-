#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>
#include <Process.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <WinAPI.au3>
#include <WinAPISysWin.au3>
#include <AutoItConstants.au3>
#include <SendMessage.au3>

;#include "GUIListViewEx\GUIListViewEx.au3"

;set aIndexList of indicies so i can clear the checkboxes on 1st column
Global $aIndexList[1]

;Retrieve a list of window handles.
Local $aList = WinList("[REGEXPTITLE:(?i)(.+)]")
;_ArrayDisplay($aList)
#comments-start
	The array returned is two-dimensional and is made up as follows:
	$aArray[0][0] = Number of windows returned
	$aArray[1][0] = 1st window title
	$aArray[1][1] = 1st window handle (HWND)
	$aArray[2][0] = 2nd window title
	$aArray[2][1] = 2nd window handle (HWND)
#comments-end

Local $aListFiltered[0]
;filtered list is just a 1d array of handles (HWND)

Local $aTitles[0]
;winGetTitle fails for microsoft edge for some reason so just get titles from the source

;filter winlist to get rid of windows with no titles and manually remove program manager
For $i = 1 to $aList[0][0]
	;have to manually remove program manager I think
	If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) == 2 And $aList[$i][0] <> "Program Manager" Then
		_ArrayAdd($aListFiltered, $aList[$i][1])
		_ArrayAdd($aTitles, $aList[$i][0])
	EndIf
Next
;let's check it right now by displaying aListFiltered
;_ArrayDisplay($aListFiltered, "check")

;make the array with info:
;NAME			HWND 			exe name 	PID	position 	size
;array size is Ubound of the filtered list and 5 columns
;make empty array
Local $aArrayFinal[UBound($aListFiltered, 1)][5]
;MsgBox ( $MB_OK, "title", UBound($aListFiltered, 1) & "|" & UBound($aListFiltered, 2))

;populate array
For $i = 0 to UBound($aListFiltered, 1)-1
	;MsgBox ( $MB_OK, "title", $i & UBound($aListFiltered, 1) & WinGetTitle($aListFiltered[$i]) & $aListFiltered[$i] & _ProcessGetName($aListFiltered[$i]) & WinGetPos ($aListFiltered[$i]) & WinGetClientSize ($aListFiltered[$i]))
	;name
	;wingettitle fails on microsoft edge for some reason
	;$aArrayFinal[$i][0] = WinGetTitle($aListFiltered[$i])
	;$aArrayFinal[$i][0] = _ProcessGetName(WinGetProcess($aListFiltered[$i]))
	$aArrayFinal[$i][0] = $aTitles[$i]
	;HWND
	$aArrayFinal[$i][1] = $aListFiltered[$i]
	;exe name
	$aArrayFinal[$i][2] = _ProcessGetName(WinGetProcess($aListFiltered[$i]))
	;pos
	$aArrayFinal[$i][3] = WinGetPos($aListFiltered[$i])[0] & "," & WinGetPos($aListFiltered[$i])[1]
	;size
	$aArrayFinal[$i][4] = WinGetClientSize($aListFiltered[$i])[0] & "," & WinGetClientSize($aListFiltered[$i])[1]
Next

#comments-start
WinGetProcess()

---

To be used on your hwnd's from winlist to see if its the PID your looking for.

But, this can return multiple matches, as a process can have multiple windows. so some additional window title information is probably needed to make sure you get the one your after.

---


---
PsaltyDS  Posted July 6, 2010 (edited) 

Only gets the handle for the FIRST visible window. As was pointed out earlier, a process can and often does have multiple windows. Try it this way:

#include <Array.au3>

; ...

; Returns an array of all Windows associated with a given process
Func WinHandFromPID($pid, $winTitle = "", $timeout = 8)
    Local $secs = TimerInit()
    Do
        $wins = WinList($winTitle)
        For $i = UBound($wins) - 1 To 1 Step -1
            If (WinGetProcess($wins[$i][1]) <> $pid) Or (BitAND(WinGetState($wins[$i][1]), 2) = 0) Then _ArrayDelete($wins, $i)
        Next
        $wins[0][0] = UBound($wins) - 1
        If $wins[0][0] Then Return SetError(0, 0, $wins)
        Sleep(1000)
    Until TimerDiff($secs) >= $timeout * 1000
    Return SetError(1, 0, $wins)
EndFunc   ;==>WinHandFromPID
#comments-end

;display array now
;_ArrayDisplay($aArrayFinal, "check")



;make a dropdown list of monitors
dim $MonitorArray[1]

$Monitors = _WinAPI_EnumDisplayMonitors()

;MsgBox ( $MB_OK, "title1", $Monitors[0][0])
;MsgBox ( $MB_OK, "title2", _WinAPI_GetMonitorInfo($Monitors[1][0])[3])

;set window titles appropriately
;update the window title properly when new monitors are connected? nah just restart Cascade+

Local $sHeaders = "Window Title|App Name(.exe)|Window Handle"

;keep track of controls so I can delete properly
dim $LVItemArray[1][4]

For $intmon = 1 To $Monitors[0][0]
	;MsgBox($MB_OK, "title1", $intmon)
	;_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	$sHeaders &= "|Monitor " & $intmon
	redim $LVItemArray[UBound($LVItemArray, 1)][UBound($LVItemArray,2)+1]
Next

	
	
;remove empty init element in MonitorArray
_ArryRemoveBlanks($MonitorArray)
;_ArrayDisplay($MonitorArray)

;GUICreate ( "title" [, width [, height [, left = -1 [, top = -1 [, style = -1 [, exStyle = -1 [, parent = 0]]]]]]] )
;$hGUI = GUICreate("Cascade+",500,500,500,500,$WS_SIZEBOX)
$hGUI = GUICreate("Cascade+",500,500,-1,-1,$WS_SIZEBOX )
;To be able to resize a GUI window it needs to have been created with the $WS_SIZEBOX and $WS_SYSMENU styles. See GUICreate().

;init the coord datas for each monitor:
; 0,0 -> empty
; [ith monitor][start x coord][start y coord][end x coord][end y coord]
dim $MonitorCoords[1][5]

; And here we get the elements (monitors) into a list
$sList = ""
For $i = 0 To UBound($MonitorArray) - 1
	$sList &= "|" & $MonitorArray[$i]
	;to add manually instead of the weird delimited version of _ArrayAdd
	ReDim $MonitorCoords[UBound($MonitorCoords,1)+1][5]
	;assume that monitors come in order I guess...
	;init x/y coords 
	$MonitorCoords[$i+1][0] = $MonitorArray[$i]
	;initial x/y
	$MonitorCoords[$i+1][1] = MonitoInfo()[$i+1][0]
	$MonitorCoords[$i+1][2] = MonitoInfo()[$i+1][1] + 200
	;final x/y
	$MonitorCoords[$i+1][3] = MonitoInfo()[$i+1][0] + 200
	$MonitorCoords[$i+1][4] = MonitoInfo()[$i+1][1]
Next

;_ArrayDisplay($MonitorCoords)

; Create the combo
$hCombo = GUICtrlCreateCombo("", 10, 10, 200, 20)
; And fill it
GUICtrlSetData($hCombo, $sList)



$Label1 = GUICtrlCreateLabel("Current Monitor", 10, 40)
$Label1b = GUICtrlCreateLabel("", 100, 40, 200, 20)
$Label2 = GUICtrlCreateLabel("Mouse X Coord", 10, 60)
;x coord update
$Label2b = GUICtrlCreateLabel("", 100, 60, 40, 20)
$Label3 = GUICtrlCreateLabel("Mouse Y Coord", 10, 80)
;y coord update
$Label3b = GUICtrlCreateLabel("", 100, 80, 40, 20)
$Label6 = GUICtrlCreateLabel("Selected Monitor", 10, 100)
$Label6b = GUICtrlCreateLabel("", 100, 100, 200, 20)
$Label7 = GUICtrlCreateLabel("Start Point X", 10, 120)
$Label7b = GUICtrlCreateInput("", 100, 120, 100, 20)
$Label8 = GUICtrlCreateLabel("Start Point Y", 10, 140)
$Label8b = GUICtrlCreateInput("", 100, 140, 100, 20)
$Label9 = GUICtrlCreateLabel("End Point X", 10, 160)
$Label9b = GUICtrlCreateInput("", 100, 160, 100, 20)
$Label10 = GUICtrlCreateLabel("End Point Y", 10, 180)
$Label10b = GUICtrlCreateInput("", 100, 180, 100, 20)
$Label11 = GUICtrlCreateButton("Cascade Now!", 10, 430, 100, 20)
$Label12 = GUICtrlCreateButton("Refresh Window List", 120, 430, 120, 20)
$Label13 = GUICtrlCreateButton("CHECK ARRAY", 120, 450, 120, 20)
$Label14 = GUICtrlCreateButton("Update Coordinates", 220, 120, 120, 20)
$Label15 = GUICtrlCreateButton("Reset Coordinates", 220, 140, 120, 20)

;It is important to use _GUIListViewEx_Close when a enabled ListView is deleted to free the memory used
;                    by the $aGLVEx_Data array which shadows the ListView contents.
;_GUIListViewEx_Close($iLV_Index)

;Func _GUIListViewEx_Init($hLV, $aArray = "", $iStart = 0, $iColour = 0, $fImage = False, $iAdded = 0)

Global $cListView_WindowList = GUICtrlCreateListView($sHeaders, 10, 220, 400, 200) ;$LVS_SHOWSELALWAYS

;Global $hListView = _GUICtrlListView_Create($hGUI, $sHeaders, 10, 220, 400, 200)
;Global $cListView_WindowList = _GUICtrlListView_GetItemParam ( $hGUI, $hListView )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;getting checkboxes so i can hack onto GUIListViewEx
;$LVS_EX_FULLROWSELECT
_GUICtrlListView_SetExtendedListViewStyle($cListView_WindowList, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_SUBITEMIMAGES));$LVS_EX_GRIDLINES

Global $hListView = GUICtrlGetHandle( $cListView_WindowList )    
; ImageList
;idListView2 and cListView_WindowList might be redudant
;Local $idListView2 = GUICtrlCreateListView( "", 0, 0, 1, 1 )                  ; 1x1 pixel listview to create state image list with checkbox icons
;apparently you can checkboxes twice to get an extra space for a supposed checkbox or smth...
;_GUICtrlListView_SetExtendedListViewStyle( $idListView2, $LVS_EX_CHECKBOXES ) ; The $LVS_EX_CHECKBOXES style forces the state image list to be created
; Get state ImageList
;Local $hStateImageList = _GUICtrlListView_GetImageList( $idListView2, 2 ) ; 2 = Image list with state images
Local $hStateImageList = _GUICtrlListView_GetImageList( $cListView_WindowList, 2 ) ; 2 = Image list with state images
; Add state ImageList as a normal ImageList
_GUICtrlListView_SetImageList( $hListView, $hStateImageList, 1 ) ; 1 = Image list with small icons
; Register WM_NOTIFY message handler
GUIRegisterMsg( $WM_NOTIFY, "WM_NOTIFY" )
GUIRegisterMsg($WM_LBUTTONUP, "WM_LBUTTONUP")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Local $IndexCounter = 0


For $rowInt = 0 To UBound($aArrayFinal, 1)-1
	;MsgBox ( $MB_OK, "start of MY ROW", "")
	;init with name
	Local $blankStr = $aArrayFinal[$rowInt][0] & "|" & $aArrayFinal[$rowInt][2] & "|" & $aArrayFinal[$rowInt][1]
	;$blankStr &=  "|" & $aArrayFinal[$rowInt][2] & "|" & $aArrayFinal[$rowInt][1]
	;add title
	;$ItemID = GUICtrlCreateListViewItem ( $blankStr, $cListView_WindowList)
	$LVItem = GUICtrlCreateListViewItem ( $blankStr, $cListView_WindowList)
	;MsgBox ( $MB_OK, "LVItem", $LVItem)

	#comments-start
	GUICtrlDelete
		Deletes a control.


		GUICtrlDelete ( controlID )


		Parameters
		controlID The control identifier (controlID) as returned by a GUICtrlCreate...() function, or -1 for the last created control. 

		Return Value
		Success: 1. 
		Failure: 0. 
	#comments-end

	;clear the checkbox
	;_GUICtrlListView_SetItemState($hListView, $LVItem, 0, $LVIS_STATEIMAGEMASK)
	
	;HEADS UP
	;IN THIS CASE $LVItem = GUICtrlCreateListViewItem IS NOT OUR CONTROLID. The control ID is still a sequence. Since $rowInt is counting from the UBound our LVItem is numbered according to the windows not the control ID's if that makes any sense
	;HEADS UP CONTROL != YOUR ID
	_GUICtrlListView_SetItemState($hListView, $IndexCounter, 0, $LVIS_STATEIMAGEMASK)
	
	$LVItemArrayItem =  $LVItem & "|" & $blankStr
	;add the checkboxes per monitor
	For $imonitor = 0 To $Monitors[0][0]-1
		;_GUICtrlListView_AddSubItem( $cListView_WindowList, $IndexCounter, "checkbox", $imonitor + 2, 1 ) ; Image index 0 = unchecked checkbox
		;_GUICtrlListView_SetItemImage( $cListView_WindowList, $IndexCounter, 0, 3) ; 3 is the zero based index of fourth column
		_GUICtrlListView_SetItemImage( $cListView_WindowList, $IndexCounter, 0, 3 + $imonitor) 
		;MsgBox($MB_OK, "how long is 0 to " & $Monitors[0][0], $imonitor)
		$LVItemArrayItem &= "|" & 0
	Next
	_ArrayAdd($LVItemArray, $LVItemArrayItem)
	;	MsgBox ( $MB_OK, "title", $IndexCounter & "|" & $LVItem)
	
	;;$aIndexList[$rowInt] = $LVItem
	;	$aIndexList[$IndexCounter] = $LVItem
	;
	_ArrayAdd ( $aIndexList, $IndexCounter)

	;;;SET ITEM IMAGE TEST
	;_GUICtrlListView_AddItem( $hListView, $rowInt, 0 )                           ; Image index 0 = unchecked checkbox
	;remove the checkboxes on column 1 (format: [row],[column])
	;_GUICtrlListView_SetItemState($hListView, $ItemID, 0, $LVIS_STATEIMAGEMASK)
	;_WinAPI_RedrawWindow($hListView)
	
	
	;MsgBox ( $MB_OK, "title", $IndexCounter)
	$IndexCounter += 1
Next
_ArrayDelete($aIndexList, 0)
_ArrayDelete($LVItemArray, 0)
;_ArrayDisplay($LVItemArray)

;redraw everything so checkboxes get removed
_WinAPI_RedrawWindow($hListView)
;
;;;;;$cListView_WindowListUDFVer = _GUIListViewEx_Init($cListView_WindowList, $aArrayFinal, 0, 0, True, + 2)

Global $time = -1

;You will need to register some Windows messages so that the UDF can intercept various key and mouse events and determine the correct actions to take. 
;;;;;_GUIListViewEx_MsgRegister()

GUISetState()

While 1
	If $time = -1 Then ; this should only run once
        _StartTimer()
    EndIf
	
	Sleep(10)
    ;If TimerDiff($time) > 5000 Then
	If TimerDiff($time) > 1000 Then
        _UpdateInfo()
        $time = 0
        $time = TimerInit()
    EndIf
	
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $hCombo
			$sComboRead = GUICtrlRead($hCombo)
			GUICtrlSetData($Label6b, $sComboRead)
			;;;;;_GUIListViewEx_Close($cListView_WindowListUDFVer)
			;Label7
			;GUICtrlSetData ( controlID, data [, default] )
			;MsgBox($IDOK ,"search the array",_ArraySearch($MonitorCoords,$sComboRead))
			Local $monitorInt = _ArraySearch($MonitorCoords,$sComboRead)
			GUICtrlSetData($Label7b, $MonitorCoords[$monitorInt][1])
			GUICtrlSetData($Label8b, $MonitorCoords[$monitorInt][2])
			GUICtrlSetData($Label9b, $MonitorCoords[$monitorInt][3])
			GUICtrlSetData($Label10b,$MonitorCoords[$monitorInt][4])
		;pressed the cascade button
		Case $Label11
			;get a list of all monitors and if you checked it then cascade it
			Global $MonitorSegments[1][1]
			;then data is:
			;$MonitorSegments[0][0] -> number of windows to cascade on monitor 1
			;$MonitorSegments[0][1] -> number of windows to cascade on monitor 2
			;$MonitorSegments[1][0] is app name
			;$MonitorSegments[1][1] is monitor to display on (monitor 1 or 2 or 3 etc)
			;_ArrayDisplay($MonitorSegments)
			
			;init the number of windows to cascade per monitor
			For $i = 0 To UBound($MonitorArray) - 1
				If $i >= 0 Then
					;add one more for one more monitor $MonitorArray
					ReDim $MonitorSegments[UBound($MonitorSegments,1)][UBound($MonitorSegments,2)+1]
					$MonitorSegments[0][$i] = 0
				EndIf
			Next
			;_ArrayDisplay($MonitorSegments)
			For $x = 0 To _GUICtrlListView_GetItemCount($cListView_WindowList) - 1
				;go through all the checkboxes and if the checkbox has a 1 for image we increment the count in $MonitorSegments and add the HWND/monitor data to $MonitorSegments
				For $i = 0 To UBound($MonitorArray) - 1 
					If _GUICtrlListView_GetItemImage($cListView_WindowList, $x, $i + 3) == 1 Then
						$MonitorSegments[0][$i] += 1
						_ArrayAdd($MonitorSegments, _GUICtrlListView_GetItemText($cListView_WindowList, $x, 2) & "|" & $i)
					EndIf
				Next
			Next
			;_ArrayDisplay($MonitorSegments)
			;if we're not the selected column set the subitem to empty checkbox

			;for each monitor
			For $i = 0 To UBound($MonitorArray) - 1 
				;get total # of windows from $MonitorSegments[0][$i]
				$Localmax = $MonitorSegments[0][$i]
				;$y = 1 to skip the initial row
				Local $OffsetValUNQ = 0
				For $y = 1 To UBound($MonitorSegments,1) -1
					If $MonitorSegments[$y][1] == $i Then
						;move the window properly
						#comments-start
							WinGetPos ( "title" [, "text"] )
								"title" = title/hWnd/class
								Success: 	a 4-element array containing the following information:
									$aArray[0] = X position
									$aArray[1] = Y position
									$aArray[2] = Width
									$aArray[3] = Height
								Failure: 	sets the @error flag to non-zero if the window is not found.
						
							WinMove ( "title", "text", x, y [, width [, height [, speed]]] )
								title The title/hWnd/class of the window to move/resize. See Title special definition. 
								text The text of the window to move/resize. See Text special definition. 
								x X coordinate to move to. 
								y Y coordinate to move to. 
								width [optional] New width of the window. 
								height [optional] New height of the window. 
								speed [optional] the speed to move the windows in the range 1 (fastest) to 100 (slowest). If not defined the move is instantaneous. 
						#comments-end
						Local $OrigPos 
						$currHWND = HWnd($MonitorSegments[$y][0])
						$OrigPos = WinGetPos($currHWND)
						;MsgBox ( $MB_OK, "check5", "does origpos even work?" & " " & $OrigPos)
						$MonitorStartX = $MonitorCoords[$i+1][1]
						$MonitorStartY = $MonitorCoords[$i+1][2]
						$MonitorEndX = $MonitorCoords[$i+1][3]
						$MonitorEndY = $MonitorCoords[$i+1][4]
						;MsgBox ( $MB_OK, "check2", "check2" & $MonitorSegments[$y][0] & " " & (($MonitorStartX + $MonitorEndX)/$Localmax)*$OffsetValUNQ & " " &(($MonitorStartY + $MonitorEndY)/$Localmax)*$OffsetValUNQ)
						;MsgBox ( $MB_OK, "check4", WinGetTitle($MonitorSegments[$y][0]) & " " &WinGetClientSize($MonitorSegments[$y][0]))
						;_ArrayDisplay($MonitorSegments)
						;MsgBox ( $MB_OK, "check5", $currHWND)
						;activate the window
						;WinActivate($currHWND)
						;some windows return false value when maximized
						;WinSetState($currHWND, '', @SW_RESTORE)
						;MsgBox ( $MB_OK, "check6", WinGetTitle("[ACTIVE]"))
						;MsgBox ( $MB_OK, "check7", WinGetTitle($currHWND))
						;MsgBox ( $MB_OK, "check7b", WinGetPos($currHWND))
						;ArrayDisplay(WinGetPos("Program Manager")) <-- WORKS
						;_ArrayDisplay(WinGetPos($currHWND))
						;MsgBox ( $MB_OK, "check8", WinGetHandle("C:\Users\RaptorPatrolCore\Desktop\2020 JOB HUNT\Cascade+\Cascade+.au3 - Notepad++"))
						;$NewPos = WinMove($MonitorSegments[$y][0], "", (($MonitorStartX + $MonitorEndX)/$Localmax)*$OffsetValUNQ, (($MonitorStartY + $MonitorEndY)/$Localmax)*$OffsetValUNQ)
						;$NewPos = _WinAPI_MoveWindow ( $hWnd, $iX, $iY, $iWidth, $iHeight [, $bRepaint = True] )
						;WinGetClientSize ( "title" [, "text"] )
						;$aArray[0] = Width of window's client area
						;$aArray[1] = Height of window's client area
						;$NewPos = _WinAPI_MoveWindow($MonitorSegments[$y][0], (($MonitorStartX + $MonitorEndX)/$Localmax)*$OffsetValUNQ, (($MonitorStartY + $MonitorEndY)/$Localmax)*$OffsetValUNQ, WinGetClientSize($MonitorSegments[$y][0])[0], WinGetClientSize($MonitorSegments[$y][0])[1])
						$OffsetX = (($MonitorEndX - $MonitorStartX)/$Localmax)*$OffsetValUNQ + $MonitorStartX
						$OffsetY = (($MonitorEndY - $MonitorStartY)/$Localmax)*$OffsetValUNQ + $MonitorStartY
						
						;MsgBox ( $MB_OK, "Pos " & " " & $Localmax, $OffsetValUNQ & " " & $OffsetX & " " & $OffsetY)
						;;;;;MsgBox ( $MB_OK, "Pos " & " " & $Localmax, $MonitorStartX & " " & $MonitorStartY & " " & $MonitorEndX & " " & $MonitorEndY )
						
						WinSetState ($currHWND, "", @SW_SHOW)
						WinSetState ($currHWND, "", @SW_RESTORE)
						
						;$NewPos = _WinAPI_MoveWindow($currHWND, $OffsetX, $OffsetY, 500, 500)
						;WinMove ( "title", "text", x, y [, width [, height [, speed]]] )
						$NewPos = WinMove(HWnd($currHWND), "", $OffsetX, $OffsetY)
						;MsgBox($MB_OK, "ERR", WinWait("[CLASS:Notepad]", "", 1)) 
						;$NewPos = WinMove(WinWait("[CLASS:Notepad]", "", 1), "", $OffsetX, $OffsetY)
						

						WinSetOnTop ($currHWND, "", 0)
						;WinMove($currHWND, "", 0, 0, 200, 200)
						;WinMove(WinWait("[TITLE:FREEK]", "", 1), "", 0, 0, 200, 200)
						;MsgBox($MB_OK, "check3",$currHWND & " " & WinGetPos($currHWND)) 
						;MsgBox($MB_OK, "ERR", _WinAPI_GetLastError()) 
						$OffsetValUNQ += 1
					EndIf
				Next 
			Next
		Case $Label12
			ListViewUpdateWindows($cListView_WindowList)
			;MsgBox ( $MB_OK, "Pos "," ")
		Case $Label13
			_ArrayDisplay($LVItemArray)
		Case $Label14
			;GUICtrlRead($idFile)
			;MsgBox($MB_OK ,"what is empty option for monitor?",GUICtrlRead($Label6b), String(GUICtrlRead($Label6b)) == String(""))
			;MsgBox($MB_OK ,"what is empty option for monitor?",String(GUICtrlRead($Label6b)) == String(""))
			;if no monitor is set, do nothing:
			If String(GUICtrlRead($Label6b)) == String("") Then
				MsgBox($MB_OK ,"pick a monitor","please select a monitor")
			Else
				;MsgBox($MB_OK ,"read all the coords:",GUICtrlRead($Label7b) & "|" & GUICtrlRead($Label8b) & "|" & GUICtrlRead($Label9b) & "|" & GUICtrlRead($Label10b) & "|" & GUICtrlRead($hCombo) & "|" & _ArraySearch($MonitorCoords,$sComboRead))
				;_ArrayDisplay($MonitorCoords)				
				$sComboRead = GUICtrlRead($hCombo)				
				;GUICtrlSetData ( controlID, data [, default] )
				;MsgBox($IDOK ,"search the array",_ArraySearch($MonitorCoords,$sComboRead))
				Local $monitorInt = _ArraySearch($MonitorCoords,$sComboRead)
				;monitorInt should be (# of that monitor+1): _ArraySearch($MonitorCoords,$sComboRead) gives you the current # so it's good enough
				$MonitorCoords[$monitorInt][1] = GUICtrlRead($Label7b)
				$MonitorCoords[$monitorInt][2] = GUICtrlRead($Label8b)
				$MonitorCoords[$monitorInt][3] = GUICtrlRead($Label9b)
				$MonitorCoords[$monitorInt][4] = GUICtrlRead($Label10b)
				;_ArrayDisplay($MonitorCoords)				
			EndIf 
		Case $Label15
			;reset data:
			$MonitorCoords = 0
			dim $MonitorCoords[1][5]
			For $i = 0 To UBound($MonitorArray) - 1
				;to add manually instead of the weird delimited version of _ArrayAdd
				ReDim $MonitorCoords[UBound($MonitorCoords,1)+1][5]
				;assume that monitors come in order I guess...
				;init x/y coords 
				$MonitorCoords[$i+1][0] = $MonitorArray[$i]
				;initial x/y
				$MonitorCoords[$i+1][1] = MonitoInfo()[$i+1][0]
				$MonitorCoords[$i+1][2] = MonitoInfo()[$i+1][1] + 200
				;final x/y
				$MonitorCoords[$i+1][3] = MonitoInfo()[$i+1][0] + 200
				$MonitorCoords[$i+1][4] = MonitoInfo()[$i+1][1]
			Next
	EndSwitch
WEnd

Func _StartTimer()
    $time = TimerInit()
EndFunc

Func _UpdateInfo()
	;update monitor name
    ;update the x coord label
	GUICtrlSetData($Label2b, MouseGetPos()[0])
    ;GUICtrlSetColor($Label2b, 0x00FF00)
	;update the y coord label
	GUICtrlSetData($Label3b, MouseGetPos()[1])
    ;GUICtrlSetColor($Label3b, 0x00FF00)
	;update monitor the mouse is on
	;GUICtrlSetData($Label1b, _WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))[3])
	;_WinAPI_GetMonitorInfo can not have the display so i need to check the length of this to be at least 4 to proceed:
	If UBound(_WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))) > 3 Then
		GUICtrlSetData($Label1b, _WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))[3])
	Else
		GUICtrlSetData($Label1b, "Error, please wait.")
	EndIf
	
	
    ;GUICtrlSetColor($Label1b, 0x00FF00)
EndFunc

Func _ArryRemoveBlanks(ByRef $arr)
  $idx = 0
  For $i = 0 To UBound($arr) - 1
    If $arr[$i] <> "" Then
      $arr[$idx] = $arr[$i]
      $idx += 1
    EndIf
  Next
  ReDim $arr[$idx]
EndFunc ;==>_ArryRemoveBlanks

Func _WinOnMonitor($iXPos, $iYPos)
    Local $aMonitors = _WinAPI_EnumDisplayMonitors()
    If IsArray($aMonitors) Then
        ReDim $aMonitors[$aMonitors[0][0] + 1][5]
        For $ix = 1 To $aMonitors[0][0]
            $aPos = _WinAPI_GetPosFromRect($aMonitors[$ix][1])
            For $j = 0 To 3
                $aMonitors[$ix][$j + 1] = $aPos[$j]
            Next
        Next
    EndIf
    For $ixMonitor = 1 to $aMonitors[0][0] ; Step through array of monitors
        If $iXPos > $aMonitors[$ixMonitor][1] And $iXPos <  $aMonitors[$ixMonitor][1] + $aMonitors[$ixMonitor][3] Then
            If $iYPos > $aMonitors[$ixMonitor][2] And $iYPos < $aMonitors[$ixMonitor][2] + $aMonitors[$ixMonitor][4] Then
                Return $aMonitors[$ixMonitor][0] ; return handle to monitor coordinate is on
            EndIf
        EndIf
    Next
    Return 0 ;Return 0 if coordinate is on none of the monitors
EndFunc ;==>  _WinOnMonitor

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
    $hWndListView = $hListView

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
				Case $LVN_BEGINDRAG
					Global $initIndex = _GUICtrlListView_GetHotItem($hListView)
					;MsgBox($MB_OK, "is this an index or what??", "not declared")
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					#comments-start
						_GUICtrlListView_SubItemHitTest
						Returns an array with the following format:
						[ 0] - 0-based index of the item at the specified position, or -1
						[ 1] - 0-based index of the subitem at the specified position, or -1
						[ 2] - If True, position is in control's client window but not on an item
						[ 3] - If True, position is over item icon
						[ 4] - If True, position is over item text
						[ 5] - If True, position is over item state image (THE DEFAULT FROM THE FIRST COLUMN)
						[ 6] - If True, position is somewhere on the item
						[ 7] - If True, the position is above the control's client area
						[ 8] - If True, the position is below the control's client area
						[ 9] - If True, the position is to the left of the client area
						[10] - If True, the position is to the right of the client area
					#comments-end
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					Local $aHit = _GUICtrlListView_SubItemHitTest( $hListView )
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
						;EndIf
						;MsgBox ( $MB_OK, "title", "click")
                        Return 1
					ElseIf $aHit[0] >= 0 And $aHit[1] >= 3 Then                                                		   	    ; Item and subitem
						;MsgBox ( $MB_OK, "title", $aHit[0] & "|" & $aHit[1])
						Local $iIcon = _GUICtrlListView_GetItemImage( $cListView_WindowList, $aHit[0], $aHit[1] )      		; Get checkbox icon
						_GUICtrlListView_SetItemImage( $cListView_WindowList, $aHit[0], $iIcon = 0 ? 1 : 0, $aHit[1] ) 		; Toggle checkbox icon
						;MsgBox ( $MB_OK, "title", $aHit[0] & "|" & $aHit[1] & "|" & $iIcon)
						;MsgBox($MB_OK, "LVItemArray update", $LVItemArray[$aHit[0]][1] & "|" & $LVItemArray[$aHit[0]][4] & "|" & $LVItemArray[$aHit[0]][5])
						;MsgBox($MB_OK, "LVItemArray update", $aHit[0] & "|" & $aHit[1]+1 & "|" & Mod($iIcon + 1, 2))
						;update the LVItemArray array
						$LVItemArray[$aHit[0]][$aHit[1]+1] = Mod($iIcon + 1, 2)
						;$LVItemArray[$aHit[0]][$aHit+1] = 3
						;MsgBox($MB_OK, "LVItemArray update", "ahitcoords are?" & $aHit[0] & "|" & $aHit[1]+1 & "|" & $LVItemArray[$aHit[0]][1] & "|" & $LVItemArray[$aHit[0]][4] & "|" & $LVItemArray[$aHit[0]][5] & "|" & $LVItemArray[$aHit[0]][$aHit[1]+1])
						;_ArrayDisplay($LVItemArray) <--- this freezes up
						;clear all other checkboxes so we force user to pick only one monitor (aka a window cannot exist in more than 1 monitor right?)
						
						;MsgBox($MB_OK, "title", $aHit)
						;know we have 3 initial columns + # of monitors so just iterate over # of monitors +3 to clear checkmarks AND skip $aHit[1].
						For $i = 0 To UBound($MonitorArray) - 1
							;if we're not the selected column set the subitem to empty checkbox
							If $i + 3 <> $aHit[1] Then
								_GUICtrlListView_SetItemImage($cListView_WindowList, $aHit[0], 0, $i + 3 )
								;MsgBox($MB_OK, "LVItemArray check the entire fucking row", $i & "|" & $aHit[0] & "|" & $aHit[1] & "|" & $LVItemArray[$aHit[0]][0] & "|" & $LVItemArray[$aHit[0]][1] & "|" & $LVItemArray[$aHit[0]][2] & "|" & $LVItemArray[$aHit[0]][3] & "|" & $LVItemArray[$aHit[0]][4] & "|" & $LVItemArray[$aHit[0]][5])
								;$LVItemArray[$aHit[0]][$aHit[1]+1+$i] = 0
								$LVItemArray[$aHit[0]][$i+4] = 0
							EndIf
						Next
						;_GUICtrlListView_RedrawItems( $cListView_WindowList, $aHit[0], $aHit[0] )                      ; Redraw listview item
						_WinAPI_RedrawWindow($cListView_WindowList)
                    EndIf

                Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
                        ;MsgBox ( $MB_OK, "title", "click2")
						Return 1
                    EndIf
                    
                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
                        ;MsgBox ( $MB_OK, "title", "click3")
						Return 1
                    EndIf

                Case $NM_RDBLCLK ; Sent by a list-view control when the user double-clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
							;MsgBox ( $MB_OK, "title", "click4")
						Return 1
                    EndIf

            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

;this activates only when you drag the mouse heads up so NOT a single solo click
; WM_LBUTTONUP event handler
; ------------------------------------------------------
Func WM_LBUTTONUP($hWndGUI, $iMsgID, $wParam, $lParam)
	;MsgBox($MB_OK, "did i release?", "maybe") $hGUI
    #forceref $iMsgID, $wParam
	Global $g_hListView
	Local $aPos = ControlGetPos($hWndGUI, "", $g_hListView)
    Local $x = BitAND($lParam, 0xFFFF) - $aPos[0]
    Local $y = BitShift($lParam, 16) - $aPos[1]
	_WinAPI_ReleaseCapture()
	;cListView_WindowList <=> Success: the handle to the ListView control. 
	;right now i have the identifier [the identifier (controlID) of the new control.]
	;;this is the handle ? hListView
	Local $tStruct_LVHITTESTINFO = DllStructCreate($tagLVHITTESTINFO)
	DllStructSetData($tStruct_LVHITTESTINFO, "X", $x)
    DllStructSetData($tStruct_LVHITTESTINFO, "Y", $y)
	;$g_aIndex[1] = _SendMessage(ControlGetHandle($hGUI, "", $cListView_WindowList), $LVM_HITTEST, 0, DllStructGetPtr($tStruct_LVHITTESTINFO), 0, "wparam", "ptr")
    $g_aIndex = _SendMessage($hListView, $LVM_HITTEST, 0, DllStructGetPtr($tStruct_LVHITTESTINFO), 0, "wparam", "ptr")
	MsgBox($MB_OK, "start index to end index", $initIndex & "|" & $g_aIndex)
	;DllCall()
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_LBUTTONUP


;modified by Yibing
;Last modified Feb 15, 2008
;MonitoInfo()

Func MonitoInfo()
    Const $DISPLAY_DEVICE_MIRRORING_DRIVER_B    = 0x00000008
    Const $ENUM_CURRENT_SETTINGS_B = -1
    Const $DISPLAY_DEVICE = "int;char[32];char[128];int;char[128];char[128]"
    Const $DEVMODE = "byte[32];short;short;short;short;int;int[2];int;int" & _
                    ";short;short;short;short;short;byte[32]" & _
                    ";short;ushort;int;int;int;int"
                    
    Dim $MonitorPos[1][4]
    $dev = 0
    $id = 0
    $dll = DllOpen("user32.dll")
    $msg = ""

    Dim $dd = DllStructCreate($DISPLAY_DEVICE)
    DllStructSetData($dd, 1, DllStructGetSize($dd))

    Dim $dm = DllStructCreate($DEVMODE)
    DllStructSetData($dm, 4, DllStructGetSize($dm))

    Do
        $EnumDisplays = DllCall($dll, "int", "EnumDisplayDevices", _
                "ptr", "NULL", _
                "int", $dev, _
                "ptr", DllStructGetPtr($dd), _
                "int", 0)
        $StateFlag = Number(StringMid(Hex(DllStructGetData($dd, 4)), 3))
        If ($StateFlag <> $DISPLAY_DEVICE_MIRRORING_DRIVER_B) And ($StateFlag <> 0) Then;ignore virtual mirror displays
            $id += 1
            ReDim $MonitorPos[$id+1][5]
            $EnumDisplaysEx = DllCall($dll, "int", "EnumDisplaySettings", _
                    "str", DllStructGetData($dd, 2), _
                    "int", $ENUM_CURRENT_SETTINGS, _
                    "ptr", DllStructGetPtr($dm))
            $MonitorPos[$id][0] = DllStructGetData($dm, 7, 1)
            $MonitorPos[$id][1] = DllStructGetData($dm, 7, 2)
            $MonitorPos[$id][2] = DllStructGetData($dm, 18)
            $MonitorPos[$id][3] = DllStructGetData($dm, 19)
			;MsgBox(0,"What's dm?",$dm)
            $msg &= "Monitor " & ($id) & " start point:(" &  _
                DllStructGetData($dm, 7, 1) & "," & _
                DllStructGetData($dm, 7, 2) & ") " & @TAB & "Screen resolution: " & _
                DllStructGetData($dm, 18) & "x" & _
                DllStructGetData($dm, 19) & @LF
        EndIf
        $dev += 1
    Until $EnumDisplays[0] = 0

    $MonitorPos[0][0] = $id
    DllClose($dll)

    ;MsgBox(0,"Screen Info",$msg)
    return $MonitorPos
EndFunc

Func ListViewUpdateWindows($LVctrl)
	;$LVctrl is the control of the List View
	;_ArrayDisplay($LVItemArray)
	;make copy of array
	$LVItemArrayCopy = $LVItemArray
	;delete everything
	For $x = 0 To UBound($LVItemArray,1) - 1
		GUICtrlDelete($LVItemArray[$x][0])
	Next
	$LVItemArray = 0
	;_ArrayDisplay($LVItemArray)
	;_GUICtrlListView_DeleteAllItems($LVctrl)
	;remake the listview
	;$LVctrl = GUICtrlCreateListView($sHeaders, 10, 220, 400, 200)
	;_GUICtrlListView_SetExtendedListViewStyle($LVctrl, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_SUBITEMIMAGES))
	;$hListView = GUICtrlGetHandle( $LVctrl )  
	;Local $hStateImageList = _GUICtrlListView_GetImageList( $LVctrl, 2 ) ; 2 = Image list with state images
	; Add state ImageList as a normal ImageList
	;_GUICtrlListView_SetImageList( $hListView, $hStateImageList, 1 ) ; 1 = Image list with small icons

	;redo gathering windows
	;how to clear array
	;$array = 0	
	$aIndexList = 0	
	Global $aIndexList[1]

	;Retrieve a list of window handles.
	Local $aList = WinList("[REGEXPTITLE:(?i)(.+)]")
	;$aListFiltered = 0
	Local $aListFiltered[0]
	;$aTitles = 0
	Local $aTitles[0]
	
	;filter winlist to get rid of windows with no titles and manually remove program manager
	For $i = 1 to $aList[0][0]
		;have to manually remove program manager I think
		If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) == 2 And $aList[$i][0] <> "Program Manager" Then
			_ArrayAdd($aListFiltered, $aList[$i][1])
			_ArrayAdd($aTitles, $aList[$i][0])
		EndIf
	Next
	;make empty array
	$aArrayFinal = 0
	Local $aArrayFinal[UBound($aListFiltered, 1)][5]
	$IndexCounter = 0
	#comments-start
	#comments-end
	;populate array
	For $i = 0 to UBound($aListFiltered, 1)-1
		;MsgBox ( $MB_OK, "title", $i & UBound($aListFiltered, 1) & WinGetTitle($aListFiltered[$i]) & $aListFiltered[$i] & _ProcessGetName($aListFiltered[$i]) & WinGetPos ($aListFiltered[$i]) & WinGetClientSize ($aListFiltered[$i]))
		;name
		;wingettitle fails on microsoft edge for some reason
		;$aArrayFinal[$i][0] = WinGetTitle($aListFiltered[$i])
		;$aArrayFinal[$i][0] = _ProcessGetName(WinGetProcess($aListFiltered[$i]))
		$aArrayFinal[$i][0] = $aTitles[$i]
		;HWND
		$aArrayFinal[$i][1] = $aListFiltered[$i]
		;exe name
		$aArrayFinal[$i][2] = _ProcessGetName(WinGetProcess($aListFiltered[$i]))
		;pos
		$aArrayFinal[$i][3] = WinGetPos($aListFiltered[$i])[0] & "," & WinGetPos($aListFiltered[$i])[1]
		;size
		$aArrayFinal[$i][4] = WinGetClientSize($aListFiltered[$i])[0] & "," & WinGetClientSize($aListFiltered[$i])[1]
	Next
	dim $LVItemArray[1][4]
	;make array bigger depending on # of monitors
	For $imonitor = 0 To $Monitors[0][0]-1
		;_ArrayDisplay($LVItemArray)
		Redim $LVItemArray[1][UBound($LVItemArray,2)+1]
	Next
	For $rowInt = 0 To UBound($aArrayFinal, 1)-1
		;init with name
		Local $blankStr = $aArrayFinal[$rowInt][0]
		$blankStr &=  "|" & $aArrayFinal[$rowInt][2] & "|" & $aArrayFinal[$rowInt][1]
		;add title
		$LVItem = GUICtrlCreateListViewItem ( $blankStr, $LVctrl)
		;$IndexCounter = GUICtrlCreateListViewItem ( $blankStr, $LVctrl)
		;MsgBox($MB_OK, "Indexcounter does not match item index...", $blankStr & "|" & $LVItem & "|" & $IndexCounter)
		_ArrayAdd($LVItemArray, $LVItem & "|" & $blankStr )
		;HEADS UP
		;IN THIS CASE $LVItem = GUICtrlCreateListViewItem IS NOT OUR CONTROLID. The control ID is still a sequence. Since $rowInt is counting from the UBound our LVItem is numbered according to the windows not the control ID's if that makes any sense
		;HEADS UP CONTROL != YOUR ID
		_GUICtrlListView_SetItemState($hListView, $IndexCounter, 0, $LVIS_STATEIMAGEMASK)
		
		;_ArrayDisplay($LVItemArrayCopy)
		;add the checkboxes per monitor
		For $imonitor = 0 To $Monitors[0][0]-1
			;search for the array in LVItemArrayCopy
			;_ArraySearch ( Const ByRef $aArray, $vValue [, $iStart = 0 [, $iEnd = 0 [, $iCase = 0 [, $iCompare = 0 [, $iForward = 1 [, $iSubItem = -1 [, $bRow = False]]]]]]] )
			;MsgBox($MB_OK, $aArrayFinal[$rowInt][0] & "|" & $aArrayFinal[$rowInt][1], _ArraySearch($LVItemArrayCopy, $aArrayFinal[$rowInt][1]))
			;_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, 0, 3) ; 3 is the zero based index of fourth column
			$ExistenceCheck = _ArraySearch($LVItemArrayCopy, $aArrayFinal[$rowInt][1])
			If $ExistenceCheck <> -1 Then
				;_ArrayDisplay($LVItemArray)
				;MsgBox($MB_OK, "", $ExistenceCheck & "|" & $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor])
				_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor], 3 + $imonitor)
				;MsgBox($MB_OK, "title",UBound($LVItemArray,1)-1)
				$LVItemArray[UBound($LVItemArray,1)-1][4 + $imonitor] = $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor]
			;if you can't find it just set as blank
			Else
				;_ArrayDisplay($LVItemArray)
				;MsgBox($MB_OK, "title",UBound($LVItemArray,1)-1)
				_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, 0, 3 + $imonitor)
				$LVItemArray[UBound($LVItemArray,1)-1][4 + $imonitor] = 0
			EndIf
		Next
		;_WinAPI_RedrawWindow($LVctrl)
		_ArrayAdd ( $aIndexList, $IndexCounter)
		$IndexCounter += 1
	Next
	;_ArrayDisplay($LVItemArray)
	;THIS IS FOR INDEXLIST TO CLEAR 1ST CHECKBOX
	_ArrayDelete ( $aIndexList, 0 )
	_ArrayDelete ( $LVItemArray, 0 )
	;_ArrayDisplay($aIndexList)
	;_WinAPI_RedrawWindow($hListView)
	;GUIRegisterMsg( $WM_NOTIFY, "WM_NOTIFY" )
	
EndFunc