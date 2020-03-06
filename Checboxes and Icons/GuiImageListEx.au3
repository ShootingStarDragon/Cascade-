#include-once
#include <GuiImageList.au3>

Func ImageList_SetOverlayImage( $hWnd, $iImage, $iOverlay )
	Local $aResult = DllCall( "comctl32.dll", "bool", "ImageList_SetOverlayImage", "handle", $hWnd, "int", $iImage, "int", $iOverlay )
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc
