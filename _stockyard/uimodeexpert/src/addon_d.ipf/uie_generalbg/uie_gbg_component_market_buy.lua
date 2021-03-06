--uie_gbg_component_market_buy
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
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT
g.gbg = g.gbg or {}


g.gbg.uiegbgComponentMarketBuy = {
    new = function( parentgbg, name,option)
        local self = inherit(g.gbg.uiegbgComponentMarketBuy, g.gbg.uiegbgComponentInventory, parentgbg, name, option)
        self.option=self.option or {}
        self.option.onclicked=self.option.onclicked or nil
        self._searchoption=nil
        self._searchpage=0
        self.marketItems={}
        return self
    end,
    initializeImpl = function(self, gbox)
        g.gbg.uiegbgComponentInventory.initializeImpl(self, gbox)

    end,
    reset = function(self)
      

        self:disposeIES()
        self:refreshInventory()
    end,
    releaseImpl=function(self)
        self:disposeIES()
    end,
    disposeIES=function(self)
        for _,v in ipairs(self.marketItems) do
            DestroyIES(v.ies)
        end
        UIE_GENERALBG_TOOLTIP_GUID={}
        self.marketItems={}
    end,
    setCustomEventScript = function(self, slot, inv)
        slot:SetEventScript(ui.LBUTTONUP, 'UIE_GBG_MARKETBUY_LBUTTON')
        slot:SetEventScriptArgNumber(ui.LBUTTONUP, inv.index)
        slot:SetEventScriptArgString(ui.LBUTTONUP, self.name)
    end,
    search=function(self,option)
        self._searchoption=option
        session.market.ClearItems();
        session.market.ClearRecipeSearchList();
        
        self:startRetrieveMarketItems(0)
    end,
    startRetrieveMarketItems=function(self,page)
        local name= self._searchoption.name
        local parentname=nil
        local concatname=name

        if  self._searchoption.parent then
            local parent=self._searchoption.parent
            while parent.parent do
                parent=parent.parent
            end
            parentname=parent
            concatname=parentname
            concatname=parentname..'_'..name
        else
            concatname=name..'_ShowAll'
        end
     
        self._searchpage=page
        local itemCntPerPage=GET_MARKET_SEARCH_ITEM_COUNT(name)
        local maxPage = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
        local curPage = session.market.GetCurPage();
        if page==0 or  curPage<maxPage-1 then
         
            g.util.namedReserveScript('market_buy',function()
                print('SEARCH!'..page..concatname..itemCntPerPage)
                MarketSearch(page + 1, 0, '',concatname, {}, {},itemCntPerPage);	
            end,0.6)
        end
      
    end,
    getItemListImpl=function(self)
        --override me
        local invItemList=  self.marketItems
        return deepcopy(invItemList),true
    end,
    updateItemListMarket=function(self)

        local mySession = session.GetMySession();
        local cid = mySession:GetCID();
        local count = session.market.GetItemCount();
        for i = 0 , count - 1 do
            local marketItem = session.market.GetItemByIndex(i);
            local itemCls = GetClassByType('Item', marketItem.itemType)
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
            local itemObj=GetIES(marketItem:GetObject())
            
            self.marketItems[#self.marketItems+1]={
                item=marketItem,
                clsid=marketItem.itemType,
                ies=CloneIES(GetIES(marketItem:GetObject())),
                rank=rank,
                guid=marketItem:GetMarketGuid(),
                price=marketItem:GetSellPrice(),
                count=marketItem.count,
                props=TryGetProp(itemObj,'BasicTooltipProp')
            }
            UIE_GENERALBG_TOOLTIP_GUID[marketItem:GetMarketGuid()]=self.marketItems[#self.marketItems]
        end

        self:refreshInventory()
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
                        if a.clsid == b.clsid then
                            if a.price == b.price then
                                return IsGreaterThanForBigNumber(b.price,a.price) 
                            else
                                return a.guid < b.guid
                            end
                        else
                            return a.clsid < b.clsid
                        end
                    end
                end
            )
        end

        local treename = nil
        local slotidx = 0
        local oy = 0
        local slotset = nil
        local slotsize = self.option.slotsize
        local cnt = 0
        local col =6
        self.col = col
        self.invItemList = invItemList
        local beginidx=0
        for k, v in ipairs(invItemList) do
            local invItem = v.item

            if invItem ~= nil then
                local itemObj = v.ies
                local itemCls = GetClassByType('Item', v.clsid)

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
                            slotset:SetSlotCount(slotidx)
                            slotset:SetUserValue('count',slotidx)
                            oy = oy + slotset:GetHeight() + 5
                        end
                        local rich = gboxin:CreateOrGetControl('richtext', 'category' .. treename, 0, oy, gboxin:GetWidth(), 30)
                        rich:SetText('{@stb42}' .. treename)
                        oy = oy + 30 + 5
                        slotset = gboxin:CreateOrGetControl('slotset', 'slotset' .. treename, 0, oy, gboxin:GetWidth()-20, 0)
                        AUTO_CAST(slotset)
                        slotset:SetColRow(col, 1)
                        slotset:SetSpc(0, 0)

                        slotset:SetSlotSize(slotset:GetWidth()/col, slotsize)
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
                        parentslot:SetEventScript(ui.RBUTTONUP, 'UIE_GBG_COMPONENTMARKET_ON_RCLICK')
                        parentslot:SetEventScriptArgString(ui.RBUTTONUP, self.name)
                        parentslot:SetEventScriptArgNumber(ui.RBUTTONUP, k)
                    end
                    self:setCustomEventScript(parentslot, invItemList[k])

                    slotidx = slotidx + 1
                end
            end
        end
     
            
    end,
    updateSlot = function(self, index)
        local inv=self.invItemList[index]

        local frame = ui.GetFrame('inventory')
        local slot =inv.slot
        local invItem = inv.item
        AUTO_CAST(slot)
        local slotsize=self.option.slotsize

        local childslot=slot:CreateOrGetControl('slot','child',0,0,slotsize,slotsize)
        AUTO_CAST(childslot)
        local icon = CreateIcon(childslot)
        local itemobj =  inv.ies
        local picon = CreateIcon(slot)
        local textname=slot:CreateOrGetControl('richtext','textname',slotsize,0,slot:GetWidth(),20)
        textname:EnableHitTest(0)
        textname:SetText('{ol}'..itemobj.Name)
        local textprice=slot:CreateOrGetControl('richtext','textprice',slotsize,0,slot:GetWidth(),20)
        textprice:EnableHitTest(0)
        local priceStr = inv.price
        textprice:SetText(g.util.generateSilverString(GetMonetaryString(priceStr)))
        textprice:SetGravity(ui.LEFT,ui.BOTTOM)

        slot:EnableDrag(0)
        slot:EnableDrop(0)
        slot:EnablePop(0)
        slot:SetColorTone('FFFFFFFF')
        childslot:EnableHitTest(0)
        childslot:EnableDrag(0)
        childslot:EnableDrop(0)
        childslot:EnablePop(0)
        childslot:SetColorTone('FFFFFFFF')
        --childslot:EnableHitTest(0)

        local img =	GET_EQUIP_ITEM_IMAGE_NAME(itemobj, "TooltipImage");
        if itemobj.GroupName == "Card" or itemobj.GroupName == "Recipe" then
            img = itemobj.Icon
        end
        local itemName = GET_FULL_NAME(itemobj);
        local properties = inv.props
        SET_SLOT_IMG(childslot, img);
        local props=properties
        local baseCls = GetClassByType('Item', inv.clsid);
        if IS_SKILL_SCROLL_ITEM(baseCls) == 0 then -- 스킬 스크롤이 아니면


            picon:SetTooltipType('wholeitem');
			picon:SetTooltipArg('uie_market', inv.clsid,inv.guid);

        else
            local skillType, level = GetSkillScrollProperty(props);
            picon:SetTooltipType('skill');
            picon:SetTooltipArg("Level", skillType, level);

        end
    
        --SET_ITEM_TOOLTIP_ALL_TYPE(icon, invItem, itemobj.ClassName, "market", inv.clsid,inv.guid);	
        -- if IS_SKILL_SCROLL_ITEM_BYNAME( itemobj.ClassName) == true then
        --     local obj = itemobj;
        --     SET_TOOLTIP_SKILLSCROLL(picon, obj, nil, "market");
        -- else
        --     picon:SetTooltipType('wholeitem');
        --     if nil ~= "market" and nil ~=  inv.clsid and nil ~= inv.guid then			
        --         picon:SetTooltipArg("market",  inv.clsid, inv.guid);
        --     end
        -- end
        SET_SLOT_BG_BY_ITEMGRADE(slot, itemobj.ItemGrade)
        SET_SLOT_STYLESET(childslot, itemobj,0)
        childslot:SetSkinName('None')
        
        -- 아이커 종류 표시	
        SET_SLOT_ICOR_CATEGORY(childslot, itemobj);
        if itemobj.MaxStack > 1 then
            local font = '{s16}{ol}{b}';
            if 100000 <= inv.count then	-- 6자리 수 폰트 크기 조정
                font = '{s14}{ol}{b}';
            end
            SET_SLOT_COUNT_TEXT(childslot, inv.count, font);
        end
        
    end,
    defaultHandlerImpl = function(self, key, frame)
        return g.uieHandlergbgComponentMarketBuy.new(key, frame, self,self.tooltipxy)
    end,
    hookmsgImpl = function(self, frame, msg, argStr, argNum)
        if msg == 'MARKET_ITEM_LIST' then
            print('hook')
            self:updateItemListMarket()
            --next 
            self:startRetrieveMarketItems( self._searchpage+1)
            
        end
    end,
}
g.uieHandlergbgComponentMarketBuy = {
    new = function(key, frame,gbg,tooltipxy)
        local self = inherit(g.uieHandlergbgComponentMarketBuy, g.uieHandlergbgBase, key,frame,gbg)
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