-- skillwithgesture
local addonName = "SKILLWITHGESTURE"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
local json = require "json_imc"
local libsearch
libsearch=libsearch or LIBITEMSEARCHER_V1_0 --dummy


g.version = 1
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "skillwithgesture"
g.debug = false
g.currentskill=nil
--ライブラリ読み込み
CHAT_SYSTEM("[SWG]loaded")
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
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
local function AUTO_CAST(ctrl)
    if (ctrl == nil) then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
    return ctrl;
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

function SKILLWITHGESTURE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            SKILLWITHGESTURE_LOAD_SETTINGS()
            acutil.slashCommand("/swgc", SKILLWITHGESTURECONFIG_PROCESS_COMMAND);
            addon:RegisterMsg('CAST_BEGIN', 'SKILLWITHGESTURE_CASTINGBAR_ON_MSG');
            
            addon:RegisterMsg('CAST_END', 'SKILLWITHGESTURE_CASTINGBAR_ON_MSG');
            
            -- 다이나믹 캐스팅바 (스킬키 누르고있는 상태에서만 게이지증가. 스킬키때면 스킬시전)
            addon:RegisterMsg('DYNAMIC_CAST_BEGIN', 'SKILLWITHGESTURE_CASTINGBAR_ON_MSG');
            addon:RegisterMsg('DYNAMIC_CAST_END', 'SKILLWITHGESTURE_CASTINGBAR_ON_MSG');

            local timer=frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript("SKILLWITHGESTURE_ON_TIMER")
            timer:Start(0.00)
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURECONFIG_DEBUG()
    dofile([[\\Mac\Home\E\TosProject\TosAddons\skillwithgesture\src\addon_d.ipf\skillwithgesture\skillwithgesture.lua]])
    dofile([[\\Mac\Home\E\TosProject\TosAddons\skillwithgesture\src\addon_d.ipf\skillwithgestureconfig\skillwithgestureconfig.lua]])
    
end
function SKILLWITHGESTURE_SAVE_SETTINGS()
    DBGOUT("SAVE_SETTINGS")

    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(session.GetMySession():GetCID()))
    DBGOUT("psn" .. g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

function SKILLWITHGESTURE_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTINGS " .. tostring(session.GetMySession():GetCID()))
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    DBGOUT("LOAD_PSETTINGS " .. g.personalsettingsFileLoc)
    g.personalsettings = {}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings = {}
    
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = 0
        end
    end
 
end
function SKILLWITHGESTURECONFIG_PROCESS_COMMAND(command)
    local cmd = "";
    
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        
    end
    
    if cmd == "toggle" then
    end
    SKILLWITHGESTURECONFIG_SHOW()
end
function SKILLWITHGESTURE_CASTINGBAR_ON_MSG(frame, msg, argStr, argNum)
    local sklObj = GetSkill(GetMyPCObject(), argStr);
    EBI_try_catch{
        try = function()
            local myActor = GetMyActor();
            -- prevent use in pvp area
            if(UI_CHECK_NOT_PVP_MAP()==0)then 
                return;
            end
            if(msg=="CAST_BEGIN")or(msg=="DYNAMIC_CAST_BEGIN") then 
                
                local sklObj = GetSkill(GetMyPCObject(), argStr);
                local skillID=sklObj.ClassID
                if g.currentskill~=skillID then
                    g.currentskill=skillID
                    print('pose')
                    for k,v in ipairs(g.personalsettings.config) do
                        if v.skill==skillID then
                            --attempt gesture
                            local poseCls = GetClassByType('Pose', v.gesture);
                            if poseCls ~= nil then
                                local visible = 1;
                                if IS_MACRO_UNVISIBLE_WEAPON_POSE(poseCls.ClassName) == true then
                                    visible = 0;
                                end
                                control.Pose(poseCls.ClassName, 0, 0, visible);
                            end
                        end
                    end
                end
            
            elseif (msg=="CAST_END") or(msg=="DYNAMIC_CAST_END")then 
                g.currentskill=nil
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLWITHGESTURE_ON_TIMER()
    
end