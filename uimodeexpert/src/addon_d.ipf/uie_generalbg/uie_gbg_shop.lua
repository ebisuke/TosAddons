--uie_gbg_shop
local acutil = require('acutil')



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



g.gbg.uiegbgShop={
    new=function(frame,name,caption)
        local shopName = session.GetCurrentShopName()
        local self=inherit(g.gbg.uiegbgShop,g.gbg.uiegbgBase,frame,name,caption or  'ショップ')
        return self
    end,
    initializeImpl=function(self,gbox)

        local inv=g.gbg.uiegbgComponentInventory.new(self,gbox,'inventory',false)
        inv:initialize(gbox:GetWidth()/2+100,60,gbox:GetWidth()/2-120,gbox:GetHeight()-190)
        self:addComponent(inv)
        local shop=g.gbg.uiegbgComponentShop.new(self,gbox,'shop')
        shop:initialize(60,60,gbox:GetWidth()/2-80,gbox:GetHeight()-190)
        self:addComponent(shop)
        local zeny=g.gbg.uiegbgComponentFund.new(self,gbox,'fund')
        zeny:initialize(gbox:GetWidth()-260,10,200,50)
        self:addComponent(zeny)
        local under=g.gbg.uiegbgComponentUnderBtn.new(self,gbox,'under',{
            {
                name="determine",
                caption='精算',
                callback=function() self:adjustment() end,

            },
            {
                name="cancel",
                caption='キャンセル',
                callback=function() self:adjustment() end,
            }
        })
        under:initialize(100,gbox:GetHeight()-140,gbox:GetWidth()-200,100)
        
        self:addComponent(under)
    end,
    adjustment=function(self)
    end

}
UIMODEEXPERT = g
