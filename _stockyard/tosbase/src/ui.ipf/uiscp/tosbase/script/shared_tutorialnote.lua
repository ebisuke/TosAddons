function GET_TUTORIALNOTE_STATE(aObj, className)
	-- checkprop : 300 보상 획득, 299 : minimized UI확인 후
	local cls = GetClass("tutorialnotelist", className);
	local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
	local checkpropname = checkpropStrList[1];
	local checkpropmaxvalue = tonumber(checkpropStrList[2]);
	local checkprop = tonumber(TryGetProp(aObj, checkpropname, 0));
    if checkprop == 300 then
        return "Clear";
    end

    if checkprop >= checkpropmaxvalue then
        return "Reward";
	end

	if 0 < checkprop then		
		return "PROGRESS";
	end

    return "POSSIBLE";
end

function TUTORIALNOTE_MINIMIZED_POINT_PIC_CHECK(aObj, type)
	local clslist, cnt  = GetClassList("tutorialnotelist");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		local group = TryGetProp(cls, "Group");
		if group == type then
			local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
			local checkpropname = checkpropStrList[1];
			local checkpropmaxvalue = checkpropStrList[2];

			local curValue = tonumber(TryGetProp(aObj, checkpropname, 0));
			if tonumber(checkpropmaxvalue) == curValue then
				return true;
			end
		end
    end
    
    return false;
end

-- 보상 받을 수 있는 가이드, 미션이 있는지 확인
function TUTORIALNOTE_GROUP_CHECK(aObj, type)
	local clslist, cnt  = GetClassList("tutorialnotelist");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		local group = TryGetProp(cls, "Group");
		if group == type then
			local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
			local checkpropname = checkpropStrList[1];
			local checkpropmaxvalue = tonumber(checkpropStrList[2]);

			local curValue = tonumber(TryGetProp(aObj, checkpropname, 0));
			if curValue ~= 300 and curValue >= checkpropmaxvalue then
				return true;
			end	
		end
    end
    
    return false;
end

-- 전체 가이드 클리어 여부 확인
function TUTORIALNOTE_GUIDE_ALL_CLEAR_CHECK(pc, aObj)
	local clslist, cnt  = GetClassList("tutorialnotelist");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		local group = TryGetProp(cls, "Group", "None");
		if group == "guide" then		
			local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
			local checkpropname = checkpropStrList[1];
			local checkprop = TryGetProp(aObj, checkpropname, 0);
			if checkprop ~= 300 then
				return false;
			end
		end
	end

	return true;
end

-- 전체 미션 클리어 여부 확인
function TUTORIALNOTE_MISSION_ALL_CLEAR_CHECK(pc, aObj)
	local clslist, cnt  = GetClassList("tutorialnotelist");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		local group = TryGetProp(cls, "Group", "None");
		if group ~= "guide" then		
			local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
			local checkpropname = checkpropStrList[1];
			local checkprop = TryGetProp(aObj, checkpropname, 0);
			if checkprop ~= 300 then
				return false;
			end
		end
	end

	return true;
end

function TUTORIALNOTE_MISSION_CLEAR_COUNT_CHECK(pc, aObj)
	local clearCnt = 0;
	local clslist, cnt  = GetClassList("tutorialnotelist");
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clslist, i);
		local group = TryGetProp(cls, "Group", "None");
		if group ~= "guide" then		
			local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
			local checkpropname = checkpropStrList[1];
			local checkprop = TryGetProp(aObj, checkpropname, 0);
			if checkprop == 300 then
				clearCnt = clearCnt + 1;
			end
		end
	end

	return clearCnt;
end

function GET_TUTORIALNOTE_MISSION_ICOR_TARGET_ITEM_TYPE(sObj)
	local prop = TryGetProp(sObj, "TUTO_ICOR_MISSION_CHECK", 0);
	if prop == 1 then
		return "Shirt";
	elseif prop == 2 then
		return "Pants";
	elseif prop == 3 then
		return "Pants";
	elseif prop == 4 then
		return "Boots";
	elseif prop == 5 then
		return "Boots";
	end

	return;
end

function TUTORIALNOTE_MISSION_3_15_PRE_CHECK(pc, aObj)
	local cls = GetClass("tutorialnotelist", "mission_3_15");
	local checkpropStrList = StringSplit(TryGetProp(cls, "CheckProp", "None"), '/');
	local checkpropname = checkpropStrList[1];
	local checkprop = TryGetProp(aObj, checkpropname, 0);

	if checkprop == 300 then
		return true;
	end
	
	local result = SCR_QUEST_CHECK(pc, "F_MAPLE_24_2_MQ_11");
	if result == "COMPLETE" then
		return true;
	end
	
	return false;
end