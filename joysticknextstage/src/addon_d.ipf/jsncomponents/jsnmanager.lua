--jsnmanager.lua
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
g.classes.JSNManager=function ()
    local self = {
        jsnframes={},
        registeredReplacer={},
        pressedKeys={},
        keyRepeatInterval=4,
        keyRepeatDelay=15,
        keyListeners={},
        tickListeners={},
        isInitialized=function (self)
            return self.cursor ~= nil
        end,
        initImpl=function (self)
            self.cursor=g.classes.JSNCursor():init()

        end,
        release=function (self)
            if(self.cursor~=nil)then
                self.cursor:release()
                self.cursor=nil
            end
        end,
        addFrame=function (self,frame)
            table.insert(self.jsnframes,frame)
            return frame
        end,
        processFrames=function (self)
            for i,v in pairs(self.registeredReplacer) do
                if ui.GetFrame(v.originalFrameName) ~= nil and ui.GetFrame:IsVisible()==1 then
                    local already=false;
                    for j,k in pairs(self.jsnframes) do
                        if k.originalFrameName == v.originalFrameName then
                            already=true
                            break
                        end
                    end
                    if(not already) then
                        self.jsnframes[#self.jsnframes+1] = v:createJSNFrame(ui.GetFrame(v.originalFrameName))
                    end
                end
            end
    
            for i,v in pairs(self.jsnframes) do
                if v:getOriginalFrame() ~= nil and v:getOriginalFrame():IsVisible()==0 then
                else
                    --close frame
                    v:release()
                    table.remove(self.jsnframes,i)
                end
            end
        end,
        processJoystickKey=function(self)
            for i,v in pairs(g.classes.JSNKey) do
                if joystick.IsKeyPressed(v) == 1 then
                    self.pressedKeys[v] = (self.pressedKeys[v] or 0) + 1
                    if self.pressedKeys[v] == self.keyRepeatDelay then
                        self.pressedKeys[v] = 0
                        self.processKey(v)
                    end
                else
                    self.pressedKeys[v]=nil
                end
            
            end
        end,
        processTick=function(self)
            for i,v in pairs(self.tickListeners) do
                v:onEveryTick()
            end
        end,
        registerReplacers=function (self)
            local list={
               g.classes.JSNReplacer("inventory",g.classes.JSNInventoryFrame)
            }
    
            for i,v in ipairs(list) do
                self.registeredReplacer[self.registeredReplacer:getOriginalFrame()]=v
            end
        end,
        registerKeyListener=function (self,obj)
            self.keyListeners[#self.keyListeners+1]=obj
        end,
        unregisterKeyListener=function (self,obj)
            for i,v in pairs(self.keyListeners) do
                if v == obj then
                    table.remove(self.keyListeners,i)
                    break
                end
            end
        end,    
        registerTickListener=function (self,obj)
            self.tickListeners[#self.tickListeners+1]=obj
        end,
        unregisterTickListener=function (self,obj)
            for i,v in pairs(self.tickListeners) do
                if v == obj then
                    table.remove(self.tickListeners,i)
                    break
                end
            end
        end,   
    }

    local object=g.inherit(self,g.classes.JSNObject())
    return object
end

g.jsnmanager=g.classes.JSNManager():init()