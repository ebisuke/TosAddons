--jsncursor.lua
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
g.classes.JSNCursor=function(frame)
    local self={

        initialize=function (self)
            --please override
            local frame=self:getJSNSideFrame()
            frame:SetSkinName("slot")
            self:setRect(20,20,32,32)
        end,
        finalize=function (self)
            --please override
        end,
        onEveryTick=function (self)
            --please override
        end,
    }

    local object=g.inherit(g.inherit(self,g.classes.JSNHandlerEveryTick()),g.classes.JSNHandlerKey())
  
    return object

end