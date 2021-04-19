-- EVENT_2009_FULLMOON_SHARED.lua

function GET_EVENT_2009_FULLMOON_POINT(pc)
    local aObj = nil

    if IsServerSection(pc) == 1 then
        aObj = GetAccountObj(pc)
    else
        aObj = GetMyAccountObj()
    end

    local point = TryGetProp(aObj, "EVENT_2009_FULLMOON_POINT")
    local coinCount = TryGetProp(aObj, "EVENT_2009_FULLMOON_COIN_TOTAL_COUNT")

    return point + (coinCount // 100) * 20
end

function GET_EVENT_2009_FULLMOON_LEVEL(pc)
    local point = GET_EVENT_2009_FULLMOON_POINT(pc)

    if point < 1000 then
        return 1
    elseif point < 2000 then
        return 2
    elseif point < 4000 then
        return 3
    elseif point < 6000 then
        return 4
    else
        return 5
    end

    return 1
end

function GET_EVENT_2009_FULLMOON_ACCRUE_REWARD_TABLE()
    local table = 
    {
        -- 누적 보상 카운트/아이템 ClassName/제공 수량
        [1] = "1;Event_2009_Chursok_Gift_Box1/1;",
        [2] = "2;Event_2009_Chursok_Gift_Box2/1;",
        [3] = "3;Event_2009_Chursok_Gift_Box3/1;",
        [4] = "4;Event_2009_Chursok_Gift_Box4/1;",
        [5] = "5;Event_2009_Chursok_Gift_Box5/1;",
        [6] = "Special;Event_2009_Chursok_Police_Box/1;"
    }

    return table;
end