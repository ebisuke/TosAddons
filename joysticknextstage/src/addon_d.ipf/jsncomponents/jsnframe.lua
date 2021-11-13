--jsnframe.lua
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
g.classes.JSNFrame=function(jsnmanager,nativeOriginalFrame)
    local self={
        _className="JSNFrame",
        _originalNativeFrame=nativeOriginalFrame,
        getOriginalNativeFrame=function(self)
            return self._originalNativeFrame
        end,
        initImpl=function(self)
            self:setNativeFrame(ui.CreateNewFrame('jsncomponents','jsnsideframe-'..self:getID()))
            self.getOriginalNativeFrame():SetOffset(self:getOriginalNativeFrame():GetX(),self:getOriginalNativeFrame():GetY())
            self.getOriginalNativeFrame():Resize(self:getOriginalNativeFrame():GetWidth(),self:getOriginalNativeFrame():GetHeight())
        end,
        releaseImpl=function (self)
            if self._nativeFrame~=nil then
                ui.DestroyFrame(self._nativeFrame:GetName())
                self._nativeFrame=nil
            end
        end,
    }


    local object=g.inherit(self,g.classes.JSNFrameBase(jsnmanager))


    
    return object
end