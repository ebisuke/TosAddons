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
local function GenerateMenuByItem(invItem)
    local menus={}
    if(not invItem.isLockState) then
        menus[#menus+1] = {
            text="Use Item",
            onClick=function()
                INV_ICON_USE(invItem)
            end
        }
    end
    return menus
end
g.classes=g.classes or {}
g.classes.JSNCommonSlotSetComponent=function(jsnmanager,jsnframe)

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
        setColumnCount=function(self,columnCount)
            self._slotsetInterface:setColumnCount(columnCount)
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
            if(key==g.classes.JSNKey.OPTION)then
                local rect=self:calculateCursorPos()
                local x,y=rect.x+self:getX(),rect.y+self:getY()
                --local x,y=rect.x,rect.y
                local dialog=self:callModal(
                    g.classes.JSNContextMenuFrame(
                        self:getJSNManager(),
                        self:getJSNFrame(),
                        x+20,
                        y+20-self:getScrollY(),
                        200,
                        rect.h,
                        GenerateMenuByItem(self:getSlotSetInterface():getItemByIndex(self:getCursorIndex()))):init(),
                    function ()
                        self:refresh()
                    end)
                
                imcSound.PlaySoundEvent(g.sounds.POPUP)
            end
        end,
        onKeyRepeatImpl=function(self,key)
            if(key==g.classes.JSNKey.LEFT)then
                self:setCursorIndex(self:getCursorIndex()-1)
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
            end
            if(key==g.classes.JSNKey.RIGHT)then
                self:setCursorIndex(self:getCursorIndex()+1)
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
            end
            if(key==g.classes.JSNKey.UP)then
                self:setCursorIndex(self:getCursorIndex()-self._slotsetInterface:getColumnCount())
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
            end
            if(key==g.classes.JSNKey.DOWN)then
                self:setCursorIndex(self:getCursorIndex()+self._slotsetInterface:getColumnCount())
                self:updateCursorPos()
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
            end
            
        end,
    }

    local object=g.inherit(self,g.classes.JSNKeyHandler(jsnmanager), g.classes.JSNComponent(jsnmanager,jsnframe))
    
    return object
end


