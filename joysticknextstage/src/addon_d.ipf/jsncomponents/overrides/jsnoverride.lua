--jsnoverride.lua
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
g.classes.JSNOverriderBase=function (jsnmanager,overridenFrame)
    local self={
        _className="JSNOverrider",
        _originalFrame=overridenFrame,
        getOriginalNativeFrame=function (self)
            return self._originalFrame
        end,
        getOriginalNativeFrameName=function(self)
            return self._originalFrame:GetName()
        end,
        releaseImpl=function (self)
            if(self:getOriginalNativeFrame())then
                self:getOriginalNativeFrame():ShowWindow(0)
            end
          
        end,
    }
    local obj=g.inherit(self,g.classes.JSNManagerLinker(jsnmanager))
    return obj
end

g.classes.JSNBlackScreenOverrider=function (jsnmanager,overridenFrame,title)
    local self={
        _className="JSNBlackScreenOverrider",
        initImpl=function (self)
            if(self:getOriginalNativeFrame():GetLayerLevel() >= self:getLayerLevel())then
                self:setLayerLevel(self:getOriginalNativeFrame():GetLayerLevel()+1)
            end
            self:focus()
        end,
       
    }
    local obj=g.inherit(self,
    g.classes.JSNOverriderBase(jsnmanager,overridenFrame),
    g.classes.JSNCustomFrame(jsnmanager,"jsndarkscreen",title or ""),
    g.classes.JSNFocusable(jsnmanager,self))
    return obj
    
end

