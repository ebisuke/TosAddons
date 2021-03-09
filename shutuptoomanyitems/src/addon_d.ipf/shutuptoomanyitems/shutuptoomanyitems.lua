--shutuptoomanyitems
--アドオン名（大文字）
local addonName = "shutuptoomanyitems"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.framename = "shutuptoomanyitems"
g.debug = false



--ライブラリ読み込み
CHAT_SYSTEM("[STI]loaded")
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

local function IsUIMode()
    return ui.GetFrame('modenotice'):IsVisible()==1
end
local function SetPseudoUIMode(mode)
    
    joystick.ToggleMouseMode()
    
end

function SHUTUPTOOMANYITEMS_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            addon:RegisterMsg("DO_OPEN_WARNINGMSGBOX_EX_UI", "SHUTUPTOOMANYITEMS_EX_FRAME_OPEN")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SHUTUPTOOMANYITEMS_EX_FRAME_OPEN()
    ReserveScript("SHUTUPTOOMANYITEMS_EX_FRAME_OPEN_DELAYED()",0.01)
end

function SHUTUPTOOMANYITEMS_EX_FRAME_OPEN_DELAYED()
    local warningbox=ui.GetFrame('warningmsgbox_ex')
    if warningbox:IsVisible()==1 then
        local text=warningbox:GetChildRecursively('warningtext')
        local yesarg=warningbox:GetChildRecursively('ok'):GetEventScriptArgString(ui.LBUTTONUP)
       
        if text:GetText()==ClMsg("MaxSlotCountMsg") or yesarg=="MaxSlotCountMsgCompare/" then
            warningbox:ShowWindow(0)
            --alternate
            ui.SysMsg(ClMsg("MaxSlotCountMsg"))
        end
    end
end