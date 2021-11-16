--jsnframebase.lua
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
g.classes.JSNFrameBase=function(jsnmanager,owner)
    local self={
        _className="JSNFrameBase",
        _nativeFrame=nil,
        initImpl=function(self)
           
            
        end,
        lazyInitImpl=function(self)
            local owner=self:getOwner()
            if(owner)then
                DBGOUT("owner "..owner._className.." lazyInitImpl"..owner:getLayerLevel())
                self:setLayerLevel(owner:getLayerLevel()+1)
            end
        end,
        refresh=function(self)
            self:refreshImpl()
        end,
        refreshImpl=function(self)
            -- please override
        end,
        setOffset=function(self,x,y)
            self:getNativeFrame():SetOffset(x,y)
        end,
        setNativeFrame=function(self,nativeFrame)
            self._nativeFrame=nativeFrame
        end,
        setLayerLevel=function(self,layerLevel)
            self:getNativeFrame():SetLayerLevel(layerLevel)
        end,
        getLayerLevel=function(self)
            return self:getNativeFrame():GetLayerLevel()
        end,
        setGravity=function(self,horz,vert)
            self:getNativeFrame():SetGravity(horz,vert)
        end,
        getNativeFrame=function (self)
            return self._nativeFrame
        end,
        setRect=function (self,x,y,w,h)
            self:getNativeFrame():SetOffset(x,y)
            self:getNativeFrame():Resize(w,h)
        end,
        resize=function (self,w,h)
            self:getNativeFrame():Resize(w,h)
        end,
        getHeight=function(self)
            return self:getNativeFrame():GetHeight()
        end,
        getWidth=function(self)
            return self:getNativeFrame():GetWidth()
        end,
        getX=function(self)
            return self:getNativeFrame():GetX()
        end,
        getY=function(self)
            return self:getNativeFrame():GetY()
        end,
        getGlobalX=function(self)
            return self:getNativeFrame():GetGlobalX()
        end,
        getGlobalY=function(self)
            return self:getNativeFrame():GetGlobalY()
        end,
        show=function(self)
            self:getNativeFrame():ShowWindow(1)
        end,
        hide=function(self)
            self:getNativeFrame():ShowWindow(0)
        end,
       

    }

    local object=g.inherit(
        self,g.classes.JSNKeyHandler(jsnmanager), 
        g.classes.JSNOwnerRelation(owner), 
        g.classes.JSNParentChildRelation(),
        g.classes.JSNManagerLinker(jsnmanager))

 
    return object

end