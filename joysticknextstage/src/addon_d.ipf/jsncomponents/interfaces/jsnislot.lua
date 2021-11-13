--jsnslotset.lua
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
g.classes.JSNISlotBase=function(nativeParentControl)

    local self={
        _className="JSNISlotBase",
        _slot=nil,
        _slotSize={w=64,h=64},
        initImpl=function(self)
        
        end,

    }

    local object=g.inherit(self,g.classes.JSNInterface(nativeParentControl))
    return object
end
g.classes.JSNISlotInSlotSet=function(jsniSlotSet,index)

    local self={
        _className="JSNISlotInSlotSet",
        _jsniSlotSet=jsniSlotSet,
        _index=index,
        getNativeSlot=function(self)
            if(self._jsniSlotSet:getNativeSlotByIndex(self._index)==nil)then
                return nil
            end
            return g.classes.JSNNativeExtender(self._jsniSlotSet:getNativeSlotByIndex(self._index)):init()
        end,
        isValid=function(self)
            if(self._jsniSlotSet:getNativeSlotByIndex(self._index)==nil)then
                return false
            end
            return true
        end,
        initImpl=function(self)
        end
    }

    local object=g.inherit(self,g.classes.JSNISlotBase(jsniSlotSet:getNativeSlotSet()))
    
    return object
end
--standalone
g.classes.JSNIStandaloneSlot=function(nativeParentControl)
    local self={
        _className="JSNIStandaloneSlot",
        _nativeSlot=nil,
        initImpl=function(self)
            self._nativeSlot=self:createorGetNativeControl('slot','slot')
            self._nativeSlot:SetSkinName("invenslot2")
        end,
    }
    local object=g.inherit(self,g.classes.JSNISlotBase(nativeParentControl))
    
    return object
end
