--uie_gbg_repair
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

g.gbg.uiegbgRepair = {
    new = function(frame, name, caption)
        local self = inherit(g.gbg.uiegbgRepair, g.gbg.uiegbgBase, frame, name, caption or g.tr('repair'))
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
        self.allequip =
            g.util.getEquipItemList(
            function(invItem)
                local itemobj = GetIES(invItem:GetObject())

                local needitem, needcount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj)
                if IS_NEED_REPAIR_ITEM(itemobj, 1) == true then
                    return true
                end

                return false
            end
        )
        self.lowdurinv =
            g.util.getInvItemList(
            function(invItem)
                local itemobj = GetIES(invItem:GetObject())
                local needitem, needcount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj)
                if IS_NEED_REPAIR_ITEM(itemobj, 1) == true then
                    return true
                end

                return false
            end
        )

        local under =
            g.gbg.uiegbgComponentUnderBtn.new(
            self,
            'under',
            {
                {
                    name = 'repairlowdurequip',
                    caption = g.tr('repairlowdurequip') .. '{nl}' .. g.util.generateSilverString(self:calcPriceRepair(self.lowdur), 30),
                    callback = function()
                        self:repair(self.lowdur)
                        self:close()
                    end
                },
                {
                    name = 'repairallequip',
                    caption = g.tr('repairallequip') .. '{nl}' .. g.util.generateSilverString(self:calcPriceRepair(self.allequip), 30),
                    callback = function()
                        self:repair(self.allequip)
                        self:close()
                    end
                },
                {
                    name = 'repairlowdurall',
                    caption = g.tr('repairlowdurall') .. '{nl}' .. g.util.generateSilverString(self:calcPriceRepair(self.lowdur) + self:calcPriceRepair(self.lowdurinv), 30),
                    callback = function()
                        self:repair(self.lowdur)
                        self:repair(self.lowdurinv)
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
    calcPriceRepair = function(self, invItemList)
        local repair = ui.GetFrame('itembuffrepair')
        local repairbox = repair:GetChild('repair')
        local reqitembox = repairbox:GetChild('materialGbox')
        local reqitemNeed = reqitembox:GetChild('reqitemNeedCount')
        local totalprice = 0
        local totalcount = 0
        if invItemList then
            
            for _, v in ipairs(invItemList) do
                local invitem = v.item
                local itemobj = GetIES(invitem:GetObject())
                local repairamount = itemobj.MaxDur - itemobj.Dur
                local needitem, needcount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj)
                if needcount and needcount > 0 then
                    totalcount = totalcount + needcount
                end
            end
        end
        local needMoneyStr = totalcount * repair:GetUserIValue('PRICE')
        return needMoneyStr
    end,
    repair = function(self, invItemList)
        local frame = ui.GetFrame('itembuffrepair')
        local targetbox = frame:GetChild('repair')
        local handle = frame:GetUserValue('HANDLE')
        local skillName = frame:GetUserValue('SKILLNAME')
        if #invItemList == 0 then
            ui.MsgBox(ScpArgMsg('DON_T_HAVE_ITEM_TO_REPAIR'))
            return
        end
        local totalprice = self:calcPriceRepair(invItemList)
        if IsGreaterThanForBigNumber(totalprice, GET_TOTAL_MONEY_STR()) == 1 then
            ui.MsgBox(ScpArgMsg('NOT_ENOUGH_MONEY'))
            return
        end
        local resultlist = session.GetItemIDList()
        session.ResetItemList()
        for _, v in ipairs(invItemList) do
            local itemobj = GetIES(v.item:GetObject())
            local itemCls = GetClassByType('Item', itemobj.ClassID)
            print(itemCls.Name .. v.iesid)
            session.AddItemID(v.iesid)
        end

        session.autoSeller.BuyItems(
            handle, 
            AUTO_SELL_SQUIRE_BUFF,
             session.GetItemIDList(),
              skillName)

        imcSound.PlaySoundEvent('button_click_repair')
    end,
    releaseImpl = function(self)
        ui.GetFrame('inventory'):ShowWindow(0)
    end,
    defaultHandlerImpl = function(self, key, frame)
        --override me
        return g.uieHandlergbgRepair.new(key, frame, self)
    end
}

g.uieHandlergbgRepair = {
    new = function(key, frame, gbg)
        local self = inherit(g.uieHandlergbgRepair, g.uieHandlergbgBase, key, frame, gbg)
        self.endo = false
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
            '{ol}耐久値の減った装備を修理する',
            function()
                self.gbg:repair(self.gbg.lowdur)
                self.gbg:close()
            end,
            false
        )
        menu:addMenu(
            '{ol}すべての装備品を修理する',
            function()
                self.gbg:repair(self.gbg.allequip)
                self.gbg:close()
            end
        )
        menu:addMenu(
            '{ol}耐久値の減ったすべての装備を修理する',
            function()
                self.gbg:repair(self.gbg.lowdur)
                self.gbg:repair(self.gbg.lowdurinv)
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
            return g.uieHandlerBase.RefEnd
        end

        return g.uieHandlerBase.RefPass
    end
}
UIMODEEXPERT = g
