-- RWFTLI
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end

local function _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)    
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local itemCnt = 0;
    local guidList = itemList:GetGuidList();
    local cnt = guidList:Count();
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);
        local obj = GetIES(invItem:GetObject());
        if insertItem == nil then
		    if obj.ClassName ~= MONEY_NAME then
                itemCnt = itemCnt + 1;
            end
        else
		    if obj.ClassName ~= MONEY_NAME and insertItem.ClassName ~= obj.ClassName then
                itemCnt = itemCnt + 1;
            end
        end
    end
    
    if slotCount <= itemCnt then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        return false;
    end
    return true;
end

function PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, slot, fromFrame)
    EBI_try_catch{
        try = function()
            
            local obj = GetIES(invItem:GetObject())
            if _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then
                return;
            end
            
            if CHECK_EMPTYSLOT(frame, obj) == 1 then
                return
            end
            
            if true == invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                return;
            end
            
            local itemCls = GetClassByType("Item", invItem.type);
            if itemCls.ItemType == 'Quest' then
                ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
                return;
            end
            
            local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
            if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end
            
            if fromFrame:GetName() == "inventory" then
                local maxCnt = invItem.count;
                if TryGetProp(obj, "BelongingCount") ~= nil then
                    maxCnt = invItem.count - obj.BelongingCount;
                    if maxCnt <= 0 then
                        maxCnt = 0;
                    end
                end
                
                if invItem.count > 1 then
                    INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt, nil, tostring(invItem:GetIESID()));
                else
                    if maxCnt <= 0 then
                        ui.SysMsg(ClMsg("ItemIsNotTradable"));
                        return;
                    end
                    
                    if invItem.hasLifeTime == true then
                        --local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", %d, %d)', IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), invItem.count, frame:GetUserIValue('HANDLE'));
                        --ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                        item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"));
                        return;
                    end
                    
                    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"));
                    --new_add_item[#new_add_item + 1] = invItem:GetIESID()
                    
                    --if geItemTable.IsStack(obj.ClassID) == 1 then
                    --   new_stack_add_item[#new_stack_add_item + 1] = obj.ClassID
                    --end
                end
            else
                if slot ~= nil then
                    AUTO_CAST(slot);
                    
                    local iconSlot = liftIcon:GetParent();
                    AUTO_CAST(iconSlot);
                    item.SwapSlotIndex(IT_ACCOUNT_WAREHOUSE, slot:GetSlotIndex(), iconSlot:GetSlotIndex());
                    ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame);
                end
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function WAREHOUSE_INV_RBTN(itemObj, slot)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("warehouse");
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
            
            local obj = GetIES(invItem:GetObject());
            if CHECK_EMPTYSLOT(frame, obj) == 1 then
                return
            end
            
            if true == invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                return;
            end
            
            local itemCls = GetClassByType("Item", invItem.type);
            if itemCls.ItemType == 'Quest' then
                ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
                return;
            end
            
            if tonumber(itemCls.LifeTime) > 0 and obj.ItemLifeTimeOver > 0 then
                ui.MsgBox(ScpArgMsg("WrongDropItem"));
                return;
            end
            
            AUTO_CAST(slot);
            local fromFrame = slot:GetTopParentFrame();
            
            if fromFrame:GetName() == "inventory" then
                if invItem.count > 1 then
                    INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_WAREHOUSE", invItem.count, 1, invItem.count, nil, tostring(invItem:GetIESID()));
                else
                    -- if invItem.hasLifeTime == true then
                    -- 	local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", %d, %d)', IT_WAREHOUSE, invItem:GetIESID(), invItem.count, frame:GetUserIValue("HANDLE"));
                    -- 	ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                    -- 	return;
                    -- end
                    item.PutItemToWarehouse(IT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"));
                end
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
