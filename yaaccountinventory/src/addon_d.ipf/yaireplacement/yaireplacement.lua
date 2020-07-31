-- YAI
local addonName = "YAACCOUNTINVENTORY"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

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
        try=function()
            if(g.debug==true)then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd=io.open (g.logpath,"a")
                fd:write(msg.."\n")
                fd:flush()
                fd:close()
                
            end
        end,
        catch=function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try=function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch=function(error)
        end
    }

end
function YAIREPLACEMENT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
