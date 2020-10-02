--uie_cursor

local acutil = require('acutil')
local framename="uie_cursor"
--ライブラリ読み込み
local debug=false
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
            if (debug == true) then
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
function UIE_CURSOR_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(framename)
            frame:ShowWindow(1)
            frame:SetSkinName('none')
            frame:SetGravity(ui.LEFT,ui.TOP)
            local slot=frame:CreateOrGetControl("slot","slot1",0,0,0,0)
            AUTO_CAST(slot)
            slot:SetSkinName('invenslot_magic')
            local timer=frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript('UIE_CURSOR_ON_TICK')
            timer:Start(0.01)
            frame:SetLayerLevel(200)
            
            slot:SetBlink(0, 2.0, '77FFFFFF', 1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_CURSOR_ON_TICK(frame)
    local slot=frame:GetChild("slot1")
    AUTO_CAST(slot)
    slot:Resize(frame:GetWidth(),frame:GetHeight())
end
UIMODEEXPERT=UIMODEEXPERT or {}
local g=UIMODEEXPERT



UIMODEEXPERT=g;
