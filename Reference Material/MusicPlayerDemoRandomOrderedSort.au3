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
make window
(skip) have dropdown for xspf playlists
	buttons:
		play
		prev
		next
		stop
		voldown
		volup
		(skip)foldersource
	
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

#comments-start
#comments-end
$Label1 = GUICtrlCreateButton("Play", 0, 2, 81, 41)
$Label2 = GUICtrlCreateButton("Prev", 0, 43, 81, 41)
$Label3 = GUICtrlCreateButton("Next", 81, 43, 81, 41)
$Label4 = GUICtrlCreateButton("Stop", 81, 2, 81, 41)
$Label5 = GUICtrlCreateButton("VolDown", 0, 84, 81, 41)
$Label6 = GUICtrlCreateButton("volUp", 81, 84, 81, 41)
$Label7 = GUICtrlCreateButton("FolderSource", 0, 125, 81, 41)
$Label8 = GUICtrlCreateButton("Refresh List", 81, 125, 81, 41)
$Label9 = GUICtrlCreateLabel("", 0, 207, 400, 30)
;$Label10 = GUICtrlCreateLabel("??????????????????????????????????????????????????????????????????", 162, 0, 400, 30)
;max char length: ??????????????????????????????????????????????????????????????????
;$Label11 = GUICtrlCreateButton("like (+1)", 162, 43, 81, 41)
;$Label12 = GUICtrlCreateButton("dislike (-1)", 243, 43, 81, 41)
$Label11 = GUICtrlCreateButton("like (+1)", 0, 166, 81, 41)
$Label12 = GUICtrlCreateButton("dislike (-1)", 81, 166, 81, 41)

Global $MusicListView = GUICtrlCreateListView ("Title|col2|col3", 183, 2, 400,200 )
_GUICtrlListView_SetExtendedListViewStyle($MusicListView, BitOR($LVS_EX_SUBITEMIMAGES, $LVS_EX_FULLROWSELECT));$LVS_EX_GRIDLINES


If FileExists("MusicList.txt") Then
	$MusicFILE = FileRead ("MusicList.txt")
	
	;make music array:
	$MusicCount = _FileCountLines("MusicList.txt")
	Global $MusicArray[$MusicCount][3]
	
	For $x = 0 to UBound($MusicCount ,1)
		;read line
		$NextLine = FileRead ("MusicList.txt")
		$SongName = StringSplit($NextLine, "|")[1]
		
		;add to array
		$MusicArray[$x][0] = $SongName
		;add to listview:
		GUICtrlCreateListViewItem ($SongName & "|" & "|", $MusicListView)
		;set data
		GUICtrlSetData ( $Label9, ($x/$MusicTotal)*100  & '%' & " done" & ", " & "Working on " & $SongName)
	Next
Else
	$MusicFILE = FileOpen ("MusicList.txt", 2 + 256)
	FileClose ($MusicFILE)
EndIf
GUISetState()
While 1
	$nMsg = GUIGetMsg()
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Label7
			$FileSource = FileSelectFolder("Select Music Folder", "")
			
			$FileList = _FileListToArray($FileSource, "*.mp3", 0)
			;IniWrite ( "filename", "section", "key", "value" )
			;IniRead ( "filename", "section", "key", "default" )
			do
			Sleep (500)
			Until IsInt ( $FileList[0] )
			$MusicFILE = FileOpen ("MusicList.txt", 2 + 256)
			IniWrite ( $MusicFILE, "FolderSource", "Folder1", $FileSource )
			For $x=1 to UBound( $FileList ,1) -1
				;i don't want to override old data....
				;if it DOES NOT exist: write
				If IniRead ( $MusicFILE, "MusicData", $FileList[$x], False ) == False Then
					GUICtrlSetData ( $Label9, ($x/$FileList[0])*100  & '%' & " done" & ", " & "Working on " & $FileList[$x])
					IniWrite ( $MusicFILE, "MusicData", $FileList[$x], $FileList[$x] )
					;add the song to the listview:
					GUICtrlCreateListViewItem ($FileList[$x] & "|" & "|", $MusicListView )
				EndIf
			Next
			FileClose ($MusicFILE)
	EndSwitch
WEnd