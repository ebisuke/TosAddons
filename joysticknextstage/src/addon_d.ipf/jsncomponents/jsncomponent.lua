--jsncomponent.lua
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

g.classes.JSNComponent=function(jsnmanager,jsnframe,parent)

    local self={
        _className="JSNComponent",
        _jsnFrame=jsnframe,
        _wrapperGroupbox=nil,
        _rect={x= 0,y=0,w=0,h=0},
        _gravityHorz=ui.LEFT,
        _gravityVert=ui.TOP,
        _interfaces={},
        _margin={left=0,right=0,top=0,bottom=0},
        
        getJSNFrame=function(self)
            return self._jsnFrame
        end,
        getNativeFrame=function(self)
            --duck typing
            return self._wrapperGroupbox
        end,
        getWrapperNativeControl=function(self)
            return self._wrapperGroupbox
        end,
        getX=function(self)
            return self._rect.x
        end,
        getY=function(self)
            return self._rect.y
        end,
        getGlobalX=function(self)
            return self:getWrapperNativeControl():GetGlobalX()
        end,
        getGlobalY=function(self)
            return self:getWrapperNativeControl():GetGlobalY()
        end,
        getWidth=function(self)
            return self._rect.w
        end,
        getHeight=function(self)
            return self._rect.h
        end,
        setX=function(self,x)
            self._rect.x=x
            self:getWrapperNativeControl():SetX(x)
        end,
        setY=function(self,y)
            self._rect.y=y
            self:getWrapperNativeControl():SetY(y)
        end,
        setWidth=function(self,w)
            self._rect.w=w
            self:getWrapperNativeControl():Resize(w,self._rect.h)
        end,
        setHeight=function(self,h)
            self._rect.h=h
            self:getWrapperNativeControl():Resize(self._rect.w,h)
        end,
        setOffset=function(self,x,y)
            self:setRect(x,y,self._rect.w,self._rect.h)
        end,
        getRect=function(self)
            return self._rect
        end,
        setRect=function(self,x,y,w,h)
            self._rect={x=x,y=y,w=w,h=h}
            self:getWrapperNativeControl():SetOffset(x,y)
            self:getWrapperNativeControl():Resize(w,h)
            self:onResize()
        end,
        setLayerLevel=function(self,layer)
            error("Layerlevel can't be set in JSNComponent")
        end,
        getLayerLevel=function(self)
            --returns frame's layerlevel
            return self:getJSNFrame():getLayerLevel()
        end,
        fitToFrame=function (self,left,up,right,down)
            left=left or 0
            up=up or 0
            right=right or 0
            down=down or 0
            self:setGravityHorz(ui.LEFT)
            self:setGravityVert(ui.TOP)
            self:setRect(left,up,self:getJSNFrame():getWidth()-left-right,self:getJSNFrame():getHeight()-up-down)

        end,
        fitToParent=function (self,left,up,right,down)
            left=left or 0
            up=up or 0
            right=right or 0
            down=down or 0
            self:setGravityHorz(ui.LEFT)
            self:setGravityVert(ui.TOP)
            self:setRect(left,up,self:getParent():getWidth()-left-right,self:getParent():getHeight()-up-down)

        end,
        getGravityHorz=function(self)
            return self._gravityHorz
        end,
        getGravityVert=function(self)
            return self._gravityVert
        end,
        ensureScroll=function(self,y,margin)
            -- Y座標がエリアの中に入るようにする
            local gbox=self:getWrapperNativeControl()
          
            if(math.max(0,y-margin)<gbox:GetScrollCurPos()) then
                gbox:SetScrollPos(math.max(y-margin,0))

                gbox:InvalidateScrollBar()
            end
            if(math.min(gbox:GetScrollBarMaxPos()+gbox:GetHeight(),y+margin)>(gbox:GetScrollCurPos()+gbox:GetHeight())) then
                gbox:SetScrollPos(math.min(y+margin-gbox:GetHeight(),gbox:GetScrollBarMaxPos()))
                gbox:InvalidateScrollBar()

            end
            
        end,
        getScrollY=function(self)
            return self:getWrapperNativeControl():GetScrollCurPos()
        end,
        setMargin=function(self,l,t,r,b)
            self._margin={left=l,top=t,right=r,bottom=b}
            self:getWrapperNativeControl():SetMargin(l,t,r,b)
            self:onResize()
        end,
        setGravityHorz=function(self,gravityhorz)
            self._gravityHorz=gravityhorz
            self:getWrapperNativeControl():SetGravity(gravityhorz,self._gravityVert)
            self:onResize()
        end,
        setGravityVert=function(self,gravityvert)
            self._gravityVert=gravityvert
            self._wrapperGroupbox:SetGravity(self._gravityHorz,gravityvert)
            self:onResize()
        end,
        setGravity=function(self,gravityhorz,gravityvert)
            self._gravityHorz=gravityhorz
            self._gravityVert=gravityvert
            self:getWrapperNativeControl():SetGravity(gravityhorz,gravityvert)
            self:onResize()
        end,
        getInterfaces=function(self)
            return self._interfaces
        end,
        addInterface=function(self,interface)
            self._interfaces[#self._interfaces]=interface

            return interface
        end,
        setVisible=function(self,visible)
            if(visible)then
                self:getWrapperNativeControl():ShowWindow(1)
            else
                self:getWrapperNativeControl():ShowWindow(0)
            end
        
        end,
        isVisible=function(self)
            return self:getWrapperNativeControl():IsVisible()~=0
        end,
        onResize=function(self)
            self:onResizeImpl()
            -- 伝搬
            for i,v in ipairs(self._interfaces) do
                v:onResize()
            end
        end,
        onResizeImpl=function(self)
            -- please override
        end,
        refresh=function(self)
            self:refreshImpl()
        end,
        refreshImpl=function(self)
            -- please override
        end,
        relayout=function(self)
            self:relayoutImpl()
        end,
        relayoutImpl=function(self)
            -- please override
        end,
        initImpl=function(self)
            self._wrapperGroupbox=
            self:getParent():getNativeFrame():CreateOrGetControl("groupbox","jsngbox_"..self:getID(),
            self._rect.x,self._rect.y,self._rect.w,self._rect.h)
            AUTO_CAST(self:getWrapperNativeControl())
            self:getWrapperNativeControl():EnableHittestGroupBox(false)
            self:getWrapperNativeControl():SetGravity(self._gravityHorz,self._gravityVert)
          
        end,
      
        
        show=function(self)
            self:getWrapperNativeControl():ShowWindow(1)
        end,
        hide=function(self)
            self:getWrapperNativeControl():ShowWindow(0)
        end,
    }

    local object=g.inherit(self,
    g.classes.JSNManagerLinker(jsnmanager),
    g.classes.JSNParentChildRelation(parent or jsnframe),
    g.classes.JSNOwnerRelation())
   
    return object
end