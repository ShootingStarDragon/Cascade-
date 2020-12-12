#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <Array.au3>

Opt( "MustDeclareVars", 1 )

Global $hGui, $hEdit, $idEditSearch, $hLV, $iItems = 1000, $aItems[$iItems], $aSearch[$iItems], $iSearch = 0

Example()


Func Example()
  ; Create GUI
  $hGui = GUICreate( "Virtual ListView search", 300, 230 )

  ; Create Edit control
  Local $idEdit = GUICtrlCreateEdit( "edit text", 10, 10, 300-20, 20, BitXOR( $GUI_SS_DEFAULT_EDIT, $WS_HSCROLL, $WS_VSCROLL ) )
  $hEdit = GUICtrlGetHandle( $idEdit )
  $idEditSearch = GUICtrlCreateDummy()

  ; Handle $WM_COMMAND messages from Edit control
  ; To be able to read the search string dynamically while it's typed in
  GUIRegisterMsg( $WM_COMMAND, "WM_COMMAND" )

  ; Create ListView
  Local $idLV = GUICtrlCreateListView( "", 10, 40, 300-20, 200-20, $LVS_OWNERDATA, BitOR( $WS_EX_CLIENTEDGE, $LVS_EX_DOUBLEBUFFER, $LVS_EX_FULLROWSELECT ) )
  $hLV = GUICtrlGetHandle( $idLV ) ;                               Virtual listview                          Reduces flicker
  _GUICtrlListView_AddColumn( $hLV, "Items",  250 )

  ; Handle $WM_NOTIFY messages from ListView
  ; Necessary to display the rows in a virtual ListView
  GUIRegisterMsg( $WM_NOTIFY, "WM_NOTIFY" )

  ; Show GUI
  GUISetState( @SW_SHOW )

  ; Fill array
  FillArray( $aItems, $iItems )
  _ArraySort( $aItems, 0, 0, 0, 0, 1 )

  ; Set search array to include all items
  For $i = 0 To $iItems - 1
    $aSearch[$i] = $i
  Next
  $iSearch = $iItems

  ; Display items
  GUICtrlSendMsg( $idLV, $LVM_SETITEMCOUNT, $iSearch, 0 )

  ; Message loop
  While 1
    Switch GUIGetMsg()
      Case $idEditSearch
        Local $sSearch = GUICtrlRead( $idEdit )
		;MsgBox(0,"??", $sSearch)
        If $sSearch = "" Then
          ; Empty search string, display all rows
          For $i = 0 To $iItems - 1
            $aSearch[$i] = $i
          Next
          $iSearch = $iItems
        Else
          ; Find rows matching the search string
          $iSearch = 0
          For $i = 0 To $iItems - 1
            ;If StringInStr( $aItems[$i], $sSearch ) Then ; Normal search
            If StringRegExp( $aItems[$i], $sSearch ) Then ; Reg. exp. search
              $aSearch[$iSearch] = $i
              $iSearch += 1
            EndIf
          Next
        EndIf
        GUICtrlSendMsg( $idLV, $LVM_SETITEMCOUNT, $iSearch, 0 )
        ConsoleWrite( StringFormat( "%4d", $iSearch ) & " rows matching """ & $sSearch & """" & @CRLF )

      Case $GUI_EVENT_CLOSE
        ExitLoop
    EndSwitch
  WEnd

  GUIDelete()
EndFunc

Func FillArray( ByRef $aItems, $iRows )
  Local $aLetters[26] = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', _
                          'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' ]
  Local $s
  For $i = 0 To $iRows - 1
    $s = $aLetters[Random(0,25,1)]
    For $j = 1 To Random(10,30,1)
      $s &= $aLetters[Random(0,25,1)]
    Next
    $aItems[$i] = $s
  Next
EndFunc

Func WM_COMMAND( $hWnd, $iMsg, $wParam, $lParam )
  Local $hWndFrom = $lParam
  Local $iCode = BitShift( $wParam, 16 ) ; High word
  Switch $hWndFrom
    Case $hEdit
      Switch $iCode
        Case $EN_CHANGE
          GUICtrlSendToDummy( $idEditSearch )
      EndSwitch
  EndSwitch
  Return $GUI_RUNDEFMSG
EndFunc

Func WM_NOTIFY( $hWnd, $iMsg, $wParam, $lParam )
  Local Static $tText = DllStructCreate( "wchar[50]" )
  Local Static $pText = DllStructGetPtr( $tText )

  Local $tNMHDR, $hWndFrom, $iCode
  $tNMHDR = DllStructCreate( $tagNMHDR, $lParam )
  $hWndFrom = HWnd( DllStructGetData( $tNMHDR, "hWndFrom" ) )
  $iCode = DllStructGetData( $tNMHDR, "Code" )

  Switch $hWndFrom
    Case $hLV
      Switch $iCode
        Case $LVN_GETDISPINFOW
          Local $tNMLVDISPINFO = DllStructCreate( $tagNMLVDISPINFO, $lParam )
          If BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), $LVIF_TEXT ) Then
            Local $sItem = $aItems[$aSearch[DllStructGetData($tNMLVDISPINFO,"Item")]]
            DllStructSetData( $tText, 1, $sItem )
            DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
            DllStructSetData( $tNMLVDISPINFO, "TextMax", StringLen( $sItem ) )
          EndIf
      EndSwitch
  EndSwitch

  Return $GUI_RUNDEFMSG
EndFunc