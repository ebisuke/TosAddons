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
g.classes.JSNReplacer=function(originalNativeFrameName,newJSNFrameConstructor)

    local self={
        _originalNativeFrameName=originalNativeFrameName,
        _newJSNFrameConstructor=newJSNFrameConstructor,
        isCreatedOriginalFrame=function(self)
            return ui.GetFrame(self._originalNativeFrameName)~=nil
        end,
        createJSNFrame=function(self,nativeFrame)
            local frame=self._newJSNFrameConstructor(nativeFrame)
            return frame:init()
        end
    }

    local object=g.inherit(self,g.classes.JSNObject())
    return object
end