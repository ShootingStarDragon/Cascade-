#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

If FileExists("Lista.ini") Then                            ;if the list exists is displayed
    $lista = IniRead("Lista.ini", "Lista" , "Caminho","")
    $var = $lista
Else                                                       ;if not, it created a false mp3 directory script
    FileOpen("No-Music.mp3",1)
    Sleep(300)
    $var = @ScriptDir
EndIf

Local $FileList = _FileListToArray($var, "*.mp3*", 1)
Global $tocando = False, $music = 1, $voll = "Volume", $vol = 30, $max = $FileList[0], $title = $FileList[1]

#region ### START Koda GUI section ###
    $Form1_1 = GUICreate("Autoit Sound Play", 500, 313, 192, 124)
    GUISetBkColor(0x393952)
    $List1 = GUICtrlCreateListView("", 200, 8, 261, 220)
    GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
    GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
    GUISetState()
    _GUICtrlListView_InsertColumn($List1, 0,"                 " & $FileList[0] & " - músicas ", 257)

For $i = 1 To $max Step 1
    _GUICtrlListView_AddItem($List1, $FileList[$i], $i)            ;generating items according to the number of songs
Next

    $Prev = GUICtrlCreateButton("Prev", 104, 2, 81, 41)
    GUICtrlSetBkColor(-1, 0xff6633)
    GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
    $Next = GUICtrlCreateButton("Next", 104, 51, 81, 49)
    GUICtrlSetBkColor(-1, 0xff6633)
    GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
    $Play = GUICtrlCreateButton("Play", 8, 2, 89, 97)
    GUICtrlSetBkColor(-1, 0xbdc6c6)
    GUICtrlSetFont(-1, 24, 400, 0, "MS Sans Serif")
    $Stop = GUICtrlCreateButton("Stop", 8, 110, 177, 33)
    GUICtrlSetBkColor(-1, 0xbdc6c6)
    GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
    $List = GUICtrlCreateButton("List", 136, 147, 49, 73)
    GUICtrlSetBkColor(-1, 0x999999)
    GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
    $VolUP = GUICtrlCreateButton("VolUP", 72, 147, 57, 73)
    GUICtrlSetBkColor(-1, 0xbdc6c6)
    GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
    $AutoSound = GUICtrlCreateLabel("A" & @CR & "U" & @CR & "T" & @CR & "O" & _
    @CR & @CR & @CR & "S" & @CR & "O" & @CR & "U" & @CR & "N" & @CR & "D", 478, 10, 257, 217)
    $VolDown = GUICtrlCreateButton("VolDown", 8, 147, 57, 73)
    GUICtrlSetBkColor(-1, 0xbdc6c6)
    $Volume = GUICtrlCreateLabel("Volume " & $vol, 15, 230, 400, 45)
    GUICtrlSetFont(-1, 30, 500, 0, "MS Sans Serif")
    $List2 = GUICtrlCreateList($title & " *********************************", 0, 280, 500, 50,3)
    GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
    GUICtrlSetBkColor(-1,0xbdc6c6)
    GUISetState(@SW_SHOW)
#endregion ### END Koda GUI section ###

SoundPlay($var & "\" & $music, 0)

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $Play
            $title = $FileList[$music]
            SoundPlay($var & "\" & $FileList[$music], 0)
            GUICtrlSetData($List2, $title & " *********************************")
            ;
            $tocando = True
        Case $Prev
            If $tocando And $music > 1 Then
                $music -= 1
                $title = $FileList[$music]
                SoundPlay($var & "\" & $FileList[$music], 0)
                GUICtrlSetData($List2, $title & " *********************************")
            EndIf
            If $tocando And $music < 2 Then
                SoundPlay($var & "\" & $FileList[$music], 0)
            EndIf
        Case $Next
            If $tocando And $music < $max Then
                $music += 1
                $title = $FileList[$music]
                GUICtrlSetData($List2,"")
                GUICtrlSetData($List2, $title & " *********************************")
                SoundPlay($var & "\" & $FileList[$music], 0)
            EndIf
        Case $Stop
            SoundPlay("nosound", 0)
            $tocando = False
        Case $VolDown
            If $tocando And $vol >= 5 Then
                $vol -= 5
                GUICtrlSetData($Volume, $voll & " " & $vol)
            EndIf
        Case $VolUP
            If $tocando And $vol < 100 Then
                $vol += 5
                GUICtrlSetData($Volume, $voll & " " & $vol)
            EndIf
        Case $List

            $openwin = FileSelectFolder("Escolha um pasta.", "")
            $var = $openwin                                       ; var equal to the Open Directory
            Local $FileList = _FileListToArray($var, "*.mp3", 0)  ; mp3 transforms into arrays
            $max   = $FileList[0]                                   ;[0] number of mp3 is the limit max
            $open  = FileOpen("Lista.ini", 2)
            $lista = IniWrite("Lista.ini", "Lista", "Caminho", $var)
            GUICtrlDelete($List1)
            $List1 = GUICtrlCreateListView("", 200, 8, 261, 220)
            GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
            GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
            GUISetState()
            _GUICtrlListView_InsertColumn($List1, 0,"                 " & $FileList[0] & " - músicas ", 256)

For $i = 1 To $max Step 1
    _GUICtrlListView_AddItem($List1, $FileList[$i], $i)         ;regenerates items after new directory
Next

        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch

    SoundSetWaveVolume($vol)
    Sleep(10)
WEnd

Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)              ;recognizes the item double-clicked and executed

    Local $iCode, $tNMHDR, $hWndListView, $tInfo, $aItem, $hWndListView = $List1, _
          $tNMHDR = DllStructCreate($tagNMHDR, $ilParam), $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $iCode
        Case $NM_DBLCLK
            $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
            $aItem = _GUICtrlListView_GetItem($hWndListView, DllStructGetData($tInfo, "Index"))
            GUICtrlSetData($List2, "")
            GUICtrlSetData($List2, $aItem[3] & " *********************************")
            SoundPlay($var & "\" & $aItem[3], 0)
            $tocando = True                        ;music playing
    EndSwitch
EndFunc