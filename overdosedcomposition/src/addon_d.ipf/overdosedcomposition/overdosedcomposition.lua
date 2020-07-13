-- overdosedcomposition
local addonName = "overdosedcomposition"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.tgtitem = nil
g.items = {}
g.reinforcing = false
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function active_reinforce_button()
    local reinforceButton = GET_CHILD_RECURSIVELY(ui.GetFrame("reinforce_by_mix"), "exec_mixreinf");
    if reinforceButton ~= nil then
        reinforceButton:EnableHitTest(1);
    end
end
function OVERDOSEDCOMPOSITION_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            acutil.setupHook(ODDC_REINFORCE_BY_MIX_SETITEM, "REINFORCE_BY_MIX_SETITEM")
            acutil.setupHook(ODDC_RECREATE_MATERIAL_SLOT, "RECREATE_MATERIAL_SLOT")
            acutil.setupHook(ODDC_REINFORCE_BY_MIX_EXECUTE, "REINFORCE_BY_MIX_EXECUTE")
            acutil.setupHook(ODDC_OPEN_REINFORCE_BY_MIX, "OPEN_REINFORCE_BY_MIX")
            
            addon:RegisterMsg("ITEM_EXP_STOP", "ODDC_REINFORCE_MIX_ITEM_EXP_STOP");
            addon:RegisterMsg("ITEM_EXPUP_END", "ODDC_REINFORCE_MIX_ITEM_EXPUP_END");
        
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function ODDC_OPEN_REINFORCE_BY_MIX(frame)
    OPEN_REINFORCE_BY_MIX_OLD(frame)
    local btn = frame:GetChildRecursively("exec_mixreinf")
    btn:SetEventScript(ui.LBUTTONUP, "ODDC_REINFORCE_BY_MIX_EXECUTE")
end

function ODDC_RECREATE_MATERIAL_SLOT(frame)
    
    EBI_try_catch{
        try = function()
            RECREATE_MATERIAL_SLOT_OLD(frame)
            local matslot = GET_MAT_SLOT(frame);
            matslot:ShowWindow(1);
            
            matslot:RemoveAllChild();
            matslot:SetColRow(18, 6);
            matslot:SetSlotSize(20, 20);
            matslot:SetSpc(1, 1);
            matslot:CreateSlots();
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function ODDC_REINFORCE_BY_MIX_SETITEM(frame, invItem)
    
    EBI_try_catch{
        try = function()
            REINFORCE_BY_MIX_SETITEM_OLD(frame, invItem)
            local matslot = GET_MAT_SLOT(frame);
            matslot:ShowWindow(1);
            
            matslot:RemoveAllChild();
            matslot:SetColRow(18, 6);
            matslot:SetSlotSize(20, 20);
            matslot:SetSpc(1, 1);
            matslot:CreateSlots();
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end

function ODDC_REINFORCE_BY_MIX_EXECUTE(parent)
    EBI_try_catch{
        try = function()
            if session.colonywar.GetIsColonyWarMap() == true then
                ui.SysMsg(ClMsg('CannotUseInPVPZone'));
                return;
            end
            
            if session.world.IsIntegrateServer() == true or
                session.world.IsIntegrateIndunServer() == true or
                session.IsMissionMap() == true then
                ui.SysMsg(ClMsg("CannotCraftInIndun"));
                return
            end
            
            -- In Challenge Mode
            if info.GetBuffByName(session.GetMyHandle(), "ChallengeMode_Player") ~= nil then
                ui.SysMsg(ClMsg("CannotCraftInChallengeMode"));
                return
            end
            
            local frame = parent:GetTopParentFrame();
            
            local slots = GET_MAT_SLOT(frame);
            local cnt = slots:GetSlotCount();
            
            local tgtItem = GET_REINFORCE_MIX_ITEM();
            if tgtItem.ItemLifeTimeOver == 1 then
                ui.SysMsg(ScpArgMsg("CannotUseLifeTimeOverItem"))
                return
            end
            local slots = GET_MAT_SLOT(frame);
            local cnt = slots:GetSlotCount();
            for i = 0, cnt - 1 do
                local slot = slots:GetSlotByIndex(i);
                local matItem, count = GET_SLOT_ITEM(slot);
                if matItem ~= nil then
                    local obj = GetIES(matItem:GetObject());
                    if obj.ItemLifeTimeOver == 1 then
                        ui.SysMsg(ScpArgMsg("CannotUseLifeTimeOverItem"))
                        return
                    end
                end
            end
            
            
            local ishavevalue = 0
            local canProcessReinforce = false
            
            for i = 0, cnt - 1 do
                local slot = slots:GetSlotByIndex(i);
                local matItem, count = GET_SLOT_ITEM(slot);
                if matItem ~= nil then
                    if IS_VALUEABLE_ITEM(matItem:GetIESID()) == 1 then
                        ishavevalue = 1
                        break
                    else
                        canProcessReinforce = true
                    end
                end
            end
            
            if ishavevalue == 1 then
                local yesScp = string.format("_ODDC_REINFORCE_BY_MIX_EXECUTE()");
                ui.MsgBox(ScpArgMsg("IsValueAbleItem"), yesScp, "None");
            elseif canProcessReinforce then
                _ODDC_REINFORCE_BY_MIX_EXECUTE()
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end


function _ODDC_REINFORCE_BY_MIX_EXECUTE()
    local tgtItem = GET_REINFORCE_MIX_ITEM();
    if tgtItem.GroupName == "Card" then
        local lv, curExp, maxExp = GET_ITEM_LEVEL_EXP(tgtItem, tgtItem.ItemExp);
        if lv > 1 and maxExp == 0 then -- 카드 합성 제한이다. 제한선을 수정할 경우 여기도 바꿔줘야한다. 카드 레벨 제한을 경험치 분할 갯수로 따지기 때문에 제함점을 따로 얻어올 방법을 못찾겠다.
            ui.MsgBox(ScpArgMsg("CardLvisMax"));
            return;
        end
    end
    local frame = ui.GetFrame("reinforce_by_mix");
    local reinforceButton = GET_CHILD_RECURSIVELY(frame, "exec_mixreinf");
    if reinforceButton ~= nil then
        reinforceButton:EnableHitTest(0);
    end
    
    frame:SetUserValue("EXECUTE_REINFORCE", 1)
    --session.ResetItemList();
    g.tgtitem = {iesid = frame:GetUserValue("ITEM_GUID")}
    --session.AddItemID(frame:GetUserValue("ITEM_GUID"));
    -- 재료로 사용된 아이템 GUID를 저장하자
    local mat_list = "";
    
    local slots = GET_MAT_SLOT(frame);
    local cnt = slots:GetSlotCount();
    for i = 0, cnt - 1 do
        local slot = slots:GetSlotByIndex(i);
        local matItem, count = GET_SLOT_ITEM(slot);
        if matItem ~= nil then
            g.items[#g.items + 1] = {iesid = matItem:GetIESID(), count = count}
            --session.AddItemID(matItem:GetIESID(), count)
            local mat_item = session.GetInvItemByGuid(matItem:GetIESID())
            if mat_item ~= nil and mat_item.isLockState == true then
                ui.SysMsg(ClMsg("MaterialItemIsLock"))
                active_reinforce_button()
                return
            end
        
        -- STRING으로 가져다 붙여
        end
    end
    
    -- 재료로 사용된 아이템의 GUID를 저장한다.
    g.reinforcing = true
    
    --local tgtItem = GET_REINFORCE_MIX_ITEM();
    frame:SetUserValue("LAST_REQ_EXP", tgtItem.ItemExp);
    CloneTempObj("REINF_MIX_TEMPOBJ", tgtItem);
    ODDC_DO_REINFORCE()
end
function ODDC_DO_REINFORCE()
    local limit = 12;
    if #g.items == 0 then
        ODDC_END()
        return
    end
    session.ResetItemList();
    session.AddItemID(g.tgtitem.iesid);
    for i = 0, limit do
        if #g.items > 0 then
            local item = g.items[1]
            table.remove(g.items, 1)
            session.AddItemID(item.iesid, item.count)
        end
    end
    
    local resultlist = session.GetItemIDList();
    if resultlist:Count() > 1 then
        SetCraftState(1);
        ui.SetHoldUI(true);
        item.DialogTransaction("SCR_ITEM_EXP_UP", resultlist);
    else
        ODDC_END()
        return
    end
end
function ODDC_END()
    g.items = {}
    g.reinforcing = false
    
    g.tgtitem = nil
    SetCraftState(0);
    ui.SetHoldUI(false);
    local frame = ui.GetFrame("reinforce_by_mix");
    frame:SetUserValue("EXECUTE_REINFORCE", 0);

end
function ODDC_REINFORCE_MIX_ITEM_EXPUP_END(frame, msg, multiPly, totalPoint)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("reinforce_by_mix");
            local matslot = GET_MAT_SLOT(frame);
            matslot:ShowWindow(1);
            
            matslot:RemoveAllChild();
            matslot:SetColRow(18, 6);
            matslot:SetSlotSize(20, 20);
            matslot:SetSpc(1, 1);
            matslot:CreateSlots();

            imcSound.PlaySoundEvent("sys_jam_mix_whoosh");
            
            local box_item = frame:GetChild("box_item");
            local item_pic = GET_CHILD(box_item, "item_pic", "ui::CSlot");
            local slots = GET_MAT_SLOT(frame);
            
            local exp_plus = box_item:GetChild("exp_plus");
            exp_plus:ShowWindow(0);
            
            local effectName = "reinf_result_";
            local resultText;
            if multiPly == 3.0 then
                resultText = "jackpot";
            elseif multiPly == 1.5 then
                resultText = "great";
            else
                resultText = "normal";
            end
            
            local sel_item_countRtext = GET_CHILD_RECURSIVELY(frame, 'sel_item_count', 'ui::CRichText')
            sel_item_countRtext:ShowWindow(0)
            
            local slot = GET_CHILD(frame, "mix_itemSlot", "ui::CSlot");
            local x, y = GET_UI_FORCE_POS(item_pic);
            APPLY_TO_ALL_ITEM_SLOT(slots, REINFORCE_MIX_FORCE, resultText, x, y);
            
            local gauge_exp = GET_CHILD(box_item, "gauge_exp", "ui::CGauge");
            local gx, gy = GET_UI_FORCE_POS(gauge_exp);
            gx = gx - 50;
            UI_FORCE(effectName, gx, gy);
            
            frame:SetUserValue("_FORCE_SHOOT_EXP", totalPoint * multiPly);
            
            local box_stats = box_item:GetChild("box_stats");
            for i = 0, box_stats:GetChildCount() - 1 do
                local ctrlSet = box_stats:GetChildByIndex(i);
                local to = ctrlSet:GetChild("to");
                if to ~= nil then to:ShowWindow(0); end
                local indicator = ctrlSet:GetChild("indicator");
                if indicator ~= nil then indicator:ShowWindow(0); end
            end
            for k, v in ipairs(g.items) do
                
                REINFORCE_BY_MIX_ADD_MATERIAL(frame, GetIES(session.GetInvItemByGuid(v.iesid):GetObject()), v.count)
            end
            local exp = frame:GetUserIValue("_FORCE_SHOOT_EXP");
            frame:SetUserValue("_EXP_UP_VALUE", exp);
	
            frame:SetUserValue("_EXP_UP_START_TIME", exp);
            REINF_MIX_UPDATE_EXP_UP(frame)
            ReserveScript("ODDC_DO_REINFORCE()", 0.5)
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function ODDC_REINFORCE_MIX_ITEM_EXP_STOP()
    
    g.items = {}
    g.reinforcing = false
    
    g.tgtitem = nil
    SetCraftState(0);
    ui.SetHoldUI(false);
    local frame = ui.GetFrame("reinforce_by_mix");
    frame:SetUserValue("EXECUTE_REINFORCE", 0);

end;
