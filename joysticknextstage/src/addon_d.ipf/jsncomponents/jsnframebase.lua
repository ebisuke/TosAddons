--jsnframebase.lua
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
g.classes.JSNFrameBase=function(jsnmanager)
    local self={
        _className="JSNFrameBase",
        _nativeFrame=nil,
        setNativeFrame=function(self,nativeFrame)
            self._nativeFrame=nativeFrame
          
        end,
        setGravity=function(self,horz,vert)
            self:getNativeFrame():SetGravity(horz,vert)
        end,
        getNativeFrame=function (self)
            return self._nativeFrame
        end,
        setRect=function (self,x,y,w,h)
            self:getNativeFrame():SetOffset(x,y)
            self:getNativeFrame():Resize(w,h)
        end,
        resize=function (self,w,h)
            self:getNativeFrame():Resize(w,h)
        end,
        getHeight=function(self)
            return self:getNativeFrame():GetHeight()
        end,
        getWidth=function(self)
            return self:getNativeFrame():GetWidth()
        end,
        getX=function(self)
            return self:getNativeFrame():GetX()
        end,
        getY=function(self)
            return self:getNativeFrame():GetY()
        end,
        getGlobalX=function(self)
            return self:getNativeFrame():GetGlobalX()
        end,
        getGlobalY=function(self)
            return self:getNativeFrame():GetGlobalY()
        end,
       

    }

    local object=g.inherit(self,g.classes.JSNKeyHandler(jsnmanager), g.classes.JSNParentChildRelation(),g.classes.JSNManagerLinker(jsnmanager))

 
    return object

end