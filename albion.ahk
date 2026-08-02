#Requires AutoHotkey v2.0
#Warn All, Off
if not A_IsAdmin
    Run('*RunAs "' A_ScriptFullPath '"'), ExitApp()

I := A_ScriptDir "\config.ini"
T := IniRead(I, "SmartGen", "BaseText", "Гильдия Yamato Club ведет набор, 16+. Играем от Lymhurst. Прием через ДС!")
V := IniRead(I, "Settings", "Interval", "125")

global isSending := 0, ChatPrefix := "/rec ", G := 1, S := 0

; Глобальная база текстов для всех трех языков
global TxtM := ["РАБОЧАЯ ПАНЕЛЬ", "WORK PANEL", "PANEL DE TRABAJO"]
global TxtL := ["ЯЗЫК ИНТЕРФЕЙСА:", "GUI LANGUAGE:", "IDIOMA DEL GUI:"]
global TxtT1 := ["ВЫБЕРИТЕ ИГРОВОЙ КАНАЛ ДЛЯ РЕКРУТИНГА:", "SELECT GAME CHANNEL FOR RECRUITMENT:", "SELECCIONE CANAL DE RECLUTAMIENTO:"]
global TxtT2 := ["НАСТРОЙКА ТЕКСТА:", "TEXT SETTINGS:", "CONFIGURACIÓN DE TEXTO:"]
global TxtT3 := ["ЗАДЕРЖКА:", "DELAY:", "TEMPORIZADOR:"]
global TxtT4 := ["секунд", "seconds", "segundos"]
global TxtT5 := ["СТАТУС:", "STATUS:", "ESTADO:"]
global TxtOff := ["ВЫКЛЮЧЕН", "OFF", "APAGADO"], TxtOn := ["ЗАПУЩЕН", "RUNNING", "ACTIVO"]
global TxtBtnOff := ["ЗАПУСТИТЬ АВТОСПАМ  [ F4 ]", "LAUNCH AUTOSPAM  [ F4 ]", "INICIAR SPAM  [ F4 ]"]
global TxtBtnOn := ["ОСТАНОВИТЬ СЕЙЧАС  [ F4 ]", "STOP SPAMMER  [ F4 ]", "DETENER SPAMMER  [ F4 ]"]

global TxtCh1 := ["/rec (Рекрут)", "/rec (Recruit)", "/rec (Reclutar)"]
global TxtCh2 := ["/g (Гильдия)", "/g (Guild)", "/g (Gremio)"]
global TxtCh3 := ["/p (Группа)", "/p (Party)", "/p (Grupo)"]
global TxtCh4 := ["/s (Сказать)", "/s (Say)", "/s (Decir)"]
global TxtCh5 := ["/a (Альянс)", "/a (Alliance)", "/a (Alianza)"]
global TxtCh6 := ["/trade (Торговля)", "/trade (Trade)", "/trade (Comercio)"]
global TxtGenOn := ["РЕЖИМ: ГЕНЕРАТОР", "MODE: GENERATOR", "MODO: GENERADOR"]
global TxtGenOff := ["РЕЖИМ: ФИКСИРОВАННЫЙ", "MODE: FIXED", "MODO: FIJO"]

W := Gui("-Theme", "Albion Smart Core [v2]")
W.BackColor := "140E0A"
W.SetFont("s11 Bold cFFF0B3", "Cinzel")

global MB := W.Add("GroupBox", "x10 y15 w540 h385 c8A6A41", "РАБОЧАЯ ПАНЕЛЬ")
W.SetFont("s9 Bold cFFE680", "Georgia")
global LT := W.Add("Text", "x25 y36 w140", "ЯЗЫК ИНТЕРФЕЙСА:")

global L1 := W.Add("Radio", "x170 y34 w75 h20 Checked +Background140E0A cFFF0B3", "RUS")
global L2 := W.Add("Radio", "x250 y34 w75 h20 +Background140E0A cFFF0B3", "ENG")
global L3 := W.Add("Radio", "x330 y34 w75 h20 +Background140E0A cFFF0B3", "ESP")
L1.OnEvent("Click", ApplyLang), L2.OnEvent("Click", ApplyLang), L3.OnEvent("Click", ApplyLang)

W.SetFont("s10 Bold cFFE680", "Georgia")
global MainT1 := W.Add("Text", "x25 y68 w510", "ВЫБЕРИТЕ ИГРОВОЙ КАНАЛ ДЛЯ РЕКРУТИНГА:")
global R1 := W.Add("Radio", "x30 y91 w160 h20 Checked +Background140E0A cFFF0B3", "/rec (Рекрут)")
global R2 := W.Add("Radio", "x200 y91 w160 h20 +Background140E0A cFFF0B3", "/g (Гильдия)")
global R3 := W.Add("Radio", "x370 y91 w160 h20 +Background140E0A cFFF0B3", "/p (Группа)")
global R4 := W.Add("Radio", "x30 y116 w160 h20 +Background140E0A cFFF0B3", "/s (Сказать)")
global R5 := W.Add("Radio", "x200 y116 w160 h20 +Background140E0A cFFF0B3", "/a (Альянс)")
global R6 := W.Add("Radio", "x370 y116 w160 h20 +Background140E0A cFFF0B3", "/trade (Торговля)")

global MainT2 := W.Add("Text", "x25 y146 w180", "НАСТРОЙКА ТЕКСТА:")
global GenBtn := W.Add("Button", "x325 y139 w210 h26 +Background201812 cFFE680", "РЕЖИМ: ГЕНЕРАТОР")
GenBtn.OnEvent("Click", ToggleGenMode)
global CT := W.Add("Text", "x230 y146 w85 Right +BackgroundTrans", "(0 / 130)")

W.SetFont("s11 Norm cFFFFFF", "Georgia")
global ED := W.Add("Edit", "x25 y170 w510 h120 +Multi +Background251B13 Limit130", T)
ED.OnEvent("Change", (*) => (CT.Text:="(" . StrLen(ED.Value) . " / 130)"))

W.SetFont("s11 Bold c000000", "Georgia")
W.Add("Text", "x27 y317 +BackgroundTrans w110", "ЗАДЕРЖКА:")
W.SetFont("s11 Bold cFFF0B3", "Georgia")
global MT3 := W.Add("Text", "x25 y315 +BackgroundTrans w110", "ЗАДЕРЖКА:")

W.SetFont("s13 Bold c000000")
W.Add("Text", "x147 y316 w65 h24 Center +BackgroundTrans", "888")
W.SetFont("s11 Bold cFFFFFF", "Georgia")
global IntervalNum := W.Add("Edit", "x145 y314 w65 h24 Center +Background251B13", V)

global MT4 := W.Add("Text", "x215 y315 w65 cFFF0B3", "секунд")

W.SetFont("s11 Bold c000000", "Georgia")
W.Add("Text", "x287 y317 +BackgroundTrans w75", "СТАТУС:")
W.SetFont("s11 Bold cFFE680", "Georgia")
global MT5 := W.Add("Text", "x285 y315 +BackgroundTrans w75", "СТАТУС:")

W.SetFont("s11 Bold c1A0303", "Georgia")
global SS := W.Add("Text", "x367 y317 w150 +BackgroundTrans", "ВЫКЛЮЧЕН")
W.SetFont("s11 Bold cFF4D4D", "Georgia")
global ST := W.Add("Text", "x365 y315 w150 +BackgroundTrans", "ВЫКЛЮЧЕН")

W.SetFont("s11 Bold cFFE680", "Cinzel")
global LB := W.Add("Button", "x25 y345 w510 h36 +Background201812", "ЗАПУСТИТЬ АВТОСПАМ  [ F4 ]")
LB.OnEvent("Click", TGB)

ApplyLang()
CT.Text := "(" . StrLen(ED.Value) . " / 130)"
W.OnEvent("Close", (*) => ExitApp())
W.Show("w560 h415")
return

ToggleGenMode(*) {
    global G := !G
    ApplyLang()
}

ApplyLang(*) {
    global S, G, MB, LT, MainT1, MainT2, GenBtn, MT3, MT4, MT5, SS, ST, LB, R1, R2, R3, R4, R5, R6
    idx := L2.Value ? 2 : (L3.Value ? 3 : 1)
    
    MB.Text := TxtM[idx]
    LT.Text := TxtL[idx]
    MainT1.Text := TxtT1[idx]
    MainT2.Text := TxtT2[idx]
    MT3.Text := TxtT3[idx]
    MT4.Text := TxtT4[idx]
    MT5.Text := TxtT5[idx]
    
    status_str := S ? TxtOn[idx] : TxtOff[idx]
    SS.Text := status_str
    ST.Text := status_str
    
    LB.Text := S ? TxtBtnOn[idx] : TxtBtnOff[idx]
    GenBtn.Text := G ? TxtGenOn[idx] : TxtGenOff[idx]
    
    R1.Text := TxtCh1[idx]
    R2.Text := TxtCh2[idx]
    R3.Text := TxtCh3[idx]
    R4.Text := TxtCh4[idx]
    R5.Text := TxtCh5[idx]
    R6.Text := TxtCh6[idx]
}

TGB(*) {
    global S := !S, BaseTextVal, ChatPrefix
    if (!S) {
        SetTimer(SM, 0)
        SoundBeep(400, 150)
        ST.Opt("cFF4D4D"), SS.Opt("c1A0303")
        ApplyLang()
        return
    }
    BaseTextVal := ED.Value
    IniWrite(BaseTextVal, I, "SmartGen", "BaseText")
    IniWrite(IntervalNum.Value, I, "Settings", "Interval")
    
    ChatPrefix := R2.Value ? "/g " : R3.Value ? "/p " : R4.Value ? "/s " : R5.Value ? "/a " : R6.Value ? "/trade " : "/rec "
        
    ST.Opt("c5CB85C"), SS.Opt("c052109")
    ApplyLang()
    
    SetTimer(SM, Integer(IntervalNum.Value) * 1000)
    SM()
}

SM() {
    global S, BaseTextVal, ChatPrefix, G
    if (!S or !WinExist("Ahk_exe Albion-Online.exe"))
        return
    WinActivate("Ahk_exe Albion-Online.exe")
    WinWaitActive("Ahk_exe Albion-Online.exe", , 2)
    Sleep(200)
    m := ED.Value
    if (StrLen(m) > 138)
        m := SubStr(m, 1, 138)
    if (G) {
        punct := Random(1, 3)
        m := (punct==2)?StrReplace(m, ".", "! "):(punct==3)?StrReplace(m, ",", " |"):m
        Loop StrLen(m) {
            char := SubStr(m, A_Index, 1)
            r := Random(1, 4)
            if (r == 1) { 
                m := (char=="о")?SubStr(m,1,A_Index-1) "o" SubStr(m,A_Index+1) : (char=="а")?SubStr(m,1,A_Index-1) "a" SubStr(m,A_Index+1) : (char=="е")?SubStr(m,1,A_Index-1) "e" SubStr(m,A_Index+1) : (char=="с")?SubStr(m,1,A_Index-1) "c" SubStr(m,A_Index+1) : (char=="р")?SubStr(m,1,A_Index-1) "p" SubStr(m,A_Index+1) : (char=="х")?SubStr(m,1,A_Index-1) "x" SubStr(m,A_Index+1) : (char=="o")?SubStr(m,1,A_Index-1) "о" SubStr(m,A_Index+1) : (char=="a")?SubStr(m,1,A_Index-1) "а" SubStr(m,A_Index+1) : (char=="e")?SubStr(m,1,A_Index-1) "е" SubStr(m,A_Index+1) : (char=="c")?SubStr(m,1,A_Index-1) "с" SubStr(m,A_Index+1) : (char=="p")?SubStr(m,1,A_Index-1) "р" SubStr(m,A_Index+1) : (char=="x")?SubStr(m,1,A_Index-1) "х" SubStr(m,A_Index+1) : m
            }
        }
        rW := Random(1, 4)
        PrefixTag := (rW==1)?"[-] " :(rW==2)?"[>] " :(rW==3)?"==> " :"=> "
        m := PrefixTag . m
    }
    if (StrLen(ChatPrefix . m) > 145)
        m := SubStr(m, 1, 135)
    c := ClipboardAll()
    A_Clipboard := ""
    A_Clipboard := ChatPrefix . m
    ClipWait(1)
    Send("{Enter}"), Sleep(150), Send("^a"), Sleep(50), Send("{Backspace}"), Sleep(50), Send("^v"), Sleep(200), Send("{Enter}")
    A_Clipboard := c
    SoundBeep(650, 100)
}

F4:: {
    TGB("", "")
}

