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
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end


local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
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
                DBGOUT("getNativeSlotByIndex:"..self._index.." is nil")
                return nil
            end
            return g.classes.JSNNativeExtender(self._jsniSlotSet:getNativeSlotByIndex(self._index)):init()
        end,
        getGlobalX=function(self)
            local nativeSlot=self:getNativeSlot()
            if(nativeSlot==nil)then
                error("JSNISlotInSlotSet:getGlobalX() nativeSlot is nil")
            end
            return nativeSlot:GetGlobalX()
        end,
        getGlobalY=function(self)
            local nativeSlot=self:getNativeSlot()
            if(nativeSlot==nil)then
                error("JSNISlotInSlotSet:getGlobalY() nativeSlot is nil")
            end
            return nativeSlot:GetGlobalY()
        end,
        getX=function(self)
            local nativeSlot=self:getNativeSlot()
            if(nativeSlot==nil)then
                error("JSNISlotInSlotSet:getX() nativeSlot is nil")
            end
            return nativeSlot:GetX()
        end,
        getY=function(self)
            local nativeSlot=self:getNativeSlot()
            if(nativeSlot==nil)then
                error("JSNISlotInSlotSet:getY() nativeSlot is nil")
            end
            return nativeSlot:GetY()
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
