#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <GUIListView.au3>
#include <EditConstants.au3>
#include "GUIListViewEx\GUIListViewEx.au3"
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
;#include "_FileListToArrayEx_Marco.au3"
#include <Array.au3>

; *******************************************************************************************************
; **************************** LETTURA FILE CODICI DALLE CARTELLE ***************************************
; *******************************************************************************************************

;~ $listaTotaleCodici = _FileListToArrayEx ("images", "*.png", 4);1+4); 1+4+128)   ;<== original
dim $listaTotaleCodici[11]
$listaTotaleCodici[0] = 10
$listaTotaleCodici[1] = "01A_COD1_Tipo1_CHECK2_01_123456789_02_.png"
$listaTotaleCodici[2] = "01A_COD2_Tipo1_CHECK3_02_321456789_01_.png"
$listaTotaleCodici[3] = "02A_COD1_Tipo1_CHECK2_01_231456798_02_.png"
$listaTotaleCodici[4] = "03A_COD1_Tipo2_CHECK1_01_888456789_01_.png"
$listaTotaleCodici[5] = "04A_COD2_Tipo2_CHECK1_01_111456789_02_.png"
$listaTotaleCodici[6] = "05A_COD1_Tipo1_CHECK2_01_777456789_02_.png"
$listaTotaleCodici[7] = "05A_COD1_Tipo3_CHECK1_01_666456789_01_.png"
$listaTotaleCodici[8] = "06A_COD1_Tipo1_CHECK2_01_555456789_02_.png"
$listaTotaleCodici[9] = "07A_COD1_Tipo3_CHECK2_01_444456789_01_.png"
$listaTotaleCodici[10] = "08A_COD1_Tipo1_CHECK2_01_666777789_02_.png"
;~ $listaTotaleCodici[11] = "08A_COD2_Tipo1_CHECK3_01_222456789_02_.png"



; read some png files
; Ex:
; 01A_COD_Tipo1_CHECK2_N_NUMBER_XY.png
; 02A_COD_Tipo1_CHECK2_N_NUMBER_XY.png
; 03A_COD_Tipo3_CHECK1_N_NUMBER_XY.png
; where NUMBER is differentfor any png files
; COD has max 2 values (COD1 or COD2)
; Tipo has max 3 values

; *******************************************************************************************************
; ********************************* DICHIARAZIONI VARIABILI *********************************************
; *******************************************************************************************************

dim $aArray[8]
dim $filtrare[13] ;array dove vengono memorizzate le parole da filtrare (899, 01, webcom, ecc ecc)
Global $fatto = 0
Global $iLV_L1,$iLV_L2,$iLV_L3,$iLV_Codici
Dim $idItem[800]
Dim $idItemL1[3]
Dim $idItemL2[3]
Dim $idItemL3[3]

Global $idListviewL1, $idListviewL2, $idListviewL3, $idListview

$x = 120
$y = 96
$offsetxpreview = 24+100
$offsetypreview = 129+96
$offsetx = $offsetxpreview + $x + 24
$offsety = 12
Global $offsetxradio = 345

Global $aList1, $tmp_String
Dim $TotaleCodici[800]
Dim $aTempArray[800]
Dim $idButton[6]
Global $offsetxbutton = 20
Global $offsetybutton = 45
Global $idx=0
Global $b = 0
Global $filtrato = 0


; *******************************************************************************************************
; **************************************** PARTENZA GDI *************************************************
; *******************************************************************************************************

_GDIPlus_Startup()
;~ GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")


; *******************************************************************************************************
; *********************************** CREAZIONE GUI PRINCIPALE ******************************************
; *******************************************************************************************************

$g_hGUI = GUICreate("GUI", 1038, 700, 192, 124)
GUISetState()

Global $Graphic = _GDIPlus_GraphicsCreateFromHWND($g_hGUI)

; *******************************************************************************************************
; **************************************** CREAZIONE CHECKBOX  ******************************************
; *******************************************************************************************************

GUIStartGroup()
$RadioCodice1 = GUICtrlCreateCheckbox("CHECK1", $offsetxradio+112, 10, 100, 17)
GUICtrlSetState($RadioCodice1, $GUI_CHECKED)
$RadioCodice2 = GUICtrlCreateCheckbox("CHECK2", $offsetxradio+227, 10, 100, 17)
GUICtrlSetState($RadioCodice2, $GUI_CHECKED)
$RadioCodice3 = GUICtrlCreateCheckbox("CHECK3", $offsetxradio+341, 10, 100, 17)
GUICtrlSetState($RadioCodice3, $GUI_CHECKED)
$Label1 = GUICtrlCreateLabel("LABEL:", $offsetxradio + 24 + 35, 10+2, 50, 17)

$RadioTipo1 = GUICtrlCreateCheckbox("Tipo1", $offsetxradio+112, 45, 100, 17)
GUICtrlSetState($RadioTipo1, $GUI_CHECKED)
$RadioTipo2 = GUICtrlCreateCheckbox("Tipo2", $offsetxradio+227, 45, 100, 17)
GUICtrlSetState($RadioTipo2, $GUI_CHECKED)
$RadioTipo3 = GUICtrlCreateCheckbox("Tipo3", $offsetxradio+341, 45, 100, 17)
GUICtrlSetState($RadioTipo3, $GUI_CHECKED)
$LabelTipo = GUICtrlCreateLabel("TIPO:", $offsetxradio + 24 + 35, 45+2, 50, 17)

Global $offsetxradio = 345
;~ GUIStartGroup()
$Radio1 = GUICtrlCreateCheckbox("A", $offsetxradio+112, 80, 50, 17)
;~  Local $idCheckbox = GUICtrlCreateCheckbox("Standard Checkbox", 10, 10, 185, 25)
GUICtrlSetState($Radio1, $GUI_CHECKED)
$Radio2 = GUICtrlCreateCheckbox("B", $offsetxradio+169, 80, 50, 17)
GUICtrlSetState($Radio2, $GUI_CHECKED)
$Radio3 = GUICtrlCreateCheckbox("C", $offsetxradio+227, 80, 50, 17)
GUICtrlSetState($Radio3, $GUI_CHECKED)
$Radio4 = GUICtrlCreateCheckbox("D", $offsetxradio+284, 80, 50, 17)
GUICtrlSetState($Radio4, $GUI_CHECKED)
$Radio5 = GUICtrlCreateCheckbox("E", $offsetxradio+341, 80, 50, 17)
GUICtrlSetState($Radio5, $GUI_CHECKED)
$Radio6 = GUICtrlCreateCheckbox("F", $offsetxradio+399, 80, 50, 17)
GUICtrlSetState($Radio6, $GUI_CHECKED)
$Radio7 = GUICtrlCreateCheckbox("ALL", $offsetxradio+456, 80, 50, 17)
GUICtrlSetState($Radio7, $GUI_CHECKED)
$LabelGruppi = GUICtrlCreateLabel("LABEL:", $offsetxradio + 24 + 35, 80+2, 50, 17)

$ButtonFiltra = GUICtrlCreateButton("Filter", 870, 12, 150, 84)
;~ GUICtrlSetBkColor(-1,0x00FF00

$hGraphic = _GDIPlus_GraphicsCreateFromHWND($Graphic)
$hPen = _GDIPlus_PenCreate(0xff000000, 2);red, 3pixels wide

; *******************************************************************************************************
; **************************************** CREAZIONE BOTTONI  *******************************************
; *******************************************************************************************************

$cDelete_Button = GUICtrlCreateButton("Delete Line", 870, 115, 150, 30)


$idListviewL1 = GUICtrlCreateListView("LISTVIEWL1", 400, 6+96, 450, 96)
_GUICtrlListView_SetColumnWidth($idListviewL1, 0, 446)
$idListviewL2 = GUICtrlCreateListView("LISTVIEWL2", 400, 6+96+96, 450, 96)
_GUICtrlListView_SetColumnWidth($idListviewL2, 0, 446)
$idListviewL3 = GUICtrlCreateListView("LISTVIEWL3", 400, 6+96+96+96, 450, 96)
_GUICtrlListView_SetColumnWidth($idListviewL3, 0, 446)
$idListview = GUICtrlCreateListView("LISTVIEW", 400, 6+96+96+96+96, 450, 573-96-96-96)
_GUICtrlListView_SetColumnWidth($idListview, 0, 446)

if $fatto = 0 Then
    ConsoleWrite("fatto = 0" & @CRLF)
    For $i = 1 To $listaTotaleCodici[0] ; Loop through the array to display the individual values.
        local $aArray = StringSplit($listaTotaleCodici[$i], '_');, $STR_ENTIRESPLIT) ; Pass the variable to StringSplit and using the delimiter "\n".
        Local $aList[$listaTotaleCodici[0]+1], $sText
        If IsArray($aArray) Then
            $sText =  $aArray[1] & " " & $aArray[2] &  " " & $aArray[3] &  " " & $aArray[4] &  " " & $aArray[6]
            $aList[$i] = $sText
            GUICtrlCreateListViewItem($sText, $idListview)
        EndIf
    Next
    $iLV_Codici = _GUIListViewEx_Init($idListview, $aList, 0, 0, True, 128 + 256)
    $TotaleEtichetteCodici = _GUIListViewEx_ReadToArray($idListview)
    $fatto = 1
EndIf

$iLV_L1 = _GUIListViewEx_Init($idListviewL1, $idItemL1, 0, 0, True) ; No external drop, will drag to others - items deleted on drag
$iLV_L2 = _GUIListViewEx_Init($idListviewL2, $idItemL2, 0, 0, True) ; No external drop, will drag to others - items deleted on drag
$iLV_L3 = _GUIListViewEx_Init($idListviewL3, $idItemL3, 0, 0, True) ; No external drop, will drag to others - items deleted on drag
;~  $iLV_Codici = _GUIListViewEx_Init($idListview, $idItem, 0, 0, True, 128 + 256) ; No external drop, will drag to others - items NOT deleted on drag
;~  GUISetState()
_GUIListViewEx_MsgRegister()

_GUICtrlListView_SetColumnWidth($idListview, 0, $LVSCW_AUTOSIZE_USEHEADER)
_GUICtrlListView_SetColumnWidth($idListview, 1, 1) ; <<<<<<<<<<<<<<<<<<<<<<<<<<

GUISetState(@SW_SHOW)

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

; *******************************************************************************************************
; ********************************************* MAIN LOOP ***********************************************
; *******************************************************************************************************

Global $idMsg
;~     ; Loop until the user exits.
    While 1
        Sleep(10)
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $cDelete_Button
                $listaTotaleCodiciaAttiva = _GUIListViewEx_GetActive()
                ConsoleWrite(" active = " & $listaTotaleCodiciaAttiva & @CRLF)
                if $listaTotaleCodiciaAttiva <> 1 Then
                    _GUIListViewEx_Delete()
                EndIf
            Case $ButtonFiltra
                _filtraCodici()
        EndSwitch
    WEnd

; Clean up resources
_GDIPlus_GraphicsDispose($Graphic)
_GDIPlus_Shutdown()


; *******************************************************************************************************
; ***************************************** QUIT FUNCTION ***********************************************
; *******************************************************************************************************

Func Quit()

    _GDIPlus_Shutdown()
    Exit
EndFunc


; *******************************************************************************************************
; **************************************** ISCHECKED FUNCTION *******************************************
; *******************************************************************************************************

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked


; *******************************************************************************************************
; ************************************ WM_NOTIFY FUNCTION ***********************************************
; *******************************************************************************************************

Func WM_NOTIFY($hWndGUI, $MsgID, $wParam, $lParam)
    _GUIListViewEx_WM_NOTIFY_Handler($hWndGUI, $MsgID, $wParam, $lParam)
    #forceref $hWndGUI, $MsgID, $wParam
    Local $index
    $tStruct = DllStructCreate("hwnd;uint_ptr;int_ptr;int;int", $lParam)
    $hWndFrom = DllStructGetData($tStruct, 1)
    $idFrom = DllStructGetData($tStruct, 2)
    $code = DllStructGetData($tStruct, 3)
    $index = DllStructGetData($tStruct, 4)
    $hWndListView1 = GUICtrlGetHandle($iLV_L1) ;($idListviewL1)
    $hWndListView2 = GUICtrlGetHandle($iLV_L2) ;($idListviewL2)
    $hWndListView3 = GUICtrlGetHandle($iLV_L3) ;($idListviewL3)
    $hWndListViewCodici = GUICtrlGetHandle($iLV_Codici) ;($idListview)
    Switch $code
        Case $NM_CLICK  ;Left Mouse Button
            ConsoleWrite("left mouse button")
            Switch $idFrom
                Case $iLV_L1
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
;~                     ConsoleWrite("+Click: " & $index & @CRLF)
                    $text = _GUICtrlListView_GetItemText($iLV_L1, DllStructGetData($tInfo, "Index"))
                    ConsoleWrite("+text: " & $text & @CRLF)
            EndSwitch

        Case $NM_DBLCLK ;Double Left Mouse Button
            Switch $idFrom
                Case $idListviewL1
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
;~                     ConsoleWrite("+Click: " & $index & @CRLF)
                    $text = _GUICtrlListView_GetItemText($idListviewL1, DllStructGetData($tInfo, "Index"))
                    ConsoleWrite("+textDBClick: " & $text & @CRLF)
                Case $idListview
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
;~                     ConsoleWrite("+Click: " & $index & @CRLF)
                    $text = _GUICtrlListView_GetItemText($idListview, DllStructGetData($tInfo, "Index"))
                    ConsoleWrite("+textDBClick: " & $text & @CRLF)
            EndSwitch

        Case $GUI_EVENT_CLOSE
            Quit()

    EndSwitch
EndFunc   ;==>WM_NOTIFY


; *******************************************************************************************************
; ***************************************** FILTRA CODICI ***********************************************
; *******************************************************************************************************

Func _filtraCodici()
            $aTempArray = $TotaleEtichetteCodici ;$listaTotaleCodici
            Local $filtrato = 0
            If _IsChecked($Radio1) Then
        $filtrare[1] = 1
    Else
        $filtrare[1] = "A"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = StringLeft($aTempArray[$b][0],3)
            If StringInStr($tmp_String,$filtrare[1]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($Radio2) Then
        $filtrare[2] = 1
    Else
        $filtrare[2] = "B"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = StringLeft($aTempArray[$b][0],3)
            If StringInStr($tmp_String,$filtrare[2]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($Radio3) Then
        $filtrare[3] = 1
    Else
        $filtrare[3] = "C"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = StringLeft($aTempArray[$b][0],3)
            If StringInStr($tmp_String,$filtrare[3]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($Radio4) Then
        $filtrare[4] = 1
    Else
        $filtrare[4] = "D"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = StringLeft($aTempArray[$b][0],3)
            If StringInStr($tmp_String,$filtrare[4]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($Radio5) Then
        $filtrare[5] = 1
    Else
        $filtrare[5] = "E"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = StringLeft($aTempArray[$b][0],3)
            If StringInStr($tmp_String,$filtrare[5]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($Radio6) Then
        $filtrare[6] = 1
    Else
        $filtrare[6] = "F"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = StringLeft($aTempArray[$b][0],3)
            If StringInStr($tmp_String,$filtrare[6]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($RadioTipo1) Then
        $filtrare[7] = 1
    Else
        $filtrare[7] = "Tipo1"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = $aTempArray[$b][0]
            If StringInStr($tmp_String,$filtrare[7]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($RadioTipo2) Then
        $filtrare[8] = 1
    Else
        $filtrare[8] = "Tipo2"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            $tmp_String = $aTempArray[$b][0]
            If StringInStr($tmp_String,$filtrare[8]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($RadioTipo3) Then
        $filtrare[9] = 1
    Else
        $filtrare[9] = "Tipo3"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            $tmp_String = $aTempArray[$b][0]
            If StringInStr($tmp_String,$filtrare[9]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($RadioCodice1) Then
        $filtrare[10] = 1
    Else
        $filtrare[10] = "CHECK1"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = $aTempArray[$b][0]
            If StringInStr($tmp_String,$filtrare[10]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($RadioCodice2) Then
        $filtrare[11] = 1
    Else
        $filtrare[11] = "CHECK2"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = $aTempArray[$b][0]
    ;~      ConsoleWrite(@CRLF & "$tmp_Stringgg= " & $tmp_String & @CRLF)
            If StringInStr($tmp_String,$filtrare[11]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf

    If _IsChecked($RadioCodice3) Then
        $filtrare[12] = 1
    Else
        $filtrare[12] = "CHECK3"
        $filtrato = 1
        For $b=UBound($aTempArray) -1 to 0 step -1
            Global $tmp_String = $aTempArray[$b][0]
    ;~      ConsoleWrite(@CRLF & "$tmp_Stringgg= " & $tmp_String & @CRLF)
            If StringInStr($tmp_String,$filtrare[12]) Then
                 _ArrayDelete($aTempArray, $b)
            EndIf
        Next
    EndIf
    _ArrayDisplay($aTempArray,"fine ciclo")
    _GUICtrlListView_DeleteAllItems($idListview)
;~  $iLV_Codici = _GUIListViewEx_Close($idListview)
    ConsoleWrite("_GUICtrlListView_DeleteAllItems" & @CRLF)
    IF $filtrato = 0 Then
        For $a=0 to UBound($TotaleEtichetteCodici)-1 ; Loop through the array to display the individual values.
            Local $aList1[UBound($TotaleEtichetteCodici)], $sText
            If IsArray($TotaleEtichetteCodici) Then
                $sText =  $TotaleEtichetteCodici[$a][0]
                ConsoleWrite("sText non filtrato = " & $sText & @CRLF)
                $aList1[$a] = $sText
                GUICtrlCreateListViewItem($sText, $idListview)
            EndIf
        Next
    EndIf
    if $filtrato = 1 Then
        For $a=0 to UBound($aTempArray)-1 ; Loop through the array to display the individual values.
            Global $aList1[UBound($aTempArray)], $sText
            If IsArray($aTempArray) Then
                $sText =  $aTempArray[$a][0]
                ConsoleWrite("sText = " & $sText & @CRLF)
                $aList1[$a] = $sText
                GUICtrlCreateListViewItem($sText, $idListview)
            EndIf
        Next
    EndIf
    $iLV_Codici = _GUIListViewEx_Close($idListview)
    $iLV_Codici = _GUIListViewEx_Init($idListview, $aList1, 0, 0, True, 128 + 256); 0, 0, True, 1 + 2 + 8, "0;2")

EndFunc     ;==>_filtraCodici