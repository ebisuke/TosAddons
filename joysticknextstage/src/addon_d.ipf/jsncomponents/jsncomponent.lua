--jsncomponent.lua
--アドオン名（大文字）
local addonName = "joysticknextstage"
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
        _jsnFrame=jsnframe,
        _jsnWrapperGroupbox=nil,
        _rect={x=x,y=y,w=w,h=h},
        _gravityHorz=gravityhorz,
        _gravityVert=gravityvert,
        _interfaces={},
        getJSNWrapperControl=function(self)
            return self._jsnWrapperGroupbox
        end,
        getRect=function(self)
            return self._rect
        end,
        setRect=function(self,x,y,w,h)
            self._rect={x=x,y=y,w=w,h=h}
            self._jsnWrapperGroupbox:SetOffset(x,y)
            self._jsnWrapperGroupbox:Resize(w,h)
            self:onResize()
        end,
        getGravityHorz=function(self)
            return self._gravityHorz
        end,
        getGravityVert=function(self)
            return self._gravityVert
        end,
        setGravityHorz=function(self,gravityhorz)
            self._gravityHorz=gravityhorz
            self._jsnWrapperGroupbox:SetGravity(gravityhorz,self._gravityVert)
            self:onResize()
        end,
        setGravityVert=function(self,gravityvert)
            self._gravityVert=gravityvert
            self._jsnWrapperGroupbox:SetGravity(self._gravityHorz,gravityvert)
            self:onResize()
        end,
        getJSNFrame=function(self)
            return self._jsnframe
        end,
        getInterfaces=function(self)
            return self._interfaces
        end,
        addInterface=function(self,interface)
            self._interfaces[#self._interfaces]=interface
        end,
        onResize=function(self)
            -- please override
        end,
        initImpl=function(self)
            self._jsnWrapperGroupbox=self._jsnFrame:CreateOrGetControl("groupbox","jsngbox_"..self:getID(),self._rect.x,self._rect.y,self._rect.w,self._rect.h)
            AUTO_CAST(self._jsnWrapperGroupbox)
            self._jsnWrapperGroupbox:EnableHittestGroupBox(false)
            self._jsnWrapperGroupbox:SetGravity(self._gravityHorz,self._gravityVert)
        end,
    }

    local object=g.inherit(self,g.classes.JSNObject(),g.classes.JSNHandlerKey(),g.classes.JSNFocusable(),g.classes.JSNManagerLinker(jsnmanager))
   
    return object
end