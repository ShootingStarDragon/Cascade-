#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Sound.au3>
#include <Timers.au3>

#comments-start
make sure to update $CurrentSong and $CurrentSongOpen consistently!
-> timer plans: use autoplay or at least init/register the timerID globally
-=-=-=-

;i keep rewriting to musicfolders.txt
plan:
-> prev and next buttons
	prev and next can mess around with this ordering
	;make sure nextchoice obeys the historylist
-> search would be nice....
-=-=-=-=-=-=-=-=--
-> COMPATIBILITY WITH XSPF
-> search through playlists for song (have like a dropdown menu for playlist?)
-> add song to playlist....



find all playlists with this song (so xspf compatible)
>for the music player there should be a sort option where u go through ALL songs then sort out the song into a playlist

>remember relative audio levels for songs...
>can play music using xspf files

		
-=-=-=-
-> blacklist filter being written to multiple times?
-> blacklist filter remove song from list and ???	
	;remove from listview
	;from the right neg/zero/pos array
	;from music.txt
;on init the -,0,+ arrays are nil and then -/+ buttons don't clear nil

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
$Label13 = GUICtrlCreateButton("blacklist", 0, 220, 81, 41)

Global $MusicListView = GUICtrlCreateListView ("Title|Like Value|Row #", 183, 2, 400,200 )
_GUICtrlListView_SetExtendedListViewStyle($MusicListView, BitOR($LVS_EX_SUBITEMIMAGES, $LVS_EX_FULLROWSELECT));$LVS_EX_GRIDLINES

;init sorted Arrays
Global $NegArray[1][2] 
	$NegArray[0][0] = "nil"
Global $ZeroArray[1][2] 
	$ZeroArray[0][0] = "nil"
Global $PosArray[1][2]
	$PosArray[0][0] = "nil"
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
$CurrentSong = 0
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Label1
			;if something is selected from listview, play:
			;else say nothing selected
			If GUICtrlRead ( $MusicListView) Then
				$CurrentSong = StringSplit(GUICtrlRead(GUICtrlRead ( $MusicListView)), "|")[1]
				;SoundPlay ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' & $CurrentSong)
				
				If $CurrentSongOpen <> 0 Then
					_SoundStop ( $CurrentSongOpen )
				EndIf
				
				$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;_ArrayDisplay($CurrentSongOpen)
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
		Case $Label2
			;find prev song index
			$prevsongIndex = _ArraySearch ($HistoryArray, $CurrentSong ,0,0,0,0,1,0,False)
			;stop current song
			If $prevsongIndex <> 0 Then
				;MsgBox(0,"",$HistoryArray[$prevsongIndex])
				;$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $HistoryArray[$prevsongIndex] )
				_SoundStop($CurrentSongOpen)
				;set current song as the prev song, and DONT add to history queue
				$CurrentSong = $HistoryArray[$prevsongIndex -1]
				$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;play prev song
				_SoundPlay($CurrentSongOpen)
				GUICtrlSetData ( $Label9, "Playing " & $CurrentSong)
			Else
				GUICtrlSetData ( $Label9, "No previous history detected.")
			EndIf
		Case $Label3
			;check if you're at end of history THEN pick one or history is nil
			$prevsongIndex = _ArraySearch ($HistoryArray, $CurrentSong ,0,0,0,0,0,0,False)
			;make sure ur at end of queue
			;MsgBox(0,"tests", $prevsongIndex &"|"& UBound($HistoryArray,1) - 1 &"|"& String($prevsongIndex == UBound($HistoryArray,1)) )
			If $prevsongIndex == UBound($HistoryArray,1) -1 or $HistoryArray[0] == "nil" Then
				_SoundStop($CurrentSongOpen)
				;choose new song:
				$CurrentSong = WeightedChoice ()
				;request new song
				$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;play song
				_SoundPlay ( $CurrentSongOpen )
				GUICtrlSetData ( $Label9, "Playing B" & $CurrentSong)
				;add to history array
				If $HistoryArray[0] == "nil" Then
					;replace 1st val
					$HistoryArray[0] = $CurrentSong
				Else
					_ArrayAdd($HistoryArray, $CurrentSong)
				EndIf
			Else
				_SoundStop($CurrentSongOpen)
				$CurrentSong = $HistoryArray[$prevsongIndex+1]
				;play the next song in history
				$CurrentSongOpen = _SoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;play song
				_SoundPlay ( $CurrentSongOpen )
				GUICtrlSetData ( $Label9, "Playing C" & $CurrentSong)
				;add to history array
				;If $HistoryArray[0] == "nil" Then
				;	;replace 1st val
				;	$HistoryArray[0] = $CurrentSong
				;Else
				;	_ArrayAdd($HistoryArray, $CurrentSong)
				;EndIf
			EndIf
		Case $Label4
			;SoundPlay("nosound", 0)
			If $CurrentSongOpen <> 0 Then
				_SoundStop ( $CurrentSongOpen )
			EndIf
			$CurrentSongOpen = 0
			$CurrentSong == 0
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
			_ArrayDisplay($HistoryArray)
			;MsgBox(0,"msgboxlabel8",WeightedChoice ())
			;WeightedChoice()
			;_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , "AutoPlay" )
			
			;MsgBox(0,"???", $MusicFILEREAD)
			;$MusicFILEBLACKLIST = FileOpen ("blacklistfileOPEN.txt", 256)
			;$MusicFILEBLACKLISTREAD = FileRead ($MusicFILEBLACKLIST)
			;;MsgBox(0,"",$MusicFILEBLACKLISTREAD)
			;MsgBox(0,"",FileSearch ($MusicFILEBLACKLISTREAD, "#7 A Secret of the Moon (Planetes Original Sound Track Album 1).mp3"))
			;;MsgBox(0,"",FileSearch ($MusicFILEBLACKLISTREAD, "Gatchaman Insight  - I n s i g h t _ Full Opening.mp3"))
			;FileClose($MusicFILEBLACKLIST)
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
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & Int($currLike) + 1, True)
				Else
					GUICtrlSetData ( $SelectedSongID, "|" & 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & 1 , True)
				EndIf
				;here if we reach certain thresholds we move the file from Neg,Zero, and Pos array to the right array:
				;set old array
				;can't reference arrays with other varnames so have to manually type shit out
				Switch $currLike
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike + 1 = 0
						If $ZeroArray[0][0] == "nil" Then
							$ZeroArray[0][0] = $SongName
							$ZeroArray[0][1] = $currLike+1
						Else
							_ArrayAdd($ZeroArray, $SongName & "|" & $currLike+1)
						EndIf
						$OldIndex = _ArraySearch ($NegArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($NegArray, $OldIndex )
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike + 1 > 0 and $currLike == 0
						If $PosArray[0][0] == "nil" Then
							$PosArray[0][0] = $SongName
							$PosArray[0][1] = $currLike+1
						Else
							_ArrayAdd($PosArray, $SongName & "|" & $currLike+1)
						EndIf
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
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & Int($currLike) - 1, True)
				Else
					GUICtrlSetData ( $SelectedSongID, "|" & -1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $SelectedSongID), "|")[1] & "|" & - 1, True)
				EndIf
				
				Switch $currLike
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike - 1 = 0
						If $ZeroArray[0][0] == "nil" Then
							$ZeroArray[0][0] = $SongName
							$ZeroArray[0][1] = $currLike-1
						Else
							_ArrayAdd($ZeroArray, $SongName & "|" & $currLike-1)
						EndIf
						$OldIndex = _ArraySearch ($PosArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($PosArray, $OldIndex )
					;can't reference arrays with other varnames so have to manually type shit out
					Case $currLike - 1 < 0 and $currLike == 0
						If $NegArray[0][0] == "nil" Then
							$NegArray[0][0] = $SongName
							$NegArray[0][1] = $currLike-1
						Else
							_ArrayAdd($NegArray, $SongName & "|" & $currLike-1)
						EndIf
						$OldIndex = _ArraySearch ($ZeroArray, $SongName ,0,0,0,0,1,0,False)
						_ArrayDelete ($ZeroArray, $OldIndex )
				EndSwitch
			EndIf
		Case $Label7
			MusicListInit(FileSelectFolder("Select Music Folder", ""))
		Case $label13
			;blacklist filter remove song from list and ???	
			$SelectedSongID = GUICtrlRead($MusicListView)
			$SelectedSong = GUICtrlRead(GUICtrlRead($MusicListView))
			If GUICtrlRead($MusicListView) > 0 Then
				;MsgBox(0,"", StringSplit(GUICtrlRead(GUICtrlRead($MusicListView),1), "|")[2])
				$SongName = StringSplit(GUICtrlRead(GUICtrlRead($MusicListView),1), "|")[1]
				$currLikeVAL = StringSplit(GUICtrlRead(GUICtrlRead($MusicListView),1), "|")[2]
				;remove from listview
				GUICtrlDelete($SelectedSongID)
				
				;construct the arrayline in music.txt (musicname | likeval) to search for
				$SearchItem = $SongName & "|" & $currLikeVAL
				
				;from the right neg/zero/pos array
				Switch $currLikeVAL
					Case $currLikeVAL < 0
						$OldIndex = _ArraySearch ($NegArray,$SongName,0,0,0,0,1,0,False)
						_ArrayDelete ($NegArray, $OldIndex )
					Case $currLikeVAL = 0
						$OldIndex = _ArraySearch ($ZeroArray,$SongName,0,0,0,0,1,0,False)
						_ArrayDelete ($ZeroArray, $OldIndex )
					Case $currLikeVAL > 0
						$OldIndex = _ArraySearch ($PosArray,$SongName,0,0,0,0,1,0,False)
						_ArrayDelete ($PosArray, $OldIndex )
				EndSwitch
				;delete from music.txt
				;fileopen		;in read mode
				$MusicFILE = FileOpen ("MusicList.txt", 256)
				;read to array
				$MusicArray = FileReadToArray ( $MusicFILE )
				
				;_ArrayDisplay($MusicArray)
				;find the line#
				;https://www.autoitscript.com/forum/topic/60817-file-delete-line/
				;search through array and delete line
				$SearchItemIndex = _ArraySearch($MusicArray, $SearchItem,0,0,0,0,1,0,False)
				MsgBox(0,"?", $SearchItemIndex & "|" & $SearchItem)
				_ArrayDelete($MusicArray, $SearchItemIndex )
				_ArrayDisplay($MusicArray)
				FileClose ($MusicFILE)
				;write to file
				$MusicFILE = FileOpen ("MusicList.txt", 2 + 256)
				For $y = 0 To UBound($MusicArray, 1)-1 
					FileWrite ( $MusicFILE, $MusicArray[$y] & @CRLF )
					GUICtrlSetData ( $Label9, ($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $SelectedSong)
				Next
				FileClose ($MusicFILE)
				;add to blacklist.txt
				$blacklistfileOPEN = FileOpen("blacklistfileOPEN.txt", 1 + 256)
				FileWrite ( $blacklistfileOPEN, $SongName & "|" & $currLikeVAL & @CRLF)
				FileClose ($blacklistfileOPEN)
			EndIf
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
		$MusicFILEBLACKLIST = FileOpen ("blacklistfileOPEN.txt", 256)
		$MusicFILEBLACKLISTREAD = FileRead ($MusicFILEBLACKLIST)
		;also don't add songs in the blacklist:
		If FileSearch ($MusicFILEREAD, $FileList[$x]) == False and FileSearch ($MusicFILEBLACKLISTREAD, $FileList[$x]) == False Then
			;MsgBox(0,"?",$FileList[$x] &"|"& FileSearch ($MusicFILEBLACKLISTREAD, $FileList[$x]))
			FileClose ($MusicFILE)
			GUICtrlSetData ( $Label9, ($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $FileList[$x])
			;MsgBox(0,"write this", $FileList[$x] & "|" & "0" & @CRLF )
			;MsgBox(0,"write this", UBound( $FileList ,1) -1)
			$MusicFILE = FileOpen ("MusicList.txt", 1 + 256)
			FileWrite ( $MusicFILE, $FileList[$x] & "|" & "0" & @CRLF )
			;MsgBox(0,"what is pos", FileGetPos($MusicFILE))
			FileClose ($MusicFILE)
			;reopen file again holy shit...
			$MusicFILE = FileOpen ("MusicList.txt", 256)
			$MusicArray = FileReadToArray($MusicFILE)
			;_ArrayDisplay($MusicArray)
			
			$searchANS = _ArraySearch ($MusicArray, $FileList[$x] & "|" & 0,0,0,0,0,1,0,False)
			;MsgBox(0,$FileList[$x], $searchANS &"|"& @error)
			GUICtrlCreateListViewItem($FileList[$x] & "|" & "0" & "|" & $searchANS, $MusicListView )
			FileClose ($MusicFILE)
		Else
			GUICtrlSetData($Label9,($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $FileList[$x])
		EndIf
		FileClose ($MusicFILEBLACKLIST)
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
			If $NegArray[$NegTest][0] == "nil" Then
				Return WeightedChoiceFail()
			Else
				;MsgBox(0,"bb",$NegArray[$NegTest][0])
				Return $NegArray[$NegTest][0]
			EndIf
			
		Else
			;pick neutral song ( likeval of 0)
			;_ArrayDisplay($ZeroArray)
			$ZeroTest = Random(0,UBound($ZeroArray, 1)-1,1)
			;MsgBox(0, "ZeroArrayVals", $ZeroTest )
			If $ZeroArray[$ZeroTest][0] == "nil" Then
				Return WeightedChoiceFail()
			Else
				;MsgBox(0,"bc",$ZeroArray[$ZeroTest][0])
				Return $ZeroArray[$ZeroTest][0]
			EndIf
			
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
					$randPick = Random(0,UBound($PosArray,1)-1,1)
					;MsgBox(0, "VALIDLIKEPICKb", $randPick)
					;_ArrayDisplay($PosArray)
					$TheAns = $PosArray[$randPick][0]
					;MsgBox(0, "VALIDLIKEPICK", $TheAns)
					If $TheAns == "nil" or $TheAns == "0" Then
						;MsgBox(0, "VALIDLIKEPICKz", "nothing")
						Return WeightedChoiceFail()
					Else
						;MsgBox(0, "VALIDLIKEPICKz", $TheAns)
						Return $TheAns
					EndIf
				Else
					;MsgBox(0, "VALIDLIKEPICKa", $ValidLikeArray[$LikeTest])
					Return $ValidLikeArray[$LikeTest]
				EndIf
			EndIf
		Next
		Return WeightedChoiceFail()
	EndIf
EndFunc

Func WeightedChoiceFail()
	;if u get a nil answer (aka no songs in that category)
	;just return random song in listview
	$SongName = _GUICtrlListView_GetItemText($MusicListView, Random (0, _GUICtrlListView_GetItemCount($MusicListView) -1 ,1), 0)
	;MsgBox(0,"??", "fail invoked")
	return $SongName
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

;HEADS UP FILESEARCH NEEDS the fileopened file to be FILEREAD!
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