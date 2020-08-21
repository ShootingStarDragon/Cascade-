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

;set aIndexList of indicies so i can clear the checkboxes on 1st column
Global $aIndexList[1]

;Retrieve a list of window handles.
Local $aList = WinList("[REGEXPTITLE:(?i)(.+)]")
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
		;there is a problem when something like firefox has "|" in the title... i have to filter that char out		
		_ArrayAdd($aListFiltered, $aList[$i][1])
		_ArrayAdd($aTitles, StringRegExpReplace($aList[$i][0],"\|","_"))
	EndIf
Next
;let's check it right now by displaying aListFiltered
;_ArrayDisplay($aListFiltered, "check")

;make the array with info:
;NAME			HWND 			exe name 	PID	position 	size
;array size is Ubound of the filtered list and 5 columns
;make empty array
Local $aArrayFinal[UBound($aListFiltered, 1)][5]

;populate array
For $i = 0 to UBound($aListFiltered, 1)-1
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

;make a dropdown list of monitors
dim $MonitorArray[1]

$Monitors = _WinAPI_EnumDisplayMonitors()

;set window titles appropriately
;update the window title properly when new monitors are connected? nah just restart Cascade+

Local $sHeaders = "Window Title|App Name(.exe)|Window Handle"

;keep track of controls so I can delete properly
dim $LVItemArray[1][4]

For $intmon = 1 To $Monitors[0][0]
	_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	$sHeaders &= "|Monitor " & $intmon
	redim $LVItemArray[UBound($LVItemArray, 1)][UBound($LVItemArray,2)+1]
Next
	
;remove empty init element in MonitorArray
_ArryRemoveBlanks($MonitorArray)

;GUICreate ( "title" [, width [, height [, left = -1 [, top = -1 [, style = -1 [, exStyle = -1 [, parent = 0]]]]]]] )
$hGUI = GUICreate("Cascade+",600,500,-1,-1,$WS_SIZEBOX )
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
;$Label13 = GUICtrlCreateButton("CHECK ARRAY", 120, 450, 120, 20);used to check arraystates when debugging
$Label14 = GUICtrlCreateButton("Update Coordinates", 220, 120, 120, 20)
$Label15 = GUICtrlCreateButton("Reset Coordinates", 220, 140, 120, 20)
;$Label16 = GUICtrlCreateButton("Check ini", 340, 140, 120, 20)

;OnLoad: make sure init file exists. if not, create it

If FileExists ("CascadePrev.ini") Then
	;MsgBox($MB_OK, "cascade succ", "wut")
Else
	;MsgBox($MB_OK, "cascade fail", "wot")
	FileOpen ("CascadePrev.ini",1 )
	FileWrite("CascadePrev.ini", "[LastSession]")
EndIf

;It is important to use _GUIListViewEx_Close when a enabled ListView is deleted to free the memory used
;                    by the $aGLVEx_Data array which shadows the ListView contents.
;_GUIListViewEx_Close($iLV_Index)

Global $cListView_WindowList = GUICtrlCreateListView($sHeaders, 10, 220, 550, 200) ;$LVS_SHOWSELALWAYS

_GUICtrlListView_SetExtendedListViewStyle($cListView_WindowList, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_SUBITEMIMAGES, $LVS_EX_FULLROWSELECT));$LVS_EX_GRIDLINES

Global $hListView = GUICtrlGetHandle( $cListView_WindowList )    
;apparently you can checkboxes twice to get an extra space for a supposed checkbox or smth...
; Get state ImageList
;Local $hStateImageList = _GUICtrlListView_GetImageList( $idListView2, 2 ) ; 2 = Image list with state images
Local $hStateImageList = _GUICtrlListView_GetImageList( $cListView_WindowList, 2 ) ; 2 = Image list with state images
; Add state ImageList as a normal ImageList
_GUICtrlListView_SetImageList( $hListView, $hStateImageList, 1 ) ; 1 = Image list with small icons
; Register WM_NOTIFY message handler
;You will need to register some Windows messages so that the UDF can intercept various key and mouse events and determine the correct actions to take. 
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_LBUTTONUP, "WM_LBUTTONUP")
Local $IndexCounter = 0

;_ArrayDisplay($aArrayFinal)
;_ArrayDisplay($LVItemArray)
For $rowInt = 0 To UBound($aArrayFinal, 1)-1
	;MsgBox ( $MB_OK, "start of MY ROW", "")
	
	;init with name
	Local $blankStr = $aArrayFinal[$rowInt][0] & "|" & $aArrayFinal[$rowInt][2] & "|" & $aArrayFinal[$rowInt][1]
	
	;add title
	$LVItem = GUICtrlCreateListViewItem ( $blankStr, $cListView_WindowList)
	
	;clear the checkbox
	;HEADS UP
	;IN THIS CASE $LVItem = GUICtrlCreateListViewItem IS NOT OUR CONTROLID. The control ID is still a sequence. Since $rowInt is counting from the UBound our LVItem is numbered according to the windows not the control ID's if that makes any sense
	;HEADS UP CONTROL != YOUR ID
	_GUICtrlListView_SetItemState($hListView, $IndexCounter, 0, $LVIS_STATEIMAGEMASK)
	
	$LVItemArrayItem =  $LVItem & "|" & $blankStr
	;add the checkboxes per monitor
	For $imonitor = 0 To $Monitors[0][0]-1
		If IniRead("CascadePrev.ini", "LastSession", $aArrayFinal[$rowInt][2], "ERR") == $imonitor+1 Then
			_GUICtrlListView_SetItemImage( $cListView_WindowList, $IndexCounter, 1, 3 + $imonitor) 
			$LVItemArrayItem &= "|" & 1
		Else
			_GUICtrlListView_SetItemImage( $cListView_WindowList, $IndexCounter, 0, 3 + $imonitor) 
			$LVItemArrayItem &= "|" & 0
		EndIf
	Next
	_ArrayAdd($LVItemArray, $LVItemArrayItem)
	_ArrayAdd($aIndexList, $IndexCounter)
	;_ArrayAdd($aIndexList, UBound($aIndexList, $1) - 1)
	$IndexCounter += 1
Next

;copy array to arraycopy
;rewrite in the right order from arraycopy to array

;sort by window1
;then amongst window1, sort by ini file pos
;repeat per window
;put all the blank windows at the end

_ArrayDelete($aIndexList, 0)
_ArrayDelete($LVItemArray, 0)

;last pos so i can set the pos differently for each monitor
$lastpos = 0
;this is the beginningpos for in-window sorting
$beginningpos = 0
;_ArrayDisplay($LVItemArray)
For $imonitor = 0 To $Monitors[0][0]-1
	;sort out per monitor
	$BlankRowList = $lastpos
	Local $BlankRowList[UBound($LVItemArray, 1)]
	For $BlankRowInit = 0 to UBound($BlankRowList, 1)-1
		$BlankRowList[$BlankRowInit] = 0
	Next
	For $lastIndexVar = $lastpos To UBound($LVItemArray,1) - 1
		;remember the last empty spot in the array for this monitor
		
		;remember to manipulate both the LVItem array AND the actual listview
		;update the array
		;switch the control ID's
		If 1 == $LVItemArray[$lastIndexVar][$imonitor+4] Then
			;MsgBox($MB_OK ,"pick a monitor","hello")
			;_ArrayDisplay($BlankRowList)
			;search for a 1 in BlankRowList that is earlier than current $lastIndexVar
			$Test = _ArraySearch($BlankRowList, 1)
			If $Test < $lastIndexVar And $Test <> -1 Then
				;then swap positions (;also swap positions in the listview array)
				;start index
				$startmem = $LVItemArray[$Test][0]
				;end index
				$endmem = $LVItemArray[$lastIndexVar][0]
				;update the array 
				_ArraySwap($LVItemArray, $Test, $lastIndexVar, False)
				;switch back the control IDs
				$LVItemArray[$lastIndexVar][0] = $endmem
				$LVItemArray[$Test][0] = $startmem
				;then reset the 1 to a 0
				$BlankRowList[$Test] = 0
				;also when u switch the new spot is a blank now as well
				$BlankRowList[$lastIndexVar] = 1
				;MsgBox($MB_OK ,"pick a monitor","set to 0" &"|"& $Test)
				;attempt to set lastpos. if lastpos is larger than our current pos, skip
				If $lastpos < $Test+1 Then
					$lastpos = $Test+1
					
				EndIf
			EndIf
		Else
			;set that value in BlankRowList to 1
			$BlankRowList[$lastIndexVar] = 1
			;MsgBox($MB_OK ,"pick a monitor",$lastIndexVar & "|" & $BlankRowList[$lastIndexVar])
			;_ArrayDisplay($BlankRowList)
			;_ArrayDisplay($LVItemArray)
		EndIf
	Next
	;when you are done sorting Per-monitor, then you sort each window section from beginningpos(?) to endpos(?)
	$endpos = _ArraySearch($BlankRowList, 1)
	For $sortpos = $beginningpos+1 To $endpos-1
		;position of current app in the ini file
		$appPos = IniRead("CascadePrev.ini", "LastSessionPOS", $LVItemArray[$sortpos][2] & "POS", "DEFFAIL")
		$appID = $LVItemArray[$sortpos][0]
		;go back to the beginning to compare and sort
		For $sortposb = $beginningpos To $sortpos
			;MsgBox ( $MB_OK, "title", "indexpos current check VS checking against " &"|"& $sortpos &"|"& $sortposb)
			;MsgBox ( $MB_OK, "title", "current and previous compares " &"|"& $LVItemArray[$sortpos][2] &"|"& $LVItemArray[$sortposb][2])
			$prevappPos = IniRead("CascadePrev.ini", "LastSessionPOS", $LVItemArray[$sortposb][2] & "POS", "DEFFAIL")
			$prevappID = $LVItemArray[$sortposb][0]
			;MsgBox ( $MB_OK, "title", "comarpingb " &"|"& $appPos &"|"& $prevappPos )
			;MsgBox ( $MB_OK, "title",  Int($appPos) < Int($prevappPos))
			;comparing 1 to 1 is whatevs
			;insert at the first time when the current pos is less than the pos i am checking
			;if current pos in ini is smaller than prevpos, switch
			If Int($appPos) < Int($prevappPos) Then
				;MsgBox ( $MB_OK, "title", "SWAP")
				;_ArrayDisplay($LVItemArray)
				;remember to swap the control ID's then u swap to preserve order...
				$LVItemArray[$sortpos][0]  = $prevappID
				$LVItemArray[$sortposb][0] = $appID
				_ArraySwap($LVItemArray, $sortpos, $sortposb)
				;_ArrayDisplay($LVItemArray)
				;since we swap, set checking against (sortposb) to the end to force end
				$sortposb = $sortpos
			EndIf
		Next
	Next
	;also set beginningpos to lastpos when you are done sorting
	$beginningpos = $lastpos
Next
;_ArrayDisplay($LVItemArray)
;redraw the listview to reflect LVItemArray update
For $i = 0 To UBound($LVItemArray,1) - 1
	$blankstr = $LVItemArray[$i][1]
	For $x = 2 To UBound($LVItemArray,2) - 3
		$blankstr &= "|" & $LVItemArray[$i][$x]
	Next
	GUICtrlSetData($LVItemArray[$i][0], $blankstr)
	;update checkboxes
	For $imonitor = 0 To $Monitors[0][0]-1
		_GUICtrlListView_SetItemImage( $cListView_WindowList, $i, $LVItemArray[$i][4 + $imonitor], 3 + $imonitor)
	Next
Next

;redraw everything so checkboxes get removed
;_WinAPI_RedrawWindow($hListView)
Global $time = -1

GUISetState()

While 1
	If $time = -1 Then ; this should only run once
        _StartTimer()
    EndIf
	
	Sleep(10)

	If TimerDiff($time) > 1000 Then
        _UpdateInfo()
        $time = 0
        $time = TimerInit()
    EndIf
	
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			;write down app name and which monitor it was at			
			For $i = 0 To UBound($LVItemArray) - 1 
				;check the right window assoc with the current app
				$window = 0
				For $j = 4 to UBound($LVItemArray,2) - 1 
					If $LVItemArray[$i][$j] == 1 Then
						$window = $j-3
					EndIf
				Next
				;write if not found
				If IniRead ( "CascadePrev.ini", "LastSession", $LVItemArray[$i][2], "ERR") == "ERR" Then
					IniWrite ( "CascadePrev.ini", "LastSession", $LVItemArray[$i][2], $window )
				;update if not the same
				ElseIf IniRead ( "CascadePrev.ini", "LastSession", $LVItemArray[$i][2], "ERR") <> $window Then
					IniWrite ( "CascadePrev.ini", "LastSession", $LVItemArray[$i][2], $window )
				EndIf
				;write the current pos of the window
				IniWrite ( "CascadePrev.ini", "LastSessionPOS", $LVItemArray[$i][2] & "POS", $LVItemArray[$i][0])
			Next
			Exit
		Case $hCombo
			$sComboRead = GUICtrlRead($hCombo)
			GUICtrlSetData($Label6b, $sComboRead)
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
						$MonitorStartX = $MonitorCoords[$i+1][1]
						$MonitorStartY = $MonitorCoords[$i+1][2]
						$MonitorEndX = $MonitorCoords[$i+1][3]
						$MonitorEndY = $MonitorCoords[$i+1][4]
						
						;activate the window
						;WinActivate($currHWND)
						;some windows return false value when maximized
						;WinSetState($currHWND, '', @SW_RESTORE)
						
						;WinGetClientSize ( "title" [, "text"] )
						;$aArray[0] = Width of window's client area
						;$aArray[1] = Height of window's client area
						
						$OffsetX = (($MonitorEndX - $MonitorStartX)/$Localmax)*$OffsetValUNQ + $MonitorStartX
						$OffsetY = (($MonitorEndY - $MonitorStartY)/$Localmax)*$OffsetValUNQ + $MonitorStartY
						
						WinSetState ($currHWND, "", @SW_SHOW)
						WinSetState ($currHWND, "", @SW_RESTORE)
						
						$NewPos = WinMove(HWnd($currHWND), "", $OffsetX, $OffsetY)

						WinSetOnTop ($currHWND, "", 0)
						$OffsetValUNQ += 1
					EndIf
				Next 
			Next
		Case $Label12
			ListViewUpdateWindows($cListView_WindowList)

		Case $Label14
			;if no monitor is set, do nothing:
			If String(GUICtrlRead($Label6b)) == String("") Then
				MsgBox($MB_OK ,"pick a monitor","please select a monitor")
			Else
				$sComboRead = GUICtrlRead($hCombo)				
				;GUICtrlSetData ( controlID, data [, default] )
				Local $monitorInt = _ArraySearch($MonitorCoords,$sComboRead)
				;monitorInt should be (# of that monitor+1): _ArraySearch($MonitorCoords,$sComboRead) gives you the current # so it's good enough
				$MonitorCoords[$monitorInt][1] = GUICtrlRead($Label7b)
				$MonitorCoords[$monitorInt][2] = GUICtrlRead($Label8b)
				$MonitorCoords[$monitorInt][3] = GUICtrlRead($Label9b)
				$MonitorCoords[$monitorInt][4] = GUICtrlRead($Label10b)
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
		#comments-start
		Case $Label13
			_ArrayDisplay($LVItemArray)
			;_ArrayDisplay($aIndexList)
		Case $Label16
			For $i = 0 To UBound($LVItemArray) - 1 
				;check the right window assoc with the current app
				$window = 0
				For $j = 3 to UBound($LVItemArray,2) - 1 
					If $LVItemArray[$i][$j] == 1 Then
						$window = $LVItemArray[$i][$j]
					EndIf
				Next
				MsgBox($MB_OK , "woot", $LVItemArray[$i][2] & "|" & IniRead("CascadePrev.ini", "LastSession", $LVItemArray[$i][2], "ERR") & "|" & $window)
				;write if not found
				If IniRead("CascadePrev.ini", "LastSession", $LVItemArray[$i][2], "ERR") == "ERR" Then
					IniWrite("CascadePrev.ini", "LastSession", $LVItemArray[$i][2], $window )
				;update if not the same
				ElseIf IniRead("CascadePrev.ini", "LastSession", $LVItemArray[$i][2], "ERR") <> $window Then
					IniWrite("CascadePrev.ini", "LastSession", $LVItemArray[$i][2], $window )
				EndIf
			Next
		#comments-end
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
	;_WinAPI_GetMonitorInfo can not have the display so i need to check the length of this to be at least 4 to proceed:
	$MouseData = _WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))
	;     		 _WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))[3]
	If UBound($MouseData) > 3 Then
		GUICtrlSetData($Label1b, $MouseData[3])
	Else
		GUICtrlSetData($Label1b, "Error, please wait.")
	EndIf
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
				;this is to allow me to sort out the listview by clicking columns
				Case $LVN_COLUMNCLICK ; A column was clicked
					Local $tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
					Local $iCol = DllStructGetData($tInfo, "SubItem")
					Switch $iCol
						;make sure we are actually clicking on a monitor column
						Case $iCol > 2
							;MsgBox($MB_OK,"look for title pos",$iCol)
							
							;idea: do the selected column first, then sort out the rest of the columns in order as well. AKA
							;for columns 1 2 3 4
							; I click col 2
							;then I do 
							;2 1 3 4 in order
							;no 0 since monitors start counting at 1
							
							$ColSeq = 0 ; each # in this array is monitor from #1 to #n
							Local $ColSeq[$Monitors[0][0]]
							For $ColSeqInit = 0 to UBound($ColSeq, 1)-1
								Switch $ColSeqInit
									Case $ColSeqInit < $iCol-2
										$ColSeq[$ColSeqInit] = $ColSeqInit
									Case $ColSeqInit >= $iCol-2 
										$ColSeq[$ColSeqInit] = $ColSeqInit+1
								EndSwitch
								$ColSeq[0] = $iCol-2
							Next
							
							;For $x = 0 to UBound($ColSeq, 1)-1
							;	MsgBox ( $MB_OK, "colseq", $x &"|"& $ColSeq[$x] )
							;Next
							$lastpos = 0
							
							For $iMonitor = 0 To $Monitors[0][0]-1
								$BlankRowList = 0
								Local $BlankRowList[UBound($LVItemArray, 1)]
								For $BlankRowInit = 0 to UBound($BlankRowList, 1)-1
									$BlankRowList[$BlankRowInit] = 0
								Next
								For $lastIndexVar = $lastpos to UBound($LVItemArray,1) - 1
									;;MsgBox ( $MB_OK, "arraycounts", $lastIndexVar &"|"&  $ColSeq[$iMonitor]+3 &"|"& $LVItemArray[$lastIndexVar][$ColSeq[$iMonitor]+3])
									;MsgBox ( $MB_OK, "arraycountsb", 1 == $LVItemArray[$lastIndexVar][$ColSeq[$iMonitor]+3])
									;MsgBox ( $MB_OK, "lastpos is", $lastpos)
									;If 1 ==_GUICtrlListView_GetItemImage( $cListView_WindowList, $lastIndexVar, $ColSeq[$iMonitor]+2) Then
									If 1 == $LVItemArray[$lastIndexVar][$ColSeq[$iMonitor]+3] Then
										$Test = _ArraySearch($BlankRowList, 1)
										If $Test < $lastIndexVar And $Test <> -1 Then
											;MsgBox ( $MB_OK, "lastpos is", $lastpos)
											;MsgBox ( $MB_OK, "swap", $lastIndexVar &"|"& $Test &"|"& $LVItemArray[$lastIndexVar][1] &"|"& $LVItemArray[$Test][1])
											;start index
											$startmem = $LVItemArray[$Test][0]
											;end index
											$endmem = $LVItemArray[$lastIndexVar][0]
											;update the array 
											_ArraySwap($LVItemArray, $Test, $lastIndexVar, False)
											;switch back the control IDs
											$LVItemArray[$lastIndexVar][0] = $endmem
											$LVItemArray[$Test][0] = $startmem
											;then reset the 1 to a 0
											$BlankRowList[$Test] = 0
											;also when u switch the new spot is a blank now as well
											$BlankRowList[$lastIndexVar] = 1
											;;MsgBox($MB_OK ,"pick a monitor","set to 0" &"|"& $Test)
											;attempt to set lastpos. if lastpos is larger than our current pos, skip
											If $lastpos < $Test+1 Then
												$lastpos = $Test+1
											EndIf
										ElseIf $Test <> -1 Then
											;basically clear this to stop me from swapping to checked line items in the 2nd, 3rd passes of monitor
											$BlankRowList[$Test] = 0
										EndIf
									Else
										$BlankRowList[$lastIndexVar] = 1
									EndIf
									;now i have to account for when everything is ordered and you do not move anything, so $lastpos never gets set.
									IF $lastIndexVar == UBound($LVItemArray,1) - 1 and $lastpos == 0 Then
										;reverse search for the end of that 'column'
										;MsgBox ( $MB_OK, "does next block even run?", )
										For $elemtest = UBound($LVItemArray,1) - 1 to 0 Step -1
											;check if is 1 on that monitor on row elemtest
											;return the first val we find
											;MsgBox ( $MB_OK, "does the check fail?", $elemtest,$ColSeq[$iMonitor]+3,$LVItemArray[$elemtest][$ColSeq[$iMonitor]+3])
											If 1 == $LVItemArray[$elemtest][$ColSeq[$iMonitor]+3] Then
												$lastpos = $elemtest+1
												ExitLoop 
											EndIf
										Next
									EndIf
									
								Next
							Next
							;redraw the listview
							For $i = 0 To UBound($LVItemArray,1) - 1
								$blankstr = $LVItemArray[$i][1]
								For $x = 2 To UBound($LVItemArray,2) - 3
									$blankstr &= "|" & $LVItemArray[$i][$x]
								Next
								GUICtrlSetData($LVItemArray[$i][0], $blankstr)
								;update checkboxes
								For $imonitorx = 0 To $Monitors[0][0]-1
									_GUICtrlListView_SetItemImage( $cListView_WindowList, $i, $LVItemArray[$i][4 + $imonitorx], 3 + $imonitorx)
								Next
							Next

							#comments-start
							;for each item in the listview
							For $rowInt = 0 To UBound($LVItemArray, 1)-1
								;if that item is checked yes on the column that was selected
								;here i assume 1 for item image is checked. also assuming iCol and rowInt don't go out of bounds
								If 1 ==_GUICtrlListView_GetItemImage( $cListView_WindowList, $rowInt, $iCol) Then
									;if there is an empty space above, 
									;IF IsNumber($BlankRowList[0]) Then
									;search for a 1 in BlankRowList that is earlier than current $rowInt
									$Test = _ArraySearch($BlankRowList, 1)
									;If $BlankRowList[0] <> $rowInt  Then
									If $Test < $rowInt And $Test <> -1 Then
										;then swap positions (;also swap positions in the listview array)

										;start index
										$startmem = $LVItemArray[$Test][0]
										;end index
										$endmem = $LVItemArray[$rowInt][0]
										;update the array 
										_ArraySwap($LVItemArray, $Test, $rowInt, False)
										;switch back the control IDs
										$LVItemArray[$rowInt][0] = $endmem
										$LVItemArray[$Test][0] = $startmem
										
										;then reset the 1 to a 0
										$BlankRowList[$Test] = 0
										;also when u switch the new spot is a blank now as well
										$BlankRowList[$rowInt] = 1
										;else
											;pass
									EndIf
									Else
										;set that value in BlankRowList to 1
										$BlankRowList[$rowInt] = 1
								EndIf
							Next
							#comments-end

							;ConsoleWrite("Column clicked: " & $iCol & @CRLF)
					EndSwitch
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
					;_ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) & "|" &
					; $aHit[0] & "|" & $aHit[1] & "|" &
					;MsgBox($MB_OK, "is this an index or what??",  $aHit[0] >= 0 And $aHit[1] >= 3)
					;_ArrayDisplay($aIndexList)
					;MsgBox($MB_OK, "is this an index or what??", _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1)
					;MsgBox($MB_OK, "is this an index or what??", DllStructGetData($tInfo, "Index"))
					;PROBLEM: _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 SAYS TRUE
					;If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                    ;    If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                    ;        _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
                    ;    Return 1
					;MsgBox($MB_OK,"look for title pos",$aHit[0] & "|" & $aHit[1])
					If $aHit[0] >= 0 And $aHit[1] >= 3 Then                                                		   	    ; Item and subitem
						;MsgBox ( $MB_OK, "title", $aHit[0] & "|" & $aHit[1])
						Local $iIcon = _GUICtrlListView_GetItemImage( $cListView_WindowList, $aHit[0], $aHit[1] )      		; Get checkbox icon
						_GUICtrlListView_SetItemImage( $cListView_WindowList, $aHit[0], $iIcon = 0 ? 1 : 0, $aHit[1] ) 		; Toggle checkbox icon
						;update the LVItemArray array
						$LVItemArray[$aHit[0]][$aHit[1]+1] = Mod($iIcon + 1, 2)
						
						;clear all other checkboxes so we force user to pick only one monitor (aka a window cannot exist in more than 1 monitor right?)
						
						;know we have 3 initial columns + # of monitors so just iterate over # of monitors +3 to clear checkmarks AND skip $aHit[1].
						For $i = 0 To UBound($MonitorArray) - 1
							;if we're not the selected column set the subitem to empty checkbox
							If $i + 3 <> $aHit[1] Then
								_GUICtrlListView_SetItemImage($cListView_WindowList, $aHit[0], 0, $i + 3 )
								$LVItemArray[$aHit[0]][$i+4] = 0
							EndIf
						Next
						;_GUICtrlListView_RedrawItems( $cListView_WindowList, $aHit[0], $aHit[0] )                      ; Redraw listview item
						_WinAPI_RedrawWindow($cListView_WindowList)
                    EndIf

                Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
						Return 1
                    EndIf
                    
                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
						Return 1
                    EndIf

                Case $NM_RDBLCLK ; Sent by a list-view control when the user double-clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, DllStructGetData($tInfo, "Index")) Then _
                            _GUICtrlListView_SetItemSelected($hListView, DllStructGetData($tInfo, "Index"), True, True)
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
    #forceref $iMsgID, $wParam
	Local $aPos = ControlGetPos($hWndGUI, "", $hListView)
    Local $x = BitAND($lParam, 0xFFFF) - $aPos[0]
    Local $y = BitShift($lParam, 16) - $aPos[1]
	;_WinAPI_ReleaseCapture()
	;cListView_WindowList <=> Success: the handle to the ListView control. 
	Local $tStruct_LVHITTESTINFO = DllStructCreate($tagLVHITTESTINFO)
	DllStructSetData($tStruct_LVHITTESTINFO, "X", $x)
    DllStructSetData($tStruct_LVHITTESTINFO, "Y", $y)
	$g_aIndex = _SendMessage($hListView, $LVM_HITTEST, 0, DllStructGetPtr($tStruct_LVHITTESTINFO), 0, "wparam", "ptr")
	
	If $g_aIndex <> -1 Then
		;swap indicies in row[start][0] and row[end][0] (IM ASSUMING THAT IDs ARE STATIC BY PLACE, THIS MIGHT BE UNNECESSARY/WRONG)
		
		;start index
		$startmem = $LVItemArray[$g_aIndex][0]
		;end index
		$endmem = $LVItemArray[$initIndex][0]
		;update the array 
		_ArraySwap($LVItemArray, $g_aIndex, $initIndex, False)
		;MsgBox ( $MB_OK, "title", $aHit[0] & "|" & $aHit[1])
		
		;switch back the control IDs
		$LVItemArray[$initIndex][0] = $endmem
		$LVItemArray[$g_aIndex][0] = $startmem
		
		;redraw the listview
		For $i = 0 To UBound($LVItemArray,1) - 1
			$blankstr = $LVItemArray[$i][1]
			For $x = 2 To UBound($LVItemArray,2) - 3
				$blankstr &= "|" & $LVItemArray[$i][$x]
			Next
			GUICtrlSetData($LVItemArray[$i][0], $blankstr)
			;update checkboxes
			For $imonitor = 0 To $Monitors[0][0]-1
				_GUICtrlListView_SetItemImage( $cListView_WindowList, $i, $LVItemArray[$i][4 + $imonitor], 3 + $imonitor)
			Next
		Next
	EndIf
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
Func ListViewUpdateWindowsREDOIFBUGGED($LVctrl)

	;idea: get a new list of windows from scratch = newwindowarray
	;make sure to update lvItemArray properly 
		;if x in newwindow and not in lvitem, add to the end
		;if x in lvitem but not in newwindow, delete entry
	;then update the listview
	

EndFunc

Func ListViewUpdateWindows($LVctrl)
	;$LVctrl is the control of the List View
	;make copy of array
	$LVItemArrayCopy = $LVItemArray
	;delete everything
	;For $x = 0 To UBound($LVItemArray,1) - 1
	;	GUICtrlDelete($LVItemArray[$x][0])
	;Next
	;$LVItemArray = 0
	
	;redo gathering windows
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
			_ArrayAdd($aTitles, StringRegExpReplace($aList[$i][0],"\|","_"))
		EndIf
	Next
	;make empty array
	$aArrayFinal = 0
	Local $aArrayFinal[UBound($aListFiltered, 1)][5]
	
	;populate array
	For $i = 0 to UBound($aListFiltered, 1)-1
		;name
		;wingettitle fails on microsoft edge for some reason
		;$aArrayFinal[$i][0] = WinGetTitle($aListFiltered[$i])
		;$aArrayFinal[$i][0] = _ProcessGetName(WinGetProcess($aListFiltered[$i]))
		;there is a problem when something like firefox has "|" in the title... i have to filter that char out
		
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
	;dim $LVItemArray[1][4]
	;make array bigger depending on # of monitors
	;For $imonitor = 0 To $Monitors[0][0]-1
		;_ArrayDisplay($LVItemArray)
	;	Redim $LVItemArray[1][UBound($LVItemArray,2)+1]
	;Next
	_ArrayDisplay($aArrayFinal)
	_ArrayDisplay($LVItemArray)
	
	;if x in lvitem but not in aArrayFinal, delete entry
	$delOffset = 0
	For $rowInt = 0 To UBound($LVItemArray,1)-1
		$searchtest = _ArraySearch($aArrayFinal, $LVItemArray[$rowInt-$delOffset][3], 0, 0, 0, 0, 1, 1, False)
		MsgBox($MB_OK, "searchtest", $LVItemArray[$rowInt-$delOffset][2] &"|"& $searchtest)
		;MsgBox($MB_OK, "test arraysearch", $LVItemArray[$rowInt-$delOffset][3] &"|"& $aArrayFinal[$searchtest][1] &"|"& $searchtest)
		;MsgBox($MB_OK, "test arraysearchb", )
		If $searchtest == -1 Then
			GUICtrlDelete($LVItemArray[$rowInt-$delOffset][0])
			_ArrayDelete($LVItemArray, $rowInt-$delOffset)
			$delOffset += 1
		EndIf
	Next
	
	$delOffset = 0
	For $rowInt = 0 To UBound($LVItemArray,1)-1
		;GUICtrlRead ( controlID [, advanced = 0] )
		;MsgBox($MB_OK, "test arraysearch",_ArraySearch($aArrayFinal, $LVItemArray[$rowInt][3], 0, 0, 0, 0, 1, 1, False))
		;read the array instead and remember to delete the right listviewitem
		If _ArraySearch($aArrayFinal, $LVItemArray[$rowInt-$delOffset][3], 0, 0, 0, 0, 1, 1, False) == -1 Then
			;i think i should make sure i dont delete too many so check if the item is actually in the array as well
			;delete the right listview control
			;MsgBox($MB_OK, "test",$LVItemArray[$rowInt][0] & "|" & $LVItemArray[$rowInt][1])
			GUICtrlDelete($LVItemArray[$rowInt-$delOffset][0]-$delOffset)
			;delete the array row and resize appropriately (_arraydelete does this apparently)
			;_ArrayDelete($LVItemArray, $rowInt)
			_ArrayDelete($LVItemArray, $rowInt-$delOffset)
			$delOffset += 1
		EndIf
	Next
	
	
	
	

	;#comments-start
	For $rowInt = 0 To UBound($aArrayFinal, 1)-1
		;MsgBox($MB_OK, "searching for|what does arraysearch say",$aArrayFinal[$rowInt][2] & "|" & $aArrayFinal[$rowInt][1] & "|" & _ArraySearch($LVItemArray, $aArrayFinal[$rowInt][1], 0, 0, 0, 0, 1, 3, False))
		;search for hwnd
		If _ArraySearch($LVItemArray, $aArrayFinal[$rowInt][1], 0, 0, 0, 0, 1, 3, False) == -1 Then
			;init with name
			Local $blankStr = $aArrayFinal[$rowInt][0]
			$blankStr &=  "|" & $aArrayFinal[$rowInt][2] & "|" & $aArrayFinal[$rowInt][1]
			;add title
			$LVItem = GUICtrlCreateListViewItem ( $blankStr, $LVctrl)
			
			_ArrayAdd($LVItemArray, $LVItem & "|" & $blankStr )
			
			$IndexCounter = UBound($LVItemArray,1) - 1
			;HEADS UP
			;IN THIS CASE $LVItem = GUICtrlCreateListViewItem IS NOT OUR CONTROLID. The control ID is still a sequence. Since $rowInt is counting from the UBound our LVItem is numbered according to the windows not the control ID's if that makes any sense
			;HEADS UP CONTROL != YOUR ID
			_GUICtrlListView_SetItemState($hListView, $IndexCounter, 0, $LVIS_STATEIMAGEMASK)
			;add the checkboxes per monitor
			For $imonitor = 0 To $Monitors[0][0]-1
				;search for the array in LVItemArrayCopy
				$ExistenceCheck = _ArraySearch($LVItemArrayCopy, $aArrayFinal[$rowInt][1])
				If $ExistenceCheck <> -1 Then
					_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor], 3 + $imonitor)
					$LVItemArray[UBound($LVItemArray,1)-1][4 + $imonitor] = $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor]
				;if you can't find it just set as blank
				Else
					_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, 0, 3 + $imonitor)
					$LVItemArray[UBound($LVItemArray,1)-1][4 + $imonitor] = 0
				EndIf
			Next
			;_WinAPI_RedrawWindow($LVctrl)
			_ArrayAdd ( $aIndexList, $IndexCounter)
		EndIf
	Next
	;#comments-end
	_ArrayDisplay($aArrayFinal)
	_ArrayDisplay($LVItemArray)
	
	;redraw the listview
	For $i = 0 To UBound($LVItemArray,1) - 1
		$blankstr = $LVItemArray[$i][1]
		For $x = 2 To UBound($LVItemArray,2) - 3
			$blankstr &= "|" & $LVItemArray[$i][$x]
		Next
		GUICtrlSetData($LVItemArray[$i][0], $blankstr)
		;update checkboxes
		For $imonitorx = 0 To $Monitors[0][0]-1
			_GUICtrlListView_SetItemImage( $cListView_WindowList, $i, $LVItemArray[$i][4 + $imonitorx], 3 + $imonitorx)
		Next
	Next
	
	;_ArrayDisplay($LVItemArray)
	;THIS IS FOR INDEXLIST TO CLEAR 1ST CHECKBOX
	_ArrayDelete ( $aIndexList, 0 )
	;;MsgBox($MB_OK, "is this an index or what??", $initIndex)
	;;_WinAPI_RedrawWindow($hGUI)
EndFunc

Func ListViewUpdateWindows_DEPRECATED($LVctrl)
	;$LVctrl is the control of the List View
	;make copy of array
	$LVItemArrayCopy = $LVItemArray
	;delete everything
	For $x = 0 To UBound($LVItemArray,1) - 1
		GUICtrlDelete($LVItemArray[$x][0])
	Next
	$LVItemArray = 0
	
	;redo gathering windows
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
	
	;populate array
	For $i = 0 to UBound($aListFiltered, 1)-1
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
		
		_ArrayAdd($LVItemArray, $LVItem & "|" & $blankStr )
		;HEADS UP
		;IN THIS CASE $LVItem = GUICtrlCreateListViewItem IS NOT OUR CONTROLID. The control ID is still a sequence. Since $rowInt is counting from the UBound our LVItem is numbered according to the windows not the control ID's if that makes any sense
		;HEADS UP CONTROL != YOUR ID
		_GUICtrlListView_SetItemState($hListView, $IndexCounter, 0, $LVIS_STATEIMAGEMASK)
		
		;add the checkboxes per monitor
		For $imonitor = 0 To $Monitors[0][0]-1
			;search for the array in LVItemArrayCopy
			$ExistenceCheck = _ArraySearch($LVItemArrayCopy, $aArrayFinal[$rowInt][1])
			If $ExistenceCheck <> -1 Then
				_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor], 3 + $imonitor)
				$LVItemArray[UBound($LVItemArray,1)-1][4 + $imonitor] = $LVItemArrayCopy[$ExistenceCheck][4 + $imonitor]
			;if you can't find it just set as blank
			Else
				_GUICtrlListView_SetItemImage( $LVctrl, $IndexCounter, 0, 3 + $imonitor)
				$LVItemArray[UBound($LVItemArray,1)-1][4 + $imonitor] = 0
			EndIf
		Next
		;_WinAPI_RedrawWindow($LVctrl)
		_ArrayAdd ( $aIndexList, $IndexCounter)
		$IndexCounter += 1
	Next
	;THIS IS FOR INDEXLIST TO CLEAR 1ST CHECKBOX
	_ArrayDelete ( $aIndexList, 0 )
	_ArrayDelete ( $LVItemArray, 0 )
	;;MsgBox($MB_OK, "is this an index or what??", $initIndex)
EndFunc