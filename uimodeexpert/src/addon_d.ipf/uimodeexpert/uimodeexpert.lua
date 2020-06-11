--uimodeexpert
--アドオン名（大文字）
local addonName = "uimodeexpert"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]["g"]
local v = _G['ADDONS'][author][addonName]["v"]

local acutil = require('acutil')

--ライブラリ読み込み

local acutil = require('acutil')
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

g.v=g.v or {
    hotkeyenablecount=0
}
g.f={
    initialize=function(self)
    end,
    enableHotKey=function(self)
        
        if(g.v.hotkeyenablecount==0)then
            keyboard.EnableHotKey(true);
        end
        g.v.hotkeyenablecount=g.v.hotkeyenablecount+1
        
    end,
    disableHotKey=function(self)
        if(g.v.hotkeyenablecount>0)then
            g.v.hotkeyenablecount=g.v.hotkeyenablecount-1
        end
        if(g.v.hotkeyenablecount==0)then
            keyboard.EnableHotKey(false);
        end
    end,
    showCommandWnd=function(self)
        ui.GetFrame("uimodecommand"):ShowWindow(1)
    end,
    hideCommandWnd=function(self)
        ui.GetFrame("uimodecommand"):ShowWindow(0)

    end
}



--マップ読み込み時処理（1度だけ）
function UIMODEEXPERT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame


            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg('FPS_UPDATE', 'UIMODEEXPERT_FPS_UPDATE');
            addon:RegisterMsg('BUFF_REMOVE', 'BUFFREMAINVISUALIZER_BUFF_ON_MSG');
            addon:RegisterMsg('BUFF_UPDATE', 'BUFFREMAINVISUALIZER_BUFF_ON_MSG');

            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIMODEEXPERT_FPS_UPDATE(frame)
    frame:ShowWindow(1)
end
