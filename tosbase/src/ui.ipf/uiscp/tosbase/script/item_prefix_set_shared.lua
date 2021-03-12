function IS_VALID_ITEM_FOR_GIVING_PREFIX(item)
    if TryGetProp(item, 'LegendGroup', 'None') == 'None' then
        return false;        
    end

    return true;
end

-- 스택형 한종류 아이템 이름은 반환
function GET_LEGEND_PREFIX_MATERIAL_ITEM_NAME(legendgroup)
    return 'Legend_ExpPotion_2_complete';
end

function GET_LEGEND_PREFIX_NEED_MATERIAL_COUNT(item)
    if item == nil then
        return 0;
    end
    
    if item.LegendGroup == 'Velcoffer' then
        if item.GroupName == 'Armor' then
            return 6;
        end
        return 24;
    elseif item.LegendGroup == 'Savinose' or item.LegendGroup == 'Varna' then
        if item.GroupName == 'Armor' then
            return 8;
        end
        return 26;
    else
        return 99999;
    end



end

function GET_LEGEND_PREFIX_ITEM_NAME(item, prefix)
    if prefix == nil then
        prefix = TryGetProp(item, 'LegendPrefix', 'None');
    end
    
    local nameText = item.Name;    
	if prefix ~= 'None' then
		local prefixCls = GetClass('LegendSetItem', prefix);
        if prefixCls ~= nil then
		    nameText = prefixCls.Name..' '..nameText;
        end
	end
	return nameText;
end

function GET_LEGEND_PREFIX_NEED_MATERIAL_CLASSNAME(prefixName)    
	local clsList, cnt = GetClassList("LegendSetItem");
	if clsList ~= nil then
        for i = 0, cnt - 1 do
            local cls = GetClassByIndexFromList(clsList, i);
            if prefixName == cls.ClassName then
                return cls.NeedMaterial;
            end           
		end
    end
end

function GET_LEGEND_PREFIX_NEED_MATERIAL_COUNT_BY_NEEDITEM(targetObj, needItemClsName)
    if targetObj == nil or needItemClsName == nil then
        return 0;
    end
    
    local legendGroup = targetObj.LegendGroup;
	local clsList, cnt = GetClassList("LegendSetItem");
	if clsList ~= nil then
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(clsList, i);
			if string.find(cls.LegendGroup, legendGroup) ~= nil and targetObj.LegendPrefix ~= cls.ClassName and cls.NeedMaterial == needItemClsName then
				if targetObj.GroupName == 'Armor' and targetObj.ClassType ~= 'Shield' then
					local count = cls.NeedMaterial_ArmorCnt
                        
					-- 440장비는 이미 셋옵이 있으면 비용 1/4
					if TryGetProp(targetObj, 'UseLv', 1) >= 440 and TryGetProp(targetObj, 'LegendPrefix', "None") ~= "None" then
					    count = math.floor(count*0.25)
					end
					
					-- 세트 옵션 없고 Ev_SetOption 값이 1인 방어구 장비 비용 40% 할인 
					if TryGetProp(targetObj, 'Ev_SetOption', 0) == 1 and TryGetProp(targetObj, 'LegendPrefix', "None") == "None" then
					    count = math.floor(count*0.6)
					end

					-- PvP 전용 아이템 재료 1
					if TryGetProp(targetObj, 'StringArg', 'None') == 'FreePvP' then
						count = 1
					end
					
					if count <= 1 then
					    count = 1
					end
					
					return count;
				else
					local count = cls.NeedMaterial_WeaponCnt;
					-- PvP 전용 아이템 재료 1
					
					-- 440장비는 이미 셋옵이 있으면 비용 1/4
					if TryGetProp(targetObj, 'UseLv', 1) >= 440 and TryGetProp(targetObj, 'LegendPrefix', "None") ~= "None" then

					    count = math.floor(count*0.25)
					end

					-- 세트 옵션 없고 Ev_SetOption 값이 1인 무기 장비 비용 40% 할인 
					if TryGetProp(targetObj, 'Ev_SetOption', 0) == 1 and TryGetProp(targetObj, 'LegendPrefix', "None") == "None" then
					    count = math.floor(count*0.6)
					end
					
					if TryGetProp(targetObj, 'StringArg', 'None') == 'FreePvP' then
						count = 1
					end
					
					if count <= 1 then
					    count = 1
					end
					
					return count
				end

			end
		end
    end
    
    return 0;
end
