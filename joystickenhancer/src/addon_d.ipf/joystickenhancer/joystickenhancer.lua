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
        "quest",
        "decompose_manager",
        "earthtowershop",
        "itembuffrepair",
        "itembuffgemroasting",
        "itemdecompose",
        "itembuff",
        "itemcraft",
        "itemdungeon",
        "indunenter",
        "buffseller_target",
        "market",
        "market_sell",
        "market_cabinet",
        "propertyshop",
        "party",
        "enchantarmor",
        "fishing",
        "adventure_book",
        "appraisal",
        "appraisal_pc",
        "appraisal_forgery",
        "guildinfo",
        "hiddenability_make",
        "induninfo",
        "companion_shop",
        "status",
        "systemoption",
        "select_mgame_buff_solo",
        "select_mgame_buff_party",
        "foodtable_ui",
        "foodtable_register",
        "camp_register",
        "camp_ui",
        "coinshopindunenter"
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
            g.ring_generic_page = nil
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
        if ui.GetFrame(k) then
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
    end
    --scroller
    -- if IsUIMode() then
    --     if joystick.GetDownJoyStickBtn() == "JOY_BTN_6" then
    --         local obj = ui.GetFocusObject();
    --         if obj:GetClassString() == 'ui::CGroupBox' then
    --             AUTO_CAST(obj)
    --             if obj:IsEnableScrollBar() == 1 then
    --                 local curpos = obj:GetScrollCurPos()
    --                 curpos = math.min(obj:GetScrollBarMaxPos(), curpos + obj:GetHeight() / 2)
    --                 obj:SetScrollPos(curpos)
    --             end
    --         end
    --     end
    --     --scroller
    --     if joystick.GetDownJoyStickBtn() == "JOY_BTN_5" then
    --         local obj = ui.GetFocusObject();
    --         if obj:GetClassString() == 'ui::CGroupBox' then
    --             AUTO_CAST(obj)
    --             if obj:IsEnableScrollBar() == 1 then
    --                 local curpos = obj:GetScrollCurPos()
    --                 curpos = math.max(0, curpos - obj:GetHeight() / 2)
    --                 obj:SetScrollPos(curpos)
    --             end
    --         end
    --     end
    -- end
    if joystick.GetDownJoyStickBtn() == 'JOY_TARGET_CHANGE' then
        if joystick.IsKeyPressed('JOY_BTN_6') == 1 then
            g.ring_generic_page = 0
            JOYSTICKENHANCER_SHOW_RINGCOMMAND('GENERIC' .. g.ring_generic_page, session.GetMyHandle())
            return
        end
    end
    local pframe = ui.GetFrame('petcommand')
    if g.ring_generic_page ~= nil and pframe:IsVisible() == 1 then
        if joystick.GetDownJoyStickBtn() == 'JOY_BTN_5' then
            g.ring_generic_page = g.ring_generic_page - 1
        elseif joystick.GetDownJoyStickBtn() == 'JOY_BTN_6' then
            g.ring_generic_page = g.ring_generic_page + 1
        else
            return
        end
        g.ring_generic_page = math.max(-2, math.min(3, g.ring_generic_page))
        JOYSTICKENHANCER_SHOW_RINGCOMMAND('GENERIC' .. g.ring_generic_page, session.GetMyHandle())
    end


end


--for ring command
function JOYSTICKENHANCER_PORTAL_SELLER_OPEN_UI(groupName, sellType, handle)
    PORTAL_SELLER_OPEN_UI_OLD(groupName, sellType, handle)
    g.ring_force = false
    ReserveScript('JOYSTICKENHANCER_SHOW_RINGCOMMAND("PORTAL",' .. handle .. ')', 0.01)
end
function JOYSTICKENHANCER_SHOW_RINGCOMMAND(typeStr, handle)
    local frame = ui.GetFrame('petcommand')
    frame:ShowWindow(1)
    if typeStr then
        
        g.ring_force = true
        g.ring_target = handle
        
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
    if not IsUIMode() then
        SetKeyboardSelectMode(1)
    end
    g.ring_sysmenu = true
end
function JOYSTICKENHANCER_OPEN_INVENTORY()
    SetMousePos_Fixed(GetScreenWidth() - 40, GetScreenHeight() / 2)
    if not IsUIMode() then
        
        SetKeyboardSelectMode(1)
    end
    g.ring_sysmenu = true
    ui.GetFrame('inventory'):ShowWindow(1)
end
function JOYSTICKENHANCER_USE_ITEM_BY_CLSID(clsid)
    local invItem = session.GetInvItemByType(clsid)
    
    if invItem == nil then
        local cls = GetClassByType("item", clsid)
        ui.SysMsg('You don\'t have ' .. cls.Name)
        imcSound.PlaySoundEvent("skill_cooltime");
        return
    end
    if TRY_TO_USE_WARP_ITEM(invItem, GetIES(invItem:GetObject())) == 0 then
        INV_ICON_USE(invItem)
    end
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
    g.ring_generic_page = nil
end
function JOYSTICKENHANCER_TOGGLE_PET()
    if ui.GetFrame('pet_info'):IsVisible()==0 then
        ui.GetFrame('pet_info'):ShowWindow(1)
        COMPANION_UI_OPEN_DO(ui.GetFrame('pet_info'))
        ReserveScript("TOGGLE_PET_ACTIVITY(ui.GetFrame('pet_info'):GetChildRecursively('bg'),ui.GetFrame('pet_info'):GetChildRecursively('activate'))",0.5)
        ReserveScript("ui.GetFrame('pet_info'):ShowWindow(0)",1)
    else
        TOGGLE_PET_ACTIVITY(ui.GetFrame('pet_info'):GetChildRecursively('bg'),ui.GetFrame('pet_info'):GetChildRecursively('activate'))
       
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
            frame:SetLayerLevel(85)
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
            g.ring_target = handle
            if ringCmdType == "GENERIC0" then
                local index = 0;
                local totalCount = 4;
                
                if IsBuffApplied(GetMyPCObject(), "RidingCompanion") == "YES" then
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_1", "companion_down", "Dismount", ClMsg("Unride"), 2, index, totalCount, "ON_RIDING_VEHICLE(0)", false);
                    index = index + 1;
                    
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "sysmenu_sys", "Sysmenu", "Sysmenu", 8, index, totalCount, "JOYSTICKENHANCER_OPEN_SYSMENU()", true);
                    
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_4", "sysmenu_inv", "Inventory", "Inventory", 4, index, totalCount, "JOYSTICKENHANCER_OPEN_INVENTORY()", true);
                    
                    index = index + 1;
                    
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_5", "sysmenu_sys", "LocalMap", "LocalMap", 7, index, totalCount, "ui.GetFrame('map'):ShowWindow(1)", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_6", "sysmenu_party", "Party", "Party", 6, index, totalCount, "ui.ToggleFrame('party')", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_7", "sysmenu_qu", "Quest", "Quest", 1, index, totalCount, "ui.ToggleFrame('quest')", false);
                    index = index + 1;
                else
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_1", "sysmenu_sys", "Sysmenu", "Sysmenu", 8, index, totalCount, "JOYSTICKENHANCER_OPEN_SYSMENU()", true);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "sysmenu_inv", "Inventory", "Inventory", 4, index, totalCount, "JOYSTICKENHANCER_OPEN_INVENTORY()", true);
                    index = index + 1;
                    
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_5", "sysmenu_sys", "LocalMap", "LocalMap", 7, index, totalCount, "ui.GetFrame('map'):ShowWindow(1)", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_4", "icon_rest_fire", "Rest", "Rest", 2, index, totalCount, "control.RestSit()", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_6", "sysmenu_party", "Party", "Party", 6, index, totalCount, "ui.ToggleFrame('party')", false);
                    index = index + 1;
                    INSERT_PET_RINGCOMMAND(bg, "RINGCMD_7", "sysmenu_qu", "Quest", "Quest", 1, index, totalCount, "ui.ToggleFrame('quest')", false);
                    index = index + 1;
                
                end
            elseif ringCmdType == "GENERIC1" then
                
                
                INSERT_PET_RINGCOMMAND(bg, '1', "sysmenu_sys", "WorldMap", "WorldMap", 8, nil, nil, "ui.ToggleFrame('worldmap2_mainmap')", false);
                INSERT_PET_RINGCOMMAND(bg, "2", "pvpmine_shop_btn", "CoinShop", "CoinShop", 9, nil, nil, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK(nil,nil)", false);
                INSERT_PET_RINGCOMMAND(bg, "3", "sysmenu_skill", "Skill", "Skill", 6, nil, nil, "ui.ToggleFrame('skillability')", false);
                INSERT_PET_RINGCOMMAND(bg, "4", "sysmenu_guild", "Guild", "Guild", 2, nil, nil, "ui.ToggleFrame('guildinfo')", false);
                INSERT_PET_RINGCOMMAND(bg, "5", "sysmenu_my", "Status", "Status", 4, nil, nil, "ui.ToggleFrame('status')", false);
                INSERT_PET_RINGCOMMAND(bg, "6", "sysmenu_instantDungeon", "Contents", "Contents", 3, nil, nil, "UI_TOGGLE_INDUN", false);
            
                INSERT_PET_RINGCOMMAND(bg, "7", "sysmenu_jal", "Journal", "Journal", 1, nil, nil, "ui.ToggleFrame('adventure_book')", false);
                INSERT_PET_RINGCOMMAND(bg, '8', "sysmenu_pet", "Tgl Pet", "Tgl pet", 7, nil, nil, "JOYSTICKENHANCER_TOGGLE_PET()", false);
            
            
            elseif ringCmdType == "GENERIC2" then
                
                
                INSERT_PET_RINGCOMMAND(bg, '1', "mercenarybadge", "WarpStone", "WarpStone", 8, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(650012)", false);
                INSERT_PET_RINGCOMMAND(bg, '2', "mercenarybadge_leaf", "Klaipeda", "Klaipeda", 9, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(661221)", false);
                INSERT_PET_RINGCOMMAND(bg, '3', "mercenarybadge_orange", "Orsha", "Orsha", 7, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(661222)", false);
                INSERT_PET_RINGCOMMAND(bg, '4', "golemmagicitem1", "Klaipeda", "Klaipeda", 3, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(640073)", false);
                INSERT_PET_RINGCOMMAND(bg, '5', "golemmagicitem1", "Orsha", "Orsha", 1, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(640156)", false);
                INSERT_PET_RINGCOMMAND(bg, '6', "golemmagicitem1", "Fedimian", "Fedimian", 2, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(640182)", false);
                INSERT_PET_RINGCOMMAND(bg, '7', "icon_item_warppremium", "Scroll", "Scroll", 4, nil, nil, "JOYSTICKENHANCER_USE_ITEM_BY_CLSID(490006)", false);
                
            elseif ringCmdType == "GENERIC3" then
                
                
                INSERT_PET_RINGCOMMAND(bg, '1', "time_1", "Ch 1", "Change to Ch 1", 8, nil, nil, "CHAT_SYSTEM('Change to Ch 1');RUN_GAMEEXIT_TIMER('Channel',0)", false);
                INSERT_PET_RINGCOMMAND(bg, '2', "time_2", "Ch 2", "Change to Ch 2", 9, nil, nil, "CHAT_SYSTEM('Change to Ch 2');RUN_GAMEEXIT_TIMER('Channel',1)", false);
                INSERT_PET_RINGCOMMAND(bg, '3', "time_3", "Ch 3", "Change to Ch 3", 6, nil, nil, "CHAT_SYSTEM('Change to Ch 3');RUN_GAMEEXIT_TIMER('Channel',2)", false);
                INSERT_PET_RINGCOMMAND(bg, '4', "time_4", "Ch 4", "Change to Ch 4", 3, nil, nil, "CHAT_SYSTEM('Change to Ch 4');RUN_GAMEEXIT_TIMER('Channel',3)", false);
                INSERT_PET_RINGCOMMAND(bg, '5', "time_5", "Ch 5", "Change to Ch 5", 2, nil, nil, "CHAT_SYSTEM('Change to Ch 5');RUN_GAMEEXIT_TIMER('Channel',4)", false);
                INSERT_PET_RINGCOMMAND(bg, '6', "time_6", "Ch 6", "Change to Ch 6", 1, nil, nil, "CHAT_SYSTEM('Change to Ch 6');RUN_GAMEEXIT_TIMER('Channel',5)", false);
                INSERT_PET_RINGCOMMAND(bg, '7', "time_7", "Ch 7", "Change to Ch 7", 4, nil, nil, "CHAT_SYSTEM('Change to Ch 7');RUN_GAMEEXIT_TIMER('Channel',6)", false);
                INSERT_PET_RINGCOMMAND(bg, '8', "time_8", "Ch 8", "Change to Ch 8", 7, nil, nil, "CHAT_SYSTEM('Change to Ch 8');RUN_GAMEEXIT_TIMER('Channel',7)", false);
                
                
            
            
            
            elseif ringCmdType == "GENERIC-1" then
                
                
                INSERT_PET_RINGCOMMAND(bg, '1', "button_chat_normal_clicked", "ChatWnd", "ChatWnd", 8, nil, nil, "ui.GetFrame('chatframe'):ShowWindow(1)", false);
                
                INSERT_PET_RINGCOMMAND(bg, '2', "barrack_button_normal", "CC", "CC", 2, nil, nil, "APPS_TRY_MOVE_BARRACK", false);
                INSERT_PET_RINGCOMMAND(bg, '3', "config_button_normal", "Settings", "Settings", 4, nil, nil, "ui.ToggleFrame('systemoption')", false);
               
            
            
            elseif ringCmdType == "GENERIC-2" then
                
                INSERT_PET_RINGCOMMAND(bg, '1', "key_1", "Macro1", "Macro1", 8, nil, nil, "EXEC_CHATMACRO(1)", false);
                INSERT_PET_RINGCOMMAND(bg, '2', "key_2", "Macro2", "Macro2", 9, nil, nil, "EXEC_CHATMACRO(2)", false);
                INSERT_PET_RINGCOMMAND(bg, '3', "key_3", "Macro3", "Macro3", 6, nil, nil, "EXEC_CHATMACRO(3)", false);
                INSERT_PET_RINGCOMMAND(bg, '4', "key_4", "Macro4", "Macro4", 3, nil, nil, "EXEC_CHATMACRO(4)", false);
                INSERT_PET_RINGCOMMAND(bg, '5', "key_5", "Macro5", "Macro5", 2, nil, nil, "EXEC_CHATMACRO(5)", false);
                INSERT_PET_RINGCOMMAND(bg, '6', "key_6", "Macro6", "Macro6", 1, nil, nil, "EXEC_CHATMACRO(6)", false);
                INSERT_PET_RINGCOMMAND(bg, '7', "key_7", "Macro7", "Macro7", 4, nil, nil, "EXEC_CHATMACRO(7)", false);
                INSERT_PET_RINGCOMMAND(bg, '8', "key_8", "Macro8", "Macro8", 7, nil, nil, "EXEC_CHATMACRO(8)", false);
            
            
            
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
                
                INSERT_PET_RINGCOMMAND(bg, "RINGCMD_0", "companion_ride", "Ride", ClMsg("Ride"), 8, index, totalCount, "ON_RIDING_VEHICLE(1)", false);
                index = index + 1;
                
                INSERT_PET_RINGCOMMAND(bg, "RINGCMD_2", "companion_hand", "Stroke", ClMsg("Stroke"), 2, index, totalCount, "PETCMD_STROKE", false);
                index = index + 1;
                INSERT_PET_RINGCOMMAND(bg, "RINGCMD_3", "companion_eat", "Feed", ClMsg("GiveFood"), 6, index, totalCount, "PETCMD_FEEDING", true);
                index = index + 1;
            else
                --abort
                ERROUT("no defined ring command")
                JOYSTICKENHANCER_HIDE_RINGCOMMAND()
                return
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
        [8] = {a = 0, k = {["JOY_UP"] = 1, ["JOY_LEFT"] = 0, ["JOY_RIGHT"] = 0}},
        [9] = {a = 45, k = {["JOY_UP"] = 1, ["JOY_RIGHT"] = 1}},
        [6] = {a = 90, k = {["JOY_RIGHT"] = 1, ["JOY_UP"] = 0, ["JOY_DOWN"] = 0}},
        [3] = {a = 135, k = {["JOY_RIGHT"] = 1, ["JOY_DOWN"] = 1}},
        [2] = {a = 180, k = {["JOY_DOWN"] = 1, ["JOY_LEFT"] = 0, ["JOY_RIGHT"] = 0}},
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
    -- if g.ring_force == false and g.ring_target and g.ring_target ~= session.GetMyHandle() then
    --     local distance = GetDistance(session.GetMyHandle(), g.ring_target);
    --     if distance > 150 then
    --         JOYSTICKENHANCER_HIDE_RINGCOMMAND()
    --         return
    --     end
    -- end
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
                local checker = {"JOY_UP", "JOY_DOWN", "JOY_RIGHT", "JOY_LEFT"}
                local keys = ''
                for _, vv in ipairs(checker) do
                    if joystick.IsKeyPressed(vv) == 1 then
                        keys = keys .. vv .. ","
                    end
                
                end
                g.ring_watchkeys = g.ring_watchkeys or ''
                if g.ring_watchkeys ~= keys then
                    g.ring_time = 0
                    g.ring_watchkeys = keys
                    return
                end
                
                if g.ring_time < 12 then
                    g.ring_time = g.ring_time + 1
                else
                    if not v.continue then
                        g.ring_time = 0
                        JOYSTICKENHANCER_HIDE_RINGCOMMAND()
                        
                        control.EnableControl(1, 1)
                    end
                    if not pcall(_G[v.func], frame, nil, v.argStr, nil) then
                        pcall(load(v.func))
                    end
                    return
                end
            
            end
        
        
        end
    else
        g.ring_watchkeys = nil
        control.EnableControl(1, 1)
    end
end
