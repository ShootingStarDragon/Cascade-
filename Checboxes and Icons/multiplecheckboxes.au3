#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <array.au3>
#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
#include <GuiImageList.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

#include <APIConstants.au3>
#include <WinAPIEx.au3>

_GDIPlus_Startup()

$hGUI = GUICreate("Absent Capture", 675, 170)

$cButton_CheckAll = GUICtrlCreateButton("Check All", 10, 145, 100, 20)
$cButton_UncheckAll = GUICtrlCreateButton("UnCheck All", 120, 145, 100, 20)
$cButton_StatesToArray = GUICtrlCreateButton("States to Array", 222, 145, 100, 20)

$cListView = GUICtrlCreateListView("", 2, 2, 667, 120, BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS))
$hListView = GUICtrlGetHandle($cListView)
_GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))

$hIml_Listview = _GUIImageList_Create(16, 16, 5, 3)
$hBitmap_Icon = _Load_BMP_From_Mem(_Icon_Image_Checkbox_Unchecked(), True)
_GUIImageList_Add($hIml_Listview, $hBitmap_Icon)
_WinAPI_DeleteObject($hBitmap_Icon)
$hBitmap_Icon = _Load_BMP_From_Mem(_Icon_Image_Checkbox_Checked(), True)
_GUIImageList_Add($hIml_Listview, $hBitmap_Icon)
_WinAPI_DeleteObject($hBitmap_Icon)

_GUICtrlListView_SetImageList($hListView, $hIml_Listview, 1)

; Add columns
_GUICtrlListView_AddColumn($hListView, "     Name", 175, 0)
For $c = 1 To 21
    _GUICtrlListView_AddColumn($hListView, $c, 22 + ($c>9 ? 2 : 0), 0)
Next

; Add items
_GUICtrlListView_AddItem($hListView, "Mathinjwa, Oluhle S", 0)
_GUICtrlListView_SetItemImage($hListView, 0, 10, 0)
For $c = 1 To 21
    _GUICtrlListView_AddSubItem($hListView, 0, " ", $c, 0)
Next


_GUICtrlListView_AddItem($hListView, "Maphumulo, Siphiwokuhle", 0)
_GUICtrlListView_SetItemImage($hListView, 1, 10, 0)
For $c = 1 To 21
    _GUICtrlListView_AddSubItem($hListView, 1, " ", $c, 0)
Next

_GUICtrlListView_AddItem($hListView, "MNGOMEZULU, Mqobi Kazimoto", 0)
_GUICtrlListView_SetItemImage($hListView, 2, 10, 0)
For $c = 1 To 21
    _GUICtrlListView_AddSubItem($hListView, 2, " ", $c, 0)
Next

GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUISetState()

; Loop until user exits
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop

        Case $cButton_CheckAll
            _LV_ImgCheckboxes_CheckAll($hListView)
        Case $cButton_UncheckAll
            _LV_ImgCheckboxes_UncheckAll($hListView)
        Case $cButton_StatesToArray
            $aLVStates = _LV_ImgCheckboxes_StatesToArray($hListView)
            _ArrayDisplay($aLVStates)
    EndSwitch
WEnd

GUIDelete()
_GUIImageList_Destroy($hIml_Listview)
_GDIPlus_Shutdown()
Exit

Func _LV_ImgCheckboxes_CheckAll($hWnd)
    _GUICtrlListView_BeginUpdate($hWnd)
    For $i = 0 To _GUICtrlListView_GetItemCount($hWnd) - 1
        For $y = 0 To _GUICtrlListView_GetColumnCount($hWnd) - 1
            _GUICtrlListView_SetItemImage($hWnd, $i, 1, $y)
        Next
    Next
    _GUICtrlListView_EndUpdate($hWnd)
EndFunc   ;==>_LV_ImgCheckboxes_CheckAll

Func _LV_ImgCheckboxes_UncheckAll($hWnd)
    _GUICtrlListView_BeginUpdate($hWnd)
    For $i = 0 To _GUICtrlListView_GetItemCount($hWnd) - 1
        For $y = 0 To _GUICtrlListView_GetColumnCount($hWnd) - 1
            _GUICtrlListView_SetItemImage($hWnd, $i, 0, $y)
        Next
    Next
    _GUICtrlListView_EndUpdate($hWnd)
EndFunc   ;==>_LV_ImgCheckboxes_UncheckAll

Func _LV_ImgCheckboxes_StatesToArray($hWnd)
    Local $iColumns = _GUICtrlListView_GetColumnCount($hWnd)
    If $iColumns = 0 Then Return SetError(1)
    Local $iItems = _GUICtrlListView_GetItemCount($hWnd)
    If $iItems = 0 Then Return SetError(2)
    Local $aStates[$iItems][$iColumns]
    For $i = 0 To $iItems - 1
        For $y = 0 To $iColumns - 1
            $aStates[$i][$y] = _GUICtrlListView_GetItemImage($hWnd, $i, $y)
        Next
    Next
    Return $aStates
EndFunc   ;==>_LV_ImgCheckboxes_StatesToArray

Func WM_NOTIFY($hWnd, $Msg, $wParam, $lParam)
    Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    Local $hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
    Local $nNotifyCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case $hListView
            Switch $nNotifyCode
                Case $NM_CUSTOMDRAW
                    ; http://www.autoitscript.com/forum/topic/123757-focushighlight-a-certain-item-in-a-listview/page__view__findpost__p__859598
                    ; Mat & Siao

                    If Not _GUICtrlListView_GetViewDetails($hWndFrom) Then Return $GUI_RUNDEFMSG ; Not in details mode

                    Local $tCustDraw, $iDrawStage, $iItem, $iSubitem, $hDC, $tRect, $iColor1, $iColor2, $iColor3

                    $tCustDraw = DllStructCreate($tagNMLVCUSTOMDRAW, $lParam)
                    $iDrawStage = DllStructGetData($tCustDraw, 'dwDrawStage')

                    Switch $iDrawStage
                        Case $CDDS_PREPAINT
                            Return $CDRF_NOTIFYITEMDRAW
                        Case $CDDS_ITEMPREPAINT
                            Return $CDRF_NOTIFYSUBITEMDRAW
                        Case $CDDS_ITEMPOSTPAINT
                            ; Not handled
                        Case BitOR($CDDS_ITEMPREPAINT, $CDDS_SUBITEM)
                            Local $iItem = DllStructGetData($tCustDraw, 'dwItemSpec')
                            Local $iSubitem = DllStructGetData($tCustDraw, 'iSubItem')

                            If $iSubitem > 0 And _GUICtrlListView_GetItemSelected($hWndFrom, $iItem) Then ; Item to draw is selected
                                Local $hDC = _WinAPI_GetDC($hWndFrom)
                                Local $tRect = DllStructCreate($tagRECT)
                                Local $pRect = DllStructGetPtr($tRect)

                                ; We draw the background when we draw the first item.
                                If $iSubitem = 0 Then
                                    ; We must send the message as we want to use the struct. _GUICtrlListView_GetSubItemRect returns an array.

                                    _SendMessage($hWndFrom, $LVM_GETSUBITEMRECT, $iItem, $pRect)
                                    DllStructSetData($tRect, "Left", 0)
                                    _WinAPI_FillRect($hDC, DllStructGetPtr($tRect), _WinAPI_GetStockObject(0)) ; NULL_PEN to overwrite default highlighting

                                EndIf

                                DllStructSetData($tRect, "Left", 2)
                                DllStructSetData($tRect, "Top", $iSubitem)
                                _SendMessage($hWndFrom, $LVM_GETSUBITEMRECT, $iItem, DllStructGetPtr($tRect))
                                Local $sText = _GUICtrlListView_GetItemText($hWndFrom, $iItem, $iSubitem)
                                _WinAPI_SetBkMode($hDC, $TRANSPARENT) ; It uses the background drawn for the first item.

                                ; Select the font we want to use
                                _WinAPI_SelectObject($hDC, _SendMessage($hWndFrom, $WM_GETFONT))

                                Local $hIcon = _GUIImageList_GetIcon($hIml_Listview, _GUICtrlListView_GetItemImage($hListView, $iItem, $iSubitem))

;~                              If $iSubitem = 0 Then
;~                                  _WinAPI_DrawIconEx($hDC, DllStructGetData($tRect, "Left") - 16, DllStructGetData($tRect, "Top") + 1, $hIcon, 16, 16)
;~                                  DllStructSetData($tRect, "Left", DllStructGetData($tRect, "Left") + 2)
;~                              Else
;~                                  _WinAPI_DrawIconEx($hDC, DllStructGetData($tRect, "Left"), DllStructGetData($tRect, "Top") + 1, $hIcon, 16, 16)
;~                                  DllStructSetData($tRect, "Left", DllStructGetData($tRect, "Left") + 6 + 18)
;~                              EndIf
                                If $iSubitem = 0 Then
                                    _GUICtrlListView_SetItemImage($hListView, $iItem, 10, 0)
                                Else
                                    _WinAPI_DrawIconEx($hDC, DllStructGetData($tRect, "Left"), DllStructGetData($tRect, "Top") + 1, $hIcon, 16, 16)
                                    DllStructSetData($tRect, "Left", DllStructGetData($tRect, "Left") + 6 + 18)
                                EndIf

                                _GUIImageList_DestroyIcon($hIcon)
                                _WinAPI_DrawText($hDC, $sText, $tRect, BitOR($DT_VCENTER, $DT_END_ELLIPSIS, $DT_SINGLELINE))

                                _WinAPI_ReleaseDC($hWndFrom, $hDC)

                                Return $CDRF_SKIPDEFAULT ; Don't do default processing

                            EndIf
                            _GUICtrlListView_SetItemImage($hListView, $iItem, 10, 0)

                            Return $CDRF_NEWFONT ; Let the system do the drawing for non-selected items
                        Case BitOR($CDDS_ITEMPOSTPAINT, $CDDS_SUBITEM)
                            ; Not handled
                    EndSwitch

                Case $NM_CLICK

                    Local $tINFO = DllStructCreate($tagNMITEMACTIVATE, $lParam)
                    Local $iItem = DllStructGetData($tINFO, "Index")
                    Local $iSubitem = DllStructGetData($tINFO, "SubItem")
                    _GUICtrlListView_SetItemImage($hListView, $iItem, Not _GUICtrlListView_GetItemImage($hListView, $iItem, $iSubitem), $iSubitem)

            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY


; Based on File to Base64 String Code Generator
; by UEZ
; http://www.autoitscript.com/forum/topic/134350-file-to-base64-string-code-generator-v103-build-2011-11-21/

;======================================================================================
; Function Name:        Load_BMP_From_Mem
; Description:          Loads an image which is saved as a binary string and converts it to a bitmap or hbitmap
;
; Parameters:           $bImage:    the binary string which contains any valid image which is supported by GDI+
; Optional:             $hHBITMAP:  if false a bitmap will be created, if true a hbitmap will be created
;
; Remark:               hbitmap format is used generally for GUI internal images, $bitmap is more a GDI+ image format
;                       Don't forget _GDIPlus_Startup() and _GDIPlus_Shutdown()
;
; Requirement(s):       GDIPlus.au3, Memory.au3 and _GDIPlus_BitmapCreateDIBFromBitmap() from WinAPIEx.au3
; Return Value(s):      Success: handle to bitmap (GDI+ bitmap format) or hbitmap (WinAPI bitmap format),
;                       Error: 0
; Error codes:          1: $bImage is not a binary string
;                       2: unable to create stream on HGlobal
;                       3: unable to create bitmap from stream
;
; Author(s):            UEZ
; Additional Code:      thanks to progandy for the MemGlobalAlloc and tVARIANT lines and
;                       Yashied for _GDIPlus_BitmapCreateDIBFromBitmap() from WinAPIEx.au3
; Version:              v0.97 Build 2012-01-04 Beta
;=======================================================================================
Func _Load_BMP_From_Mem($bImage, $hHBITMAP = False)
    If Not IsBinary($bImage) Then Return SetError(1, 0, 0)
    Local $aResult
    Local Const $memBitmap = Binary($bImage) ;load image  saved in variable (memory) and convert it to binary
    Local Const $len = BinaryLen($memBitmap) ;get length of image
    Local Const $hData = _MemGlobalAlloc($len, $GMEM_MOVEABLE) ;allocates movable memory  ($GMEM_MOVEABLE = 0x0002)
    Local Const $pData = _MemGlobalLock($hData) ;translate the handle into a pointer
    Local $tMem = DllStructCreate("byte[" & $len & "]", $pData) ;create struct
    DllStructSetData($tMem, 1, $memBitmap) ;fill struct with image data
    _MemGlobalUnlock($hData) ;decrements the lock count  associated with a memory object that was allocated with GMEM_MOVEABLE
    $aResult = DllCall("ole32.dll", "int", "CreateStreamOnHGlobal", "handle", $pData, "int", True, "ptr*", 0) ;Creates a stream object that uses an HGLOBAL memory handle to store the stream contents
    If @error Then SetError(2, 0, 0)
    Local Const $hStream = $aResult[3]
    $aResult = DllCall($__g_hGDIPDll, "uint", "GdipCreateBitmapFromStream", "ptr", $hStream, "int*", 0) ;Creates a Bitmap object based on an IStream COM interface
    If @error Then SetError(3, 0, 0)
    Local Const $hBitmap = $aResult[2]
    Local $tVARIANT = DllStructCreate("word vt;word r1;word r2;word r3;ptr data; ptr")
    DllCall("oleaut32.dll", "long", "DispCallFunc", "ptr", $hStream, "dword", 8 + 8 * @AutoItX64, _
            "dword", 4, "dword", 23, "dword", 0, "ptr", 0, "ptr", 0, "ptr", DllStructGetPtr($tVARIANT)) ;release memory from $hStream to avoid memory leak
    $tMem = 0
    $tVARIANT = 0
    If $hHBITMAP Then
        Local Const $hHBmp = _GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)
        _GDIPlus_BitmapDispose($hBitmap)
        Return $hHBmp
    EndIf
    Return $hBitmap
EndFunc   ;==>_Load_BMP_From_Mem

;~ Func _GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)
;~  Local $tBIHDR, $Ret, $tData, $pBits, $hResult = 0
;~  $Ret = DllCall($__g_hGDIPDll, 'uint', 'GdipGetImageDimension', 'ptr', $hBitmap, 'float*', 0, 'float*', 0)
;~  If (@error) Or ($Ret[0]) Then Return 0
;~  $tData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $Ret[2], $Ret[3], $GDIP_ILMREAD, $GDIP_PXF32ARGB)
;~  $pBits = DllStructGetData($tData, 'Scan0')
;~  If Not $pBits Then Return 0
;~  $tBIHDR = DllStructCreate('dword;long;long;ushort;ushort;dword;dword;long;long;dword;dword')
;~  DllStructSetData($tBIHDR, 1, DllStructGetSize($tBIHDR))
;~  DllStructSetData($tBIHDR, 2, $Ret[2])
;~  DllStructSetData($tBIHDR, 3, $Ret[3])
;~  DllStructSetData($tBIHDR, 4, 1)
;~  DllStructSetData($tBIHDR, 5, 32)
;~  DllStructSetData($tBIHDR, 6, 0)
;~  $hResult = DllCall('gdi32.dll', 'ptr', 'CreateDIBSection', 'hwnd', 0, 'ptr', DllStructGetPtr($tBIHDR), 'uint', 0, 'ptr*', 0, 'ptr', 0, 'dword', 0)
;~  If (Not @error) And ($hResult[0]) Then
;~      DllCall('gdi32.dll', 'dword', 'SetBitmapBits', 'ptr', $hResult[0], 'dword', $Ret[2] * $Ret[3] * 4, 'ptr', DllStructGetData($tData, 'Scan0'))
;~      $hResult = $hResult[0]
;~  Else
;~      $hResult = 0
;~  EndIf
;~  _GDIPlus_BitmapUnlockBits($hBitmap, $tData)
;~  Return $hResult
;~ EndFunc   ;==>_GDIPlus_BitmapCreateDIBFromBitmap

Func _Decompress_Binary_String_to_Bitmap($Base64String)
    $Base64String = Binary($Base64String)
    Local $iSize_Source = BinaryLen($Base64String)
    Local $pBuffer_Source = _WinAPI_CreateBuffer($iSize_Source)
    DllStructSetData(DllStructCreate('byte[' & $iSize_Source & ']', $pBuffer_Source), 1, $Base64String)
    Local $pBuffer_Decompress = _WinAPI_CreateBuffer(8388608)
    Local $Size_Decompressed = _WinAPI_DecompressBuffer($pBuffer_Decompress, 8388608, $pBuffer_Source, $iSize_Source)
    Local $b_Result = Binary(DllStructGetData(DllStructCreate('byte[' & $Size_Decompressed & ']', $pBuffer_Decompress), 1))
    _WinAPI_FreeMemory($pBuffer_Source)
    _WinAPI_FreeMemory($pBuffer_Decompress)
    Return $b_Result
EndFunc   ;==>_Decompress_Binary_String_to_Bitmap

Func _Icon_Image_Checkbox_Unchecked()
    Local $Base64String
    $Base64String &= '7rBIAAABABAQEAFwCAAAaAUAABYAAMwAKAAYAJAAIAAYAVwZAQBAAQIYDgCAgAAAANfc3ADZ3t4AANvg4ADe4uIAAOLl5QDl6OgAAOns7ADs7+8AAO/x8QDx8/MAAPT19QD29/cAAPj5+QD6+/sAAPz9/QD+/v7wAP///xNc/wB/AD8A/z8APwA/AD8APwA/AD8ACAAb4HYLAAEJAOEBCgsMAA0ODxAREhISbeIBCQcC4gEIBwLiAQfbBwLiAQYHAuIBBQcC4gG2BAcC4gEDBwLiAQIHAv/jAQcC5AEGAuIB7BceAOCfHgN/AG0A4QZhAA=='
    Return _Decompress_Binary_String_to_Bitmap(_Base64Decode($Base64String))
EndFunc   ;==>_Icon_Image_Checkbox_Unchecked


Func _Icon_Image_Checkbox_Checked()
    Local $Base64String
    ;$Base64String &= 'z7BIAAABABAQEAFwCAAAaAUAABYAAMwAKAAYAJAAIAAYAVwZAQBAAQIYDgCAgAAAAISEhADe3t5AAN7n5wDnAQbvCO8A7wEG9/cA9/EABv///xN4/wE/AD8A/z8APwA/AD8AHwAMAOB6CwAGAQkA4QEHCAkJCR4KAgDjAQcC5AEHCAKDAwLiAQYHBwICAwI54gEFBsABAwLjAQUCxgIkBOIBBAUCRQbjAVgEBQUCAuQBAwUCCPPkAQUCBwjkAQYC4gHsF3seAOCfA38AbQDhBmEA'
    $Base64String &= 'YbJIAAABABAQEAFwIAAAaAQAABYAAHwAKAAYAJAAiAO4FQD/hP//SgYAAPHsAAOrAAgFA+8EA+0BA+0bOwD17Bog9f88TAD5/zpJ+P84RwD4/zVF+P80QwD3/zJC9/8UGwkBT+3oEzv37B0jAPn/RFP6/yQpAPn/EhL3/w8PAPb/DAz1/wkJgPX/Fhv1/zOAIwGRIQAA+ewfJfoA/0pY+/9CR/sA/8nJ/f87O/kA/xMT9/8QEPYA/zMz9//Fxf2A/zA19/80RIEhAvKKIQAA+/9PXQD9/zI3+//LywD+//Ly///r6wL+giE5Ofj/6uog/v/x8f6CIRgdD4AngEOBiYcf/f9SXwD9/ygo/P9HR2D8/+zs/4IhgQPsCuyBHf+CITQ09/8YCwv1gomNH1Vi/gD/LCz9/ykp/OD/SEj8/0FawRDDEZD+/zo6x0Q4SMEPAwAVyA9XZP7/MDAA/f8tLf3/S0sBzQ///z09+f8WJBb4wkQ8S80P//8IWmf+wEn+/1BQ4v3CDvPz/8IBxRHBIAA+Pvr/Fxf4/wg/TvnOD1to//9AQ0f+/8/Pxw5MIEz8/0pKx0PKygD+/yov+v9CUQ76AA0ACccP6yYr/wD/XWr//1hb/wHCEFJS/v8vL/0DwkTBM8zM/v9ITMD7/0lX+//BicCaRuvLgMcQQ0f/wFr+iP8yMsdEODz8wHg8/P/BicCayg7NEFxpA8MzwURYZf7/VmMA/v9UYf7/Iifa/AAJ+0Ay2cD/wM8BAj3FAP3JAEBC/+hrAAAAAPAPAADgBwAAwMADAACAAXsAYQQHYQVhBmEH'
    Return _Decompress_Binary_String_to_Bitmap(_Base64Decode($Base64String))
EndFunc   ;==>_Icon_Image_Checkbox_Checked

Func _Base64Decode($input_string)
    Local $struct = DllStructCreate("int")
    Local $a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", "str", $input_string, "int", 0, "int", 1, "ptr", 0, "ptr", DllStructGetPtr($struct, 1), "ptr", 0, "ptr", 0)
    If @error Or Not $a_Call[0] Then Return SetError(1, 0, "")
    Local $a = DllStructCreate("byte[" & DllStructGetData($struct, 1) & "]")
    $a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", "str", $input_string, "int", 0, "int", 1, "ptr", DllStructGetPtr($a), "ptr", DllStructGetPtr($struct, 1), "ptr", 0, "ptr", 0)
    If @error Or Not $a_Call[0] Then Return SetError(2, 0, "")
    Return DllStructGetData($a, 1)
EndFunc   ;==>_Base64Decode