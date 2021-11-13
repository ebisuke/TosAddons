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
g.classes.JSNComponent=function(jsnmanager,jsnframe,x,y,w,h,gravityhorz,gravityvert)

    local self={
        _className="JSNComponent",
        _jsnFrame=jsnframe,
        _wrapperGroupbox=nil,
        _rect={x=x or 0,y=y or 0,w=w or 0,h=h or 0},
        _gravityHorz=gravityhorz or ui.LEFT,
        _gravityVert=gravityvert or ui.TOP,
        _interfaces={},
        _margin={left=0,right=0,top=0,bottom=0},
        getJSNFrame=function(self)
            return self._jsnFrame
        end,
        getWrapperNativeControl=function(self)
            return self._wrapperGroupbox
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
        fitToFrame=function (self,left,up,right,down)
            left=left or 0
            up=up or 0
            right=right or 0
            down=down or 0
            self:setGravityHorz(ui.LEFT)
            self:setGravityVert(ui.TOP)
            self:setRect(left,up,self:getJSNFrame():getWidth()-left-right,self:getJSNFrame():getHeight()-up-down)

        end,
        getGravityHorz=function(self)
            return self._gravityHorz
        end,
        getGravityVert=function(self)
            return self._gravityVert
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
        getInterfaces=function(self)
            return self._interfaces
        end,
        addInterface=function(self,interface)
            self._interfaces[#self._interfaces]=interface

            return interface
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
            self:getJSNFrame():getNativeFrame():CreateOrGetControl("groupbox","jsngbox_"..self:getID(),
            self._rect.x,self._rect.y,self._rect.w,self._rect.h)
            AUTO_CAST(self:getWrapperNativeControl())
            self:getWrapperNativeControl():EnableHittestGroupBox(false)
            self:getWrapperNativeControl():SetGravity(self._gravityHorz,self._gravityVert)
          
        end,
    }

    local object=g.inherit(self,g.classes.JSNManagerLinker(jsnmanager),g.classes.JSNParentChildRelation(jsnframe))
   
    return object
end