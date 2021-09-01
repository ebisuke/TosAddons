-- type 1 : 메데이나 flex box
--      2 : 2101 신년맞이
function GET_EVENT_FLEX_BOX_CONSUME_CLASSNAME(type)
    local table = 
    {
        -- 누적 보상 카운트/아이템 ClassName/제공 수량
        [1] = "EVENT_Flex_Gold_Moneybag",
        [2] = "Event_2101_new_year_ticket",
    }

    return table[type];
end

-- flex box 개봉 가능 수량
function GET_EVENT_FLEX_BOX_MAX_OPEN_COUNT(type)
    local table = 
    {
        [1] = 200,
        [2] = 200,
    }

    return table[type];
end

-- flex box 개봉에 드는 재료 수량
function GET_EVENT_FLEX_BOX_CONSUME_COUNT(type)
    local table = 
    {
        [1] = 10,
        [2] = 1,
    }

    return table[type];
end

-- 누적 보상 
function GET_EVENT_FLEX_BOX_ACCRUE_REWARD_TABLE(type)
    local table = 
    {
        -- 아이템 ClassName/제공 수량
        [1] = {[1] = "50/medeina_emotion06/3", [2] = "100/medeina_emotion05/3", [3] = "150/medeina_emotion04/3", [4] = "200/Gesture_Flex/1"},
        [2] = {[1] = "50/Event_Ability_Point_Stone_10000_18/5", [2] = "100/Event_HiddenAbility_MasterPiece/3", [3] = "150/malsuns_emotion82/3", [4] = "200/PersonalHousing_Item_hp_p_h_barrack_pond_01/1"},
    }

    return table[type];
end

function GET_EVENT_FLEX_BOX_CURRENT_ACCRUE_REWARD(aObj, type, count)
    local table = GET_EVENT_FLEX_BOX_ACCRUE_REWARD_TABLE(type);
    for k, v in pairs(table) do
        local rewardlist = StringSplit(v, "/");
        if tonumber(rewardlist[1]) == count then
            local ItemclassName = rewardlist[2];
            local Itemcount = rewardlist[3];
            return true, ItemclassName, Itemcount;
        end
    end

    return false;
end

function GET_EVENT_FLEX_BOX_TITLE(type)
    local table = 
    {
        [1] = ClMsg("EVENT_2007_FLEX_BOX_TITLE"),
        [2] = ClMsg("EVENT_2101_NEW_YEAR_BOX_TITLE"),
    }

    return table[type];
end

function GET_EVENT_FLEX_BOX_GROUP_NAME(type)
    local table = 
    {
        [1] = "EVENT_FLEX_BOX",
        [2] = "EVENT_2101_NEW_YEAR",
    }

    return table[type];
end

function GET_EVENT_FLEX_BOX_TOTAL_OPEN_COUNT_PROP_NAME(type)
    local table = 
    {
        [1] = "EVENT_FLEX_BOX_OPEN_COUNT",
        [2] = "EVENT_2101_NEW_YEAR_TOTAL_BOX_OPEN_COUNT",
    }

    return table[type];
end 
--------------------------- flex box ---------------------------

--------------------------- 메데이나 flex box ---------------------------
-- 일일 콘텐츠 클리어 보상 획득 가능 최대 수량
function GET_EVENT_FLEX_BOX_DAILY_CONTENTS_MAX_CONSUME_COUNT()
    return 50;
end

-- 일일 1시간 접속 보상 획득 가능 최대 횟수
function GET_EVENT_FLEX_BOX_DAILY_PLAY_TIME_MAX_CONSUME_COUNT()
    return 36;
end

-- 주머니 획득 가능 여부 확인
function ENABLE_ACQURE_EVENT_FLEX_BOX_CONSUME(accObj, count)
    local curCnt = TryGetProp(accObj, "EVENT_FLEX_BOX_ACQUIRE_CONSUME_COUNT")

    if tonumber(count) <= 0 then
        return false;
    end

    return true, count;
end

function GET_EVENT_FLEX_BOX_DESC()
    return ClMsg("EVENT_2007_FLEX_BOX_DESC");
end
--------------------------- 메데이나 flex box ---------------------------