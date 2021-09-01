--uie_gbg_shop
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

g.gbg.uiegbgShop={
    new=function(frame,name,caption)
        local shopName = session.GetCurrentShopName()
        local self=inherit(g.gbg.uiegbgShop,g.gbg.uiegbgBase,frame,name,caption or g.tr('shop'))
        return self
    end,
    initializeImpl=function(self,gbox)

        local inv=g.gbg.uiegbgComponentShopInventory.new(self,'inventory',function()
            self:update()
        end,{
            tooltipxy={x=60,y=30}
            })
        inv:initialize(gbox:GetWidth()/2+140,60,gbox:GetWidth()/2-160,gbox:GetHeight()-250)
        self:addComponent(inv)
        local shop=g.gbg.uiegbgComponentShop.new(self,'shop',function()
            self:update()
        end,{x=gbox:GetWidth()/2+60,y=30})
        shop:initialize(60,60,gbox:GetWidth()/2-120,gbox:GetHeight()-250)
        self:addComponent(shop)
        local zeny=g.gbg.uiegbgComponentFund.new(self,'fund')
        zeny:initialize(gbox:GetWidth()-260,10,200,50)
        self:addComponent(zeny)
        local trade=g.gbg.uiegbgComponentTradeResult.new(self,'trade',inv,shop)
        trade:initialize(gbox:GetWidth()/2-75,75,150,200)
        self:addComponent(trade)
        local under=g.gbg.uiegbgComponentUnderBtn.new(self,'under',{
            {
                name="clear",
                caption='空にする',
                callback=function() inv:reset();shop:reset(); end,

            },
            {
                name="determine",
                caption='精算',
                callback=function() self:adjustment();self:close(); end,

            },
            {
                name="cancel",
                caption='キャンセル',
                callback=function() self:close() end,
            }
        })
        under:initialize()
        
        self:addComponent(under)

        
    end,
    defaultHandlerImpl = function(self,key,frame)
        --override me
        return g.uieHandlergbgShop.new(key,frame,self)
    end,
    update=function(self)
        local shop=self:getComponent('shop')
        local buy=shop:calcTotalValue()
        local inventory=self:getComponent('inventory')
        local sell=inventory:calcTotalValue()
        local trade=self:getComponent('trade')
        local balance=SumForBigNumberInt64(buy,'-'..sell)
        trade:updateBalance(balance)
    end,
    adjustment=function(self)
        local shop=self:getComponent('shop')
        local buy=shop:calcTotalValue()
        local inventory=self:getComponent('inventory')
        local sell=inventory:calcTotalValue()
        local trade=self:getComponent('trade')
        local balance=SumForBigNumberInt64(buy,'-'..sell)
        if IsGreaterThanForBigNumber(balance, GET_TOTAL_MONEY_STR()) == 1 then
            ui.AddText("SystemMsgFrame", ClMsg('NotEnoughMoney'));
            return;
        end
        self:doSell()
        self:doBuy()
        imcSound.PlaySoundEvent("market_sell");

    end,
    doSell=function(self)
        local inventory=self:getComponent('inventory')
        for _,v in ipairs(inventory.invItemList) do
            if v.amount and v.amount >0 then
                item.AddToSellList(v.item:GetIESID(), v.amount);
            end
        end
        item.SellList();
    end,
    doBuy=function(self)
        local inventory=self:getComponent('shop')
        for _,v in ipairs(inventory.invItemList) do
            if v.amount and v.amount >0 then
                if GET_SHOP_ITEM_MAXSTACK(v.item)~=-1 then
                    item.AddToBuyList(v.item.classID, v.amount);
                else
                    for i=1,v.amount do
                        item.AddToBuyList(v.item.classID, 1);
                    end
                end
               
            end
        end
        item.BuyList();
    end,
    reset=function(self)
        local inv =self:getComponent('inventory')
        local shop =self:getComponent('shop')
        
        inv:reset();
        shop:reset();
    end,
}
g.uieHandlergbgShop = {
    new = function(key, frame,gbg)
        local self = inherit(g.uieHandlergbgShop, g.uieHandlergbgBase, key,frame,gbg)
        self.endo=false
        return self
    end,
    delayedenter = function(self)
        self:refresh()
    end,
    refresh = function(self)
        g.uieHandlergbgBase.refresh(self)
        if self.menu then
            self.menu:dispose()
            self.menu=nil
        end
        self.menu=g.menu.uiePopupMenu.new(nil,100,400,40,nil,function()
            self.gbg:close()


        end)
        local menu=self.menu
        menu:addMenu('{ol}かごを空にする',function()
            self.gbg:reset()
        end,false)
        menu:addMenu('{ol}買う',function()
            self.gbg:getComponent('shop'):attachDefaultHandler()
        end)
        menu:addMenu('{ol}売る',function()
            self.gbg:getComponent('inventory'):attachDefaultHandler()
        end)
        
        menu:addMenu('{ol}精算',function()
            self.gbg:adjustment()
            self.gbg:close()
            
        end)
        menu:addMenu('{ol}キャンセル',function()
            self.gbg:close()
           
        end)
    end,
    leave=function(self)
        g.uieHandlergbgBase.leave(self)
        if self.menu then
            self.menu:dispose()
            self.menu=nil
        end
    end,
    gbgTick = function(self)
        if self.endo then
            if self.menu then
                self.menu:dispose()
                self.menu=nil
            end
            return g.uieHandlerBase.RefEnd
        end

        return g.uieHandlerBase.RefPass
    end
}
UIMODEEXPERT = g
