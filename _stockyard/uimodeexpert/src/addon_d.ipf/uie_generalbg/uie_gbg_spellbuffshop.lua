--uie_gbg_spellbuffshop
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

g.gbg = g.gbg or {}

g.gbg.uiegbgSpellBuffShop = {
    current=nil,
    new = function(frame, name, caption)
        local self = inherit(g.gbg.uiegbgSpellBuffShop, g.gbg.uiegbgBase, frame, name, caption or g.tr('spellbuffshop'))
        return self
    end,
    initializeImpl = function(self, gbox)
        local zeny = g.gbg.uiegbgComponentFund.new(self, 'fund')
        zeny:initialize(gbox:GetWidth() - 260, 10, 200, 50)
        self:addComponent(zeny)
        self.lowdur =
            g.util.getEquipItemList(
            function(invItem)
                local itemobj = GetIES(invItem:GetObject())

                local needitem, needcount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj)
                if IS_NEED_REPAIR_ITEM(itemobj, 1) == true then
                    if itemobj.Dur / itemobj.MaxDur <= 0.7 then
                        return true
                    end
                end

                return false
            end
        )
        local frame = ui.GetFrame("buffseller_target");
        local sellType = frame:GetUserIValue("SELLTYPE");
        local groupName = frame:GetUserValue("GROUPNAME");
        
        local cnt = session.autoSeller.GetCount(groupName);
        for i = 0 , cnt - 1 do
            local info = session.autoSeller.GetByIndex(groupName, i);
           
            local buffCls = GetClassByType('Buff', info.classID);
            local spendItemName, spendItemCount, captionTimeScp, captionList, captionRatioScpList=
             GetBuffSellerInfoByBuffName(buffCls.ClassName);
            local text=gbox:CreateOrGetControl('richtext','buff'..i,50,50+i*50,0,50)
            
            text:SetText(
                string.format('{ol}{img icon_%s 40 40}{s28} %s{/}(%d個) %s',
                buffCls.Icon,
                buffCls.Name,
                info.remainCount,
                g.util.generateSilverString(info.price,40)))
        end


        local under =
            g.gbg.uiegbgComponentUnderBtn.new(
            self,
            'under',
            {
                {
                    name = 'applyallbuff',
                    caption = g.tr('applyallbuff') .. '{nl}' .. g.util.generateSilverString(self:calcPrice(), 30),
                    callback = function()
                        self:buffAll()
                        self:close()
                    end
                },
                {
                    name = 'cancel',
                    caption = g.tr('cancel'),
                    callback = function()
                        self:close()
                    end
                }
            }
        )
        under:initialize()

        self:addComponent(under)
    end,
    calcPrice = function(self, invItemList)
        local frame = ui.GetFrame("buffseller_target");
        local sellType = frame:GetUserIValue("SELLTYPE");
        local groupName = frame:GetUserValue("GROUPNAME");
        
        local cnt = session.autoSeller.GetCount(groupName);
        local total=0
        for i = 0 , cnt - 1 do
            local info = session.autoSeller.GetByIndex(groupName, i);
           
            local buffCls = GetClassByType('Buff', info.classID);
            local spendItemName, spendItemCount, captionTimeScp, captionList, captionRatioScpList=
             GetBuffSellerInfoByBuffName(buffCls.ClassName);

            total=total+info.price
        end
        return total
    end,
    buffAll = function(self)
        local frame = ui.GetFrame("buffseller_target");
        local sellType = frame:GetUserIValue("SELLTYPE");
        local groupName = frame:GetUserValue("GROUPNAME");
        local cnt = session.autoSeller.GetCount(groupName);
        if IsGreaterThanForBigNumber(self:calcPrice(), GET_TOTAL_MONEY_STR()) == 1 then
            ui.SysMsg(ClMsg("NotEnoughMoney"));
            return;
        end
        for i = 0 , cnt - 1 do
            local info = session.autoSeller.GetByIndex(groupName, i);
           
            ReserveScript(string.format('session.autoSeller.Buy(%d,%d,%d,%d)',frame:GetUserIValue("HANDLE"),i,1,sellType),0.5*i)

        end
     

    end,
    releaseImpl = function(self)

    end,
    defaultHandlerImpl = function(self, key, frame)
        --override me
        return g.uieHandlergbgSpellBuffShop.new(key, frame, self)
    end
}

g.uieHandlergbgSpellBuffShop = {
    new = function(key, frame, gbg)
        local self = inherit(g.uieHandlergbgSpellBuffShop, g.uieHandlergbgBase, key, frame, gbg)
        
        return self
    end,
    delayedenter = function(self)
        self:refresh()
    end,
    refresh = function(self)
        g.uieHandlergbgBase.refresh(self)
        if self.menu then
            self.menu:dispose()
            self.menu = nil
        end
        self.menu =
            g.menu.uiePopupMenu.new(
            self.frame:GetWidth() - 700,
            100,
            400,
            40,
            nil,
            function()
                self.gbg:close()
            end
        )
        local menu = self.menu
        menu:addMenu(
            '{ol}すべてのバフを適用する',
            function()
                self.gbg:buffAll()
                self.gbg:close()
            end
            
        )

        menu:addMenu(
            '{ol}キャンセル',
            function()
                self.gbg:close()
            end
        )
    end,
    leave = function(self)
        g.uieHandlergbgBase.leave(self)
        if self.menu then
            self.menu:dispose()
            self.menu = nil
        end
    end,
    gbgTick = function(self)
        if self.endo then
            if self.menu then
                self.menu:dispose()
                self.menu = nil
            end
            return g.uieHandlerBase.RefPass
        end

        return g.uieHandlerBase.RefPass
    end
}

UIMODEEXPERT = g
