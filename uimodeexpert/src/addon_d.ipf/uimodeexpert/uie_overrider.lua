--uie_overrider

local acutil = require('acutil')

--ライブラリ読み込み
local debug=false
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (debug == true) then
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


local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

UIMODEEXPERT=UIMODEEXPERT or {}
local g=UIMODEEXPERT
g.over={
    uieOverriderBase={
        new = function(framename)
            local self = {}
            setmetatable(self, {__index = g.over.uieOverriderBase})
            self.framename=framename
            self.x=0
            self.y=0
            self.w=0
            self.h=0
            
            return self
        end,
        override=function(self)
            local frame=ui.GetFrame(self.framename)
            self.x=frame:GetX()
            self.y=frame:GetY()
            self.w=frame:GetWidth()
            self.h=frame:GetHeight()
            
            return 
        end,
        restore=function(self)
            local frame=ui.GetFrame(self.framename)
            
        end
    },
    uieCallbackedOverrider={
        new = function(framename,callbackonoverride,callbackonrestore)
            local self = inherit(g.over.uieCallbackedOverrider, g.over.uieOverriderBase, framename)
            self.framename=framename
            self.callbackonoverride=callbackonoverride
            self.callbackonrestore=callbackonrestore
      
            
            return self
        end,
        override=function(self)
            g.over.uieOverriderBase.override(self)
            if self.callbackonoverride then
                local e,ret = pcall(self.callbackonoverride,self)
                if not e or not ret then
                    -- no override
                else
                   
                    return ret
                    
                end
            else
                return
            end
        end,
        restore=function(self)
            g.over.uieOverriderBase.restore(self)
            if self.callbackonrestore then
                local e,ret =pcall(self.callbackonrestore,self)
                if not e or not ret then
                    -- no restore
                else
                    return ret
                end
            else
                
            end
        end
    },
    uieCallbackedOverriderDontCare={
        new = function(framename,callbackonoverride,callbackonrestore)
            local self = inherit(g.over.uieCallbackedOverriderDontCare, g.over.uieOverriderBase, framename)
            self.framename=framename
            self.callbackonoverride=callbackonoverride
            self.callbackonrestore=callbackonrestore
      
            
            return self
        end,
        override=function(self)

            if self.callbackonoverride then
                local e,ret = pcall(self.callbackonoverride,self)
                if not e or not ret then
                    -- no override
                else
                   
                    return ret
                    
                end
            else
                return
            end
        end,
        restore=function(self)

            if self.callbackonrestore then
                local e,ret =pcall(self.callbackonrestore,self)
                if not e or not ret then
                    -- no restore
                else
                    return ret
                end
            else
                
            end
        end
    }
}

UIMODEEXPERT=g;
