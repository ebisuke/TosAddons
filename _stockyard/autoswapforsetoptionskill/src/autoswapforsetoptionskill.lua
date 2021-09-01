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

local function startswith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
local acutil = require('acutil')
local g = {}
g.debug = true
g.waitforend = nil
g.totalcooldown = nil
g.cooldown = nil
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

local triggerlist = {
    S100001 = {skill = "Velcoffer_Sumazinti", clsid = 100001, prefix = "Set_Sumazin", needs = 5},
    S100002 = {skill = "Velcoffer_Tiksline", clsid = 100002, prefix = "Set_Tiksline", needs = 5},
    S100003 = {skill = "Velcoffer_Mergaite", clsid = 100003, prefix = "Set_Mergaite", needs = 5},
    S100004 = {skill = "Velcoffer_Kraujas", clsid = 100004, prefix = "Set_Kraujas", needs = 5},
    S100005 = {skill = "Velcoffer_Gyvenimas", clsid = 100005, prefix = "Set_Gyvenimas", needs = 5},
    S100010 = {skill = "Savinose_Rykuma", clsid = 100010, prefix = "Set_rykuma", needs = 5},
    S100011 = {skill = "Savinose_Korup", clsid = 100011, prefix = "Set_korup", needs = 5},
    S100012 = {skill = "Savinose_Apsauga", clsid = 100012, prefix = "Set_Apsauga", needs = 5},
    S100013 = {skill = "Savinose_Bendrinti", clsid = 100013, prefix = "Set_Bendrinti", needs = 5},
    S100014 = {skill = "Varna_Goduma", clsid = 100014, prefix = "Set_Goduma", needs = 5},
    S100015 = {skill = "Varna_Gymas", clsid = 100015, prefix = "Set_Gymas", needs = 5},
    S100016 = {skill = "Varna_Smugis", clsid = 100016, prefix = "Set_Smugis", needs = 5},
    S100017 = {skill = "Varna_Aqkrova", clsid = 100017, prefix = "Set_apkrova", needs = 5},
    S100018 = {skill = "Varna_Atagal", clsid = 100018, prefix = "Set_atgal", needs = 5},
    S100019 = {skill = "Varna_Liris", clsid = 100019, prefix = "Set_Liris", needs = 5},
    S100020 = {skill = "Varna_Proverbs", clsid = 100020, prefix = "Set_Proverbs", needs = 5},

}

function ASFSOS_HOOK()
    
    acutil.setupHook(ASFSOS_ICON_USE_JUMPER, "ICON_USE")


end


-- ライブラリ読み込み
function AUTOSWAPFORSETOPTIONSKILL_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            local timer = GET_CHILD(ui.GetFrame("autoswapforsetoptionskill"), "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("ASFSOS_UPDATE")
            --addon:RegisterMsg('GAME_START_3SEC', 'ASFSOS_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'ASFSOS_SHOW');
            timer:Start(0.5);
            frame:ShowWindow(1)
            ASFSOS_HOOK()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function ASFSOS_3SEC()
    ASFSOS_HOOK()
end
function ASFSOS_SHOW()
    ui.GetFrame("autoswapforsetoptionskill"):ShowWindow(1)
end

function ASFSOS_GETVALID()
    return EBI_try_catch{
        try = function()
            
            local equipItemList = session.GetEquipItemList()
            local cnt = equipItemList:Count()
            local setprefix = nil
            for i = 0, cnt - 1 do
                local equipItem = equipItemList:GetEquipItemByIndex(i);
                local spotName = item.GetEquipSpotName(equipItem.equipSpot);
                if spotName ~= nil then
                    local equipItemObj = GetIES(equipItem:GetObject());
                    if spotName == "SHIRT" and equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) then
                        local prefix = TryGetProp(equipItemObj, "LegendPrefix")
                        setprefix = prefix
                    end
                end
            end
            if (setprefix == nil) then
                return nil
            end
            local setcount = 5
            -- local setcount = 0
            -- for i = 0, cnt - 1 do
            --     local equipItem = equipItemList:GetEquipItemByIndex(i);
            --     local spotName = item.GetEquipSpotName(equipItem.equipSpot);
            --     if spotName ~= nil then
            --         local equipItemObj = GetIES(equipItem:GetObject());
            --         if spotName ~= "LH" and spotName ~= "RH" and equipItem.type ~= item.GetNoneItem(equipItem.equipSpot) then
            --             local prefix = TryGetProp(equipItemObj, "LegendPrefix")
            --             if (prefix ~= nil and prefix ~= "") then
            --                 setcount = setcount + 1
            --                 setprefix = prefix
            --             end
            --         end
            --     end
            -- end
            --スワップをカウント
            local slot = {quickslot.GetSwapWeaponGuid(0), quickslot.GetSwapWeaponGuid(1), quickslot.GetSwapWeaponGuid(2), quickslot.GetSwapWeaponGuid(3)}
            for i = 1, 4 do
                local equipItemGuid = slot[i];
                if (equipItemGuid ~= nil) then
                    local equipItem = session.GetEquipItemByGuid(equipItemGuid);
                    if (equipItem == nil) then
                        equipItem = session.GetInvItemByGuid(equipItemGuid);
                    end
                    
                    if (equipItem ~= nil) then
                        
                        local equipItemObj = GetIES(equipItem:GetObject());
                        
                        local prefix = TryGetProp(equipItemObj, "LegendPrefix")
                        if (prefix ~= nil and prefix ~= "") then
                            setcount = setcount + 1
                        
                        end
                    
                    
                    end
                end
            end
            -- 必要数あるか検証
            for sclsid, data in pairs(triggerlist) do
                if (data.prefix == setprefix) then
                    if (data.needs > setcount) then
                        
                        return nil
                    else
                        
                        return triggerlist[sclsid]
                    end
                end
            end
            --OK
            return nil
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ASFSOS_UPDATE_FORKEYBOARD()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('quickslotnexpbar');
            local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
            if (frame:IsVisible() == 1) then
                for i = 0, MAX_QUICKSLOT_CNT - 1 do
                    local quickSlotInfo = quickslot.GetInfoByIndex(i);
                    local applied = false
                    
                    if quickSlotInfo.type ~= 0 then
                        
                        local updateslot = false;
                        
                        
                        if quickSlotInfo.category == 'Skill' then
                            updateslot = true;
                        end
                        
                        
                        if true == updateslot and quickSlotInfo.category ~= 'NONE' and triggerlist["S" .. tostring(quickSlotInfo.type)] ~= nil then
                            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                            ASFSOS_SETINFO(slot, quickSlotInfo.type)
                            
                            --LEGEXPPOTIONGAUGE_SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, quickSlotInfo.type, quickSlotInfo:GetIESID(), 0, true, true);
                            applied = true
                        end
                    end
                    if (applied == false) then
                        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
                        
                        ASFSOS_CLEARSLOT(slot)
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ASFSOS_UPDATE_FORJOYSTICK()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame('joystickquickslot');
            if (frame:IsVisible() == 1) then
                local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
                
                for i = 0, MAX_SLOT_CNT - 1 do
                    local quickSlotInfo = quickslot.GetInfoByIndex(i);
                    local applied = false
                    
                    if quickSlotInfo.type ~= 0 then
                        
                        local updateslot = false;
                        
                        
                        if quickSlotInfo.category == 'Skill' then
                            updateslot = true;
                        end
                        
                        
                        if true == updateslot and quickSlotInfo.category ~= 'NONE' and triggerlist["S" .. tostring(quickSlotInfo.type)] ~= nil then
                            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                            ASFSOS_SETINFO(slot, quickSlotInfo.type)
                            
                            --LEGEXPPOTIONGAUGE_SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, quickSlotInfo.type, quickSlotInfo:GetIESID(), 0, true, true);
                            applied = true
                        end
                    end
                    if (applied == false) then
                        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
                        
                        ASFSOS_CLEARSLOT(slot)
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ASFSOS_GETITEM(iesid)
    local invitem = GET_PC_ITEM_BY_GUID(iesid);
    if invitem == nil then
        invitem = session.GetEtcItemByGuid(IT_WAREHOUSE, iesid);
    end
    if invitem == nil then
        invitem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid);
    end
    return invitem;
end
function ASFSOS_SETINFO(slot, clsid)
    
    local skillClass = GetClassByType('Skill', clsid);
    
    
    local trigger = triggerlist["S" .. tostring(clsid)]
    
    if (trigger ~= nil) then
        
        tolua.cast(slot, "ui::CSlot")
        
        local txt = slot:CreateOrGetControl("richtext", "asfsos", 0, 0, slot:GetWidth(), 12)
        txt:SetGravity(ui.RIGHT, ui.TOP)
        txt:EnableHitTest(0)
        txt:SetText("{ol}{#FF8888}{s10}" .. skillClass.Name)
        txt:ShowWindow(1)
        
        local txtcd = slot:CreateOrGetControl("richtext", "asfsoscd", 0, 0, slot:GetWidth(), 12)
        txtcd:EnableHitTest(0)
        txtcd:SetGravity(ui.RIGHT, ui.BOTTOM)
        local skillInfo = session.GetSkill(clsid);
        if (skillInfo == nil) then
            if (g.totalcooldown ~= nil) then
                if (g.currentcooldown > 0) then
                    
                    txtcd:SetText("{ol}{#FFFFFF}{s18}" .. string.format("%d", math.floor(g.currentcooldown / 1000)))
                    txtcd:ShowWindow(1)
                else
                    txtcd:ShowWindow(0)
                end
            end
        else
            txtcd:ShowWindow(0)
            local skillinfo = session.GetSkill(clsid);
            g.totalcooldown = skillinfo:GetTotalCoolDownTime()
            g.currentcooldown = skillinfo:GetCurrentCoolDownTime()
        end
    end

end
function ASFSOS_CLEARSLOT(slot)
    if (slot:GetChild("asfsos")) then
        slot:RemoveChild("asfsos")
        slot:RemoveChild("asfsoscd")
    end
end
function ASFSOS_UPDATE()
    ASFSOS_UPDATE_FORKEYBOARD()
    ASFSOS_UPDATE_FORJOYSTICK()
    if (g.currentcooldown > 0) then
        g.currentcooldown = math.max(0, g.currentcooldown - 500)
    end
    if (g.waitforend ~= nil) then
        local actor = GetMyActor()
        local skillId = actor:GetUseSkill()
        if (skillId ~= g.waitforend) then
            ReserveScript("quickslot.SwapWeapon()", 0.5)
            g.waitforend = nil
        end
    end
end

function ASFSOS_ICON_USE_JUMPER(object, reAction)
    
    if (ASFSOS_ICON_USE(object, reAction) == false) then
        ICON_USE_OLD(object, reAction)
    end
end
function ASFSOS_DO_SKILL(clsid)
    EBI_try_catch{
        try = function()
            
            g.skillinfo = session.GetSkill(clsid);
            if (g.skillinfo == nil) then
                ReserveScript("quickslot.SwapWeapon()", 0.5)
                g.waitforend = nil
            else
                if (g.skillinfo:GetCurrentCoolDownTime() > 0) then
                    --failed
                    ReserveScript("quickslot.SwapWeapon()", 0.5)
                    g.totalcooldown = g.skillinfo:GetTotalCoolDownTime()
                    g.currentcooldown = g.skillinfo:GetCurrentCoolDownTime()
                    g.waitforend = nil
                else
                    g.totalcooldown = g.skillinfo:GetTotalCoolDownTime()
                    g.currentcooldown = g.skillinfo:GetCurrentCoolDownTime()
                    g.waitforend = clsid
                    control.Skill(clsid)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ASFSOS_ICON_USE(object, reAction)
    return EBI_try_catch{
        try = function()
            local iconPt = object;
            if iconPt ~= nil then
                local icon = tolua.cast(iconPt, 'ui::CIcon');
                
                local iconInfo = icon:GetInfo();
                if iconInfo:GetCategory() == 'Skill' then
                    
                    
                    --control.Skill(iconInfo.type);
                    local valid = ASFSOS_GETVALID()
                    
                    
                    if (valid ~= nil and valid ~= nil and valid.clsid == iconInfo.type) then
                        local skillInfo = session.GetSkill(valid.clsid);
                        if (skillInfo == nil) then
                            --g.waitforend = valid.clsid
                            g.clsid = valid.clsid
                            ReserveScript("quickslot.SwapWeapon()", 0.25)
                            ReserveScript(string.format("ASFSOS_DO_SKILL(%d);", valid.clsid), 0.75)
                        else
                            control.Skill(valid.clsid)
                        end
                        return true
                    end
                end
            
            end
            return false
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
