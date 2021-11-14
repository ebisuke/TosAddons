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
g.singleton=g.singleton or {}
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
        _overrides={},
        _globalKeyListener=nil,
        initImpl=function (self)
            self._globalKeyListener=g.classes.JSNGlobalKeyListener(self):init()
            self:_registerReplacers()
        end,
        releaseImpl=function (self)
            self._globalKeyListener:release()
        end,
  
        processFrames=function (self)
            for i,v in pairs(self.registeredReplacer) do
                local name=v:getOriginalNativeFrameName()
                if  name~=nil and 
                     ui.GetFrame(name) ~= nil and 
                     ui.GetFrame(name):IsVisible()==1 then
                    local already=false;
                    for j,k in pairs(self.jsnframes) do
                        if j == name then
                            already=true
                            break
                        end
                    end
                    if(not already )and (not self.jsnframes[ name]) then
                        local f,err=pcall(v.createOverrider,v,ui.GetFrame(name))
                        if(f) then
                            self.jsnframes[name]=err
                        else
                            self.jsnframes[name] =g.classes.JSNObject()
                            ERROUT("JSNManager:processFrames:createOverrider:"..err)
                        end
                       
                                           
                    end
                end
            end
    
            for i,v in pairs(self.jsnframes) do
                if  v:isReleased() then
                
                    --close frame

                    self.jsnframes[i]=nil
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
                                            if vvv:onKeyDown(v) then
                                                break
                                            end
                                        end
                                    end
                                end
                                for _,vvv in pairs(self.keyListeners) do
                                    if(vvv:canHandleKeyDirectly())then
                                        if vvv:onKeyRepeat(v) then
                                            break
                                        end
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
        _registerReplacers=function (self)
            local list={
               g.classes.JSNReplacer(self,"shop",g.classes.JSNShopOverrider):init()
            }
    
            for i,v in ipairs(list) do
                if(not v:instanceOf(g.classes.JSNReplacer()))then
                    error("JSNManager:_registerReplacers:registing replacer is not  replacer:"..v._className)
                end
                if(not v._overriderConstructor():instanceOf(g.classes.JSNOverriderBase()))then
                    error("JSNManager:_registerReplacers:registing jsnobject is not  overrider:"..v._overriderConstructor()._className)
                end
                
                self.registeredReplacer[v:getOriginalNativeFrameName()]=v
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
        temporallyEnableControlRestriction=function (self)
            if(self._controlRestrictionCounter>0)then
                control.EnableControl(1,1)
            end
            return {
                release=function ()
                    if(self._controlRestrictionCounter>0)then
                        control.EnableControl(0,1)
                    end
                end
            }
        end,
        incrementControlRestrictionCounter=function (self)
            if(self._controlRestrictionCounter==0)then
                control.EnableControl(0,1)
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
    if(g.singleton[self._className]~=nil)then
        return g.singleton[self._className]
    end
    local object=g.inherit(self,g.classes.JSNSingleton())
    return object
end
