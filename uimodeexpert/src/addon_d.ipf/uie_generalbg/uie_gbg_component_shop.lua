--uie_gbg_component_shop

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
local inventory_filters = {
    --{name = "Fav", text = "★", tooltip = "Favorites", imagename = "uie_favorites", original = nil},
    --{name = 'All', text = 'All', tooltip = 'All', imagename = 'uie_all', original = 'All'},
    {rank = 0, name = 'Prm', text = 'Prm', tooltip = 'Premium', imagename = 'uie_premium', original = 'Premium'},
    {rank = 1, name = 'Equ', text = 'Equ', tooltip = 'Equip', imagename = 'uie_equip', original = 'Equip'},
    {rank = 2, name = 'Spl', text = 'Spl', tooltip = 'Consume Item', imagename = 'uie_consume', original = 'Consume'},
    {rank = 3, name = 'Crd', text = 'Crd', tooltip = 'Card', imagename = 'uie_card', original = 'Card'},
    {rank = 4, name = 'Gem', text = 'Gem', tooltip = 'Gem', imagename = 'uie_gem', original = 'Gem'},
    {rank = 5, name = 'Etc', text = 'Etc', tooltip = 'Etc', imagename = 'uie_etc', original = 'Etc'},
    {rank = 6, name = 'Rcp', text = 'Rcp', tooltip = 'Recipe', imagename = 'uie_recipe', original = 'Recipe'},
    {rank = 7, name = 'Hou', text = 'Hou', tooltip = 'Housing', imagename = 'uie_housing', original = 'Housing'}
}
UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT

g.gbg.uiegbgComponentShop = {
    new = function(tab, parent, name, updatecallback)
        local self = inherit(g.gbg.uiegbgComponentShop, g.gbg.uiegbgComponentBase, tab, parent, name)
        self.updatecallback = updatecallback
        self.buy = {}
        return self
    end,
    initializeImpl = function(self, gbox)
        local gboxin = gbox:CreateOrGetControl('groupbox', 'gboxin', 0, 0, gbox:GetWidth() - 25, gbox:GetHeight())
        local gboxtab = gbox:CreateOrGetControl('groupbox', 'gboxtab', gbox:GetWidth() - 25, 0, 25, gbox:GetHeight())
        AUTO_CAST(gboxin)
        AUTO_CAST(gboxtab)

        --create tabs
        for k, v in ipairs(inventory_filters) do
            local btn = gboxtab:CreateOrGetControl('button', 'btn' .. v.name, 0, 35 * (k - 1), 25, 25)
            btn:SetSkinName('none')
        end
        --create inven
        self:refreshShop(gboxin)
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
    end,
    buyItem = function(self, index, amount)
        local inv = self.invItemList[index]
        inv.amount = math.max(0, inv.amount + amount)
        self:updateSlot(index)
        if self.updatecallback then
            self.updatecallback()
        end
        
    end,
    calcTotalValue=function(self)
        local invItemList=self.invItemList
        local total='0'
        for k, v in ipairs(invItemList) do
            if v.amount>0 then
                local unit= GET_SHOPITEM_PRICE_TXT(v.item)
                local price=MultForBigNumberInt64(unit,tostring(v.amount))
                total=SumForBigNumberInt64(total,price)
            end
        end
        return total
    end,
    updateSlot = function(self, index)
        local inv = self.invItemList[index]
        local parentslot = inv.slot
        local txtprice = parentslot:GetChild('price')
        local txtname = parentslot:GetChild('name')
        local itemCls = GetClassByType(inv.item:GetIDSpace(), inv.item.type)
        if inv.amount > 0 then
            txtname:SetText('{ol}{#FFFF00} ' .. GET_SHOPITEM_TXT(inv.item, itemCls))
            txtprice:SetText(string.format(' {img icon_item_silver 20 20}{#FFFF00} {ol}%s x%d', GET_SHOPITEM_PRICE_TXT(inv.item), inv.amount))
        else
            txtname:SetText('{ol}' .. GET_SHOPITEM_TXT(inv.item, itemCls))
            txtprice:SetText(string.format(' {img icon_item_silver 20 20} {ol}%s', GET_SHOPITEM_PRICE_TXT(inv.item)))
        end
    end,
    refreshShop = function(self, gboxin)
        if not gboxin then
            gboxin = self.parent:GetChild('gboxin')
        end
        self.invItemList = {}
        local shopItemList = session.GetShopItemList()
        local sframe = ui.GetFrame('shop')

        gboxin:RemoveAllChild()
        local sortedList = session.GetShopItemList()

        local invItemCount = shopItemList:Count()
        local invItemList = {}
        local index_count = 1
        for i = 0, invItemCount - 1 do
            local invItem = sortedList:PtrAt(i)
            if invItem ~= nil then
                local itemCls = GetClassByType(invItem:GetIDSpace(), invItem.type)
                if itemCls ~= nil and item.IsNoneItem(itemCls.ClassID) == 0 and itemCls.MarketCategory ~= 'None' then
                    local baseidcls = GetClassByNumProp('inven_baseid', 'BaseID', GetInvenBaseID(itemCls.ClassID))

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= 'NO' then
                        titleName = baseidcls.MergedTreeTitle
                    end
                    local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                    local rank = 0
                    for _, v in ipairs(inventory_filters) do
                        if v.original == typeStr then
                            rank = v.rank
                        end
                    end
                    invItemList[index_count] = {
                        rank = rank,
                        item = invItem,
                        amount = 0
                    }

                    index_count = index_count + 1
                end
            end
        end
        table.sort(
            invItemList,
            function(a, b)
                if a.rank ~= b.rank then
                    return a.rank < b.rank
                else
                    return a.item.type < b.item.type
                end
            end
        )
        -- slotset:SetColRow(9, math.ceil(invItemCount / 2))
        -- slotset:SetSpc(0, 0)
        -- local slotsize = 48

        -- slotset:SetSlotSize(slotwidth, slotsize)
        -- slotset:EnableDrag(1)
        -- slotset:EnableDrop(1)
        -- slotset:EnablePop(1)
        -- --slotset:SetSkinName('slot')
        -- slotset:CreateSlots()
        local treename = nil
        local slotidx = 0
        local oy = 0
        local slotset = nil
        local slotsize = 48
        local cnt = 0
        local col = 3

        for k, v in ipairs(invItemList) do
            local invItem = v.item

            if invItem ~= nil then
                local itemCls = GetClassByType(invItem:GetIDSpace(), invItem.type)
                if itemCls ~= nil and item.IsNoneItem(itemCls.ClassID) == 0 and itemCls.MarketCategory ~= 'None' then
                    local baseidcls = GetClassByNumProp('inven_baseid', 'BaseID', GetInvenBaseID(itemCls.ClassID))

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= 'NO' then
                        titleName = baseidcls.MergedTreeTitle
                    end
                    local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                    if treename ~= typeStr then
                        cnt = 0
                        treename = typeStr
                        if slotset then
                            slotset:Invalidate()
                            slotset:EnableAutoResize(true, true)
                            oy = oy + slotset:GetHeight() + 5
                        end
                        local rich = gboxin:CreateOrGetControl('richtext', 'category' .. treename, 0, oy, gboxin:GetWidth(), 30)
                        rich:SetText('{@stb42}' .. treename)
                        oy = oy + 30 + 5
                        slotset = gboxin:CreateOrGetControl('slotset', 'slotset' .. treename, 0, oy, gboxin:GetWidth(), 0)
                        AUTO_CAST(slotset)
                        slotset:SetColRow(col, 1)
                        slotset:SetSpc(0, 0)
                        slotset:SetSlotSize(gboxin:GetWidth() / col, slotsize)
                        slotset:EnableDrag(1)
                        slotset:EnableDrop(1)
                        slotset:EnablePop(1)

                        slotset:CreateSlots()
                        slotidx = 0
                    end
                    cnt = cnt + 1
                    if cnt == col then
                        slotset:ExpandRow()
                        cnt = 0
                    end

                    local parentslot = slotset:GetSlotByIndex(slotidx)
                    AUTO_CAST(parentslot)

                    local childslot = parentslot:CreateOrGetControl('slot', 'child', 5, 0, slotsize, slotsize)
                    AUTO_CAST(childslot)

                    local icon = CreateIcon(childslot)
                    local picon = CreateIcon(parentslot)
                    local imageName = invItem:GetIcon()
                    icon:Set(imageName, 'SHOPITEM', invItem, 0)
                    SET_SHOP_ITEM_TOOLTIP(picon, invItem)
                    childslot:EnableHitTest(0)
                    local itemType = invItem.type
                    --icon:Set('uie_transparent', 'Item', itemType, 0,"0", invItem.count)
                    icon:Resize(0, 0)
                    parentslot:EnableDrag(0)
                    parentslot:EnableDrop(0)
                    parentslot:EnablePop(0)
                    parentslot:SetColorTone('FFFFFFFF')
                    parentslot:SetSkinName('slot')
                    parentslot:SetEventScript(ui.RBUTTONUP, 'UIE_GBG_COMPONENT_SHOP_RCLICK')
                    parentslot:SetEventScriptArgNumber(ui.RBUTTONUP, k)
                    parentslot:SetEventScriptArgString(ui.RBUTTONUP, self.name)
                    parentslot:SetEventScript(ui.LBUTTONUP, 'UIE_GBG_COMPONENT_SHOP_LCLICK')
                    parentslot:SetEventScriptArgNumber(ui.LBUTTONUP, k)
                    parentslot:SetEventScriptArgString(ui.LBUTTONUP, self.name)
                    local txtname = parentslot:CreateOrGetControl('richtext', 'name', slotsize + 5, 0, 10, 20)
                    txtname:SetGravity(ui.RIGHT, ui.TOP)
                    txtname:SetText('{ol}' .. GET_SHOPITEM_TXT(invItem, itemCls))
                    txtname:EnableHitTest(false)
                    txtname:SetMargin(5, 5, 20, 5)
                    local txtprice = parentslot:CreateOrGetControl('richtext', 'price', slotsize + 5, parentslot:GetHeight() - 20, 10, 20)
                    txtprice:SetGravity(ui.RIGHT, ui.BOTTOM)
                    txtprice:SetMargin(5, 5, 20, 5)
                    txtprice:SetText(string.format(' {img icon_item_silver 20 20} {ol}%s', GET_SHOPITEM_PRICE_TXT(invItem)))
                    txtprice:EnableHitTest(false)
                    invItemList[k].slot = parentslot
                    invItemList[k].index=k
                    slotidx = slotidx + 1
                end
            end
        end
        self.invItemList = invItemList
    end
}

UIMODEEXPERT = g

function UIE_GBG_COMPONENT_SHOP_RCLICK(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local self = g.gbg.getComponentInstanceByName(argstr)
            self:buyItem(argnum, 1)
            imcSound.PlaySoundEvent("button_inven_click_item");
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GBG_COMPONENT_SHOP_LCLICK(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local self = g.gbg.getComponentInstanceByName(argstr)
            self:buyItem(argnum, -1)
            imcSound.PlaySoundEvent("button_inven_click_item");
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
