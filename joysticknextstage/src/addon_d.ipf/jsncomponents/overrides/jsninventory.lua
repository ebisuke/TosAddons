--jsninventory.lua
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
g.classes.JSNInventoryComponent=function(jsnmanager,jsnframe)

    local self={

        initImpl=function(self)
            self:init()

            local gbox=self:getJSNWrapperGroupBox()
            local slotset=gbox:CreateOrGetControl('slotset','inventory',0,0,0,0)
            AUTO_CAST(slotset)
            slotset:SetSkinName('inventory_slot')
            self:relayout()
        end,
        relayout=function (self)
            local gbox=self:getJSNWrapperGroupBox()
            local slotset=gbox:GetChild('inventory')
            slotset:SetGravity(ui.LEFT,ui.TOP)
            slotset:SetOffset(0,0)
            slotset:Resize(self:getRect().w,self:getRect().h)
        end,
        onResize=function(self)
            
        end,
    }

    local object=g.inherit(self,g.classes.JSNComponent(jsnmanager,jsnframe))
    
    return object
end

g.classes.JSNInventoryFrame=function(jsnmanager)

    local self={

        initImpl=function(self)
            self:init()

            local gbox=self:getJSNWrapperGroupBox()
            local slotset=gbox:CreateOrGetControl('slotset','inventory',0,0,0,0)
            AUTO_CAST(slotset)
            slotset:SetSkinName('inventory_slot')
            self:relayout()
        end,
        relayout=function (self)
            local gbox=self:getJSNWrapperGroupBox()
            local slotset=gbox:GetChild('inventory')
            slotset:SetGravity(ui.LEFT,ui.TOP)
            slotset:SetOffset(0,0)
            slotset:Resize(self:getRect().w,self:getRect().h)
        end,
        onResize=function(self)
            
        end,
    }

    local object=g.inherit(self,g.classes.JSNCustomFrame(jsnmanager,"jsnframe"))
    
    return object
end