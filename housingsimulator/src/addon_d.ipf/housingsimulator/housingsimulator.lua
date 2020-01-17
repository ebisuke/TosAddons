-- housingsimulator
local addonName = "housingsimulator"
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
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "housingsimulator"
g.debug = false
g.resizing = nil

--ライブラリ読み込み
CHAT_SYSTEM("[HSIM]loaded")
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

function HOUSINGSIMULATOR_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function HOUSINGSIMULATOR_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {x = 300, y = 300, w = 300, h = 200}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    HOUSINGSIMULATOR_UPGRADE_SETTINGS()
    HOUSINGSIMULATOR_SAVE_SETTINGS()

end


function HOUSINGSIMULATOR_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function HOUSINGSIMULATOR_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            g.initialized = false
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('HSIM', 'sysmenu_inv', 'housingsimulator', 'HOUSINGSIMULATOR_TOGGLE_FRAME')

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            
            --  --コンテキストメニュー
            --frame:SetEventScript(ui.RBUTTONDOWN, "HSIM_ON_RCLICK")
            -- --ドラッグ
            
            
            HOUSINGSIMULATOR_LOAD_SETTINGS()
            HSIM_INIT()
           
            --ui.GetFrame("housingsimulator"):SetSkinName("None")
            ui.GetFrame("housingsimulator"):ShowWindow(1)
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HOUSINGSIMULATOR_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function HOUSINGSIMULATOR_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function HOUSINGSIMULATOR_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end

function HSIM_UPDATE_INVENTORY_TOGGLE_ITEM(frame)
    local ret = UPDATE_INVENTORY_TOGGLE_ITEM_OLD(frame)
    frame = ui.GetFrame(g.framename)
    if (not HSIM_ISINITIALIZED()) then
        return
    end
    if ui.GetFrame("housingsimulator"):IsVisible() == 0 or not g.initialized then
        return;
    end
    
    local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
    AUTO_CAST(slt)
    for i = 0, slt:GetSlotCount() - 1 do
        local slot = slt:GetSlotByIndex(i)
        if slot ~= nil and slot:IsVisible() == 1 then
            if slt:GetHeight() == 0 then
                return 1;
            end
            
            if slot:IsVisibleRecursively() == true then
                slot:PlayUIEffect("I_sys_item_slot", 2.2, "Inventory_TOGGLE_ITEM", true);
            end
        end
    end
    return ret
end

function HSIM_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("housingsimulator") or ui.GetFrame(g.framename)
        
            frame:Resize(g.settings.w, g.settings.h)
            frame:SetOffset(g.settings.x, g.settings.y)
            frame:EnableMove(1)
            frame:SetSkinName("chat_window")
            frame:EnableHittestFrame(1)
            --frame:SetGravity(ui.LEFT, ui.BOTTOM)
            frame:EnableResize(1)
            frame:EnableHide(0)
            frame:SetLayerLevel(80)
            frame:SetEventScript(ui.RESIZE, "HSIM_ON_RESIZE")
            frame:SetEventScript(ui.LBUTTONUP, "HSIM_SAVE_POSITION")
            
            frame:SetOffset(g.settings.x, g.settings.y)
            frame:Resize(g.settings.w, g.settings.h)
            local title=frame:CreateOrGetControl("richtext","title",30,5,100,20)
            title:EnableHitTest(0)
            title:SetText("{ol}Housing Simulator")
            local gbox=frame:CreateOrGetControl("groupbox","gbox",0,30,frame:GetWidth(),frame:GetHeight())
            AUTO_CAST(gbox)
            gbox:RemoveAllChild()
            gbox:SetSkinName("chat_window")
            gbox:EnableScrollBar(0)
            local scroller=gbox:CreateOrGetControl("groupbox","scroller",0,0,1920,1080)
            AUTO_CAST(scroller)
            local pic=gbox:CreateOrGetControl("picture","pic",0,0,2048,2048)
            AUTO_CAST(pic)
            local pics=gbox:CreateOrGetControl("picture","testpic",0,0,200,200)
           

            AUTO_CAST(pics)
            local actor =  world.GetActor(559232)
            local apc=actor:GetPCApc()
            ui.CaptureMonsterImage(559232)
            local imgName = "number"
            pics:SetImage(imgName)
            pic:CreateInstTexture()
            pic:FillClonePicture("00000000")
            pic:SetEventScript(ui.LBUTTONUP, "HSIM_SAVE_POSITION")
            
            HSIM_RESIZE()
            HSIM_NEWDOC(48,48)
            g.initialized = true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HSIM_CLEARANDINIT_SLOT(slot)
    slot:RemoveAllChild()
    slot:ClearIcon()
    
    slot:ReleaseBlink();
    slot:SetText("")
    slot:SetSkinName("invenslot2")
 
end
function HSIM_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("housingsimulator")
            local gbox=frame:GetChild("gbox")
            AUTO_CAST(gbox)
            gbox:Resize(frame:GetWidth(),frame:GetHeight()-80)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HSIM_NEWDOC(w,h)
    g.settings.document={}
    g.settings.document.tile={}
    for y=1,h do
        g.settings.document.tile[y]={}
        for x=1,w do
            g.settings.document.tile[y][x]={}
        end
    end
end

function HSIM_ON_TIMER()
    EBI_try_catch{
        try = function()
           
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function HSIM_ON_RESIZE()
    g.resizing = 1
    HSIM_RESIZE()
    HSIM_SAVE_POSITION()
end
function HSIM_SAVE_POSITION()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            
            g.settings.x = frame:GetX()
            g.settings.y = frame:GetY()
            g.settings.w = frame:GetWidth()
            g.settings.h = frame:GetHeight()
            HOUSINGSIMULATOR_SAVE_SETTINGS()
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end