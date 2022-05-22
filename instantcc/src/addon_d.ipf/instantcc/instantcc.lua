--instantcc
local addonName = "INSTANTCC"
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
g.settings = {
    charactors = {}
}
g.personalsettingsFileLoc = ""
g.framename = "instantcc"
g.debug = false
g.reason = nil
--ライブラリ読み込み
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
--マップ読み込み時処理（1度だけ）
function INSTANTCC_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            acutil.setupHook(INSTANTCC_APPS_TRY_MOVE_BARRACK, "APPS_TRY_MOVE_BARRACK")
            acutil.setupHook(INSTANTCC_APPS_TRY_LOGOUT, "APPS_TRY_LOGOUT")
            acutil.slashCommand("/icc", INSTANTCC_PROCESS_COMMAND);
            acutil.slashCommand("/instantcc", INSTANTCC_PROCESS_COMMAND);
            INSTANTCC_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function INSTANTCC_APPS_TRY_MOVE_BARRACK(a,b,c,d,bno)
    return INSTANTCC_APPS_TRY_MOVE_BARRACK2(a,b,c,d,bno)
end
function INSTANTCC_APPS_TRY_MOVE_BARRACK2(a,b,c,d,bno)
    bno=bno or 1
    
    ReserveScript('INSTANTCC_APPS_TRY_MOVE_BARRACK3(a,b,c,d,'..bno..')',0.25)
end
function INSTANTCC_APPS_TRY_MOVE_BARRACK3(a,b,c,d,bno)
    EBI_try_catch {
        try = function()
            bno=bno or 1
            local context = ui.CreateContextMenu("INSTANTCC_SELECT_CHARACTOR", "Barrack "..bno, 0, 0, 300, 200)

            ui.AddContextMenuItem(context, "Return To Barrack", "INSTANTCC_DO_MOVE_BARRACK()")
            ui.AddContextMenuItem(context, "Barrack1", "INSTANTCC_APPS_TRY_MOVE_BARRACK(nil,nil,nil,nil,1)")
            ui.AddContextMenuItem(context, "Barrack2", "INSTANTCC_APPS_TRY_MOVE_BARRACK(nil,nil,nil,nil,2)")
            ui.AddContextMenuItem(context, "Barrack3", "INSTANTCC_APPS_TRY_MOVE_BARRACK(nil,nil,nil,nil,3)")
            ui.AddContextMenuItem(context, "------", "None")
            local aidx = session.loginInfo.GetAID();
            local myHandle = session.GetMyHandle();
            local myGuildIdx = 0
            local myTeamName = info.GetFamilyName(myHandle)
       
            for i = 1, #g.settings.charactors do

                if g.settings.charactors[i].layer==bno  and
                g.settings.charactors[i].aid==aidx and
                g.settings.charactors[i].server==GetServerGroupID() then
                    local char=g.settings.charactors[i]

                    local pcName = char.name

                    local jobCls = GetClassByType("Job", char.job)
                    ui.AddContextMenuItem(
                        context,
                        "Lv" .. char.level .. " {b}" .. pcName .. "{/} (" .. GET_JOB_NAME(jobCls, gender) .. ")",
                        "INSTANTCC_DO_CC('"..char.cid.."',"..bno..")"
                    )
                else
                    --CHAT_SYSTEM("FAIL")
                    --g.settings.charactors[i]=nil
                end
            end
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function INSTANTCC_APPS_TRY_LOGOUT()
    g.settings.do_cc=nil
    INSTANTCC_SAVE_SETTINGS()
    return APPS_TRY_LOGOUT_OLD()
end
function INSTANTCC_DO_MOVE_BARRACK()
    g.settings.do_cc=nil
    INSTANTCC_SAVE_SETTINGS()
    return APPS_TRY_MOVE_BARRACK_OLD()
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
function INSTANTCC_DO_CC(cid,layer)
    CHAT_SYSTEM("[ICC]Attempt to CC.")
    g.settings.do_cc={
        cid=cid,
        layer=layer
    }
    INSTANTCC_SAVE_SETTINGS()
    return APPS_TRY_MOVE_BARRACK_OLD()
end
function INSTANTCC_DEFAULT_SETTINGS()
    g.settings = {
        charactors={}
    
    }

end
function INSTANTCC_LOAD_SETTINGS()
    local aidx = session.loginInfo.GetAID();
    local myHandle = session.GetMyHandle();
	local myGuildIdx = 0
	local myTeamName = info.GetFamilyName(myHandle)
    g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
    EBI_try_catch{
        try = function()
            g.settings={}
            local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
            if err then
                --設定ファイル読み込み失敗時処理
            
                INSTANTCC_DEFAULT_SETTINGS()
            else
                --設定ファイル読み込み成功時処理
                g.settings = t
                if (not g.settings.version) then
                    g.settings.version = 0
                
                end
            end

            INSTANTCC_SAVE_SETTINGS()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function INSTANTCC_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = L_("character name needed");
        return ui.MsgBox(msg, "", "Nope")
    end
    
 
    for i = 1, #g.settings.charactors do

        if g.settings.charactors[i].name==cmd then
            local char=g.settings.charactors[i]

            INSTANTCC_DO_CC(char.cid,char.layer)
            return
        else
           
            --g.settings.charactors[i]=nil
        end
    end
    
    CHAT_SYSTEM("[ICC]Charactor Not Found.")
end
