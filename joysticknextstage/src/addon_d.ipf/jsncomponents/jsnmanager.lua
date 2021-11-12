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

g.jsnmanager = {
    jsnframes={},
    currentFocus=nil,
    registeredReplacer={},
    pressedKeys={},
    keyRepeatInterval=4,
    keyRepeatDelay=15,
    keyListeners={},
    tickListeners={},
    processFrames=function ()
        for i,v in pairs(g.jsnmanager.registeredReplacer) do
            if ui.GetFrame(v.originalFrameName) ~= nil and ui.GetFrame:IsVisible()==1 then
                local already=false;
                for j,k in pairs(g.jsnmanager.jsnframes) do
                    if k.originalFrameName == v.originalFrameName then
                        already=true
                        break
                    end
                end
                if(not already) then
                    g.jsnmanager.jsnframes[#g.jsnmanager.jsnframes+1] = v:createJSNFrame(ui.GetFrame(v.originalFrameName))
                end
            end
        end

        for i,v in pairs(g.jsnmanager.jsnframes) do
            if v:getOriginalFrame() ~= nil and v:getOriginalFrame():IsVisible()==0 then
            else
                --close frame
                v:finalize()
                table.remove(g.jsnmanager.jsnframes,i)
            end
        end
    end,
    processJoystickKey=function()
        for i,v in pairs(g.classes.JSNKey) do
            if joystick.IsKeyPressed(v) == 1 then
                g.jsnmanager.pressedKeys[v] = (g.jsnmanager.pressedKeys[v] or 0) + 1
                if g.jsnmanager.pressedKeys[v] == g.jsnmanager.keyRepeatDelay then
                    g.jsnmanager.pressedKeys[v] = 0
                    g.jsnmanager.processKey(v)
                end
            else
                g.jsnmanager.pressedKeys[v]=nil
            end
        
        end
    end,
    processTick=function()
        for i,v in pairs(g.jsnmanager.tickListeners) do
            v:onEveryTick()
        end
    end,
    registerReplacers=function ()
        local list={
           g.classes.JSNReplacer("inventory",g.classes.JSNInventoryFrame)
        }

        for i,v in ipairs(list) do
            g.jsnmanager.registeredReplacer[g.jsnmanager.registeredReplacer:getOriginalFrame()]=v
        end
    end,
    registerKeyListener=function (obj)
        g.jsnmanager.keyListeners[#g.jsnmanager.keyListeners+1]=obj
    end,
    unregisterKeyListener=function (obj)
        for i,v in pairs(g.jsnmanager.keyListeners) do
            if v == obj then
                table.remove(g.jsnmanager.keyListeners,i)
                break
            end
        end
    end,    
    registerTickListener=function (obj)
        g.jsnmanager.tickListener[#g.jsnmanager.tickListener+1]=obj
    end,
    unregisterTickListener=function (obj)
        for i,v in pairs(g.jsnmanager.tickListener) do
            if v == obj then
                table.remove(g.jsnmanager.tickListener,i)
                break
            end
        end
    end,   
}
