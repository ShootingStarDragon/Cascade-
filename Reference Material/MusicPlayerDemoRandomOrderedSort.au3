#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <Sound.au3>
#include <Timers.au3>

#comments-start
music app

>sort through all the songs, 
	give a +1 to songs u want to listen to again, 
	-1 to u don't like, 
	+1 to songs that you keep playing 
		(up to a limit, u don't want to listen to a song 10x in a row.... or even 10 times out of 20 songs... unless....?), 
	ability to blacklist files from the random search
random music-> take 5 sec to let me sort into playlist
find all playlists with this song (so xspf compatible)
>for the music player there should be a sort option where u go through ALL songs then sort out the song into a playlist

>remember relative audio levels for songs...
>can play music using xspf files

-=-=-=-
plan:
-> every time i +- out of an array i have to switch array data
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

-> prev and next buttons
	prev and next can mess around with this ordering
-> autoplay

Look up _Timer_SetTimer.

Note that the function called by the timer must have 4 parameters or it won't work. The help doesn't tell you this. You don't have to use the parameters. 

-> refresh music list to add newer songs
-> blacklist filter
-=-=-
-> COMPATIBILITY WITH XSPF
-> search through playlists for song (have like a dropdown menu for playlist?)
-> add song to playlist....



add the ez buttons:
	hard buttons:
		prev
		next

		



	
get music from folder
	(skip) have ability to search through multiple folders
-> shitty file structure
->???
->???
->???
-=-=-
PROBLEMS:
i have to reload the entire array if i want to update ini file... (probably do an array subtraction first then update?)
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
Global $NegArray[0] = "nil"
Global $ZeroArray[0] = "nil"
Global $PosArray[0] = "nil"

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

				_Timer_SetTimer ( $hGUI , _SoundLength($CurrentSongOpen,2) + 500 , AutoPlay )

				GUICtrlSetData ( $Label9, "Playing " & $CurrentSong)
				;set the ctrl ID because I need to know for +1 -1
				Global $CurrentMusicCtrlID = GUICtrlRead ( $MusicListView)
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
		Case $Label11
			If $CurrentMusicCtrlID > 0 Then
				$currLike = StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[2]
				$RowNum = StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[3]
				If $currLike <> "" Then
					;set data on ListView
					GUICtrlSetData ( $CurrentMusicCtrlID, "|" & Int($currLike) + 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[1] & "|" & Int($currLike) + 1 & "|" & $RowNum, True)
				Else
					GUICtrlSetData ( $CurrentMusicCtrlID, "|" & 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[1] & "|" & 1 & "|" & $RowNum, True)
				EndIf
			EndIf
		Case $Label12
			If $CurrentMusicCtrlID > 0 Then
				$currLike = StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[2]
				$RowNum = StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[3]
				If $currLike <> "" Then
					;set data on ListView
					GUICtrlSetData ( $CurrentMusicCtrlID, "|" & Int($currLike) - 1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[1] & "|" & Int($currLike) - 1 & "|" & $RowNum, True)
				Else
					GUICtrlSetData ( $CurrentMusicCtrlID, "|" & -1)
					_FileWriteToLine("MusicList.txt", $RowNum,  StringSplit(GUICtrlRead ( $CurrentMusicCtrlID), "|")[1] & "|" & - 1 & "|" & $RowNum, True)
				EndIf
			EndIf
		Case $Label7
			$FileSource = FileSelectFolder("Select Music Folder", "")
			
			$FileList = _FileListToArray($FileSource, "*.mp3", 0)
			;IniWrite ( "filename", "section", "key", "value" )
			;IniRead ( "filename", "section", "key", "default" )
			do
			Sleep (500)
			Until IsInt ( $FileList[0] )
			$MusicFILE = FileOpen ("MusicList.txt", 1 + 256)
			$MusicFILEREAD = FileRead ("MusicList.txt", 1 + 256)
			$MusicFOLDERS = FileOpen ("MusicFolders.txt", 1 + 256)
			FileWrite ( $MusicFOLDERS, $FileSource & @CRLF )
			
			For $x=1 to UBound( $FileList ,1) -1
				;i don't want to override old data....
				;if it DOES NOT exist: write
				;reread to update
				$MusicFILEREAD = FileRead ("MusicList.txt", 1 + 256)
				If FileSearch ($MusicFILEREAD, $FileList[$x]) == False Then
					GUICtrlSetData ( $Label9, ($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $FileList[$x])
					FileWrite ( $MusicFILE, $FileList[$x] & "|" & "0" & @CRLF )
					GUICtrlCreateListViewItem ($FileList[$x] & "|" & "0" & "|" & $x, $MusicListView )
				EndIf
			Next
			FileClose ($MusicFILE)
			FileClose ($MusicFOLDERS)
	EndSwitch
WEnd

Func WeightedChoiceInit ()
	;here we set up the arrays for songs:
	For $x = 0 To _GUICtrlListView_GetItemCount($MusicListView) -1 
		$SongName = _GUICtrlListView_GetItemText($MusicListView, $x)
		$LikeVal = Int(_GUICtrlListView_GetItemText($MusicListView, $x, 1))
		Switch $LikeVal
			;#array1: songs of negative value
			Case $LikeVal < 0
				;send to NegArray
				If $NegArray[0] == "nil" Then
					;replace 1st val
					$NegArray[0] = $SongName 
				Else
					_ArrayAdd($NegArray, $SongName & "|" & $LikeVal)
				EndIf
			;#array2: songs of 0 value
			Case $LikeVal = 0
				;send to ZeroArray
				If $ZeroArray[0] == "nil" Then
					;replace 1st val
					$ZeroArray[0] = $SongName 
				Else
					_ArrayAdd($ZeroArray, $SongName & "|" & $LikeVal)
				EndIf
			;#array3: songs of positive value
			Case $LikeVal > 0
				;send to PosArray
				If $PosArray[0] == "nil" Then
					;replace 1st val
					$PosArray[0] = $SongName 
				Else
					_ArrayAdd($PosArray, $SongName & "|" & $LikeVal)
				EndIf
		EndSwitch
	Next
EndFunc

Func WeightedChoice ()
	#comments-start
	random walk with weights:
	
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
			Return $NegArray[Random(0,UBound($NegArray, 1),1)]
		Else
			;pick neutral song ( likeval of 0)
			Return $ZeroArray[Random(0,UBound($ZeroArray, 1),1)]
		EndIf 
	Else
		;old song
		$MaxLike = _ArrayMax ( $PosArray ,1 , -1 , -1 , 1 )
		For $x = $MaxLine To 0 Step -1
			;successively 1/2 chance to choose from $xth like song. this levels out so u listen to like 2 songs way more than like 1 songs and ur forced to -1 them
			$Choice3 = Random ( 0,1,1 )
			If $Choice3 == 0 Then
				;choose a song of this like value
				$ValidLikeArray = StringRegExp ( _ArrayToString($PosArray, " | "), "^(.+?)\|" , 1)
				Return $ValidLikeArray[Random(0,UBound($ValidLikeArray, 1),1)]
			EndIf
		Next
	EndIf

	
EndFunc

Func AutoPlay ()
	;called when song is supposedly over
	;make sure the song is actually over (aka nothing is playing)
	
	;randomly pick the next song
	;set the timer again to songlength + 500 miliseconds
	;WeightedChoice()
	
	If $CurrentSongOpen <> 0 Then
		_SoundStop ( $CurrentSongOpen )
	EndIf
EndFunc

Func FileSearch ($FileReadObj, $string)
	If @error = -1 Then
		MsgBox(0, "Error", "File not read")
		Exit
	Else
		;MsgBox(0, "Read", $read)
		If StringRegExp($FileReadObj, $string) Then
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc