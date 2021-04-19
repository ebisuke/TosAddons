function GET_LIMITATION_TO_BUY(tpItemID)
    local tpItemObj = GetClassByType('TPitem', tpItemID);    
    if tpItemObj == nil then
        return 'NO', 0;
    end

    local accountLimitCount = TryGetProp(tpItemObj, 'AccountLimitCount');
    if accountLimitCount ~= nil and accountLimitCount > 0 then
        return 'ACCOUNT', accountLimitCount;
    end

    local monthLimitCount = TryGetProp(tpItemObj, 'MonthLimitCount');
    if monthLimitCount ~= nil and monthLimitCount > 0 then
        return 'MONTH', monthLimitCount;
    end

    return 'NO', 0;
end

function GET_LIMITATION_TO_BUY_WITH_SHOPTYPE(tpItemID, shopType)
    local tpItemObj = nil
    -- shopType normal(0), return User(1), newbie(2)
    if shopType == 1 then
        tpItemObj = GetClassByType('TPitem_Return_User', tpItemID);
    elseif shopType == 2 then
        tpItemObj = GetClassByType('TPitem_User_New', tpItemID);
    else
        tpItemObj = GetClassByType('TPitem', tpItemID);
    end
    
    if tpItemObj == nil then
        return 'NO', 0;
    end

    local accountLimitCount = TryGetProp(tpItemObj, 'AccountLimitCount');
    if accountLimitCount ~= nil and accountLimitCount > 0 then
        return 'ACCOUNT', accountLimitCount;
    end

    local monthLimitCount = TryGetProp(tpItemObj, 'MonthLimitCount');
    if monthLimitCount ~= nil and monthLimitCount > 0 then
        return 'MONTH', monthLimitCount;
    end

    return 'NO', 0;
end

itemOptCheckTable = nil;
function CREATE_ITEM_OPTION_TABLE()
    --추가할 프로퍼티가 존재한다면 밑에다가 추가하면 됨.
    itemOptCheckTable = {
    "Reinforce_2", -- 강화
    "Transcend", -- 초월
    "IsAwaken", -- 각성
    "RandomOptionRareValue",
    }
end

function IS_MECHANICAL_ITEM(itemObject)
    if itemOptCheckTable == nil then
        CREATE_ITEM_OPTION_TABLE();
    end

    if itemOptCheckTable == nil or #itemOptCheckTable == 0 then
        return false;
    end 

    for i = 1, #itemOptCheckTable do
        local itemProp = TryGetProp(itemObject, itemOptCheckTable[i]);
        if itemProp ~= nil then
            if itemProp > 0 then
                return true;
            end
        end
    end

    local maxSocketCnt = TryGetProp(itemObject, 'MaxSocket', 0);
    if maxSocketCnt > 0 then
        if IsServerSection() == 0 then
            local invitem = GET_INV_ITEM_BY_ITEM_OBJ(itemObject);
            if invitem == nil then
                return false;
            end

            if itemObject.MaxSocket > 100 then itemObject.MaxSocket = 0 end
            for i = 0, itemObject.MaxSocket - 1 do
                if invitem:IsAvailableSocket(i) == true then
                    return true;
                end                
            end
        else
            if itemObject.MaxSocket > 100 then itemObject.MaxSocket = 0 end
            for i = 0, itemObject.MaxSocket - 1 do
                local equipGemID = GetItemSocketInfo(itemObject, i);
                if equipGemID ~= nil then
                    return true;
                end
            end
        end    
    end

    return false;
end

function GET_COMMON_SOCKET_TYPE()
	return 5;
end

local _anitiqueCache = {}; -- key: itemClassName, value: groupKey
local function _RETURN_ANTIQUE_INFO(itemClassName, groupKey, group, exchangeItemList, giveItemList, giveItemCntList, matItemList, matItemCntList)
    if groupKey == nil then
        return nil;
    end

    local anitiqueCacheKey = group..'_'..itemClassName;
    _anitiqueCache[anitiqueCacheKey] = groupKey;
    local giveList = {};
    for i = 1, #giveItemList do
        giveList[#giveList + 1] = {
            Name = giveItemList[i],
            Count = giveItemCntList[i]
        };
    end

    local matList = {};
    for i = 1, #matItemList do
        matList[#matList + 1] = {
            Name = matItemList[i],
            Count = matItemCntList[i]
        };
    end

    return {
        GroupKey = groupKey,
        ExchangeGroup = group,
        AddGiveItemList = giveList,
        ExchangeItemList = exchangeItemList,
        MatItemList = matList,
    };
end

function GET_EXCHANGE_ANTIQUE_INFO(exchangeGroupName, itemClassName)
    if itemClassName == nil then
        return nil;
    end

    local anitiqueCacheKey = exchangeGroupName..'_'..itemClassName;
    if _anitiqueCache[anitiqueCacheKey] ~= nil then
        return _RETURN_ANTIQUE_INFO(itemClassName, GetExchangeAntiqueInfoByGroupKey(_anitiqueCache[anitiqueCacheKey]));
    end
    return _RETURN_ANTIQUE_INFO(itemClassName, GetExchangeAntiqueInfoByItemName(exchangeGroupName, itemClassName));
end

function IS_ENABLE_EXCHANGE_ANTIQUE(srcItem, dstItem)
    if srcItem == nil or dstItem == nil then
        return false;
    end
    
    if srcItem.ClassID == dstItem.ClassID then
        return false;
    end

    if dstItem.ClassName == 'CAN05_101' or dstItem.ClassName == 'CAN05_102' then
        return false;
    end
    return true;
end

-- exchangeWeaponType : Check Data
function IS_EXCHANGE_WEAPONTYPE(exchangeGroupName, itemClassName)
    if exchangeGroupName == nil or itemClassName == nil then
        return false;
    end

    return IsExchangeWeaponType(exchangeGroupName, itemClassName);
end

-- exchangeWeaponType : Get Material / return materialNameList, materialCountList
function GET_EXCHANGE_WEAPONTYPE_MATERIAL(exchangeGroupName, itemClassName)
    if exchangeGroupName == nil or itemClassName == nil then
        return nil, nil;
    end

    return GetExChangeMeterialList(exchangeGroupName, itemClassName);
end

-- exchangeWeaponType : exchange enable check
function IS_ENABLE_EXCHANGE_WEAPONTYPE(scrItem, destItemID)
    if scrItem == nil or destItemID == nil then 
        return false; 
    end

    if scrItem.ClassID == destItemID then 
        return false; 
    end
    
    local scrItemGroup = TryGetProp(scrItem, "ExchangeGroup", "None");
    if IsExchangeWeaponType(scrItemGroup, scrItem.ClassName) == false or IsExchangeWeaponTypeByClassID(destItemID) == false then 
        return false; 
    end
    return true;
end

function IS_ICOR_ITEM(item)
	if TryGetProp(item, 'GroupName', 'None') == 'Icor' then
		return true;
	end
	return false;
end

function GET_GEM_PROTECT_NEED_COUNT(gemObj)
    if gemObj == nil then
        return 999999
    end
    
    local lv = TryGetProp(gemObj, "NumberArg1", 0)
    local cls = GetClassByType("item_gem_Extract_Protect", lv)

    return TryGetProp(cls, 'NeedCount', 999999)
end