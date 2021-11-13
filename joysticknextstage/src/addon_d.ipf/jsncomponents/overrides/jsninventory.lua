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
        _className="JSNInventoryComponent",
        initImpl=function(self)
            self:focus()
        end,
        refreshImpl=function(self)
          
            session.BuildInvItemSortedList();
            local sortedList = session.GetInvItemSortedList();
            local invItemCount = sortedList:size();
            --sortedList:at(i);
            local slotset=self:getSlotSetInterface()
            local itergen=function()
                local i=0
                return function()
                    i=i+1

                    if i<=invItemCount then
                        return sortedList:at(i-1)
                    end
                end
            end
      
            slotset:assign(itergen(),function(v,slot)
                INV_SLOT_UPDATE(ui.GetFrame("inventory"),v,slot)
            end)
        end,
    }

    local object=g.inherit(self, g.classes.JSNCommonSlotSetComponent(jsnmanager,jsnframe),g.classes.JSNFocusable(jsnmanager))
    return object
end

g.classes.JSNInventoryFrame=function(jsnmanager)

    local self={
        _className="JSNInventoryFrame",
        _inventoryComponent=nil,
        initImpl=function(self)
            self._inventoryComponent=g.classes.JSNInventoryComponent(self:getJSNManager(),self):init()
            self._inventoryComponent:fitToFrame(30,100,30,100)
            self._inventoryComponent:setColumnCount(math.floor(self._inventoryComponent:getRect().w/64))
            self._inventoryComponent:refresh()
            self:addChild(self._inventoryComponent)
        end,
        onFocusedImpl=function(self)
            self._inventoryComponent:focus()
            self._inventoryComponent:setCursorRect(0,0,128,128)
        end,
        onKeyDownImpl=function(self,key)
            self._supers["JSNCustomFrame"].onKeyDownImpl(self,key)
            self._inventoryComponent:onKeyDown(key)
        end,
    }

    local object=g.inherit(self,g.classes.JSNCustomFrame(jsnmanager,"jsnframe"),g.classes.JSNFocusable(jsnmanager))
    
    return object
end