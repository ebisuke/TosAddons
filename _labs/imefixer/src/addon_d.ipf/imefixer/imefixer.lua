--imefixer
--アドオン名（大文字）
local addonName = "imefixer"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings = {x = 300, y = 300}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.scriptpath = string.format('../addons/%s/imeon.csx', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "imefixer"
g.debug = false
g.focused=false

local script=[[
using System;
using System.Runtime.InteropServices;
    [DllImport("User32.dll")]
    static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    [DllImport("imm32.dll")]
    static extern IntPtr ImmGetDefaultIMEWnd(IntPtr hWnd);
    [DllImport("user32.dll")]
    static extern bool GetGUIThreadInfo(uint dwthreadid, ref GUITHREADINFO lpguithreadinfo);
    //IME状態の取得
    GUITHREADINFO gti = new GUITHREADINFO();
    gti.cbSize = Marshal.SizeOf(gti);

    if ( !GetGUIThreadInfo(0, ref gti) ) {
        return;
    }
    IntPtr imwd = ImmGetDefaultIMEWnd(gti.hwndFocus);

    int  imeConvMode = SendMessage(imwd, WM_IME_CONTROL, (IntPtr)IMC_GETCONVERSIONMODE, IntPtr.Zero);
    bool imeEnabled = (SendMessage(imwd, WM_IME_CONTROL, (IntPtr)IMC_GETOPENSTATUS, IntPtr.Zero) != 0);

    Console.WriteLine(imeEnabled.ToString() + " status code:"+imeConvMode.ToString());

    if ( imeEnabled ) {
        switch ( imeConvMode ) {
        case CMode_Hiragana:
            /* Nothing to do */
            break;
        case CMode_HankakuKana: /* through */
        case CMode_ZenkakuEisu: /* through */
        case CMode_ZenkakuKana:
            SendMessage(imwd, WM_IME_CONTROL, (IntPtr)IMC_SETCONVERSIONMODE, (IntPtr)CMode_Hiragana); // ひらがなモードに設定
            break;
        default:
            /* Nothing to do */
            /* 環境によっては上のcaseをやめてここに飛ばしたほうがよいかも */
            break;
        }
    }/* else 無変換(半角英数) */
]]

--ライブラリ読み込み
CHAT_SYSTEM("[IMEFIXER]loaded")
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end


local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end


function IMEFIXER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('FPS_UPDATE', 'IMEFIXER_FPS_UPDATE');
            local timer=frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('IMEFIXER_ON_TIMER')
            timer:Start(0.1)
            timer:EnableHideUpdate(1)
            io.open(g.scriptpath,"w");
            io.write(script)
            io.flush()
            io.close()
            g.focused=nil

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function IMEFIXER_FPS_UPDATE()
    ui.GetFrame(g.framename):ShowWindow(1)
end 
function IMEFIXER_ON_TIMER()
    local focus=ui.GetFocusObject()
    if focus:GetClassString()=='ui::CEditControl' then
        if g.focused==nil then
            g.focused=focus
            CHAT_SYSTEM('OK')
            debug.ShellExecute("dotnet "..g.scriptpath)
        end
    else
        g.focused=nil
    end

    
end
