--jsninventory.lua
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
g.classes.JSNInventoryComponent=function(jsnmanager,jsnframe,parent,inventoryFilter,slotFormatter)

    local self={
        _className="JSNInventoryComponent",
        _inventoryFilter=inventoryFilter,
        _slotFormatter=slotFormatter,
        initImpl=function(self)

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
        eventUserRequestedMenu=function(self)
            -- please override
            local rect=self:calculateCursorPos()
            local x,y=rect.x+self:getX(),rect.y+self:getY()

            --local x,y=rect.x,rect.y
            local dialog=self:callModal(
                g.classes.JSNContextMenuFrame(
                    self:getJSNManager(),
                    self:getParent(),
                    x+20,
                    y+20-self:getScrollY(),
                    200,
                    rect.h,
                    self:invokeEvent(
                        g.classes.JSNGenericEventHandlerType.eventRequestGenerateMenu,
                        self:getCursorItem(),
                        self,
                        self:getCursorSlot())):init(),
                function ()
                    g.fn.ReserveFunction(0.1,function ()
                        self:refresh()
                    end)
                end)
            return true
        end,
        eventRequestGenerateMenu=function(self,invItem,sender,slot)
            return g.fn.GenerateMenuByItem(invItem,sender,slot)
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
                
                return function()
                    if(filter~=nil)then
                        while( i<invItemCount and not filter(sortedList:at(i)))do
                            i=i+1
                        end
         
                    end
                    if i<invItemCount then
                        local invItem= sortedList:at(i)
                        i=i+1
                        return invItem
                    end
                    
                end
            end
            local slotFormatter=self._slotFormatter or function(v,slot)
                INV_SLOT_UPDATE(ui.GetFrame("inventory"),v,slot)
            end
            slotset:assign(itergen(),slotFormatter)
        end,
        onKeyDownImpl=function(self,key)
            if self._supers["JSNCommonSlotSetComponent"].onKeyDownImpl(self,key) then
                return true
            end

           
        end,
    }

    local object=g.inherit(self, g.classes.JSNCommonSlotSetComponent(jsnmanager,jsnframe,parent),g.classes.JSNFocusable(jsnmanager,self))
    return object
end

g.classes.JSNInventoryFrame=function(jsnmanager,owner,inventoryFilter,x,y,title)

    local self={
        _className="JSNInventoryFrame",
        _inventoryComponent=nil,
        _inventoryFilter=inventoryFilter,

        initImpl=function(self)
            self._inventoryComponent=g.classes.JSNInventoryComponent(
                self:getJSNManager(),
                self,
                self,
                self._inventoryFilter,
                self._selectHandler,
                self._submenuHandler):init()
            self:setRect(x or 100,y or 100,200,160)
            local offset=0
            if(self:getTitle())then
                local frame=self:getNativeFrame()
                local text=frame:CreateOrGetControl("richtext", "title", 0, 0, self:getWidth(), 30);
                text:SetText("{ol}"..self:getTitle());
                text:SetTextAlign(ui.LEFT, ui.TOP);
                offset=30
            end
            self._inventoryComponent:fitToFrame(4,4+offset,4,4)
            self._inventoryComponent:autoSelectColumnCount()
            self._inventoryComponent:refresh()
            self:getNativeFrame():SetSkinName("test_frame_low")
            self:getNativeFrame():ShowWindow(1)
            
        end,
        lazyInitImpl=   function(self)
            self:focus()

            --self._inventoryComponent:focus()
        end,
        onFocusedImpl=function(self)
            self._inventoryComponent:focus()
        end,

        eventUserRequestedCancel=function(self)
            self:release()
            imcSound.PlaySoundEvent(g.sounds.CANCEL)
        end,
        -- onKeyDownImpl=function(self,key)
        --     if(key==g.classes.JSNKey.CLOSE )then
        --         self:release()
        --         imcSound.PlaySoundEvent(g.sounds.CANCEL)
        --         if(self._cancelHandler)then
        --             self._cancelHandler(self)
        --         end
                
        --         return true
        --     end
            
        -- end,
    }

    local object=g.inherit(self,
    g.classes.JSNCustomFrame(jsnmanager,"jsncomponents",title),
    g.classes.JSNGenericEventHandler(jsnmanager),
    g.classes.JSNPlayerControlDisabler(jsnmanager),
     g.classes.JSNOwnerRelation(owner), 
     g.classes.JSNFocusable(jsnmanager,self))
    
    return object
end