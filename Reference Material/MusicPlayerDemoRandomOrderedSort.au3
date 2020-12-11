#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Sound.au3>
#include <Timers.au3>

#comments-start

-> timer plans: use autoplay or at least init/register the timerID globally
-=-=-=-
plan:


-> refresh music list to add newer songs (have to because resetting songlist will kill my song +- values)
-> blacklist filter remove song from list and ???
-> prev and next buttons
	prev and next can mess around with this ordering
-> search would be nice....
-=-=-=-=-=-=-=-=--
-> COMPATIBILITY WITH XSPF
-> search through playlists for song (have like a dropdown menu for playlist?)
-> add song to playlist....



find all playlists with this song (so xspf compatible)
>for the music player there should be a sort option where u go through ALL songs then sort out the song into a playlist

>remember relative audio levels for songs...
>can play music using xspf files

		



-> autoplay
-> plan out random walk (default is this autoplay)
	random walk with weights:
	plan:
		set timer for the song length +1 second
		if song is NOT playing: pick new song and add to history (use _SoundStatus function instead of soundplay)
		50% new songs
		50% old songs
		idea is u have 50% chance to take the max level of likeness (ex: 10) <--- hook onto +1 func?
			then from all the songs that are rated 10 in this example, u pick a random song
				if you play a new song too much, you skip (and skipping is a -1)
			if no songs, then go to 9
		
get music from folder
	(skip) have ability to search through multiple folders

Look up _Timer_SetTimer.
Note that the function called by the timer must have 4 parameters or it won't work. The help doesn't tell you this. You don't have to use the parameters. 

#comments-end

$hGUI = GUICreate("MPDROS",600,500,-1,-1,$WS_SIZEBOX)

$Label1 = GUICtrlCreateButton("Play", 0, 2, 81, 41)
$Label2 = GUICtrlCreateButton("Prev", 0, 43, 81, 41)
$Label3 = GUICtrlCreateButton("Next", 81, 43, 81, 41)
$Label4 = GUICtrlCreateButton("Stop", 81, 2, 81, 41)
$Label5 = GUICtrlCreateButton("VolUp,5", 0, 84, 81, 41)
$Label6 = GUICtrlCreateButton("volDown,5", 81, 84, 81, 41)
$Label7 = GUICtrlCreateButton("FolderSource", 0, 125, 81, 41)
$Label8 = GUICtrlCreateButton("Refresh List", 81, 125, 81, 41)
$Label9 = GUICtrlCreateLabel("", 0, 207, 400, 30)
;$Label10 = GUICtrlCreateLabel("??????????????????????????????????????????????????????????????????", 162, 0, 400, 30)
;max char length: ??????????????????????????????????????????????????????????????????
$Label11 = GUICtrlCreateButton("like (+1)", 0, 166, 81, 41)
$Label12 = GUICtrlCreateButton("dislike (-1)", 81, 166, 81, 41)

Global $MusicListView = GUICtrlCreateListView ("Title|Like Value|Row #", 183, 2, 400,200 )
_GUICtrlListView_SetExtendedListViewStyle($MusicListView, BitOR($LVS_EX_SUBITEMIMAGES, $LVS_EX_FULLROWSELECT));$LVS_EX_GRIDLINES

;init sorted Arrays
Global $NegArray[1][2] 
	$NegArray[0][0] = "nil"
Global $ZeroArray[1][2] 
	$ZeroArray[0][0] = "nil"
Global $PosArray[1][2]
	$PosArray[0][0] = "nil"
;_ArrayDisplay($ZeroArray)
;history array:
Global $HistoryArray[1]
	$HistoryArray[0] = "nil"

If FileExists("MusicList.txt") Then
	$MusicFILE = FileOpen ("MusicList.txt")
	
	;make music array:
	$MusicCount = _FileCountLines("MusicList.txt")
	Global $MusicArray[$MusicCount][3]
	
	;$MusicCount
	For $x = 0 to 15 -1
		;read line
		$NextLine = FileReadLine ($MusicFILE)
		$SongName = StringSplit($NextLine, "|")[1]
		$SongLikes = StringSplit($NextLine, "|")[2]

		;add to array
		$MusicArray[$x][0] = $SongName
		;add to listview:
		GUICtrlCreateListViewItem ($SongName & "|" & $SongLikes & "|" & $x+1, $MusicListView)
		;set data
		GUICtrlSetData ( $Label9, ($x/$MusicCount)*100  & '%' & " done" & ", " & "Working on " & $SongName)
	Next
Else
	$MusicFILE = FileOpen ("MusicList.txt", 2 + 256)
	FileClose ($MusicFILE)
EndIf

WeightedChoiceInit ()
GUISetState()
;set false ID
Global $CurrentMusicCtrlID = -1
$CurrentSongOpen = 0
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Label1
			;if something is selected from listview, play:
			;else say nothing selected
			If 3+2 = 5 Then
				$CurrentSong = StringSplit(GUICtrlRead(GUICtrlRead ( $MusicListView)), "|")[1]
				;SoundPlay ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' & $CurrentSong)
				
				If $CurrentSongOpen <> 0 Then
					_SoundStop ( $CurrentSongOpen )
				EndIf
				
				$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				_SoundPlay ( $CurrentSongOpen )
				;set timer to play next song:

				_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , "AutoPlay" )

				GUICtrlSetData ( $Label9, "Playing " & $CurrentSong)
				;set the ctrl ID because I need to know for +1 -1
				Global $CurrentMusicCtrlID = GUICtrlRead($MusicListView)
				
				;append to history array:
				If $HistoryArray[0] == "nil" Then
					;replace 1st val
					$HistoryArray[0] = $CurrentSong 
				Else
					_ArrayAdd($HistoryArray, $CurrentSong)
				EndIf
			Else
				GUICtrlSetData ( $Label9, "No song selected!")
			EndIf
		Case $Label4
			;SoundPlay("nosound", 0)
			If $CurrentSongOpen <> 0 Then
				_SoundStop ( $CurrentSongOpen )
			EndIf
			$CurrentSongOpen = 0
		Case $Label5
			$number = StringSplit( GUICtrlRead ($Label5), ",") [2] + 5
			SoundSetWaveVolume ( $number )
			GUICtrlSetData ( $Label5, "VolUp," & $number )
			GUICtrlSetData ( $Label6, "VolDown," & $number )
		Case $Label6
			$number = StringSplit( GUICtrlRead ($Label6), ",") [2] - 5
			SoundSetWaveVolume ( $number )
			GUICtrlSetData ( $Label5, "VolUp," & $number )
			GUICtrlSetData ( $Label6, "VolDown," & $number )
		Case $Label8
			;MsgBox(0,"??",_GUICtrlListView_GetSelectedIndices ( $MusicListView ))
			;WeightedChoice()
			;_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , "AutoPlay" )
			$MusicFILE = FileOpen ("MusicList.txt", 256)
			$MusicFILEREAD = FileRead ($MusicFILE)
			MsgBox(0,"???", FileSearch ($MusicFILEREAD, " Gatchaman Insight  - I n s i g h t _ Full Opening.mp3"))
			MsgBox(0,"???", FileSearch ($MusicFILEREAD, "#7 A Secret of the Moon (Planetes Original Sound Track Album 1).mp3"))
			;.mp3 is a problem
			MsgBox(0,"???", FileSearch ($MusicFILEREAD, "(Planetes Original Sound Track Album 1)"))
			MsgBox(0,"???", FileSearch ($MusicFILEREAD, "#7 A Secret of the Moon (Planetes Original Sound Track Album 1).mp3|0"))
			MsgBox(0,"???", FileSearch ($MusicFILEREAD, "03 決闘のテーマ.mp3"))
			FileClose ($MusicFILE)
			;MsgBox(0,"???", $MusicFILEREAD)
			;_ArrayDisplay($NegArray)
			;_ArrayDisplay($ZeroArray)
			;_ArrayDisplay($PosArray)
			;GUICtrlSetData ( $Label9, _SoundStatus ( $CurrentSongOpen ) == 0)
			;GUICtrlSetData ( $Label9, IsString(_SoundStatus ( $CurrentSongOpen )))
			;GUICtrlSetData ( $Label9, _SoundStatus ( $CurrentSongOpen ))
			;another check is try to append to the string
		Case $Label11
			$SelectedSongID = GUICtrlRead($MusicListView)
			$SelectedSong = GUICtrlRead(GUICtrlRead($MusicListView))
			;MsgBox(0,"?", $SelectedSong)
			If GUICtrlRead($MusicListView) > 0 Then
			
				$SongName = StringSplit($SelectedSong, "|")[1]
				$currLike = StringSplit($SelectedSong, "|")[2]
				$RowNum = StringSplit($SelectedSong, "|")[3]

				If $currLike <> "" Then
					;set data on ListView
					GUICtrlSetData ( $SelectedSongID, "|" & Int($currLike) + 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & Int($currLike) + 1 & "|" & $RowNum, True)
				Else
					GUICtrlSetData ( $SelectedSongID, "|" & 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & 1 & "|" & $RowNum, True)
				EndIf
				;here if we reach certain thresholds we move the file from Neg,Zero, and Pos array to the right array:
				;set old array
				;can't reference arrays with other varnames so have to manually type shit out
				Switch $currLike
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike + 1 = 0
						_ArrayAdd($ZeroArray, $SongName & "|" & $currLike)
						$OldIndex = _ArraySearch ($NegArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($NegArray, $OldIndex )
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike + 1 > 0 and $currLike == 0
						_ArrayAdd($PosArray, $SongName & "|" & $currLike)
						$OldIndex = _ArraySearch ($ZeroArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($ZeroArray, $OldIndex )
				EndSwitch
			EndIf
		Case $Label12
			$SelectedSongID = GUICtrlRead($MusicListView)
			$SelectedSong = GUICtrlRead(GUICtrlRead($MusicListView))
			;MsgBox(0,"??", StringSplit($SelectedSong, "|"))
			;StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")
			If GUICtrlRead($MusicListView) > 0 Then
				$SongName = StringSplit($SelectedSong, "|")[1]
				$currLike = StringSplit($SelectedSong, "|")[2]
				$RowNum = StringSplit($SelectedSong, "|")[3]
				If $currLike <> "" Then
					;set data on ListView
					GUICtrlSetData ( $SelectedSongID, "|" & Int($currLike) - 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & Int($currLike) - 1 & "|" & $RowNum, True)
				Else
					GUICtrlSetData ( $SelectedSongID, "|" & -1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & - 1 & "|" & $RowNum, True)
				EndIf
				
				Switch $currLike
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike - 1 = 0
						_ArrayAdd($ZeroArray, $SongName & "|" & $currLike)
						$OldIndex = _ArraySearch ($PosArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($PosArray, $OldIndex )
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike - 1 < 0 and $currLike == 0
						_ArrayAdd($NegArray, $SongName & "|" & $currLike)
						$OldIndex = _ArraySearch ($ZeroArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($ZeroArray, $OldIndex )
				EndSwitch
			EndIf
		Case $Label7
			MusicListInit(FileSelectFolder("Select Music Folder", ""))
	EndSwitch
WEnd

Func MusicListInit ($FileSourceGIVEN)
	$FileSource = $FileSourceGIVEN
	$FileList = _FileListToArray($FileSource, "*.mp3", 0)
	;IniWrite ( "filename", "section", "key", "value" )
	;IniRead ( "filename", "section", "key", "default" )
	do
	Sleep (500)
	Until IsInt ( $FileList[0] )
	$MusicFILE = FileOpen ("MusicList.txt", 1 + 256)
	$MusicFILEREAD = FileRead ($MusicFILE)
	$MusicFOLDERS = FileOpen ("MusicFolders.txt", 1 + 256)
	FileWrite($MusicFOLDERS, $FileSource & @CRLF )
	FileClose ($MusicFILE)
	
	For $x=1 to UBound( $FileList ,1) -1
		;i don't want to override old data....
		;if it DOES NOT exist: write
		;reread to update
		$MusicFILE = FileOpen ("MusicList.txt", 256)
		$MusicFILEREAD = FileRead ($MusicFILE)
		;MsgBox(0,"???", FileSearch ($MusicFILEREAD, " Gatchaman Insight  - I n s i g h t _ Full Opening.mp3"))
		;MsgBox(0,"??", $FileList[$x] & "|" & FileSearch ($MusicFILEREAD, $FileList[$x]))
		If FileSearch ($MusicFILEREAD, $FileList[$x]) == False Then
			FileClose ($MusicFILE)
			GUICtrlSetData ( $Label9, ($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $FileList[$x])
			;MsgBox(0,"write this", $FileList[$x] & "|" & "0" & @CRLF )
			;MsgBox(0,"write this", UBound( $FileList ,1) -1)
			$MusicFILE = FileOpen ("MusicList.txt", 1 + 256)
			FileWrite ( $MusicFILE, $FileList[$x] & "|" & "0" & @CRLF )
			MsgBox(0,"what is pos", FileGetPos($MusicFILE))
			FileClose ($MusicFILE)
			;GUICtrlCreateListViewItem ($FileList[$x] & "|" & "0" & "|" & $x, $MusicListView )
		Else
			GUICtrlSetData ( $Label9, ($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $FileList[$x])
		EndIf
		
	Next
	FileClose ($MusicFOLDERS)
EndFunc

Func WeightedChoiceInit ()
	;here we set up the arrays for songs:
	For $x = 0 To _GUICtrlListView_GetItemCount($MusicListView) -1 
		$SongName = _GUICtrlListView_GetItemText($MusicListView, $x, 0)
		$LikeVal = Int(_GUICtrlListView_GetItemText($MusicListView, $x, 1))
		;MsgBox(0, "Error",$SongName)
		;MsgBox(0, "Error1",$LikeVal)
		;MsgBox(0, "Error2",$LikeVal < 0)
		;MsgBox(0, "Error3",$LikeVal = 0)
		;MsgBox(0, "Error4",$LikeVal > 0)
		
		$SwitchVar = "Z"
		If $LikeVal < 0 Then
			$SwitchVar = "A"
		EndIf
		If $LikeVal = 0 Then
			$SwitchVar = "B"
		EndIf
		If $LikeVal > 0 Then
			$SwitchVar = "C"
		EndIf
		
		Switch $SwitchVar
			;#array1: songs of negative value
			Case "A"
				;send to NegArray
				If $NegArray[0][0] == "nil" Then
					;replace 1st val
					$NegArray[0][0] = $SongName 
					$NegArray[0][1] = $LikeVal 
				Else
					_ArrayAdd($NegArray, $SongName & "|" & $LikeVal)
				EndIf
			;#array2: songs of 0 value
			Case "B"
				;MsgBox(0, "Error","=0 triggered!")
				;send to ZeroArray
				If $ZeroArray[0][0] == "nil" Then
					;replace 1st val
					$ZeroArray[0][0] = $SongName 
					;_ArrayDisplay($ZeroArray)
					$ZeroArray[0][1] = $LikeVal
				Else
					_ArrayAdd($ZeroArray, $SongName & "|" & $LikeVal)
				EndIf
			;#array3: songs of positive value
			Case "C"
				;send to PosArray
				If $PosArray[0][0] == "nil" Then
					;replace 1st val
					$PosArray[0][0] = $SongName 
					$PosArray[0][1] = $LikeVal
				Else
					_ArrayAdd($PosArray, $SongName & "|" & $LikeVal)
				EndIf
		EndSwitch
		;_ArrayDisplay($NegArray)
		;_ArrayDisplay($ZeroArray)
		;_ArrayDisplay($PosArray)
	Next
EndFunc

Func WeightedChoice ()
	#comments-start
	random walk with weights:
	;324, 313
	plan:
		50% new songs
		50% old songs
		idea is u have 50% chance to take the max level of likeness (ex: 10) <--- hook onto +1 func?
			then from all the songs that are rated 10 in this example, u pick a random song
				if you play a new song too much, you skip (and skipping is a -1)
			if no songs, then go to 9
	#comments-end
	;instead of going through 5000 lines repeatedly i should store listened songs in memory and ???
	$Choice1 = Random ( 0,1,1 )
	If $Choice1 == 0 Then
		;pick a negative song 25% of the time:
		$Choice2 = Random ( 0,3,1 )
		If $Choice2 == 0 Then
			;pick a negative val song
			$NegTest = Random(0,UBound($NegArray, 1)-1,1)
			;MsgBox(0, "NegArrayVals", $NegTest )
			;_ArrayDisplay($NegArray)
			Return $NegArray[$NegTest][0]
		Else
			;pick neutral song ( likeval of 0)
			;_ArrayDisplay($ZeroArray)
			$ZeroTest = Random(0,UBound($ZeroArray, 1)-1,1)
			;MsgBox(0, "ZeroArrayVals", $ZeroTest )
			Return $ZeroArray[$ZeroTest][0]
		EndIf 
	Else
		;old song
		$MaxLike = _ArrayMax ( $PosArray ,1 , -1 , -1 , 1 )
		For $x = $MaxLike To 0 Step -1
			;successively 1/2 chance to choose from $xth like song. this levels out so u listen to like 2 songs way more than like 1 songs and ur forced to -1 them
			$Choice3 = Random ( 0,1,1 )
			;if I hit a likeval with no song, go random in poslist
			If $Choice3 == 0 Then
				;this set can fail if there are like vals with no song...
			
				;choose a song of this like value
				;the way i create the array is wrong, just fucking filter manually.
				;$ValidLikeArray = StringRegExp ( _ArrayToString($PosArray, " | "), "^(.+?)\|" , 1)
				Global $ValidLikeArray[1]
				$ValidLikeArray[0] = "nil"
				For $i = 0 To UBound($PosArray, 1)-1
					If $ValidLikeArray[0] == "nil" and $PosArray[$i][1] == $x Then
						$ValidLikeArray[0] = $PosArray[$i][0]
					ElseIf $PosArray[$i][1] == $x Then
						_ArrayAdd($ValidLikeArray,$PosArray[$i][0])
					EndIf
				Next
				;;;MsgBox(0, "LikeValChosen", $x)
				;;;_ArrayDisplay($ValidLikeArray)
				$LikeTest = Random(0,UBound($ValidLikeArray, 1)-1,1)
				;MsgBox(0, "LikeArrayVals", $LikeTest & "|" & 0 & "|" & $Choice1 & "|" & "|" & $Choice3)
				;MsgBox(0, $Choice1 & "|" & "|" & $Choice3, StringRegExp ( _ArrayToString($PosArray, " | "), "^(.+?)\|" , 1))
				;MsgBox(0, $Choice1 & "|" & "|" & $Choice3, $ValidLikeArray[$LikeTest][0])
				;;;MsgBox(0, "LikeTest", $LikeTest)
				;_ArrayDisplay($ValidLikeArray)
				;;;_ArrayDisplay($PosArray)
				;;;_ArrayDisplay($ValidLikeArray)
				;;;MsgBox(0, "VALIDLIKEPICK", $ValidLikeArray[$LikeTest])
				If $ValidLikeArray[$LikeTest] == "nil" Then
					$TheAns = $PosArray[Random(0,UBound($PosArray,1)-1,1)][0]
					;;;MsgBox(0, "VALIDLIKEPICK", $TheAns)
					Return $TheAns
				Else
					Return $ValidLikeArray[$LikeTest]
				EndIf
				
				
			EndIf
		Next
	EndIf
EndFunc

;HEADS UP FUNCTION DIES IF IT ISNT GIVEN 4 ARGS! (when triggered by timer funcs)
Func AutoPlay ($hWnd, $iMsg, $iIDTimer, $iTime, $CurrentSongOpen)
	#forceref $hWnd, $iMsg, $iIDTimer, $iTime
	GUICtrlSetData ( $Label9, "Autoplay triggered!..." & _SoundStatus ( $CurrentSongOpen ) == 0)
	;make sure nothing is playing
	If  _SoundStatus ( $CurrentSongOpen ) == 0 or _SoundStatus ( $CurrentSongOpen ) == "stopped" Then
		;randomly pick the next song
		$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' & WeightedChoice() )
		GUICtrlSetData ( $Label9, "Autoplay triggered2!..." & StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' & WeightedChoice())
		_SoundPlay ( $CurrentSongOpen )
		;set the timer again to songlength + 500 miliseconds
		;_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , AutoPlay )
	EndIf
EndFunc

Func FileSearch ($FileReadObj, $string)
	If @error = -1 Then
		MsgBox(0, "Error", "File not read")
		Exit
	Else
		;MsgBox(0, "Read", $read)
		;can't use regexp since songs use special chars in regex
		;StringRegExp($FileReadObj, $string)
		If StringInStr ( $FileReadObj, $string) Then
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc