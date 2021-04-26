--flowers! class_conf_prefab
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

g.prefab={
    pipecache={},
    
    generateValueSetter=function(gbox,offsety,inpipe)
        local gboxinner=gbox:CreateOrGetControl("groupbox","gboxinner_"..inpipe.name,0,offsety,300,60)
        AUTO_CAST(gboxinner)
        gboxinner:RemoveAllChild()
        local rtext=gboxinner:CreateOrGetControl("richtext","in_"..inpipe.name,40,3,200,30)
        rtext:SetText("{ol}"..inpipe.description)
        local btn=gboxinner:CreateOrGetControl("button","toggler",0,0,40,30)
        AUTO_CAST(btn)
        btn:SetEventScript(ui.LBUTTONUP,"FLOWERS_CLASS_CONF_PREFAB_TOGGLE_VALUETYPE")
        btn:SetEventScriptArgString(ui.LBUTTONUP,inpipe.name)
        g.prefab.pipecache[inpipe.name]={gbox=gbox,offsety=offsety,inpipe=inpipe}
     
        if inpipe.variable.is()=="TVariable" then
            -- immediate value
           
            AUTO_CAST(edit)
            btn:SetText("{ol}IM")
            local edit=gboxinner:CreateOrGetControl("edit","inedit",0,30,150,30)
            edit:SetText(tostring(inpipe.variable:GetValue()))
        elseif inpipe.variable:is()=="TVariableLua" then
            -- lua
            local edit=gboxinner:CreateOrGetControl("edit","inedit",0,30,150,30)
            AUTO_CAST(edit)
            btn:SetText("{ol}Lua")
            edit:SetText(tostring(inpipe.variable:GetValue()))
        elseif inpipe.variable:is()=="TVariableReference" then
            -- refer
            local btn2=gboxinner:CreateOrGetControl("button","inref",0,30,150,30)
            AUTO_CAST(btn2)
            btn:SetText("{ol}Ref")             
        elseif inpipe.variable:is()=="TVariableFunction" then
            -- func
            local btn2=gboxinner:CreateOrGetControl("button","infunc",0,30,150,30)
            AUTO_CAST(btn2)
            btn:SetText("{ol}Func")
        end
        return 60
    end,
    generateValueSetterList=function(frame,parent,gboxname,x,y,w,h,inout)
        if parent==nil then
            parent=frame
        end
        local gbox=parent:CreateOrGetControl("groupbox",gboxname,x,y,w,h)
        AUTO_CAST(gbox)
        local height=0
        for k,v in ipairs(inout.ins) do
            
            height=height+g.prefab.generateValueSetter(gbox,height,v)
        end
    end
}
function FLOWERS_CLASS_CONF_PREFAB_TOGGLE_VALUETYPE(frame,ctrl,argstr,argnum)

    local pipe=g.prefab.pipecache[argstr]
    local inpipe=pipe.inpipe
    if inpipe.variable:is()=="TVariable" then
        inpipe.variable=g.classes.TVariableLua.new()
    elseif inpipe.variable:is()=="TVariableLua" then
        inpipe.variable=g.classes.TVariableReference.new()
    elseif inpipe.variable:is()=="TVariableReference" then
        inpipe.variable=g.classes.TVariableFunction.Functions.Noop()
    elseif inpipe.variable:is()=="TVariableFunction" then
        inpipe.variable=g.classes.TVariable.new(nil,nil,nil,inpipe.type)
    end


    if pipe then
        g.prefab.generateValueSetter(pipe.gbox,pipe.offsety,pipe.inpipe)
    end
end