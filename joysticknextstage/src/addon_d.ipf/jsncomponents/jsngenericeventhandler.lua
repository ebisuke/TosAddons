
--jsngenericeventhandler.lua
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
g.classes.JSNGenericEventHandlerType={
    eventUserRequestedDetermine="eventUserRequestedDetermine",
    eventUserRequestedMenu="eventUserRequestedMenu",
    eventUserRequestedCancel="eventUserRequestedCancel",
    eventUserRequestedClose="eventUserRequestedClose",
    eventRequestGenerateMenu="eventRequestGenerateMenu",
}

g.classes.JSNGenericEventHandler=function(jsnmanager,eventHandler)
    local self={
        _eventHandler=eventHandler,
        initImpl=function(self)
            
        end,
        _getEventHandler=function(self)
            return self._eventHandler 
        end,
        invokeEvent=function(self,eventName,...)
            if self:_getEventHandler() then
                if self:_getEventHandler()[eventName]==0  then
                 
                elseif self:_getEventHandler()[eventName] then
                    return self:_getEventHandler()[eventName](self,...)
                else
                    if self[eventName] then
                        return self[eventName](self,...)
                    end

                end
            elseif self[eventName] then
                return self[eventName](self,...)
            end

        end,
        onKeyDownImpl=function(self,key)
            if g.classes.JSNKey.MAIN==key then
                if(self:invokeHandler(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedDetermine))then
          
                    return true
                end
               
            end
            if(key==g.classes.JSNKey.OPTION)then
                if(self:invokeHandler(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedMenu))then
   
                    return true
                end
            end
            if(key==g.classes.JSNKey.CANCEL)then
                if(self:invokeHandler(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedCancel))then
   
                    return true
                end
            end
            if(key==g.classes.JSNKey.CLOSE)then
                if(self:invokeHandler(
                    g.classes.JSNGenericEventHandlerType.eventUserRequestedClose))then
   
                    return true
                end
            end
        end,
    }

    local obj=g.inherit(self,g.classes.JSNKeyHandler(jsnmanager))
    return obj
end