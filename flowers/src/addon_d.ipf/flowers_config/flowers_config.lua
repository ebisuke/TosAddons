--flowers! config
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

function FLOWERS_CONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()

            FLOWERS_CONFIG_INITFRAME()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
g.garden=g.garden or {}
g.garden.selecteditem=nil
g.garden.select=function(obj)
    g.garden.selecteditem=obj
    FLOWERS_CONFIG_INITFLOWERORPETAL()
end
function FLOWERS_CONFIG_INITFLOWERORPETAL()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local gboxparent=frame:GetChild("gbox")
            local gbox=gboxparent:CreateOrGetControl("groupbox","gboxm",0,0,gboxparent:GetWidth()-250,gboxparent:GetHeight()-40)
            gbox:RemoveAllChild()
            gbox:SetMargin(0,40,20,0)
            gbox:SetGravity(ui.RIGHT,ui.TOP)
            gbox:SetSkinName("bg2")
            local gboxp=gbox:CreateOrGetControl("groupbox","gboxp",10,0,280,400)
            gboxp:RemoveAllChild()
            gboxp:SetMargin(20,40,20,0)
            gboxp:SetGravity(ui.LEFT,ui.TOP)
            gboxp:SetSkinName("bg2")
            local labelframeconfig=gboxp:CreateOrGetControl("richtext","labelframeconfig",0,0,200,40)
            labelframeconfig:SetGravity(ui.LEFT,ui.TOP)
            labelframeconfig:SetMargin(10,10,50,20)
            labelframeconfig:SetText("{ol}"..g.L("Flower/Petal Config"))

            if g.garden.selecteditem==nil then
                return
            end
            local labeltitle=gboxparent:CreateOrGetControl("richtext","labeltitle",0,0,200,40)
            labeltitle:SetGravity(ui.RIGHT,ui.TOP)
            labeltitle:SetMargin(320,10,50,20)
            labeltitle:SetText("{ol}{s20}"..g.garden.selecteditem:is().."/{s24}"..g.garden.selecteditem.name)

            local labelcondition=gbox:CreateOrGetControl("richtext","labelcondition",0,0,200,80)
            labelcondition:SetGravity(ui.LEFT,ui.TOP)
            labelcondition:SetMargin(320,20)
            labelcondition:SetText("{ol}{s20}"..g.L("Conditions"))
            FLOWERS_CONFIG_INITCONDITION()

            
            local labelaction=gbox:CreateOrGetControl("richtext","labelaction",0,0,200,80)
            labelaction:SetGravity(ui.LEFT,ui.TOP)
            labelaction:SetMargin(320,360)
            labelaction:SetText("{ol}{s20}"..g.L("Actions"))
            FLOWERS_CONFIG_INITACTION()

            local labelaction=gbox:CreateOrGetControl("richtext","labelvariables",0,0,200,80)
            labelaction:SetGravity(ui.LEFT,ui.TOP)
            labelaction:SetMargin(320,730)
            labelaction:SetText("{ol}{s20}"..g.L("Variables"))
            FLOWERS_CONFIG_INITVARIABLES()

            FLOWERS_CONFIG_INITFLOWERPETALVALUE()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_INITCONDITION_DIG(cond,level)
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local gbox=frame:GetChildRecursively("gboxcondition")
            gbox:RemoveAllChild()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_INITFLOWERPETALVALUE()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local gbox=frame:GetChildRecursively("gboxp")
            g.prefab.generateValueSetterList(frame,gbox,"gboxvalues",40,40,gbox:GetWidth(),gbox:GetHeight()-40,g.garden.selecteditem.fixedaction[1].inout)
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_INITVARIABLES()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local gboxparent=frame:GetChildRecursively("gboxm")
            local gbox=gboxparent:CreateOrGetControl("groupbox","gboxvariables",0,0,gboxparent:GetWidth()-360,320)
            gbox:SetMargin(320,760)
            gbox:SetSkinName("bg2")
            local btnAddCond=gboxparent:CreateOrGetControl("button","btnaddvariables",0,0,100,30)
            AUTO_CAST(btnAddCond)
            btnAddCond:SetText("{ol}"..g.L("Add Variable"))
            btnAddCond:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_ADD_ACTION")
            btnAddCond:SetGravity(ui.RIGHT,ui.TOP)
            btnAddCond:SetMargin(0,730,20,30)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_INITACTION()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local gboxparent=frame:GetChildRecursively("gboxm")
            local gbox=gboxparent:CreateOrGetControl("groupbox","gboxaction",0,0,gboxparent:GetWidth()-360,320)
            gbox:SetMargin(320,400)
            gbox:SetSkinName("bg2")
            local btnAddCond=gboxparent:CreateOrGetControl("button","btnaddaction",0,0,100,30)
            AUTO_CAST(btnAddCond)
            btnAddCond:SetText("{ol}"..g.L("Add Action"))
            btnAddCond:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_ADD_ACTION")
            btnAddCond:SetGravity(ui.RIGHT,ui.TOP)
            btnAddCond:SetMargin(0,370,20,30)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_INITCONDITION()
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local gboxparent=frame:GetChildRecursively("gboxm")
            local gbox=gboxparent:CreateOrGetControl("groupbox","gboxcondition",0,0,gboxparent:GetWidth()-360,300)
            gbox:SetMargin(320,60)
            gbox:SetSkinName("bg2")
            local btnAddCond=gboxparent:CreateOrGetControl("button","btnaddcondition",0,0,100,30)
            AUTO_CAST(btnAddCond)
            btnAddCond:SetText("{ol}"..g.L("Add Condition"))
            btnAddCond:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_ADD_CONDITION")
            btnAddCond:SetGravity(ui.RIGHT,ui.TOP)
            btnAddCond:SetMargin(0,30,20,30)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_INITFRAME()
    EBI_try_catch{
        try = function()

            local frame=ui.GetFrame("flowers_config")
            frame:SetLayerLevel(80)
            local gbox=frame:CreateOrGetControl("groupbox","gbox",0,0,frame:GetWidth()-20,frame:GetHeight()-120)
           
            gbox:SetGravity(ui.LEFT,ui.TOP)
            gbox:SetMargin(10,110,10,10)
            if g.debug then
                local btndebug=gbox:CreateOrGetControl("button","btndebug",0,0,30,20)
                AUTO_CAST(btndebug)
                btndebug:SetText("{s8}{ol}DBG")
                btndebug:SetEventScript(ui.LBUTTONUP,"FLOWERS_LOAD_DEBUG")
             end
            local label=gbox:CreateOrGetControl("richtext","labelflower",0,0,150,30)
            AUTO_CAST(label)
            label:SetGravity(ui.LEFT,ui.TOP)
            label:SetMargin(20,20,0,0)
            label:SetText("{ol}Flowers")
            local lstflowers=gbox:CreateOrGetControl("listbox","lstflowers",0,0,200,gbox:GetHeight()/2-80)
            AUTO_CAST(lstflowers)

            lstflowers:SetGravity(ui.LEFT,ui.TOP)
            lstflowers:SetMargin(20,40,0,0)
            lstflowers:ClearItemAll();

            lstflowers:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_SELECT_FLOWER")
            local btnadd=gbox:CreateOrGetControl("button","btnaddflower",0,0,50,30)
            AUTO_CAST(btnadd)
            btnadd:SetText("{ol}"..g.L("Add"))
            btnadd:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_ADDFLOWER")
            btnadd:SetGravity(ui.LEFT,ui.TOP)
            btnadd:SetMargin(150+20,15,0,0)
            --petal
            local label=gbox:CreateOrGetControl("richtext","labelpetals",0,0,150,30)
            AUTO_CAST(label)
            label:SetGravity(ui.LEFT,ui.TOP)
            label:SetMargin(20,gbox:GetHeight()/2-80+40+20,0,0)
            label:SetText("{ol}Petals")
            local lstpetals=gbox:CreateOrGetControl("listbox","lstpetals",0,0,200,gbox:GetHeight()/2-80)
            AUTO_CAST(lstpetals)
            lstpetals:SetGravity(ui.LEFT,ui.TOP)
            lstpetals:SetMargin(20,gbox:GetHeight()/2-80+40+40,0,0)
            lstpetals:ClearItemAll();
            
            lstpetals:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_SELECT_PETAL")
            local btnadd=gbox:CreateOrGetControl("button","btnaddpetal",0,0,50,30)
            AUTO_CAST(btnadd)
            btnadd:SetText("{ol}"..g.L("Add"))
            btnadd:SetEventScript(ui.LBUTTONUP,"FLOWERS_CONFIG_ADDPETAL")
            btnadd:SetGravity(ui.LEFT,ui.TOP)
            btnadd:SetMargin(150+20,gbox:GetHeight()/2-80+40+15,0,0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_ADDFLOWER()
    INPUT_STRING_BOX_CB(ui.GetFrame("flowers_config"),g.L("Enter Flower Name"), "FLOWERS_CONFIG_DO_ADDFLOWER", "", nil, nil,  128,false);

end
function FLOWERS_CONFIG_DO_ADDFLOWER(inputframe,changedName )
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_config")
            local lstflowers=frame:GetChildRecursively("lstflowers")
        
            AUTO_CAST(lstflowers)
            lstflowers:AddItem(changedName,#g.garden.flowers)
            lstflowers:Invalidate()
            g.garden.flowers[#g.garden.flowers+1] = g.classes.TFlower.new(changedName)
            g.garden.select(g.garden.flowers[#g.garden.flowers])
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_CONFIG_ADDPETAL()
 
end
function FLOWERS_CONFIG_SELECT_FLOWER(frame)
end
function FLOWERS_CONFIG_SELECT_PETAL(frame)
end

function FLOWERS_CONFIG_TOGGLE_FRAME()
    ui.ToggleFrame("flowers_config")
end

function FLOWERS_CONFIG_ADD_CONDITION()
    local temp=g.classes.TCondition.new()
    FLOWERS_CONDITION_SHOW(temp,function()
    end)
end