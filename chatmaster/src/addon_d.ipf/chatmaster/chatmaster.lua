--chatmaster
local addonName = "chatmaster"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
g.version = 0
g.settings = g.settings or {redirect = {}}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "chatmaster"
g.debug = false
g.acquire_by_chatmaster = false
g.msgs = {}
g.flattened = {}
g.loadedchatcount = {}
local totalgroupboxname = "chatgbox_TOTAL"
function table.unique(t, elemfunc, bArray)
    local check = {}
    local n = {}
    local idx = 1
    elemfunc = elemfunc or function(x)
            return x
        end
    for k, v in pairs(t) do
        if not check[elemfunc(v)] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[elemfunc(v)] = true
        end
    end
    return n
end
--ライブラリ読み込み
CHAT_SYSTEM("[ChatMaster]loaded")
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
-- Make proxy object with property support.
-- Notes:
--   If key is found in <getters> (or <setters>), then
--     corresponding function is used, else lookup turns to the
--     <class> metatable (or first to <priv> if <is_expose_private> is true).
--   Given a proxy object <self>, <priv> can be obtained with
--     getmetatable(self).priv .
-- @param class - metatable acting as the object class.
-- @param priv - table containing private data for object.
-- @param getters - table of getter functions
--                  with keys as property names. (default is nil)
-- @param setters - table of setter functions,
--                  with keys as property names. (default is nil)
-- @param is_expose_private - Boolean whether to expose <priv> through proxy.
--                  (default is nil/false)
-- @version 3 - 20060921 (D.Manura)
local function make_proxy(class, priv, getters, setters, is_expose_private)
    setmetatable(priv, class) -- fallback priv lookups to class
    local fallback = is_expose_private and priv or class
    local index = getters and function(self, key)
            -- read from getter, else from fallback
            local func = getters[key]
            if func then
                return func(self)
            else
                return fallback[key]
            end
        end or fallback -- default to fast property reads through table
    local newindex = setters and function(self, key, value)
            -- write to setter, else to proxy
            local func = setters[key]
            if func then
                func(self, value)
            else
                rawset(self, key, value)
            end
        end or fallback -- default to fast property writes through table
    local proxy_mt = {
        -- create metatable for proxy object
        __newindex = newindex,
        __index = index,
        priv = priv
    }
    local self = setmetatable({}, proxy_mt) -- create proxy object
    return self
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

function CHATMASTER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            local addontimer = frame:GetChild("addontimer")
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0, 0)
            --addon:RegisterMsg('GAME_START_3SEC', 'CHATMASTER_INITFRAME')
            acutil.setupHook(CHATMASTER_GCM_ON_LOAD_MESSAGES, "GCM_ON_LOAD_MESSAGES")
            acutil.setupHook(CHATMASTER_GCM_SELECT_CHANNEL, "GCM_SELECT_CHANNEL")
            if
                (session.ui.GetMsgInfoSize ~= CHATMASTER_SESSION_UI_GETMSGINFOSIZE and
                    session.ui.GetMsgInfoSize_OLD == nil)
             then
                session.ui.GetMsgInfoSize_OLD = session.ui.GetMsgInfoSize
                session.ui.GetMsgInfoSize = CHATMASTER_SESSION_UI_GETMSGINFOSIZE
                session.ui.GetChatMsgInfo_OLD = session.ui.GetChatMsgInfo
                session.ui.GetChatMsgInfo = CHATMASTER_SESSION_UI_GETCHATMSGINFO
            end

            acutil.setupHook(CHATMASTER_DRAW_CHAT_MSG, "DRAW_CHAT_MSG")

            addon:RegisterMsg("GAME_START_3SEC", "CHATMASTER_3SEC")
            --addon:RegisterMsg("DO_SOLODUNGEON_RANKINGPAGE_OPEN", "CHATMASTER_INITFRAME");
            --soloDungeonClient.ReqSoloDungeonRankingPage()

            --addon:RegisterMsg("GAME_START", "CHATMASTER_REFRESH")
            CHATMASTER_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CHATMASTER_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function CHATMASTER_SESSION_UI_GETMSGINFOSIZE(groupboxname)
    return CHATMASTER_SESSION_UI_GETMSGINFOSIZE_IMPL(groupboxname)
end
function CHATMASTER_SESSION_UI_GETCHATMSGINFO(groupboxname, i)
    return CHATMASTER_SESSION_UI_GETCHATMSGINFO_IMPL(groupboxname, i)
end
function CHATMASTER_SESSION_UI_GETMSGINFOSIZE_IMPL(groupboxname)
    local originalsize = session.ui.GetMsgInfoSize_OLD(groupboxname)
    if (groupboxname ~= "chatgbox_TOTAL") then
        return originalsize
    end

    local additionalsize = 0
    g.flattened[groupboxname]=g.flattened[groupboxname] or {}
    if g.flattened[groupboxname] then

        additionalsize = additionalsize + #g.flattened[groupboxname]
    else

    end
    return originalsize + additionalsize
end
function CHATMASTER_SESSION_UI_GETCHATMSGINFO_IMPL(groupboxname, i)
    if (groupboxname ~= "chatgbox_TOTAL") then
        return session.ui.GetChatMsgInfo_OLD(groupboxname, i)
    end
    g.flattened[groupboxname]=g.flattened[groupboxname] or {}
    local msginfo = g.flattened[groupboxname][i + 1]
    return msginfo
end
function CHATMASTER_DRAW_CHAT_MSG(groupboxname, startindex, chatframe, removeChatIDList)
    return CHATMASTER_DRAW_CHAT_MSG_IMPL(groupboxname, startindex, chatframe, removeChatIDList)
end
function CHATMASTER_DRAW_CHAT_MSG_IMPL(groupboxname, startindex, chatframe, removeChatIDList)
    return EBI_try_catch {
        try = function()
            if (groupboxname ~= "chatgbox_TOTAL") then
                return DRAW_CHAT_MSG_OLD(groupboxname, startindex, chatframe, removeChatIDList)
            end
            CHATMASTER_RELOAD_CHATS(groupboxname,false)

            return DRAW_CHAT_MSG_OLD(groupboxname, startindex, chatframe, removeChatIDList)
        end,
        catch = function(error)
            print(error)
        end
    }
end
function CHATMASTER_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format("[%s] cannot load setting files", addonName))
        g.settings = {redirect = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    CHATMASTER_UPGRADE_SETTINGS()
    CHATMASTER_SAVE_SETTINGS()
end

function CHATMASTER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function CHATMASTER_3SEC()
end
function CHATMASTER_LOAD_MESSAGE()
    g.acquire_by_chatmaster = true
    g.calllist = {}
    g.msgs = {}
    g.flattened = {}

    -- invoke loadmessage

    for k, _ in pairs(g.settings.redirect) do
        g.calllist[#g.calllist + 1] = k
    end
    CHATMASTER_LOAD_MESSAGE_NEXT()
end
function CHATMASTER_LOAD_MESSAGE_NEXT()
    g.acquire_by_chatmaster = true
    -- invoke loadmessage

    gcm_LoadMessages(g.calllist[1])
    if (#g.calllist > 1) then
        table.remove(g.calllist, 1)
        CHATMASTER_LOAD_MESSAGE_NEXT()
    else
        g.acquire_by_chatmaster = false
        CHAT_SYSTEM("[Chatmaster]Redraw")
        ui.ReDrawAllChatMsg()
        CHATMASTER_RELOAD_CHATS(nil,true)
    end
end

function CHATMASTER_GCM_SELECT_CHANNEL(channel, no_reload)
    return EBI_try_catch {
        try = function()
            local result = GCM_SELECT_CHANNEL_OLD(channel, no_reload)
            local frame = ui.GetFrame("guildinfo")
            local panel = GET_CHILD_RECURSIVELY(frame, "communitypanel")
            local channels = GET_CHILD_RECURSIVELY(frame, "communitypanel_channels")

            if type(channel) == "string" then
                channel = channels:GetChild(channel)
            elseif type(channel) == "number" then
                channel = channels:GetChildByIndex(channel)
            end
            if not channel or not gcm_IsJoinedChannel(channel:GetName()) then
                return false
            end

            local redir = panel:CreateOrGetControl("checkbox", "redirect", 0, 0, 100, 24)
            AUTO_CAST(redir)
            redir:SetText("{ol}Redirect")
            local chname = channel:GetName()
            redir:SetEventScript(ui.LBUTTONUP, "CHATMASTER_REDIRECT_CHANNEL")
            redir:SetEventScriptArgString(ui.LBUTTONUP, chname)
            if (g.settings.redirect[chname] == true) then
                redir:SetCheck(1)
            else
                redir:SetCheck(0)
            end
            return result
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CHATMASTER_REDIRECT_CHANNEL(frame, redir, channel, argnum)
    return EBI_try_catch {
        try = function()
            AUTO_CAST(redir)
            g.settings.redirect = g.settings.redirect or {}
            if (g.settings.redirect[channel] == true) then
                g.settings.redirect[channel] = nil
                redir:SetCheck(0)
            else
                g.settings.redirect[channel] = true
                redir:SetCheck(1)
            end
            CHATMASTER_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CHATMASTER_GCM_ON_LOAD_MESSAGES(channel, messages)
    if (g.acquire_by_chatmaster) then
        CHATMASTER_ON_LOAD_MESSAGES(channel, messages)
    else
        GCM_ON_LOAD_MESSAGES_OLD(channel, messages)
    end
end

function CHATMASTER_ON_LOAD_MESSAGES(channel, messages)
    return EBI_try_catch {
        try = function()
            if (g.settings.redirect[channel]) then
                g.msgs[channel] = g.msgs[channel] or {}
                g.msgs[channel] = {table.unpack(messages)}
                for k, v in pairs(g.msgs[channel]) do
                    CHATMASTER_INSERT(totalgroupboxname, channel, v, true)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CHATMASTER_RELOAD_CHATS(groupboxname,all)
    groupboxname = groupboxname or totalgroupboxname
    if all then
        g.loadedchatcount[groupboxname] = 0
    end
    g.loadedchatcount[groupboxname] = g.loadedchatcount[groupboxname] or 0
    for i = g.loadedchatcount[groupboxname], session.ui.GetMsgInfoSize_OLD(groupboxname) - 1 do
        local chatmsg = session.ui.GetChatMsgInfo_OLD(groupboxname, i)
        CHATMASTER_INSERT(totalgroupboxname, groupboxname, chatmsg, false)
        g.loadedchatcount[groupboxname] = g.loadedchatcount[groupboxname] + 1
    end
end
function CHATMASTER_INSERT(groupboxname, channel, msg, isguildcomm)
    local obj = {
        _groupboxname = groupboxname,
        _channel = channel,
        _msg = msg,
        _isguildcomm = isguildcomm,
        getChannel = function(self)
            return self._channel
        end,
        getGroupboxName = function(self)
            return self._groupboxname
        end,
        getTime = function(self)
            if (self._isguildcomm) then
                return self._msg.time
            else
                return self._msg:GetTimeStr()
            end
        end,
        getText = function(self)
            if (self._isguildcomm) then
                return self._msg.text
            else
                return self._msg:GetMsg()
            end
        end,
        getSource = function(self)
            if (self._isguildcomm) then
                return self._msg.sender
            else
                return self._msg:GetCommanderName()
            end
        end,
        getDestination = function(self)
            if (self._isguildcomm) then
                return ""
            else
                return self._msg:GetToName()
            end
        end,
        getMessageType = function(self)
            if (self._isguildcomm) then
                return "GuildComm"
            else
                return self._msg:GetMsgType()
            end
        end,
        getMessageID = function(self)
            if (self._isguildcomm) then
                return self._msg.id
            else
                return self._msg:GetMsgInfoID()
            end
        end,
        getRoomID = function(self)
            if (self._isguildcomm) then
                return self._channel
            else
                return self._msg:GetRoomID()
            end
        end,
        getColor= function(self)
            if (self._isguildcomm) then
                return "FF77FF"
            else
                return self._msg:GetColor()
            end
        end,
    }

    -- compatibles
    obj.GetMsgType = obj.getMessageType
    obj.GetCommanderName = obj.getSource
    obj.GetToName = obj.getDestination
    obj.GetMsg = obj.getText
    obj.GetRoomID = obj.getRoomID
    obj.GetMsgInfoID = obj.getMessageID
    local getters = {
        text = obj.getText,
        time = obj.getTime,
        sender = obj.getSource,
        id = obj.getMessageID,
        roomid = obj.getRoomID
    }
    obj = make_proxy(obj, obj, getters)
    g.flattened[groupboxname] = g.flattened[groupboxname] or {}
    table.insert(g.flattened[groupboxname], obj)
    table.unique(
        g.flattened[groupboxname],
        function(a)
            return tostring(a:getChannel()) .. a:getMessageID()
        end
    )
    g.flattened[groupboxname] =
        table.sort(
        g.flattened[groupboxname],
        function(a, b)
            return a.getTime() < b.getTime()
        end
    )
end
