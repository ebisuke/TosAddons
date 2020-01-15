--アドオン名（大文字）
local addonName = "enemystat"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "enemystat"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x=nil
g.y=nil
--ライブラリ読み込み
CHAT_SYSTEM("[ENEMYSTAT]loaded")
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
function ENEMYSTAT_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function ENEMYSTAT_LOAD_SETTINGS()
    ENEMYSTAT_DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ENEMYSTAT_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    ENEMYSTAT_UPGRADE_SETTINGS()
    ENEMYSTAT_SAVE_SETTINGS()

end


function ENEMYSTAT_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=ENEMYSTAT_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function ENEMYSTAT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('ENEMYSTAT', 'sysmenu_sys', 'ENEMYSTAT', 'ENEMYSTAT_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'ENEMYSTAT_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "ENEMYSTAT_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("ENEMYSTAT_ON_TIMER");
            timer:Start(0.1);
            --ENEMYSTAT_SHOW(g.frame)
            
            ENEMYSTAT_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ENEMYSTAT_ERROUT(error)
        end
    }
end
function ENEMYSTAT_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function ENEMYSTAT_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function ENEMYSTAT_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
--フレーム場所保存処理
function ENEMYSTAT_END_DRAG()
    g.settings.position= g.settings.position or {}
    g.settings.position.x = g.frame:GetX();
    g.settings.position.y = g.frame:GetY();
    ENEMYSTAT_SAVE_SETTINGS();
end
function ENEMYSTAT_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ENEMYSTAT_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
    
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
