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
g.classes.JSNCommonSlotSetComponent=function(jsnmanager,jsnframe,parent,eventhandler)

    local self={
        _className="JSNCommonSlotSetComponent",
        _slotsetInterface=nil,
        _cursorIndex=0,
        getSlotSetInterface=function(self)
            return self._slotsetInterface
        end,
        initImpl=function(self)
            self._slotsetInterface=self:addInterface(g.classes.JSNISlotset(self:getWrapperNativeControl()):init())
            self:relayout()
            self:updateCursorPos()
        end,
        relayoutImpl=function (self)
            self._slotsetInterface:setClippingRect(self:getRect())
        end,
        onResizeImpl=function(self)
            self:relayout()
        end,
        autoSelectColumnCount=function(self)
          
            self:setColumnCount(math.max(1,math.floor(self:getWidth()/
            (self:getSlotSetInterface():getSlotWidth()+self:getSlotSetInterface():getSlotSpcX())
        )))
        end,
        setColumnCount=function(self,columnCount)
            self._slotsetInterface:setColumnCount(columnCount)
        end,
        getCursorSlot=function(self)
            return self._slotsetInterface:getSlotByIndex(self._cursorIndex)
        end,
        getCursorIndex=function(self)
            return self._cursorIndex
        end,
        setCursorIndex=function(self,index)
            self._cursorIndex=math.max(0,math.min(index,self._slotsetInterface:getSlotCount()-1))
        end,
        updateCursorPos=function (self)
 
            local rect=self:calculateCursorPos()
            self:setCursorRect(rect.x,rect.y,rect.w,rect.h)
        end,
        setCursorRect=function(self,x,y,w,h)
            self._supers['JSNFocusable'].setCursorRect(self,x,y,w,h)
            self:ensureScroll(y+h/2,self:getSlotSetInterface():getSlotHeight())
        end,
        calculateCursorPos=function (self,index)
            local idx=index or self:getCursorIndex()
            local rect={
                x=idx%self._slotsetInterface:getColumnCount()*(self._slotsetInterface:getSlotWidth()+self._slotsetInterface:getSlotSpcX()),
                y=math.floor(idx/self._slotsetInterface:getColumnCount())*(self._slotsetInterface:getSlotHeight()+self._slotsetInterface:getSlotSpcY()),
                w=(self._slotsetInterface:getSlotWidth()+self._slotsetInterface:getSlotSpcX()),
                h=(self._slotsetInterface:getSlotHeight()+self._slotsetInterface:getSlotSpcY())}
                return rect;
        end,
        
        onKeyDownImpl=function(self,key)
            if g.classes.JSNKey.MAIN==key and self:getCursorSlot() then
                if(self:invokeEvent(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedDetermine,
                    self:getCursorSlot(),self:getCursorIndex()
                ))then
          
                    return true
                end
               
            end
            if(key==g.classes.JSNKey.OPTION)then
                if(self:invokeEvent(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedMenu,
                    self:getCursorSlot(),self:getCursorIndex()
                ))then
   
                    return true
                end
            end
            if(key==g.classes.JSNKey.CANCEL)then
                if(self:invokeEvent(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedCancel))then
   
                    return true
                end
            end
        end,
        onKeyRepeatImpl=function(self,key)
            if(key==g.classes.JSNKey.LEFT)then
                self:setCursorIndex(self:getCursorIndex()-1)
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.RIGHT)then
                self:setCursorIndex(self:getCursorIndex()+1)
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.UP)then
                self:setCursorIndex(self:getCursorIndex()-self._slotsetInterface:getColumnCount())
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.DOWN)then
                self:setCursorIndex(self:getCursorIndex()+self._slotsetInterface:getColumnCount())
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
           
        end,
    }

    local object=g.inherit(self,
    g.classes.JSNKeyHandler(jsnmanager), 
    g.classes.JSNGenericEventHandler(jsnmanager,eventhandler),
    g.classes.JSNComponent(jsnmanager,jsnframe,parent))
    
    return object
end


