--joysticknextstage
--アドオン名（大文字）
local addonName = "joysticknextstage"
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
g.framename = "joysticknextstage"
g.debug = false


--ライブラリ読み込み
CHAT_SYSTEM("[JNS]loaded")
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
    return ui.GetFrame('modenotice'):IsVisible() == 1
end


function JOYSTICKNEXTSTAGE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
           
            addon:RegisterMsg('FPS_UPDATE', 'JOYSTICNEXTSTAGE_FPS_UPDATE');
          
            local timer = frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('JOYSTICKNEXTSTAGE_ON_TIMER')
            timer:Start(0.00)
            timer:EnableHideUpdate(1)
  
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function JOYSTICKNEXTSTAGE_FPS_UPDATE()
    ui.GetFrame(g.framename):ShowWindow(1)
end
function JOYSTICKNEXTSTAGE_ON_TIMER()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            g.jsnmanager.processJoystickKey()
            g.jsnmanager.processFrames()
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

