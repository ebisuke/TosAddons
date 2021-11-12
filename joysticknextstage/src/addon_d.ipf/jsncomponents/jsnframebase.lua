--jsnframebase.lua
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
g.classes.JSNFrameBase=function(jsnmanager)
    local self={
        _jsnWrapperFrame=nil,
        getJSNWrapperFrame=function (self)
            return self._jsnWrapperFrame
        end,
        getNativeFrame=function (self)
            --duck typing
            return self._jsnWrapperFrame
        end,

        releaseImpl=function (self)
            if self._jsnWrapperFrame~=nil then
                ui.DestroyFrame(self._jsnWrapperFrame:GetName())
                self._jsnWrapperFrame=nil
            end
        end,
        setRect=function (self,x,y,w,h)
            self:getJSNSideFrame():SetOffset(x,y)
            self:getJSNSideFrame():Resize(w,h)
        end,
        initImpl=function (self)
            self._jsnWrapperFrame=ui.CreateNewFrame('jsncomponents','jsnsideframe-'..self:getID())
        end,
 
    
    }

    local object=g.inherit(self,g.classes.JSNContainer(),g.classes.JSNManagerLinker(jsnmanager))

 
    return object

end