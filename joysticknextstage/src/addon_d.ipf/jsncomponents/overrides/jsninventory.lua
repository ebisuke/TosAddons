--jsninventory.lua
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
g.classes.JSNInventoryComponent=function(jsnmanager,jsnframe)

    local self={
        initImpl=function(self)
        end,
        refreshImpl=function(self)
            session.BuildInvItemSortedList();
            local sortedList = session.GetInvItemSortedList();
            local invItemCount = sortedList:size();
            --sortedList:at(i);
            local slotset=self:getSlotSetInterface()
            local itergen=function(inv)
                local i=-1
                return function()
                    i=i+1
                    if i<=invItemCount then
                        return inv:at(i-1)
                    end
                end
            end
            slotset:assign(itergen(sortedList),function(v,slot)
                INV_ICON_SETINFO(slot:GetTopParentFrame(),slot,v)
            end)
        end,
    }

    local object=g.inherit(self,g.classes.JSNCommonSlotSetComponent(jsnmanager,jsnframe))
    return object
end

g.classes.JSNInventoryFrame=function(jsnmanager)

    local self={
        _inventoryComponent=nil,
        initImpl=function(self)
            self._inventoryComponent=g.classes.JSNInventoryComponent(jsnmanager,self):init()
            self._inventoryComponent:setRect(0,0,300,300)
        end,
    }

    local object=g.inherit(self,g.classes.JSNCustomFrame(jsnmanager,"jsnframe"))
    
    return object
end