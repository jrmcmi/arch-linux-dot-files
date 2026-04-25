#Requires AutoHotkey v2.0
#SingleInstance Force

; --- 1. THE "LINUX-STYLE" FILTER ---
; Prevents the script from accidentally maximizing/minimizing the Taskbar or Desktop
IsRealWindow(hwnd) {
    if (!hwnd)
        return false
    
    winClass := WinGetClass("ahk_id " hwnd)
    
    if (winClass ~= "i)Shell_TrayWnd|WorkerW|Progman|ComboLBox|Windows.UI.Core.CoreWindow|Shell_SecondaryTrayWnd")
        return false
        
    return true
}

; Fullscreen Detection for Games (Shortcuts disabled when in a game)
IsLockedFullscreen() {
    try {
        if !WinActive("A") 
            return false
        if (!IsRealWindow(WinExist("A")))
            return false
        style := WinGetStyle("A")
        WinGetPos(,, &w, &h, "A")
        if !(style & 0x00C00000) && (w >= A_ScreenWidth && h >= A_ScreenHeight)
            return true
    }
    return false
}

; --- 2. KEYBOARD SHORTCUTS (KDE/ROFI STYLE) ---
#HotIf !IsLockedFullscreen()

; Win + Enter: App Launcher (Search Apps Only)
$#Enter:: {
    Send "#s"
    if WinWaitActive("ahk_class Windows.UI.Core.CoreWindow",, 1) || WinWaitActive("ahk_class CortanaMainFrame",, 1) {
        Sleep 50
        Send "apps: "
    }
}

; Win + 2: Terminal Placeholder
$#2:: {
    try {
        ; Example: Run "wt.exe" 
        return
    }
}

; Win + F: Toggle Maximize
$#f:: {
    hwnd := WinExist("A")
    if (!IsRealWindow(hwnd))
        return

    state := WinGetMinMax("ahk_id " hwnd)
    if (state = 1)
        WinRestore("ahk_id " hwnd)
    else
        WinMaximize("ahk_id " hwnd)
}

; Win + Esc: Task Manager
$#Esc::Run "taskmgr.exe"

; Win + X: Minimize
$#x:: {
    hwnd := WinExist("A")
    if (IsRealWindow(hwnd))
        WinMinimize("ahk_id " hwnd)
}

; Win + Z: Close (Overrides Windows Snap Menu)
$#z:: {
    hwnd := WinExist("A")
    if (IsRealWindow(hwnd))
        WinClose("ahk_id " hwnd)
}

; Explicitly disable native Search/Widgets to keep keys free for AHK
#s::return
#w::return

#HotIf

; --- 3. THE START MENU KILLER ---
; Traces every press and release to ensure the lone Win-key does nothing.

~LWin::
~RWin:: {
    Send "{Blind}{vkE8}" ; Send unassigned dummy key to suppress Start Menu popup
}

; These block the 'Release' event which is what Windows uses to trigger the Start Menu.
$LWin Up:: {
    if (A_PriorKey = "LWin")
        return ; "Sink" the keypress - do nothing.
    else
        Send "{LWin Up}"
}

$RWin Up:: {
    if (A_PriorKey = "RWin")
        return ; "Sink" the keypress - do nothing.
    else
        Send "{RWin Up}"
}