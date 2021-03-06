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

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT
g.gbg = g.gbg or {}
g.gbg.uiegbgComponentInventoryBase = {
    new = function( parentgbg, name, option)
        local self = inherit(g.gbg.uiegbgComponentInventoryBase, g.gbg.uiegbgComponentBase, parentgbg, name)
        self.option=option or {
        }
        self.option.enableaccess=self.option.enableaccess or true
        self.option.filter= self.option.filter or nil
        self.option.tooltipxy=self.option.tooltipxy or nil
        self.option.selectable=self.option.selectable or false
        self.option.singleselect=self.option.singleselect or true
        self.option.slotsize=self.option.slotsize or 48
        self.option.onrclicked= self.option.onrclicked or nil
        return self
    end,
    initializeImpl = function(self, gbox)
        gbox:SetSkinName('bg')
        
        local gboxin = gbox:CreateOrGetControl('groupbox', 'gboxin', 0, 0, gbox:GetWidth() - 25, gbox:GetHeight())
        local gboxtab = gbox:CreateOrGetControl('groupbox', 'gboxtab', gbox:GetWidth() - 25, 0, 25, gbox:GetHeight())
        AUTO_CAST(gboxin)
        AUTO_CAST(gboxtab)
        gboxtab:EnableScrollBar(0)
        gboxtab:SetSkinName('bg')
      
        --create tabs
        for k, v in ipairs(g.util.inventory_filters) do
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
    defaultHandlerImpl = function(self, key, frame)
        return g.uieHandlergbgComponentInventory.new(key, frame, self,self.option.tooltipxy)
    end,
    getItemList=function(self)
        local items,nosort=self:getItemListImpl()
        if self.option.filter then
            local filtered={}
            for _,v in ipairs(items) do
                if self.option.filter(v.item) then
                    filtered[#filtered+1] = v
                end
            end
            return filtered
        end
        return items,nosort
    end,
    getItemListImpl=function(self)
        --override me
        return {},false
    end,
    getSelectedItems=function(self)
        if not self.option.selectable then
            ERROUT('option.selectable is false.Must be true!')
            return {}
        end
        local selected={}
        for _,v in ipairs(self.invItemList) do
            local slot=v.slot

            if slot:IsSelected()==1 then
                selected[#selected+1] = v
            end
        end
        return selected
    end,
    refreshInventory = function(self, gboxin)
        if not gboxin then
            gboxin = self.gbox:GetChild('gboxin')
        end

        local iframe = ui.GetFrame('inventory')

        gboxin:RemoveAllChild()
        
        local invItemList,nosort=self:getItemList()
        if not nosort then
            
            table.sort(
                invItemList,
                function(a, b)
                    if a.rank ~= b.rank then
                        if a.rank==nil or b.rank==nil then

                            return false
                        end
                        return a.rank < b.rank
                    else
                        return a.item.type < b.item.type
                    end
                end
            )
        end
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
        local slotsize = self.option.slotsize
        local cnt = 0
        local col = math.floor((gboxin:GetWidth() - 20) / slotsize)
        self.col = col
        self.invItemList = invItemList
        local beginidx=0
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
                            slotset:SetSlotCount(slotidx)
                            slotset:SetUserValue('count',slotidx)
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
                        if not self.option.enableaccess or  self.option.selectable then
                            slotset:EnableDrag(0)
                            slotset:EnableDrop(0)
                            slotset:EnablePop(0)
                        else

                            slotset:EnableDrag(0)
                            slotset:EnableDrop(0)
                            slotset:EnablePop(0)
                        end
                        if self.option.selectable then
                            slotset:EnableSelection(1)
                        else
                            slotset:EnableSelection(0)
                        end
                        --slotset:SetSkinName('slot')
                        slotset:CreateSlots()
                        beginidx=beginidx+slotidx
                        slotidx = 0
                    end
                    cnt = cnt + 1
                    if cnt == col then
                        slotset:ExpandRow()
                        cnt = 0
                    end
                    local parentslot = slotset:GetSlotByIndex(slotidx)
                    invItemList[k].slot = parentslot
                    invItemList[k].index = k-1
                    invItemList[k].slotset=slotset
                    invItemList[k].indexinslotset=slotidx
                    invItemList[k].beginindexinslotset=beginidx
                    
                    self:updateSlot(k)
                    if not self.option.enableaccess or  self.option.selectable then
                        parentslot:SetEventScript(ui.RBUTTONDOWN, 'None')

                        parentslot:SetEventScript(ui.RBUTTONDBLCLICK, 'None')

                        parentslot:SetEventScript(ui.LBUTTONDOWN, 'None')
                        parentslot:SetEventScript(ui.RBUTTONUP, 'None')

                        parentslot:SetEventScript(ui.LBUTTONUP, 'None')
                    end
                    if self.option.enableaccess and  self.option.onrclicked then
                        parentslot:SetEventScript(ui.RBUTTONUP, 'UIE_GBG_COMPONENTINVENTORYBASE_ON_RCLICK')
                        parentslot:SetEventScriptArgString(ui.RBUTTONUP, self.name)
                        parentslot:SetEventScriptArgNumber(ui.RBUTTONUP, k)
                    end
                    self:setCustomEventScript(parentslot, invItemList[k])

                    slotidx = slotidx + 1
                end
            end
        end
        --slotset:SetUserValue('count',slotidx)
        if self.option.singleselect then
            ui.EnableSlotMultiSelect(0);
        else
            ui.EnableSlotMultiSelect(1);
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

       
        parentslot:SetColorTone('FFFFFFFF')

        INV_SLOT_UPDATE(ui.GetFrame('inventory'), invItem, parentslot)

        parentslot:EnableDrag(0)
        parentslot:EnableDrop(0)
        parentslot:EnablePop(0)
    end
}
g.gbg.uiegbgComponentCustomInventory = {
    new = function(parentgbg, name,custominvenfunc, option)
        local self = inherit(g.gbg.uiegbgComponentCustomInventory, g.gbg.uiegbgComponentInventoryBase,  parentgbg, name,option)
        self.custominvenfunc=custominvenfunc
        return self
    end,
    getItemListImpl=function(self)
        --override me
        return self.custominvenfunc()
    end,
}
g.gbg.uiegbgComponentInventory = {
    new = function(parentgbg, name, option)
        local self = inherit(g.gbg.uiegbgComponentInventory, g.gbg.uiegbgComponentInventoryBase,  parentgbg, name,option)

        return self
    end,

    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        if msg == 'INV_ITEM_ADD' or msg == 'INV_ITEM_CHANGE_COUNT' or msg == 'INV_ITEM_REMOVE' or msg == 'INV_ITEM_LIST_GET' then
            self:refreshInventory()
        end
    end,
    getItemListImpl=function(self)
        --override me
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
                    for _, v in ipairs(g.util.inventory_filters) do
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
        return invItemList
    end,
}

g.gbg.uiegbgComponentShopInventory = {
    new = function( parentgbg, name,  updatecallback,option)
        local self = inherit(g.gbg.uiegbgComponentShopInventory, g.gbg.uiegbgComponentInventory, parentgbg, name, option)
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
    defaultHandlerImpl = function(self, key, frame)
        return g.uieHandlergbgComponentInventory.new(key, frame, self,self.option.tooltipxy)
    end,
    setCustomEventScript = function(self, slot, inv)
        slot:SetEventScript(ui.RBUTTONUP, 'UIE_GBG_SHOPINVENTORY_RBUTTON')
        slot:SetEventScriptArgNumber(ui.RBUTTONUP, inv.index)
        slot:SetEventScriptArgString(ui.RBUTTONUP, self.name)
        slot:SetEventScript(ui.LBUTTONUP, 'UIE_GBG_SHOPINVENTORY_LBUTTON')
        slot:SetEventScriptArgNumber(ui.LBUTTONUP, inv.index)
        slot:SetEventScriptArgString(ui.LBUTTONUP, self.name)
    end,
    getItemListImpl=function(self)
        --override me
        session.BuildInvItemSortedList()

        local sortedList = session.GetInvItemSortedList()
        local invItemCount = sortedList:size()
        local invItemList = {}
        local index_count = 1
        
        for i = 0, invItemCount - 1 do
            local invItem = sortedList:at(i)
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                local itemProp = geItemTable.GetPropByName(itemCls.ClassName)
            
                if itemCls ~= nil and item.IsNoneItem(itemCls.ClassID) == 0 and
                  itemCls.MarketCategory ~= 'None' then
                    if true == invItem.isLockState or itemProp:IsEnableShopTrade() == false or
                    itemCls.MarketCategory == 'Housing_Furniture' or 
                    itemCls.MarketCategory == 'PHousing_Furniture' or 
                    itemCls.MarketCategory == 'PHousing_Wall' or
                    itemCls.MarketCategory == 'PHousing_Carpet' then

                     else

                        local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

                        local titleName = baseidcls.ClassName
                        if baseidcls.MergedTreeTitle ~= 'NO' then
                            titleName = baseidcls.MergedTreeTitle
                        end
                        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                        local rank = 0
                        for _, v in ipairs(g.util.inventory_filters) do
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
        end
        return invItemList
    end,
    sellItem = function(self, index, amount)
        local inv = self.invItemList[index]
        local invitem = inv.item
        if true == invitem.isLockState then
            ui.SysMsg(ClMsg('MaterialItemIsLock'))
            return
        end

        local itemobj = GetIES(invitem:GetObject())
        local itemProp = geItemTable.GetPropByName(itemobj.ClassName)
        if itemProp:IsEnableShopTrade() == false then
            ui.SysMsg(ClMsg('CannoTradeToNPC'))
            return
        end

        if
            itemobj.MarketCategory == 'Housing_Furniture' or itemobj.MarketCategory == 'PHousing_Furniture' or itemobj.MarketCategory == 'PHousing_Wall' or
                itemobj.MarketCategory == 'PHousing_Carpet'
         then
            ui.SysMsg(ClMsg('Housing_Cant_Sell_This_Item'))
            return
        end

        inv.amount = inv.amount or 0
        inv.amount = math.min(inv.item.count, inv.amount + amount)
        self:updateSlot(index)
        if self.updatecallback then
            self.updatecallback()
        end
        imcSound.PlaySoundEvent("button_inven_click_item");
    end,
    calcTotalValue = function(self)
        local invItemList = self.invItemList
        local total = '0'
        for k, v in ipairs(invItemList) do
            if v.amount and v.amount > 0 then
                local itemcls = GetIES(v.item:GetObject())
                local itemProp = geItemTable.GetPropByName(itemcls.ClassName)

                local unit = tostring(geItemTable.GetSellPrice(itemProp))
                local price = MultForBigNumberInt64(unit, tostring(v.amount))
                total = SumForBigNumberInt64(total, price)
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
g.uieHandlergbgComponentInventory = {
    new = function(key, frame, gbg, tooltipxy)
        local self = inherit(g.uieHandlergbgComponentInventory, g.uieHandlergbgBase, key, frame, gbg)
        self.tooltipxy = tooltipxy
        self.cursor = 0
        return self
    end,
    delayedenter = function(self)
        self:moveMouseToControl(self.gbg.invItemList[self.cursor + 1].slot)
    end,
    moveMouse = function(self)
        EBI_try_catch {
            try = function()
                local slot = self.gbg.invItemList[self.cursor + 1].slot
                local item = self.gbg.invItemList[self.cursor + 1].item
                if slot then
                    --g_invenTypeStrList
                    local inven = self.gbg.gbox:GetChild('gboxin')
                    local parent = slot:GetParent()
                    local y
                    AUTO_CAST(inven)
                    if parent then
                        y = slot:GetY() + parent:GetY()
                    else
                        y = slot:GetY()
                    end
                    local h = slot:GetHeight()
                    local scrolly = inven:GetScrollCurPos()
                    local scrollh = inven:GetHeight()
                    scrolly = math.min(y, math.max(scrolly, y - scrollh + h + 10))
                    inven:SetScrollPos(scrolly)
                    inven:UpdateGroupBox()
                    inven:ValidateControl()
                    inven:UpdateDataByScroll()

                    self:moveMouseToControl(slot)
                    g.util.showItemToolTip(item, self.tooltipxy.x, self.tooltipxy.y)
                end
            end,
            catch = function(error)
                ERROUT(error)
            end
        }
    end,
    findNextElem=function(self,index,invItemList) 
        local slotset=invItemList[index].slotset
        for i=index,#invItemList do
            if slotset~=invItemList[i].slotset then
                return invItemList[i]
            end
        end
        return nil
    end,
    findPrevElem=function(self,index,invItemList) 
        local slotset=invItemList[index].slotset
        for i=index,1,-1 do
            if slotset~=invItemList[i].slotset then
                return invItemList[i]
            end
        end
        return nil
    end,
    tick = function(self)
        local count = #self.gbg.invItemList
      
        if count > 0 then
            local elem=self.gbg.invItemList[self.cursor+1]
            local prevelem=self:findPrevElem(self.cursor+1,self.gbg.invItemList)
            local nextelem=self:findNextElem(self.cursor+1,self.gbg.invItemList)
            if g.key:IsKeyPressed(g.key.SUB) then
                local gbg=self.gbg
                if g.key:IsKeyPress(g.key.RIGHT) then
                    -- +1
                    gbg:sellItem(self.cursor+1, 1)
          
                end
                if g.key:IsKeyPress(g.key.LEFT) then
                    -- +1
                    gbg:sellItem(self.cursor+1, -1)

                end
                if g.key:IsKeyPress(g.key.UP) then
                    -- -10
                    gbg:sellItem(self.cursor+1, 10)
       
                end
                if g.key:IsKeyPress(g.key.DOWN) then
                    -- +10
                    gbg:sellItem(self.cursor+1, -10)
                    
                end
                if g.key:IsKeyPress(g.key.PAGEUP) then
                    -- -100
                    gbg:sellItem(self.cursor+1, -100)
                   
                end
                if g.key:IsKeyPress(g.key.PAGEDOWN) then
                    -- 100
                    gbg:sellItem(self.cursor+1, 100)
                    
                end
            else
                if g.key:IsKeyPress(g.key.RIGHT) then
                    --down
                    self.cursor = self.cursor + 1
                    if self.cursor >= count then
                        self.cursor = 0
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.LEFT) then
                    --up
                    self.cursor = self.cursor - 1
                    if self.cursor < 0 then
                        self.cursor = count - 1
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.DOWN) then
                    --down
                    local inindex=self.cursor+self.gbg.col
                    
                    if nextelem then
                        
                        self.cursor=math.min(
                            nextelem.beginindexinslotset+elem.indexinslotset,
                        nextelem.beginindexinslotset+nextelem.slotset:GetUserIValue('count')-1,inindex)
                    else
                        self.cursor=inindex
                    end
                    
                    if self.cursor<0 then
                        self.cursor= count - 1
                    end
                    if self.cursor>=count then
                        self.cursor= 0
        
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.UP) then
                    --up
                    local inindex=self.cursor-self.gbg.col
                
                    if prevelem then
                        self.cursor=math.max(
                            math.min(prevelem.beginindexinslotset+elem.indexinslotset,
                            prevelem.beginindexinslotset+prevelem.slotset:GetUserIValue('count')-1)
                            ,inindex)
                    else
                        self.cursor=inindex
                    end
                    if self.cursor<0 then
                        self.cursor= count - 1
                    end
                    if self.cursor>=count then
                        self.cursor= 0
        
                    end
                  
                    print(''..self.cursor)
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.PAGEUP) then
                    local inindex=self.cursor-self.gbg.col*4
                
                    if prevelem then
                        self.cursor=math.max(
                            math.min(prevelem.beginindexinslotset+elem.indexinslotset,
                            prevelem.beginindexinslotset+prevelem.slotset:GetUserIValue('count')-1)
                            ,inindex)
                    else
                        self.cursor=inindex
                    end
                    if self.cursor<0 then
                        self.cursor= count - 1
                    end
                    if self.cursor>=count then
                        self.cursor= 0
        
                    end
                  
                    print(''..self.cursor)
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.PAGEDOWN) then
                    --down
                    local inindex=self.cursor+self.gbg.col*4
                    
                    if nextelem then
                        
                        self.cursor=math.min(
                            nextelem.beginindexinslotset+elem.indexinslotset,
                        nextelem.beginindexinslotset+nextelem.slotset:GetUserIValue('count')-1,inindex)
                    else
                        self.cursor=inindex
                    end
                    
                    if self.cursor<0 then
                        self.cursor= count - 1
                    end
                    if self.cursor>=count then
                        self.cursor= 0
        
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyDown(g.key.CANCEL) then
                    g:onCanceledCursor()
                    return g.uieHandlerBase.RefEnd
                end
            end
            if g.key:IsKeyDown(g.key.MAIN)  then
                local scp
                local idx = self.cursor
                local ctrl = self.gbg.invItemList[self.cursor + 1].slot

                if ctrl:GetClassString() == 'ui::CButton' or ctrl:GetClassString() == 'ui::CCheckBox' or ctrl:GetClassString() == 'ui::CSlot' then
                    local evt
                    if g.key:IsKeyDown(g.key.MAIN) then
                        evt = ui.LBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.LBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.LBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    end

                    local scpnum = ctrl:GetEventScriptArgNumber(evt)
                    local scpstr = ctrl:GetEventScriptArgString(evt)

                    if scp and ctrl:IsEnable() == 1 then
                        local r, s = load('return (' .. scp .. ')')
                        g:onDeterminedCursor()
                        if r then
                            --print(scp)
                            local parent = ctrl:GetParent()
                            local ctrlset

                            while parent do
                                if parent:GetClassString() == 'ui::CControlSet' then
                                    ctrlset = parent

                                    break
                                end
                                parent = parent:GetParent()
                            end

                            if ctrlset then
                                pcall(r(), ctrlset, ctrl, scpstr, scpnum)
                            else
                                pcall(r(), ctrl:GetTopParentFrame(), ctrl, scpstr, scpnum)
                            end
                        end
                    end
                end
                if ctrl:GetClassString() == 'ui::CCheckBox' then
                    if ctrl:IsChecked() == 1 then
                        ctrl:SetCheck(0)
                    else
                        ctrl:SetCheck(1)
                    end
                end
                if ctrl:GetClassString() == 'ui::CSlot'  then
                    if g.key:IsKeyDown(g.key.MAIN) then
                        local parent = ctrl:GetParent()
                        if parent:GetClassString() == 'ui::CSlotSet' then
                            
                            AUTO_CAST(parent)
                           
                            if ctrl:IsSelected() == 1 then
                                ctrl:Select(0)
                            else
                                if self.gbg.option.singleselect then
                                    parent:ClearSelectedSlot()
                                end
                                ctrl:Select(1)
                            end
                            parent:MakeSelectionList()
                            parent:Invalidate()
                        else
                            if ctrl:IsSelected() == 1 then
                                ctrl:Select(0)
                            else
                                ctrl:Select(1)
                            end
                        end
                    end
                end
                return g.uieHandlerBase.RefRefresh
            end
        end
        return g.uieHandlerBase.RefPass
    end,
    leave = function(self)
        g.uieHandlergbgBase.leave(self)
        g.util.hideItemToolTip()
    end
}
UIMODEEXPERT = g
function UIE_GBG_SHOPINVENTORY_RBUTTON(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local self = g.gbg.getComponentInstanceByName(argstr)
            self:sellItem(argnum, 1)
            imcSound.PlaySoundEvent('button_inven_click_item')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_GBG_SHOPINVENTORY_LBUTTON(frame, ctrl, argstr, argnum)
    local self = g.gbg.getComponentInstanceByName(argstr)
    self:sellItem(argnum, -1)
    imcSound.PlaySoundEvent('button_inven_click_item')
end

function UIE_GBG_COMPONENTINVENTORYBASE_ON_RCLICK(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local self = g.gbg.getComponentInstanceByName(argstr)
            self.option.onrclicked(self.invItemList[argnum])
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
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
