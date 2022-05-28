-- instantcc
-- includes
local acutil = {}
local json = require("json")
local addonSavePath = "../addons/"

-- ================================================================
-- Lua 5.3 Migration
-- ================================================================

if not _G["loadstring"] and _G["load"] then
    _G["loadstring"] = _G["load"]
end

if not _G["unpack"] then
    _G["unpack"] = table.unpack
end

-- ================================================================
-- Strings
-- ================================================================

function acutil.addThousandsSeparator(amount)
    local formatted = amount

    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end

    return formatted
end

function acutil.leftPad(str, len, char)
    if char == nil then
        char = " "
    end

    return string.rep(char, len - #str) .. str
end

function acutil.rightPad(str, len, char)
    if char == nil then
        char = " "
    end

    return str .. string.rep(char, len - #str)
end

function acutil.tostring(var)
    if (var == nil) then
        return "nil"
    end
    local tp = type(var)
    if (tp == "string" or tp == "number") then
        return var
    end
    if (tp == "boolean") then
        if (var) then
            return "true"
        else
            return "false"
        end
    end
    return tp
end

-- ================================================================
-- Json
-- ================================================================

function acutil.saveJSON(path, tbl)
    file, err = io.open(path, "w")
    if err then
        return _, err
    end

    local s = json.encode(tbl)
    file:write(s)
    file:close()
end

function acutil.saveJSONX(addonPath, tbl)
    file, err = io.open(addonSavePath .. addonPath, "w")
    if err then
        return _, err
    end

    local s = json.encode(tbl)
    file:write(s)
    file:close()
end

-- tblMerge is optional, use this to merge new pairs from tblMerge while
-- preserving the pairs set in the pre-existing config file
function acutil.loadJSON(path, tblMerge, ignoreError)
    -- opening the file
    local file, err = io.open(path, "r")
    local t = nil
    -- if a error happened
    if (err) then
        -- if the ignoreError is true
        if (ignoreError) then
            -- we simply set it as a empty json
            t = {}
        else
            -- if it's not, the error is returned
            return _, err
        end
    else
        -- if nothing wrong happened, the file is read
        local content = file:read("*all")
        file:close()
        t = json.decode(content)
    end
    -- if there is another table to merge (like default options)
    if tblMerge then
        -- we merge it
        t = acutil.mergeLeft(tblMerge, t)
        -- and save it back to file
        acutil.saveJSON(path, t)
    end
    -- returning the table
    return t
end

function acutil.loadJSONX(addonPath, tblMerge, ignoreError)
    -- opening the file
    local file, err = io.open(addonSavePath .. addonPath, "r")
    local t = nil
    -- if a error happened
    if (err) then
        -- if the ignoreError is true
        if (ignoreError) then
            -- we simply set it as a empty json
            t = {}
        else
            -- if it's not, the error is returned
            return _, err
        end
    else
        -- if nothing wrong happened, the file is read
        local content = file:read("*all")
        file:close()
        t = json.decode(content)
    end
    -- if there is another table to merge (like default options)
    if tblMerge then
        -- we merge it
        t = acutil.mergeLeft(tblMerge, t)
        -- and save it back to file
        acutil.saveJSONX(addonPath, t)
    end
    -- returning the table
    return t
end

-- ================================================================
-- Tables
-- ================================================================

-- merge left
function acutil.mergeLeft(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            acutil.mergeLeft(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

-- table length (when #table doesn't works)
function acutil.tableLength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

-- code

local addonName = "INSTANTCC"
local addonNameLower = "instantcc"

local author = "ebisuke"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local suppressupdate = false
local firsttouch = false
local retries = 0
local ininfo=nil
g.personalsettingsFileLoc = ""
g.settings =
    g.settings or
    {
        charactors = {}
    }
g.INSTANTCC_LOGIN_INFO = nil
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
            print(msg)
        end,
        catch = function(error)
        end
    }
end
function INSTANTCC_ISHIDELOGIN()
    local result = INSTANTCC_ISHIDELOGIN_OLD()

    INSTANTCC_LOAD_SETTINGS()
    firsttouch=false
    ReserveScript("INSTANTCC_ISHIDELOGIN_DELAY()", 0.01)

    return result
end

function INSTANTCC_ISHIDELOGIN_DELAY()
    ininfo=nil
    g.settings={}
    INSTANTCC_LOAD_SETTINGS()
    firsttouch = true
    if g.settings.do_cc then
        suppressupdate = true
        ui.DestroyFrame("barrack_charlist")
        ininfo=g.settings.do_cc
        g.settings.do_cc = nil
        retries=0
        INSTANTCC_SAVE_SETTINGS()
        INSTANTCC_CHANGE()
        
    else
        suppressupdate = false
    end
end

function INSTANTCC_CHANGE()
    ReserveScript("barrack.SelectBarrackLayer(" .. ininfo.layer .. ")", 0.1)
    ReserveScript("barrack.SelectCharacterByCID('" .. ininfo.cid .. "')", 0.2)
    ReserveScript("INSTANTCC_TOGAME()", 0.3)
end
function INSTANTCC_RETRY()
    retries = retries + 1
    if retries > 15 then
        app.BarrackToLogin()
        ui.SysMsg("[ICC] Failed to select character, please try manually select.")
        return
    end
    INSTANTCC_CHANGE()
end
function INSTANTCC_TOGAME()
    local bpca = barrack.GetBarrackPCInfoByCID(ininfo.cid)
    if bpca == nil then
        --fail
        INSTANTCC_RETRY()
        return
    end
    local bpc = barrack.GetGameStartAccount()
    if bpc ~= nil then
        if (bpc:GetCID() ~= ininfo.cid) then
            --fail
            INSTANTCC_RETRY()
            return
        end
        local jobName = barrack.GetSelectedCharacterJob();
        local charName = barrack.GetSelectedCharacterName();

        local bpacap=bpca:GetApc();
        if(charName~=bpacap:GetName())then
            --fail
            INSTANTCC_RETRY()
            return
        end
        local apc = bpc:GetApc()

        local jobid = apc:GetJob()
        local level = apc:GetLv()

        local JobCtrlType = GetClassString("Job", jobid, "CtrlType")

        config.SetConfig("LastJobCtrltype", JobCtrlType)
        config.SetConfig("LastPCLevel", level)
        local frame = ui.GetFrame("barrack_gamestart")
        local channels = GET_CHILD(frame, "channels", "ui::CDropList")
        local key = channels:GetSelItemIndex()
        app.BarrackToGame(key)
        return
    end
    --fail
    INSTANTCC_RETRY()
    
end

function INSTANTCC_GetBarrackSystem(actor)
    EBI_try_catch {
        try = function()
            if suppressupdate then
                return
            end
            if INSTANTCC_GetCurrentLayer()==nil then
                return
            end
            local aidx = session.loginInfo.GetAID();
            local myHandle = session.GetMyHandle();
            local myGuildIdx = 0
            local myTeamName = info.GetFamilyName(myHandle)
            --ui.SysMsg("hoge")
            if firsttouch == false then
                return
            end
            local brk = INSTANTCC_GetBarrackSystem_OLD(actor)
            local key = brk:GetCIDStr()
            local bpc = barrack.GetBarrackPCInfoByCID(key)
            g.settings = g.settings or {}
            g.settings.charactors = g.settings.charactors or {}
            if bpc == nil then
                for i = 1, #g.settings.charactors do
                    if g.settings.charactors[i].cid == key then
                        g.settings.charactors[i] = nil
                    end
                end
                return
            end
            local bcframe = ui.GetFrame("barrack_charlist")
            local scrollBox = bcframe:GetChild("scrollBox")
            local order=scrollBox:GetChildCount()
            for i=0, scrollBox:GetChildCount()-1 do
                local child = scrollBox:GetChildByIndex(i);
		        if string.find(child:GetName(), 'char_') ~= nil then
                    local guid = child:GetUserValue("CID");
                    if guid==key then
                        order=i
                        break
                    end
                end	
            end
            local pcInfo=session.barrack.GetMyAccount():GetByStrCID(key);
            local apc = bpc:GetApc()
            local gender = apc:GetGender()
            local jobid =pcInfo:GetRepID()
         

            local info = {
                name = actor:GetName(),
                layer = INSTANTCC_GetCurrentLayer(),
                cid = key,
                job = jobid,
                gender = gender,
                level = actor:GetLv(),
                order = scrollBox:GetChildCount(),
                server=GetServerGroupID(),
                aid=aidx,
            }
            local found = false
            for i = 1, #g.settings.charactors do
                if g.settings.charactors[i].cid == key then
                    found = i
                    break
                end
            end
            if found == false then
                table.insert(g.settings.charactors, info)
            else
                g.settings.charactors[found] = info
            end

            --cleanup
            local continue=false
            repeat
                continue=false
                for i = 1, #g.settings.charactors do

                    if g.settings.charactors[i].layer == INSTANTCC_GetCurrentLayer() and
                    g.settings.charactors[i].aid==aidx and
                    g.settings.charactors[i].server==GetServerGroupID() then
                        local bpc = barrack.GetBarrackPCInfoByCID(g.settings.charactors[i].cid)
                        if bpc==nil then
                            table.remove(g.settings.charactors, i)
                            continue=true
                            break
                        end
                    end
                end
                
            until continue==false

            --sort

            table.sort(
                g.settings.charactors,
                function(a, b)
                    if a.layer ~= b.layer then
                        return a.layer > b.layer
                    end
                    if a.order ~= b.order then
                        return a.order < b.order
                    end
                end
            )

            INSTANTCC_SAVE_SETTINGS()
        end,
        catch = function(error)
            ui.SysMsg(error)
        end
    }
    return INSTANTCC_GetBarrackSystem_OLD(actor)
end

function INSTANTCC_SAVE_SETTINGS()
    local aidx = session.loginInfo.GetAID();
    local myHandle = session.GetMyHandle();
	local myGuildIdx = 0
	local myTeamName = info.GetFamilyName(myHandle)
    g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function INSTANTCC_DEFAULT_SETTINGS()
    g.settings = {
        charactors = {}
    }
end
function INSTANTCC_LOAD_SETTINGS()

    g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
    EBI_try_catch {
        try = function()
            g.settings={}
            INSTANTCC_DEFAULT_SETTINGS()
            local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

            g.settings = t

            INSTANTCC_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function INSTANTCC_GetCurrentLayer()
    local frame = ui.GetFrame("barrack_charlist");
    local layer= frame:GetUserIValue("SelectBarrackLayer");
    if layer==0 then
        return nil
    end
    return layer
end
function INSTANTCC_GetMyAccount()

    if ui.GetFrame('barrack_charlist')==nil or ui.GetFrame('barrack_charlist'):IsVisible()==0 or suppressupdate then
        
    elseif INSTANTCC_GetCurrentLayer()~=nil and firsttouch then

        local modified=false
        --cleanup
        local continue=false
        repeat
            continue=false
            local aidx = session.loginInfo.GetAID();
            local myHandle = session.GetMyHandle();
            local myGuildIdx = 0
            local myTeamName = info.GetFamilyName(myHandle)
            for i = 1, #g.settings.charactors do

                if g.settings.charactors[i].layer == INSTANTCC_GetCurrentLayer() and
                g.settings.charactors[i].aid==aidx and
                g.settings.charactors[i].server==GetServerGroupID()
                 then
                    local bpc = barrack.GetBarrackPCInfoByCID(g.settings.charactors[i].cid)
                    if bpc==nil then
                        table.remove(g.settings.charactors, i)
                        continue=true
                        modified=true
                        break
                    end
                end
            end
            
        until continue==false
        if modified then
            INSTANTCC_SAVE_SETTINGS()
        end
    end
    return INSTANTCC_GetMyAccount_OLD()
end
if INSTANTCC_GetMyAccount_OLD==nil and session.barrack.GetMyAccount~= INSTANTCC_GetBarrackSystem then
    INSTANTCC_GetMyAccount_OLD=session.barrack.GetMyAccount
    session.barrack.GetMyAccount=INSTANTCC_GetMyAccount

end
if INSTANTCC_ISHIDELOGIN_OLD == nil and barrack.IsHideLogin ~= INSTANTCC_ISHIDELOGIN then
    INSTANTCC_ISHIDELOGIN_OLD = barrack.IsHideLogin
    barrack.IsHideLogin = INSTANTCC_ISHIDELOGIN
end

if INSTANTCC_GetBarrackSystem_OLD == nil and GetBarrackSystem ~= INSTANTCC_GetBarrackSystem then
    INSTANTCC_GetBarrackSystem_OLD = GetBarrackSystem
    GetBarrackSystem = INSTANTCC_GetBarrackSystem
end
