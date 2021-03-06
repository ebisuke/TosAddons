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

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT
g.gbg=g.gbg or {}
g.gbg.uiegbgComponentShop = {
    new = function(parentgbg, name, updatecallback,option)
        local self = inherit(g.gbg.uiegbgComponentShop, g.gbg.uiegbgComponentBase, parentgbg, name)
        self.updatecallback = updatecallback
        self.buy = {}
        self.col=3
        self.option=option
        self.option.tooltipxy=self.option.tooltipxy or nil
        return self
    end,
    initializeImpl = function(self, gbox)
        gbox:SetSkinName('bg')
        local gboxin = gbox:CreateOrGetControl('groupbox', 'gboxin', 0, 0, gbox:GetWidth() - 25, gbox:GetHeight())
        local gboxtab = gbox:CreateOrGetControl('groupbox', 'gboxtab', gbox:GetWidth() - 25, 0, 25, gbox:GetHeight())
        AUTO_CAST(gboxin)
        AUTO_CAST(gboxtab)

        --create tabs
        for k, v in ipairs(g.util.inventory_filters) do
            local btn = gboxtab:CreateOrGetControl('button', 'btn' .. v.name, 0, 35 * (k - 1), 25, 25)
            btn:SetSkinName('none')
        end
        --create inven
        self:refreshShop(gboxin)
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
    end,
    reset=function(self)

        self:refreshShop()
        if self.updatecallback then
            self.updatecallback()
        end
    end,
    buyItem = function(self, index, amount)
        local inv = self.invItemList[index]
        inv.amount = math.max(0, inv.amount + amount)
        self:updateSlot(index)
        if self.updatecallback then
            self.updatecallback()
        end
        imcSound.PlaySoundEvent("button_inven_click_item");
    end,
    defaultHandlerImpl=function(self,key,frame)
        
        return g.uieHandlergbgComponentShop.new(key,frame,self,self.option.tooltipxy)
    end,
    calcTotalValue=function(self)
        local invItemList=self.invItemList
        local total='0'
        for k, v in ipairs(invItemList) do
            if v.amount and v.amount>0 then
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
            gboxin = self.gbox:GetChild('gboxin')
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
                    for _, v in ipairs(g.util.inventory_filters) do
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
        local col = self.col

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
    end,
}
g.uieHandlergbgComponentShop = {
    new = function(key, frame,gbg,tooltipxy)
        local self = inherit(g.uieHandlergbgComponentShop, g.uieHandlergbgBase, key,frame,gbg)
        self.tooltipxy=tooltipxy
        self.cursor=0
        return self
    end,
    delayedenter = function(self)
        
        self:moveMouse()
    end,
    moveMouse=function(self)
        local slot=self.gbg.invItemList[self.cursor+1].slot
        local item=self.gbg.invItemList[self.cursor+1].item
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
            if self.option.tooltipxy then
                --g.util.showItemToolTip(item,self.tooltipxy.x,self.tooltipxy.y)
            end
        end
    end,
    tick = function(self)
        local count=#self.gbg.invItemList
        if count > 0 then
            if g.key:IsKeyPressed(g.key.SUB) then
                local gbg=self.gbg
                if g.key:IsKeyPress(g.key.RIGHT) then
                    -- +1
                    gbg:buyItem(self.cursor+1, 1)
          
                end
                if g.key:IsKeyPress(g.key.LEFT) then
                    -- +1
                    gbg:buyItem(self.cursor+1, -1)

                end
                if g.key:IsKeyPress(g.key.UP) then
                    -- 10
                    gbg:buyItem(self.cursor+1, 10)
       
                end
                if g.key:IsKeyPress(g.key.DOWN) then
                    -- -10
                    gbg:buyItem(self.cursor+1, -10)
                    
                end
                if g.key:IsKeyPress(g.key.PAGEUP) then
                    -- -100
                    gbg:buyItem(self.cursor+1, -100)
                   
                end
                if g.key:IsKeyPress(g.key.PAGEDOWN) then
                    -- 100
                    gbg:buyItem(self.cursor+1, 100)
                    
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
                    self.cursor = self.cursor + self.gbg.col
                    if self.cursor >= count then
                        self.cursor = 0
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                if g.key:IsKeyPress(g.key.UP) then
                    --up
                    self.cursor = self.cursor - self.gbg.col
                    if self.cursor < 0 then
                        self.cursor = count - 1
                    end
                    self:moveMouse()
                    g:onChangedCursor()
                end
                
                if g.key:IsKeyDown(g.key.CANCEL) then
                    g:onCanceledCursor()
                    return g.uieHandlerBase.RefEnd
                end

            end
            if g.key:IsKeyDown(g.key.MAIN) then
                local scp
                local idx = self.cursor
                local ctrl = self.gbg.invItemList[self.cursor+1].slot

                if ctrl:GetClassString() == 'ui::CButton' or ctrl:GetClassString() == 'ui::CCheckBox' or ctrl:GetClassString() == 'ui::CSlot' then
                    local evt
                    if g.key:IsKeyDown(g.key.MAIN) then
                        evt = ui.RBUTTONUP
                        scp = ctrl:GetEventScript(evt)
                        if not scp then
                            evt = ui.RBUTTONDOWN
                            scp = ctrl:GetEventScript(evt)
                            if not scp then
                                evt = ui.RBUTTONPRESSED
                                scp = ctrl:GetEventScript(evt)
                                if not scp then
                                --none
                                end
                            end
                        end
                    end

                    local scpnum = ctrl:GetEventScriptArgNumber(evt)
                    local scpstr = ctrl:GetEventScriptArgString(evt)

                    if scp and ctrl:IsEnable()==1 then
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
                -- if ctrl:GetClassString() == 'ui::CSlot' then
                --     if g.key:IsKeyDown(g.key.MAIN) then
                --         local parent = ctrl:GetParent()
                --         if parent:GetClassString()=='ui::CSlotSet' then
                --             AUTO_CAST(parent)
                            
                --             if ctrl:IsSelected() == 1 then
                --                 ctrl:Select(0)
                --             else
                --                 ctrl:Select(1)
                --             end
                --             parent:MakeSelectionList()
                --             parent:Invalidate()
                --         else
                --             if ctrl:IsSelected() == 1 then
                --                 ctrl:Select(0)
                --             else
                --                 ctrl:Select(1)
                --             end
                --         end
                --     end
                -- end
                return g.uieHandlerBase.RefRefresh
            end
        end
        return g.uieHandlerBase.RefPass
    end,
    updateToolTip=function(self)
        local inv=g.inv.getUIEInventoryByFrameName(self.frame:GetName())
        local base=inv.base
        local slotset=base:GetChildRecursively('slotset')
        AUTO_CAST(slotset)
        local itemcount=inv.itemcount
        local slot
          local cols=slotset:GetCol()
        if itemcount>0 then 
            slot=slotset:GetSlotByRowCol(math.floor(self.itemcursor/cols),self.itemcursor%cols)
        else
            inv:hideToolTip()
            return
        end
        local Icon=slot:GetIcon()
        local iconInfo = Icon:GetInfo();
        
        local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
        inv:showToolTip(invItem)
    end,
    leave=function(self)
        g.uieHandlergbgBase.leave(self)
        g.util.hideItemToolTip()
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
            if keyboard.IsKeyPressed('LSHIFT')==1 then
                local shopItem=self.invItemList[argnum].item

                local itemPrice = shopItem.price * shopItem.count;
                local buyableCnt = math.floor(tonumber(GET_TOTAL_MONEY_STR()) / itemPrice);
                local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", buyableCnt);
                INPUT_NUMBER_BOX(frame:GetTopParentFrame(), titleText, "UIE_GBG_COMPONENT_SHOP_EXEC_SHOP_SLOT_BUY", 1, 1, UIE_GBG_COMPONENT_SHOP_EXEC_SHOP_SLOT_BUY, argnum, argstr, 1)
            else
                self:buyItem(argnum, -1)
                imcSound.PlaySoundEvent("button_inven_click_item");
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function  UIE_GBG_COMPONENT_SHOP_EXEC_SHOP_SLOT_BUY(frame, ret,argStr, argNum)
    local self = g.gbg.getComponentInstanceByName(argstr)
    local shopItem=self.gbg.invItemList[argNum].item
    self:buyItem(argNum, ret)
end
