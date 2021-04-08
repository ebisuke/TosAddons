--tpssavior
--アドオン名（大文字）
local addonName = "tpssavior"
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
g.settings = {x = 300, y = 300}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "tpssavior"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[TS]loaded")
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
    return ui.GetFrame('modenotice'):IsVisible() == 1
end


function TPSSAVIOR_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('FPS_UPDATE', 'TPSSAVIOR_FPS_UPDATE');
     
            local timer = frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('TPSSAVIOR_ON_TIMER')
            timer:Start(0.00)
            timer:EnableHideUpdate(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TPSSAVIOR_FPS_UPDATE()
    ui.GetFrame(g.framename):ShowWindow(1)
end
function TPSSAVIOR_ON_TIMER()
    local actor=GetMyActor()
    local dir=math.atan2(actor:GetHorizonalDir().y,actor:GetHorizonalDir().x)
    local pos=actor:GetPos()
    local px,py,pz;
    local lx,ly,lz;
    local len=-20;
    local looklen=20;
    px=pos.x+math.cos(dir)*len
    py=pos.y+math.sin(dir)*len
    pz=pos.z+1
    lx=pos.x+math.cos(dir)*looklen
    ly=pos.y+math.sin(dir)*looklen
    lz=pos.z
    
    --camera look
    camera.ChangeCameraType(4); -- CT_VIDEO
    camera.SetCameraWorkingMode(true);
    camera.SetNavCamPos(px, py, pz)
    --camera.ChangeCamera(2, session.GetMyHandle(), px, py, pz, 0, 1, 0);
    camera.WatchPos(lx, ly, lz, 0, 1, 0);

end
