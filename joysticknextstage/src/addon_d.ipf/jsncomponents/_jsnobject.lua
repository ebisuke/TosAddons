--jsnobject.lua
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

g.instanceOf=function(subject,super)

    super = tostring(super)
    local mt = getmetatable(subject)

    while true do
        if mt == nil then return false end
        if tostring(mt) == super then return true end

        mt = getmetatable(mt)
    end	

end
g.inherit=function(obj,super)
    setmetatable(obj,{__index=super})
end
g.classes=g.classes or {}
g.classes.JSNObject=function(rect)

    local self={
        _id=""..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999).."-"..IMCRandom(1,99999999),
        _rect={
            x=0,
            y=0,
            w=0,
            h=0,
        },
        _name="",
        getID=function(self)
            return self._id
        end,
        setName=function(self,name)
            self._name=name
        end,
        getName=function(self)
            return self._name
        end,
        setRect=function(self,x,y,w,h)
            self._rect.x=x
            self._rect.y=y
            self._rect.w=w
            self._rect.h=h
        end,
        getRect=function(self)
            return self._rect
        end,
        isInstanceOf=function (self,super)
            g.instanceOf(self,super)
        end,
    }
    self:setRect(rect.x,rect.y,rect.w,rect.h);

    return self
end
g.classes.JSNDisposable=function()
    local self={
        dispose=function(self)
            --please override
        end
    }
    return self
end
g.classes.JSNHandlerEveryTick=function()

    local self={
        
        onEveryTick=function (self)
            --please override
        end,
        dispose=function(self)
            g.jsnmanager.unregisterTickListener(self)
        end
    }
    local object=g.inherit(self,g.classes.JSNDisposable())
    g.jsnmanager.registerTickListener(object)
    return self

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
        dispose=function(self)
            g.jsnmanager.unregisterKeyListener(self)
        end
    }
    local object=setmetatable(self,{__index=g.classes.JSNDisposable()})
    g.jsnmanager.registerKeyListener(object)
    return self
end