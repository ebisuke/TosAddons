--jsncursor.lua
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
g.classes.JSNCursor = function(jsnmanager, linkedjsnframe)
    local self = {
        _className = "JSNCursor",
        _cursorRect = nil,
        _linkedjsnFrame = linkedjsnframe,
        _anchorObject = nil,
        initImpl = function(self)

            local frame = self:getNativeFrame()
            frame:SetSkinName("none")
            frame:ShowWindow(1)
            local ctrl = frame:CreateOrGetControl("slot", "jsn_dummyslot", 0, 0, 32, 32)
            AUTO_CAST(ctrl)
            ctrl:EnableHitTest(0)
            ctrl:RemoveAllChild()
            ctrl:SetSkinName("invenslot_magic")
            ctrl:SetBlink(0, 2, "0x44FFFFFF", 1)
        end,
        getLinkedJSNFrame = function(self)
            return self._linkedjsnFrame
        end,
        onEveryTickImpl = function(self)
            local frame = self:getNativeFrame()
            
            if (not self._linkedjsnFrame:hasFocus() or self._cursorRect == nil) then
                frame:ShowWindow(0)
            else
                local rect = self._cursorRect
                local offset = {x = 0, y = 0}
                if (self._anchorObject ~= nil) then
                    local obj = self._anchorObject
                    if(obj:instanceOf(g.classes.JSNFocusable())) then
                        if(not obj:hasFocus()) then
                            frame:ShowWindow(0)
                            
                            return
                        end
                    end
                    if obj:instanceOf(g.classes.JSNComponent()) then
                        local rect = obj:getRect()
                        local dframe = obj:getJSNFrame():getNativeFrame()
                        if (not dframe or dframe:IsVisible() == 0 ) then
                            frame:ShowWindow(0)
                            self:clear()
                            return
                        end
                        local gbox=obj:getWrapperNativeControl()
                        local x, y  = rect.x + dframe:GetX(), rect.y + dframe:GetY() - gbox:GetScrollCurPos()
                        offset = {x = x, y = y}
                    elseif obj:instanceOf(g.classes.JSNFrameBase()) then
                        --not show cursor to  frame
                        local dframe = obj:getNativeFrame()
                        if (not dframe or dframe:IsVisible() == 0  ) then
                            frame:ShowWindow(0)
                            self:clear()
                            return
                        end
                        local x, y= rect.x + dframe:GetX(), rect.y + dframe:GetY() - dframe:GetScrollCurPos()
                        offset = {x = x, y = y}
                    else
                        self:clear()
                        error("Focused to invalid object. [" .. (obj._className) .. "]")
                    end
                end
                local link = self:getLinkedJSNFrame()
                frame:SetLayerLevel(link:getNativeFrame():GetLayerLevel() + 1)
                frame:SetOffset(offset.x + rect.x, offset.y + rect.y)
                frame:Resize(rect.w, rect.h)
                local ctrl = frame:GetChild("jsn_dummyslot")
                AUTO_CAST(ctrl)
                ctrl:Resize(frame:GetWidth(), frame:GetHeight())
                frame:ShowWindow(1)
                
            end
        end,
        setCursorRect = function(self, x, y, w, h)
            self._cursorRect = {x = x, y = y, w = w, h = h}
        end,
        setAnchor = function(self, obj)
            self._anchorObject = obj
        end,
        clear = function(self)
            self._cursorRect = nil
            self._anchorObject = nil
        end
    }

    local object =
        g.inherit(
        self,
        g.classes.JSNCustomFrame(jsnmanager, "jsncomponents"),
        g.classes.JSNEveryTickHandler(jsnmanager),
        g.classes.JSNManagerLinker(jsnmanager)
    )

    return object
end
