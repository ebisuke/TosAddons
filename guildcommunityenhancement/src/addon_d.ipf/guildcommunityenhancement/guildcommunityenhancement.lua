--アドオン名（大文字）
local addonName = "guildcommunityenhancement"
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
g.settings = g.settings or {x = 300, y = 300, target = nil}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "guildcommunityenhancement"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
--ライブラリ読み込み
CHAT_SYSTEM("[GCE]loaded")
local acutil = require('acutil')
local json = require "json"

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
function GCE_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function GCE_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
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
    
    GCE_UPGRADE_SETTINGS()
    GCE_SAVE_SETTINGS()

end


function GCE_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=GCE_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function GUILDCOMMUNITYENHANCEMENT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            --acutil.addSysIcon('GCE', 'sysmenu_sys', 'GCE', 'GCE_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'GCE_SHOW')
            acutil.setupHook(GCE_ON_TIMELINE_UPDATE_JUMPER, "ON_TIMELINE_UPDATE")
            addon:RegisterMsg("UPDATE_GUILD_ASSET", "GCE_UPDATE_GUILD_ONE_SAY");
            acutil.slashCommand("/gce", GCE_PROCESS_COMMAND);
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            --timer:SetUpdateScript("GCE_ON_TIMER");
            --timer:Start(0.1);
            --GCE_SHOW(g.frame)
            GCE_LOAD_SETTINGS()
            --GCE_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function GCE_UPDATE_GUILD_ONE_SAY()

    if (g.settings.target) then
        GetComment("GCE_ON_COMMENT_GET", g.settings.target);
    end
end
function GCE_ON_COMMENT_GET(code,ret_json)
    EBI_try_catch{
        try = function()
            if code ~= 200 then
                return
            end
            
            local list = json.decode(ret_json);
            list = list["list"];
            for i = 1, #list do
                local replyData = list[i]
                if( g.settings.logindex<i)then
                    session.ui.GetChatMsg():AddSystemMsg(replyData["message"], true, "{#A566FF}{ol}[ギルコミュ]"..replyData["author"],nil);
                end
            end
            g.settings.logindex=#list
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function GCE_ON_TIMELINE_UPDATE_JUMPER(code, ret_json)
    GCE_ON_TIMELINE_UPDATE(code, ret_json)
end
function GCE_ON_TIMELINE_UPDATE(code, ret_json)
    EBI_try_catch{
        try = function()
            ON_TIMELINE_UPDATE_OLD(code, ret_json)
            
            
            if code ~= 200 then
                return
            end
            local frame = ui.GetFrame("guildinfo");
            local communityPanel = GET_CHILD_RECURSIVELY(frame, "communitypanel", "ui::CGroupBox");
            for i = 0, communityPanel:GetChildCount() - 1 do
                
                local ctrlSet = communityPanel:GetChildByIndex(i);
                local chkbox = ctrlSet:CreateOrGetControl("checkbox", "chktarget", 400, 10, 24, 24)
                local mainText = GET_CHILD_RECURSIVELY(ctrlSet, "mainText", "ui::CRichText");
                if (mainText) then
                    tolua.cast(chkbox, "ui::CCheckBox")
                    chkbox:SetText("{ol}狙")
                    chkbox:SetEventScript(ui.LBUTTONUP, "GCE_TARGETCHECK")
                    chkbox:SetEventScriptArgNumber(ui.LBUTTONUP, mainText:GetUserIValue("boardIdx"))
                    if (mainText:GetUserIValue("boardIdx") == g.settings.target) then
                        chkbox:SetCheck(1)
                    else
                        chkbox:SetCheck(0)
                    
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function GCE_TARGETCHECK(frame, ctrl, argstr, argnum)
    g.settings.target = argnum
    g.settings.logindex=0 
    local frame = ui.GetFrame("guildinfo");
    local communityPanel = GET_CHILD_RECURSIVELY(frame, "communitypanel", "ui::CGroupBox");
    for i = 0, communityPanel:GetChildCount() - 1 do
        
        local ctrlSet = communityPanel:GetChildByIndex(i);
        local chkbox = ctrlSet:GetChild("chktarget")
        local mainText = GET_CHILD_RECURSIVELY(ctrlSet, "mainText", "ui::CRichText");
        if (mainText) then
            tolua.cast(chkbox, "ui::CCheckBox")
            if (mainText:GetUserIValue("boardIdx") == g.settings.target) then
                chkbox:SetCheck(1)
            else
                chkbox:SetCheck(0)
            
            end
            GCE_SAVE_SETTINGS()
        end
    end
end
function GCE_PROCESS_COMMAND(command)
    local cmd = "";
    
    
    if(g.settings.target)then
        local msg=""
        for _,v in ipairs(command) do
            msg=msg..v.." "
            print(v)
        end
        --print(msg)
        WriteOnelineComment("GCE_ON_REPLY_SUCCESS",msg,g.settings.target)
    else
        return ui.MsgBox("先に書き込み対象を選んでください", "", "Nope")
    end
end
    
function GCE_ON_REPLY_SUCCESS(code, ret_json, boardIdx)

    if code ~= 200 then
        SHOW_GUILD_HTTP_ERROR(code, ret_json, "GCE_ON_REPLY_SUCCESS")
        return
    end
    --お金を投入
    control.CustomCommand('DEPOSIT_GUILD_ASSET', "1");
end
