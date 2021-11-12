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
g.classes.JSNFrame=function(frame)
    local self={
        _originalFrame=frame,
        getOriginalFrame=function(self)
            return self._originalFrame
        end,

    }


    local object=setmetatable(self,{__index=g.classes.JSNFrameBase()})


    object.getJSNSideFrame():SetOffset(object:getOriginalFrame():GetX(),object:getOriginalFrame():GetY())
    object.getJSNSideFrame():Resize(object:getOriginalFrame():GetWidth(),object:getOriginalFrame():GetHeight())
    return object
end