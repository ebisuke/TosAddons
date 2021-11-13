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
   
        getNativeFrame=function (self)
            return self._nativeFrame
        end,
        setRect=function (self,x,y,w,h)
            self:getNativeFrame():SetOffset(x,y)
            self:getNativeFrame():Resize(w,h)
        end,
        getHeight=function(self)
            return self:getNativeFrame():GetHeight()
        end,
        getWidth=function(self)
            return self:getNativeFrame():GetWidth()
        end,
       
        releaseImpl=function(self)

        end,

    }

    local object=g.inherit(self,g.classes.JSNHandlerKey(jsnmanager), g.classes.JSNParentChildRelation(),g.classes.JSNManagerLinker(jsnmanager))

 
    return object

end