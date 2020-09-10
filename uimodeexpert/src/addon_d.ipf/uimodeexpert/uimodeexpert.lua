--uimodeexpert
--アドオン名（大文字）
local addonName = "uimodeexpert"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local acutil = require('acutil')

--ライブラリ読み込み

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

UIMODEEXPERT=UIMODEEXPERT or {}
local g=UIMODEEXPERT

g=table.concat(g,{
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
});
UIMODEEXPERT=g;



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


UIMODEEXPERT=g