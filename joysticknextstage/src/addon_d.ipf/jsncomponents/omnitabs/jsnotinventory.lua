--jsnotinventory.lua
--アドオン名（大文字）
local addonName = "jsn_commonlib"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"
--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")

g.classes = g.classes or {}
g.classes.JSNOmniTabInventory = function(jsnmanager, omniscreen)
    local self = {
        _className = "JSNOmniTabInventory",
        _inventory = nil,
        lazyInitImpl = function(self)
            self:fitToFrame(30, 200, 30, 50)
            self._inventory =
                g.classes.JSNInventoryComponent(jsnmanager, omniscreen, self, nil, nil, g.fn.GenerateMenuByItem):init()
            self._inventory:fitToParent(0, 0, 0, 0)
            self._inventory:autoSelectColumnCount()
            self._inventory:refresh()
        end,
        onFocusedImpl = function(self)
            self._inventory:focus()
            self._inventory:refresh()
        end,
        getTitle=function(self)
            return "Inventory"
        end,
    }
    local obj =
        g.inherit(
        self,
        g.classes.JSNComponent(jsnmanager, omniscreen),
        g.classes.JSNKeyHandler(jsnmanager),
        g.classes.JSNOwnerRelation(),
        g.classes.JSNFocusable(jsnmanager, self)
    )
    return obj
end
