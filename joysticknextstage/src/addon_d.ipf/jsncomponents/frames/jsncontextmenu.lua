--jsncontextmenu.lua
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

g.classes=g.classes or {}
g.classes.JSNContextMenuComponent=function(jsnmanager,jsnframe,menus,eventHandler)

    local self={
        _className="JSNContextMenuComponent",
        _menus=menus,
        _cursorIndex=1,
        _elementHeight=32,
        _margin={
            top=4,
            bottom=4,
            left=4,
            right=4,
        },
        initImpl=function(self)
            local gbox=self:getWrapperNativeControl()
            gbox:SetSkinName("test_frame_low")
            gbox:EnableScrollBar(0)
            local totalHeight=self._margin.top+self._margin.bottom
            for i,v in ipairs(self._menus) do
                local rect=self:calculateMenuRect(i)
                local text=gbox:CreateOrGetControl("richtext","menu_"..i,rect.x,rect.y,rect.width,rect.height)
                AUTO_CAST(text)
                text:SetText("{ol}{s20}"..v.text)
                text:SetTextAlign("left","center")
                totalHeight=totalHeight+rect.h
            end
            self:setRect(0,0,self:getParent():getWidth(),totalHeight)
            
       
        end,
        getCursorIndex=function(self)
            return self._cursorIndex
        end,
        setCursorIndex=function(self,index)
            self._cursorIndex=index
            if(index<=0)then
                self._cursorIndex=#self._menus
            end
            if(index>#self._menus)then
                self._cursorIndex=1
            end
            
          

            self:updateCursorPos()
        end,
        updateCursorPos=function (self)
            local idx=self:getCursorIndex()
            local rect=self:calculateMenuRect()
            self:setCursorRect(rect.x,rect.y,rect.w,rect.h)
        end,
        calculateMenuRect=function(self,idx)
            local index=idx or self:getCursorIndex()
            local menuWidth=self:getJSNFrame():getWidth()-(self._margin.left+self._margin.right)
            local menuHeight=self._elementHeight
            local menuX=self._margin.left
            local menuY=(index-1)*menuHeight+self._margin.top
            return {x=menuX,y=menuY,w=menuWidth,h=menuHeight}
        end,
        eventUserRequestedDetermine=function(self)
            local idx=self:getCursorIndex()
            local menu=self._menus[idx]
            if(menu.onClick)then
                menu.onClick(self)
                return true
            end
        end,
        eventUserRequestedClose=function(self)
            return true
        end,
        onKeyDownImpl=function(self,key)
            if(key==g.classes.JSNKey.CLOSE or key==g.classes.JSNKey.CANCEL)then

                if(self:invokeEvent(g.classes.JSNGenericEventHandlerType.eventUserRequestedClose))then
                    self:getParent():release()
                   
                    imcSound.PlaySoundEvent(g.sounds.CANCEL)
                    return true
                end
               
            end
            if(key==g.classes.JSNKey.MAIN) then
                
                if(self:invokeEvent(g.classes.JSNGenericEventHandlerType.eventUserRequestedDetermine))then
                    self:getParent():release()
                   
                    --imcSound.PlaySoundEvent(g.sounds.DETERMINE)
                    return true
                end
            end
           
        end,
        onKeyRepeatImpl=function(self,key)
            if(key==g.classes.JSNKey.UP)then
                self:setCursorIndex(self:getCursorIndex()-1)
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
            if(key==g.classes.JSNKey.DOWN)then
                self:setCursorIndex(self:getCursorIndex()+1)
                imcSound.PlaySoundEvent(g.sounds.CURSOR_MOVE)
                return true
            end
        end,
    }

    local object=g.inherit(self,
     g.classes.JSNComponent(jsnmanager,jsnframe),
     g.classes.JSNGenericEventHandler(jsnmanager,eventHandler),
     g.classes.JSNKeyHandler(jsnmanager),
     g.classes.JSNFocusable(jsnmanager,self))
    return object
end

g.classes.JSNContextMenuFrame=function(jsnmanager,owner,x,y,w,h,menus,eventHandler)

    local self={
        _className="JSNContextMenuFrame",
        _contextMenuComponent=nil,
        initImpl=function(self)
            local cx,cy=x,y;
            if(menus==nil or #menus==0)then
                self:release()
                return
            end
            self._contextMenuComponent=g.classes.JSNContextMenuComponent(self:getJSNManager(),self,menus,eventHandler):init()

            if(owner)then
                if(not owner:instanceOf(g.classes.JSNFrameBase()) and not owner:instanceOf(g.classes.JSNComponent()))then
                    error("owner is not JSNFrameBase nor JSNComponent.")
                
                end
                local rx,ry=owner:getGlobalX(),owner:getGlobalY()
                cx=cx+rx
                cy=cy+ry
                
            end
            self:setGravity(ui.LEFT,ui.TOP)
            self:setRect(cx,cy,w,self._contextMenuComponent:getHeight())
           
            self._contextMenuComponent:fitToFrame(0,0,0,0)
            self:getNativeFrame():SetLayerLevel(120)
            self:getNativeFrame():ShowWindow(1)
            self:getNativeFrame():SetSkinName("None")
            self:focus()
            self._contextMenuComponent:updateCursorPos()
        end,
        releaseImpl=function(self)
            if self._contextMenuComponent then
                self._contextMenuComponent:release()
                self._contextMenuComponent=nil
            end

        end,
        onFocusedImpl=function(self)
            self._contextMenuComponent:focus()
        end,

    }

    local object=g.inherit(self,
    g.classes.JSNCustomFrame(jsnmanager,"jsncomponents"),
    g.classes.JSNGenericEventHandler(jsnmanager,eventHandler),
    g.classes.JSNOwnerRelation(owner), 
    g.classes.JSNPlayerControlDisabler(jsnmanager),
    g.classes.JSNFocusable(jsnmanager,self))
    
    return object
end