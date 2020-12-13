#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Sound.au3>
#include <Timers.au3>
#include <EditConstants.au3>

#comments-start
https://www.autoitscript.com/forum/topic/196973-detect-input-box-changes/
When I put  GUIRegisterMsg($WM_COMMAND,'WM_COMMAND'), on my input...my buttons stop working... 
Just use _GuiCtrlIPAddress_... functions example: 
-=-=-
make sure to update $CurrentSong and $CurrentSongOpen consistently!
-> timer plans: use autoplay or at least init/register the timerID globally
-=-=-=-=-=-=-=-=--
plan:
clickable progress bar
neg/zero/ and pos arrays are not init if u just press play (there are 2 init, so maybe they are not init in the folder init and are ok in the 2nd engage? another thing too is they are probably init in "next" button)

faster init
	i have a sorted file list...
	probably use an array read/write once at the end


sometimes autoplay doesn't trigger immediately
negative like value is too common


this line fails probably when you add to zeroarray then remove it again but it's empty. it was complaining about improper bounds
	If $ZeroArray[$ZeroTest][0] == "nil" Then





;i keep rewriting to musicfolders.txt (aka accumulate redundant info)
-> "01.crossing field.mp3" does not play
->soundopen sets @error to 1, so maybe i can still outplay somehow using filenames...
-=-=-=-=-=-=-=-=--
-> COMPATIBILITY WITH XSPF
-> search through playlists for song (have like a dropdown menu for playlist?)
-> add song to playlist....
>remember relative audio levels for songs...
>can play music using xspf files


-=-=-=-
DONE:
somehow i am duplicating -1 lines...
find all playlists with this song (so xspf compatible)
>for the music player there should be a sort option where u go through ALL songs then sort out the song into a playlist
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
-> set a timer when clicking next... AND IT HAS TO BE THE SAME TIMER AS IN PLA YBUTTON
-> skipping a song needs to be a minus

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
$Label14 = GUICtrlCreateEdit( "search", 81, 240, 300-20, 20, BitXOR( $GUI_SS_DEFAULT_EDIT, $WS_HSCROLL, $WS_VSCROLL ) )

; Handle $WM_COMMAND messages from Edit control
  ; To be able to read the search string dynamically while it's typed in
Global $MusicListView = GUICtrlCreateListView ("Title|Like Value|Row #", 183, 2, 400,200 )
_GUICtrlListView_SetExtendedListViewStyle($MusicListView, BitOR($LVS_EX_SUBITEMIMAGES, $LVS_EX_FULLROWSELECT));$LVS_EX_GRIDLINES
_GUICtrlListView_SetColumnWidth ( $MusicListView, 0, 200 )

GUIRegisterMsg( $WM_COMMAND, "WM_COMMAND" )

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

MusicListViewInit($MusicListView)
Func MusicListViewInit($LVhnd)
	If FileExists("MusicList.txt") Then
		$MusicFILE = FileOpen ("MusicList.txt")
		
		;clear previous music arrays:
		;orig array: 
		Global $MusicArray[1]
			$MusicArray[0] = "nil"
		;copy array
		Global $MusicArrayCopy[1]
			$MusicArrayCopy[0] = "nil"
		
		$MusicFILEArray = FileReadToArray($MusicFILE)
		
		;$MusicCount
		;ARRAYADD IS SLOW, REDIM TO MaxLike
		;ReDim $aArray[subscript 1]...[subscript n]
		ReDim $MusicArray[UBound($MusicFILEArray,1)]
		ReDim $MusicArrayCopy[UBound($MusicFILEArray,1)]
		
		For $x = 0 to UBound($MusicFILEArray,1)-1
			;read line
			$SongName = StringSplit($MusicFILEArray[$x], "|")[1]
			$SongLikes = StringSplit($MusicFILEArray[$x], "|")[2]

			$MusicArray[$x] = $SongName
			$MusicArrayCopy[$x] = $SongName
			
			;add to listview:
			GUICtrlCreateListViewItem ($SongName & "|" & $SongLikes & "|" & $x+1, $LVhnd)
			
			;set data
			GUICtrlSetData ( $Label9, ($x/UBound($MusicFILEArray,1))*100  & '%' & " done" & ", " & "Working on " & $SongName)
		Next
		
		
		#comments-start
		;make music array:
		$MusicCount = _FileCountLines("MusicList.txt")
		;Global $MusicArray[$MusicCount][3]
		
		;$MusicCount
		For $x = 0 to $MusicCount -1
			;read line
			$NextLine = FileReadLine ($MusicFILE)
			$SongName = StringSplit($NextLine, "|")[1]
			$SongLikes = StringSplit($NextLine, "|")[2]

			;add to array
			If $MusicArray[0] == "nil" Then
				$MusicArray[0] = $SongName
			Else
				_ArrayAdd($MusicArray, $SongName)
			EndIf
			
			;add to listview:
			GUICtrlCreateListViewItem ($SongName & "|" & $SongLikes & "|" & $x+1, $LVhnd)
			If $MusicArrayCopy[0] == "nil" Then
				$MusicArrayCopy[0] = $SongName
			Else
				_ArrayAdd($MusicArrayCopy, $SongName)
			EndIf
			;set data
			GUICtrlSetData ( $Label9, ($x/$MusicCount)*100  & '%' & " done" & ", " & "Working on " & $SongName)
		Next
		#comments-end
	Else
		$MusicFILE = FileOpen ("MusicList.txt", 2 + 256)
		FileClose ($MusicFILE)
	EndIf
EndFunc

WeightedChoiceInit ()
GUISetState()
;set false ID
Global $CurrentMusicCtrlID = -1
$CurrentSongOpen = 0
$CurrentSong = 0
$AutoplayTimer = 0
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
				
				$CurrentSongOpen = _RPCSoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;_ArrayDisplay($CurrentSongOpen)
				;_WinAPI_PlaySound
				;MsgBox(0,"lf error = 1", @error == 1)
				_SoundPlay ( $CurrentSongOpen )
				
				;MsgBox(0,"timerlength", $CurrentSong)
				;set timer to play next song:
				If $AutoplayTimer == 0 Then
					$AutoplayTimer = _Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , "AutoPlay" )
				Else
					$AutoplayTimer = _Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 ,"", $AutoplayTimer)
				EndIf 

				GUICtrlSetData ( $Label9, "Playing Line #A: " & _GUICtrlListView_FindInText ( $MusicListView, $CurrentSong , -1 , True , False) +1 & " " & $CurrentSong)
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
				;$CurrentSongOpen = _RPCSoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $HistoryArray[$prevsongIndex] )
				_SoundStop($CurrentSongOpen)
				;set current song as the prev song, and DONT add to history queue
				$CurrentSong = $HistoryArray[$prevsongIndex -1]
				$CurrentSongOpen = _RPCSoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;play prev song
				_SoundPlay($CurrentSongOpen)
				GUICtrlSetData ( $Label9, "Playing Line #B: " & _GUICtrlListView_FindInText ( $MusicListView, $CurrentSong , -1 , True , False) +1 & " " & $CurrentSong)
			Else
				GUICtrlSetData ( $Label9, "No previous history detected.")
			EndIf
		Case $Label3
			$PrevSong = $CurrentSong
			;check if you're at end of history THEN pick one or history is nil
			$prevsongIndex = _ArraySearch ($HistoryArray, $CurrentSong ,0,0,0,0,0,0,False)
			;make sure ur at end of queue
			;MsgBox(0,"tests", $prevsongIndex &"|"& UBound($HistoryArray,1) - 1 &"|"& String($prevsongIndex == UBound($HistoryArray,1)) )
			If $prevsongIndex == UBound($HistoryArray,1) -1 or $HistoryArray[0] == "nil" Then
				_SoundStop($CurrentSongOpen)
				;choose new song:
				$CurrentSong = WeightedChoice ()
				;request new song
				$CurrentSongOpen = _RPCSoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;play song
				_SoundPlay ( $CurrentSongOpen )
				GUICtrlSetData ( $Label9, "Playing Line #C: " & _GUICtrlListView_FindInText ( $MusicListView, $CurrentSong , -1 , True , False) +1 & " " & $CurrentSong)
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
				$CurrentSongOpen = _RPCSoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' &  $CurrentSong )
				;play song
				_SoundPlay ( $CurrentSongOpen )
				GUICtrlSetData ( $Label9, "Playing Line #D: " & _GUICtrlListView_FindInText ( $MusicListView, $CurrentSong , -1 , True , False) +1 & " " & $CurrentSong)
				;add to history array
				;If $HistoryArray[0] == "nil" Then
				;	;replace 1st val
				;	$HistoryArray[0] = $CurrentSong
				;Else
				;	_ArrayAdd($HistoryArray, $CurrentSong)
				;EndIf
			EndIf
			
			;CurrentSong and CurrentSongOpen have been reset in the if above
			If $AutoplayTimer == 0 Then
				$AutoplayTimer = _Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , "AutoPlay" )
			Else
				$AutoplayTimer = _Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 ,"", $AutoplayTimer)
			EndIf 
			If UBound($HistoryArray,1) > 1 and $HistoryArray[0] <> "nil" Then
				$SelectedSongID = _GUICtrlListView_FindInText ( $MusicListView, $PrevSong , -1 , True , False)
				$SelectedSong = _GUICtrlListView_GetItemTextArray ( $MusicListView , $SelectedSongID)
				;MsgBox(0,"?",_ArrayToString (($SelectedSong)))
				If $SelectedSongID > 0 Then
					$SongName = $SelectedSong[1]
					$currLike = $SelectedSong[2]
					$RowNum = $SelectedSong[3]

					If $currLike <> "" Then
						;set data on ListView
						_GUICtrlListView_SetItemText ( $MusicListView, $SelectedSongID, Int($currLike) - 1 , 1 )
						; i suspect i need to $RowNum+1 since i get the info from the listview which is 0-indexed
						;+1 FAILS
						;when i say -10 on next line, EVERYTHING IS FUCKING FINE SOMEHOW
						_FileWriteToLine("MusicList.txt", $RowNum,  $SongName & "|" & Int($currLike) - 1, True)
					Else
						_GUICtrlListView_SetItemText ( $MusicListView, $SelectedSongID, - 1 , 1 )
						_FileWriteToLine("MusicList.txt", $RowNum,  $SongName & "|" & - 1, True)
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
			;_WinAPI_PlaySound ("C:\Users\RaptorPatrolCore\Downloads\01crossing field - Copy.mp3" )
			;SoundPlay("C:\Users\RaptorPatrolCore\Downloads\01crossing field - Copy.mp3")
			;SoundPlay("C:\Users\RaptorPatrolCore\Downloads\01 - Overfly ~TV size~.mp3")
			;SoundPlay("C:\Users\RaptorPatrolCore\Downloads\01. crossing field.mp3")
			;_PathSplit ( "C:\Users\RaptorPatrolCore\Downloads\01.crossing field.mp3", ByRef $sDrive, ByRef $sDir, ByRef $sFileName, ByRef $sExtension )
			;$currentd = _RPCSoundOpen ("C:\Users\RaptorPatrolCore\Downloads\01 - Overfly ~TV size~.mp3")
			;$currentd = _RPCSoundOpen ("C:\Users\RaptorPatrolCore\Downloads\01.crossing field.mp3")
			;_ArrayDisplay($currentd)
			;MsgBox(0,"", @error == 1)
			;_SoundPlay($currentd)
			;_SoundPlay(_RPCSoundOpen ("C:\Users\RaptorPatrolCore\Downloads\01.crossing field.mp3" ))
			
			;MsgBox(0,"msgboxlabel8",_ArrayToString ( (_GUICtrlListView_GetItemTextArray ( $MusicListView , 0))))
			;WeightedChoice()
			;_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , "AutoPlay" )
			
			;MsgBox(0,"???", $MusicFILEREAD)
			;$MusicFILEBLACKLIST = FileOpen ("blacklistfileOPEN.txt", 256)
			;$MusicFILEBLACKLISTREAD = FileRead ($MusicFILEBLACKLIST)
			;;MsgBox(0,"",$MusicFILEBLACKLISTREAD)
			;MsgBox(0,"",FileSearch ($MusicFILEBLACKLISTREAD, "#7 A Secret of the Moon (Planetes Original Sound Track Album 1).mp3"))
			;;MsgBox(0,"",FileSearch ($MusicFILEBLACKLISTREAD, "Gatchaman Insight  - I n s i g h t _ Full Opening.mp3"))
			;FileClose($MusicFILEBLACKLIST)
			_ArrayDisplay($HistoryArray)
			_ArrayDisplay($NegArray)
			_ArrayDisplay($ZeroArray)
			_ArrayDisplay($PosArray)
			
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
					;keep going positive, and modify PosArray as fitting
					Case $currLike > 1
						;find the index in PosArray and +1 it
						$PosIndex = _ArraySearch ($PosArray, $SongName ,0,0,0,0,1,0,False)
						$PosArray[$PosIndex][1] = $currLike+1
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
					Case $currLike < -1
						;find the index in PosArray and +1 it
						$NegIndex = _ArraySearch ($NegArray, $SongName ,0,0,0,0,1,0,False)
						$NegArray[$NegIndex][1] = $currLike-1
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
					GUICtrlSetData ( $Label9, ($y/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $SelectedSong)
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
			GUICtrlCreateListViewItem($FileList[$x] & "|" & "0" & "|" & $searchANS+1, $MusicListView )
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
	;GUICtrlSetData ( $Label9, "Autoplay triggered!..." & _SoundStatus ( $CurrentSongOpen ) == 0)
	;make sure nothing is playing
	If  _SoundStatus ( $CurrentSongOpen ) == 0 or _SoundStatus ( $CurrentSongOpen ) == "stopped" Then
		;randomly pick the next song
		$CurrentSong = WeightedChoice()
		$CurrentSongOpen = _RPCSoundOpen ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' & $CurrentSong )
		GUICtrlSetData ( $Label9, "Autoplaying. Line #E: " & _GUICtrlListView_FindInText ( $MusicListView, $CurrentSong , -1 , True , False) +1 & " " & $CurrentSong)
		_SoundPlay ( $CurrentSongOpen )
		;set the timer again to songlength + 500 miliseconds
		;_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , AutoPlay )
	EndIf
	;this is to mess with historyarray
	;add to history array
	If $HistoryArray[0] == "nil" Then
		;replace 1st val
		$HistoryArray[0] = $CurrentSong
	Else
		_ArrayAdd($HistoryArray, $CurrentSong)
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

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

    Local $hdlWindowFrom, _
          $intMessageCode, _
          $intControlID_From

    $intControlID_From =  BitAND($wParam, 0xFFFF)
    $intMessageCode = BitShift($wParam, 16)

    Switch $intControlID_From
        Case $Label14
            Switch $intMessageCode
                Case $EN_CHANGE
					;MsgBox(0,"?",GUICtrlRead($label14) == "")
					If GUICtrlRead($label14) == "" Then
						;if searchbar is blank, init again
						_GUICtrlListView_DeleteAllItems ( $MusicListView )
						MusicListViewInit($MusicListView)
					Else
						#comments-start
						;if i make an original ghost listview, i need to assign the var on init and on reinit
						;if i make an array, i'll have to track changes again.... fuck there are so many
						i think i write abstractl enough that arrayclone will work
						
						how to clear data but still remember w/o reading file repeatedly?
						;clear it
						;then assemble again
						;problem: i can only do this for one search. the next search will search this neutered list.
						
						;problem 1:						
						;successive filters are not good:
							OK:
							;ex: search abcd -> abcde  
							NOT OK:
							;ex: search abcd -> fghe
							;i can stop this possibly by resetting the search every time the search string loses 1 character:
							aka
							search: abcde -> abcd (refresh search)

							
						;if not, then filter out
						
						plan: copy filenames into array and have it be init at the same time i call musivlistviewinit
						then i can filter by songname AND when reading or writing i take info from MusicList.txt AKA regenerate the row
						need: 
							songname 
							likes
							line in text file
						
						#comments-end
						;MsgBox(0,"?",GUICtrlRead($label14))
						;redraw listview with search text filter with partial search:
						_GUICtrlListView_DeleteAllItems ( $MusicListView )
						$searchText = GUICtrlRead($label14)
						;_ArrayDisplay($MusicArrayCopy)
						$FoundArray = _ArrayFindAll($MusicArrayCopy,$searchText,0,0,0,1,0,False)
						;MsgBox(0,"arraysize",UBound($FoundArray,1))
						;MsgBox(0,"array",$MusicArrayCopy[$FoundArray[0]])
						;_ArrayDisplay($FoundArray)
						If $FoundArray <> -1 Then
							;fileopen in read mode
							$MusicFILE = FileOpen ("MusicList.txt", 256)
							;read to array
							$MusicArrayOrigin = FileReadToArray ( $MusicFILE )
							For $y = 0 to UBound($FoundArray,1)-1
								;$FoundArray[$y] = index of song name in $MusicArrayCopy
								$SongCandidateName = $MusicArrayCopy[$FoundArray[$y]]
								;Search in file. 1 in $iCompare should be a partial search...:
								$SearchItemIndex = _ArraySearch($MusicArrayOrigin, $SongCandidateName,0,0,0,1,1,0,False)
								;generate listview line:
								GUICtrlCreateListViewItem ($SongCandidateName & "|" & StringSplit($MusicArrayOrigin[$SearchItemIndex], "|")[2] & "|" & $SearchItemIndex+1, $MusicListView)
							Next
							FileClose ($MusicFILE)
						EndIf
					EndIf
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc

Func __RPCSoundMciSendString($sString, $iLen = 0)
	;MsgBox(0,"ddd", @error)
	Local $aRet = DllCall("winmm.dll", "dword", "mciSendStringW", "wstr", $sString, "wstr", "", "uint", $iLen, "ptr", 0)
	;MsgBox(0,"dde", @error)
	If @error Then Return SetError(@error, @extended, "")
	If $aRet[0] Then Return SetError(10, $aRet[0], $aRet[2])
	Return $aRet[2]
EndFunc   ;==>__SoundMciSendString

Func _RPCSoundOpen($sFilePath)
	$Ans = _RPCSoundOpenOld($sFilePath)
	;If I cannot play, write to file:
	If @error <> 0 Then
		$musicErrors = FileOpen("MusicErrors.txt",1)
		FileWrite($musicErrors, $CurrentSong & @CRLF)
		FileClose($musicErrors)
	EndIf
	Return $Ans
EndFunc

Func _RPCSoundOpenOld($sFilePath)
	;MsgBox(0,"injected?","y!")
	;check for file
	If Not FileExists($sFilePath) Then Return SetError(2, 0, 0)
	;create random string for file ID
	Local $aSndID[4]
	For $i = 1 To 10
		$aSndID[0] &= Chr(Random(97, 122, 1))
	Next
	;MsgBox(0,"A", @error)
	Local $sDrive, $sDir, $sFName, $sExt
	_PathSplit($sFilePath, $sDrive, $sDir, $sFName, $sExt)
	;MsgBox(0,"b", @error)
	Local $sSndDirName
	If $sDrive = "" Then
		$sSndDirName = @WorkingDir & "\"
	Else
		$sSndDirName = $sDrive & $sDir
	EndIf
	Local $sSndFileName = $sFName & $sExt
	;MsgBox(0,"C", @error)
	Local $sSndDirShortName = FileGetShortName($sSndDirName, 1)
	;MsgBox(0,"D", @error)
	;open file
	__RPCSoundMciSendString("open """ & $sFilePath & """ alias " & $aSndID[0])
	;MsgBox(0,"E", @error)

	;__RPCSoundMciSendString RETURNS ERROR OF 10 FOR SOME REASON AND I CANNOT PLAY 01.crossing field.mp3 in downloads folder
	If @error Then Return SetError(1, @error, 0) ; open failed
	
	Local $sTrackLength, $bTryNextMethod = False
	Local $oShell = ObjCreate("shell.application")
	If IsObj($oShell) Then
		Local $oShellDir = $oShell.NameSpace($sSndDirShortName)
		If IsObj($oShellDir) Then
			Local $oShellDirFile = $oShellDir.Parsename($sSndFileName)
			If IsObj($oShellDirFile) Then
				Local $sRaw = $oShellDir.GetDetailsOf($oShellDirFile, -1)
				Local $aInfo = StringRegExp($sRaw, ": ([0-9]{2}:[0-9]{2}:[0-9]{2})", $STR_REGEXPARRAYGLOBALMATCH)
				If Not IsArray($aInfo) Then
					$bTryNextMethod = True
				Else
					$sTrackLength = $aInfo[0]
				EndIf
			Else
				$bTryNextMethod = True
			EndIf
		Else
			$bTryNextMethod = True
		EndIf
	Else
		$bTryNextMethod = True
	EndIf

	Local $sTag
	If $bTryNextMethod Then
		$bTryNextMethod = False
		If $sExt = ".mp3" Then
			Local $hFile = FileOpen(FileGetShortName($sSndDirName & $sSndFileName), $FO_READ)
			$sTag = FileRead($hFile, 5156)
			FileClose($hFile)
			$sTrackLength = __SoundReadXingFromMP3($sTag)
			If @error Then $bTryNextMethod = True
		Else
			$bTryNextMethod = True
		EndIf
	EndIf

	If $bTryNextMethod Then
		$bTryNextMethod = False
		If $sExt = ".mp3" Then
			$sTrackLength = __SoundReadTLENFromMP3($sTag)
			If @error Then $bTryNextMethod = True
		Else
			$bTryNextMethod = True
		EndIf
	EndIf

	If $bTryNextMethod Then
		$bTryNextMethod = False
		;tell mci to use time in milliseconds
		__SoundMciSendString("set " & $aSndID[0] & " time format milliseconds")
		;receive length of sound
		Local $iSndLenMs = __SoundMciSendString("status " & $aSndID[0] & " length", 255)

		;assign modified data to variables
		Local $iSndLenMin, $iSndLenHour, $iSndLenSecs
		__SoundTicksToTime($iSndLenMs, $iSndLenHour, $iSndLenMin, $iSndLenSecs)

		;assign formatted data to $sSndLenFormat
		$sTrackLength = StringFormat("%02i:%02i:%02i", $iSndLenHour, $iSndLenMin, $iSndLenSecs)
	EndIf

	; Convert Track_Length to mSec
	Local $aiTime = StringSplit($sTrackLength, ":")
	Local $iActualTicks = __SoundTimeToTicks($aiTime[1], $aiTime[2], $aiTime[3])

	;tell mci to use time in milliseconds
	__SoundMciSendString("set " & $aSndID[0] & " time format milliseconds")

	;;Get estimated length
	Local $iSoundTicks = __SoundMciSendString("status " & $aSndID[0] & " length", 255)

	;Compare to actual length
	Local $iVBRRatio
	If Abs($iSoundTicks - $iActualTicks) < 1000 Then ;Assume CBR, as our track length from shell.application is only accurate within 1000ms
		$iVBRRatio = 0
	Else ;Set correction ratio for VBR operations
		$iVBRRatio = $iSoundTicks / $iActualTicks
	EndIf

	$aSndID[1] = $iVBRRatio
	$aSndID[2] = 0
	$aSndID[3] = $__SOUNDCONSTANT_SNDID_MARKER

	Return $aSndID
EndFunc   ;==>_RPCSoundOpen