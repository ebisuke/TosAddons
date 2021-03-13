--joystickenhancer
--アドオン名（大文字）
local addonName = "joystickenhancer"
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
g.framename = "joystickenhancer"
g.debug = false
g.sys = {
    uimodecount = 0,
    uimodevisibles = {
    
    },
    uimodetriggers = {
        "worldmap2_mainmap",
        "worldmap2_submap",
        "skillability",
        "warehouse",
        "accountwarehouse",
        "shop",
        "decompose_manager",
        "earthtowershop",
        "itembuffrepair",
        "itembuffgemroasting",
        "itembuff",
        "itemcraft",
        "itemdungeon",
        "indunenter",
        "buffseller_target",
        "market",
        "enchantarmor",
        "fishing"
    }
}

--ライブラリ読み込み
CHAT_SYSTEM("[JE]loaded")
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
local function SetPseudoUIMode(mode)
    
    joystick.ToggleMouseMode()

end

function JOYSTICKENHANCER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('FPS_UPDATE', 'JOYSTICKENHANCER_FPS_UPDATE');
            acutil.setupHook(JOYSTICKENHANCER_PORTAL_SELLER_OPEN_UI, 'PORTAL_SELLER_OPEN_UI')
            
            local timer = frame:GetChild('addontimer')
            AUTO_CAST(timer)
            timer:SetUpdateScript('JOYSTICKENHANCER_ON_TIMER')
            timer:Start(0.01)
            timer:EnableHideUpdate(1)
            g.sys.uimodevisibles = {}
            g.sys.uimodecount = 0
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function JOYSTICKENHANCER_FPS_UPDATE()
    ui.GetFrame(g.framename):ShowWindow(1)
end
function JOYSTICKENHANCER_ON_TIMER()
    if IsJoyStickMode() == 0 then
        return
    end
    --ui.SysMsg('CHAT')
    for _, k in ipairs(g.sys.uimodetriggers) do
        
        if ui.GetFrame(k):IsVisible() == 1 and not g.sys.uimodevisibles[k] then
            g.sys.uimodevisibles[k] = true
            g.sys.uimodecount = g.sys.uimodecount + 1
            if g.sys.uimodecount == 1 then
                SetKeyboardSelectMode(1)
            end
        end
        if ui.GetFrame(k):IsVisible() == 0 and g.sys.uimodevisibles[k] then
            g.sys.uimodevisibles[k] = nil
            g.sys.uimodecount = g.sys.uimodecount - 1
            if g.sys.uimodecount == 0 then
                SetKeyboardSelectMode(0)
            end
        end
    end
    if joystick.IsKeyPressed('JOY_TARGET_CHANGE') == 1 then
        if joystick.IsKeyPressed('JOY_BTN_6') == 1 then
            JOYSTICKENHANCER_SHOW_RINGCOMMAND('GENERIC', session.GetMyHandle())
        end
    end
end

function JOYSTICKENHANCER_INDUNENTER_UI_RESET(frame)
    INDUNENTER_UI_RESET_OLD(frame)
    ReserveScript('JOYSTICKENHANCER_SHOW_RINGCOMMAND("INSTANCEDUNGEON",' .. session.GetMyHandle() .. ')', 0.01)
end

--for ring command
function JOYSTICKENHANCER_PORTAL_SELLER_OPEN_UI(groupName, sellType, handle)
    PORTAL_SELLER_OPEN_UI_OLD(groupName, sellType, handle)
    ReserveScript('JOYSTICKENHANCER_SHOW_RINGCOMMAND("PORTAL",' .. handle .. ')', 0.01)
end
function JOYSTICKENHANCER_SHOW_RINGCOMMAND(typeStr, handle)
    local frame = ui.GetFrame('petcommand')
    frame:ShowWindow(1)
    local timer = frame:CreateOrGetControl('timer', 'joystickenhancer_timer', 0, 0, 10, 10)
    
    AUTO_CAST(timer)
    timer:SetUpdateScript('JOYSTICKENHANCER_ON_TIMER_RINGCOMMAND')
    timer:Start(0.00)
    g.cmdtable = {}
    g.ring_force = true
    g.ring_target = handle
    if typeStr then
        
        SET_PETCOMMAND_TYPE(frame, typeStr, handle)
    
    end
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
function JOYSTICKENHANCER_OPEN_SYSMENU()
    SetMousePos_Fixed(GetScreenWidth() - 5, GetScreenHeight() - 5)
    SetKeyboardSelectMode(1)
    g.ring_sysmenu = true
end
function JOYSTICKENHANCER_OPEN_INVENTORY()
    SetMousePos_Fixed(GetScreenWidth() - 40, GetScreenHeight() / 2)
    SetKeyboardSelectMode(1)
    g.ring_sysmenu = true
    ui.GetFrame('inventory'):ShowWindow(1)
end


function JOYSTICKENHANCER_HIDE_RINGCOMMAND()
    local frame = ui.GetFrame('petcommand')
    frame:ShowWindow(0)
    local timer = frame:CreateOrGetControl('timer', 'joystickenhancer_timer', 0, 0, 10, 10)
    AUTO_CAST(timer)
    timer:Stop()
    control.EnableControl(1, 1)
    if g.ring_sysmenu then
        SetKeyboardSelectMode(0)
        g.ring_sysmenu = nil
    end
end
function CLOSE_PET_RINGCOMMAND(obj)
    if g.ring_force == false then
        JOYSTICKENHANCER_HIDE_RINGCOMMAND()
    end

end

function SHOW_PET_RINGCOMMAND(obj, frame)
    
    g.ring_force = false
    local fsmActor = GetMyActor();
    if fsmActor:GetVehicleState() == true then
        return;
    end
    
    --[[
    local frame = ui.GetFrame("ringcommand");
    SET_RINGCOMMAND_TYPE(frame, "COMPANION", obj:GetHandleVal());
    frame:ShowWindow(1);
    ]]
    local frame = ui.GetFrame("petcommand");
    SET_PETCOMMAND_TYPE(frame, "COMPANION", obj:GetHandleVal());

end

function SET_PETCOMMAND_TYPE(frame, typeStr, handle)
    EBI_try_catch{
        try = function()
            if not frame then
                frame = ui.GetFrame('petcommand')
            end
            frame:EnableHide(1)
            frame:ShowWindow(1);
            frame:SetLayerLevel(99)
            frame:SetCloseScript("JOYSTICKENHANCER_HIDE_RINGCOMMAND")
            frame:SetUserValue("HANDLE", handle);
            local ringCmdType = frame:GetUserValue("RINGCMD_TYPE");
            if typeStr ~= ringCmdType then
                frame:SetUserValue("RINGCMD_TYPE", typeStr);
                ringCmdType = typeStr;
            end
            g.cmdtable = {}
            local bg = frame:GetChild("bg");
            bg:RemoveAllChild();
            
            local myActor = GetMyActor();
            local angle = fsmactor.GetAngle(myActor) - 45;
            
            if ringCmdType == "GENERIC" then
                local index = 0;
                local totalCount = 4;
                
                if IsBuffApplied(GetMyPCObject(), "RidingCompanion") == "YES" then
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_1", "companion_down", "Alt+Dn", ClMsg("Unride"), 2, index, totalCount, "ON_RIDING_VEHICLE(0)", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_3", "companion_eat", "Alt+2", ClMsg("GiveFood"), 6, index, totalCount, "PETCMD_FEEDING", true);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "sysmenu_sys", "Sysmenu", "Sysmenu", 8, index, totalCount, "JOYSTICKENHANCER_OPEN_SYSMENU()", true);
                    
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_4", "sysmenu_inv", "Inventory", "Inventory", 4, index, totalCount, "JOYSTICKENHANCER_OPEN_INVENTORY()", true);
                    
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_5", "sysmenu_sys", "WorldMap", "WorldMap", 7, index, totalCount, "ui.GetFrame('worldmap2_mainmap'):ShowWindow(1)", false);
                    
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_4", "icon_rest_fire", "Rest", "Rest", 2, index, totalCount, "control.RestSit()", false);
                    index = index + 1;
                else
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_1", "sysmenu_sys", "Sysmenu", "Sysmenu", 8, index, totalCount, "JOYSTICKENHANCER_OPEN_SYSMENU()", true);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "sysmenu_inv", "Inventory", "Inventory", 4, index, totalCount, "JOYSTICKENHANCER_OPEN_INVENTORY()", true);
                    index = index + 1;
                    
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_5", "sysmenu_sys", "WorldMap", "WorldMap", 7, index, totalCount, "ui.GetFrame('worldmap2_mainmap'):ShowWindow(1)", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_4", "icon_rest_fire", "Rest", "Rest", 2, index, totalCount, "control.RestSit()", false);
                    index = index + 1;
                
                
                end
            elseif ringCmdType == "PORTAL" then
                local pframe = ui.GetFrame("portal_seller")
                local index = 0;
                local totalCount = 4;
                local groupName = pframe:GetUserValue('GroupName');
                local itemCount = session.autoSeller.GetCount(groupName);
                local sellType = pframe:GetUserIValue('SELL_TYPE');
                
                local handle = pframe:GetUserIValue('HANDLE');
                if itemCount >= 1 then
                    local itemInfo = session.autoSeller.GetByIndex(groupName, index);
                    local propValue = itemInfo:GetArgStr();
                    local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
                    local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
                    
                    -- name
                    local mapName = portalPosList[1];
                    local mapCls = GetClass('Map', mapName);
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_0", "icon_wizar_Portal", mapCls.Name, mapName, 4, index, totalCount,
                        string.format("ACCEPT_PORTAL_OK_BTN(%d, %d, %d)", handle, 0, sellType), false);
                    index = index + 1;
                end
                if itemCount >= 2 then
                    local itemInfo = session.autoSeller.GetByIndex(groupName, index);
                    local propValue = itemInfo:GetArgStr();
                    local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
                    local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
                    
                    -- name
                    local mapName = portalPosList[1];
                    local mapCls = GetClass('Map', mapName);
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_1", "icon_wizar_Portal", mapCls.Name, mapName, 8, index, totalCount, string.format("ACCEPT_PORTAL_OK_BTN(%d, %d, %d)", handle, 1, sellType), false);
                    index = index + 1;
                end
                
                if itemCount >= 3 then
                    local itemInfo = session.autoSeller.GetByIndex(groupName, index);
                    local propValue = itemInfo:GetArgStr();
                    local portalInfoList = StringSplit(propValue, "@"); -- portalPos@openedTime
                    local portalPosList = StringSplit(portalInfoList[1], "#"); -- zoneName#x#y#z
                    
                    -- name
                    local mapName = portalPosList[1];
                    local mapCls = GetClass('Map', mapName);
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "icon_wizar_Portal", mapCls.Name, mapName, 6, index, totalCount, string.format("ACCEPT_PORTAL_OK_BTN(%d, %d, %d)", handle, 2, sellType), true);
                    index = index + 1;
                end
            
            elseif ringCmdType == "COMPANION" then
                
                local index = 0;
                local totalCount = 4;
                
                INSERT_PET_RINGCOMMAND(bg, "RINGCMD_0", "companion_ride", "Alt+Up", ClMsg("Ride"), 8, index, totalCount, "ON_RIDING_VEHICLE(1)", false);
                index = index + 1;
                
                INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "companion_hand", "Alt+1", ClMsg("Stroke"), 2, index, totalCount, "PETCMD_STROKE", false);
                index = index + 1;
                INSERT_PET_RINGCOMMAND(bg, "RINGCMD_3", "companion_eat", "Alt+2", ClMsg("GiveFood"), 6, index, totalCount, "PETCMD_FEEDING", true);
                index = index + 1;
            end
            if handle then
                frame:SetGravity(ui.LEFT, ui.TOP);
                FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2);
            else
                frame:StopUpdateScript('_FRAME_AUTOPOS')
                frame:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT);
                frame:SetMargin(0, 0, 0, 0)
            end
            local timer = frame:CreateOrGetControl('timer', 'joystickenhancer_timer', 0, 0, 10, 10)
            AUTO_CAST(timer)
            timer:SetUpdateScript('JOYSTICKENHANCER_ON_TIMER_RINGCOMMAND')
            timer:Start(0.00)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function INSERT_PET_RINGCOMMAND(bg, name, img, text, toolTipText, angle, index, totalCount, cbFunc, continue)
    
    local cx = bg:GetWidth() / 2;
    local cy = bg:GetHeight() / 2;
    
    local angletable = {
        [8] = {a = 0, k = {["JOY_UP"] = 1, ["JOT_LEFT"] = 0, ["JOT_RIGHT"] = 0}},
        [9] = {a = 45, k = {["JOY_UP"] = 1, ["JOY_RIGHT"] = 1}},
        [6] = {a = 90, k = {["JOY_RIGHT"] = 1, ["JOY_UP"] = 0, ["JOY_DOWN"] = 0}},
        [3] = {a = 135, k = {["JOY_RIGHT"] = 1, ["JOY_DOWN"] = 1}},
        [2] = {a = 180, k = {["JOY_DOWN"] = 1, ["JOT_LEFT"] = 0, ["JOT_RIGHT"] = 0}},
        [1] = {a = 225, k = {["JOY_DOWN"] = 1, ["JOY_LEFT"] = 1}},
        [4] = {a = 270, k = {["JOY_LEFT"] = 1, ["JOY_UP"] = 0, ["JOY_DOWN"] = 0}},
        [7] = {a = 315, k = {["JOY_LEFT"] = 1, ["JOY_UP"] = 1}},
    
    }
    local dangle = DegToRad(angletable[angle].a);
    local radius = 140;
    local addX = math.sin(dangle) * radius;
    local addY = math.cos(dangle) * radius;
    local x = cx + addX;
    local y = cy - addY;
    
    local ctrlSet = bg:CreateControlSet('ringcmd_menu', name, ui.LEFT, ui.TOP, x, y, 0, 0);
    ctrlSet = tolua.cast(ctrlSet, 'ui::CControlSet');
    
    -- �ش� ��Ʈ�Ѽ� ��ư ������ �ش� ��� �����ϱ� ���ؼ� name�� �Լ��� ����� ó����..
    -- ���� ������ �ƴѵ�.. ���� ���� ������ �������� �ʾƼ�.. �������� ���� ����.
    local byFullString = string.find(cbFunc, '%(') ~= nil;
    ctrlSet:SetEventScript(ui.LBUTTONUP, cbFunc, byFullString);
    g.cmdtable[#g.cmdtable + 1] = {
        angletable = angletable[angle],
        func = cbFunc,
        argStr = byFullString,
        continue = continue,
    }
    g.ring_time = 0
    local pic = GET_CHILD(ctrlSet, "pic", "ui::CPicture");
    pic:SetImage(img);
    local textCtrl = ctrlSet:GetChild("text");
    textCtrl:SetTextByKey("text", text);
    ctrlSet:SetTextTooltip(toolTipText);
    return y;
end

function JOYSTICKENHANCER_ON_TIMER_RINGCOMMAND(frame)
    if #g.cmdtable == 0 then
        JOYSTICKENHANCER_HIDE_RINGCOMMAND()
        return
    end
    if imcinput.HotKey.IsDown("Escape") then
        --JOYSTICKENHANCER_HIDE_RINGCOMMAND()
        return
    end
    if g.ring_force and g.ring_target and g.ring_target ~= session.GetMyHandle() then
        local distance = GetDistance(session.GetMyHandle(), g.ring_target);
        if distance > 150 then
            JOYSTICKENHANCER_HIDE_RINGCOMMAND()
            return
        end
    end
    if joystick.IsKeyPressed('JOY_TARGET_CHANGE') == 1 then
        control.EnableControl(0, 0)
        for _, v in ipairs(g.cmdtable) do
            local fail = false
            for kk, vv in pairs(v.angletable.k) do
                if joystick.IsKeyPressed(kk) ~= vv then
                    fail = true
                    break
                end
            end
            if fail == false then
                if g.ring_time < 4 then
                    g.ring_time = g.ring_time + 1
                else
                    if not v.continue then
                        JOYSTICKENHANCER_HIDE_RINGCOMMAND()
                        
                        control.EnableControl(1, 1)
                    end
                    if not pcall(_G[v.func], frame, nil, v.argStr, nil) then
                        pcall(load(v.func))
                    end
                end
            
            end
        
        
        end
    else
        control.EnableControl(1, 1)
    end
end
