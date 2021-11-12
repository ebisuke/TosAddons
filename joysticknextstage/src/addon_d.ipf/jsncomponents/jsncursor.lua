--jsncursor.lua
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
local function CalcPos(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame("worldmap2_mainmap")
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (ow/sw), y * ( oh/sh)
end


g.classes=g.classes or {}
g.classes.JSNCursor=function()
    local self={
        _rect=nil,
        initImpl=function (self)
            --please override
            local frame=self:getJSNSideFrame()
            frame:SetSkinName("None")
            frame:ShowWindow(1)
            local ctrl=frame:CreateOrGetControl("slot", "jsn_dummyslot", 0, 0, 32, 32)
            AUTO_CAST(ctrl)
            ctrl:EnableHitTest(0)
            ctrl:SetSkinName("invenslot_magic")
            self:setRect(0,0,32,32)
            ctrl:SetBlink(0.0, 0.5, "0xFFFFFFFF",1);
        end,

        onEveryTick=function (self)
            --please override
            local frame=self:getJSNSideFrame()
            if(self._rect==nil) then
                frame:ShowWindow(0)
            else
                frame:SetLayerLevel(100)
                self:setRect(x-frame:GetWidth()/2,y-frame:GetHeight()/2,frame:GetWidth(),frame:GetHeight())
                local ctrl=frame:GetChild( "jsn_dummyslot")
                AUTO_CAST(ctrl)
                ctrl:Resize(frame:GetWidth(),frame:GetHeight())
            end
        end,
        setSize=function (self,w,h)
            local frame=self:getJSNSideFrame()
            frame:Resize(w,h)
        end,
        reset=function ()
            self._rect=nil
        end,
        setRect=function (self,x,y,w,h)
            self._rect={x=x,y=y,w=w,h=h}
            
        end,
        setRectByControl=function (self,nativeControl)
            self:setRect(nativeControl:GetX(),nativeControl:GetY(),nativeControl:GetWidth(),nativeControl:GetHeight())
        end
    }

    local object=g.inherit(g.inherit(g.inherit(self,g.classes.JSNHandlerEveryTick()),g.classes.JSNHandlerKey()),g.classes.JSNFrameBase())
  
    return object

end