function LEGENDCARD_GET_REINFORCE_CLASS(cardLv,reinforceType,namespace)
	local legendCardReinforceList, cnt = GetClassList(namespace)
	for i = 0, cnt - 1 do
		local cls = GetClassByIndexFromList(legendCardReinforceList,i);
		if cardLv == TryGetProp(cls, "CardLevel") and reinforceType == TryGetProp(cls, "ReinforceType") then
			return cls
		end
	end
	return nil
end

function LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(obj)
	if obj.CardGroupName == nil then
		return nil
	end
	if obj.CardGroupName == 'LEG' then
		return "legendCardReinforce"
	elseif obj.CardGroupName == 'GODDESS' then
		return "goddessCardReinforce"
	elseif obj.CardGroupName == 'REINFORCE_GODDESS_CARD' then
		return "goddessCardReinforce"
	end
	return nil
end

function LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(mainObj,materialObj)
	if mainObj == nil or mainObj.CardGroupName == nil then
		return nil
	end
	if materialObj.CardGroupName == nil then
		return nil
	end
	if mainObj.CardGroupName == 'LEG' then
		local validTypeList = {"LegendCard","Card","ReinForceCard"}
		-- 레티샤의 강화용 보루타 카드
		for i = 1,8 do
			local reinforceType = string.format("ReinForceCard_Leticia_Lv%s",i)
			table.insert(validTypeList,reinforceType)
		end
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "legendCardReinforce"
		end
	elseif mainObj.CardGroupName == 'GODDESS' then
		local validTypeList = {"GoddessReinForceCard"}
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "goddessCardReinforce"
		end
	elseif mainObj.CardGroupName == 'REINFORCE_GODDESS_CARD' then
		local validTypeList = {"GoddessReinForceCard","LegendCard"}
		if table.find(validTypeList,materialObj.Reinforce_Type) ~= 0 then
			return "goddessCardReinforce"
		end
	end
	
	return nil
end


function CALC_LEGENDCARD_REINFORCE_PERCENTS(legendCardObj,materialCardObjList)
	if legendCardObj == nil then
		return 0,0,0
	end

	local legendCardType = TryGetProp(legendCardObj, 'Reinforce_Type')
	local legendCardLv = GET_ITEM_LEVEL(legendCardObj)
	local namespace = LEGENDCARD_REINFORCE_GET_MAIN_CARD_NAMESPACE(legendCardObj)
	local legendCardCls = LEGENDCARD_GET_REINFORCE_CLASS(legendCardLv,legendCardType,namespace)
	local needPoint = TryGetProp(legendCardCls, "NeedPoint",0)
	local totalGivePoint = 0

	for i = 1,#materialCardObjList do
		local materialCardObj = materialCardObjList[i]
		local materialType = materialCardObj.Reinforce_Type
		local materialCardLv = GET_ITEM_LEVEL(materialCardObj)
		local matterialNamespace = LEGENDCARD_REINFORCE_GET_MATERIAL_CARD_NAMESPACE(legendCardObj,materialCardObj)
		local materialCls = LEGENDCARD_GET_REINFORCE_CLASS(materialCardLv,materialType,matterialNamespace)
		local givePoint = TryGetProp(materialCls, "GivePoint",0)
		if materialCls.ReinforceType == "LegendCard" and legendCardCls.ReinforceType == "GoddessCard" then
			givePoint = 0
		end
		totalGivePoint = totalGivePoint + givePoint
	end

	local givePerNeedPoint = 0
	if needPoint ~= 0 then
		givePerNeedPoint = totalGivePoint / needPoint
	end
	
	local successPercent = math.floor(givePerNeedPoint * 100 + 0.5)
	local failPercent = math.floor((1 - givePerNeedPoint) * 0.4 * 100 + 0.5)
	local brokenPercent = 100 - (successPercent + failPercent)

	if givePerNeedPoint >= 0.995 then
		successRatio = 100
	end
	

	successPercent = math.max(0,math.min(100,successPercent))
	failPercent = math.max(0,math.min(100,failPercent))
	brokenPercent = math.max(0,math.min(100,brokenPercent))

	return successPercent, failPercent, brokenPercent, needPoint, totalGivePoint
end

function GET_CARD_REINFORCE_NEED_ITEM_STRARG(cls,cardObj)
	return cardObj.StringArg
end