--flowers! condition
local addonName = "flowers"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local currentcond=nil
local okcb=nil
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
function FLOWERS_CONDITION_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()

        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function FLOWERS_CONDITION_TOGGLE_FRAME()
    
end
function FLOWERS_CONDITION_INITFRAME()
    
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_condition")
            local gbox=frame:CreateOrGetControl("groupbox","gbox",0,100,frame:GetWidth(),frame:GetHeight()-100)
            local btnok=gbox:CreateOrGetControl("button","btnok",0,0,100,30)
            btnok:SetMargin(60,0,0,20)
            btnok:SetGravity(ui.LEFT,ui.BOTTOM)
            btnok:SetText("{ol}"..g.L("OK"))
            btnok:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONDITION_ONOK")
            local btncancel=gbox:CreateOrGetControl("button","btncancel",0,0,100,30)
            btncancel:SetMargin(20,0,60,20)
            btncancel:SetGravity(ui.RIGHT,ui.BOTTOM)
            btncancel:SetText("{ol}"..g.L("Cancel"))
            btncancel:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONDITION_ONCANCEL")

            local label=gbox:CreateOrGetControl("richtext","labellhs",0,0,100,30)
            label:SetText("{ol}"..g.L("LHS"))
            label:SetMargin(20,100,20,0)
            label:SetGravity(ui.LEFT,ui.TOP)
            local label=gbox:CreateOrGetControl("richtext","labelcomp",0,0,100,30)
            label:SetText("{ol}"..g.L("Comparator"))
            label:SetMargin(240,100,20,0)
            label:SetGravity(ui.LEFT,ui.TOP)
            local label=gbox:CreateOrGetControl("richtext","labelrhs",0,0,100,30)
            label:SetText("{ol}"..g.L("RHS"))
            label:SetMargin(20,100,20,0)
            label:SetGravity(ui.RIGHT,ui.TOP)
            local button=gbox:CreateOrGetControl("button","buttonlhs",0,0,200,30)
    
            button:SetMargin(20,140,20,0)
            button:SetGravity(ui.LEFT,ui.TOP)
            button:SetEventScript(ui.LBUTTONUP,"FLOWER_CONDITION_SETVALUE_LHS")
            local list=gbox:CreateOrGetControl("droplist","listcomp",0,0,140,30)
            AUTO_CAST(list)
            list:SetMargin(230,140,20,0)
            list:SetGravity(ui.LEFT,ui.TOP)
            list:SetSkinName("droplist_normal")
            list:ClearItems()
            for k,v in ipairs(g.classes.TComparator.Comparators) do
                
                local val=v()
                list:AddItem(k-1,"{ol}"..val.text)

            end
            local button=gbox:CreateOrGetControl("button","buttonrhs",0,0,200,30)

            button:SetMargin(20,140,20,0)
            button:SetGravity(ui.RIGHT,ui.TOP)
            button:SetEventScript(ui.LBUTTONUP,"FLOWER_CONDITION_SETVALUE_RHS")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONDITION_ONOK()
    if okcb then
        okcb(currentcond)
    end
    local frame=ui.GetFrame("flowers_condition")
    frame:ShowWindow(0)
end
function FLOWERS_CONDITION_ONCANCEL()
    local frame=ui.GetFrame("flowers_condition")
    frame:ShowWindow(0)
end
function FLOWERS_CONDITION_SHOW(cond,okcb)
    currentcond=cond
    okcb=okcb
    local frame=ui.GetFrame("flowers_condition")
    frame:ShowWindow(1)
    FLOWERS_CONDITION_INITFRAME()
end
function FLOWER_CONDITION_SETVALUE_LHS()
    FLOWERS_VALUE_SHOW(currentcond:GetLHS())
end

function FLOWER_CONDITION_SETVALUE_RHS()
    FLOWERS_VALUE_SHOW(currentcond:GetRHS())
end