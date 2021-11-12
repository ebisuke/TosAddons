--jsninterface.lua
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
g.classes.JSNInterface=function(parent)

    local self={
        _nativeObjects={},
        getNativeObject=function(self)
            return self._nativeObjects
        end,
        addNativeObject=function(self,nativeObject)
            self._nativeObjects[#self._nativeObjects+1]=nativeObject
        end,
        removeNativeObject=function(self,nativeObject)
            for i,v in ipairs(self._nativeObjects) do
                if v==nativeObject then
                    table.remove(self._nativeObjects,i)
                    break
                end
            end
        end,
        removeNativeObjectByName=function(self,name)
            for i,v in ipairs(self._nativeObjects) do
                if v:GetName()==name then
                    table.remove(self._nativeObjects,i)
                    break
                end
            end
        end,
        clearNativeObjects=function(self)
            self._nativeObjects={}
        end,
        
    }

    local object=setmetatable(self,{__index=g.classes.JSNObject()})
    return object
end