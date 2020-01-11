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

local g = {}
g.debug = false

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
function EWSC_TOGGLE()
    ui.ToggleFrame("enhancedweaponswapconfig")
end


-- ライブラリ読み込み
function ENHANCEDWEAPONSWAPCONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            EWSC_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


