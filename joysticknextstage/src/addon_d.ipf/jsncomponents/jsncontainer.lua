--jsncontainer.lua
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
g.classes.JSNContainer=function()

    local self={
        _children={},
        getChildren=function(self)
            return self._children
        end,
        findChildByID=function(self,id)
            for i,v in ipairs(self._children) do
                if v:getID()==id then
                    return v
                end
            end
            return nil
        end,
        addChild=function(self,child)
            table.insert(self._children,child)
        end,
        removeChild=function(self,child)
            for i,v in ipairs(self._children) do
                if v==child then
                    table.remove(self._children,i)
                    break
                end
            end
        end,
        removeChildByID=function(self,id)
            for i,v in ipairs(self._children) do
                if v.id==id then
                    table.remove(self._children,i)
                    break
                end
            end
        end,
        getChildByID=function(self,id)
            for i,v in ipairs(self._children) do
                if v:getID()==id then
                    return v
                end
            end
            return nil
        end,
    }

    local object=g.inherit(self,g.classes.JSNObject())
    return object
end