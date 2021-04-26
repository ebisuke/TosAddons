--flowers! value
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
local cv={}
local okcallbacks={}
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
function FLOWERS_VALUE_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()

        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function FLOWERS_VALUE_INITFRAME(frame,currentinpipe)
    
    EBI_try_catch{
        try = function()
            local frame=ui.GetFrame("flowers_value")
            local gbox=frame:CreateOrGetControl("groupbox","gbox",0,100,frame:GetWidth(),frame:GetHeight()-100)
            gbox:RemoveAllChild()
            local btnok=gbox:CreateOrGetControl("button","btnok",0,0,100,30)

            


            btnok:SetMargin(60,0,0,20)
            btnok:SetGravity(ui.LEFT,ui.BOTTOM)
            btnok:SetText("{ol}"..g.L("OK"))
            btnok:SetEventScript(ui.LBUTTONUP,"FLOWERS_VALUE_ONOK")
         

            local btncancel=gbox:CreateOrGetControl("button","btncancel",0,0,100,30)
            btncancel:SetMargin(20,0,60,20)
            btncancel:SetGravity(ui.RIGHT,ui.BOTTOM)
            btncancel:SetText("{ol}"..g.L("Cancel"))
            btncancel:SetEventScript(ui.LBUTTONUP,"FLOWERS_VALUE_ONCANCEL")
            local gbox2=frame:CreateOrGetControl("groupbox","gboxv",50,300,300,100)
            
            g.prefab.generateValueSetter(gbox2,0,currentinpipe)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_VALUE_ONOK(frame)
    if okcallbacks then
        okcallbacks[#okcallbacks](cv[#cv])
    end
    
    frame:ShowWindow(0)
end
function FLOWERS_VALUE_ONCANCEL(frame)
    
    frame:ShowWindow(0)
    
end
function FLOWERS_VALUE_ON_CLOSE(frame)
    frame:ShowWindow(0)
end
function FLOWERS_VALUE_ON_CLOSE(frame)
    local frameno=frame:GetUserIValue("FRAME_NO")
    ui.DestroyFrame("flowers_value_"..frameno)
    cv[frameno]=nil
    okcallbacks[frameno]=nil
    --table.remove(cv,frameno)
    --table.remove(okcallbacks,frameno)
end

function FLOWERS_VALUE_SHOW(currentinpipe,okcb)
    table.insert(cv,currentinpipe)
    table.insert(okcallbacks,okcb)

    local frame=ui.CreateNewFrame("flowers_value","flowers_value_"..#cv)
    frame:ShowWindow(1)
    frame:SetUserValue("FRAME_NO",#cv)
    FLOWERS_VALUE_INITFRAME(frame,currentinpipe)
end