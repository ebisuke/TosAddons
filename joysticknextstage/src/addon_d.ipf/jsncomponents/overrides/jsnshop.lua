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
      
            slotset:assign(itergen(),function(v,slot)
                local priceText	= string.format(" {img icon_item_silver 20 20} {@st66b}%s", GET_SHOPITEM_PRICE_TXT(shopItem));
                
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

    local object=g.inherit(self, g.classes.JSNCommonSlotSetComponent(jsnmanager,jsnframe,parent,selectHandler),g.classes.JSNFocusable(jsnmanager,self))
    return object
end

g.classes.JSNShopOverrider=function (jsnmanager,overridenFrame)
    local self={
        _className="JSNBlackScreenOverrider",
        _shopSlotSet=nil,
        _inventorySlotSet=nil,
        _actionChooser=nil,
        initImpl=function (self)
            if(self:getOriginalNativeFrame():GetLayerLevel() >= self:getLayerLevel())then
                self:setLayerLevel(self:getOriginalNativeFrame():GetLayerLevel()+1)
            end
            self._inventorySlotSet=g.classes.JSNInventoryComponent(
                jsnmanager,
                self,
                self,
                function(invItem)
                    local Itemclass = GetClassByType("Item", invItem.type);
                    local itemProp = geItemTable.GetPropByName(Itemclass.ClassName);
                    return itemProp:IsEnableShopTrade()
                end
            ):init()
            self._inventorySlotSet:fitToFrame(0,200,0,30)
            self._inventorySlotSet:setWidth(self:getWidth()/2-60,self:getHeight()-330)
            self._inventorySlotSet:setGravity(ui.RIGHT,ui.TOP)
            self._inventorySlotSet:setOffset(40,200)
            self._inventorySlotSet:autoSelectColumnCount()
            self._inventorySlotSet:hook(
                "onKeyDownImpl",
                function(_self,key)
                    if(key==g.classes.JSNKey.CANCEL)then
                        _self:unfocus()
                        self:generateMainMenu()
                        return true,true
                    else
                        --ignore other keys
                        return true,false
                    end
                end
            )
            self._inventorySlotSet:refresh()
            self._shopSlotSet=g.classes.JSNShopComponent(
                jsnmanager,
                self,
                self
            ):init()
            self._shopSlotSet:fitToFrame(0,200,0,30)
            self._shopSlotSet:setWidth(self:getWidth()/2-60,self:getHeight()-230)
            self._shopSlotSet:setOffset(40,200)
            self._shopSlotSet:setGravity(ui.LEFT,ui.TOP)
            self._shopSlotSet:autoSelectColumnCount()
            self._shopSlotSet:hook(
                "onKeyDownImpl",
                function(_self,key)
                    if(key==g.classes.JSNKey.CANCEL)then
                        _self:unfocus()
                        self:generateMainMenu()
                        return true,true
                    else
                        --ignore other keys
                        return true,false
                    end
                end
            )
            self._shopSlotSet:refresh()
            self:generateMainMenu()
            
          
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
                            
                        end
                    },
                    {
                        text="Sell",
                        onClick=function()
                            
                        end
                    },
                    {
                        text="{b}Settle",
                        onClick=function()
                            
                        end
                    },
                    {
                        text="Cancel",
                        onClick=function(self)
                            self:invokeEvent(g.classes.JSNGenericEventHandlerType.eventUserRequestedClose)
                        end
                    },
                },{
                    eventUserRequestedClose=function(self)
                        DBGOUT("eventUserRequestedClose")
                        self:getParent():getOwner():release()
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

