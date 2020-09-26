--uie_gbg_component_inventory

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
g.gbg=g.gbg or {}
g.gbg.uiegbgComponentInventory = {
    new = function(tab, parent, name, enableaccess)
        local self = inherit(g.gbg.uiegbgComponentInventory, g.gbg.uiegbgComponentBase, tab, parent, name)
        self.enableaccess = enableaccess or true
        return self
    end,
    initializeImpl = function(self, gbox)
        gbox:SetSkinName('bg')
        local gboxin = gbox:CreateOrGetControl('groupbox', 'gboxin', 0, 0, gbox:GetWidth() - 25, gbox:GetHeight())
        local gboxtab = gbox:CreateOrGetControl('groupbox', 'gboxtab', gbox:GetWidth() - 25, 0, 25, gbox:GetHeight())
        AUTO_CAST(gboxin)
        AUTO_CAST(gboxtab)

        --create tabs
        for k, v in ipairs(inventory_filters) do
            local btn = gboxtab:CreateOrGetControl('button', 'btn' .. v.name, 0, 35 * (k - 1), 25, 25)
            btn:SetSkinName('none')
        end
        --create inven)
        self:refreshInventory(gboxin)
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        if msg == 'INV_ITEM_ADD' or msg == 'INV_ITEM_CHANGE_COUNT' or msg == 'INV_ITEM_REMOVE' or msg == 'INV_ITEM_LIST_GET' then
            self:refreshInventory()
        end
    end,
    setCustomEventScript = function(self, slot, inv)
        --override me
    end,
    refreshInventory = function(self, gboxin)
        if not gboxin then
            gboxin = self.gbox:GetChild('gboxin')
        end

        local iframe = ui.GetFrame('inventory')

        gboxin:RemoveAllChild()
        session.BuildInvItemSortedList()

        local sortedList = session.GetInvItemSortedList()
        local invItemCount = sortedList:size()
        local invItemList = {}
        local index_count = 1
        for i = 0, invItemCount - 1 do
            local invItem = sortedList:at(i)
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls ~= nil and item.IsNoneItem(itemCls.ClassID) == 0 and itemCls.MarketCategory ~= 'None' then
                    local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

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
                        item = invItem
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
        local col = math.floor((gboxin:GetWidth() - 20) / slotsize)
        self.invItemList = invItemList
        for k, v in ipairs(invItemList) do
            local invItem = v.item

            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls ~= nil and item.IsNoneItem(itemCls.ClassID) == 0 and itemCls.MarketCategory ~= 'None' then
                    local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

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

                        slotset:SetSlotSize(slotsize, slotsize)
                        slotset:EnableDrag(1)
                        slotset:EnableDrop(1)
                        slotset:EnablePop(1)
                        --slotset:SetSkinName('slot')
                        slotset:CreateSlots()
                        slotidx = 0
                    end
                    cnt = cnt + 1
                    if cnt == col then
                        slotset:ExpandRow()
                        cnt = 0
                    end
                    local parentslot = slotset:GetSlotByIndex(slotidx)
                    invItemList[k].slot = parentslot
                    invItemList[k].index = k
                    self:updateSlot(k)
                    if not self.enableaccess then
                        parentslot:SetEventScript(ui.RBUTTONDOWN, 'None')

                        parentslot:SetEventScript(ui.RBUTTONDBLCLICK, 'None')

                        parentslot:SetEventScript(ui.LBUTTONDOWN, 'None')
                        parentslot:SetEventScript(ui.RBUTTONUP, 'None')

                        parentslot:SetEventScript(ui.LBUTTONUP, 'None')
                    end
                    self:setCustomEventScript(parentslot, invItemList[k])

                    slotidx = slotidx + 1
                end
            end
        end
    end,
    updateSlot = function(self, index)
        local iframe = ui.GetFrame('inventory')
        local parentslot = self.invItemList[index].slot
        local invItem = self.invItemList[index].item
        AUTO_CAST(parentslot)

        local customFunc = nil
        local scriptName = iframe:GetUserValue('CUSTOM_ICON_SCP')
        local scriptArg = nil
        if scriptName ~= nil then
            customFunc = _G[scriptName]
            local getArgFunc = _G[iframe:GetUserValue('CUSTOM_ICON_ARG_SCP')]
            if getArgFunc ~= nil then
                scriptArg = getArgFunc()
            end
        end

        local icon = CreateIcon(parentslot)
        local itemobj = GetIES(invItem:GetObject())
        local imageName = GET_EQUIP_ITEM_IMAGE_NAME(itemobj, 'Icon')
        local iconImgName = GET_ITEM_ICON_IMAGE(itemobj)
        local itemType = invItem.type

        parentslot:EnableDrag(0)
        parentslot:EnableDrop(0)
        parentslot:EnablePop(0)
        parentslot:SetColorTone('FFFFFFFF')

        INV_SLOT_UPDATE(ui.GetFrame('inventory'), invItem, parentslot)
    end
}

g.gbg.uiegbgComponentShopInventory = {
    new = function(tab, parent, name, enableaccess, updatecallback)
        local self = inherit(g.gbg.uiegbgComponentShopInventory, g.gbg.uiegbgComponentInventory, tab, parent, name, enableaccess)
        self.updatecallback = updatecallback
        return self
    end,
    initializeImpl = function(self, gbox)
        g.gbg.uiegbgComponentInventory.initializeImpl(self, gbox)
        self.sell = {}
    end,
    reset = function(self)
        self.sell = {}
        self:refreshInventory()
    end,
    setCustomEventScript = function(self, slot, inv)
        slot:SetEventScript(ui.RBUTTONUP, 'UIE_GBG_SHOPINVENTORY_RBUTTON')
        slot:SetEventScriptArgNumber(ui.RBUTTONUP, inv.index)
        slot:SetEventScriptArgString(ui.RBUTTONUP, self.name)
        slot:SetEventScript(ui.LBUTTONUP, 'UIE_GBG_SHOPINVENTORY_LBUTTON')
        slot:SetEventScriptArgNumber(ui.LBUTTONUP, inv.index)
        slot:SetEventScriptArgString(ui.LBUTTONUP, self.name)
    end,
    sellItem = function(self, index, amount)
        local inv = self.invItemList[index]
        local invitem=inv.item
        if true == invitem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return;
        end
    
        local itemobj = GetIES(invitem:GetObject());
        local itemProp = geItemTable.GetPropByName(itemobj.ClassName);
        if itemProp:IsEnableShopTrade() == false then
            ui.SysMsg(ClMsg("CannoTradeToNPC"));
            return;
        end
    
        if itemobj.MarketCategory == "Housing_Furniture" or itemobj.MarketCategory == "PHousing_Furniture" or itemobj.MarketCategory == "PHousing_Wall" or itemobj.MarketCategory == "PHousing_Carpet" then
            ui.SysMsg(ClMsg("Housing_Cant_Sell_This_Item"));
            return;
        end
        
        
        
        inv.amount=inv.amount or 0
        inv.amount = math.min(inv.item.count, inv.amount + amount)
        self:updateSlot(index)
        if self.updatecallback then
            self.updatecallback()
        end
    end,
    calcTotalValue=function(self)
        local invItemList=self.invItemList
        local total='0'
        for k, v in ipairs(invItemList) do
            if  v.amount and v.amount>0 then
                local itemcls = GetIES(v.item:GetObject());
                local itemProp = geItemTable.GetPropByName(itemcls.ClassName);
       
                local unit= tostring(geItemTable.GetSellPrice(itemProp))
                local price=MultForBigNumberInt64(unit,tostring(v.amount))
                total=SumForBigNumberInt64(total,price)
            end
        end
        return total
    end,
    updateSlot = function(self, index)
        local inv = self.invItemList[index]

        local frame = ui.GetFrame('inventory')
        local slot = self.invItemList[index].slot
        local invItem = self.invItemList[index].item
        AUTO_CAST(slot)

        local customFunc = nil
        local scriptName = frame:GetUserValue('CUSTOM_ICON_SCP')
        local scriptArg = nil
        if scriptName ~= nil then
            customFunc = _G[scriptName]
            local getArgFunc = _G[frame:GetUserValue('CUSTOM_ICON_ARG_SCP')]
            if getArgFunc ~= nil then
                scriptArg = getArgFunc()
            end
        end

        local icon = CreateIcon(slot)
        local itemobj = GetIES(invItem:GetObject())
        local imageName = GET_EQUIP_ITEM_IMAGE_NAME(itemobj, 'Icon')
        local iconImgName = GET_ITEM_ICON_IMAGE(itemobj)
        local itemType = invItem.type
        local class = GetClassByType('Item', invItem.type)
        slot:EnableDrag(0)
        slot:EnableDrop(0)
        slot:EnablePop(0)
        slot:SetColorTone('FFFFFFFF')
        ICON_SET_ITEM_COOLDOWN(icon, itemType)
        ICON_SET_INVENTORY_TOOLTIP(icon, invItem, nil, class)
        SET_SLOT_STYLESET(slot, itemobj, nil, nil, nil, nil, 1)
        local slotFont = frame:GetUserConfig('TREE_SLOT_TEXT_FONT')

        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemobj, invItem.count, slotFont)

        local txtcount = slot:CreateOrGetControl('richtext', 'txtamount', 0, 0, slot:GetWidth(), slot:GetHeight())

        if inv.amount and inv.amount > 0 then
            txtcount:SetText('{ol}{#5577FF}{s24}' .. tostring(inv.amount))
        else
            txtcount:SetText('')
        end
        icon:Set(iconImgName, 'Item', itemType, invItem.invIndex, invItem:GetIESID(), invItem.count)
        if itemobj.GroupName == 'Quest' then
            slot:SetFrontImage('quest_indi_icon')
        elseif invItem.isLockState == true then
            local controlset = slot:CreateOrGetControlSet('inv_itemlock', 'itemlock', 0, 0)
            controlset:SetGravity(ui.RIGHT, ui.TOP)
        elseif true == IS_TEMP_LOCK(frame, invItem) then
            slot:SetFrontImage('item_Lock')
        else
            slot:SetFrontImage('None')
            DESTROY_CHILD_BYNAME(slot, 'itemlock')
        end

        if invItem.hasLifeTime == true or TryGetProp(itemobj, 'ExpireDateTime', 'None') ~= 'None' then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon)
            slot:SetFrontImage('clock_inven')
        end

        -- 아이커 종류 표시
        SET_SLOT_ICOR_CATEGORY(slot, itemobj)

        if invItem.isNew == true then
            slot:SetHeaderImage('new_inventory_icon')
        elseif IS_EQUIPPED_WEAPON_SWAP_SLOT(invItem) then
            slot:SetHeaderImage('equip_inven')
        else
            slot:SetHeaderImage('None')
        end
        txtcount:EnableHitTest(0)
    end
}

UIMODEEXPERT = g
function UIE_GBG_SHOPINVENTORY_RBUTTON(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local self = g.gbg.getComponentInstanceByName(argstr)
            self:sellItem(argnum, 1)
            imcSound.PlaySoundEvent('button_inven_click_item');
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GBG_SHOPINVENTORY_LBUTTON(frame, ctrl, argstr, argnum)
    local self = g.gbg.getComponentInstanceByName(argstr)
    self:sellItem(argnum, -1)
    imcSound.PlaySoundEvent('button_inven_click_item');
end

function UIE_GBG_INVENTORY_FILTER(invItem, filtername)
    return EBI_try_catch {
        try = function()
            local filter = filtername or 'All'
            if (filter == 'All') then
                return true
            end
            if (filter == 'Lim') then
                --時間制限付きか判定
                if (invItem.hasLifeTime == true) then
                    return true
                else
                    return false
                end
            end
            if (filter == 'Ing') then
                --材料か
                local itemObj = GetIES(invItem:GetObject())
                if (itemObj.GroupName == 'Material') then
                    return true
                else
                    return false
                end
            end
            if (filter == 'Que') then
                --クエストアイテムか
                local itemObj = GetIES(invItem:GetObject())
                if (itemObj.GroupName == 'Quest') then
                    return true
                else
                    return false
                end
            end
            if (filter == 'Fnd') then
                --検索
                local findstr = g.inv.findstr or '.*'
                local itemCls = GetIES(invItem:GetObject())
                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name))
                if (itemname:find(findstr)) then
                    return true
                else
                    return false
                end
            end
            --オリジナルソート
            local filterdata = g.inv.filterbyname[filter]
            if (filterdata.original) then
                local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

                local titleName = baseidcls.ClassName
                if baseidcls.MergedTreeTitle ~= 'NO' then
                    titleName = baseidcls.MergedTreeTitle
                end
                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                if filterdata.original == typeStr then
                    return true
                else
                    return false
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
