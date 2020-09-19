--uie_overrider

local acutil = require('acutil')

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



UIMODEEXPERT=UIMODEEXPERT or {}
local g=UIMODEEXPERT
g.over={
    
}

UIMODEEXPERT=g;
