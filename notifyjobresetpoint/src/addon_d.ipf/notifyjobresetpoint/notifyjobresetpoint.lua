--アドオン名（大文字）
local addonName = "notifyjobresetpoint"
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
g.framename = "notifyjobresetpoint"
g.debug = false
g.endo=false
g.currentaid= g.currentaid or nil
g.currentpt= g.currentpt or nil
g.forced=false
--ライブラリ読み込み
CHAT_SYSTEM("[NJRP]loaded")
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


--マップ読み込み時処理（1度だけ）
function NOTIFYJOBRESETPOINT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            addon:RegisterMsg("UPDATE_CLASS_RESET_POINT_INFO", "NJRP_ON_UPDATE_CLASS_RESET_POINT_INFO");
            addon:RegisterMsg("GAME_START", "NJRP_ON_GAMESTART");
            addon:RegisterMsg('INDUN_REWARD_RESULT', 'NJRP_INDUN_REWARD_SET')
            if not g.loaded then
                
                g.loaded = true
            end

            --CHALLENGEMODESTUFF_SHOW(g.frame)
            DBGOUT("INIT")
            --CHALLENGEMODESTUFF_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function NJRP_ON_UPDATE_CLASS_RESET_POINT_INFO(frame, msg, argStr, argNum)	
    NJRP_NOTIFY_RESETPT()
end
function NJRP_INDUN_REWARD_SET()
    g.forced=true
    --ReserveScript("session.job.ReqClassResetPoint()",2)
end
function NJRP_ON_GAMESTART()
    --session.job.ReqClassResetPoint();
end
function NJRP_NOTIFY_RESETPT()
    local curExp = session.job.GetClassResetPointExp();
    if((NJRP_UPDATE_RESETPT() or g.forced) and ui.IsFrameVisible("changejob")~=1)then
        CHAT_SYSTEM(string.format("{img class_tree_reset_icon 20 20}{b}転職ポイント %d",curExp))
    end
    g.forced=false
end
function NJRP_UPDATE_RESETPT()
    local aid=session.GetMySession():GetCID();
    local curExp = session.job.GetClassResetPointExp();
    local notify=false
    if(g.currentaid~=nil)then
        if(g.currentaid==aid)then
            if(g.currentpt~=curExp)then
               
                notify= true
            end
       
        end
    end
    g.currentaid=aid
    g.currentpt=curExp
    return notify
end