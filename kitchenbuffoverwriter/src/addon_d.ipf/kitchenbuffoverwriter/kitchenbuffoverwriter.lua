-- kitchenbuffoverwriter
--アドオン名（大文字）
local addonName = 'KITCHENBUFFOVERWRITER'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'kitchenbuffoverwriter'
g.debug = false
CHAT_SYSTEM('[KBO]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function KITCHENBUFFOVERWRITER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPEXTENDER_GETCID()))
            frame:ShowWindow(0)
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end

            acutil.setupHook(KITCHENBUFFOVERWRITER_EAT_FOODTABLE,"EAT_FOODTABLE")

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function KITCHENBUFFOVERWRITER_EAT_FOODTABLE(parent,ctrl)
    local bufftable={
        [1]=4022,
        [2]=4023,
        [3]=4024,
        [4]=4021,
        [5]=4087,
        [6]=4136
    }
    local type = parent:GetUserIValue("FOOD_TYPE");

	local frame = parent:GetTopParentFrame();
	local handle = frame:GetUserIValue("HANDLE");

    local buffid=bufftable[type]
    local meshi = info.GetBuff(session.GetMyHandle(), buffid)
    if meshi then
        -- remove buff
        packet.ReqRemoveBuff(buffid);
        -- delayed eat
        ReserveScript(string.format("KITCHENBUFFOVERWRITER_EAT_FOODTABLE_DELAYED(%d,%d)",handle,type),0.1)
    else
        -- eat immediately
        EAT_FOODTABLE_OLD(parent,ctrl)
    end
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(),parent:GetName(),ctrl:GetName(),4)
end


function KITCHENBUFFOVERWRITER_EAT_FOODTABLE_DELAYED(handle,clsid)
    control.CustomCommand("EAT_FOODTABLE", handle, clsid);
   
end