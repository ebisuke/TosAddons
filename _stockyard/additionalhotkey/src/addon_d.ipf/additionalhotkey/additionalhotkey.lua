--additionalchatmacro
--アドオン名（大文字）
local addonName = "additionalhotkey"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
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

local function startswith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
g.debug = true
g.sz={32,32}
g.framename = "additionalhotkey"
g.settings=g.settings or {
    x=200,
    y=200,
    
}
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


function ADDITIONALHOTKEY_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            g.frame = ui.GetFrame("additionalhotkey");
            frame = g.frame
            frame:ShowWindow(0)
            addon:RegisterMsg('GAME_START_3SEC', 'ADDITIONALHOTKEY_3SEC')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADDITIONALHOTKEY_INIT()
    EBI_try_catch{
        try = function()
            
            g.frame = ui.GetFrame("additionalhotkey");
            local frame = g.frame
            

        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end

function ADDITIONALHOTKEY_3SEC()
    ADDITIONALHOTKEY_INIT()
end
function ADDITIONALHOTKEY_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function ADDITIONALHOTKEY_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {x=300,y=200}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    ADDITIONALHOTKEY_UPGRADE_SETTINGS()
    ADDITIONALHOTKEY_SAVE_SETTINGS()

end


function ADDITIONALHOTKEY_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end