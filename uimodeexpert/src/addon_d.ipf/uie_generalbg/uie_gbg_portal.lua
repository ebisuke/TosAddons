--uie_gbg_portal


local acutil = require('acutil')

--ライブラリ読み込み
local debug = false
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end
local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
                fd:flush()
                fd:close()
            end
        end,
        catch = function(error)
        end
    }
end
local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT

g.gbg=g.gbg or {}

g.gbg.uiegbgPortal={
    new=function(frame,name,caption)
        local self=inherit(g.gbg.uiegbgInventory,g.gbg.uiegbgBase,frame,name,caption or g.tr('portalshop') )
        return self
    end,
    initializeImpl=function(self,gbox)

     
        local zeny=g.gbg.uiegbgComponentFund.new(self,'fund')
        zeny:initialize(gbox:GetWidth()-260,20,200,40)
        self:addComponent(zeny)

        
    end,
}
UIMODEEXPERT = g
