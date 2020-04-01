; modified by fisofo
; Last Modified: Jan 20, 2007

Global Const $DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = 0x00000001
Global Const $DISPLAY_DEVICE_MULTI_DRIVER        = 0x00000002
Global Const $DISPLAY_DEVICE_PRIMARY_DEVICE      = 0x00000004
Global Const $DISPLAY_DEVICE_MIRRORING_DRIVER      = 0x00000008

Global Const $DISPLAY_DEVICE_ACTIVE              = 0x00000001
Global Const $DISPLAY_DEVICE_ATTACHED              = 0x00000002

Global Const $ENUM_CURRENT_SETTINGS = -1
Global Const $ENUM_REGISTRY_SETTINGS = -2

Global Const $MONITORINFO = "int;int[4];int[4];int"
Global Const $RECT = "long;long;long;long"
Global Const $DEVMODE = "byte[32];short;short;short;short;int;int[2];int;int" & _
        ";short;short;short;short;short;byte[32]" & _
        ";short;ushort;int;int;int;int"
Global Const $POINTL = "long;long"
Global Const $DISPLAY_DEVICE = "int;char[32];char[128];int;char[128];char[128]"

MonitoInfo()

Func MonitoInfo()
    Dim $MonitorPos[1][5]
    $dev = 0
    $id = 0
    $dll = DllOpen("user32.dll")
    $msg = ""
    
    Dim $dd = DllStructCreate($DISPLAY_DEVICE)
    DllStructSetData($dd, 1, DllStructGetSize($dd))
    
    $EnumDisplays = DllCall($dll, "int", "EnumDisplayDevices", _
            "ptr", 0, _
            "int", $dev, _
            "ptr", DllStructGetPtr($dd), _
            "int", 0)
    $StateFlag = Number(StringMid(Hex(DllStructGetData($dd, 4)), 3))
    While $EnumDisplays[0] <> 0
        If ($StateFlag <> $DISPLAY_DEVICE_MIRRORING_DRIVER) And ($StateFlag <> 0) Then ;ignore virtual mirror displays
            
            ;get information about the display's position and the current display mode
            Dim $dm = DllStructCreate($DEVMODE)
            DllStructSetData($dm, 4, DllStructGetSize($dm))
            $EnumDisplaysEx = DllCall($dll, "int", "EnumDisplaySettingsEx", _
                    "str", DllStructGetData($dd, 2), _
                    "int", $ENUM_CURRENT_SETTINGS, _
                    "ptr", DllStructGetPtr($dm), _
                    "int", 0)
            If $EnumDisplaysEx[0] = 0 Then
                DllCall($dll, "int", "EnumDisplaySettingsEx", _
                        "str", DllStructGetData($dd, 2), _
                        "int", $ENUM_REGISTRY_SETTINGS, _
                        "ptr", DllStructGetPtr($dm), _
                        "int", 0)
            EndIf
            
            ;get the monitor handle and workspace
            Dim $hm
            Dim $mi = DllStructCreate($MONITORINFO)
            DllStructSetData($mi, 1, DllStructGetSize($mi))
            If Mod($StateFlag, 2) <> 0 Then ; $DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
                ;display is enabled. only enabled displays have a monitor handle
                $hm = DllCall($dll, "hwnd", "MonitorFromPoint", _
                        "int", DllStructGetData($dm, 7, 1), _
                        "int", DllStructGetData($dm, 7, 2), _
                        "int", 0)
                If $hm[0] <> 0 Then
                    DllCall($dll, "int", "GetMonitorInfo", _
                            "hwnd", $hm[0], _
                            "ptr", DllStructGetPtr($mi))
                EndIf
            EndIf

            ;format information about this monitor
            If $hm[0] <> 0 Then
                $id += 1
                ReDim $MonitorPos[$id+1][5]
                $MonitorPos[$id][0] = $hm[0]
                $MonitorPos[$id][1] = DllStructGetData($mi, 3, 1)
                $MonitorPos[$id][2] = DllStructGetData($mi, 3, 2)
                $MonitorPos[$id][3] = DllStructGetData($mi, 3, 3)
                $MonitorPos[$id][4] = DllStructGetData($mi, 3, 4)
                ;workspace and monitor handle
                
                ;workspace: x,y - x,y HMONITOR: handle
                $msg &= "workspace:" & $hm[0] & ": " & _
                        DllStructGetData($mi, 3, 1) & "," & _
                        DllStructGetData($mi, 3, 2) & " to " & _
                        DllStructGetData($mi, 3, 3) & "," & _
                        DllStructGetData($mi, 3, 4) & Chr(13)
            EndIf
        EndIf

        $dev += 1
        
        $EnumDisplays = DllCall($dll, "int", "EnumDisplayDevices", _
                "ptr", 0, _
                "int", $dev, _
                "ptr", DllStructGetPtr($dd), _
                "int", 0)
        $StateFlag = Number(StringMid(Hex(DllStructGetData($dd, 4)), 3))
    WEnd
    
    $MonitorPos[0][0] = $id
    DllClose($dll)
    
    MsgBox(0,"",$msg)
    Return $MonitorPos
EndFunc