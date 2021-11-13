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
            self:setNativeFrame(frame)
            --print("INIT:"..self:getNativeFrame():GetName())
        end,
        onKeyDownImpl=function(self,key)

            
        end,
        releaseImpl=function(self)
            if(self:getNativeFrame())then
                --print("RELEASE"..self:getNativeFrame():GetName())
                self:getNativeFrame():ShowWindow(0)
                ui.DestroyFrame(self:getNativeFrame():GetName())
                self:setNativeFrame(nil)
            end
        end,
        setTitle=function(self,title)
            local frame=self:getNativeFrame()
            local titleText=frame:GetChildRecursively("title")
            titleText:SetText("{@st42}{s20}"..title)
        end,
    }


    local object=g.inherit(self,g.classes.JSNFrameBase(jsnmanager))


    
    return object
end