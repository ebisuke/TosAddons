function GET_EVENT_2101_NEW_YEAR_TYPE(pc)
    -- event_flex_box type
    return 2;
end

-- 일일 1시간 접속 티켓 보상 제공 제한
function GET_EVENT_2101_NEW_YEAR_PLAY_TIME_TICKET_LIMIT_COUNT()
    return 5;
end

-- 일일 1시간 접속 티켓 보상 제공 수량
function GET_EVENT_2101_NEW_YEAR_PLAY_TIME_TICKET_COUNT()
    return 1;
end

-- 일일 콘텐츠 클리어 코인 획득 제한
function GET_EVENT_2101_NEW_YEAR_CONTENT_DAILY_LIMIT_COUNT()
    return 200;
end

-- 일일 필드 사냥 코인 획득 제한
function GET_EVENT_2101_NEW_YEAR_FIELD_DAILY_LIMIT_COUNT()
    return 100;
end

-- 행운 상자 오픈 가능 캐릭터 레벨 제한
function GET_EVENT_2101_NEW_YEAR_OPEN_BOX_LOWLEVEL()
    return 400;
end