-- RWFTLI
local json = require "json_imc"

local max_slot_per_tab = account_warehouse.get_max_slot_per_tab()
local current_tab_index = 0
local custom_title_name = {}
local new_add_item = { }
local new_stack_add_item = { }
local ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD = ON_ACCOUNT_WAREHOUSE_ITEM_LIST

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function get_valid_index()    
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();    
    local sortedCnt = sortedGuidList:Count();    
    
    local start_index = (current_tab_index * max_slot_per_tab)
    local last_index = (start_index + max_slot_per_tab) -1
    
    local __set = {}
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME then
            if start_index <= invItem.invIndex and invItem.invIndex <= last_index and __set[invItem.invIndex] == nil then
                __set[invItem.invIndex] = 1
            end
        end
    end

    local index = start_index
    for k, v in pairs(__set) do
        if __set[index] ~= 1 then
            break
        else
            index = index + 1
        end
    end
    
    return index
end


local function get_tab_index(item_inv_index)
    if item_inv_index < 0 then
        item_inv_index = 0
    end
    local index = math.floor(item_inv_index / max_slot_per_tab)
    return index
end

local function is_new_item(id)
    for k, v in pairs(new_add_item) do
        if v == id then
            return true
        end
    end
    return false
end

local function is_stack_new_item(class_id)
    for k, v in pairs(new_stack_add_item) do
        if v == class_id then
            return true
        end
    end
    return false
end
function ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, msg, argStr, argNum, tab_index)  
    ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD(frame, msg, argStr, argNum, tab_index)  
    if tab_index == nil then
        tab_index = current_tab_index
    end
	
    current_tab_index=tab_index
end
local function _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)    
    local index = get_valid_index()    
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
        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < max_slot_per_tab then
            itemCnt = itemCnt + 1;
        end
    end

    if slotCount <= itemCnt and index < max_slot_per_tab then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        return false;
    end
    
    if slotCount <= index and index < max_slot_per_tab then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        return false;
    end
    return true;
end


function PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, slot, fromFrame)
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

            local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset');
            local goal_index = get_valid_index()                  
            if invItem.hasLifeTime == true then
                local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", "%s", %d, %d)', IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue('HANDLE'), goal_index);
                --ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                ReserveScript(yesscp,0.00)
                return;
            end

            -- 여기서 아이템 입고 요청
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"), goal_index)
            new_add_item[#new_add_item + 1] = invItem:GetIESID()

            --if geItemTable.IsStack(obj.ClassID) == 1 then
            --    new_stack_add_item[#new_stack_add_item + 1] = obj.ClassID
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
end

function WAREHOUSE_INV_RBTN(itemObj, slot)
	
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

	if itemCls.MarketCategory == 'Housing_Furniture' or 
	    itemCls.MarketCategory == 'Housing_Laboratory' or 
	    itemCls.MarketCategory == 'Housing_Contract' then
		ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
		return;
	end
    	
	AUTO_CAST(slot);
	local fromFrame = slot:GetTopParentFrame();

	if fromFrame:GetName() == "inventory" then        
		if invItem.count > 1 then
			INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_WAREHOUSE", invItem.count, 1, invItem.count, nil, tostring(invItem:GetIESID()));
		else
			if invItem.hasLifeTime == true then
				local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", %d, %d)', IT_WAREHOUSE, invItem:GetIESID(), invItem.count, frame:GetUserIValue("HANDLE"));
				--ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                ReserveScript(yesscp,0.00)
                return;
			end

			item.PutItemToWarehouse(IT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"));
		end
	end
end
