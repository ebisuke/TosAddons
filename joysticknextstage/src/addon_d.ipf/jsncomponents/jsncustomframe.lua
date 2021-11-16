--jsnframe.lua
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
g.classes.JSNCustomFrame=function(jsnmanager,templateFrameName,title)
    local self={
        _className="JSNCustomFrame",
        _templateFrameName=templateFrameName,
        _title=title,
        _nativeFrameName=nil,
        getTemplateFrameName=function(self)
            return self._templateFrameName
        end,
        initImpl=function(self)
            local frame=ui.CreateNewFrame(self:getTemplateFrameName(),"jsncustom_"..self:getID())
            self._nativeFrameName=frame:GetName()
            frame:ShowWindow(1)
            self:setNativeFrame(frame)
            self:applyFade(frame)
            if(self._title)then
                self:setTitle(self._title)
            end
            
        
            --print("INIT:"..self:getNativeFrame():GetName())
        end,

        applyFade=function(self)
            self:applyFadeImpl(self:getNativeFrame())
        end,
        applyFadeImpl=function(self,nativeFrame)
            -- please override
            
        end,
        releaseImpl=function(self)
            if(self:getNativeFrame())then
                DBGOUT("RELEASE"..self._className)
                self:getNativeFrame():ShowWindow(0)
                ui.DestroyFrame(self._nativeFrameName)
                self:setNativeFrame(nil)
            end
        end,
        setTitle=function(self,title)
            DBGOUT("SETTITLE:"..title.." "..self._className)
            local frame=self:getNativeFrame()
            local titleText=frame:GetChildRecursively("title")
            self._title=title
            if(titleText)then
                titleText:SetText("{@st42}{s20}"..(title or ""))
                titleText:SetTextByKey('value', title);
            else
                ERROUT("titleText is nil")
            end
        end,
        getTitle=function(self)
            return self._title
        end,
    }


    local object=g.inherit(self,g.classes.JSNFrameBase(jsnmanager))


    
    return object
end