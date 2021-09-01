-- DISABLEMAGICSHIELD
--アドオン名（大文字）
local addonName = 'DISABLEMAGICSHIELD'
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
g.framename = 'disablemagicshield'
g.debug = false
local removeid=67

--ライブラリ読み込み
CHAT_SYSTEM('[DMS]loaded')
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
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end
function DISABLEMAGICSHIELD_SAVE_SETTINGS()
    --DISABLEMAGICSHIELD_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end
function DISABLEMAGICSHIELD_SAVE_ALL()

    DISABLEMAGICSHIELD_SAVE_SETTINGS()

end

function DISABLEMAGICSHIELD_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {foods = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    DBGOUT("LOAD_PSETTINGS "..g.personalsettingsFileLoc)
    g.personalsettings={disable=false}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings=  {disable=false}
        
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
      
    end
    
    DISABLEMAGICSHIELD_SAVE_SETTINGS()
   
end



function DISABLEMAGICSHIELD_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function DISABLEMAGICSHIELD_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,session.GetMySession():GetCID())
            frame:ShowWindow(0)
            addon:RegisterMsg('BUFF_ADD', 'DISABLEMAGICSHIELD_BUFF_ON_MSG');
            addon:RegisterMsg('BUFF_UPDATE', 'DISABLEMAGICSHIELD_BUFF_ON_MSG');
            acutil.slashCommand("/dms", DISABLEMAGICSHIELD_PROCESS_COMMAND);
            acutil.slashCommand("/disablemagicshield", DISABLEMAGICSHIELD_PROCESS_COMMAND);
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end

            frame:ShowWindow(0)

            DISABLEMAGICSHIELD_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DISABLEMAGICSHIELD_REMOVECURRENT()
    local targetBuffID
    local handle = session.GetMyHandle();
    for i = 0, info.GetBuffCount(handle) - 1 do
        if removeid == info.GetBuffIndexed(handle, i).buffID then
            packet.ReqRemoveBuff(removeid);
        end
    end
end
function DISABLEMAGICSHIELD_PROCESS_COMMAND(command)
    EBI_try_catch {
        try = function()
            local cmd = "";
        
            if #command > 0 then
                cmd = table.remove(command, 1);
            else
                local msg = "usage{nl}/dms on 自動解除有効化 {nl}/dms off 自動解除無効化(デフォルト) {nl}/dms toggle トグル"
                return ui.MsgBox(msg,"","Nope")
            end
        
            if cmd == "on" then
            --有効
                g.personalsettings.disable=true
                CHAT_SYSTEM("[DMS]マジックシールドバフ自動解除有効化しました");
                DISABLEMAGICSHIELD_REMOVECURRENT()
                DISABLEMAGICSHIELD_SAVE_SETTINGS()
                return;
            elseif cmd == "off" then
            --無効
                g.personalsettings.disable=false
                CHAT_SYSTEM("[DMS]マジックシールドバフ自動解除無効化しました");
                DISABLEMAGICSHIELD_SAVE_SETTINGS()
                 return;
            elseif cmd == "toggle" then
                --無効
                g.personalsettings.disable=not g.personalsettings.disable

                if g.personalsettings.disable then
                    CHAT_SYSTEM("[DMS]マジックシールドバフ自動解除有効化しました");
                    DISABLEMAGICSHIELD_SAVE_SETTINGS()
                    DISABLEMAGICSHIELD_REMOVECURRENT()
                else
                    CHAT_SYSTEM("[DMS]マジックシールドバフ自動解除無効化しました");
                    DISABLEMAGICSHIELD_SAVE_SETTINGS()
                end
                
                return;
            end
            CHAT_SYSTEM(string.format("[%s] Invalid Command", addonName));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DISABLEMAGICSHIELD_BUFF_ON_MSG(frame, msg, argStr, argNum)
    if not g.personalsettings.disable then
        return
    end
    --local buff = info.GetBuff(session.GetMyHandle(), argNum);
    if argNum==removeid then
        packet.ReqRemoveBuff(argNum);
    end
end