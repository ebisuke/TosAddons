--jsnreplacer.lua
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
g.classes.JSNReplacer=function(jsnmanager,originalNativeFrameName,overriderConstructor)

    local self={
        _className="JSNReplacer",
        _originalNativeFrameName=originalNativeFrameName,
        _overriderConstructor=overriderConstructor,
        isCreatedOriginalFrame=function(self)
            return ui.GetFrame(self._originalNativeFrameName)~=nil
        end,
        getOriginalNativeFrameName=function(self)
            return self._originalNativeFrameName
        end,
        getOriginalNativeFrame=function(self)
            return ui.GetFrame(self._originalNativeFrameName)
        end,
        createOverrider=function(self,nativeFrame)
            local frame=self._overriderConstructor(jsnmanager,nativeFrame)
            return frame:init()
        end
    }

    local object=g.inherit(self,g.classes.JSNManagerLinker(jsnmanager))
    return object
end