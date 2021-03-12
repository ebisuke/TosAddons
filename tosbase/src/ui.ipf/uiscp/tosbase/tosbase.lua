local g = {
    debug = true,
    baseclass = 1,
    logpath = "c:/temp/tblog.txt"
}

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
                ui.SysMsg(msg)
                
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
            ui.SysMsg(msg)
            print(msg)
            if (g.debug == true) then
                
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

function TB_LOGIN_SERVERLIST()
    ReserveScript("TB_LOGIN_SERVERLIST_DELAY()", 0.01)
    local result = TB_LOGIN_SERVERLIST_OLD()
    return result
end
function TB_LOGIN_SERVERLIST_DELAY()
    local frame = ui.GetFrame('loginui_autojoin')
    if frame:IsVisible() == 1 then
        local btn = frame:CreateOrGetControl('button', 'skillsimulator', 0, 0, 100, 80)
        btn:SetGravity(ui.LEFT, ui.BOTTOM)
        btn:SetMargin(30, 30, 30, 230)
        btn:SetText("JobSimulator")
        btn:SetEventScript(ui.LBUTTONUP, "TB_SHOW_SKILLSIMULATOR")
        local btn = frame:CreateOrGetControl('button', 'reloadscript', 0, 0, 100, 80)
        btn:SetGravity(ui.LEFT, ui.BOTTOM)
        btn:SetMargin(230, 30, 30, 230)
        btn:SetText("Reload")
        btn:SetEventScript(ui.LBUTTONUP, "TB_DEBUG_RELOAD")
    end
end
function TB_DEBUG_RELOAD()
    dofile([[E:/ToSProject/TosAddons/tosbase/src/ui.ipf/uiscp/tosbase/tosbase.lua]])
    ui.SysMsg("Reloaded.")
end
function TB_SHOW_SKILLSIMULATOR()
    EBI_try_catch{
        try = function()
            
            TB_ENTERENV()
            
            local frame = ui.CreateNewFrame('changejob', 'changejob')
            frame:ShowWindow(0)
            local frame = ui.CreateNewFrame('skillability', 'skillability')
            frame:ShowWindow(0)
            TB_RECONSTRUCT_JOB(nil, nil, nil, 1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end
--1 swordman
--2 wizard
--3 archer
--4 cleric
--5 scout
local baseclass = {
    {name = "Char1_1", clsid = 1001},
    {name = "Char2_1", clsid = 2001},
    {name = "Char3_1", clsid = 3001},
    {name = "Char4_1", clsid = 4001},
    {name = "Char5_1", clsid = 5001}

}
function TB_RECONSTRUCT_JOB(frame, ctrl, argstr, argnum)
    g.baseclass = argnum
    local frame = ui.GetFrame('changejob')
    frame:ShowWindow(1)
    frame:SetCloseScript('TB_EXIT_SKILLSIMULATOR')
    local btn1 = frame:CreateOrGetControl('button', 'btnswordman', 0, 0, 120, 40)
    local btn2 = frame:CreateOrGetControl('button', 'btnwizard', 0, 0, 120, 40)
    local btn3 = frame:CreateOrGetControl('button', 'btnarcher', 0, 0, 120, 40)
    local btn4 = frame:CreateOrGetControl('button', 'btncleric', 0, 0, 120, 40)
    local btn5 = frame:CreateOrGetControl('button', 'btnscout', 0, 0, 120, 40)
    local btn6 = frame:CreateOrGetControl('button', 'btnskill', 0, 0, 180, 40)
    btn1:SetGravity(ui.LEFT, ui.BOTTOM)
    btn1:SetMargin(30, 0, 0, 30)
    btn1:SetEventScript(ui.LBUTTONUP, "TB_RECONSTRUCT_JOB")
    btn1:SetEventScriptArgNumber(ui.LBUTTONUP, 1)
    btn1:SetText("Swordman")
    btn2:SetGravity(ui.LEFT, ui.BOTTOM)
    btn2:SetMargin(230, 0, 0, 30)
    btn2:SetEventScript(ui.LBUTTONUP, "TB_RECONSTRUCT_JOB")
    btn2:SetEventScriptArgNumber(ui.LBUTTONUP, 2)
    btn2:SetText("Wizard")
    btn3:SetGravity(ui.LEFT, ui.BOTTOM)
    btn3:SetMargin(430, 0, 0, 30)
    btn3:SetEventScript(ui.LBUTTONUP, "TB_RECONSTRUCT_JOB")
    btn3:SetEventScriptArgNumber(ui.LBUTTONUP, 3)
    btn3:SetText("Archer")
    btn4:SetGravity(ui.LEFT, ui.BOTTOM)
    btn4:SetMargin(630, 0, 0, 30)
    btn4:SetEventScript(ui.LBUTTONUP, "TB_RECONSTRUCT_JOB")
    btn4:SetEventScriptArgNumber(ui.LBUTTONUP, 4)
    btn4:SetText("Cleric")
    btn5:SetGravity(ui.LEFT, ui.BOTTOM)
    btn5:SetMargin(830, 0, 0, 30)
    btn5:SetEventScript(ui.LBUTTONUP, "TB_RECONSTRUCT_JOB")
    btn5:SetEventScriptArgNumber(ui.LBUTTONUP, 5)
    btn5:SetText("Scout")
    
    
    btn6:SetGravity(ui.RIGHT, ui.BOTTOM)
    btn6:SetMargin(0, 0, 100, 30)
    btn6:SetEventScript(ui.LBUTTONUP, "TB_SHOW_SKILL")
    btn6:SetEventScriptArgNumber(ui.LBUTTONUP, 5)
    btn6:SetText("Skill")
    CHANGEJOB_GAMESTART(frame)
end
function TB_SHOW_SKILL()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('skillability')
            frame:ShowWindow(1)
            frame:SetLayerLevel(120)
            SKILLABILITY_ON_OPEN(frame)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TB_EXIT_SKILLSIMULATOR()
    ui.DestroyFrame('changejob')
    ui.DestroyFrame('skillability')
    
    TB_LEAVEENV()
end


--TB_RETREAT
function TB_ENTERENV()
    local TB_METATABLE = {
        session = setmetatable({
            GetMyHandle = function()
                return nil
            end,
            job = {
                ReqClassResetPoint = function() end
            },
            IsEquipWeaponAbil = function(typ)
                return 1
            end,
            CanChangeJob = function()
                return 1
            end,
            GetChangeJobHotRank = function(classname)
                return 1
            end,
            GetSkillByName = function(classname)
                local skill=GetClass("Skill",classname)
                return nil
                -- return setmetatable(
                -- {
                --     GetObject = function(self)
                --         return nil
                --     end,
                --     Level = 12,
                --     GetIESID = function(self)
                --         return skill.ClassID
                --     end,
                -- },{__index=skill});
            end,
            GetSkillByGuid = function(arg)
                local skill=GetClassByType("Skill",arg)
                return nil
                -- return setmetatable(
                -- {
                --     GetObject = function(self)
                --         return nil
                --     end,
                --     Level = 12,
                --     GetIESID = function(self)
                --         return skill.ClassID
                --     end,
                -- },{__index=skill});
            end,
            ability = setmetatable({
                GetAbilityPoint = function()
                    return '10000000000'
                end
            }, {__index = session.ability})
        
        }, {__index = session}),
        ui = setmetatable({
            ReqRedisSkillPoint = function(arg)
                return nil
            end,
        
        }, {__index = ui}),
        info = setmetatable({
            GetJob = function()
                return baseclass[g.baseclass].clsid
            end,
            GetGender = function(hnd) return 1 end,
            GetLevel = function(hnd) return 460 end,
            GetName = function(ses) return "Sim" end,
        }, {__index = info}),
        IsServerSection = function(pc) return 0 end,
        GetMyPCObject = function() return {JobName = baseclass[g.baseclass].name} end,
        GetMyJobList = function() return {1001} end,
        GetMyEtcObject = function() return {JobChanging = 1} end,
        GetAbilityNamesByJob = function(pc, classname) return {} end,
        GetAbilityIESObject = function(pc, classname) return nil end,
        GetIES = function(arg) return arg end,
    }
    TB_RETREAT = TB_RETREAT or {}
    TB_LEAVEENV()
    for k, v in pairs(TB_METATABLE) do
        if _G[k] then
            TB_RETREAT[k] = _G[k]
            _G[k] = v
        end
    end

end
function TB_LEAVEENV()
    for k, v in pairs(TB_RETREAT) do
        _G[k] = v
    end
    TB_RETREAT = {}
end
local function CalcPos(x, y)
    if option.GetClientWidth() >= 3000 then
        x = x * 2
        y = y * 2
    end
    return x, y

end

if TB_LOGIN_SERVERLIST_OLD == nil and login.LoadServerList ~= TB_LOGIN_SERVERLIST then
    TB_LOGIN_SERVERLIST_OLD = login.LoadServerList
    login.LoadServerList = TB_LOGIN_SERVERLIST
end

