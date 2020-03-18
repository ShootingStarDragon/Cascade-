#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>
#include <Process.au3>
#include "GUIListViewEx\GUIListViewEx.au3"
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>

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

Local $sHeaders = "Window Title|App Name(.exe)"


For $intmon = 1 To $Monitors[0][0]
	;MsgBox($MB_OK, "title1", $intmon)
	;_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	_ArrayAdd($MonitorArray,_WinAPI_GetMonitorInfo($Monitors[$intmon][0])[3])
	$sHeaders &= "|Monitor " & $intmon
	Next

	
	
;remove empty init element in MonitorArray
_ArryRemoveBlanks($MonitorArray)

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

_ArrayDisplay($MonitorCoords)

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
$Label11 = _GUICtrlButton_Create ( $hGUI, "Cascade Now!", 10, 430, 100, 20)

;It is important to use _GUIListViewEx_Close when a enabled ListView is deleted to free the memory used
;                    by the $aGLVEx_Data array which shadows the ListView contents.
;_GUIListViewEx_Close($iLV_Index)

;Func _GUIListViewEx_Init($hLV, $aArray = "", $iStart = 0, $iColour = 0, $fImage = False, $iAdded = 0)

Global $cListView_WindowList = GUICtrlCreateListView($sHeaders, 10, 220, 400, 200) ;$LVS_SHOWSELALWAYS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;getting checkboxes so i can hack onto GUIListViewEx
;$LVS_EX_FULLROWSELECT
_GUICtrlListView_SetExtendedListViewStyle($cListView_WindowList, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_SUBITEMIMAGES))

$hListView = GUICtrlGetHandle( $cListView_WindowList )    
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Local $IndexCounter = 0

For $rowInt = 0 To UBound($aArrayFinal, 1)-1
	;MsgBox ( $MB_OK, "start of MY ROW", "")
	;init with name
	Local $blankStr = $aArrayFinal[$rowInt][0]
	$blankStr &=  "|" & $aArrayFinal[$rowInt][2]
	;add title
	;MsgBox ( $MB_OK, "STRPls", $blankStr)	
	;$ItemID = GUICtrlCreateListViewItem ( $blankStr, $cListView_WindowList)
	$LVItem = GUICtrlCreateListViewItem ( $blankStr, $cListView_WindowList)
	;clear the checkbox
	;_GUICtrlListView_SetItemState($hListView, $LVItem, 0, $LVIS_STATEIMAGEMASK)
	
	;HEADS UP
	;IN THIS CASE $LVItem = GUICtrlCreateListViewItem IS NOT OUR CONTROLID. The control ID is still a sequence. Since $rowInt is counting from the UBound our LVItem is numbered according to the windows not the control ID's if that makes any sense
	;HEADS UP CONTROL != YOUR ID
	_GUICtrlListView_SetItemState($hListView, $IndexCounter, 0, $LVIS_STATEIMAGEMASK)
	
	;add the checkboxes per monitor
	For $imonitor = 0 To $Monitors[0][0]
		;_GUICtrlListView_AddSubItem( $cListView_WindowList, $IndexCounter, "checkbox", $imonitor + 2, 1 ) ; Image index 0 = unchecked checkbox
		_GUICtrlListView_SetItemImage( $cListView_WindowList, $IndexCounter, 0, 2) 
		_GUICtrlListView_SetItemImage( $cListView_WindowList, $IndexCounter, 0, 3) ; 3 is the zero based index of fourth column
	Next
	
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
_ArrayDelete ( $aIndexList, 0 )
;_ArrayDisplay ($aIndexList )

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
		MsgBox("search the array",)



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
					ElseIf $aHit[0] >= 0 And $aHit[1] >= 2 Then                                                		   	   ; Item and subitem
						Local $iIcon = _GUICtrlListView_GetItemImage( $cListView_WindowList, $aHit[0], $aHit[1] )      ; Get checkbox icon
						_GUICtrlListView_SetItemImage( $cListView_WindowList, $aHit[0], $iIcon = 0 ? 1 : 0, $aHit[1] ) ; Toggle checkbox icon
						;clear all other checkboxes so we force user to pick only one monitor (aka a window cannot exist in more than 1 monitor right?)
						;know we have 2 initial columns + # of monitors so just iterate over # of monitors +2 to clear checkmarks AND skip $aHit[1].
						For $i = 0 To UBound($MonitorArray) - 1
							;if we're not the selected column set the subitem to empty checkbox
							If $i + 2 <> $aHit[1] Then
								_GUICtrlListView_SetItemImage( $cListView_WindowList, $aHit[0], 0, $i + 2 )
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