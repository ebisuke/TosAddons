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
g.classes.JSNComponent=function(frame)

    local self={
        _frame=frame,
        _interfaces={},
        getFrame=function(self)
            return self._frame
        end,
        getInterfaces=function(self)
            return self._interfaces
        end,
        addInterface=function(self,interface)
            self._interfaces[#self._interfaces]=interface
        end,
        
    }

    local object=setmetatable(self,{__index=setmetatable(g.classes.JSNHandlerKey(),{__index=g.classes.JSNObject()})})
   
    return object
end