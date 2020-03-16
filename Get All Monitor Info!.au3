#include <Array.au3>
;modified by Yibing
;Last modified Feb 15, 2008
MonitoInfo()

Func MonitoInfo()
    Const $DISPLAY_DEVICE_MIRRORING_DRIVER    = 0x00000008
    Const $ENUM_CURRENT_SETTINGS = -1
    Const $DISPLAY_DEVICE = "int;char[32];char[128];int;char[128];char[128]"
    Const $DEVMODE = "byte[32];short;short;short;short;int;int[2];int;int" & _
                    ";short;short;short;short;short;byte[32]" & _
                    ";short;ushort;int;int;int;int"
                    
    Dim $MonitorPos[1][4]
    $dev = 0
    $id = 0
    $dll = DllOpen("user32.dll")
    $msg = ""

    Dim $dd = DllStructCreate($DISPLAY_DEVICE)
    DllStructSetData($dd, 1, DllStructGetSize($dd))

    Dim $dm = DllStructCreate($DEVMODE)
    DllStructSetData($dm, 4, DllStructGetSize($dm))

    Do
        $EnumDisplays = DllCall($dll, "int", "EnumDisplayDevices", _
                "ptr", "NULL", _
                "int", $dev, _
                "ptr", DllStructGetPtr($dd), _
                "int", 0)
        $StateFlag = Number(StringMid(Hex(DllStructGetData($dd, 4)), 3))
        If ($StateFlag <> $DISPLAY_DEVICE_MIRRORING_DRIVER) And ($StateFlag <> 0) Then;ignore virtual mirror displays
            $id += 1
            ReDim $MonitorPos[$id+1][5]
            $EnumDisplaysEx = DllCall($dll, "int", "EnumDisplaySettings", _
                    "str", DllStructGetData($dd, 2), _
                    "int", $ENUM_CURRENT_SETTINGS, _
                    "ptr", DllStructGetPtr($dm))
            $MonitorPos[$id][0] = DllStructGetData($dm, 7, 1)
            $MonitorPos[$id][1] = DllStructGetData($dm, 7, 2)
            $MonitorPos[$id][2] = DllStructGetData($dm, 18)
            $MonitorPos[$id][3] = DllStructGetData($dm, 19)
			;MsgBox(0,"What's dm?",$dm)
            $msg &= "Monitor " & ($id) & " start point:(" &  _
                DllStructGetData($dm, 7, 1) & "," & _
                DllStructGetData($dm, 7, 2) & ") " & @TAB & "Screen resolution: " & _
                DllStructGetData($dm, 18) & "x" & _
                DllStructGetData($dm, 19) & @LF
        EndIf
        $dev += 1
    Until $EnumDisplays[0] = 0

    $MonitorPos[0][0] = $id
    DllClose($dll)

    MsgBox(0,"Screen Info",$msg)
    return $MonitorPos

EndFunc
_ArrayDisplay(MonitoInfo())
;the info I want is x/y coords of upper left corner:
;X = [monitor # (AKA monitor 1 is 1 since 0,0 is something else)][0]
;Y = [monitor #][1]