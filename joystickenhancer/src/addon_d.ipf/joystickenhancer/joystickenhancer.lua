--joystickenhancer
--アドオン名（大文字）
local addonName = "joystickenhancer"
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
g.personalsettingsFileLoc = ""
g.framename = "joystickenhancer"
g.debug = false
g.sys={
    uimodecount=0,
    uimodevisibles={
       
    },
    uimodetriggers={
        "worldmap2_mainmap",
        "worldmap2_submap",
        "skillability",
    }
}

--ライブラリ読み込み
CHAT_SYSTEM("[JE]loaded")
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

local function IsUIMode()
    return ui.GetFrame('modenotice'):IsVisible()==1
end
local function SetPseudoUIMode(mode)
    
    joystick.ToggleMouseMode()
    
end

function JOYSTICKENHANCER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('FPS_UPDATE', 'JOYSTICKENHANCER_FPS_UPDATE');
            local timer=frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('JOYSTICKENHANCER_ON_TIMER')
            timer:Start(0.01)
            timer:EnableHideUpdate(1)
            g.sys.uimodevisibles={}
            g.sys.uimodecount=0
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function JOYSTICKENHANCER_FPS_UPDATE()
    ui.GetFrame(g.framename):ShowWindow(1)
end 
function JOYSTICKENHANCER_ON_TIMER()
    if IsJoyStickMode() == 0 then
        return
    end
    --ui.SysMsg('CHAT')
    for _,k in ipairs(g.sys.uimodetriggers) do
     
        if ui.GetFrame(k):IsVisible()==1 and not g.sys.uimodevisibles[k] then
            g.sys.uimodevisibles[k]=true
            g.sys.uimodecount=g.sys.uimodecount+1
            if g.sys.uimodecount==1 then
                SetKeyboardSelectMode(1)
                CHAT_SYSTEM("setvbuf")
            end
        end
        if ui.GetFrame(k):IsVisible()==0 and g.sys.uimodevisibles[k] then
            g.sys.uimodevisibles[k]=nil
            g.sys.uimodecount=g.sys.uimodecount-1
            if g.sys.uimodecount==0 then
                SetKeyboardSelectMode(0)
                CHAT_SYSTEM("reset")
            end
        end
    end
end
