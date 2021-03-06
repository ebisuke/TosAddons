--uie_gbg_market_buy


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

g.gbg.uiegbgMarketBuy={
    new=function(frame,name,caption)
        local self=inherit(g.gbg.uiegbgMarketBuy,g.gbg.uiegbgBase,frame,name,caption or g.tr('marketbuy') )
        return self
    end,
    initializeImpl=function(self,gbox)
        local search=g.gbg.uiegbgComponentMarketSearch.new(self,'search',function(component,cat)
            print('FIND!'..cat.name)
            self:onSelectedCategory(cat)
        end)
     
        self:addComponent(search)
        local view=g.gbg.uiegbgComponentMarketBuy.new(self,'view',
        {onclicked=function(view)
        end})
        view:initialize(gbox:GetWidth()/4-50,20,gbox:GetWidth()-gbox:GetWidth()/4-100,gbox:GetHeight()-120)
        self:addComponent(view)
       
        search:initialize(50,20,gbox:GetWidth()/4-100,gbox:GetHeight()-120)
        
    end,
    postInitializeImpl=function(self,gbox)
        local search=self:getComponent('search')
        search:attachDefaultHandler()
    end,
    onSelectedCategory=function(self,cat)
        local view=self:getComponent('view')
        view:reset()
        view:search(cat)
    end,
    -- defaultHandlerImpl = function(self,key,frame)
    --     --override me
    --     return g.uieHandlergbgComponentTracer.new(key,frame,self)
    -- end,
}
UIMODEEXPERT = g