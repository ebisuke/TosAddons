--jsnomniscreen.lua
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
g.classes.JSNOmniScreen=function()
    local jsnmanager=g.classes.JSNManager():getInstance()
    local self={
        _className="JSNOmniScreen",
        _tabInventory=nil,
        _activeTab=nil,
        initImpl=function(self)
            self:focus()
        end,
        lazyInitImpl=function(self)

            self._tabInventory=g.classes.JSNOmniTabInventory(jsnmanager,self):init()
           
            self:setActiveTab(self._tabInventory)
            
        end,
        setActiveTab=function(self,tab)
            if(self._activeTab~=nil)then
                self._activeTab:unfocus()
                self._activeTab:hide()
            end
            self._activeTab=tab
            if(self._activeTab~=nil)then
                self._activeTab:focus()
                self._activeTab:show()
                self:setTitle("{@sti7}{s28}"..tab:getTitle())
            end
        end,
        releaseImpl=function(self)
            
            self._tabInventory:release()
        end,
       
        applyFadeImpl=function (self,frame)

            -- local fadein=frame:GetFadeInManager()
            -- local fadeout=frame:GetFadeOutManager()
            -- fadein:Enable(true)
            -- fadeout:Enable(true)
            -- fadein:SetPivot(0.5,1)
            -- fadein:SetBasePosition(frame:GetWidth()/2,frame:GetHeight())
            -- fadein:SetBlend(0.5)
            -- fadein:SetScaleX(0.2,0.5)
            -- fadein:SetScaleY(0.2,0.5)
            -- fadein:SetMove(0.3)
            -- fadeout:SetPivot(0.5,1)
            -- fadeout:SetBasePosition(frame:GetWidth()/2,frame:GetHeight())
            -- fadeout:SetBlend(0.5)
            -- fadeout:SetScaleX(0.2,0.5)
            -- fadeout:SetScaleY(0.2,0.5)
            -- fadeout:SetMove(0.3)
        end,
        onKeyDownImpl=function(self,key)
            if(key==g.classes.JSNKey.CLOSE)then
                self:release()
                return true
            end
        end,
    }
    if(g.singleton[self._className]~=nil)then
        return g.singleton[self._className]
    end
 
    local obj= g.inherit(self,
    g.classes.JSNCustomFrame(jsnmanager,'jsndarkscreen'),
    g.classes.JSNGenericEventHandler(jsnmanager),
    g.classes.JSNFocusable(jsnmanager,self),
    g.classes.JSNOwnerRelation(),
    g.classes.JSNPlayerControlDisabler(jsnmanager),
    g.classes.JSNSingleton())
  
    return obj
end

