--jsnframebase.lua
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
g.classes.JSNFrameBase=function(frame)
    local self={
        _jsnSideFrame=nil,
        getJSNSideFrame=function (self)
            return self._jsnSideFrame
        end,
        initialize=function (self)
            --please override
        end,
        finalize=function (self)
            if self._jsnSideFrame~=nil then
                ui.DestroyFrame(self._jsnSideFrame:GetName())
                self._jsnSideFrame=nil
            end
        end,
        setRect=function (self,x,y,w,h)
            self:getJSNSideFrame():SetOffset(x,y)
            self:getJSNSideFrame():Resize(w,h)
        end,
    }

    local object=setmetatable(self,{__index=g.classes.JSNContainer()})

    object._jsnSideFrame=ui.CreateNewFrame('jsncomponent','jsnsideframe-'..object:getID())

    return object

end