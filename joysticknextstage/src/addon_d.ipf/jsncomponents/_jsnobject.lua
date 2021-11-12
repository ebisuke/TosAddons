--jsnobject.lua
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

g.instanceOf=function(subject,super)

    super = tostring(super)
    local mt = getmetatable(subject)

    while true do
        if mt == nil then return false end
        if tostring(mt) == super then return true end

        mt = getmetatable(mt)
    end	

end
local function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end
g.inherit=function(obj,...)
    local chain={...}
    local object=obj
    object._hierarchy= object._hierarchy or {}

    for _,super in pairs(chain) do

        object=setmetatable(object,{__index=super})
        object._hierarchy[#object._hierarchy+1]={
            super=super
        }
    end

    return object
end
g.classes=g.classes or {}
g.classes.JSNObject=function()

    local self={
      
        _id=""..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999),
        init=function(self)
            --don't be confused with the initialize function of the class
            --don't call in the constructor
            --don't inherit this function
            self._hierarchy[#self._hierarchy+1]={
                super=self
            }
        
            for i,v in ipairs(self._hierarchy) do
     
                v.super.initImpl(self)
            end
            self:initImpl()
            return self
        end,
        release=function(self)
            --don't be confused with the initialize function of the class
            --don't call in the constructor
            --don't inherit this function
            local called={}
            local reversed=ReverseTable(self._hierarchy)
            self:releaseImpl(self)
            for i,v in ipairs(reversed) do
                     v.super.releaseImpl(self)
               
            end

            return self
        end,
        initImpl=function(self)
            --override me
        end,
        releaseImpl=function(self)
            --override me
        end,
        
        getID=function(self)
            return self._id
        end,
        isInstanceOf=function (self,super)
            g.instanceOf(self,super)
        end,
    }

    return self
end

g.classes.JSNHandlerEveryTick=function()

    local self={
        
        onEveryTick=function (self)
            --please override
        end,
        initImpl=function (self)
            g.jsnmanager.registerTickListener(self)   
        end,
        releaseImpl=function(self)
            g.jsnmanager.unregisterTickListener(self)
        end
    }
    local object=g.inherit(self,g.classes.JSNObject())


    return object

end
g.classes.JSNFocusable=function(disableFocus)

    local self={
        _focused=false,
        _disableFocus=disableFocus,
        focus=function (self)
            if(not self._disableFocus)then
                return
            end
            self._focused=true
            if(self:isInstanceOf(g.classes.JSNContainer))then
                for i,v in ipairs(self:getChildren())do
                    if(v~=self and v:isInstanceOf(g.classes.JSNFocusable))then
                        --remove siblings focus
                        v:unfocus()
                    end
                end
            end
            self:onFocused()
        end,
        setDisableFocus=function (self,disableFocus)
            self._disableFocus=disableFocus
        end,
        onFocused=function (self)
            --please override
        end,
        unfocus=function (self)
            self._focused=false
            self:onUnfocused()
        end,
        onUnfocused=function (self)
            --please override
        end,
    }
    local object=g.inherit(self,g.classes.JSNObject())


    return object

end
g.classes.JSNKey={
    NONE=0,
    JOY_UP=JOY_UP,
    JOY_DOWN=JOY_DOWN,
    JOY_LEFT=JOY_LEFT,
    JOY_RIGHT=JOY_RIGHT,
    JOY_BTN_1=JOY_BTN_1,
    JOY_BTN_2=JOY_BTN_2,
    JOY_BTN_3=JOY_BTN_3,
    JOY_BTN_4=JOY_BTN_4,
    JOY_BTN_5=JOY_BTN_5,
    JOY_BTN_6=JOY_BTN_6,
    JOY_BTN_7=JOY_BTN_7,
    JOY_BTN_8=JOY_BTN_8,
    JOY_L1L2=JOY_L1L2,
    JOY_R1R2=JOY_R1R2,
}
g.classes.JSNHandlerKey=function()

    local self={
        getKeyState=function (self,key)
            if(joystick.IsKeyPressed(key))then
                return true
            else
                return false
            end
        end,
        onKeyDown=function (self,key)
            --please override
        end,
        onKeyRepeat=function (self,key)
            --please override
        end,
        releaseImpl=function(self)
            g.jsnmanager.unregisterKeyListener(self)
        end
    }
    local object=g.inherit(self,g.classes.JSNObject())

    return object
end
g.classes.JSNManagerLinker=function(jsnmanager)

    local self={
        _jsnmanager=jsnmanager,
        getJSNManager=function (self)
            return self._jsnmanager
        end,
    }
    local object=g.inherit(self,g.classes.JSNObject())

    return object
end