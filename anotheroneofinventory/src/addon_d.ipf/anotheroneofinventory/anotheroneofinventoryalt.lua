
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
function ANOTHERONEOFINVENTORYALT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame:SetOffset(1920/2-250,1080/2-250)
            frame:ShowWindow(0)
            local timer = GET_CHILD(frame, "aoi_addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("AOI_ALT_ON_TIMER");
            timer:Start(0.01);
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_ON_TIMER(frame)
end

function AOI_ALT_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            frame:EnableMove(1)            frame:SetSkinName("None")
            frame:EnableHittestFrame(0)
           
            
            AOI_RESIZE()
            AOI_INV_REFRESH()
        
  
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
