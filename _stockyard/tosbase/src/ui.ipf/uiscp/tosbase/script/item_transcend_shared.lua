--- item_transcend_shared.lua

function IS_TRANSCENDING_STATE()
    local frame = ui.GetFrame("itemtranscend");
    if frame ~= nil then
        if frame:IsVisible() == 1 then
            return true;
        end
    end

    frame = ui.GetFrame("itemtranscend_remove");
    if frame ~= nil then
        if frame:IsVisible() == 1 then
            return true;
        end
    end

    frame = ui.GetFrame("itemtranscend_break");
    if frame ~= nil then
        if frame:IsVisible() == 1 then
            return true;
        end
    end

    return false;
end

function IS_TRANSCEND_ABLE_ITEM(obj)
    if TryGetProp(obj, "Transcend") == nil then
        return 0;
    end
    
    if TryGetProp(obj, "BasicTooltipProp") == nil then
        return 0;
    end

    if TryGetProp(obj, "ItemStar") == nil or TryGetProp(obj, "ItemStar") < 1 then
        return 0;
    end
    
    local afterNames, afterValues = GET_ITEM_TRANSCENDED_PROPERTY(obj);
    if #afterNames == 0 then
        return 0;
    end
    
    local itemCls = GetClass("Item", obj.ClassName);
    if itemCls == nil then
        return 0;
    end

    local itemMaxPR = TryGetProp(itemCls, "MaxPR")
    if itemMaxPR == nil or itemMaxPR == 0 then
        return 0;
    end

    local itemMPR = TryGetProp(itemCls, "PR")
    if itemMPR == nil or itemMPR == 0 then
        return 0;
    end

    local itemStringArg = TryGetProp(itemCls, "StringArg")
    if itemStringArg == "Tutorial" then
        return 0;
    end

    return 1;
end

function IS_TRANSCEND_ITEM(obj)
    local value = TryGetProp(obj, "Transcend");
    if value ~= nil then
        if value ~= 0 then
            return 1;
        end
    end

    return 0;
end

function SCR_TARGET_TRANSCEND_CHECK(obj, scrollTranscend)
    local value = TryGetProp(obj, "Transcend");
    if value == nil then
        return 0
    else
        if value < scrollTranscend then
            return 1
        end
    end

    return 0;
end

function GET_TRANSCEND_MATERIAL_ITEM(target)

    local groupName = TryGetProp(target, "GroupName");
    if groupName == nil then
        return 0;
    end
    
    return "Premium_item_transcendence_Stone";
end

function GET_TRANSCEND_MATERIAL_COUNT(targetItem, Arg1)

    local lv = TryGetProp(targetItem , "UseLv");
    
    if lv == nil then
        return 0;
    end
    
    if (GetServerNation() == "KOR" and (GetServerGroupID() == 9001 or GetServerGroupID() == 9501)) then
        local kupoleItemLv = SRC_KUPOLE_GROWTH_ITEM(targetItem, 0);
        if kupoleItemLv ==  nil then
            lv = lv;
        elseif kupoleItemLv > 0 then
            lv = kupoleItemLv;
        end
    end

    local pcBangItemLevel = CALC_PCBANG_GROWTH_ITEM_LEVEL(targetItem);
    if pcBangItemLevel ~= nil then
        lv = pcBangItemLevel;
    end
    
    local transcendCount = TryGetProp(targetItem, "Transcend");

    if transcendCount == nil then
        return 0;
    end
    
    if Arg1 ~= nil then
        transcendCount = Arg1;
    end
    
    
    local grade = TryGetProp(targetItem, "ItemGrade");
    if grade == nil then
        return 0;
    end
    
    local gradeRatio = SCR_GET_ITEM_GRADE_RATIO(grade, "TranscendCostRatio")
    
    local needMatCount;
    
    local classType = TryGetProp(targetItem , "ClassType");
    
    if classType == nil then
        return 0;
    end

    local slot = TryGetProp(targetItem, "DefaultEqpSlot");
    
    if slot == nil then
        return 0;
    end

    local equipTypeRatio;
    
    local groupName = TryGetProp(targetItem, "GroupName");
    if groupName == nil then
        return 0;
    end
    
    if groupName == 'Weapon' then
        if classType == 'Sword' or classType == 'Staff' or classType =='Rapier' or classType =='Spear' or classType =='Bow' or classType =='Mace' then
            equipTypeRatio = 0.8;
        elseif slot == 'RH' then
        --Twohand Weapon-- 
            equipTypeRatio = 1;
        else
            return 0;
        end
    elseif groupName == 'SubWeapon' then
            equipTypeRatio = 0.6;
        if classType == 'Trinket' then
            equipTypeRatio = 0.4
        end
    elseif groupName == 'Armor' and classType ~= 'Shield' then
        --Amor/Acc--
            equipTypeRatio = 0.33;
    elseif classType == 'Shield' then  
            equipTypeRatio = 0.6;
    else
        return 0;
    end

    --Need Material Count --
    needMatCount = math.floor(((1 + (transcendCount + lv ^ (0.2 + ((math.floor(transcendCount / 3) * 0.03)) + (transcendCount * 0.05))) * equipTypeRatio) * gradeRatio)* 0.5);
    --20180409 초월 개편?�로 ?�한 gradeRatio ??0.5 추�? 50% 감소 --
    if needMatCount < 1 then
        needMatCount = 1;
    end
    
    --EVENT_1811_WEEKEND
    local isServer = false
    if IsServerSection(targetItem) == 1 then
        isServer = true
    end

    --if SCR_EVENT_1903_WEEKEND_CHECK('TRANSCEND', isServer) == 'YES' then
    --    if transcendCount % 2 == 1 then
    --        needMatCount = math.floor(needMatCount/2)
    --        if needMatCount < 1 then
    --            needMatCount = 1
    --        end
    --    end
    --end
    
--    --EVENT_1804_TRANSCEND_DISCOUNT
--    if transcendCount % 2 == 1 then
--        needMatCount = math.floor(needMatCount/2)
--        if needMatCount < 1 then
--            needMatCount = 1
--        end
--    end

    --burning_event
    local pc = GetItemOwner(targetItem)
    if IsBuffApplied(pc, "Event_Even_Transcend_Discount_50") == "YES" then
        if transcendCount % 2 == 1 then
            needMatCount = math.floor(needMatCount/2)
            if needMatCount < 1 then
                needMatCount = 1
            end
        end
    end

    --steam_new_world
    -- if IsBuffApplied(pc, "Event_Steam_New_World_Buff") == "YES" then
    --     needMatCount = math.floor(needMatCount/2)
    --     if needMatCount < 1 then
    --         needMatCount = 1
    --     end
	-- end
    -- PvP ?�이?�인 경우, ?�구??개수 1
    if TryGetProp(targetItem, 'StringArg', 'None') == 'FreePvP' then
        needMatCount = 1
    end

    return SyncFloor(needMatCount);
end

function GET_TRANSCEND_BREAK_ITEM()
    return "Premium_itemDissassembleStone";
end

function GET_TRANSCEND_BREAK_ITEM_COUNT(itemObj)
    if 1 ~= IS_TRANSCEND_ABLE_ITEM(itemObj) then
        return;
    end
    
    local transcend = TryGetProp(itemObj,"Transcend");
    if transcend == nil then
        return 0;
    end
    
    local useMatCount = TryGetProp(itemObj,"Transcend_SucessCount");
    if useMatCount == nil then
        return 0;
    end
    
    local giveCnt = math.floor(useMatCount * 0.9);
    
    if transcend <= 1 then
        giveCnt = 0;
    end
    
    return SyncFloor(giveCnt);
end

function GET_TRANSCEND_BREAK_SILVER(itemObj)
    return GET_TRANSCEND_BREAK_ITEM_COUNT(itemObj) * 10000;
end

function GET_TRANSCEND_SUCCESS_RATIO(itemObj, cls, itemCount)

    local maxItemCls = GET_TRANSCEND_MATERIAL_COUNT(itemObj, nil);
    if maxItemCls == nil or maxItemCls == 0 then
    
        return 0;
    
    end 
    
    return math.floor(itemCount * 100 / maxItemCls);

end

function GET_ITEM_TRANSCENDED_PROPERTY(itemObj, ignoreTranscend)
    if ignoreTranscend == nil then
        ignoreTranscend = 0;
    end

    local retPropType = {};
    local retPropValue = {};
    local basicTooltipPropList = StringSplit(itemObj.BasicTooltipProp, ';');
    for i = 1, #basicTooltipPropList do
        local baseProp = basicTooltipPropList[i];
        if (baseProp == "ATK" or baseProp == "MATK") and CHECK_EXIST_ELEMENT_IN_LIST(retPropType, 'ATK') == false then
            retPropValue[#retPropValue + 1] = GET_UPGRADE_ADD_ATK_RATIO(itemObj, ignoreTranscend);
            retPropType[#retPropType + 1] = "ATK";
        elseif baseProp == "DEF" and CHECK_EXIST_ELEMENT_IN_LIST(retPropType, 'DEF') == false then
            retPropValue[#retPropValue + 1] = GET_UPGRADE_ADD_DEF_RATIO(itemObj, ignoreTranscend);
            retPropType[#retPropType + 1] = "DEF";
        elseif baseProp == "MDEF" and CHECK_EXIST_ELEMENT_IN_LIST(retPropType, 'MDEF') == false then
            retPropValue[#retPropValue + 1] = GET_UPGRADE_ADD_MDEF_RATIO(itemObj, ignoreTranscend);
            retPropType[#retPropType + 1] = "MDEF";
        end
    end

    return retPropType, retPropValue;
end

function CHECK_EXIST_ELEMENT_IN_LIST(list, element)
    for i = 1, #list do
        if list[i] == element then
            return true;
        end
    end
    return false;
end

function GET_UPGRADE_ADD_ATK_RATIO(item, ignoreTranscend)
    if item.Transcend > 0 and ignoreTranscend ~= 1 then
        local class = GetClassByType('ItemTranscend', item.Transcend);
        if class == nil then return 0 end
        local value = class.AtkRatio;        
        -- PVP --
        value = SCR_PVP_ITEM_TRANSCEND_SET(item, value);        
        
        return value;
    end
    local value = 0;
    value = SCR_PVP_ITEM_TRANSCEND_SET(item, value);
    
    return value;
end

function GET_UPGRADE_ADD_DEF_RATIO(item, ignoreTranscend)
    if item.Transcend > 0  and ignoreTranscend ~= 1 then
        local class = GetClassByType('ItemTranscend', item.Transcend);
        local value = class.DefRatio;
        
        -- PVP --
        value = SCR_PVP_ITEM_TRANSCEND_SET(item, value);
        
        return value;
    end
    local value = 0;
    value = SCR_PVP_ITEM_TRANSCEND_SET(item, value);
    
    return value;
end

function GET_UPGRADE_ADD_MDEF_RATIO(item, ignoreTranscend)
    if item.Transcend > 0 and ignoreTranscend ~= 1 then
        local class = GetClassByType('ItemTranscend', item.Transcend);
        local value = class.MdefRatio;
        
        -- PVP --
        value = SCR_PVP_ITEM_TRANSCEND_SET(item, value);
        return value;
    end
    local value = 0;
    value = SCR_PVP_ITEM_TRANSCEND_SET(item, value);
    
    return value;
end

function GET_TRANSCEND_REMOVE_ITEM()
    return "Premium_deleteTranscendStone";
end

function GET_TRANSCEND_SCROLL_TYPE(scrollObj)
    if IS_TRANSCEND_SCROLL_ITEM(scrollObj) ~= 1 then
        return;
    end

    local scrollType = scrollObj.StringArg;
    return scrollType;
end

function IS_TRANSCEND_SCROLL_ITEM(scrollObj)
	local scrollType = TryGetProp(scrollObj, "StringArg");
    local transcend = TryGetProp(scrollObj, "NumberArg1");
    local percent = TryGetProp(scrollObj, "NumberArg2");
    if scrollType == nil or transcend == nil or percent == nil then
        return 0;
    end

	if scrollType == "transcend_Set" then
		return 1;
	elseif scrollType == "transcend_Set_380" then
	    return 1;
	elseif scrollType == "transcend_Set_400" then
		return 1;
	elseif scrollType == "transcend_Set_420" then
		return 1;
	elseif scrollType == "transcend_Set_430" then
		return 1;
	elseif scrollType == "transcend_Set_440" then
		return 1;
        elseif scrollType == "transcend_Set_440_Weapon" or scrollType == "transcend_Set_440_Armor" or scrollType == "transcend_Set_440_Accessory" then
            return 1;
        elseif scrollType == "transcend_Set_440_Weapon_Old" or scrollType == "transcend_Set_440_Armor_Old" or scrollType == "transcend_Set_440_Accessory_Old" then
            return 1;
	elseif scrollType == "transcend_Add" then
        return 1;
	elseif scrollType == "transcend_Set_450" then
        return 1;
    end
	return 0;
end

-- ReLabeling_Rewards_EP12
-- Target Itme TRANSCEND
function IS_TRANSCEND_SCROLL_ITEM_EP12_REWARD(scrollObj)
    local className = TryGetProp(scrollObj, "ClassName")

    if className == "Episode12_Transcend_Scroll_8_Weapon_440Lv" then
        return 1
    elseif className == "Episode12_Transcend_Scroll_8_Armor_440Lv" then
        return 1
    end

    return 0
end

function IS_TRANSCEND_SCROLL_ITEM_EP12_REWARD_USABLE(scrollObj, targetObj)
    local scrollName = TryGetProp(scrollObj, "ClassName")
    local targetGroup = TryGetProp(targetObj, "EquipGroup")
    
    if SHARED_IS_EVENT_ITEM_CHECK(targetObj, "EP12REWARD") ~= true then
        return 0
    end

    if scrollName == "Episode12_Transcend_Scroll_8_Weapon_440Lv" then
        if targetGroup == "THWeapon" or targetGroup == "SubWeapon" or targetGroup == "Weapon" then
            return 1
        end
    elseif scrollName == "Episode12_Transcend_Scroll_8_Armor_440Lv" then
        if targetGroup == "SHIRT" or targetGroup == "PANTS" or targetGroup == "GLOVES" or targetGroup == "BOOTS" then
            return 1
        end
    end

    return 0
end

-- Target Itme Reinforce
function IS_REINFORCE_SCROLL_ITEM_EP12_REWARD(scrollObj)
    local className = TryGetProp(scrollObj, "ClassName")

    if className == "Episode12_Reinforce_Scroll_11_Weapon_440Lv" then
        return 1
    elseif className == "Episode12_Reinforce_Scroll_11_Armor_440Lv" then
        return 1
    end

    return 0
end

function IS_REINFORCE_SCROLL_ITEM_EP12_REWARD_USABLE(scrollObj, targetObj)
    local scrollName = TryGetProp(scrollObj, "ClassName")
    local targetGroup = TryGetProp(targetObj, "EquipGroup")
    
    if SHARED_IS_EVENT_ITEM_CHECK(targetObj, "EP12REWARD") ~= true then
        return 0
    end

    if scrollName == "Episode12_Reinforce_Scroll_11_Weapon_440Lv" then
        if targetGroup == "THWeapon" or targetGroup == "SubWeapon" or targetGroup == "Weapon" then
            return 1
        end
    elseif scrollName == "Episode12_Reinforce_Scroll_11_Armor_440Lv" then
        if targetGroup == "SHIRT" or targetGroup == "PANTS" or targetGroup == "GLOVES" or targetGroup == "BOOTS" then
            return 1
        end
    end

    return 0
end


-- Target Itme Enchant
function IS_ENCHANT_SCROLL_ITEM_EP12_REWARD(scrollObj)
    local className = TryGetProp(scrollObj, "ClassName", "None")
    if className == "Episode12_Enchant_Scroll_Main_440Lv"
        or className == "Episode12_Enchant_Scroll_Sub_440Lv" then
            return 1

    end

    return 0
end

function IS_ENCHANT_SCROLL_ITEM(targetObj)
    local eventItem = TryGetProp(targetObj, "EventEquip", 0);
    if eventItem == 0 then
        return false;
    end

    local itemLevel = TryGetProp(targetObj, "UseLv", 0);
    if itemLevel ~= 440 then
        return false;
    end

    local ItemType_str = TryGetProp(targetObj, "ItemType", "None");
    if ItemType_str ~= "Equip" then
        return false;
    end

    return true;
end

function IS_PREMIUM_ENCHANT_SCROLL_ITEM(targetObj, scrollObj)
	local premium = TryGetProp(targetObj, "PremiumEquip", 0)
    if premium == 0 then
        return false
    end

	local StringArg = TryGetProp(scrollObj, "StringArg", "None")
	if StringArg == "ENCHANT_SCROLL_VIBORA_MAIN" then
		if TryGetProp(targetObj, "GroupName", "None") ~= "Weapon" then
			return false
		end
	elseif StringArg == "ENCHANT_SCROLL_VIBORA_SUB" then
		if TryGetProp(targetObj, "GroupName", "None") ~= "SubWeapon" and TryGetProp(targetObj, "ClassType", "None") ~= "Shield" then
			return false
		end
	else
		return false
	end

    local itemLevel = TryGetProp(targetObj, "UseLv", 0)
    if itemLevel < 440 then
        return false
    end

    local ItemType_str = TryGetProp(targetObj, "ItemType", "None")
    if ItemType_str ~= "Equip" then
        return false
    end

    return true
end

function IS_ENCHANT_SCROLL_ITEM_EP12_REWARD_USABLE_VIBORA_LV1(scrollObj, targetObj)
    local scrollName = TryGetProp(scrollObj, "ClassName")
    local tgtItemClassType = "None"
    if scrollName == "Episode12_Enchant_Scroll_Main_440Lv" then
        tgtItemClassType = "MAIN_Hand"
    elseif scrollName == "Episode12_Enchant_Scroll_Sub_440Lv" then
        tgtItemClassType = "SUB_Hand"
    end

    local iSPass = 0
    local targetGroup = TryGetProp(targetObj, "GroupName", "None")
    if tgtItemClassType == "MAIN_Hand" then
        if targetGroup == "Weapon" then
            iSPass = 1
        end
    elseif tgtItemClassType == "SUB_Hand" then
        if targetGroup ~= "Weapon" then
            iSPass = 1
        end
    end

    if iSPass == 1 then
        if SHARED_IS_EVENT_ITEM_CHECK(targetObj, "ENCHANT") == true then
            return 1
        end
    end
    return 0;
end


function IS_ENCHANT_SCROLL_ITEM_EP12_REWARD_USABLE(scrollObj, targetObj)
    local itemTB = {
        { 'Dagger', 'EP12_Vaivora_Enchant_DAG04_123_1'},
        { 'Dagger', 'EP12_Vaivora_Enchant_DAG04_123_5'},
        { 'Dagger', 'EP12_Vaivora_Enchant_DAG04_123_3'},
        { 'Dagger', 'EP12_Vaivora_Enchant_DAG04_123_2'},
        { 'Dagger', 'EP12_Vaivora_Enchant_DAG04_123'},
        { 'Dagger', 'EP12_Vaivora_Enchant_DAG04_123_4'},
        { 'Rapier', 'EP12_Vaivora_Enchant_RAP04_124'},
        { 'Rapier', 'EP12_Vaivora_Enchant_RAP04_124_1'},
        { 'Staff', 'EP12_Vaivora_Enchant_STF04_127_3'},
        { 'Staff', 'EP12_Vaivora_Enchant_STF04_127_1'},
        { 'Staff', 'EP12_Vaivora_Enchant_STF04_127_2'},
        { 'Staff', 'EP12_Vaivora_Enchant_STF04_127'},
        { 'Musket', 'EP12_Vaivora_Enchant_MUS04_118_2'},
        { 'Musket', 'EP12_Vaivora_Enchant_MUS04_118_1'},
        { 'Musket', 'EP12_Vaivora_Enchant_MUS04_118'},
        { 'Mace', 'EP12_Vaivora_Enchant_MAC04_129'},
        { 'Mace', 'EP12_Vaivora_Enchant_MAC04_129_1'},
        { 'THBow', 'EP12_Vaivora_Enchant_TBW04_126_1'},
        { 'THBow', 'EP12_Vaivora_Enchant_TBW04_126'},
        { 'Sword', 'EP12_Vaivora_Enchant_SWD04_126_1'},
        { 'Sword', 'EP12_Vaivora_Enchant_SWD04_126_2'},
        { 'Sword', 'EP12_Vaivora_Enchant_SWD04_126'},
        { 'Sword', 'EP12_Vaivora_Enchant_SWD04_126_4'},
        { 'Sword', 'EP12_Vaivora_Enchant_SWD04_126_3'},
        { 'THStaff', 'EP12_Vaivora_Enchant_TSF04_129_4'},
        { 'THStaff', 'EP12_Vaivora_Enchant_TSF04_129'},
        { 'THStaff', 'EP12_Vaivora_Enchant_TSF04_129_2'},
        { 'THStaff', 'EP12_Vaivora_Enchant_TSF04_129_3'},
        { 'THStaff', 'EP12_Vaivora_Enchant_TSF04_129_1'},
        { 'Spear', 'EP12_Vaivora_Enchant_SPR04_127_1'},
        { 'Spear', 'EP12_Vaivora_Enchant_SPR04_127'},
        { 'Shield', 'EP12_Vaivora_Enchant_SHD04_122'},
        { 'Shield', 'EP12_Vaivora_Enchant_SHD04_122_1'},
        { 'Cannon', 'EP12_Vaivora_Enchant_CAN04_118_1'},
        { 'Cannon', 'EP12_Vaivora_Enchant_CAN04_118'},
        { 'Bow', 'EP12_Vaivora_Enchant_BOW04_126'},
        { 'Bow', 'EP12_Vaivora_Enchant_BOW04_126_1'},
        { 'THMace', 'EP12_Vaivora_Enchant_TMAC04_118_3'},
        { 'THMace', 'EP12_Vaivora_Enchant_TMAC04_118'},
        { 'THMace', 'EP12_Vaivora_Enchant_TMAC04_118_4'},
        { 'THMace', 'EP12_Vaivora_Enchant_TMAC04_118_2'},
        { 'THMace', 'EP12_Vaivora_Enchant_TMAC04_118_1'},
        { 'THSword', 'EP12_Vaivora_Enchant_TSW04_126_1'},
        { 'THSword', 'EP12_Vaivora_Enchant_TSW04_126_2'},
        { 'THSword', 'EP12_Vaivora_Enchant_TSW04_126'},
        { 'Trinket', 'EP12_Vaivora_Enchant_TRK04_111'},
        { 'THSpear', 'EP12_Vaivora_Enchant_TSP04_128'},
        { 'THSpear', 'EP12_Vaivora_Enchant_TSP04_128_1'},
        { 'THSpear', 'EP12_Vaivora_Enchant_TSP04_128_2'},
        { 'Pistol', 'EP12_Vaivora_Enchant_PST04_122_2'},
        { 'Pistol', 'EP12_Vaivora_Enchant_PST04_122'},
        { 'Pistol', 'EP12_Vaivora_Enchant_PST04_122_1'}
    }


    local scrollName = TryGetProp(scrollObj, "ClassName")
    local targetGroup = TryGetProp(targetObj, "ClassType")
    for i = 1, #itemTB do
        if itemTB[i][1] == targetGroup then
            if itemTB[i][2] == scrollName then
                return 1
            end
        end
    end

    return 0
end



-- Target Itme SetOption
function IS_SETOPTION_SCROLL_ITEM_EP12_REWARD(scrollObj)
    local className = TryGetProp(scrollObj, "ClassName", "None")
    if className == "Episode12_SetOption_Scroll_Armor_440Lv"
        or className == "Episode12_SetOption_Scroll_Weapon_440Lv" then
            return 1

    end

    return 0
end

function IS_SETOPTION_SCROLL_ITEM(targetObj)
    local eventItem = TryGetProp(targetObj, "EventEquip", 0)
    if eventItem == 0 then
        return false;
    end

    local itemLevel = TryGetProp(targetObj, "UseLv", 0)
    if itemLevel ~= 440 then
        return false;
    end

    local ItemType_str = TryGetProp(targetObj, "ItemType", "None")
    if ItemType_str ~= "Equip" then
        return false;
    end

    return true;
end

function PREMIUM_IS_SETOPTION_SCROLL_ITEM(targetObj, scrollObj)
	local premium = TryGetProp(targetObj, "PremiumEquip", 0)
    if premium == 0 then
        return false
    end

	local StringArg = TryGetProp(scrollObj, "StringArg", "None")
	if StringArg == "SETOPTION_SCROLL_ARMOR" then
		if TryGetProp(targetObj, "GroupName", "None") ~= "Armor" or TryGetProp(targetObj, "ClassType", "None") == 'Shield' then
			return false
		end
	elseif StringArg == "SETOPTION_SCROLL_WEAPON" then
		if TryGetProp(targetObj, "GroupName", "None") ~= "Weapon" and TryGetProp(targetObj, "GroupName", "None") ~= "SubWeapon" and TryGetProp(targetObj, "ClassType", "None") ~= 'Shield' then
			return false
		end
	else
		return false
	end

    local itemLevel = TryGetProp(targetObj, "UseLv", 0)
    if itemLevel < 440 then
        return false
    end

    local ItemType_str = TryGetProp(targetObj, "ItemType", "None")
    if ItemType_str ~= "Equip" then
        return false
    end

    return true
end


function ENABLE_SETOPTION_SCROLL_ITEM(targetObj)
    local eventItem = TryGetProp(targetObj, "EventEquip", 0)
    if eventItem == 0 then
        return false;
    end

    local itemLevel = TryGetProp(targetObj, "UseLv", 0)
    if itemLevel ~= 440 then
        return false;
    end

    local ItemType_str = TryGetProp(targetObj, "ItemType", "None")
    if ItemType_str ~= "Equip" then
        return false;
    end

    return true;
end

local targetEquipGroup = TryGetProp(targetObj, "EquipGroup")
if ScrollType == "Weapon" then
    if targetEquipGroup == "THWeapon" 
    or targetEquipGroup == "SubWeapon" 
    or targetEquipGroup == "Weapon" then
        return 1
    end
elseif ScrollType == "Armor" then
    if targetEquipGroup == "SHIRT" 
    or targetEquipGroup == "PANTS" 
    or targetEquipGroup == "GLOVES" 
    or targetEquipGroup == "BOOTS" then
        return 1
    end
end

function IS_SETOPTION_SCROLL_ITEM_EP12_REWARD_USABLE_440(scrollObj, targetObj)
    local scrollName = TryGetProp(scrollObj, "ClassName")
    local tgtItemClassType = "None"
    if scrollName == "Episode12_SetOption_Scroll_Weapon_440Lv" then
        tgtItemClassType = "Weapon_set"
    elseif scrollName == "Episode12_SetOption_Scroll_Armor_440Lv" then
        tgtItemClassType = "Armor_set"
    end

    local iSPass = 0
    local targetEquipGroup = TryGetProp(targetObj, "EquipGroup", "None")
    if tgtItemClassType == "Weapon_set" then
        if targetEquipGroup == "THWeapon" 
        or targetEquipGroup == "SubWeapon" 
        or targetEquipGroup == "Weapon" then
            iSPass = 1
        end
    elseif tgtItemClassType == "Armor_set" then
        if targetEquipGroup == "SHIRT" 
        or targetEquipGroup == "PANTS" 
        or targetEquipGroup == "GLOVES" 
        or targetEquipGroup == "BOOTS" then
            iSPass = 1
        end
    end

    if iSPass == 1 then
        if SHARED_IS_EVENT_ITEM_CHECK(targetObj, "NoSetOpt") == true then
            return 1
        end
    end
    return 0;
end

function IS_SETOPTION_SCROLL_ITEM_EP12_REWARD_USABLE(scrollObj, targetObj)
    local SetOptionTB = {

        { 'Weapon', 'EP12_SetOptionScroll_Weapon_Set_Balinta' },
        { 'Armor', 'EP12_SetOptionScroll_Armor_Set_Balinta' },
        { 'Weapon', 'EP12_SetOptionScroll_Weapon_Set_Sauk' },
        { 'Armor', 'EP12_SetOptionScroll_Armor_Set_Sauk' },
        { 'Weapon', 'EP12_SetOptionScroll_Weapon_Set_Svirti' },
        { 'Armor', 'EP12_SetOptionScroll_Armor_Set_Svirti' },
        { 'Weapon', 'EP12_SetOptionScroll_Weapon_Set_Lydeti' },
        { 'Armor', 'EP12_SetOptionScroll_Armor_Set_Lydeti' }
        

    }


    local itemTB = {

        'Episode12_EP12_FIELD_TOP_001',
        'Episode12_EP12_FIELD_TOP_002',
        'Episode12_EP12_FIELD_TOP_003',
        'Episode12_EP12_FIELD_LEG_001',
        'Episode12_EP12_FIELD_LEG_002',
        'Episode12_EP12_FIELD_LEG_003',
        'Episode12_EP12_FIELD_FOOT_001',
        'Episode12_EP12_FIELD_FOOT_002',
        'Episode12_EP12_FIELD_FOOT_003',
        'Episode12_EP12_FIELD_HAND_001',
        'Episode12_EP12_FIELD_HAND_002',
        'Episode12_EP12_FIELD_HAND_003',
        'Episode12_EP12_FIELD_SWORD',
        'Episode12_EP12_FIELD_THSWORD',
        'Episode12_EP12_FIELD_STAFF',
        'Episode12_EP12_FIELD_THBOW',
        'Episode12_EP12_FIELD_BOW',
        'Episode12_EP12_FIELD_MACE',
        'Episode12_EP12_FIELD_THMACE',
        'Episode12_EP12_FIELD_SHIELD',
        'Episode12_EP12_FIELD_SPEAR',
        'Episode12_EP12_FIELD_THSPEAR',
        'Episode12_EP12_FIELD_DAGGER',
        'Episode12_EP12_FIELD_THSTAFF',
        'Episode12_EP12_FIELD_PISTOL',
        'Episode12_EP12_FIELD_RAPIER',
        'Episode12_EP12_FIELD_CANNON',
        'Episode12_EP12_FIELD_MUSKET',
        'Episode12_EP12_FIELD_TRINKET'
        

    }

    local ScrollType = "None"
    local ScrollTypeName = "None"

    local scrollName = TryGetProp(scrollObj, "ClassName")
    for i = 1, #SetOptionTB do
        if SetOptionTB[i][2] == scrollName then
            ScrollType = SetOptionTB[i][1]
            ScrollTypeName = SetOptionTB[i][2]
            break
        end
    end

    if ScrollType ~= "None" then
        local iSPass = 0

        local targetClassName = TryGetProp(targetObj, "ClassName")
        for i = 1, #itemTB do
            if itemTB[i] == targetClassName then
                iSPass = 1
            end
        end

        --여기서 무기랑 방어구 구분이 안 되고 있음 수정 해야함
        if iSPass == 1 then

            local targetEquipGroup = TryGetProp(targetObj, "EquipGroup")
            if ScrollType == "Weapon" then
                if targetEquipGroup == "THWeapon" 
                or targetEquipGroup == "SubWeapon" 
                or targetEquipGroup == "Weapon" then
                    return 1
                end
            elseif ScrollType == "Armor" then
                if targetEquipGroup == "SHIRT" 
                or targetEquipGroup == "PANTS" 
                or targetEquipGroup == "GLOVES" 
                or targetEquipGroup == "BOOTS" then
                    return 1
                end
            end
        end
            
        

    end

    return 0
end



function IS_TRANSCEND_SCROLL_ITEM_EVENT_2011_5TH(scrollObj)
    local className = TryGetProp(scrollObj, "ClassName")

    if className == "Event_Transcend_Scroll_8_440Lv_Weapon_Ev" then
        return 1
    elseif className == "Event_Transcend_Scroll_8_440Lv_Armor_Ev" then
        return 1
    end

    return 0
end

function IS_TRANSCEND_SCROLL_ITEM_EVENT_2011_5TH_USABLE(scrollObj, targetObj)
    local scrollName = TryGetProp(scrollObj, "ClassName")
    local targetGroup = TryGetProp(targetObj, "EquipGroup")
    local EventType = TryGetProp(targetObj, "Ev_EventType")
    if EventType ~= nil then
        local checkResult = SHARED_IS_EVENT_ITEM_CHECK(targetObj, "EP12REWARD")
        if checkResult == true then
            return 0;
        end
    end
    
    if scrollName == "Event_Transcend_Scroll_8_440Lv_Weapon_Ev" then
        if targetGroup == "THWeapon" or targetGroup == "SubWeapon" or targetGroup == "Weapon" then
            return 1
        end
    elseif scrollName == "Event_Transcend_Scroll_8_440Lv_Armor_Ev" then
        if targetGroup == "SHIRT" or targetGroup == "PANTS" or targetGroup == "GLOVES" or targetGroup == "BOOTS" then
            return 1
        end
    end

    return 0
end

function IS_TRANSCEND_SCROLL_ABLE_ITEM_EP12(itemObj, scrollType, scrollTranscend)
    local Lv = TryGetProp(itemObj, "UseLv", 1)      -- Level 
    local itemGroup = TryGetProp(itemObj, "EquipGroup", "None")     -- Check Armor and Weapon 
    local itemType = TryGetProp(itemObj, "ClassType", "None")       -- Check Accessory
    local potential = TryGetProp(itemObj, "PR") -- Check potential

    if scrollType == "transcend_Set_440_EP12" then
        if IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            return 1;
        else
            return 0;
        end
    end
    return 0;
end

function IS_TRANSCEND_SCROLL_ABLE_ITEM(itemObj, scrollType, scrollTranscend)
    local Lv = TryGetProp(itemObj, "UseLv", 1)      -- Level 
    local itemGroup = TryGetProp(itemObj, "EquipGroup", "None")     -- Check Armor and Weapon 
    local itemType = TryGetProp(itemObj, "ClassType", "None")       -- Check Accessory
    local potential = TryGetProp(itemObj, "PR") -- Check potential

    if scrollType == "transcend_Set" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            return 1;
        else
            return 0
        end
    elseif scrollType == "transcend_Set_380" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 380 then -- Is item UseLv under 380 then
                return 1;
            end
        return 0
        end
    elseif scrollType == "transcend_Set_400" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 400 then -- Is item UseLv under 400 then
                return 1;
            end
        return 0
        end
    elseif scrollType == "transcend_Set_420" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 420 then -- Is item UseLv under 420 then
                return 1;
            end
        return 0
        end
    elseif scrollType == "transcend_Set_430" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 430 then -- Is item UseLv under 430 then
                return 1;
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then -- Is item UseLv under 440 then
                return 1;
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Weapon" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then
                if itemGroup  == "THWeapon" or itemGroup == "SubWeapon" or itemGroup  == "Weapon" then -- Is item UseLv under 440 and is weapon then
                    return 1;
                end
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Armor" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then
                if itemGroup  == "SHIRT" or itemGroup == "PANTS" or itemGroup == "GLOVES" or itemGroup == "BOOTS" then -- Is item UseLv under 440 and is armor then
                    return 1;
                end
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Accessory" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then
                if itemType == "Neck" or itemType == "Ring" then -- Is item UseLv under 440 and is Accessory then
                    return 1;
                end
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Weapon_Old" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then
                if itemGroup  == "THWeapon" and potential == 0 or itemGroup == "SubWeapon" and potential == 0 or itemGroup  == "Weapon" and potential == 0 then -- Is item UseLv under 440 and is weapon and potential == 0 then
                    return 1;
                end
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Armor_Old" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then
                if itemGroup  == "SHIRT" and potential == 0 or itemGroup == "PANTS" and potential == 0 or itemGroup == "GLOVES" and potential == 0 or itemGroup == "BOOTS" and potential == 0 then -- Is item UseLv under 440 and is armor and potential == 0 then
                    return 1;
                end
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Accessory_Old" then
        if SCR_TARGET_TRANSCEND_CHECK(itemObj, scrollTranscend) == 1 and IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            if Lv <= 440 then
                if itemType == "Neck" and potential == 0 or itemType == "Ring" and potential == 0 then -- Is item UseLv under 440 and is Accessory and potential == 0 then
                    return 1;
                end
            end
        return 0
        end
    elseif scrollType == "transcend_Set_440_Event" then
        if Lv == 440 then
            if TryGetProp(itemObj, 'EventEquip', 0) == 1 then -- Is item UseLv under 440 and  Event Equip then
                return 1;
            end
        end
        return 0
	elseif scrollType == "transcend_Set_450" then
        if Lv <= 450 and TryGetProp(itemObj, 'Transcend', 0) < 10 then
           return 1;
        end
        return 0
    elseif scrollType == "transcend_Add" then
        if IS_TRANSCEND_ABLE_ITEM(itemObj) == 1 then
            return 1;
        else
            return 0;
        end
    elseif scrollType == "ENCHANT" then
        if SHARED_IS_EVENT_ITEM_CHECK_SCROLL(itemObj, scrollType) == 1 then
            return 1;
        else
            return 0;
        end
    end
    return 0;
end

function GET_ANTICIPATED_TRANSCEND_SCROLL_SUCCESS(itemObj, scrollObj)
    if IS_TRANSCEND_SCROLL_ITEM(scrollObj) ~= 1 then
        return;
    end
    local scrollType = scrollObj.StringArg;
    local scrollTranscend = scrollObj.NumberArg1;
    if IS_TRANSCEND_SCROLL_ABLE_ITEM(itemObj, scrollType, scrollTranscend) ~= 1 then
        return;
    end
    
    local transcend = scrollObj.NumberArg1;
    local percent = scrollObj.NumberArg2;
    if scrollType == nil or transcend == nil or percent == nil then
        return;
    end
    
    if scrollType == "transcend_Set" or scrollType == "transcend_Set_380" or scrollType == "transcend_Set_400" or scrollType == "transcend_Set_420"  or scrollType == "transcend_Set_430" or scrollType == "transcend_Set_440" or scrollType == "transcend_Set_450" then
        return transcend, percent;
    elseif scrollType == "transcend_Set_440_Weapon" or scrollType == "transcend_Set_440_Armor" or scrollType == "transcend_Set_440_Accessory" then
        return transcend, percent;
    elseif scrollType == "transcend_Set_440_Weapon_Old" or scrollType == "transcend_Set_440_Armor_Old" or scrollType == "transcend_Set_440_Accessory_Old" then
        return transcend, percent;
    elseif scrollType == "transcend_Add" then
        local curTranscend = 0;
        if IS_TRANSCEND_ITEM(itemObj) == 1 then
            curTranscend = itemObj.Transcend;
        end
        return curTranscend + transcend, percent;
    end
end
