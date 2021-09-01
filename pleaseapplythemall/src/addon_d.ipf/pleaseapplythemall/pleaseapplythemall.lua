--pleaseapplythemall
--アドオン名（大文字）
local addonName = "pleaseapplythemall"
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
g.framename = "アドオン名（大文字）"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[PATM]loaded")
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


function PLEASEAPPLYTHEMALL_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            acutil.setupHook(PLEASEAPPLYTHEMALL_TARGET_BUFF_AUTOSELL_LIST, "TARGET_BUFF_AUTOSELL_LIST")
            
            acutil.setupHook(PLEASEAPPLYTHEMALL_ITEMBUFF_REPAIR_UI_COMMON, "ITEMBUFF_REPAIR_UI_COMMON")
            g.itemrepair=false
            g.buffseller=false
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function PLEASEAPPLYTHEMALL_ITEMBUFF_REPAIR_UI_COMMON(groupName, sellType, handle)
    EBI_try_catch{
        try = function()
            ITEMBUFF_REPAIR_UI_COMMON_OLD(groupName, sellType, handle)
            local frame = ui.GetFrame('itembuffrepair');
            if not g.itemrepair then
                if _G['ADDONS']['TOUKIBI']['ShopHelper'] then
                    local toukibi = _G['ADDONS']['TOUKIBI']['ShopHelper']
                    local dur = toukibi.ComLib:GetValueOrDefault(toukibi.Settings.Repair_DurValue, 3, false);
                    ui.MsgBox_NonNested("Would you like to repair equips under " .. dur .. "0% durability?", g.framename, 'PLEASEAPPLYTHEMALL_APPLY_REPAIR(' .. (dur) .. ')', 'None')
                else
                    ui.MsgBox_NonNested("Would you like to repair equips under 70% durability?", g.framename, 'PLEASEAPPLYTHEMALL_APPLY_REPAIR(7)', 'None')
                end
                
                g.itemrepair = true
            end
            frame:SetCloseScript("PLEASEAPPLYTHEMALL_ITEMBUFF_REPAIR_CLOSE")
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function PLEASEAPPLYTHEMALL_TARGET_BUFF_AUTOSELL_LIST(groupName, sellType, handle)
    EBI_try_catch{
        try = function()
            TARGET_BUFF_AUTOSELL_LIST_OLD(groupName, sellType, handle)
            local frame = ui.GetFrame('buffseller_target');
            if not g.buffseller then
                ui.MsgBox_NonNested("Would you like to buy them all?", g.framename, 'PLEASEAPPLYTHEMALL_APPLY_ALLBUFF()', 'None')
                g.buffseller = true
            end
            frame:SetCloseScript("PLEASEAPPLYTHEMALL_BUFFSELLER_CLOSE")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function PLEASEAPPLYTHEMALL_BUFFSELLER_CLOSE()
    g.buffseller = false
end
function PLEASEAPPLYTHEMALL_ITEMBUFF_REPAIR_CLOSE()
    g.itemrepair = false
end
function PLEASEAPPLYTHEMALL_APPLY_ALLBUFF()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('buffseller_target');
            local handle = frame:GetUserIValue("HANDLE")
            
            local groupName = frame:GetUserValue("GROUPNAME");
            local itemInfo0 = session.autoSeller.GetByIndex(groupName, 0);
            local itemInfo1 = session.autoSeller.GetByIndex(groupName, 1);
            local itemInfo2 = session.autoSeller.GetByIndex(groupName, 2);
            local itemInfo3 = session.autoSeller.GetByIndex(groupName, 3);
            
            local sellType = frame:GetUserIValue("SELLTYPE");
            ReserveScript(string.format("EXEC_BUY_AUTOSELL(%d,0,%d,%d)", handle, itemInfo0.price, sellType), 0.1)
            ReserveScript(string.format("EXEC_BUY_AUTOSELL(%d,1,%d,%d)", handle, itemInfo1.price, sellType), 0.6)
            ReserveScript(string.format("EXEC_BUY_AUTOSELL(%d,2,%d,%d)", handle, itemInfo2.price, sellType), 1.1)
            ReserveScript(string.format("EXEC_BUY_AUTOSELL(%d,3,%d,%d)", handle, itemInfo3.price, sellType), 1.6)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function PLEASEAPPLYTHEMALL_APPLY_REPAIR(dur)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("itembuffrepair");
            if PLEASEAPPLYTHEMALL_ITEMREPAIR_SelectItem(true, dur)>0 then
                SQIORE_REPAIR_EXCUTE(frame:GetChildRecursively('btn_excute'))
                imcSound.PlaySoundEvent('button_click_repair')
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
-- from toukibi's ShopHelper
function PLEASEAPPLYTHEMALL_ITEMREPAIR_SelectItem(OnlyEquip, DurValue)
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
    
    UPDATE_SQIOR_REPAIR_MONEY(TopParent, totalcont);
    
    if bolFound then
        TopParent:SetUserValue("SELECTED", "SelectedAll");
    else
        TopParent:SetUserValue("SELECTED", "NotSelected");
    end
    
    return totalcont
end
