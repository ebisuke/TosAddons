MAX_VIBORA_LEVEL = 4  -- 현재 바이보라 최대 레벨
MAX_GODDESS_LEVEL = 3  -- 현재 여신 마신 최대 레벨

MATERIAL_COUNT = {300, 450, 750, 1200, 1950, 3150}

g_vibora_weapon_list = nil

function make_vibora_list()
    if g_vibora_weapon_list ~= nil then
        return
    end

    g_vibora_weapon_list = {}

    local xmlList, xmlCount = GetClassList("Item")
    for i = 0, xmlCount - 1 do
        local cls = GetClassByIndexFromList(xmlList, i)
        if cls ~= nil then
            local string_arg = TryGetProp(cls, 'StringArg', 'None')
            local lv = TryGetProp(cls, 'NumberArg1', 0)
            if string_arg == 'Vibora' and lv >= 1 then
                if g_vibora_weapon_list[lv] == nil then
                    g_vibora_weapon_list[lv] = {}                    
                end

                if g_vibora_weapon_list[lv][cls.ClassType] == nil then
                    g_vibora_weapon_list[lv][cls.ClassType] = {}
                end
                
                table.insert(g_vibora_weapon_list[lv][cls.ClassType], cls.ClassName)
            end
        end
    end
end

make_vibora_list()  -- 바이보라 리스트 생성

-- nil이 될 수 있음
function GET_VIBORA_SELECT_LIST(class_type, lv)
    if g_vibora_weapon_list == nil then
        make_vibora_list()        
    end

    return g_vibora_weapon_list[lv][class_type]
end

function IS_ENABLE_EXTRACT_OPTION(item)
    if TryGetProp(item,'Extractable', 'No') ~= 'Yes' or TryGetProp(item,'LifeTime', 1) ~= 0 then
        return false;
    end

    if IS_LEGEND_GROUP_ITEM(item) == false and item.NeedRandomOption == 1 then
        return false;    
    end

    return true;
end

function IS_LEGEND_GROUP_ITEM(item)
    if TryGetProp(item, 'LegendGroup', 'None') == 'None' then
        return false;
    end
    return true;
end

function GET_OPTION_EXTRACT_KIT_LIST()
    return {'Extract_kit', 'Extract_kit_Sliver', 'Extract_kit_Gold', 'Extract_kit_Gold_NotFail', 'Tuto_Extract_kit_silver_Team', 'Tuto_Extract_kit_Gold_Team'};
end

function IS_VALID_OPTION_EXTRACT_KIT(itemCls)
    local list = GET_OPTION_EXTRACT_KIT_LIST();
    for i = 1, #list do
        if list[i] == itemCls.StringArg and tonumber(TryGetProp(itemCls, "ItemLifeTimeOver", 0)) == 0 then
            return true;
        end
    end
    return false;
end

function GET_OPTION_EXTRACT_MATERIAL_NAME()
    return 'misc_ore23'; 
end

function GET_OPTION_EXTRACT_NEED_MATERIAL_COUNT(item)

    if item.UseLv > 440 then
        local index = (item.UseLv - 440) / 10
        return MATERIAL_COUNT[index] * (5 - item.ItemGrade)
    else
        return math.floor(item.UseLv / (3 * (5 - item.ItemGrade)));
    end
end

function IS_ENABLE_NOT_TAKE_MATERIAL_KIT(kitCls)
    if kitCls.StringArg == 'Extract_kit_Sliver' or kitCls.StringArg == 'Extract_kit_Gold_NotFail' or kitCls.StringArg == 'Extract_kit_Gold_NotFail_Recipe' or kitCls.StringArg == 'Extract_kit_Gold_NotFail_Rand' or kitCls.StringArg == 'Tuto_Extract_kit_silver_Team' or kitCls.StringArg == 'Tuto_Extract_kit_Gold_Team' then 
        return true;
    end
    return false;
end

-- 튜토리얼에서만 사용할 키트
function IS_ENABLE_TUTORIAL_KIT_ITEM(kitCls)
    -- 새롭게 추가될 키트 아이템 StringArg 추가해야함
    if kitCls.StringArg == 'Tuto_Extract_kit_silver_Team' or kitCls.StringArg == 'Tuto_Extract_kit_Gold_Team' then
        return true
	end

	return false;
end

-- 튜토리얼에서만 사용할 장비 아이템
function IS_ENABLE_TUTORIAL_TARGET_ITEM(item)
	if TryGetProp(item, 'StringArg', 'None') == "Tutorial" then
		return true;
	end

	return false;
end

-- 아이커 연성 재료 정보 관련 내용
function GET_OPTION_LEGEND_EXTRACT_KIT_LIST()
    return {'Dirbtumas_kit', 'Dirbtumas_kit_Sliver'};
end

function IS_VALID_OPTION_LEGEND_EXTRACT_KIT(itemCls)
    local list = GET_OPTION_LEGEND_EXTRACT_KIT_LIST();
    for i = 1, #list do
        if list[i] == itemCls.StringArg and tonumber(TryGetProp(itemCls, "ItemLifeTimeOver", 0)) == 0 then
            return true;
        end
    end
    return false;
end

function GET_OPTION_LEGEND_EXTRACT_MATERIAL_NAME()
    return 'misc_ore23'; 
end

function GET_OPTION_LEGEND_EXTRACT_NEED_MATERIAL_COUNT(item)
    if item.UseLv > 440 then
        local index = (item.UseLv - 440) / 10
        return (MATERIAL_COUNT[index] * 7) * (5 - item.ItemGrade)
    else
        return math.floor(item.UseLv * (item.ItemGrade + 3) / (3 * (5 - item.ItemGrade)));
    end
end

function IS_ENABLE_NOT_TAKE_MATERIAL_KIT_LEGEND_EXTRACT(kitCls)
    if kitCls.StringArg == 'Dirbtumas_kit_Sliver' then 
        return true;
    end
    return false;
end
--------------------------------

function IS_ENABLE_NOT_TAKE_POTENTIAL_BY_EXTRACT_OPTION(kitCls)
    if kitCls.StringArg == 'Extract_kit_Gold' or kitCls.StringArg == 'Tuto_Extract_kit_Gold_Team' then 
        return true;
    end
    return false;
end

function GET_OPTION_EXTRACT_TARGET_ITEM_NAME(inheritanceItemName)
    if inheritanceItemName.GroupName == 'Armor' then
        return 'Armor_icor';
    end
    return 'Weapon_icor';
end

function GET_OPTION_EQUIP_NEED_MATERIAL_COUNT(item)
    return 0;
end

function GET_OPTION_EQUIP_CAPITAL_MATERIAL_NAME() 
    return 'misc_BlessedStone';
end

function GET_OPTION_EQUIP_NEED_CAPITAL_COUNT(item)
    return 0;
end

function GET_OPTION_EQUIP_NEED_SILVER_COUNT(item)
    return item.UseLv * 30000;
end

function OVERRIDE_INHERITANCE_PROPERTY(item)
    if item == nil or (item.InheritanceItemName == 'None' and item.InheritanceRandomItemName == 'None') then
        return;
    end

    local inheritanceItem = GetClass('Item', item.InheritanceItemName);
    if inheritanceItem == nil then
        inheritanceItem = GetClass('Item', item.InheritanceRandomItemName);
        
        if inheritanceItem == nil then
            return;
        end
    end

    local basicTooltipPropList = StringSplit(item.BasicTooltipProp, ';');
    local basicTooltipPropTable = {};
    for i = 1, #basicTooltipPropList do
        basicTooltipPropTable[basicTooltipPropList[i]] = true;
    end

    local commonPropList = GET_COMMON_PROP_LIST();
    for i = 1, #commonPropList do
        local propName = commonPropList[i];
        if basicTooltipPropTable[propName] == nil then
            item[propName] = item[propName] + inheritanceItem[propName];
        end
    end
end

function SCR_VELLCOFFER_MATCOUNT(pc)
    local matCount = 2;
    
    for i = 5, 7 do
        local rndCount = IMCRandom(1, i)
        if rndCount == 1 then
            matCount = matCount + 1
        else
            break;
        end
    end
    
    return matCount;
end

function SCR_SEVINOSE_MATCOUNT(pc)
    local matCount = 1;
    
    for i = 10, 12 do
        local rndCount = IMCRandom(1, i)
        if rndCount == 1 then
            matCount = matCount + 1
        else
            break;
        end
    end
    
    return matCount;
end

function IS_100PERCENT_SUCCESS_EXTRACT_ICOR_ITEM(item)
    if item == nil then
        return false;
    end

    return item.StringArg == 'Extract_kit_Gold_NotFail' or item.StringArg == 'Extract_kit_Gold_NotFail_Rand' or item.StringArg == 'Extract_kit_Gold_NotFail_Recipe';
end

-- 아이커 장착 해제 조건 체크, 고정옵션(InheritanceItemName), 랜덤옵션(InheritanceRandomItemName)
function IS_ENABLE_RELEASE_OPTION(item)   
    if TryGetProp(item, 'ItemType', 'None') == 'Equip' then
        if TryGetProp(item, 'InheritanceItemName', 'None') ~= 'None' or TryGetProp(item, 'InheritanceRandomItemName', 'None') ~= 'None' then
            return true        
        end
    end
    
    return false;
end;

function GET_OPTION_RELEASE_COST(item, taxRate, isLegendShop)
    if item == nil then
        return 0, 0;
    end;

    local useLv = TryGetProp(item, 'UseLv');
    local priceWithoutTax = useLv * 100;
    
    if isLegendShop ~= nil and isLegendShop ~= 1 then
        -- 앉아서 하면 1.2배, 세율 미적용
        priceWithoutTax = priceWithoutTax * 1.2;
    end
    
    local price = priceWithoutTax;
    if taxRate ~= nil then
        price = tonumber(CALC_PRICE_WITH_TAX_RATE(price, taxRate));
    end;
    
    return SyncFloor(price), SyncFloor(priceWithoutTax);
end;

-- 아이커가 가능한 랜덤 레전드 아이템인가?
function IS_ICORABLE_RANDOM_LEGEND_ITEM(item)    
    if TryGetProp(item, 'NeedRandomOption', 0) == 1 and TryGetProp(item, 'LegendGroup', 'None') ~= 'None' then
        return true
    else
        return false
    end
end
function GET_ICOR_MULTIPLE_MAX_COUNT()
    local max_count = 6
    
    return max_count
end

function GET_COMPOSITION_VIROBA_SOURCE_COUNT()
    local max_count = 3
    
    return max_count
end
-- Lv1 바이보라 장비 또는 아이커
function IS_COMPOSABLE_VIRORA(item)
    local group_name = TryGetProp(item, 'GroupName', 'None')
    if group_name == 'None' then
        return false, 'None'
    end

    if group_name == 'Icor' then
        local class_name = TryGetProp(item, 'InheritanceItemName', 'None')
        local cls = GetClass('Item', class_name)
        if cls ~= nil then
            if TryGetProp(cls, 'StringArg', 'None') == 'Vibora' and TryGetProp(cls, 'NumberArg1', 0) == 1 then
                return true, TryGetProp(cls, 'ClassName', 'None')
            end
        end
    else    
        if TryGetProp(item, 'StringArg', 'None') == 'Vibora' and TryGetProp(item, 'NumberArg1', 0) == 1 then
            return true, TryGetProp(item, 'ClassName', 'None')
        end
    end

    return false, 'None'
end


-- 바이보라 업그레이드
function GET_UPGRADE_VIROBA_SOURCE_COUNT()
    local max_count = 2;
    
    return max_count
end

-- 가능여부, ClassName, NumberArg1
function CAN_UPGRADE_VIBORA(item)
    local group_name = TryGetProp(item, 'GroupName', 'None')
    if group_name == 'None' then
        return false, 'None', 0
    end

    if group_name == 'Icor' then
        local class_name = TryGetProp(item, 'InheritanceItemName', 'None')
        local cls = GetClass('Item', class_name)
        if cls ~= nil then
            if TryGetProp(cls, 'StringArg', 'None') == 'Vibora' then
                return true, TryGetProp(cls, 'ClassName', 'None'), TryGetProp(cls, 'NumberArg1', 0)
            end
        end
    else    
        if TryGetProp(item, 'StringArg', 'None') == 'Vibora' then
            return true, TryGetProp(item, 'ClassName', 'None'), TryGetProp(item, 'NumberArg1', 0)
        end
    end
    return false, 'None', 0
end

-- 바이보라 연성 재료인가?
function IS_UPGARDE_VIBORA_MISC(name, dic)
    if dic == nil then
        return false
    end

    if dic[name] ~= nil then
        return true
    end

    return false
end
-- 여신/마신 연성 재료인가?
function IS_UPGARDE_GODDESS_MISC(name, dic)
    if dic == nil then
        return false
    end

    if dic[name] ~= nil then
        return true
    end

    return false
end

-- 바이보라 연성에서는 사용하지 않음, 스킬젬에서 사용함
function GET_REQUIRED_VIBORA_MISC_COUNT(goal_lv)
    if goal_lv == 2 then
        return 20
    end
    return 20
end

-- 연성된 결과로 얻을 아이템 ClassName를 가져온다.
function GET_UPGRADE_VIBORA_ITEM_NAME(item)
    local group_name = TryGetProp(item, 'GroupName', 'None')
    if group_name == 'None' then
        return 'None'
    end

    if group_name == 'Icor' then
        local class_name = TryGetProp(item, 'InheritanceItemName', 'None')
        local cls = GetClass('Item', class_name)
        if cls ~= nil then
            item = cls            
        end    
    end

    if TryGetProp(item, 'StringArg', 'None') ~= 'Vibora' then
        return 'None'
    end

    local lv = TryGetProp(item, 'NumberArg1', 0)
    if lv < 1 then
        return 'None'
    end

    local class_name = TryGetProp(item, 'ClassName', 'None')

    local vibora_name = ''
    local token = StringSplit(class_name, '_')
    local end_count = #token - 1

    local goal_lv = lv + 1;
    if goal_lv == 2 then
        end_count = end_count + 1
    end

    local i = 1
    for i = 1, end_count do
        vibora_name = vibora_name .. token[i] .. '_'
    end
    
    vibora_name = vibora_name .. 'Lv' .. tostring(goal_lv)

    return vibora_name
end

-- 1레벨 바이보라 ClassName을 얻어온다
function GET_LV1_VIBORA_CLASS_NAME(name, lv)
    if lv == 1 then
        return name
    else        
        local token = StringSplit(name, '_')
        local ret = ''
        for i = 1, #token - 1 do
            if i == #token - 1 then
                ret = ret .. token[i]
            else
                ret = ret .. token[i] .. '_'
            end            
        end
        return ret
    end
end

-- 리스트 중 check_count 까지 모두 동일한 아이템인가? 같은 종류 아이커/장비, NumberArg1 수치
 function IS_VALID_UPGRADE_VIBORA_ITEM_LIST(list, check_count)
    if #list < check_count or check_count < 1 then
        return false, 'None', 0
    end

    local dic_name = {}
    local dic_lv = {}
    local level = 0
    local class_name = ''
    
    for i = 1, check_count do
        local ret, name, lv = CAN_UPGRADE_VIBORA(list[i])
        
        if ret == false then            
            return false, 'None', 0
        end
        
        dic_name[name] = 1        
        dic_lv[lv] = 1
        if level == 0 then
            level = lv
        end
        if class_name == '' then
            class_name = name
        end
    end

    local name_count = 0
    local lv_count = 0

    for k, v in pairs(dic_name) do        
        name_count = name_count + 1
    end

    for k, v in pairs(dic_lv) do
        lv_count = lv_count + 1
    end

    if name_count ~= 1 or lv_count ~= 1 then
        return false, 'None', 0
    end

    return true, class_name, level
 end

-- 바이보라 연성에 필요한 재료를 가져온다.
function GET_UPGRADE_VIBORA_MISC_LIST(goal_lv)
    local dic = {}
    local dic_index = {}

    if goal_lv == 2 then
        dic_index['Vibora_misc_Lv2'] = 1
        dic['Vibora_misc_Lv2'] = 20        
        return dic, 1, dic_index
    elseif goal_lv == 3 then
        dic['EP12_enrich_Vibora_misc'] = 1
        dic_index['EP12_enrich_Vibora_misc'] = 1        
        return dic, 1, dic_index
    elseif goal_lv == 4 then
        dic['EP12_enrich_Vibora_misc'] = 1
        dic_index['EP12_enrich_Vibora_misc'] = 1        
        return dic, 1, dic_index
    end

    return nil, 0, nil
end
-- 바이보라 연성에 필요한 실버를 가져온다.
function GET_UPGRADE_VIBORA_SILVER_COST(goal_lv)
    if goal_lv == 2 then
        return 0
    elseif goal_lv == 3 then
        return 5000000
    elseif goal_lv == 4 then
        return 7000000
    end

    return 100000000
end
-- 바이보라 최대 업그레이드 카운트, 현재 레벨에서 다음 레벨로 가기위해 시도해야하는 횟수
function GET_UPGRADE_VIBORA_MAX_COUNT(goal_lv)
    if goal_lv == 2 then
        return 0
    elseif goal_lv == 3 then
        return 15
    elseif goal_lv == 4 then
        return 40
    end

    return 1000
end


--------------------------------- 여신, 마신 업그레이드 -------------------------------------------------------
-- 리스트 중 check_count 까지 모두 동일한 아이템인가? 같은 종류 아이커/장비, NumberArg1 수치
function IS_VALID_UPGRADE_GODDESS_ITEM_LIST(list, check_count)
    if #list < check_count or check_count < 1 then
        return false, 'None', 0
    end

    local dic_name = {}
    local dic_lv = {}
    local level = 0
    local class_name = ''
    
    for i = 1, check_count do
        local ret, name, lv = CAN_UPGRADE_GODDESS(list[i])
        
        if ret == false then            
            return false, 'None', 0
        end
        
        dic_name[name] = 1        
        dic_lv[lv] = 1
        if level == 0 then
            level = lv
        end
        if class_name == '' then
            class_name = name
        end
    end

    local name_count = 0
    local lv_count = 0

    for k, v in pairs(dic_name) do        
        name_count = name_count + 1
    end

    for k, v in pairs(dic_lv) do
        lv_count = lv_count + 1
    end

    if name_count ~= 1 or lv_count ~= 1 then
        return false, 'None', 0
    end

    return true, class_name, level
end

-- 가능여부, ClassName, NumberArg1
function CAN_UPGRADE_GODDESS(item)
    local group_name = TryGetProp(item, 'GroupName', 'None')
    if group_name == 'None' then
        return false, 'None', 0
    end

    if group_name == 'Icor' then
        local class_name = TryGetProp(item, 'InheritanceItemName', 'None')
        local cls = GetClass('Item', class_name)
        if cls ~= nil then
            if TryGetProp(cls, 'StringArg', 'None') == 'goddess' or TryGetProp(cls, 'StringArg', 'None') == 'evil' then
                return true, TryGetProp(cls, 'ClassName', 'None'), TryGetProp(cls, 'NumberArg1', 0)
            end
        end
    else
        if TryGetProp(item, 'StringArg', 'None') == 'goddess' or TryGetProp(item, 'StringArg', 'None') == 'evil' then
            return true, TryGetProp(item, 'ClassName', 'None'), TryGetProp(item, 'NumberArg1', 0)
        end
    end
    return false, 'None', 0
end

function GET_UPGRADE_GODDESS_ITEM_NAME(item)
    local group_name = TryGetProp(item, 'GroupName', 'None')
    if group_name == 'None' then
        return 'None'
    end

    if group_name == 'Icor' then
        local class_name = TryGetProp(item, 'InheritanceItemName', 'None')
        local cls = GetClass('Item', class_name)
        if cls ~= nil then
            item = cls            
        end    
    end

    if TryGetProp(item, 'StringArg', 'None') ~= 'evil' and TryGetProp(item, 'StringArg', 'None') ~= 'goddess' then
        return 'None'
    end

    local lv = TryGetProp(item, 'NumberArg1', 0)
    if lv < 1 then
        return 'None'
    end

    local class_name = TryGetProp(item, 'ClassName', 'None')

    local vibora_name = ''
    local token = StringSplit(class_name, '_')
    local end_count = #token - 1

    local goal_lv = lv + 1;
    if goal_lv == 2 then
        end_count = end_count + 1
    end

    local i = 1
    for i = 1, end_count do
        vibora_name = vibora_name .. token[i] .. '_'
    end
    
    vibora_name = vibora_name .. 'Lv' .. tostring(goal_lv)

    return vibora_name
end

-- 여신/마신 연성에 필요한 재료를 가져온다.
function GET_UPGRADE_GODDESS_MISC_LIST(goal_lv)
    local dic = {}
    local dic_index = {}
    if goal_lv == 2 then        
        dic_index['EP12_enrich_Goddess_misc'] = 1    
        dic['EP12_enrich_Goddess_misc'] = 1           
        return dic, 1, dic_index
    elseif goal_lv == 3 then        
        dic_index['EP12_enrich_Goddess_misc'] = 1    
        dic['EP12_enrich_Goddess_misc'] = 1
        return dic, 1, dic_index
    end

    return nil, 0, nil
end

-- 여신/마신 연성에 필요한 실버를 가져온다.
function GET_UPGRADE_GODDESS_SILVER_COST(goal_lv)
    if goal_lv == 2 then
        return 2500000
    elseif goal_lv == 3 then
        return 4000000
    end

    return 100000000
end
-- 여신/마신 최대 업그레이드 카운트, 현재 레벨에서 다음 레벨로 가기위해 시도해야하는 횟수
function GET_UPGRADE_GODDESS_MAX_COUNT(goal_lv)
    if goal_lv == 2 then
        return 10
    elseif goal_lv == 3 then
        return 25
    end

    return 1000
end
--------------------------------- 여신, 마신 업그레이드 -------------------------------------------------------


function IS_DECOMPOSABLE_ARK(item)
    if TryGetProp(item, 'ClassType', 'None') ~= 'Ark' then
        return false, 'decomposeCant'
	end

	local decomposeAble = TryGetProp(item, 'DecomposeAble')
    if decomposeAble == nil or decomposeAble == "NO" then
        return false, 'decomposeCant'
	end
	
	local target_lv = TryGetProp(item, 'ArkLevel', 1)
	local target_exp = TryGetProp(item, 'ArkExp', 0)
	if target_lv > 1 or target_exp > 0 then
		return false, 'DecomposeArkCant'
	end

	return true, 'None'
end

function GET_LEGEND_MISC_DECOMPOSE_COST()
    local item_name = 'HiddenAbility_Piece'
    local item_count = 10

    return item_name, item_count
end

function IS_DECOMPOSABLE_LEGEND_MISC(item)
    if item ~= nil then
        local stringArg = TryGetProp(item, 'StringArg', 'None')
        if stringArg == 'LegendMiscChange' then
            return true
        end
    end

    return false
end

function GET_ACC_EP12_DECOMPOSE_COST()
    local value = 10000000
    return value
end

function IS_DECOMPOSABLE_ACC_EP12(item)
    if item ~= nil then
        local stringArg = TryGetProp(item, 'StringArg', 'None')
        if stringArg == 'Acc_EP12' then
            return true
        end
    end

    return false
end

function IS_DECOMPOSABLE_VIBORA(item)
    if item ~= nil then
        if TryGetProp(item, 'GroupName', 'None') == 'Icor' then
            local name = TryGetProp(item, 'InheritanceItemName', 'None')
            local cls = GetClass('Item', name)
            if cls ~= nil then                
                if TryGetProp(cls, 'StringArg', 'None') == 'Vibora' and TryGetProp(cls, 'NumberArg1', 0) == 1 then
                    return true
                end     
            end
        else
            local stringArg = TryGetProp(item, 'StringArg', 'None')
            if stringArg == 'Vibora' and TryGetProp(item, 'NumberArg1', 0) == 1 then
                return true
            end
        end
    end

    return false
end

function GET_VIBORA_DECOMPOSE_MISC_COUNT(item)    
    local lv = 1
    if TryGetProp(item, 'GroupName', 'None') == 'Icor' then
        local name = TryGetProp(item, 'InheritanceItemName', 'None')
        local cls = GetClass('Item', name)
        if cls ~= nil then                
            lv = TryGetProp(cls, 'NumberArg1', 0)
        end
    else
        lv = TryGetProp(item, 'NumberArg1', 0)
    end

    if lv == 1 then
        return 500
    end

    return 500
end

--------------------------------- 세트 옵션 ---------------------------------
function GET_SAVED_SETOPTION_LIST(pc)
    local acc_obj = nil
    if IsServerSection() == 1 and pc ~= nil then
        acc_obj = GetAccountObj(pc)
    else
        acc_obj = GetMyAccountObj()
    end

    if acc_obj == nil then
        return nil
    end

    local option_list = {}

    local set_cls_list, cnt = GetClassList('LegendSetItem')
    for i = 0, cnt - 1 do
        local set_cls = GetClassByIndexFromList(set_cls_list, i)
        if set_cls ~= nil then
            local set_cls_name = TryGetProp(set_cls, 'ClassName', 'None')
            if acc_obj[set_cls_name] ~= nil and acc_obj[set_cls_name] == 1 then
                table.insert(option_list, set_cls_name)
            end
        end
    end

    return option_list
end

function IS_SETOPTION_MATCH(item_list)
    local prefix_list = {}
    local no_option_flag = false
    for k, item in pairs(item_list) do
        local prefix = TryGetProp(item, 'LegendPrefix', 'None')
        if prefix ~= 'None' and table.find(prefix_list, prefix) <= 0 then
            table.insert(prefix_list, prefix)
        elseif prefix == 'None' then
            no_option_flag = true
        end
    end

    if #prefix_list == 0 then
        return 'None'
    elseif #prefix_list == 1 and no_option_flag == false then
        return prefix_list[1]
    else
        return 'DIFF'
    end
end

-- 현재 적용된 세트 옵션 제외 적용 가능한 세트 옵션 리스트 반환
function GET_ENABLE_SETOPTION_LIST(itemObj)
    local option_list = {};
    
    local legendGroup = TryGetProp(itemObj, "LegendGroup", "None");
    local setOption = TryGetProp(itemObj, "LegendPrefix", "None");
    local clsList, cnt = GetClassList("LegendSetItem");
	for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        if string.find(cls.LegendGroup, legendGroup) ~= nil and cls.ClassName ~= setOption then
            option_list[#option_list + 1] = cls.ClassName;
        end
	end

    return option_list;
end
--------------------------------- 세트 옵션 ---------------------------------


function GIBBS_SAMPLING(list, max_number)
    local production_sum = 0
    local random_num = IMCRandom(1, max_number)
    for k, v in pairs(list) do
        production_sum = production_sum + tonumber(v)
        if production_sum >= random_num then            
            return k
        end
    end
    
    return #list
end

function IS_EXTRACTABLE_SPECIAL_UNIQUE(item)
    local str_arg = TryGetProp(item, 'StringArg', 'None')
    local num_arg = TryGetProp(item, 'NumberArg1', 0)
    if str_arg == 'Vibora' and num_arg > 1 then
        return false
    elseif str_arg == 'goddess' or str_arg == 'evil' then
        return false
    end

    return true
end