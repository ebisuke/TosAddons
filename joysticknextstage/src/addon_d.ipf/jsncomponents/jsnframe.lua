--jsnframe.lua
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
g.classes.JSNFrame=function(nativeframe)
    local self={
        _originalNativeFrame=nativeframe,
        getOriginalNativeFrame=function(self)
            return self._originalNativeFrame
        end,
        initImpl=function(self)
            self.getJSNWrapperFrame():SetOffset(self:getOriginalNativeFrame():GetX(),self:getOriginalNativeFrame():GetY())
            self.getJSNWrapperFrame():Resize(self:getOriginalNativeFrame():GetWidth(),self:getOriginalNativeFrame():GetHeight())
        end,
    }


    local object=g.inherit(g.inherit(self,g.classes.JSNFrameBase()),g.classes.JSNFocusable())


    
    return object
end