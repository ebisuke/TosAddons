-- reputation_shared.lua

-- Const
function GET_REPUTATION_MAX()
    return 15000
end

function GET_REPUTATION_RANK(point)
    if point == GET_REPUTATION_MAX() then
        return 5
    elseif point >= 11250 then
        return 4
    elseif point >= 7500 then
        return 3
    elseif point >= 3000 then
        return 2
    elseif point > 0 then
        return 1
    else
        return 0
    end
end

function GET_REPUTATION_REQUIRE_POINT(rank)
    if rank == 5 then
        return GET_REPUTATION_MAX()
    elseif rank == 4 then
        return 11250
    elseif rank == 3 then
        return 7500
    elseif rank == 2 then
        return 3000
    elseif rank == 1 then
        return 1
    else
        return 0
    end
end

function GET_REPUTATION_POINT_EXTRACT_LIMIT()
    return 500
end

function GET_REPUTATION_PRICE_NAME(group)
    if group == "EP13" then
        return "reputation_Coin"
    else
        return "None"
    end
end

function GET_REPUTATION_MAP_LIST(group)
    if group == "EP13" then
        return {"ep13_f_siauliai_1", "ep13_f_siauliai_2", "ep13_f_siauliai_3", "ep13_f_siauliai_4", "ep13_f_siauliai_5"}
    else
        return {}
    end
end

-- Script
function IS_REPUTATION_OPEN(pc, reputationName)
    local aObj = nil

    if IsServerSection(pc) == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    if aObj == nil then
        return false
    end

    local class = GetClass("reputation", reputationName)
    if class == nil then
        return false
    end

    local openProp = TryGetProp(class, "Open", "None")
    if openProp == nil then
        return false
    end

    return TryGetProp(aObj, openProp, 0) == 1
end

function GET_REPUTATION_EXTRACT_POINT(cls, reputationName, usingCommonItem)
    if cls == nil then
        return 0
    end

    if usingCommonItem == true then
        if cls.Group == "Common" then
            return cls.Point
        end
    else
        if table.find(SCR_STRING_CUT(cls.TargetProp, ';'), reputationName) > 0 then
            return cls.Point
        elseif cls.Group == GetClass("reputation", reputationName).Group then
            return math.floor(cls.Point / 2)
        end
    end

    return 0
end

function GET_REPUTATION_QUEST_LIST(pc)
    local aObj = nil

    if IsServerSection(pc) == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    if aObj == nil then
        return {}
    end

    local listStr = TryGetProp(aObj, "REPUTATION_QUEST_LIST", "None")
    if listStr == "None" then
        return {}
    end

    return SCR_STRING_CUT(listStr, ';')
end

function GET_REPUTATION_QUEST_ENABLE(pc, questName)
    local aObj = nil

    if IsServerSection(pc) == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    if aObj == nil then
        return "NO"
    end

    local alreadyClear = TryGetProp(aObj, "REPUTATION_QUEST_CLEAR_"..questName, 1)
    if alreadyClear == 1 then
        return "NO"
    end

    local quest = GetClass("reputation_quest", questName)
    local questList = GET_REPUTATION_QUEST_LIST(pc)

    if quest == nil then
        return "NO"
    end

    if TryGetProp(aObj, quest.OpenProp, 0) == 0 then
        return "NO"
    end

    if quest.ResetType == "WEEK" and table.find(questList, questName) == 0 then
        return "NO"
    end

    return "YES"
end

function IS_REPUTATION_MAP(pc, group)
    if table.find(GET_REPUTATION_MAP_LIST(group), GetZoneName(pc)) > 0 then
        return true
    else
        return false
    end
end


function SCR_REPUTAION_WEEKQUEST_POSSIBLECHECK(self, QuestName, SysMsg)

    local Possible_check = SCR_QUEST_CHECK(self, QuestName)

    if Possible_check == "POSSIBLE" then
        local questIES = GetClass('QuestProgressCheck', QuestName)
        local QUESTNAME = TryGetProp(questIES, 'Name')
        
        local zoneFind = TryGetProp(questIES, 'StartMap')
        local MapIES = GetClass('Map', zoneFind)
        local ZONENAME = TryGetProp(MapIES, 'Name')
        
        if SysMsg == 1 then
            return ScpArgMsg('REPUTATION_POSSIBLEQUEST{QUESTNAME}{ZONE}', 'QUESTNAME', "{nl}"..QUESTNAME, 'ZONE', "{nl}"..ZONENAME).."{nl} {nl}"
        else
            return ShowOkDlg(self, 'REPUTATION_POSSIBLEQUEST\\'..ScpArgMsg('REPUTATION_POSSIBLEQUEST{QUESTNAME}{ZONE}', 'QUESTNAME', QUESTNAME, 'ZONE', ZONENAME), 1)
        end
    end

end