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
g.classes.JSNCustomFrame=function(jsnmanager,templateFrameName)
    local self={
        _templateFrameName=templateFrameName,
        _nativeFrame=nil,
        getTemplateFrameName=function(self)
            return self._templateFrameName
        end,
        getNativeFrame=function(self)
            return self._nativeFrame
        end,
        initImpl=function(self)
            local frame=ui.CreateNewFrame(templateFrameName,"jsncustom_"..self:getID())
            frame:ShowWindow(1)
            self._nativeFrame=frame
        end,
        releaseImpl=function(self)
            self._nativeFrame:ShowWindow(0)
            ui.DestroyFrame(self._nativeFrame:GetName())
            self._nativeFrame=nil
        end,
    }


    local object=g.inherit(self,g.classes.JSNContainer(),g.classes.JSNManagerLinker(jsnmanager),g.classes.JSNFocusable())


    
    return object
end