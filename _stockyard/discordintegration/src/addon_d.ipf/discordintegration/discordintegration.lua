--アドオン名（大文字）
local addonName = "discordintegration"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "discordintegration"
g.debug = true
g.reqrxloc = string.format('../addons/%s/req_rx.lua', addonNameLower)
g.intervalrxloc = string.format('../addons/%s/int_rx.lua', addonNameLower)
g.execpath = string.format('../addons/%s/bridge/dibridge.exe', addonNameLower)

g.currentguildlist={}
local filelocation = "../addons/discordintegration/"
local execlocation = "..\\addons\\discordintegration\\dibridge\\dibridge.exe"


--ライブラリ読み込み
CHAT_SYSTEM("[DI]loaded")
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

function diapi_reqrx(token)

    local fpath =string.format('../addons/%s/req_rx_%s.lua', addonNameLower,token)

    local state, json = pcall(dofile, fpath, {})
    if (state) then
        os.remove(fpath)
        local state = diapi_state
        diapi_state = nil;
        
        return json, state
    else
        DISCORDINTEGRATION_DBGOUT(state);
        return nil, nil
    end
end

function diapi_req(url,token)
    DISCORDINTEGRATION_DBGOUT(url)
    debug.ShellExecute(execlocation .. " -X " .. url .. " " .. token)
    diapi_state = url

end
function diapi_reqb(url,token)
    DISCORDINTEGRATION_DBGOUT(url)
    debug.ShellExecute(execlocation .. " -B " .. url.. " " .. token)
    diapi_state = url

end



local translationtable = {
    
    --Tsettingsupdt12 = {jp="[AIM]共通設定のバージョンを更新しました 1->2",  eng="[AIM]Team settings updated 1->2"},
    }

local function L_(str)
    if (option.GetCurrentCountry() == "Japanese") then
        return translationtable[str].jp
    else
        return translationtable[str].eng
    end
end

function DISCORDINTEGRATION_DBGOUT(msg)
    
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
function DISCORDINTEGRATION_ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
function DISCORDINTEGRATION_SAVE_SETTINGS()
    
    acutil.saveJSON(g.settingsFileLoc, g.settings)

end

function DISCORDINTEGRATION_LOAD_SETTINGS()
    DISCORDINTEGRATION_DBGOUT("LOAD_SETTINGS " .. tostring(DISCORDINTEGRATION_GETCID()))
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DISCORDINTEGRATION_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    
    DISCORDINTEGRATION_UPGRADE_SETTINGS()
    DISCORDINTEGRATION_SAVE_SETTINGS()

end
function DISCORDINTEGRATION_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end


--マップ読み込み時処理（1度だけ）
function DISCORDINTEGRATION_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(DISCORDINTEGRATION_GETCID()))
            frame:ShowWindow(0)
            acutil.slashCommand("/di", DISCORDINTEGRATION_PROCESS_COMMAND);
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            acutil.addSysIcon(g.framename, 'sysmenu_sys', g.framename, 'DISCORDINTEGRATION_TOGGLE_FRAME')
            
            frame:ShowWindow(0)
            DISCORDINTEGRATION_INITFRAME(frame)
        end,
        catch = function(error)
            DISCORDINTEGRATION_ERROUT(error)
        end
    }
end
function DISCORDINTEGRATION_INITFRAME(frame)
    if (frame == nil) then
        frame = ui.GetFrame(g.framename)
    end
    
    local btnRefresh = frame:CreateOrGetControl("button", "btnRefresh", 250, 80, 70, 50)
    btnRefresh:SetText("Refresh")
    btnRefresh:SetEventScript(ui.LBUTTONDOWN, "DISCORDINTEGRATION_REFRESH_GUILDLIST")
    local dlGuildList = frame:CreateOrGetControl("droplist", "dlGuildList", 20, 80, 200, 20)
    tolua.cast(dlGuildList, "ui::CDropList")
    dlGuildList:SetSkinName("droplist_normal")
    dlGuildList:SetSelectedScp("DISCORDINTEGRATION_SELECTED_GUILDLIST")
    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 10, 120, 300, 400)
    gbox:ShowWindow(1)
end
function DISCORDINTEGRATION_REFRESH_GUILDLIST()
    diapi_req("/users/@me/guilds","guilds")
    ReserveScript("DISCORDINTEGRATION_REFRESH_GUILDLIST_DELAY()", 1)
    DISCORDINTEGRATION_DBGOUT("gbb")
end
function DISCORDINTEGRATION_REFRESH_GUILDLIST_DELAY()
    frame = ui.GetFrame(g.framename)
    local res = diapi_reqrx("guilds")
    local dlGuildList = frame:GetChild("dlGuildList")
    tolua.cast(dlGuildList, "ui::CDropList")
    dlGuildList:ClearItems()
    DISCORDINTEGRATION_DBGOUT("recv")
    if(res==nil)then
        return
    end
    for i, v in ipairs(res) do
        DISCORDINTEGRATION_DBGOUT("recva")
        dlGuildList:AddItem(i - 1, v.name)
    end
    dlGuildList:Invalidate()
    g.currentguildlist=res

end
function DISCORDINTEGRATION_SELECTED_GUILDLIST()
    frame = ui.GetFrame(g.framename)

    local dlGuildList = frame:GetChild("dlGuildList")
    tolua.cast(dlGuildList, "ui::CDropList")
    local idx = dlGuildList:GetSelItemIndex()
    --今宵は家畜のみ・・・
    local id = g.currentguildlist[idx+1].id
    --リストアップ
    diapi_reqb("/guilds/" .. id .. "/channels","channels")
    DISCORDINTEGRATION_DBGOUT("gld")
    ReserveScript("DISCORDINTEGRATION_SELECTED_GUILDLIST_DELAY()", 1)


end
function DISCORDINTEGRATION_SELECTED_GUILDLIST_DELAY()
    EBI_try_catch{try =
        function()
            
            frame = ui.GetFrame(g.framename)
            local res = diapi_reqrx("channels")
            if(res==nil)then
                return
            end
            local gbox = frame:GetChild("gbox")
            tolua.cast("ui::CGroupBox", gbox)
            --一覧作成
            gbox:RemoveAllChild()
            for i, v in ipairs(res) do
                if(v.type==4)then
                    --local btn=gbox:CreateOrGetControl("richtext", "label"..tostring(i), 0, 30 * i, 300, 30)
                    --btn:SetText("{ol}"..v.name)
                else
                    local btn=gbox:CreateOrGetControl("button", "btn"..tostring(i), 0, 30 * i, 300, 30)
                    btn:SetText(v.name)
                    btn:SetEventScript(ui.LBUTTONUP,"DISCORDINTEGRATION_SHOW_CHAT")
                    btn:SetEventScriptArgString(ui.LBUTTONUP,v.id)
                    
                end
                
            end
        end,
        catch = function(error)
            DISCORDINTEGRATION_ERROUT(error)
        end
    }
--gbox:CreateOrGetControl("button","")
end
function DISCORDINTEGRATION_SHOW_CHAT(frame,ctrl,argstr,argnum)
    EBI_try_catch{try =
    function()
        
    frame = ui.GetFrame(g.framename)
    
    local chatframe=ui.CreateNewFrame("dichat","dichat_"..argstr)
    chatframe:Resize(500,300)
    chatframe:SetUserValue("id",argstr)
    
    chatframe:ShowWindow(1)
    DICHAT_POPUP_OPEN(chatframe)
end,
catch = function(error)
    DISCORDINTEGRATION_ERROUT(error)
end
}
end
function DISCORDINTEGRATION_TOGGLE_FRAME()
    if g.frame:IsVisible() == 0 then
        --非表示->表示
        g.frame:ShowWindow(1)
        g.settings.enable = true
    else
        --表示->非表示
        g.frame:ShowWindow(0)
        g.settings.show = false
    end

--DISCORDINTEGRATION_SAVE_SETTINGS()
end

--フレーム場所保存処理
function DISCORDINTEGRATION_END_DRAG()
    g.settings.position.x = g.frame:GetX()
    g.settings.position.y = g.frame:GetY()
    DISCORDINTEGRATION_SAVE_SETTINGS()
end
--チャットコマンド処理（acutil使用時）
function DISCORDINTEGRATION_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = L_("Usagemsg")
        return ui.MsgBox(msg, "", "Nope")
    end
    CHAT_SYSTEM("POC")
    print("poc")
    diapi_req("/users/@me","me")
    ReserveScript("CHAT_SYSTEM(\"RECV\");print(tostring(diapi_reqrx(),\"me\")", 1)
    if cmd == "on" then
        --有効
        g.settings.itemmanagetempdisabled = false
        
        CHAT_SYSTEM(L_("Enablemsg"));
        DISCORDINTEGRATION_SAVE_SETTINGS()
        return;
    elseif cmd == "off" then
        --無効
        g.settings.itemmanagetempdisabled = true
        CHAT_SYSTEM(L_("Disablemsg"));
        DISCORDINTEGRATION_SAVE_SETTINGS()
        return;
    end

end
