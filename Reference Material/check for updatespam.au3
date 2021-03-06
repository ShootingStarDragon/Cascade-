#include <GUIConstantsEx.au3>
#include <WinAPIGdi.au3>
#include <Array.au3>
#include <Process.au3>
#include "GUIListViewEx\GUIListViewEx.au3"
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>

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
;NAME			HWND 			exe name 		position 	size
;array size is Ubound of the filtered list and 5 columns
;make empty array
Local $aArrayFinal[UBound($aListFiltered, 1)][5]
;MsgBox ( $MB_OK, "title", UBound($aListFiltered, 1) & "|" &  UBound($aArrayFinal, 0) & "|" & UBound($aArrayFinal, 1) & "|" & UBound($aArrayFinal, 2) )

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
$hGUI = GUICreate("Cascade+",500,500,-1,-1,$WS_SIZEBOX)
;To be able to resize a GUI window it needs to have been created with the $WS_SIZEBOX and $WS_SYSMENU styles. See GUICreate().

; And here we get the elements into a list
$sList = ""
For $i = 0 To UBound($MonitorArray) - 1
	$sList &= "|" & $MonitorArray[$i]
Next

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

;It is important to use _GUIListViewEx_Close when a enabled ListView is deleted to free the memory used
;                    by the $aGLVEx_Data array which shadows the ListView contents.
;_GUIListViewEx_Close($iLV_Index)

;Func _GUIListViewEx_Init($hLV, $aArray = "", $iStart = 0, $iColour = 0, $fImage = False, $iAdded = 0)

$cListView_WindowList = GUICtrlCreateListView($sHeaders, 10, 220, 400, 200) ;$LVS_SHOWSELALWAYS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;getting checkboxes so i can hack onto GUIListViewEx

_GUICtrlListView_SetExtendedListViewStyle($cListView_WindowList, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))

$hListView = GUICtrlGetHandle( $cListView_WindowList )    
; ImageList
Local $idListView2 = GUICtrlCreateListView( "", 0, 0, 1, 1 )                  ; 1x1 pixel listview to create state image list with checkbox icons
_GUICtrlListView_SetExtendedListViewStyle( $idListView2, $LVS_EX_CHECKBOXES ) ; The $LVS_EX_CHECKBOXES style forces the state image list to be created
Local $hStateImageList = _GUICtrlListView_GetImageList( $hListView, 2 ) ; 2 = Image list with state images
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
		_GUIListViewEx_Close($cListView_WindowListUDFVer)
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
	GUICtrlSetData($Label1b, _WinAPI_GetMonitorInfo(_WinOnMonitor(MouseGetPos()[0],MouseGetPos()[1]))[3])
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


; WM_NOTIFY message handler
;Func WM_NOTIFY( $hWnd, $iMsg, $wParam, $lParam )
;	#forceref $hWnd, $iMsg, $wParam
;	Local $tNMHDR = DllStructCreate( $tagNMHDR, $lParam )
;	Local $hWndFrom = HWnd( DllStructGetData( $tNMHDR, "hWndFrom" ) )
;	Local $iCode = DllStructGetData( $tNMHDR, "Code" )

;	Switch $hWndFrom
;		Case $hListView
;			Switch $iCode
;				Case $LVN_ITEMCHANGED
;					Local $tNMLISTVIEW = DllStructCreate( $tagNMLISTVIEW, $lParam )
;					Local $iItem = DllStructGetData( $tNMLISTVIEW, "Item" )
;					_GUICtrlListView_SetItemSelected( $hListView, $iItem, False )         ; Remove selected state
;					_GUICtrlListView_SetItemState( $hListView, $iItem, 0, $LVIS_FOCUSED ) ; Remove focused state
;
;				Case $NM_CLICK
;					Local $aHit = _GUICtrlListView_SubItemHitTest( $hListView )
;					If $aHit[6] Then                         ; On item?
;						If $aHit[3] Then                       ; On icon?
;							If $aHit[1] = 0 Or $aHit[1] = 3 Then ; On subitem 0 or 3?
;								Local $iImage = _GUICtrlListView_GetItemImage( $hListView, $aHit[0], $aHit[1] )  ; Image index 0 or 1
;								_GUICtrlListView_SetItemImage( $hListView, $aHit[0], $iImage ? 0 : 1, $aHit[1] ) ; Switch image index
;							EndIf                                      ; $iItem    $iImage          $iSubItem
;						EndIf
;					EndIf
;			EndSwitch
;	EndSwitch
;	Return $GUI_RUNDEFMSG
;EndFunc

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iCode, $tNMHDR, $hWndListView, $tInfo, $iIndex
    $hWndListView = $hListView

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, $iIndex) Then _
                            _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
                        Return 1
                    EndIf
                    
                Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, $iIndex) Then _
                            _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
                        Return 1
                    EndIf
                    
                Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
                        Return 1
                    EndIf

                Case $NM_RDBLCLK ; Sent by a list-view control when the user double-clicks an item with the right mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                    ;If DllStructGetData($tInfo, "Index") = $iIndex Then
					If _ArraySearch($aIndexList,DllStructGetData($tInfo, "Index")) <> -1 Then
                        If Not _GUICtrlListView_GetItemSelected($hListView, $iIndex) Then _
                            _GUICtrlListView_SetItemSelected($hListView, $iIndex, True, True)
                        Return 1
                    EndIf
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY