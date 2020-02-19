#include <Process.au3>
#Include <WinAPI.au3>
$winlist=_getwinlist()
for $i= 1 to $winlist[0][1]
    WinSetState($winlist[$i][2],"",@SW_MINIMIZE)
Next

func _getwinlist ()
Local $sExclude_List = "|Start[CL:102939]|Start|Desktop|Start Menu[CL:102938]|taskbar|iconwin|desktop[CL:102937]|Program Manager|taskbar|Menu|Save As|Drag|maincontext|context|"
Local $sExclude_class = "|tooltips_class32|gdkWindowToplevel|gdkWindowTempShadow|TaskSwitcherWnd|gdkWindowTemp|bosa_sdm_Microsoft Office Word 11.0|MsoCommandBarPopup|MsoCommandBarShadow|NUIDialog|CallTip|ThumbnailClass|#32770|Desktop User Picture|OfficeTooltip|"
Local $Listit
Local $aWinList = WinList()
dim $Listit[$aWinList[0][0]][5]
;Count windows

For $i = 1 To $aWinList[0][0]
;Only display visible windows that have a title
    If $aWinList[$i][0] = "" Or Not BitAND(WinGetState($aWinList[$i][1]), 2) Then ContinueLoop
;Add to array all win titles that is not in the exclude list
        $class = _WinAPI_GetClassName($aWinList[$i][1])
    If Not StringInStr($sExclude_List, "|" & $aWinList[$i][0] & "|") and Not StringInStr($sExclude_class, "|" & $class & "|") Then
        $Listit[0][1]=$Listit[0][1]+1
        $Listit[$Listit[0][1]][0]= _ProcessGetName (WinGetProcess($aWinList[$i][1]))
        $Listit[$Listit[0][1]][1]= $aWinList[$i][0]
        $Listit[$Listit[0][1]][2]= $aWinList[$i][1]
        $Listit[$Listit[0][1]][3]= $class
    EndIf
Next
ReDim $Listit[$Listit[0][1]+1][5]
return $Listit
EndFunc