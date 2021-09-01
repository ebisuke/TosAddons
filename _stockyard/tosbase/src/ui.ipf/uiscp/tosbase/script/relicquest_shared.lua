relicResetType = {
	Day = 1,
	Week = 2,
	Month = 3,
	Quater = 4,
	Event = 5,
	Etc = 6,
	Normal = 100,
	Infinite = 300,
} -- relic_quest.xml의 ResetType 컬럼 값과 동기화 필요함

function GET_RELICQUEST_MAP_LIST_RESULT(pc, group)

    local requiredLv = 9999
    if group == "EP13" then
        requiredLv = 440
    end

    local NowZone = GetZoneName(pc)
    if NowZone == "None" or NowZone == nil then
        return false
    end

    local fieldTB13 = {"ep13_f_siauliai_1", "ep13_f_siauliai_2", "ep13_f_siauliai_3", "ep13_f_siauliai_4", "ep13_f_siauliai_5"}
    local indunTypeTB13 = {"MythicDungeon_Auto", "MythicDungeon_Auto_Hard", "Challenge_Auto",
                            "Raid", "UniqueRaid", "FieldBossRaid", "MissionIndun", "DefenceMission"
                        }

    if table.find(fieldTB13, NowZone) > 0 then
        return true;
    end
    local indunCls = GetClassByStrProp("Indun", "MapName", NowZone);
    if indunCls ~= nil then
        local DungeonStr = TryGetProp(indunCls, "DungeonType", "None")
        local indunLevel = TryGetProp(indunCls, "Level", 0)
        if table.find(indunTypeTB13, DungeonStr) > 0 and indunLevel >= requiredLv then
            return true;
        end
    end

    return false
end


local s_relic_list  = nil
local function GET_RELIC_QUEST_LIST(categoryName)
    if s_relic_list == nil then
        s_relic_list = {}

        local clsList, cnt = GetClassList('Relic_Quest')
        for i = 0, cnt - 1 do
            local relicCls = GetClassByIndexFromList(clsList, i)
            if relicCls ~= nil and TryGetProp(relicCls, 'QuestType', 'None') == 'Quest' then
                local className = TryGetProp(relicCls, 'ClassName', 'None')
                local category = TryGetProp(relicCls, 'Category', 'None')
                if className ~= 'None' and category ~= 'None' then
                    if s_relic_list[category] == nil then
                        s_relic_list[category] = {}
                    end
                    table.insert(s_relic_list[category], className)
                end
            end 
        end
    end

    if s_relic_list[categoryName] == nil then
        return nil
    end

    return s_relic_list[categoryName]
end

function SCR_RELIC_QUEST_CHECK(pc, className)
    if pc == nil then
        return 'Error'
    end
    
    local relicRewardIES = GetClass('Relic_Reward', className)
    if relicRewardIES == nil then
        return 'Error'
    end

    local relicQuestIES = GetClass('Relic_Quest', className)
    if relicQuestIES == nil then
        return 'Error'
    end
   
    local accountObj = nil
	if IsServerObj(pc) == 1 then
		accountObj =  GetAccountObj(pc)
	else
		accountObj = GetMyAccountObj()
    end

    if accountObj == nil then
        return 'Error'
    end

    local countName = TryGetProp(relicQuestIES, 'AccountProperty', 'None')
    local currentCount = TryGetProp(accountObj, countName, 0)
    local goalCount = TryGetProp(relicQuestIES, 'GoalCount1', 0)
    local clearName = TryGetProp(relicRewardIES, 'ClearProperty', 'None')
    local clearCheck = TryGetProp(accountObj, clearName, 0)
    if clearCheck ~= 0 then
        return 'Clear'
    elseif goalCount > 0 and currentCount >= goalCount then
        return 'Reward'
    end

    return 'Progress'
end