--jsnshop.lua
--アドオン名（大文字）
local addonName = "jsn_commonlib"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end


local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
g.classes=g.classes or {}

g.classes.JSNShopComponent=function (jsnmanager,jsnframe,parent,slotPostGenerateHandler)
    local self={
        _className="JSNInventoryComponent",
        _slotPostGenerateHandler=slotPostGenerateHandler,
        initImpl=function(self)
            self:setSlotSize(256,64)
            self:refresh()
        end,
        getCursorItem=function(self)
            --conventional func
            
            local slot= self:getCursorSlot():getNativeSlot()
            if slot==nil then
                DBGOUT("getCursorItem:slot is nil")
                return nil
            end
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());

            return invItem

        end,
        setInventoryFilter=function(self,inventoryFilter)
            self._inventoryFilter=inventoryFilter
        end,

        refreshImpl=function(self)
          
            session.BuildInvItemSortedList();
            local sortedList = session.GetInvItemSortedList();
            local invItemCount = sortedList:size();
            --sortedList:at(i);
            local slotset=self:getSlotSetInterface()
            local filter=self._inventoryFilter
            DBGOUT("JSNInventoryComponent Refersh Impl")
            local itergen=function()
                local i=0
                local shopItemList = session.GetShopItemList();
                local count=shopItemList:Count()
                return function()
                    if i<count then
                        local shopItem=shopItemList:PtrAt(i)
                        i=i+1
                        return shopItem
                    end
                    
                end
            end
      
            slotset:assign(itergen(),function(shopItem,slot)
               
                local cls=GetClassByType("Item",shopItem.type)
                local priceText	= string.format(" {img icon_item_silver 20 20} {ol}{s20}%s", GET_COMMAED_STRING(shopItem.price));
                local img=slot:CreateOrGetControl("picture","img",0,0,64,64)
                slot:SetUserValue("ITEM_CLSID", shopItem.type)
                slot:SetUserValue("SHOP_CLSID", shopItem.classID)
                CreateIcon(slot)
                AUTO_CAST(img)
                img:SetEnableStretch(1)
                img:SetImage(cls.Icon)
                
                local text=slot:CreateOrGetControl("richtext","price",0,0,64,32)
                text:SetText(priceText)
                text:SetGravity(ui.RIGHT,ui.UP)
                if(self._slotPostGenerateHandler)then
                    self._slotPostGenerateHandler(shopItem,slot)
                end
                
            end)
        end,
        eventUserRequestedDetermine=function(self,slot,slotindex)
          
        end,
        
    }

    local object=g.inherit(self, g.classes.JSNCommonSlotSetComponent(jsnmanager,jsnframe,parent),
        g.classes.JSNOwnerRelation(),
    g.classes.JSNFocusable(jsnmanager,self))
    return object
end

g.classes.JSNShopOverrider=function (jsnmanager,overridenFrame)
    local self={
        _className="JSNBlackScreenOverrider",
        _shopSlotSet=nil,
        _inventorySlotSet=nil,
        _actionChooser=nil,
        _buySlotSet=nil,
        _sellSlotSet=nil,
        _buyItems={},
        _sellItems={},
        initImpl=function (self)
            if(self:getOriginalNativeFrame():GetLayerLevel() >= self:getLayerLevel())then
                self:setLayerLevel(self:getOriginalNativeFrame():GetLayerLevel()+1)
            end
            
            local selleventHandler={
                eventUserRequestedCancel=function(_self)
                    _self:unfocus()
                    self:generateMainMenu()
                    return true
                end,
                eventUserRequestedClose=function(_self)
                    _self:unfocus()
                    self:generateMainMenu()
                    return true
                end,
                eventUserRequestedMenu=function(_self,slot,slotindex)
                    local guid=slot:getNativeSlot():GetUserValue("ITEM_GUID")
                    
                    if(guid) then
                        local invItem=GET_PC_ITEM_BY_GUID(guid)
                        g.fn.InputNumberBox(self,"How many would you link to?",1,invItem.count,
                        function(count)
                            self:addSellItem(invItem,count)
                            imcSound.PlaySoundEvent("button_inven_click_item");
                            
                        end)
                        self:refresh()
                    end

                    return false
                end,
                eventUserRequestedDetermine=function(_self,slot,slotindex)
                    local guid=slot:getNativeSlot():GetUserValue("ITEM_GUID")
                    
                    if(guid) then
                        local invItem=GET_PC_ITEM_BY_GUID(guid)
                        self:addSellItem(guid,1)
                        imcSound.PlaySoundEvent("button_inven_click_item");
                        self:refresh()
                    else
                    end
                   
          
                    return false
                end,
                eventUserRequestedSubAction=function(_self,slot,slotindex)
                    
                    local guid=slot:getNativeSlot():GetUserValue("ITEM_GUID")
                 
                    imcSound.PlaySoundEvent("inven_unequip");
                    self:removeSellItem(guid)
                    self:refresh()
                    return false
                end,
            }
            ui.EnableSlotMultiSelect(1);

            self._inventorySlotSet=g.classes.JSNInventoryComponent(
                jsnmanager,
                self,
                self,
                function(invItem)
                    local Itemclass = GetClassByType("Item", invItem.type);
                    local itemProp = geItemTable.GetPropByName(Itemclass.ClassName);
                    return itemProp:IsEnableShopTrade()
                end,
                function (invItem,slot)
                    
                    local cls=GetClassByType("Item",invItem.type)
                    SET_SLOT_COUNT(slot, invItem.count)
                    SET_SLOT_STYLESET(slot, cls)
                    CreateIcon(slot)
                    slot:SetUserValue("ITEM_GUID", invItem:GetIESID())
                    slot:SetUserValue("ITEM_CLSID", invItem.type)
                    if(self._sellItems[invItem:GetIESID()]) then
                        DBGOUT("set sell item")
                        slot:Select(1)
                       
                     
                    else
                        slot:Select(0)
                       
                    end
                    local priceText	= string.format(" {img icon_item_silver 24 24} {s25}{ol}%s", GET_COMMAED_STRING(cls.SellPrice));
                    local img=slot:CreateOrGetControl("picture","img",0,0,64,64)
                    AUTO_CAST(img)
                    img:SetImage(cls.Icon)
                    img:SetEnableStretch(1)
                    local text=slot:CreateOrGetControl("richtext","price",0,0,64,32)
                    text:SetText(priceText)
                    text:SetGravity(ui.RIGHT,ui.UP)

                    local text=slot:CreateOrGetControl("richtext","count",0,32,64,32)
                    AUTO_CAST(text)
                    if(self._sellItems[invItem:GetIESID()]) then
                        text:SetText("{ol}{s25}"..self._sellItems[invItem:GetIESID()].count.."/"..invItem.count)
                    else
                        text:SetText("{ol}{s25}"..invItem.count)
                    end
                    text:SetGravity(ui.RIGHT,ui.DOWN)
            
                    
                end
            ):init()
            self._inventorySlotSet:setEventHandler(selleventHandler)
            self._inventorySlotSet:setSlotSize(128,64)
            self._inventorySlotSet:fitToFrame(0,200,0,30)
            self._inventorySlotSet:setWidth(self:getWidth()/2-80,self:getHeight()-430)
            self._inventorySlotSet:setGravity(ui.LEFT,ui.TOP)
            self._inventorySlotSet:setOffset(self:getWidth()/2+120,200)
            self._inventorySlotSet:autoSelectColumnCount()
            self._inventorySlotSet:setEnableSelection(true)

            self._inventorySlotSet:refresh()
            
            ui.EnableSlotMultiSelect(1);
            local buyeventHandler={
                eventUserRequestedCancel=function(_self)
                    _self:unfocus()
                    self:generateMainMenu()
                    return true
                end,
                eventUserRequestedClose=function(_self)
                    _self:unfocus()
                    self:generateMainMenu()
                    return true
                end,
                eventUserRequestedMenu=function(_self,slot,slotindex)
                    local clsid=slot:getNativeSlot():GetUserIValue("SHOP_CLSID")
                    if(clsid) then
           
                        g.fn.InputNumberBox(self,"How many would you like to buy?",1,1,self:calculateBuyableCount(clsid),
                        function(parent,count)
                            self:addBuyItem(clsid,count)
                            imcSound.PlaySoundEvent("button_inven_click_item");
                            
                        end)
                        
                    end
                    self:refresh()
                    return false
                end,
                eventUserRequestedDetermine=function(_self,slot,slotindex)
                    
                    local clsid=slot:getNativeSlot():GetUserIValue("SHOP_CLSID")
                 
                    imcSound.PlaySoundEvent("button_inven_click_item");
                    self:addBuyItem(clsid,1)
                    self:refresh()
                    return false
                end,
                eventUserRequestedSubAction=function(_self,slot,slotindex)
                    
                    local clsid=slot:getNativeSlot():GetUserIValue("SHOP_CLSID")
                 
                    imcSound.PlaySoundEvent("inven_unequip");
                    self:removeBuyItem(clsid)
                    self:refresh()
                    return false
                end,
            }
            self._shopSlotSet=g.classes.JSNShopComponent(
                jsnmanager,
                self,
                self,
                function(shopItem,slot)
                    local clsid=shopItem.classID
                    if(self._buyItems[clsid]) then
                        DBGOUT("set buy item")
                        slot:Select(1)

                    else
                        slot:Select(0)
                       
                    end
                    local text=slot:CreateOrGetControl("richtext","count",0,32,64,32)
                    AUTO_CAST(text)
                    if(self._buyItems[clsid]) then
                        text:SetText("{ol}{s25}"..self._buyItems[clsid].count)
                    else
                        text:SetText("{ol}{s25}")
                    end
                    text:SetGravity(ui.RIGHT,ui.DOWN)

                end
            ):init()
            self._shopSlotSet:setEventHandler(buyeventHandler)
            self._shopSlotSet:setSlotSize(128,64)
            self._shopSlotSet:fitToFrame(0,200,0,30)
            self._shopSlotSet:setWidth(self:getWidth()/2-80,self:getHeight()-430)
            self._shopSlotSet:setGravity(ui.LEFT,ui.TOP)
            self._shopSlotSet:setOffset(20,200)
            self._shopSlotSet:autoSelectColumnCount()
            self._shopSlotSet:refresh()
            self._shopSlotSet:setEnableSelection(true)
            self:generateMainMenu()
            
            self:refresh()
        end,
        addSellItem=function (self,guid,count)
            if(self._sellItems[guid]) then
                self._sellItems[guid].count=self._sellItems[guid].count+count
            else
                DBGOUT("add sell item"..guid)
                self._sellItems[guid]={
                    item=guid,
                    count=count,
                }
            end
            DBGOUT(string.format("addSellItem:%s,%d",guid,count))
            self:refresh()
        end,
        addBuyItem=function(self,shopclsid,count)
            if(self._buyItems[shopclsid])then
                self._buyItems[shopclsid].count=self._buyItems[shopclsid].count+count
            else
                self._buyItems[shopclsid]={
                    item=shopclsid,
                    count=count,
                }
            end
            DBGOUT(string.format("addBuyItem:%d,%d",shopclsid,count))
            self:refresh()
        end,
        removeBuyItem=function(self,shopclsid)
       
            self._buyItems[shopclsid]=nil
            self:refresh()
        end,
        removeSellItem=function(self,iesid)
       
            self._sellItems[iesid]=nil
            self:refresh()
        end,
        clearSettlement=function (self)
            self._sellItems={}
            self._buyItems={}
            self:refresh()
        end,
        calculateBuyableCount=function(self,shopclsid)
            local balance=self:calculateBalance()
            local remain=tonumber(GET_TOTAL_MONEY_STR())-balance
            local item= geShopTable.GetByClassID(shopclsid);
            local count=0
            if(item)then
                count=math.floor(remain/item.price)
            end
            return count
        end,
        settle=function(self)

            local count=0
            for _,v in pairs(self._sellItems) do
                count=count+1
                item.AddToSellList(v.item,v.count)
            end
            if(count>0) then
                item.SellList()
            end

            count=0
            for _,v in pairs(self._buyItems) do
                count=count+1
                item.AddToBuyList(v.item,v.count)
            end
            if(count>0) then
                item.BuyList()
            end

            self:clearSettlement()
        end,
        generateMainMenu=function(self)
            if(self._actionChooser)then
                self._actionChooser:release()
            end
            self._actionChooser=g.classes.JSNContextMenuFrame(
                jsnmanager,
                self,
                self:getWidth()/2-100,
                200,
                200,
                30,
                {
                    {
                        text="Buy",
                        onClick=function()
                            self._shopSlotSet:focus()
                            return true
                        end
                    },
                    {
                        text="Sell",
                        onClick=function()
                            self._inventorySlotSet:focus()
                            return true
                        end
                    },
                    
                    {
                        text="{b}Settle",
                        onClick=function(component)
                            if IsGreaterThanForBigNumber(tostring(-self:calculateBalance()), GET_TOTAL_MONEY_STR()) == 1 then
                                ui.SysMsg(ClMsg('NotEnoughMoney'));
                                imcSound.PlaySoundEvent(g.sounds.ERROR);
                                return false;
                            end
                            
                            self:settle()
                            component:invokeEvent(g.classes.JSNGenericEventHandlerType.eventUserRequestedClose)
                            imcSound.PlaySoundEvent("market_sell");
                            return true
                        end
                    },
                    {
                        text="Cancel",
                        onClick=function(component)
                            component:invokeEvent(g.classes.JSNGenericEventHandlerType.eventUserRequestedClose)
                        end
                    },
                },{
                    eventUserRequestedClose=function(component)
                        DBGOUT("eventUserRequestedClose")
                        component:getParent():getOwner():release()
                        return true
                    end,
                }
            ):init()
            self._actionChooser:focus()
            return self._actionChooser
        end,
        calculateTotalSellPrice=function(self)
            local total=0
            for _,v in pairs(self._sellItems) do
                local itm=GET_PC_ITEM_BY_GUID(v.item)
                if(itm)then
                    local cls=GetClassByType("Item",itm.type)
                    local itemProp = geItemTable.GetPropByName(cls.ClassName);
                    local price=0
                    if itemProp ~= nil then
                        price = geItemTable.GetSellPrice(itemProp);
      
                    end
                    total=total+price*v.count
                end
            end
            return total
        end,
        calculateTotalBuyPrice=function(self)
            local total=0
            for _,v in pairs(self._buyItems) do
                local item= geShopTable.GetByClassID(v.item);
                if(item)then
                    total=total+item.price*v.count
                end
            end
            return total
        end,
        calculateBalance=function(self)
            return self:calculateTotalSellPrice()-self:calculateTotalBuyPrice()
        end,
        refreshImpl=function(self)
            DBGOUT("refreshImpl")
            self._shopSlotSet:refresh()
            self._inventorySlotSet:refresh()

            local balance=self:calculateBalance()
            local text=self:getNativeFrame():CreateOrGetControl("richtext","balance",0,400,100,100)
            local arrow=self:getNativeFrame():CreateOrGetControl("picture","arrow",0,600,100,100)
            local silvers=self:getNativeFrame():CreateOrGetControl("richtext","silvers",0,0,400,30)
            silvers:SetGravity(ui.RIGHT,ui.TOP)
            silvers:SetOffset(100,80)
           
            silvers:SetText(string.format(" {img icon_item_silver 48 48} {s48}{ol}%s",GET_COMMAED_STRING(GET_TOTAL_MONEY_STR())))
            AUTO_CAST(arrow)
            AUTO_CAST(text)
            text:SetGravity(ui.CENTER_HORZ,ui.TOP)
            text:SetTextAlign("center","center")
            arrow:SetGravity(ui.CENTER_HORZ,ui.TOP)
            arrow:SetEnableStretch(1)
            if(balance==0)then
                text:SetText("")
                arrow:ShowWindow(0)
            elseif(balance<0)then
                if IsGreaterThanForBigNumber(tostring(-balance), GET_TOTAL_MONEY_STR()) == 1 then
                    text:SetText("{ol}{s48}{#444444}"..GET_COMMAED_STRING(-balance))
                else
                    text:SetText("{ol}{s48}"..GET_COMMAED_STRING(-balance))
                end
                arrow:ShowWindow(1)
                arrow:SetImage("icon_arrow_left")
                
            else
                
                text:SetText("{ol}{s48}"..GET_COMMAED_STRING(balance))
                arrow:ShowWindow(1)
                arrow:SetImage("icon_arrow_right")
            end

        end,
        releaseImpl=function (self)

        end,
    }
    local obj=g.inherit(self,
    g.classes.JSNBlackScreenOverrider(jsnmanager,overridenFrame,"Shop"),
    g.classes.JSNOwnerRelation(),
    g.classes.JSNFocusable(jsnmanager,self))
    return obj
    
end

