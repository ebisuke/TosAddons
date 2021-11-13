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
        _className="JSNCustomFrame",
        _templateFrameName=templateFrameName,
        getTemplateFrameName=function(self)
            return self._templateFrameName
        end,
        initImpl=function(self)
            local frame=ui.CreateNewFrame(self:getTemplateFrameName(),"jsncustom_"..self:getID())
            frame:ShowWindow(1)
            self._nativeFrame=frame
        end,
        onKeyDownImpl=function(self,key)
            print("iml")
            if key==g.classes.JSNKey.CLOSE then
                print('close')
                self:release()
            end
        end,
        releaseImpl=function(self)
            if(self._nativeFrame)then
                self._nativeFrame:ShowWindow(0)
                ui.DestroyFrame(self._nativeFrame:GetName())
                self._nativeFrame=nil
            end
        end,
        setTitle=function(self,title)
            local frame=self:getNativeFrame()
            local titleText=frame:GetChild("title")
            titleText:SetText("{@st42}{s20}"..title)
        end,
    }


    local object=g.inherit(self,g.classes.JSNFrameBase(jsnmanager),g.classes.JSNFocusable(jsnmanager))


    
    return object
end