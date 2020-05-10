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
g.debug = true
g.resizing = nil

g.gridsize = 50
g.marginy = 0
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
            local frame = ui.GetFrame(g.framename)
            frame:CreateOrGetControl("timer", "addontimer", 0, 0, 10, 10)
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("HSIM_ON_TIMER");
            timer:Start(0.01);
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
            local title = frame:CreateOrGetControl("richtext", "title", 30, 5, 100, 20)
            title:EnableHitTest(0)
            title:SetText("{ol}Housing Simulator")
            local gbox = frame:CreateOrGetControl("groupbox", "gbox", 120, 30, frame:GetWidth() - 40, frame:GetHeight())
            AUTO_CAST(gbox)
            gbox:RemoveAllChild()
            gbox:SetSkinName("chat_window")
            gbox:EnableScrollBar(0)
            local gboxpalette = frame:CreateOrGetControl("groupbox", "gboxpalette", 0, 30, 100, frame:GetHeight())
            AUTO_CAST(gboxpalette)
            gboxpalette:EnableScrollBar(1)
            local palette = gboxpalette:CreateOrGetControl("slotset", "palette", 0, 0, 0, 0)
            AUTO_CAST(palette)
            local scroller = gbox:CreateOrGetControl("groupbox", "scroller", 0, 0, 1920, 1080)
            AUTO_CAST(scroller)
            scroller:SetEventScript(ui.LBUTTONDOWN, "HSIM_ON_LBUTTONDOWN")
            scroller:SetEventScript(ui.RBUTTONDOWN, "HSIM_ON_LBUTTONDOWN")
            scroller:SetEventScriptArgNumber(ui.LBUTTONDOWN, 0)
            scroller:SetEventScriptArgNumber(ui.RBUTTONDOWN, 1)
            
            local pic = gbox:CreateOrGetControl("picture", "pic", 0, 0, 2048, 2048)
            AUTO_CAST(pic)
            pic:CreateInstTexture()
            pic:FillClonePicture("00000000")
            pic:SetEventScript(ui.LBUTTONUP, "HSIM_SAVE_POSITION")
            pic:EnableHitTest(0)
            HSIM_RESIZE()
            HSIM_INITIALIZE_PALETTE()
            HSIM_NEWDOC(15, 15)
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
function HSIM_INITIALIZE_PALETTE()
    local frame = ui.GetFrame("housingsimulator")
    local gbox = frame:GetChild("gboxpalette")
    local palette = gbox:GetChild("palette")
    AUTO_CAST(palette)
    local itemClsList, cnt = GetClassList('Item');
    palette:RemoveAllChild()
    palette:SetColRow(2, 0)
    palette:SetSlotSize(45, 45)
    palette:EnableDrag(0)
    palette:SetSpc(0, 0)
    palette:EnableDrop(0)
    palette:EnableSelection(1)
    palette:CreateSlots()
    palette:ClearSelectedSlot()
    local idx = 1
    for i = 0, cnt - 1 do
        local itemCls = GetClassByIndexFromList(itemClsList, i);
        if itemCls.ToolTipScp == "HOUSING" then
            
            if (palette:GetSlotCount() <= idx) then
                palette:ExpandRow()
            end
            --palette:CreateSlots()
            local slot = palette:GetSlotByIndex(idx - 1)
            
            --HSIM_CLEARANDINIT_SLOT(slot)
            SET_SLOT_ITEM_CLS(slot, itemCls)
            SET_SLOT_STYLESET(slot, itemCls)
            slot:EnableDrag(0)
            slot:EnableDrop(0)
            slot:EnablePop(0)
            slot:SetUserValue("clsid", itemCls.ClassID)
            idx = idx + 1
            print(tostring(idx))
        end
    end
    palette:Resize(90, idx * 45 / 2)
end
function HSIM_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("housingsimulator")
            local gbox = frame:GetChild("gbox")
            AUTO_CAST(gbox)
            gbox:Resize(frame:GetWidth() - 120, frame:GetHeight() - 80)
            local gboxpalette = frame:GetChild("gboxpalette")
            AUTO_CAST(gboxpalette)
            gboxpalette:Resize(120, frame:GetHeight() - 80)
            gboxpalette:EnableScrollBar(1)
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HSIM_ON_LBUTTONDOWN(frame,ctrl,argstr,argnum)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local mx, my = GET_MOUSE_POS()
            local qx, qy = HSIM_CALC_MOUSEPOS_TO_QUARTERPOS(mx, my)
            if (qx) then
                local name="hsim_h_weapon_laboratory"
                if(argnum==1)then
                    name="hsim_h_topiary_cube"
                end
                local idx=#g.settings.document.item+1
                g.settings.document.item[idx]={
                    direction=0,
                    name=name,
                    clsid=HSIM_GET_SELECTED_ITEM(),
                    x=qx,
                    y=qy,
                }
                DBGOUT("PUT")
                g.settings.document.tile[qy][qx]=idx
                HSIM_RENDER()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HSIM_NEWDOC(w, h)
    local frame = ui.GetFrame(g.framename)
    g.settings.document = {}
    g.settings.document.item = {}
    g.settings.document.tile = {}
    g.settings.docw = w;
    g.settings.doch = h
    local parent = GET_CHILD_RECURSIVELY(frame, "scroller")
    AUTO_CAST(parent)
    parent:RemoveAllChild()
    
end

function HSIM_ON_TIMER()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            
            local gbox = frame:GetChild("gbox")
            AUTO_CAST(gbox)
            local scroller = gbox:GetChild("scroller")
            AUTO_CAST(scroller)
            local pic = scroller:CreateOrGetControl("picture", "selectpic", 0, 0, 300, 600)
            AUTO_CAST(pic)
            local mx, my = GET_MOUSE_POS()
            local qx, qy = HSIM_CALC_MOUSEPOS_TO_QUARTERPOS(mx, my)
            if (qx) then
                local clsid = HSIM_GET_SELECTED_ITEM()
                if (clsid) then
                   
                    local ox, oy = HSIM_CALC_QUARTERPOS_TO_POS(qx, qy)
                    pic:SetOffset(ox - 150, oy - 300)
                    pic:SetColorTone("FF00FF00")
                    pic:SetImage("hsim_h_weapon_laboratory_0")
                    pic:ShowWindow(1)
                else
                    pic:ShowWindow(0)
                end
            else
                pic:ShowWindow(0)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HSIM_RENDER()
    local frame = ui.GetFrame(g.framename)
    local gbox = frame:GetChild("gbox")
    AUTO_CAST(gbox)
    local scroller = gbox:GetChild("scroller")
    AUTO_CAST(scroller)
    for k, v in ipairs(g.settings.document.item) do
        local itemy=v.y-v.x+g.settings.docw;

        DBGOUT(tostring(itemy))
        local pic=scroller:CreateOrGetControl("picture","pic"..tostring(k),0,0,300,600);
        AUTO_CAST(pic)
        pic:EnableHitTest(0)
        local ox,oy=HSIM_CALC_QUARTERPOS_TO_POS(v.x,v.y)
        
        pic:SetOffset(ox-150,oy-300)
        pic:SetImage(v.name.."_"..tostring(v.direction))
        
    end
end
function HSIM_GET_SELECTED_ITEM()
    local frame = ui.GetFrame(g.framename)
    local gboxpalette = frame:GetChild("gboxpalette")
    local slotset = GET_CHILD_RECURSIVELY(gboxpalette, "palette")
    AUTO_CAST(slotset)
    if (slotset:GetSelectedSlotCount() == 0) then

        return nil        
    end
    local slot = slotset:GetSelectedSlot(0)
    if (slot == nil) then
        
        return nil
    end
    
    local icon = slot:GetIcon()
    --local itemobj = GetIES(icon:GetInfo():GetObject());
    local clsid = slot:GetUserIValue("clsid")
    return clsid

end
--https://teratail.com/questions/32022
function HSIM_CALC_MOUSEPOS_TO_QUARTERPOS(mx, my)
    local frame = ui.GetFrame(g.framename)
    local gbox = frame:GetChild("gbox")
    AUTO_CAST(gbox)
    local scroller = gbox:GetChild("scroller")
    AUTO_CAST(scroller)
    
    
    if (option.GetClientWidth() >= 3000) then
        mx = mx / 2
        my = my / 2
    end
    
    mx = mx - frame:GetX() - gbox:GetX() - scroller:GetX()
    my = my - frame:GetY() - gbox:GetY() - scroller:GetY() - g.gridsize * (g.settings.docw) / 2 - g.marginy
    my = my
    my = my * 2
    local cx = math.cos(math.pi / 4) * mx - math.sin(math.pi / 4) * my;
    local cy = math.sin(math.pi / 4) * mx + math.cos(math.pi / 4) * my;
    
    
    local quatx = math.floor(cx / g.gridsize)
    local quaty = math.floor(cy / g.gridsize)
   -- print(string.format("%d,%d,%d,%d", mx, my, quatx, quaty))
    if (quatx >= 0 and quatx < g.settings.w and quaty >= 0 and quaty < g.settings.h) then
        return quatx, quaty
    else
        return nil, nil
    end
end
function HSIM_CALC_QUARTERPOS_TO_POS(qx, qy)
    local frame = ui.GetFrame(g.framename)
    local gbox = frame:GetChild("gbox")
    AUTO_CAST(gbox)
    local scroller = gbox:GetChild("scroller")
    AUTO_CAST(scroller)
    
    
    
    --affine transform
    local cx, cy
    local qcx = qx * g.gridsize
    local qcy = qy * g.gridsize
    cx = math.cos(-math.pi / 4) * qcx - math.sin(-math.pi / 4) * qcy;
    cy = math.sin(-math.pi / 4) * qcx + math.cos(-math.pi / 4) * qcy;
    cy = cy / 2
    
    cy = cy + g.gridsize * (g.settings.docw) / 2 + g.marginy
    --print(string.format("%d,%d",cx,cy))
    return cx, cy
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
