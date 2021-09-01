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
g.prevx = nil
g.prevy = nil
g.lookyaw = 0
g.lookpitch = 0
g.mode = false
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
local function SetMousePos_Fixed(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    --return x*(sw/ow),y*(sh/oh)
    mouse.SetPos(x * (sw / ow), y * (sh / oh))
end
local function GetScreenWidth()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return ow
end
local function GetScreenHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('worldmap2_mainmap')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return oh
end
local function CalcPos(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame('loginui_autojoin')
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (sw / ow), y * (sh / oh)

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
            acutil.slashCommand("/tps", TPSSAVIOR_PROCESS_COMMAND);
           
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
    EBI_try_catch{
        try = function()
            local actor = GetMyActor()
            if g.mode then
             
                local dir = math.atan2(actor:GetHorizonalDir().x, actor:GetHorizonalDir().y)
                local pos = actor:GetPos()
                local px, py, pz;
                local lx, ly, lz;
                local len = -1;
                local looklen = 40;
                
                
                local mousex = mouse.GetX()
                local mousey = mouse.GetY()
                if g.prevx then
                    local deltax = mousex - g.prevx
                    local deltay = mousey - g.prevy
                    deltax = math.min(10, math.max(-10, deltax / 10))
                    deltay = math.min(10, math.max(-10, deltay / 10))
                    
                    g.lookyaw = g.lookyaw - deltax
                    g.lookpitch = math.min(89.99, math.max(-89.99, g.lookpitch + deltay))
                
                
                end
                
                px = pos.x + math.sin(g.lookyaw * math.pi / 180) * len
                py = pos.y +3
                pz = pos.z + math.cos(g.lookyaw * math.pi / 180) * len
                local rot90 = g.lookyaw + 90
                px = px + math.sin(rot90 * math.pi / 180) * 10
                py = py 
                pz = pz- math.cos(rot90 * math.pi / 180) * 10
                
                actor:SetRotate(-225)
                lx = pos.x + math.cos(g.lookyaw * math.pi / 180) * looklen
                ly = pos.y + 10
                lz = pos.z + math.sin(g.lookyaw * math.pi / 180) * looklen
                
               
                --camera look
                camera.ChangeCameraType(5); -- CT_FREE
                camera.SetCameraWorkingMode(false);
                
                camera.ChangeCamera(1, 0, px, py, pz, 0, 1, 0);
                
                
                camera.CamRotate(g.lookpitch, g.lookyaw)
                camera.CustomZoom(30,5, 0);
                camera.ChangeFov(90);
                local frame = ui.GetFrame('worldmap2_mainmap')
                local ow = frame:GetWidth()
                local oh = frame:GetHeight()
                SetMousePos_Fixed(ow/2,oh/2)
                g.prevx = option.GetClientWidth()/2;
                g.prevy = option.GetClientHeight()/2;
            else
               
            end
            
            if 1 == keyboard.IsKeyPressed("ESCAPE") and g.mode then
                g.mode = false
                camera.CamRotate(40, 45)
               
                local pos = actor:GetPos()
                local px, py, pz;
                px = pos.x 
                py = pos.y
                pz = pos.z 
                
                camera.WatchPos(px, py, pz, 0, 2, 1);
                camera.ChangeCameraType(1); -- CT_BIND
                camera.SetCameraWorkingMode(false);
                camera.ChangeCameraZoom(2, 0, 1, 1);
                camera.ChangeCamera(1, 0, px, py, pz, 0, 1, 0);
                camera.ChangeFov(60);
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TPSSAVIOR_PROCESS_COMMAND(command)
    local cmd = "";
    
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        
    end
    
    if cmd == "toggle" then
		g.mode=not g.mode
        if not g.mode then
            
            camera.CamRotate(40, 45)
            local actor = GetMyActor()
            local pos = actor:GetPos()
            local px, py, pz;
            px = pos.x 
            py = pos.y
            pz = pos.z 
            
            camera.WatchPos(px, py, pz, 0, 2, 1);
            camera.ChangeCameraType(1); -- CT_BIND
            camera.SetCameraWorkingMode(false);
            camera.ChangeCameraZoom(2, 0, 1, 1);
            camera.ChangeCamera(1, 0, px, py, pz, 0, 1, 0);
            camera.ChangeFov(60);
            CHAT_SYSTEM("[TS]DISABLED")
        else
            CHAT_SYSTEM("[TS]ENABLED")
        end 
		
	end
  
end