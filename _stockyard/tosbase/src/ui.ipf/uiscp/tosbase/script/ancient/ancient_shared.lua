--사용가능 설정--
function IS_ANCIENT_ENABLE_MAP(self)
    if IsServerSection() ~= 1 then
        self = GetMyPCObject()
    end

    local zoneName = 'None'
    if IsServerSection() == 1 then
        zoneName = GetZoneName(self);
    else
        zoneName = session.GetMapName();
    end
    
    local enableMapList = {"onehour_test1", "d_solo_dungeon_2", "d_solo_dungeon"}
    for i = 1, #enableMapList do
        if zoneName == enableMapList[i] then
            return "YES";
        end
    end
    
    local clsIndun = nil
    if IsServerSection() == 1 then
    local cmd = GetMGameCmd(self);
    if cmd ~= nil then
        local mGameName = cmd:GetMGameName();
            clsIndun = GET_MGAME_CLASS_BY_MGAMENAME(mGameName);
        end
    else
        if IsRaidField() == 1 or IsRaidMap() == 1 then
            local mGameName = session.mgame.GetCurrentMGameName()
			if mGameName ~= nil and mGameName ~= 'None' then
				clsIndun = GetClassByStrProp("Indun", "MGame", mGameName)
			end
        end
	end
    if clsIndun ~= nil and (TryGetProp(clsIndun, "SubType", "None") == "Casual" or TryGetProp(clsIndun, "DungeonType", "None") == "WeeklyRaid" or TryGetProp(clsIndun, "DungeonType", "None") == "FreeDungeon") then
        return "YES";
    end

    -- 챌린지 모드 캐주얼 모드
    if IsServerSection() == 1 then
    local isChallengeModePlaying = IsChallengeModePlaying(self);
	if isChallengeModePlaying == 1 then
		local partyObj = GetPartyObj(self);
		if partyObj ~= nil then
			local selectedLevel = GetExProp(partyObj, "ChallengeMode_SelectedLevel");
			if selectedLevel == 2 then
				return "YES";
			end
		end
	end
    else
        local selectedLevel = GetExProp(self, 'ChallengeMode_SelectedLevel')
        if selectedLevel == 2 then
            return 'YES'
        end
    end
    
    return "NO"
end

function IS_ANCIENT_HEAL_ENABLE(self)
    if self == nil then
        self = GetMyPCObject()
    end

    -- 텔 하르샤 4단계 이하
    local mGameName = 'None'
    if IsServerSection() == 1 then
        local cmd = GetMGameCmd(self)
        if cmd ~= nil then
            mGameName = cmd:GetMGameName()
        end
    else
        zoneName = session.GetMapName();
		if zoneName == 'id_irredians_113_1' then
            mGameName = session.mgame.GetCurrentMGameName()
        end
    end
    if mGameName == 'IRREDIAN1131_SRAID_C' then
        local dungeon_level = GetExProp(self, 'sraidC_Total_Level_boss')
        if dungeon_level > 0 and dungeon_level <= 4 then
            return "YES"
        end
    end

    -- 챌린지 1인 모드
    if IsServerSection() == 1 then
        local isChallengeModePlaying = IsChallengeModePlaying(self);
        if isChallengeModePlaying == 1 then
            local partyObj = GetPartyObj(self)
            if partyObj ~= nil then
                local selectedLevel = GetExProp(partyObj, "ChallengeMode_SelectedLevel")
                if selectedLevel == 2 then
                    return "YES"
                end
            end
        end
    else
        local selectedLevel = GetExProp(self, 'ChallengeMode_SelectedLevel')
        if selectedLevel == 2 then
            return 'YES'
        end
    end
    
    return "NO"
end

function IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName)
    local zoneCls = GetClass("Map", zoneName);
    local mapType = TryGetProp(zoneCls,"MapType","None")
    if mapType == 'City' then
        return true
    end
    return false
end

local function is_contain(tab,elem)
    local guid = elem:GetGuid()
    for i = 1,#tab do
        if tab[i]:GetGuid() == guid then
            return true
        end
    end
    return false
end

function GET_ANCIENT_COMBO_CARD_LIST(combo,cardList)
    table.sort(cardList,SORT_ANCIENT)
    
    local num = combo.MaxApplyCount
    local ret = ""
    for i = 1,num do
        ret = ret..cardList[i].slot..'/'
    end
    return ret
end

function SORT_ANCIENT(a,b)
    if a.rarity ~= b.rarity then
        return a.rarity > b.rarity
    end
    if a.starrank ~= b.starrank then
        return a.starrank > b.starrank
    end
    local a_exp = a:GetStrExp();
    local a_xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(a_exp))
    local a_level = a_xpInfo.level

    local b_exp = b:GetStrExp();
    local b_xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(b_exp))
    local b_level = b_xpInfo.level
    if a_level ~= b_level then
        return a_level > b_level
    end
    return a.slot < b.slot
end
--combo prescp--
function SCR_ANCIENT_COMBO_RACETYPE_PRECHECK(combo, cardList)
    local comboMonList = {}
    local comboCardList = {}
    for i = 1,4 do
        local raceType = TryGetProp(combo,"TypeName_"..i)
        if raceType == nil or raceType == "None" then
            break
        end
        local needCnt = TryGetProp(combo,"TypeNum_"..i)
        local myCnt = 0
        for i = 1,#cardList do
            local cls = GetClass("Monster",cardList[i]:GetClassName())
            if cls ~= nil and TryGetProp(cls,"RaceType") == raceType then
                if table.find(comboMonList, cls.ClassName) == 0 then
                    myCnt = myCnt + 1
                    comboMonList[#comboMonList+1] = cls.ClassName
                    comboCardList[#comboCardList+1] = cardList[i]
                end
            end
        end
        if myCnt < needCnt then
            return "None"
        end
    end
    local slotList_str = GET_ANCIENT_COMBO_CARD_LIST(combo,comboCardList)
    return slotList_str
end

function SCR_ANCIENT_COMBO_ATTRIBUTE_PRECHECK(combo, cardList)
    local comboMonList = {}
    local comboCardList = {}
    for i = 1,4 do
        local raceType = TryGetProp(combo,"TypeName_"..i)
        if raceType == nil or raceType == "None" then
            break
        end
        local needCnt = TryGetProp(combo,"TypeNum_"..i)
        local myCnt = 0
        for i = 1,#cardList do
            local cls = GetClass("Monster",cardList[i]:GetClassName())
            if cls ~= nil and TryGetProp(cls,"Attribute") == raceType then
                if table.find(comboMonList, cls.ClassName) == 0 then
                    myCnt = myCnt + 1
                    comboMonList[#comboMonList+1] = cls.ClassName
                    comboCardList[#comboCardList+1] = cardList[i]
                end
            end
        end
        if myCnt < needCnt then
            return "None"
        end
    end
    local slotList_str = GET_ANCIENT_COMBO_CARD_LIST(combo,comboCardList)
    return slotList_str
end

function SCR_ANCIENT_COMBO_RANK_PRECHECK(combo, cardList)
    local comboMonList = {}
    local comboCardList = {}
    for i = 1, 4 do
        local rank = TryGetProp(combo,"TypeName_"..i)
        if rank == nil or rank == "None" then
            break
        end
        local needCnt = TryGetProp(combo,"TypeNum_"..i)
        local myCnt = 0
        for i = 1,#cardList do
            local cls = GetClass("Monster",cardList[i]:GetClassName())
            if cls ~= nil then
                local infoCls = GetClass("Ancient_Info",cls.ClassName)
                local rarity= infoCls.Rarity
                if tonumber(rank) == tonumber(rarity) then
                    if table.find(comboMonList, cls.ClassName) == 0 then
                        myCnt = myCnt + 1
                        comboMonList[#comboMonList+1] = cls.ClassName
                        comboCardList[#comboCardList+1] = cardList[i]
                    end
                end
            end
        end
        if myCnt < needCnt then
            return "None"
        end
    end
    local slotList_str = GET_ANCIENT_COMBO_CARD_LIST(combo,comboCardList)
    return slotList_str
end
--combo calc--
function GET_ANCIENT_COMBO_CALC_VALUE(combo,cardList)
    local defaultValue = combo.NumArg1
    local lvRate = combo.NumArg2
    local level = 0;
    local starRank = 0;
    local grade = 0;
    for i = 1, #cardList do
        local exp = cardList[i]:GetStrExp();
        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
        local addLv = xpInfo.level
        if addLv >= PC_MAX_LEVEL then
            addLv = PC_MAX_LEVEL
        end
        level = level + addLv
        
        local cls = GetClass("Monster",cardList[i]:GetClassName())
        local infoCls = GetClass("Ancient_Info",cls.ClassName)
        grade = grade + infoCls.Rarity
        starRank = starRank + cardList[i].starrank
    end
    
    local levelValue = (level/#cardList) * lvRate
    local starRankValue, gradeValue = ANCINET_GRADE_RANK_CALC((starRank/#cardList), (grade/#cardList))
    local value = defaultValue + levelValue * starRankValue *  gradeValue
    if value < 1 then
        value = 1
    end
    return math.floor(value)
end

function GET_ANCIENT_COMBO_PERCENT_CALC_VALUE(combo, cardList)
    local defaultValue = combo.NumArg1
    local maxValue = combo.NumArg2
    local lvRate = (maxValue - defaultValue)/PC_MAX_LEVEL
    
    local level = 0;
    local starRank = 0;
    
    for i = 1, #cardList do
        local exp = cardList[i]:GetStrExp();
        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
        local addLv = xpInfo.level
        if addLv >= PC_MAX_LEVEL then
            addLv = PC_MAX_LEVEL
        end
        level = level + addLv
        starRank = starRank + cardList[i].starrank
    end
    
    local starRankValue = ANCINET_GRADE_RANK_CALC(math.floor(starRank/#cardList), 1)
    local levelValue = (level/#cardList) * lvRate
    
    local value = defaultValue + (levelValue*starRankValue)
    if value < 1 then
        value = 1
    end
    
    if maxValue < value then
        value = maxValue
    end
    
    return math.floor(value)
end

--Passive calc--
function GET_ANCIENT_CALC_VALUE(infoCls,card)
    local defaultValue = infoCls.NumArg1

    local exp = card:GetStrExp();
    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
    local level = xpInfo.level
    if level >= PC_MAX_LEVEL then
        level = PC_MAX_LEVEL
    end
        
    local levelValue = level * infoCls.NumArg2
    
    local starRank = card.starrank
    local grade = infoCls.Rarity;
    if starRank == nil or starRank < 1 then
        starRank = 1;
    end
    if grade == nil or grade < 1 then
        grade = 1
    end
    local starRankValue, gradeRankValue = ANCINET_GRADE_RANK_CALC(starRank, grade)
    
    local value = defaultValue + (levelValue * starRankValue * gradeRankValue)
    if value < 1 then
        value = 1
    end
    
    return math.floor(value)
end

function GET_ANCIENT_PERCENT_CALC_VALUE(infoCls,card)
    local defaultValue = infoCls.NumArg1
    local maxValue = infoCls.NumArg2
    local lvRate = (maxValue - defaultValue)/PC_MAX_LEVEL
    
    local exp = card:GetStrExp();
    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
    local level = xpInfo.level
    if level >= PC_MAX_LEVEL then
        level = PC_MAX_LEVEL
    end
        
    local levelValue = level * lvRate
    
    local starRank = card.starrank
    local grade = infoCls.Rarity;
    if starRank == nil or starRank < 1 then
        starRank = 1;
    end
    if grade == nil or grade < 1 then
        grade = 1
    end
    local starRankValue, gradeRankValue = ANCINET_GRADE_RANK_CALC(starRank, grade)
    
    local value = defaultValue + (levelValue * starRankValue * gradeRankValue)
    if value < 1 then
        value = 1
    end
    
    return math.floor(value)
end

function ANCINET_GRADE_RANK_CALC(starRank, grade)
    local rankValue = 0.5 + (starRank-1) * 0.25
    local gradeValue = 0.4 + (grade-1) * 0.2
    
    return rankValue, gradeValue
end