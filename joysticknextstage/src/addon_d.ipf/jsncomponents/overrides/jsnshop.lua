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

g.classes.JSNShopComponent=function (jsnmanager,jsnframe,parent)
    local self={
        _className="JSNInventoryComponent",
        _selectHandler=selectHandler,
        _submenuHandler=submenuHandler,
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
                local priceText	= string.format(" {img icon_item_silver 30 30} {ol}{s25}%s", GET_COMMAED_STRING(cls.SellPrice));
                local img=slot:CreateOrGetControl("picture","img",0,0,64,64)
                slot:SetUserValue("ITEM_CLSID", shopItem.type)
                CreateIcon(slot)
                AUTO_CAST(img)
                img:SetEnableStretch(1)
                img:SetImage(cls.Icon)
                local text=slot:CreateOrGetControl("richtext","price",0,0,20,64)
                text:SetText(priceText)
                text:SetGravity(ui.RIGHT,ui.UP)
            end)
        end,
        eventUserRequestedDetermine=function(self,slot,slotindex)
          
        end,
        -- onKeyDownImpl=function(self,key)
        --     local handler
          
        --     if self:getSubmenuHandler() then
        --         handler=self:getSubmenuHandler()
        --     end
        --     if g.classes.JSNKey.MAIN==key and self:getSelectHandler() then
        --         DBGOUT("JSNInventoryComponent onKeyDownImpl")
        --         if(self:getSelectHandler()(self:getCursorItem(),self,self:getCursorSlot()))then
        --             g.fn.ReserveFunction(0.01,function()
        --                 self:releaseAllRelationship()
        --             end)
                 
                    
        --         end
        --         return true
        --     end
        --     if(key==g.classes.JSNKey.OPTION and handler)then
        --         local rect=self:calculateCursorPos()
        --         local x,y=rect.x+self:getX(),rect.y+self:getY()
     
        --         --local x,y=rect.x,rect.y
        --         local dialog=self:callModal(
        --             g.classes.JSNContextMenuFrame(
        --                 self:getJSNManager(),
        --                 self:getParent(),
        --                 x+20,
        --                 y+20-self:getScrollY(),
        --                 200,
        --                 rect.h,
        --                 handler(
        --                     self:getCursorItem(),
        --                     self,
        --                     self:getCursorSlot())):init(),
        --             function ()
        --                 g.fn.ReserveFunction(0.1,function ()
        --                     self:refresh()
        --                 end)
        --             end)
                
        --         imcSound.PlaySoundEvent(g.sounds.POPUP)
        --         return true
        --     end
        -- end,
    }

    local object=g.inherit(self, g.classes.JSNCommonSlotSetComponent(jsnmanager,jsnframe,parent),g.classes.JSNFocusable(jsnmanager,self))
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
        initImpl=function (self)
            if(self:getOriginalNativeFrame():GetLayerLevel() >= self:getLayerLevel())then
                self:setLayerLevel(self:getOriginalNativeFrame():GetLayerLevel()+1)
            end
            local eventHandler={
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
                eventUserRequestedDetermine=function(_self,slot,slotindex)
                    local guid=slot:getNativeSlot():GetUserValue("ITEM_GUID")
                    local clsid=slot:getNativeSlot():GetUserValue("ITEM_CLSID")
                    if(guid) then

                    else
                    end
                    imcSound.PlaySoundEvent("button_inven_click_item");
                    return false
                end,
            }
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
                    local priceText	= string.format(" {img icon_item_silver 30 30} {s25}{ol}%s", GET_COMMAED_STRING(cls.SellPrice));
                    local img=slot:CreateOrGetControl("picture","img",0,0,64,64)
                    AUTO_CAST(img)
                    img:SetImage(cls.Icon)
                    img:SetEnableStretch(1)
                    local text=slot:CreateOrGetControl("richtext","price",0,0,20,64)
                    text:SetText(priceText)
                    text:SetGravity(ui.RIGHT,ui.UP)
                end
            ):init()
            self._inventorySlotSet:setEventHandler(eventHandler)
            self._inventorySlotSet:setSlotSize(128,64)
            self._inventorySlotSet:fitToFrame(0,200,0,30)
            self._inventorySlotSet:setWidth(self:getWidth()/2-80,self:getHeight()-430)
            self._inventorySlotSet:setGravity(ui.LEFT,ui.TOP)
            self._inventorySlotSet:setOffset(self:getWidth()/2+120,200)
            self._inventorySlotSet:autoSelectColumnCount()

            self._inventorySlotSet:refresh()
            self._shopSlotSet=g.classes.JSNShopComponent(
                jsnmanager,
                self,
                self
            ):init()
            self._shopSlotSet:setEventHandler(eventHandler)
            self._shopSlotSet:fitToFrame(0,200,0,30)
            self._shopSlotSet:setWidth(self:getWidth()/2-80,self:getHeight()-430)
            self._shopSlotSet:setOffset(40,200)
            self._shopSlotSet:setGravity(ui.LEFT,ui.TOP)
            self._shopSlotSet:autoSelectColumnCount()

            self._shopSlotSet:refresh()


            self._buySlotSet=g.classes.JSNCommonSlotSetComponent(
                jsnmanager,
                self,
                self):init();
            self._buySlotSet:resize(self:getWidth()/2-60,128)
            self._buySlotSet:setOffset(40,self:getHeight()-200)
            self._buySlotSet:autoSelectColumnCount()

            self._sellSlotSet=g.classes.JSNCommonSlotSetComponent(
                jsnmanager,
                self,
                self):init();
            self._sellSlotSet:resize(self:getWidth()/2-60,128)
            self._sellSlotSet:setOffset(self:getWidth()/2+120,200)
            self._sellSlotSet:autoSelectColumnCount()
    

            self:generateMainMenu()
            
          
        end,
        addSellItem=function (self,item)
            self._sellSlotSet:addItem(item)
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
        releaseImpl=function (self)

        end,
    }
    local obj=g.inherit(self,
    g.classes.JSNBlackScreenOverrider(jsnmanager,overridenFrame,"Shop"),
    g.classes.JSNOwnerRelation(),
    g.classes.JSNFocusable(jsnmanager,self))
    return obj
    
end

