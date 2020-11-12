-- bypassdialogassisterdungeon
--アドオン名（大文字）
local addonName = 'bypassdialogassisterdungeon'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'bypassdialogassisterdungeon'
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM('[PDD]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function BYPASSDIALOGASSISTERDUNGEON_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(ADVANCEDASSISTERMANAGER_GETCID()))
            frame:ShowWindow(0)
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end

            addon:RegisterMsg('GAME_START_3SEC', 'BYPASSDIALOGASSISTERDUNGEON_3SEC')
           
            

           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function BYPASSDIALOGASSISTERDUNGEON_3SEC(frame)
    local mapName = session.GetMapName();
    if  mapName=='d_solo_dungeon_2'  then
        ui.SysMsg('BypassDialogAssisterDungeon is active')
        local timer=frame:GetChild('addontimer')
        AUTO_CAST(timer)
        timer:EnableHideUpdate(1)
        timer:SetUpdateScript('BYPASSDIALOGASSISTERDUNGEON_ON_TIMER')
        timer:Start(0.1)
        frame:ShowWindow(1)
        
    end
end
function BYPASSDIALOGASSISTERDUNGEON_ON_TIMER()
   
    if ui.GetFrame('dialogillust'):IsVisible()==1 then 
        if ui.GetFrame('dialogselect'):IsVisible()==1 then 
            DBGOUT('perk')
            control.DialogOk()
        else
            DBGOUT('poke')
            control.DialogOk();
        end
    end
end
