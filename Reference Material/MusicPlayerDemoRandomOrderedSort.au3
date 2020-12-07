#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

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
-> refresh music list to add newer songs
->blacklist filter
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


If FileExists("MusicList.txt") Then
	$MusicFILE = FileOpen ("MusicList.txt")
	
	;make music array:
	$MusicCount = _FileCountLines("MusicList.txt")
	Global $MusicArray[$MusicCount][3]
	
	;$MusicCount
	For $x = 0 to 5 -1
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
GUISetState()
;set false ID
Global $CurrentMusicCtrlID = -1
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Label1
			;if something is selected from listview, play:
			;else say nothing selected
			If 3+2 = 5 Then
				$CurrentSong = StringSplit(GUICtrlRead(GUICtrlRead ( $MusicListView)), "|")[1]
				SoundPlay ( StringSplit(FileReadLine("MusicFolders.txt"), "|")[1] & '\' & $CurrentSong)
				GUICtrlSetData ( $Label9, "Playing " & $CurrentSong)
				;set the ctrl ID because I need to know for +1 -1
				Global $CurrentMusicCtrlID = GUICtrlRead ( $MusicListView)
			Else
				GUICtrlSetData ( $Label9, "No song selected!")
			EndIf
		Case $Label4
			SoundPlay("nosound", 0)
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