--jsninventory.lua
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
g.classes.JSNCommonSlotSetComponent=function(jsnmanager,jsnframe)

    local self={
        _slotsetInterface=nil,
        getSlotSetInterface=function(self)
            return self._slotsetInterface
        end,
        initImpl=function(self)
            self._slotsetInterface=self:addInterface(g.classes.JSNISlotset(self:getJSNWrapperControl()):init())
            self:relayout()
        end,
        relayoutImpl=function (self)
            self._slotsetInterface:setClippingRect(self:getRect())
        end,
        onResizeImpl=function(self)
            self:relayout()
        end,
    }

    local object=g.inherit(self,g.classes.JSNComponent(jsnmanager,jsnframe))
    
    return object
end
