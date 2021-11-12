--jsninterface.lua
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

g.classes.JSNNativeExtender=function(interface)
    local self={
       _interface=interface,
       getInterface=function(self)
           return self._interface
       end,
       fitToParent=function(self)
            local parent=self:GetParent()

            if(self:getInterface():getClippingRect())then
                local rect=self:getInterface():getClippingRect()
                self:SetGravity(ui.LEFT,ui.TOP)
                self:SetOffset(rect.x,rect.y)
                self:Resize(rect.w,rect.h)
            else
                local x,y=parent:GetX(),parent:GetY()
                local w,h=parent:GetWidth(),parent:GetHeight()
                self:SetGravity(ui.LEFT,ui.TOP)
                self:SetOffset(x,y)
                self:Resize(w,h)
            end
       end,
    }

    local object=g.inherit(self,g.classes.JSNObject())
    return object
end
g.classes.JSNInterface=function(nativeParentControl)

    local self={
        _nativeParentControl=nativeParentControl,
        _nativeControls={},
        _clippingRect=nil,
        setClippingRect=function(self,x,y,w,h)
            self._clippingRect={x=x,y=y,w=w,h=h}
        end,
        getClippingRect=function(self)
            return self._clippingRect
        end,
        getNativeParentControl=function(self)
            return self._nativeParentControl
        end,
        createorGetNativeControl=function(self,type,prefix)
            if(self._nativeControls[prefix]~=nil)then
                return self._nativeControls[prefix]
            end
            local nativeControl=self._nativeParentControl:CreateOrGetControl(type,prefix..self:getID(),0,0,0,0)
            AUTO_CAST(nativeControl)
            nativeControl=g.inherit(nativeControl,g.classes.JSNNativeExtender(self))
            self:registerNativeControl(nativeControl,prefix)
            return nativeControl
        end,
        getNativeControl=function(self,prefix)
            return self._nativeControls[prefix]
        end,
        registerNativeControl=function(self,nativeControl,prefix)
            self._nativeControls[prefix]=nativeControl
        end,
        releaseAllNativeControls=function(self)
            for k,v in pairs(self._nativeControls) do
                self._nativeParentControl:RemoveChild(k)
            end
     
            self._nativeControls={}
        end,
        onResize=function(self)
            self:onResizeImpl()
        end,
        onResizeImpl=function(self)
            -- please Override
        end,
        releaseImpl=function(self)
            self:releaseAllNativeControls()
        end,
    }

    local object=g.inherit(self,g.classes.JSNObject())
    return object
end