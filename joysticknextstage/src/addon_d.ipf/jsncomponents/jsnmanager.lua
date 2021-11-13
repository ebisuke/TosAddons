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
        _className="JSNManager",
        jsnframes={},
        registeredReplacer={},
        pressedKeys={},
        keyRepeatInterval=3,
        keyRepeatDelay=13,
        keyListeners={},
        tickListeners={},
        _controlRestrictionCounter=0,
        activeFrame=nil,
        isInitialized=function (self)
            return self.cursor ~= nil
        end,
        initImpl=function (self)
            self:release()
          
        end,
        releaseImpl=function (self)
          
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
         
            for k,v in pairs(g.classes.JSNKey) do
                
                local rawkeys=g.jsnKeyInterpretation[v]
                if(rawkeys)then
                    local pass=true
                    local count=0
                   
                    for kk,vv in pairs(rawkeys) do
                  
                        local expect=vv
                        if expect then
                            expect=1
                        else
                            expect=0
                        end
                        if (joystick.IsKeyPressed(kk) ~= expect) then
                            pass=false
                            
                        else
                            count=count+1
                        end
                        
                    end
                    if(pass) and count>0 then
                        self.pressedKeys[k] = (self.pressedKeys[k] or -1) + 1
                        if self.pressedKeys[k] ==0 or self.pressedKeys[k] >= self.keyRepeatDelay then
                            local repeatValue=self.pressedKeys[k] - self.keyRepeatDelay
                            if(self.pressedKeys[k] ==0 or repeatValue%self.keyRepeatInterval==0)then
                                
                                if(self.pressedKeys[k] ==0)then
                                 
                                    for _,vvv in pairs(self.keyListeners) do
                                        if(vvv:canHandleKeyDirectly())then
                                            vvv:onKeyDown(v)
                                        end
                                    end
                                end
                                for _,vvv in pairs(self.keyListeners) do
                                    if(vvv:canHandleKeyDirectly())then
                                        vvv:onKeyRepeat(v)
                                    end
                                end
                                
                            end
                            
                        end
     
                    else
                        self.pressedKeys[k]=nil
                    end
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

           
            self.keyListeners[obj:getID()]=obj
        end,
        unregisterKeyListener=function (self,obj)

            self.keyListeners[obj:getID()]=nil
        end,    
        registerTickListener=function (self,obj)
            
            self.tickListeners[obj:getID()]=obj
        end,
        unregisterTickListener=function (self,obj)
            self.tickListeners[obj:getID()]=nil
        end,
        incrementControlRestrictionCounter=function (self)
            if(self._controlRestrictionCounter==0)then
                control.EnableControl(0,0)
            end
            self._controlRestrictionCounter=self._controlRestrictionCounter+1
        end,
        decrementControlRestrictionCounter=function (self)
            if(self._controlRestrictionCounter==1)then
                control.EnableControl(1,1)
            end
            self._controlRestrictionCounter=self._controlRestrictionCounter-1
        end,
    }

    local object=g.inherit(self,g.classes.JSNObject())
    return object
end
