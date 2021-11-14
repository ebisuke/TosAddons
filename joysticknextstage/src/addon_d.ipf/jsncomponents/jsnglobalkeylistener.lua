--jsnglobalkeylistener.lua
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

g.classes.JSNGlobalKeyListener=function(jsnmanager)

    local self={
        _className="JSNGlobalKeyListener",
        onKeyDownImpl=function(self,key)
            if key==g.classes.JSNKey.OMNISCREEN then
                
                --if(not g.classes.JSNOmniScreen():getInstance())then
                    g.classes.JSNOmniScreen():init()
                --end
                return true
            end
            if key==g.classes.JSNKey.DEBUG and g.debug then
                JOYSTICKNEXTSTAGE_DEBUG_RELOAD()
                --if(not g.classes.JSNOmniScreen():getInstance())then
                 --   g.classes.JSNInventoryFrame(g.classes.JSNManager():getInstance()):init()
                --end
                return true
            end
        end,
    }

    local object=g.inherit(self,
    g.classes.JSNKeyHandler(jsnmanager))
   
    return object
end