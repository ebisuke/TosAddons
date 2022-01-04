--ITEMBUFFMACHINE
local addonName = "ITEMBUFFMACHINE"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"
local contributor = "Kiicchan"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}

local g = _G["ADDONS"][author][addonName]

local hik = _G["ADDONS"][author]["HIDEINACCESSIBLEKITCHEN"]
local acutil = require("acutil")
local BUFFSHOP_TYPE = {
    Squire_Repair = 1,
    Squire_Maintainance = 2,
    Enchanter_EnchantArmor = 3,
    Pardoner_SpellBuff = 4,
    Alchemist_Roasting = 5,
    Squire_Kitchen = 6
}
local BUFFSHOP_MODE = {
    Squire_Repair_All = 11,
    Squire_Repair_Damaged = 12,
    Squire_Repair_BuffOnly = 13,
    Squire_Maintainance_All = 21,
    Squire_Maintainance_Weapons = 22,
    Pardoner_SpellBuff_All = 41,
    Pardoner_SpellBuff_AttackBuff = 42,
    Pardoner_SpellBuff_DefenseBuff = 43,
    Squire_Kitchen_All_Overwrite = 61,
    Squire_Kitchen_All_DontOverwrite = 62
}
g.version = 0
g.settings =
    g.settings or
    {
        x = 300,
        y = 300,
        style = 0
    }
g.configurepattern = {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "itembuffmachine"
g.debug = false

g.addon = g.addon
g.items = {}
g.itemcursor = 1
g.issquire = false
g.working = false
g.squirewaitfornext = false
g.enchantname = nil
--ライブラリ読み込み
CHAT_SYSTEM("[IBM]loaded")
local acutil = require("acutil")
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
local function ebi_hook(newFunction, hookedFunctionStr)
    local storeOldFunc = hookedFunctionStr .. "_OLD_IBM"
    if _G[storeOldFunc] == nil then
        _G[storeOldFunc] = _G[hookedFunctionStr]
        _G[hookedFunctionStr] = newFunction
    else
        _G[hookedFunctionStr] = newFunction
    end
end

local function DBGOUT(msg)
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function ITEMBUFFMACHINE_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            frame:Resize(200, 24)
            frame:SetLayerLevel(60)
            frame:EnableHitTest(0)
            frame:EnableHittestFrame(0)
            frame:EnableMove(0)
            local text = frame:CreateOrGetControl("richtext", "text", 0, 0, 200, 16)
            text:SetText("{ol}Buff Machine Time Remain")
            local gg = frame:CreateOrGetControl("gauge", "gauge", 0, 16, 200, 8)
            AUTO_CAST(gg)

            FRAME_AUTO_POS_TO_OBJ(frame, session.GetMyHandle(), -100, -200, 1, 1, 1)
            if not g.loaded then
                g.loaded = true
            end
            --if(g.debug)then
            ebi_hook(ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN, "ENCHANTAROR_STORE_OPEN")
            ebi_hook(ITEMBUFFMACHINE_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
            --end
            local timer = frame:GetChild("addontimer")
            AUTO_CAST(timer)
            ebi_hook(ITEMBUFFMACHINE_SQUIRE_ITEM_SUCCEED, "SQUIRE_ITEM_SUCCEED")
            --ebi_hook(ITEMBUFFMACHINE_TARGET_AUTOSELL_LIST, 'TARGET_AUTOSELL_LIST')
            ebi_hook(ITEMBUFFMACHINE_OPEN_ITEMBUFF_UI_COMMON, "OPEN_ITEMBUFF_UI_COMMON")
            ebi_hook(ITEMBUFFMACHINE_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")
            ebi_hook(ITEMBUFFMACHINE_OPEN_FOOD_TABLE_UI, "OPEN_FOOD_TABLE_UI")

            --addon:RegisterMsg("OPEN_FOOD_TABLE_UI", "ITEMBUFFMACHINE_OPEN_FOOD_TABLE_UI")
            addon:RegisterMsg("EQUIP_ITEM_LIST_UPDATE", "ITEMBUFFMACHINE_EQUIP_ITEM_LIST")
            addon:RegisterMsg("GAME_START_3SEC", "ITEMBUFFMACHINE_ITEMBUFFOPEN_INIT")
            addon:RegisterMsg("FPS_UPDATE", "ITEMBUFFMACHINE_FPS_UPDATE")
            g.squirewaitfornext = false
            frame:ShowWindow(0)
            g.eatignore = false
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_REPAIR_UI_COMMON(groupName, sellType, handle)
    ITEMBUFF_REPAIR_UI_COMMON_OLD_IBM(groupName, sellType, handle)
    ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Squire_Repair)
end
function ITEMBUFFMACHINE_OPEN_FOOD_TABLE_UI(groupName, sellType, handle, sellerCID, arg_num)
    OPEN_FOOD_TABLE_UI_OLD_IBM(groupName, sellType, handle, sellerCID, arg_num)
    local actor = world.GetActor(handle)
    local apc = actor:GetPCApc()
    local aid=apc:GetAID()
    if arg_num == 0 then
        DBGOUT("PARTY ONLY")

        local actor = world.GetActor(handle)
        local apc = actor:GetPCApc()
        local fname = apc:GetFamilyName()
        local info = session.party.GetPartyMemberInfoByName(PARTY_NORMAL, fname)

        if info == nil and session.loginInfo.GetAID()~= aid  then
            return
        end
    end
    if arg_num == 1 then
        DBGOUT("GUILD ONLY")

        local actor = world.GetActor(handle)
        local apc = actor:GetPCApc()
        local fname = apc:GetFamilyName()
        local info = session.party.GetPartyMemberInfoByName(PARTY_GUILD, fname)

        if info == nil and session.loginInfo.GetAID()~= aid  then
            return
        end
    end
    if hik.intrudes[handle] == 1 then
        return
    end
    if hik.intrudes[handle] == 2 then
        hik.intrudes[handle] = 3
        return
    end
    if not g.eatignore then
        ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Squire_Kitchen)
    else
        g.eatignore=false
    end
end
function ITEMBUFFMACHINE_OPEN_ITEMBUFF_UI_COMMON(groupName, sellType, handle);
    OPEN_ITEMBUFF_UI_COMMON_OLD_IBM(groupName, sellType, handle);
    --if open:GetName() == "itembuffopen" then

    ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Squire_Maintainance)
    --else
    --ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Squire_Repair)
    --end
end
function ITEMBUFFMACHINE_FPS_UPDATE()
    --local frame = ui.GetFrame(g.framename)
    --frame:ShowWindow(1)
end
function ITEMBUFFMACHINE_CHECK_BUTTON(buffType)
    EBI_try_catch {
        try = function()
            local gg = g.frame:GetChild("gauge")
            AUTO_CAST(gg)
            g.buffType = buffType
            g.remainTime = 250
            ui.SetEscapeScp("ITEMBUFFMACHINE_CANCEL_DO_BUTTON()")
            local timer = g.frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:Stop()

            ReserveScript("ITEMBUFFMACHINE_START_TIMER('ITEMBUFFMACHINE_DO_CHECK_BUTTON')", 0.01)
            g.frame:ShowWindow(1)
            gg:SetMaxPoint(250)
            gg:SetCurPoint(g.remainTime)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_DO_CHECK_BUTTON()
    local buffType = g.buffType
    local gg = g.frame:GetChild("gauge")
    AUTO_CAST(gg)
    g.remainTime = g.remainTime - 1
    gg:SetCurPoint(g.remainTime)
    if g.remainTime < 0 then
        local timer = g.frame:GetChild("addontimer")
        timer:Stop()
        g.frame:ShowWindow(0)
        ui.SetEscapeScp("")
    end
    if
        joystick.IsKeyPressed("JOY_TARGET_CHANGE") == 0 and keyboard.IsKeyPressed("LSHIFT") == 0 and
            keyboard.IsKeyPressed("RSHIFT") == 0
     then
        return
    end

    if buffType == BUFFSHOP_TYPE.Squire_Repair then
        if keyboard.IsKeyPressed("UP") == 1 or joystick.IsKeyPressed("JOY_UP") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Repair_All)
        elseif keyboard.IsKeyPressed("LEFT") == 1 or joystick.IsKeyPressed("JOY_LEFT") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Repair_Damaged)
       
        elseif keyboard.IsKeyPressed("RIGHT") == 1 or joystick.IsKeyPressed("JOY_RIGHT") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Repair_BuffOnly)

        end
    elseif buffType == BUFFSHOP_TYPE.Squire_Maintainance then
        if keyboard.IsKeyPressed("UP") == 1 or joystick.IsKeyPressed("JOY_UP") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Maintainance_All)
        elseif keyboard.IsKeyPressed("LEFT") == 1 or joystick.IsKeyPressed("JOY_LEFT") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Maintainance_Weapons)
        end
    elseif buffType == BUFFSHOP_TYPE.Enchanter_EnchantArmor then
    elseif buffType == BUFFSHOP_TYPE.Pardoner_SpellBuff then
        if keyboard.IsKeyPressed("UP") == 1 or joystick.IsKeyPressed("JOY_UP") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Pardoner_SpellBuff_All)
        elseif keyboard.IsKeyPressed("LEFT") == 1 or joystick.IsKeyPressed("JOY_LEFT") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Pardoner_SpellBuff_AttackBuff)
        elseif keyboard.IsKeyPressed("RIGHT") == 1 or joystick.IsKeyPressed("JOY_RIGHT") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Pardoner_SpellBuff_DefenseBuff)
        end
    elseif buffType == BUFFSHOP_TYPE.Alchemist_Roasting then
    elseif buffType == BUFFSHOP_TYPE.Squire_Kitchen then
        if keyboard.IsKeyPressed("UP") == 1 or joystick.IsKeyPressed("JOY_UP") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Kitchen_All_Overwrite)
        elseif keyboard.IsKeyPressed("LEFT") == 1 or joystick.IsKeyPressed("JOY_LEFT") == 1 then
            ITEMBUFFMACHINE_MSG_BUTTON(BUFFSHOP_MODE.Squire_Kitchen_All_DontOverwrite)
        end
    end
end
function ITEMBUFFMACHINE_MSG_BUTTON(mode)
    local msgs = {
        [BUFFSHOP_MODE.Pardoner_SpellBuff_All] = "Purchasing {b}[ALL]{/} buffs.",
        [BUFFSHOP_MODE.Pardoner_SpellBuff_AttackBuff] = "Purchasing {b}[ATTACK]{/} buffs.",
        [BUFFSHOP_MODE.Pardoner_SpellBuff_DefenseBuff] = "Purchasing {b}[DEFENSE]{/} buffs.",
        [BUFFSHOP_MODE.Squire_Kitchen_All_DontOverwrite] = "Eating foods.{b}[NOT OVERWRITE]{/}",
        [BUFFSHOP_MODE.Squire_Kitchen_All_Overwrite] = "Eating kitchen foods.{b}[OVERWRITE]{/}",
        [BUFFSHOP_MODE.Squire_Maintainance_All] = "Maintanancing {b}[ALL]{/} equipments.",
        [BUFFSHOP_MODE.Squire_Maintainance_Weapons] = "Maintanance {b}[WEAPONS]{/}.",
        [BUFFSHOP_MODE.Squire_Repair_All] = "Repairing {b}[ALL]{/} equipments.",
        [BUFFSHOP_MODE.Squire_Repair_Damaged] = "Repairing {b}[DAMAGED]{/} equipments.",
        [BUFFSHOP_MODE.Squire_Repair_BuffOnly] = "Repairing for {b}[APPLY BUFF]{/}.(Repair the cheapest equipment.)"
    }
    ui.SysMsg(msgs[mode] .. "{nl}{b}Press ESC key to cancel.")
    local frame = ui.GetFrame(g.framename)
    local timer = frame:GetChild("addontimer")
    timer:Stop()
    AUTO_CAST(timer)
    g.keymode = mode
    g.remainTime = 120
    ui.SetEscapeScp("ITEMBUFFMACHINE_CANCEL_DO_BUTTON()")
    ReserveScript("ITEMBUFFMACHINE_START_TIMER('ITEMBUFFMACHINE_DO_BUTTON')", 0.01)
    local gg = g.frame:GetChild("gauge")
    gg:SetMaxPoint(120)
    g.frame:ShowWindow(1)
end

function ITEMBUFFMACHINE_START_TIMER(funcname)
    local frame = ui.GetFrame(g.framename)
    local timer = frame:GetChild("addontimer")
    timer:Stop()
    timer:SetUpdateScript(funcname)
    timer:Start(0.01)
end
function ITEMBUFFMACHINE_DO_BUTTON()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            local timer = frame:GetChild("addontimer")
            AUTO_CAST(timer)

            local mode = g.keymode
            local gg = g.frame:GetChild("gauge")
            AUTO_CAST(gg)
            g.remainTime = g.remainTime - 1
            gg:SetCurPoint(g.remainTime)
            --g.frame:ShowWindow(1)
            if g.remainTime < 0 then
                local timer = g.frame:GetChild("addontimer")
                timer:Stop()
                g.frame:ShowWindow(0)
                ui.SetEscapeScp("")

                if
                    mode == BUFFSHOP_MODE.Pardoner_SpellBuff_All or mode == BUFFSHOP_MODE.Pardoner_SpellBuff_AttackBuff or
                        mode == BUFFSHOP_MODE.Pardoner_SpellBuff_DefenseBuff
                 then
                    local frame = ui.GetFrame("personal_shop_target")
                    -- if frame:IsVisible()==1 then
                    frame = ui.GetFrame("buffseller_target")
                    -- end

                    --frame:ShowWindow(1);

                    local handle = frame:GetUserIValue("HANDLE")
                    local groupName = frame:GetUserValue("GROUPNAME")
                    local sellType = frame:GetUserIValue("SELLTYPE")
                    local ctrlsetType = "buffseller_target"
                    local titleName = session.autoSeller.GetTitle(groupName)

                    local cnt = session.autoSeller.GetCount(groupName)
                    local inc = 0
                    for i = 0, cnt - 1 do
                        local info = session.autoSeller.GetByIndex(groupName, i)
                        if
                            mode == BUFFSHOP_MODE.Pardoner_SpellBuff_All or
                                mode == BUFFSHOP_MODE.Pardoner_SpellBuff_AttackBuff and
                                    (info.classID == 359 or info.classID == 358) or
                                mode == BUFFSHOP_MODE.Pardoner_SpellBuff_DefenseBuff and
                                    (info.classID == 360 or info.classID == 370)
                         then
                            ReserveScript(
                                string.format(
                                    "ITEMBUFFMACHINE_BUY_BUFF(%d,%d,%d,%d)",
                                    handle,
                                    i,
                                    info.classID,
                                    sellType
                                ),
                                inc * 0.5
                            )
                            inc = inc + 1
                        end
                    end
                    ReserveScript('ui.CloseFrame("buffseller_target")', inc * 0.5)
                    inc = inc + 1
                elseif
                    mode == BUFFSHOP_MODE.Squire_Kitchen_All_DontOverwrite or
                        mode == BUFFSHOP_MODE.Squire_Kitchen_All_Overwrite
                 then
                    frame = ui.GetFrame("foodtable_ui")
                    local groupName = frame:GetUserValue("GroupName")
                    local cnt = session.autoSeller.GetCount(groupName)
                    local inc = 0
                    local handle = frame:GetUserIValue("HANDLE")
                    local self = GetMyActor()
                    local actor = world.GetActor(handle)
                    local pos = actor:GetPos()
                    local dist = info.GetDestPosDistance(pos.x, pos.y, pos.z, session.GetMyHandle());
                    if dist>30 then
                        ui.SysMsg("Please more closer to the table.")
                        return
                    end
                    
                    for i = 0, cnt - 1 do
                        local inf = session.autoSeller.GetByIndex(groupName, i)

                        
                        local sellType = frame:GetUserIValue("SELLTYPE")
                        local bufftable = {
                            [1] = 4022,
                            [2] = 4023,
                            [3] = 4024,
                            [4] = 4021,
                            [5] = 4087,
                            [6] = 4136
                        }
                       
                        local buffid = bufftable[inf.classID]
                        local meshi = info.GetBuff(session.GetMyHandle(), buffid)
                        if meshi then
                            if mode == BUFFSHOP_MODE.Squire_Kitchen_All_DontOverwrite then
                                --pass
                            else
                                ReserveScript(string.format(" packet.ReqRemoveBuff(%d)", buffid), inc * 0.5)
                                inc = inc + 1
                                ReserveScript(string.format("ITEMBUFFMACHINE_EAT(%d)", i), inc * 0.5)
                                inc = inc + 1
                            end
                        else
                            ReserveScript(string.format("ITEMBUFFMACHINE_EAT(%d)", i), inc * 0.5)
                            inc = inc + 1
                        end
                    end
                    ReserveScript("ui.CloseFrame('foodtable_ui')", inc * 0.5)
                    inc = inc + 1
                elseif mode == BUFFSHOP_MODE.Squire_Maintainance_All then
                    ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT(1)
                    
                elseif mode == BUFFSHOP_MODE.Squire_Maintainance_Weapons then
                    ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT(0)
                elseif mode == BUFFSHOP_MODE.Squire_Repair_All then
                    ITEMBUFFMACHINE_ITEMREPAIR_SelectItem(true, 99999)
                    ui.CloseFrame("itembuffrepair")
                elseif mode == BUFFSHOP_MODE.Squire_Repair_Damaged then
                    local durthres = 7
                    if _G["ADDONS"]["TOUKIBI"]["ShopHelper"] then
                        local toukibi = _G["ADDONS"]["TOUKIBI"]["ShopHelper"]
                        durthres = toukibi.ComLib:GetValueOrDefault(toukibi.Settings.Repair_DurValue, 3, false)
                    end
                    ITEMBUFFMACHINE_ITEMREPAIR_SelectItem(true, durthres)
                    ui.CloseFrame("itembuffrepair")
                elseif mode == BUFFSHOP_MODE.Squire_Repair_BuffOnly then
                    EBI_try_catch {
                        try = function()
                            local frame = ui.GetFrame("itembuffrepair")
                            ITEMBUFFMACHINE_ITEMREPAIR_SelectItemCheapest()
                            ui.CloseFrame("itembuffrepair")
                        end,
                        catch = function(error)
                            ERROUT(error)
                        end
                    }
                end
                g.keymode = 0
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

-- from toukibi's ShopHelper
function ITEMBUFFMACHINE_ITEMREPAIR_SelectItem(OnlyEquip, DurValue)
    DurValue = DurValue or 1000;
    OnlyEquip = OnlyEquip or false;
    local TopParent = ui.GetFrame("itembuffrepair");
    if TopParent == nil or TopParent:IsVisible() == 0 then return end
    -- スロットの中身を調べる
    local slotSet = GET_CHILD_RECURSIVELY(TopParent, "slotlist", "ui::CSlotSet")
    local slotCount = slotSet:GetSlotCount();
    local isselected = TopParent:GetUserValue("SELECTED");
    -- 一度選択を解除する
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        if slot:GetIcon() ~= nil then
            slot:Select(0)
        end
    end
    
    local bolFound = false;
    local equipList = session.GetEquipItemList();
    local totalcont = 0;
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        if slot:GetIcon() ~= nil then
            if (OnlyEquip and isselected == "SelectedEquiped") or (not OnlyEquip and isselected == "SelectedAll") then
                slot:Select(0)
            else
                local IsMatch = not OnlyEquip
                if not IsMatch then
                    for i = 0, equipList:Count() - 1 do
                        local equipItem = equipList:GetEquipItemByIndex(i);
                        if equipItem:GetIESID() == slot:GetIcon():GetInfo():GetIESID() then
                            IsMatch = true;
                            break;
                        end
                    end
                end
                if IsMatch then
                    local Icon = slot:GetIcon();
                    local iconInfo = Icon:GetInfo();
                    local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID());
                    local itemobj = GetIES(invitem:GetObject());
                    local needItem, needCount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj);
                    if itemobj.MaxDur * DurValue > itemobj.Dur * 10 then
                        slot:Select(1)
                        totalcont = totalcont + needCount;
                        bolFound = true;
                    end
                end
            end
        end
    end
    slotSet:MakeSelectionList();
 
    if bolFound then
        TopParent:SetUserValue("SELECTED", "SelectedAll");
    else
        TopParent:SetUserValue("SELECTED", "NotSelected");
    end
    ReserveScript("ITEMBUFFMACHINE_EXECUTE_REPAIR140731()",0.1)
    return totalcont
end

function ITEMBUFFMACHINE_ITEMREPAIR_SelectItemCheapest()
    DurValue = DurValue or 1000;
    OnlyEquip = OnlyEquip or false;
    local TopParent = ui.GetFrame("itembuffrepair");
    if TopParent == nil or TopParent:IsVisible() == 0 then return end
    -- スロットの中身を調べる
    local slotSet = GET_CHILD_RECURSIVELY(TopParent, "slotlist", "ui::CSlotSet")
    local slotCount = slotSet:GetSlotCount();
    local isselected = TopParent:GetUserValue("SELECTED");
    -- 一度選択を解除する
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        if slot:GetIcon() ~= nil then
            slot:Select(0)
        end
    end
    
    local bolFound = false;
    local equipList = session.GetEquipItemList();
    local totalcont = 0;
    local price=999999999999;
    local cheapestslot=nil
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        if slot:GetIcon() ~= nil then
            slot:Select(0)
      
            for i = 0, equipList:Count() - 1 do
                local equipItem = equipList:GetEquipItemByIndex(i);
                if equipItem:GetIESID() == slot:GetIcon():GetInfo():GetIESID() then
                    IsMatch = true;
                    break;
                end
            end

            local Icon = slot:GetIcon();
            local iconInfo = Icon:GetInfo();
            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID());
            local itemobj = GetIES(invitem:GetObject());
            local needItem, needCount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj);
            if itemobj.MaxDur * DurValue > itemobj.Dur * 10 then
        
                if price>needCount then
                    price=needCount;
                    cheapestslot=slot
                end
            
            end
            
        end
    end
    if cheapestslot==nil then
        return
        
    end
    cheapestslot:Select(1)
    slotSet:MakeSelectionList();
    

    if bolFound then
        TopParent:SetUserValue("SELECTED", "SelectedAll");
    else
        TopParent:SetUserValue("SELECTED", "NotSelected");
    end
    
    ReserveScript("ITEMBUFFMACHINE_EXECUTE_REPAIR140731()",0.1)
end
function ITEMBUFFMACHINE_EXECUTE_REPAIR140731()
    local frame=ui.GetFrame("itembuffrepair")
	session.ResetItemList();

	local totalprice = 0;

	local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
	
	if slotSet:GetSelectedSlotCount() < 1 then
		--ui.MsgBox(ScpArgMsg("SelectRepairItemPlz"))
		return;
	end

	for i = 0, slotSet:GetSelectedSlotCount() -1 do
		local slot = slotSet:GetSelectedSlot(i)
		local Icon = slot:GetIcon();
		local iconInfo = Icon:GetInfo();

		session.AddItemID(iconInfo:GetIESID());

		local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID());
		local itemobj = GetIES(invitem:GetObject());

		local repairamount = itemobj.MaxDur - itemobj.Dur
		totalprice = totalprice + GET_REPAIR_PRICE(itemobj,repairamount, GET_COLONY_TAX_RATE_CURRENT_MAP())
	end

	if totalprice == 0 then
		ui.MsgBox(ScpArgMsg("DON_T_HAVE_ITEM_TO_REPAIR"));
		return;
	end
	
	if IsGreaterThanForBigNumber(totalprice, GET_TOTAL_MONEY_STR()) == 1 then
		ui.MsgBox(ScpArgMsg("NOT_ENOUGH_MONEY"))
		return;
	end

	local targetbox = frame:GetChild("repair");
	local handle = frame:GetUserValue("HANDLE");
	local skillName = frame:GetUserValue("SKILLNAME");
	
    SQUIRE_REPAIR_EXCUTE_RUN(handle, skillName)
    imcSound.PlaySoundEvent('button_click_repair');

end

function ITEMBUFFMACHINE_BUY_BUFF(handle, index, price, sellType)
    session.autoSeller.Buy(handle, index, price, sellType)
end
function ITEMBUFFMACHINE_EAT(index)
    local frame = ui.GetFrame("foodtable_ui")

    local handle = frame:GetUserIValue("HANDLE")
    local sellType = frame:GetUserIValue("SELLTYPE")
    session.autoSeller.Buy(handle, index, 1, sellType)
    g.eatignore = true
end
function ITEMBUFFMACHINE_CANCEL_DO_BUTTON()
    ui.SetEscapeScp("")
    local frame = ui.GetFrame(g.framename)
    local timer = frame:GetChild("addontimer")
    AUTO_CAST(timer)
    timer:Stop()
    g.frame:ShowWindow(0)
end
function ITEMBUFFMACHINE_TARGET_BUFF_AUTOSELL_LIST(groupName, sellType, handle)
    local shown = false
    if ui.GetFrame("buffseller_target"):IsVisible() == 1 then
        shown = true
    end
    TARGET_BUFF_AUTOSELL_LIST_OLD_IBM(groupName, sellType, handle)
    if shown == false then
        ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Pardoner_SpellBuff)
    end
end

--  enchant armor
function ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN(groupName, sellType, handle)
    EBI_try_catch {
        try = function()
            ENCHANTAROR_STORE_OPEN_OLD_IBM(groupName, sellType, handle)
            local frame = ui.GetFrame("enchantarmoropen")
            local btn = frame:CreateOrGetControl("button", "ibmbuff", 20, 70, 100, 30)
            btn:SetText("{ol}Auto Buff")
            btn:SetEventScript(ui.LBUTTONUP, "ITEMBUFFMACHINE_ENCHANTARMOR_ONBUTTON")
            --ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Enchanter_EnchantArmor)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_OPEN_ITEMBUFF_UI(groupName, sellType, handle)
    EBI_try_catch {
        try = function()
            OPEN_ITEMBUFF_UI_OLD_IBM(groupName, sellType, handle)
            local groupInfo = session.autoSeller.GetByIndex(groupName, 0)
            if groupInfo == nil then
                return
            end

            local sklName = GetClassByType("Skill", groupInfo.classID).ClassName
            if "Squire_Repair" == sklName then
                ITEMBUFFMACHINE_CHECK_BUTTON(BUFFSHOP_TYPE.Squire_Repair)
            elseif "Alchemist_Roasting" == sklName then
            -- local frame = ui.GetFrame('itembuffgemroasting')
            -- local btn = frame:CreateOrGetControl('button', 'ibmroast', 20, 70, 100, 30)
            -- btn:SetText('{ol}Auto Roast')
            -- btn:SetEventScript(ui.LBUTTONUP, 'ITEMBUFFMACHINE_ROASTING_ONBUTTON')
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
local function ITEMBUFFMACHINE_GET_ROASTING_GEMS()
    local gems = {}
    local ingredientscount = 0
    local sortedList = session.GetInvItemSortedList()
    local invItemCount = sortedList:size()
    local frame = ui.GetFrame("itembuffgemroasting")
    for i = 0, invItemCount - 1 do
        local invItem = sortedList:at(i)
        local pc = GetMyPCObject()
        local obj = GetIES(invItem:GetObject())
        local succ = true
        if invItem.isLockState == true then
            succ = false
        elseif obj.GemRoastingLv >= frame:GetUserIValue("SKILLLEVEL") then
            succ = false
        else
            local checkItem = _G["ITEMBUFF_CHECK_" .. frame:GetUserValue("SKILLNAME")]
            if 1 ~= checkItem(pc, obj) then
                succ = false
            else
                local name, cnt = checkFunc(pc, obj)
                ingredientscount = ingredientscount + cnt
                gems[#gems + 1] = {iesid = invItem:GetIESID(), ingredientscount = cnt}
            end
        end
    end
    return gems, ingredientscount
end
function ITEMBUFFMACHINE_ROASTING_ONBUTTON()
    local frame = ui.GetFrame("itembuffgemroasting")
    local sortedList = session.GetInvItemSortedList()
    local invItemCount = sortedList:size()
    if g.working then
        ui.SysMsg("{ol}Currently working.")
        return
    end
    local gems, ingredientscount = ITEMBUFFMACHINE_GET_ROASTING_GEMS()
    if (#gems == 0) then
        ui.SysMsg("No gems.")
    end
    local price = ingredientscount * frame:GetUserIValue("PRICE")
    ui.MsgBox(
        "Would you like to roast all gems?{nl}{#FFFF00}{ol}Price:" .. tostring(price),
        string.format("ITEMBUFFMACHINE_ROASTING_DO_SELECT()"),
        "None"
    )
end
function ITEMBUFFMACHINE_ROASTING_DO_SELECT()
    g.working = true
    ui.SetEscapeScp("")
    g.items = ITEMBUFFMACHINE_GET_ROASTING_GEMS()
    ITEMBUFFMACHINE_ROAST(1)
end
function ITEMBUFFMACHINE_ROAST(index)
    session.ResetItemList()
    local frame = ui.GetFrame("itembuffgemroasting")
    session.AddItemID(g.items[0].iesid)
    local handle = frame:GetUserValue("HANDLE")
    local skillName = frame:GetUserValue("SKILLNAME")

    lock_state_check.disable_lock_state(g.items[0].iesid)
    session.autoSeller.BuyItems(handle, AUTO_SELL_GEM_ROASTING, session.GetItemIDList(), skillName)
    ui.SetEscapeScp("ITEMBUFFMACHINE_ROAST_CANCEL()")
end
function ITEMBUFFMACHINE_ROAST_CANCEL(index)
    ui.SetEscapeScp("")
    lock_state_check.enable_lock_state(g.items[index].iesid)
    g.items = {}
    g.working = false
end
function ITEMBUFFMACHINE_ROAST_COMPLETE(index)
    ui.SetEscapeScp("")
    lock_state_check.enable_lock_state(g.items[index].iesid)
    if #g.items > index then
        ui.SysMsg("Roasting complete.")
        g.working = false
        return
    end
    ITEMBUFFMACHINE_ROAST(index + 1)
end
function ITEMBUFFMACHINE_ITEMBUFFOPEN_INIT()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame("itembuffopen")
            local btn = frame:CreateOrGetControl("button", "ibmbuff", 20, 70, 100, 30)
            btn:SetText("{ol}Auto Buff")
            btn:SetEventScript(ui.LBUTTONUP, "ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON")
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

            local btn = frame:CreateOrGetControl("button", "ibmbuffweapon", 130, 70, 100, 30)
            btn:SetText("{ol}Weapon Only")
            btn:SetEventScript(ui.LBUTTONUP, "ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON")
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, 0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON(frame, control, argStr, isAll)
    EBI_try_catch {
        try = function()
            local equiplist = session.GetEquipItemList()
            local price = 0
            local frame = ui.GetFrame("itembuffopen")
            local pc = GetMyPCObject()
            local imoney = frame:GetUserIValue("PRICE")
            local totalcnt = 0
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local tempobj = equipItem:GetObject()
                if tempobj ~= nil then
                    local obj = GetIES(tempobj)
                    if
                        (item.IsNoneItem(obj.ClassID) == 0 and
                            ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(obj, isAll) == 1)
                     then
                        local checkFunc = _G["ITEMBUFF_NEEDITEM_" .. frame:GetUserValue("SKILLNAME")]
                        local name, cnt = checkFunc(pc, obj)
                        totalcnt = totalcnt + cnt
                    end
                end
            end
            local price = totalcnt * imoney
            if price == 0 then
                ui.SysMsg("Applicatable equipment is not found.")
                return
            else
                ui.MsgBox(
                    "Would you like to apply maintainance to all equipments?{nl}{#FFFF00}{ol}Price:" .. tostring(price),
                    string.format("ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT(%d)", isAll),
                    "None"
                )
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANTARMOR_ONBUTTON(frame)
    EBI_try_catch {
        try = function()
            local aframe = ui.GetFrame("enchantarmoropen")
            local groupName = aframe:GetUserValue("GroupName")
            DBGOUT("HOGE")
            local context =
                ui.CreateContextMenu(
                "CONTEXT_ITEMBUFFMACHINE_ENCHANT",
                "Please select the applicatable buff.",
                0,
                0,
                200,
                200
            )
            ui.AddContextMenuItem(context, "Cancel", "None")
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)
            for i = 1, #optionList do
                local msg = ScpArgMsg(optionList[i])
                ui.AddContextMenuItem(
                    context,
                    "「" .. msg .. "」" .. ScpArgMsg(optionList[i] .. "_DESC"),
                    string.format('ITEMBUFFMACHINE_ENCHANTARMOR_SELECT("%s",%d)', groupName, i)
                )
            end
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(item)
    if item.GroupName == "Armor" then
        if item.ClassType == "Shield" or item.ClassType == "Shirt" or item.ClassType == "Pants" then
            return 1
        end
        return 0
    end
    return 0
end
function ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(item, isAll)
    if item.GroupName == "Weapon" then
        return 1
    end

    if item.GroupName == "SubWeapon" and CHECK_ITEM_BASIC_TOOLTIP_PROP_EXIST(item, "ATK") then
        return 1
    end

    if item.GroupName == "Armor" and isAll == 1 then
        if
            item.ClassType == "Shield" or item.ClassType == "Shirt" or item.ClassType == "Pants" or
                item.ClassType == "Gloves" or
                item.ClassType == "Boots"
         then
            return 1
        end
    end

    return 0
end

function ITEMBUFFMACHINE_ENCHANTARMOR_SELECT(groupName, index)
    EBI_try_catch {
        try = function()
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local groupInfo = session.autoSeller.GetByIndex(groupName, 0)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)
            local equiplist = session.GetEquipItemList()
            local price = 0
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local tempobj = equipItem:GetObject()
                if tempobj ~= nil then
                    local obj = GetIES(tempobj)
                    if
                        (item.IsNoneItem(obj.ClassID) == 0 and
                            ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(obj) == 1)
                     then
                        price = price + groupInfo.price
                    end
                end
            end
            if price == 0 then
                ui.SysMsg("Applicatable equipment is not found.")
                return
            else
                local msg = ScpArgMsg(optionList[index])
                ui.MsgBox(
                    'Would you like to applicate enchant armor of "' ..
                        msg ..
                            '"' ..
                                ScpArgMsg(optionList[index] .. "_DESC") ..
                                    "{nl} ?{nl}{#FFFF00}{ol}Price:" .. tostring(price),
                    string.format("ITEMBUFFMACHINE_ENCHANTARMOR_DO_SELECT(%d)", index),
                    "None"
                )
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT(isAll)
    EBI_try_catch {
        try = function()
            g.items = {}
            local equiplist = session.GetEquipItemList()
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot)
                if spotName ~= nil then
                    local tempobj = equipItem:GetObject()
                    if tempobj ~= nil then
                        local obj = GetIES(tempobj)
                        local fn = ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp

                        if (item.IsNoneItem(obj.ClassID) == 0 and fn(obj, isAll) == 1) then
                            local curIndex = -1
                            for ii = 0, 3 do
                                local guid = quickslot.GetSwapWeaponGuid(ii)
                                if nil ~= guid then
                                    local item = session.GetEquipItemByGuid(guid)
                                    if nil ~= item and guid == equipItem:GetIESID() then
                                        curIndex = ii
                                    end
                                end
                            end

                            g.items[#g.items + 1] = {
                                iesid = equipItem:GetIESID(),
                                swapIndex = curIndex
                            }
                        end
                    end
                    -- sort by swapIndex
                    table.sort(
                        g.items,
                        function(a, b)
                            return a.swapIndex < b.swapIndex
                        end
                    )
                end
            end
            g.itemcursor = 1
            g.squirewaitfornext = false
            --g.working=true
            --ui.SetEscapeScp("ITEMBUFFMACHINE_CANCEL()")
            local frame = ui.GetFrame("itembuffopen")
            local skillName = frame:GetUserValue("SKILLNAME")
            local handle = frame:GetUserValue("HANDLE")
            local ids = {}
            session.ResetItemList()

            for _, v in ipairs(g.items) do

                --    ids[#ids+1]=v.iesid
                session.AddItemID(v.iesid)
            end
            session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName)
            --ITEMBUFFMACHINE_UNWEAR(1)

            ReserveScript('ui.CloseFrame("itembuffopen")', 0.5)
            ReserveScript('ui.CloseFrame("inventory")', 0.5)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANTARMOR_DO_SELECT(index)
    g.items = {}
    g.itemcursor = 1
    local equiplist = session.GetEquipItemList()
    for i = 0, equiplist:Count() - 1 do
        local equipItem = equiplist:GetEquipItemByIndex(i)
        local spotName = item.GetEquipSpotName(equipItem.equipSpot)
        if spotName ~= nil then
            local tempobj = equipItem:GetObject()
            if tempobj ~= nil then
                local obj = GetIES(tempobj)
                local fn = ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor

                if (item.IsNoneItem(obj.ClassID) == 0 and fn(obj) == 1) then
                    local curIndex = -1
                    for ii = 0, 3 do
                        local guid = quickslot.GetSwapWeaponGuid(ii)
                        if nil ~= guid then
                            local item = session.GetEquipItemByGuid(guid)
                            if nil ~= item and guid == equipItem:GetIESID() then
                                curIndex = ii
                            end
                        end
                    end

                    g.items[#g.items + 1] = {
                        iesid = equipItem:GetIESID(),
                        swapIndex = curIndex
                    }
                end
            end
        end
    end
    g.enchantname = index
    g.squirewaitfornext = false
    g.working = true
    ui.SetEscapeScp("ITEMBUFFMACHINE_CANCEL()")
    ITEMBUFFMACHINE_UNWEAR(0)
end

function ITEMBUFFMACHINE_UNWEAR(squire)
    EBI_try_catch {
        try = function()
            local equipItemIESID = g.items[g.itemcursor].iesid
            local equipItem = session.GetEquipItemByGuid(equipItemIESID)
            if (equipItem ~= nil) then
                local spot = equipItem.equipSpot
                item.UnEquip(spot)
            end

            g.itemcursor = g.itemcursor + 1
            if g.working then
                if g.itemcursor > #g.items then
                    g.itemcursor = 1
                    if squire == 1 then
                        ReserveScript("ITEMBUFFMACHINE_ITEMBUFF()", 0.75)
                    else
                        ReserveScript("ITEMBUFFMACHINE_ENCHANT()", 0.75)
                    end
                else
                    ReserveScript(string.format("ITEMBUFFMACHINE_UNWEAR(%d)", squire), 0.75)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANT()
    EBI_try_catch {
        try = function()
            local equipItemIESID = g.items[g.itemcursor].iesid
            local frame = ui.GetFrame("enchantarmoropen")
            local handle = frame:GetUserIValue("HANDLE")
            local skillName = frame:GetUserValue("GroupName")
            --local equipItem = nil
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)

            session.autoSeller.BuyEnchantBuff(
                handle,
                AUTO_SELL_ENCHANTERARMOR,
                optionList[g.enchantname],
                skillName,
                equipItemIESID
            )
            g.itemcursor = g.itemcursor + 1
            if g.working then
                if g.itemcursor > #g.items then
                    g.itemcursor = 1

                    ReserveScript("ITEMBUFFMACHINE_WEAR()", 7)
                else
                    ReserveScript("ITEMBUFFMACHINE_ENCHANT()", 7)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_SQUIRE_ITEM_SUCCEED()
    SQUIRE_ITEM_SUCCEED_OLD_IBM()
 
    -- if g.working then
    --     g.itemcursor = g.itemcursor + 1
    --     if g.itemcursor > #g.items then
    --         g.itemcursor = 1
    --         g.squirewaitfornext = false
    --         ReserveScript("ITEMBUFFMACHINE_WEAR()", 1)
    --     else
    --         ReserveScript("ITEMBUFFMACHINE_ITEMBUFF()", 1)
    --     end
    -- end
end
function ITEMBUFFMACHINE_ITEMBUFF()
    EBI_try_catch {
        try = function()
            local equipItemIESID = g.items[g.itemcursor].iesid
            local frame = ui.GetFrame("itembuffopen")
            local skillName = frame:GetUserValue("SKILLNAME")
            local handle = frame:GetUserValue("HANDLE")
            local equipItem = nil
            equipItem = session.GetInvItemByGuid(equipItemIESID)

            session.autoSeller.BuySquireBuff(handle, AUTO_SELL_SQUIRE_BUFF, skillName, equipItemIESID)
            g.squirewaitfornext = true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_EQUIP_ITEM_LIST()
    ITEMBUFFMACHINE_CHECK()
end
function ITEMBUFFMACHINE_CANCEL(quiet)
    if not quiet then
        ui.SysMsg("Cancelled")
    end
    ui.SetEscapeScp("")
    g.working = false
end
function ITEMBUFFMACHINE_WEAR()
    EBI_try_catch {
        try = function()
            local equipItemIESID = g.items[g.itemcursor].iesid
            local swapIndex = g.items[g.itemcursor].swapIndex
            local equipItem = session.GetInvItemByGuid(equipItemIESID)
            if swapIndex ~= -1 then
                DO_WEAPON_SWAP(frame, swapIndex)
            end
            --local spname = item.GetEquipSpotName(equipSpot)
            ReserveScript(string.format("ITEM_EQUIP_MSG(session.GetInvItemByGuid('%s'))", equipItemIESID), 0.5)
            if g.working then
                g.itemcursor = g.itemcursor + 1
                if g.itemcursor > #g.items then
                    g.itemcursor = 1

                    ReserveScript('ITEMBUFFMACHINE_CANCEL(true);ui.SysMsg("Completed")', 1.25)
                else
                    ReserveScript("ITEMBUFFMACHINE_WEAR()", 1.25)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
