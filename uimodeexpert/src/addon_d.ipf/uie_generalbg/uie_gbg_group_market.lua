--uie_gbg_group_market


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

g.gbg.uiegbgGroupMarket={
    new=function(frame,name,caption,initindex)
        local self=inherit(g.gbg.uiegbgGroupMarket,g.gbg.uiegbgGroupBase,frame,name,caption or g.tr('market'),initindex )
        self:addChild(g.gbg.uiegbgMarketBuy.new(frame,'gp_market_buy',nil,self))
        return self
    end,
    initializeImpl=function(self,gbox)
        ui.GetFrame('market'):SetLayerLevel(98)
    end,
    releaseImpl=function (self)
        g.gbg.uiegbgGroupBase.releaseImpl(self)
        ui.GetFrame('inventory'):ShowWindow(0)
    end
}
UIMODEEXPERT = g