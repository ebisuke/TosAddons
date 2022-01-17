-- customui
--アドオン名（大文字）
local addonName = "customui"
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
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "customui"
g.debug = false
g.x = nil
g.y = nil
g.customizing=false
g.frms={}

local function CalcPosScreenToClient(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame("worldmap2_mainmap")
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (ow / sw), y * (oh / sh)
end
--ライブラリ読み込み
CHAT_SYSTEM("[CUI]loaded")
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

function CUSTOMUI_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
           
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
   
            addon:RegisterMsg('FPS_UPDATE', 'CUSTOMUI_EVERY');
            local addontimer = frame:GetChild("addontimer")
            AUTO_CAST(addontimer)
            addontimer:SetUpdateScript("CUSTOMUI_ON_TIMER")
            addontimer:Start(0.00)
            addontimer:EnableHideUpdate(1)
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0,0)

            local settingsPath="../addons/customui/frames.txt"
            local f=io.open(settingsPath, "r")
            local line
            while(true) do
                line=f:read("l")
                if line==nil then
                    break
                end
                local k=line:lower()
                g.frms[k]=true
                
            end
            acutil.addSysIcon('customui_custom', 'sysmenu_sys', 'CustomUI Start/End Customize', 'CUSTOMUI_TOGGLE_CUSTOMIZE')
            g.default={}
            for k,v in pairs(g.frms) do
                local frame=ui.GetFrame(k)
                g.default[k]={
                    isVisible=frame:IsVisible(),
                    x=frame:GetGlobalX(),
                    y=frame:GetGlobalY(),
                    w=frame:GetWidth(),
                    h=frame:GetHeight(),
                }
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CUSTOMUI_GET_UNDERLYING_FRAME()
    local blacklist={
        ["customui"]=true,
        ['customui_frame']=true,
    }
    local posx,posy=CalcPosScreenToClient(mouse.GetX(),mouse.GetY())
    local list={}
    for k,v in pairs(g.frms) do
        local frame = ui.GetFrame(k)
        if not blacklist[k] and frame ~= nil and frame:IsVisible()==1 then
            local x,y=frame:GetGlobalX(),frame:GetGlobalY()
            local w,h=frame:GetWidth(),frame:GetHeight()
            if posx>x and posx<x+w and posy>y and posy<y+h then
                list[#list+1] = frame
            end
        end
    end
    table.sort(list,function(a,b)
        return a:GetLayerLevel()<b:GetLayerLevel()
    end)
    --CHAT_SYSTEM(tostring(#list)..posx..']'..posy.."#"..#g.frms)
    return list[#list]
end
function CUSTOMUI_TOGGLE_CUSTOMIZE()
    if g.customizing then
        g.customizing=false
        ui.SysMsg("CustomUI End Customize")
    else
        g.customizing=true
        ui.SysMsg("CustomUI Start Customize")
    end
end
function CUSTOMUI_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function CUSTOMUI_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    CUSTOMUI_UPGRADE_SETTINGS()
    CUSTOMUI_SAVE_SETTINGS()

end


function  CUSTOMUI_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

function CUSTOMUI_GAME_START()
    EBI_try_catch{
        try = function()
            
        CUSTOMUI_LOAD_SETTINGS()

        
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function CUSTOMUI_3SEC()
    
    CUSTOMUI_APPLY()
end

function CUSTOMUI_APPLY()
    EBI_try_catch{
        try = function()
            g.settings.frames=g.settings.frames or {}
            for k,v in pairs(g.settings.frames) do
                local frame=ui.GetFrame(k)
                if frame then
                    frame:SetOffset(v.x,v.y)
                end
            end

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CUSTOMUI_EVERY()
    ui.GetFrame(g.framename):ShowWindow(1)
    CUSTOMUI_APPLY()
end
function CUSTOMUI_UPDATE_SELECTFRAME()
    local frame = g.selectframe
    local selframe=ui.GetFrame("customui_frame")
    if not g.selectframe then
        selframe:ShowWindow(0)
    else
        selframe:ShowWindow(1)
        selframe:SetOffset(frame:GetGlobalX(),frame:GetGlobalY())
        selframe:Resize(frame:GetWidth(),frame:GetHeight())
        selframe:SetLayerLevel(frame:GetLayerLevel()+1)
        selframe:EnableHitTest(0)
        selframe:EnableHittestFrame(0)
    end

    
end
function CUSTOMUI_ON_TIMER()
    EBI_try_catch{
        try = function()
            
            if g.customizing then
                local frame=CUSTOMUI_GET_UNDERLYING_FRAME()
                if keyboard.IsKeyPressed("C")==0 then
                    if g.selectframe~= frame then
                        g.selectframe= frame
                        CUSTOMUI_UPDATE_SELECTFRAME()
                    end
                    if g.selectframe==nil then
                        CUSTOMUI_UPDATE_SELECTFRAME()
                    end
                end
                if keyboard.IsKeyPressed("C")==1 and g.selectframe then
                    if g.startpos==nil then
                        local x,y=CalcPosScreenToClient(mouse.GetX(),mouse.GetY())
                        g.startpos={x=x,y=y}
                      
                    else
                        local x,y=CalcPosScreenToClient(mouse.GetX(),mouse.GetY())
                        local dx=x-g.startpos.x
                        local dy=y-g.startpos.y
                        g.startpos={x=x,y=y}
                        g.selectframe:SetOffset(g.selectframe:GetX()+dx,g.selectframe:GetY()+dy)
                        g.settings.frames[g.selectframe:GetName()]= g.settings.frames[g.selectframe:GetName()] or {}
                        g.settings.frames[g.selectframe:GetName()].x=g.selectframe:GetX()
                        g.settings.frames[g.selectframe:GetName()].y=g.selectframe:GetY()
                        CUSTOMUI_SAVE_SETTINGS()
                    end
                else
                    g.startpos=nil
                end
                if g.selectframe then
                    if keyboard.IsKeyDown("V")==1 then
                        --reset
                        local context=ui.CreateContextMenu("CUSTOMUI_CONTEXTMENU", "CustomUI", 0, 0, 100, 100)
                        ui.AddContextMenuItem(context, "Reset Frame", string.format("CUSTOMUI_CONTEXTMENU_RESETFRAME('%s')",g.selectframe:GetName()))
                        ui.OpenContextMenu(context);
                    end
                end
            end

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CUSTOMUI_CONTEXTMENU_RESETFRAME(framename)
    g.settings.frames[framename] = nil
    local frame=ui.GetFrame(framename)
    frame:SetOffset(g.default[framename].x,g.default[framename].y)
    frame:Resize(g.default[framename].w,g.default[framename].h)

    CUSTOMUI_SAVE_SETTINGS()
end

