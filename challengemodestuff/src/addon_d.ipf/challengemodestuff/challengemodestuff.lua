--アドオン名（大文字）
local addonName = "challengemodestuff"
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
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "challengemodestuff"
g.debug = true
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.large=0
g.endo=false

--ライブラリ読み込み
CHAT_SYSTEM("[challengemodestuff]loaded")
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
function CHALLENGEMODESTUFF_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function CHALLENGEMODESTUFF_LOAD_SETTINGS()
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
    
    CHALLENGEMODESTUFF_UPGRADE_SETTINGS()
    CHALLENGEMODESTUFF_SAVE_SETTINGS()

end


function CHALLENGEMODESTUFF_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=CHALLENGEMODESTUFF_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function CHALLENGEMODESTUFF_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            --acutil.addSysIcon('CHALLENGEMODESTUFF', 'sysmenu_sys', 'CHALLENGEMODESTUFF', 'CHALLENGEMODESTUFF_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'CHALLENGEMODESTUFF_SHOW')
            --ccするたびに設定を読み込む
            acutil.setupHook(CMS_CHALLENGE_MODE_ON_INIT_JUMPER,"CHALLENGE_MODE_ON_INIT")
            acutil.setupHook(CMS_DIALOG_ACCEPT_CHALLENGE_MODE_JUMPER,"DIALOG_ACCEPT_CHALLENGE_MODE")
            acutil.setupHook(CMS_DIALOG_ACCEPT_CHALLENGE_MODE_RE_JOIN_JUMPER,"DIALOG_ACCEPT_CHALLENGE_MODE_RE_JOIN")
            addon:RegisterMsg("UI_CHALLENGE_MODE_TOTAL_KILL_COUNT", "CMS_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT");
            
            if not g.loaded then
                
                g.loaded = true
            end
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("CHALLENGEMODESTUFF_ON_TIMER");
            timer:Start(0.01);
            timer:EnableHideUpdate(1)
            --CHALLENGEMODESTUFF_SHOW(g.frame)
            DBGOUT("INIT")
            --CHALLENGEMODESTUFF_INIT()
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CHALLENGEMODESTUFF_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function CHALLENGEMODESTUFF_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function CHALLENGEMODESTUFF_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end
function CMS_CHALLENGE_MODE_ON_INIT_JUMPER(addon, frame)
    CHALLENGE_MODE_ON_INIT_OLD(addon,frame)
    CMS_CHALLENGE_MODE_ON_INIT(addon,frame)

end
function CMS_CHALLENGE_MODE_ON_INIT(addon, frame)
    frame=ui.GetFrame("challenge_mode")
    local txt=frame:CreateOrGetControl("richtext","remain",0,0,400,96)
    txt:SetGravity(ui.LEFT,ui.TOP)
    txt:SetOffset(0,0)
    txt:SetText("{@st43}{#FF2222}{s48}敵 --")
    txt:ShowWindow(1)
    txt:EnableHitTest(0)
end
function CMS_DIALOG_ACCEPT_CHALLENGE_MODE_RE_JOIN_JUMPER(handle)
    DIALOG_ACCEPT_CHALLENGE_MODE_RE_JOIN_OLD(handle)
    CMS_DIALOG_ACCEPT_CHALLENGE_MODE_RE_JOIN(handle)
end
function CMS_DIALOG_ACCEPT_CHALLENGE_MODE_JUMPER(handle)
    DIALOG_ACCEPT_CHALLENGE_MODE_OLD(handle)
    CMS_DIALOG_ACCEPT_CHALLENGE_MODE(handle)
end
function CMS_DIALOG_ACCEPT_CHALLENGE_MODE(handle)
    g.challengehandle=handle
end
function CMS_DIALOG_ACCEPT_CHALLENGE_MODE_RE_JOIN(handle)
    g.challengehandle=handle
end
function CMS_ON_CHALLENGE_MODE_TOTAL_KILL_COUNT(frame, msg, str, arg)
    local frame=ui.GetFrame("challenge_mode")
    local msgList = StringSplit(str, '#');
	if #msgList < 1 then
		return;
	end
    local sz=string.format("{s%d}",48+g.large)
	if msgList[1] == "SHOW" then
        
        local txt=frame:GetChild("remain")
        txt:SetText("{@st43}{#FF2222}"..sz.."敵 --匹")
        g.killCount=0
        g.targetKillCount=0
        g.endo=false
        DBGOUT("SHOW")
	elseif msgList[1] == "HIDE" then
	elseif msgList[1] == "START_CHALLENGE_TIMER" then
        DBGOUT("START_CHALLENGE_TIMER")
        local txt=frame:GetChild("remain")
        txt:SetText("")
    elseif msgList[1] == "GAUGERESET" then
		local txt=frame:GetChild("remain")
        txt:SetText("{@st43}{#FF2222}"..sz.."敵 --匹")
        
        g.killCount=0
        g.targetKillCount=0
        g.endo=false
        DBGOUT("RESET")
	elseif msgList[1] == "REFRESH" then
		frame:ShowWindow(1);
        local txt=frame:GetChild("remain")
        local killCount = tonumber(msgList[2]);
        local targetKillCount = tonumber(msgList[3]);
        if(g.killCount~=killCount)then
            g.killCount=killCount
            g.large=24
        end
        g.targetKillCount=targetKillCount
        txt:SetText("{@st43}{#FF2222}"..sz.."敵 "..string.format("%4d匹",targetKillCount-killCount))
        if(g.killCount~=g.targetKillCount)then
            g.endo=false
        else
            g.endo=true
        end
    elseif msgList[1] == "MONKILLMAX" then
        local txt=frame:GetChild("remain")
        txt:SetText("{@st43}{#FF2222}"..sz.."ボス戦")
        DBGOUT("MONKILLMAX")
        g.endo=true
	end
end

function CHALLENGEMODESTUFF_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("challenge_mode")
            if g.large>=0 then
                
                g.large=g.large-4
                local killCount = g.killCount
                local targetKillCount = g.targetKillCount
                local sz=string.format("{s%d}",48+g.large)
                local txt=frame:GetChild("remain")
                if(g.endo==false)then
                    txt:SetText("{@st43}{#FF2222}"..sz.."敵 "..string.format("%4d匹",targetKillCount-killCount))
                else
                    txt:SetText("{@st43}{#FF2222}"..sz.."敵 全滅")
                end
                
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
