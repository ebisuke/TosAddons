--uie_tip

local acutil = require('acutil')
local framename="uie_tip"
--ライブラリ読み込み

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
function UIE_TIP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(framename)
            frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


UIMODEEXPERT=UIMODEEXPERT or {}
local g=UIMODEEXPERT

g=table.concat(g,{
    
});
UIMODEEXPERT=g;
