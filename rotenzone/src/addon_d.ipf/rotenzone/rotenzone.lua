-- rotenzone
local addonName = "ROTENZONE"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")

g.version = 1
g.settings = g.settings or {}
g.framename = "rotenzone"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[RZ]loaded")
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
local function AUTO_CAST(ctrl)
    if (ctrl == nil) then
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
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

function ROTENZONE_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg("FPS_UPDATE", "ROTENZONE_FPS")

            g.frame:ShowWindow(1)
            local timer = g.frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript("ROTENZONE_TIMER")
            timer:Start(0.00)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ROTENZONE_FPS()
    EBI_try_catch {
        try = function()
            ui.GetFrame("rotenzone"):ShowWindow(1)
            g.hooked = true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ROTENZONE_TIMER()
    EBI_try_catch {
        try = function()
           if keyboard.IsKeyPressed("LSHIFT") == 1 then
                local pc = GetMyPCObject()
                local x, y, z = GetPos(pc)
                local actor = GetMyActor()
                local range = 50
                local jobGrade = GetJobGradeByName(pc, "Char5_4")
                if (jobGrade ~= nil and jobGrade > 0) then
                    range = 50
                end
                local jobGrade = GetJobGradeByName(pc, "Char2_5")
                if (jobGrade ~= nil and jobGrade > 0) then
                    range = 60
                end
                if 0 == IsFarFromNPC(pc, x, y, z, range) or keyboard.IsKeyPressed("LALT") == 1 then
                    local list, cnt
                    if keyboard.IsKeyPressed("LALT") == 1 then
                        list, cnt = SelectObject(actor, 300, 'ALL',1)
                    else
                        list, cnt = SelectObject(actor, range, 'ALL',1)
                    end
                    local i
                    for i = 1, cnt do
                        local npc=world.GetActor( GetHandle(list[i]))
                        local targetMonRank = info.GetMonRankbyHandle(GetHandle(list[i]));
                        local monCls=GetClassByType("Monster", npc:GetType());
                        local ownerHandle = info.GetOwner(GetHandle(list[i]));
                        local npcPos=npc:GetPos();
                        if( ownerHandle==0 and npc:GetPCApc():GetFamilyName()=="") 
                            and 0 == IsFarFromNPC(pc,npcPos.x, npcPos.y, npcPos.z, 1) then
                          
                           
                            local posnpc=npc:GetPos()
                            debug.DrawPos(posnpc.x,posnpc.y,posnpc.z,range*2)
                        end
                    end
                    if  0 == IsFarFromNPC(pc, x, y, z, range)  then
                        actor:SetAuraInfo("EliteBuff")
                        g.eliteflag=true
                    else
                        actor:SetAuraInfo("")
                        g.eliteflag=false
                    end
                else
                    actor:SetAuraInfo("")
                    g.eliteflag=false
                end
            else
                if(g.eliteflag==true) then 
                    local actor = GetMyActor()
                    actor:SetAuraInfo("")
                    g.eliteflag=false
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
