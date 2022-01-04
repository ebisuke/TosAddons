-- hideinaccessiblekitchen
--アドオン名（大文字）
local addonName = "HIDEINACCESSIBLEKITCHEN"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.version = 0
g.settings = {intrusive = false}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "hideinaccessiblekitchen"
g.debug = false
g.intrudes = {}
g.oknext=true
CHAT_SYSTEM("[HIK]loaded")
local acutil = require("acutil")
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end

local function ebi_hook(newFunction, hookedFunctionStr)
    local storeOldFunc = hookedFunctionStr .. "_OLD_HIK";
    if _G[storeOldFunc] == nil then
        _G[storeOldFunc] = _G[hookedFunctionStr];
        _G[hookedFunctionStr] = newFunction;
    else
        _G[hookedFunctionStr] = newFunction;
    end
end

--マップ読み込み時処理（1度だけ）
function HIDEINACCESSIBLEKITCHEN_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPEXTENDER_GETCID()))
            frame:ShowWindow(1)
            ebi_hook(HIDEINACCESSIBLEKITCHEN_AUTOSELLER_BALLOON, "AUTOSELLER_BALLOON")
            acutil.slashCommand("/cfghik", HIDEINACCESSIBLEKITCHEN_PROCESS_COMMAND)
            addon:RegisterMsg("FPS_UPDATE","HIDEINACCESSIBLEKITCHEN_ON_FPS_UPDATE")
            addon:RegisterMsg("GAME_START_3SEC","HIDEINACCESSIBLEKITCHEN_GAME_START_3SEC")
            ebi_hook(HIDEINACCESSIBLEKITCHEN_OPEN_FOOD_TABLE_UI, "OPEN_FOOD_TABLE_UI")
            ebi_hook(HIDEINACCESSIBLEKITCHEN_ON_OPEN_FOOD_TABLE_UI, "ON_OPEN_FOOD_TABLE_UI")
            --addon:RegisterMsg("OPEN_FOOD_TABLE_UI", "HIDEINACCESSIBLEKITCHEN_ON_OPEN_FOOD_TABLE_UI");
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            g.intrudes={}
            HIDEINACCESSIBLEKITCHEN_LOADSETTINGS()
            --ReserveScript("HIDEINACCESSIBLEKITCHEN_CYCLE()", 1)
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HIDEINACCESSIBLEKITCHEN_ON_FPS_UPDATE()
    g.frame:ShowWindow(1)
end
function HIDEINACCESSIBLEKITCHEN_GAME_START_3SEC()
    local frame=g.frame;
    local timer=frame:GetChild("addontimer")
    AUTO_CAST(timer)
    timer:SetUpdateScript("HIDEINACCESSIBLEKITCHEN_CYCLE")
    timer:Start(0.1)
    g.oknext=true
end
function HIDEINACCESSIBLEKITCHEN_CYCLE()
    if g.oknext==false then
        return
    end
    DBGOUT("CYCLE")
    
    for handle,_ in pairs(g.intrudes) do
        if g.intrudes[handle]==1 then
            local actor = world.GetActor(handle)
            local pos = actor:GetPos()
            local dist = info.GetDestPosDistance(pos.x, pos.y, pos.z, session.GetMyHandle());
            if dist<999 then
                DBGOUT("OPEN"..handle)
                session.autoSeller.RequestOpenShop(handle, AUTO_TITLE_FOOD_TABLE);
                g.oknext=false

                break;
            end
        end
    end
    --ReserveScript("HIDEINACCESSIBLEKITCHEN_CYCLE()", 0.3)
end
--チャットコマンド処理（acutil使用時）
function HIDEINACCESSIBLEKITCHEN_PROCESS_COMMAND(command)
    local cmd = ""

    if #command > 0 then
        cmd = table.remove(command, 1)
        arg = table.remove(command, 1)
    else
        local msg = "/cfghik intrusive [on|off]"
        return ui.MsgBox(msg, "", "Nope")
    end
    if cmd == "intrusive" then
        if arg == "on" then
            --有効
            CHAT_SYSTEM("[HIK]Intrusive mode enabled")
            g.settings.intrusive = true
            HIDEINACCESSIBLEKITCHEN_SAVESETTINGS()
            return
        elseif arg == "off" then
            --無効
            CHAT_SYSTEM("[HIK]Intrusive mode disabled")
            g.settings.intrusive = false
            HIDEINACCESSIBLEKITCHEN_SAVESETTINGS()
            return
        end
    end
end

function HIDEINACCESSIBLEKITCHEN_LOADSETTINGS()
    local s, err = acutil.loadJSON(g.settingsFileLoc)
    if err then
        g.settings = {intrusive = false}
    else
        -- for k, v in pairs(default) do
        --     if s[k] == nil then
        --         settings[k] = v
        --     end
        -- end
        g.settings = s
    end
    HIDEINACCESSIBLEKITCHEN_SAVESETTINGS()
end

function HIDEINACCESSIBLEKITCHEN_SAVESETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function HIDEINACCESSIBLEKITCHEN_ON_OPEN_FOOD_TABLE_UI(frame, msg, arg_str, arg_num)
    local tableHandle = frame:GetUserValue("HANDLE");
    if g.intrudes[tableHandle] then

        return
    end
    ON_OPEN_FOOD_TABLE_UI_OLD_HIK(frame, msg, arg_str, arg_num)
end
function HIDEINACCESSIBLEKITCHEN_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)
    HIDEINACCESSIBLEKITCHEN_OPEN_FOOD_TABLE_UI_IMPL(groupName, sellType, handle, sellerCID, arg_num)
end
function HIDEINACCESSIBLEKITCHEN_OPEN_FOOD_TABLE_UI_IMPL(groupName, sellType, handle, sellerCID, arg_num)
    EBI_try_catch {
        try = function()
            local callOld = true
            local hideFrame = false
           
            
            DBGOUT("INTRUDE"..tostring(handle))
            if g.intrudes[handle]==1 then
                callOld = false
                DBGOUT("SUPPRESSED")
            end

            if callOld then
                  
                OPEN_FOOD_TABLE_UI_OLD_HIK(groupName, sellType, handle, sellerCID, arg_num)
            else
                    DBGOUT("STOP OPEN")
                    --OPEN_FOOD_TABLE_UI_OLD(groupName, sellType, handle, sellerCID, arg_num)
            end
            if arg_num == 0 then
                DBGOUT("PARTY_ONLY")
            
                local actor = world.GetActor(handle)
                local apc = actor:GetPCApc()
                local aid = apc:GetAID()
                local fname = apc:GetFamilyName()
                local info = session.party.GetPartyMemberInfoByName(PARTY_NORMAL, fname)
                local frameName = "SELL_BALLOON_" .. handle
                local frame = ui.GetFrame(frameName)
                if info == nil and session.loginInfo.GetAID()~= aid then
                    if g.intrudes[handle]==1 then
                        actor:GetTitle():ClearBuffSellerBalloonFrame();
                        ui.DestroyFrame(frameName)
                    else
                        actor:GetTitle():ClearBuffSellerBalloonFrame();
                        ui.DestroyFrame(frameName)
                        ui.CloseFrame("foodtable_ui")
                        ui.SysMsg("Cannot access tables of different party.")
                    end
                else
                end
            elseif arg_num == 1 then
                DBGOUT("GUILD_ONLY")
            
                local actor = world.GetActor(handle)
                local apc = actor:GetPCApc()
                local aid = apc:GetAID()
                local fname = apc:GetFamilyName()
                local info = session.party.GetPartyMemberInfoByName(PARTY_GUILD, fname)
                local frameName = "SELL_BALLOON_" .. handle
                local frame = ui.GetFrame(frameName)
                if info == nil and session.loginInfo.GetAID()~= aid  then
                    if g.intrudes[handle] ==1 then
                        actor:GetTitle():ClearBuffSellerBalloonFrame();
                        ui.DestroyFrame(frameName)
                    else
                        actor:GetTitle():ClearBuffSellerBalloonFrame();
                        ui.DestroyFrame(frameName)
                        ui.CloseFrame("foodtable_ui")
                        ui.SysMsg("Cannot access tables of different guild.")
                    end
                end
            
        else
            DBGOUT("PUBLIC")
        
        end
    
            if g.intrudes[handle]==1 then
               
                g.oknext=true
                g.intrudes[handle]=2
            end
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HIDEINACCESSIBLEKITCHEN_AUTOSELLER_BALLOON(title, sellType, handle, skillID, skillLv)
    EBI_try_catch {
        try = function()
            AUTOSELLER_BALLOON_OLD_HIK(title, sellType, handle, skillID, skillLv)
            HIDEINACCESSIBLEKITCHEN_AUTOSELLER_BALLOON_IMPL(title, sellType, handle, skillID, skillLv)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function HIDEINACCESSIBLEKITCHEN_AUTOSELLER_BALLOON_IMPL(title, sellType, handle, skillID, skillLv, arg_num)
    EBI_try_catch {
        try = function()
            if sellType == AUTO_TITLE_FOOD_TABLE then
                local frameName = "SELL_BALLOON_" .. handle
                local frame = ui.GetFrame(frameName)
              
                local bg = frame:GetChild("bg")
                local guildInfo = session.party.GetPartyInfo(PARTY_GUILD)
                if g.settings.intrusive then
                    g.intrudes[handle] = 1
                    
                end
                if guildInfo == nil then
      
                    return
                end
                local actor = world.GetActor(handle)
                local apc = actor:GetPCApc()
                local aid=apc:GetAID()
                local fname = apc:GetFamilyName()
                local info = session.party.GetPartyMemberInfoByName(PARTY_GUILD, fname)
                if info==nil then
                    info = session.party.GetPartyMemberInfoByName(PARTY_NORMAL, fname)
                end
                if info == nil and session.loginInfo.GetAID()~= aid  then

                else
                    local pic = bg:CreateOrGetControl("picture", "pic", 16, 12, 30, 30)

                    pic:SetGravity(ui.LEFT, ui.TOP)
                    AUTO_CAST(pic)

                    pic:SetEnableStretch(1)
                    pic:EnableHitTest(0)
                    pic:SetImage("icon_warri_foodrationing")
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
