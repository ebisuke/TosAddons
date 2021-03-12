-- 이벤트 진행 확인 UI 설정 lua
--  type =   1 : 정규 여신의 룰렛 
--           2 : 시즌 서버 여신의 룰렛
--           3 : 메데이나 flex box
--           4 : 당신의 마스터
--           5 : 달맞이 대작전
--           6 : 5주년 이벤트

function GET_EVENT_PROGRESS_CHECK_TITLE(type)
    local table = 
    {
        [1] = "GODDESS_ROULETTE",
        [2] = "GODDESS_ROULETTE",
        [3] = "EVENT_2007_FLEX_BOX_DESC",
        [4] = "EVENT_YOUR_MASTER_TITLE",
        [5] = "EVENT_2009_FULLMOON_TITLE",
        [6] = "EVENT_2011_5TH_TITLE",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_DESC(type)
    local table = 
    {
        [1] = {"Acquire_State", "STAMP_TOUR", "Auto_KeonTenCheu"},
        [2] = {"Acquire_State", "STAMP_TOUR", "Auto_KeonTenCheu"},
        [3] = {"Acquire_State", "TOS_VACANCE", "Auto_KeonTenCheu"},
        [4] = {"EVENT_YOUR_MASTER_DESC", "prev_ranking", "AccVoteReward"},
        [5] = {"EventState", "LevelReward", "BuffDesc"},
        [6] = {"EventState", "EVENT_2011_5TH_MSG_1", "EVENT_2011_5TH_MSG_2"},
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_TITLE_SKIN(type)
    local table = 
    {
        [1] = "test_h_redribbon_skin",
        [2] = "test_h_redribbon_skin",
        [3] = "test_h_redribbon_skin",
        [4] = "your_master_title",
        [5] = "test_h_redribbon_skin",
        [6] = "test_h_redribbon_skin",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_TITLE_DECO(type)
    local table = 
    {
        [1] = "",
        [2] = "",
        [3] = "",
        [4] = "your_master_title_deco",
        [5] = "",
        [6] = "",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_ITEM(type)
    local table = 
    {
        [1] = "Event_Roulette_Coin_2",
        [2] = "Event_Roulette_Coin_2",
        [3] = "EVENT_Flex_Gold_Moneybag",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_NOTE_BTN(type)
    local table = 
    {
        [1] = "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND",
        [2] = "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND",
        [3] = "ON_EVENT_STAMP_TOUR_UI_OPEN_COMMAND_SUMMER",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_TAB_TITLE(type)
    local table = 
    {
        [1] = {"Acquire_State", "STAMP_TOUR", "Auto_KeonTenCheu"},
        [2] = {"Acquire_State", "STAMP_TOUR", "Auto_KeonTenCheu"},
        [3] = {"Acquire_State", "TOS_VACANCE", "Auto_KeonTenCheu"},
        [4] = {"now_ranking", "prev_ranking", "AccVoteReward"},
        [5] = {"EventState", "LevelReward", "BuffDesc"},
        [6] = {"EventState", "EVENT_2011_5TH_MSG_1", "EVENT_2011_5TH_MSG_2"},
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_TIP_TEXT(type)
    local table = 
    {
        [1] = {"EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text", "EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text", "None"},
        [2] = {"EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text", "EVENT_NEW_SEASON_SERVER_stamp_tour_tip_text", "None"},
        [3] = {"EVENT_2007_FLEX_BOX_CHECK_TIP_TEXT_1", "EVENT_2007_FLEX_BOX_CHECK_TIP_TEXT_1", "None"},
        [4] = {"EVENT_YOUR_MASTER_TOOLTIP_WEEK_", "EVENT_YOUR_MASTER_TOOLTIP_WEEK_", "None"},
        [5] = {"EVENT_2009_FULLMOON_TIP_TEXT_1", "EVENT_2009_FULLMOON_TIP_TEXT_2", "EVENT_2009_FULLMOON_TIP_TEXT_3"},
        [6] = {"EVENT_2011_5TH_MSG_3", "None", "None"},
    }

    return table[type];
end

-- pre : 이벤트 전, end : 이벤트 종료, cur : 이벤트 중
function GET_EVENT_PROGRESS_CHECK_EVENT_STATE(type)
    local table = 
    {
        [1] = {"cur", "cur", "cur", "pre", "pre"},
        [2] = {"cur", "cur", "cur", "cur", "end"},
        [3] = {"cur", "cur", "end", "cur", "cur"},
        [5] = {"cur", "cur", "cur", "cur", "cur"},
        [6] = {"cur", "cur", "cur", "cur", "cur"},
    }

    return table[type];
end

------------------- 획득 현황 -------------------
function GET_EVENT_PROGRESS_CHECK_LIST_COUNT(type)
    local table = 
    {
        [1] = 5,
        [2] = 5,
        [3] = 5,
        [5] = 5,
        [6] = 6,
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_ICON(type)
    local table = 
    {
        [1] = {"stamp_coin_mark", "stamp_watch_mark", "stamp_stamp_mark", "stamp_flag_mark", "stamp_roulette_mark"},
        [2] = {"stamp_coin_mark", "stamp_watch_mark", "stamp_stamp_mark", "stamp_flag_mark", "stamp_roulette_mark"},
        [3] = {"stamp_coin_mark", "stamp_watch_mark", "stamp_stamp_mark", "stamp_flag_mark", "stamp_flex_box_mark"},
        [5] = {"stamp_flag_mark", "stamp_coin_mark", "stamp_stamp_mark", "stamp_watch_mark", "stamp_coin_mark"},
        [6] = {"stamp_flag_mark", "stamp_flag_mark", "stamp_coin_mark", "stamp_coin_mark", "stamp_coin_mark", "stamp_watch_mark"},
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_TEXT(type)
    local table = 
    {
        [1] = {ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_1"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_2"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_3"), ClMsg("DailyContentMissionAcquireCount"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_5")},
        [2] = {ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_1"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_2"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_3"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_4"), ClMsg("EVENT_NEW_SEASON_SERVER_COIN_CHECK_STATE_5")},
        [3] = {ClMsg("EVENT_2007_FLEX_BOX_CHECK_STATE_1"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_STATE_2"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_STATE_3"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_STATE_4"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_STATE_5")},
        [5] = {ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_1"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_2"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_3"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_4"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_5")},
        [6] = {ClMsg("EventPoint").."/"..ClMsg("EventLevel"), ClMsg("EVENT_2011_5TH_MSG_4"), ClMsg("EVENT_2011_5TH_MSG_5"), ClMsg("EVENT_2011_5TH_MSG_6"),  ClMsg("EVENT_2011_5TH_MSG_14"), ClMsg("EventDailyPlayTime")},
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_TOOLTIP(type)
    local table = 
    {
        [1] = {ClMsg("GoddessRouletteTexttooltip_1"), ClMsg("GoddessRouletteTexttooltip_2"), ClMsg("GoddessRouletteTexttooltip_3"), ClMsg("GoddessRouletteTexttooltip_4"), ClMsg("GoddessRouletteTexttooltip_5")},
        [2] = {ClMsg("GoddessRouletteTexttooltip_1"), ClMsg("GoddessRouletteTexttooltip_2"), ClMsg("GoddessRouletteTexttooltip_3"), ClMsg("GoddessRouletteTexttooltip_4"), ClMsg("GoddessRouletteTexttooltip_5")},        
        [3] = {ClMsg("EVENT_2007_FLEX_BOX_CHECK_TOOLTIP_1"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_TOOLTIP_2"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_TOOLTIP_3"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_TOOLTIP_4"), ClMsg("EVENT_2007_FLEX_BOX_CHECK_TOOLTIP_5")},
        [5] = {ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_1"), ClMsg("EVENT_2009_FULLMOON_CHECK_TOOLTIP_2"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_3"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_4"), ClMsg("EVENT_2009_FULLMOON_CHECK_STATE_5")},
        [6] = {ClMsg("EventLevelGradeSection").." {nl}"..ClMsg("EVENT_2011_5TH_MSG_16"), "None", "None", ClMsg("EVENT_2011_5TH_MSG_12"), ClMsg("EVENT_2011_5TH_MSG_15"), ClMsg("EVENT_2011_5TH_MSG_13")},
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_CUR_VALUE(type, accObj)
    local table = 
    {
        [1] = {TryGetProp(accObj, "GODDESS_ROULETTE_COIN_ACQUIRE_COUNT", 0), TryGetProp(accObj, "GODDESS_ROULETTE_DAILY_PLAY_TIME_MINUTE", 0), GET_EVENT_PROGRESS_STAMP_TOUR_CLEAR_COUNT(), TryGetProp(accObj, "GODDESS_ROULETTE_DAILY_CONTENTS_ACQUIRE_COUNT", 0), TryGetProp(accObj, "GODDESS_ROULETTE_USE_ROULETTE_COUNT", 0)},
        [2] = {TryGetProp(accObj, "GODDESS_ROULETTE_COIN_ACQUIRE_COUNT", 0), TryGetProp(accObj, "GODDESS_ROULETTE_DAILY_PLAY_TIME_MINUTE", 0), GET_EVENT_PROGRESS_STAMP_TOUR_CLEAR_COUNT(), TryGetProp(accObj, "GODDESS_ROULETTE_DAILY_CONTENTS_ACQUIRE_COUNT", 0), TryGetProp(accObj, "GODDESS_ROULETTE_USE_ROULETTE_COUNT", 0)},
        [3] = {TryGetProp(accObj, "EVENT_FLEX_BOX_ACQUIRE_CONSUME_COUNT", 0), TryGetProp(accObj, "EVENT_FLEX_BOX_DAILY_PLAY_CONSUME_COUNT", 0), GET_EVENT_PROGRESS_STAMP_TOUR_CLEAR_COUNT(), TryGetProp(accObj, "EVENT_FLEX_BOX_DAILY_CONTENTS_CONSUME_COUNT", 0), TryGetProp(accObj, "EVENT_FLEX_BOX_OPEN_COUNT", 0)},
        [5] = {GET_EVENT_2009_FULLMOON_LEVEL(), GET_EVENT_2009_FULLMOON_POINT(), TryGetProp(accObj, "EVENT_2009_FULLMOON_REWARD_COUNT", 0), TryGetProp(accObj, "EVENT_2009_FULLMOON_WISH_COUNT", 0), TryGetProp(accObj, "EVENT_2009_FULLMOON_COIN_COUNT", 0)},
        [6] = {TryGetProp(accObj, "EVENT_2011_5TH_POINT_COUNT", 0) .. "/" .. GET_EVENT_2011_5TH_EVENT_LEVEL(TryGetProp(accObj, "EVENT_2011_5TH_POINT_COUNT", 0)), TryGetProp(accObj, "EVENT_2011_5TH_DAILY_TOS_COIN_COUNT", 0), TryGetProp(accObj, "EVENT_2011_5TH_COIN_TOTAL_COUNT", 0), TryGetProp(accObj, "EVENT_2011_5TH_DAILY_COIN_COUNT", 0), TryGetProp(accObj, "EVENT_2011_5TH_COIN_RAID_COUNT", 0), TryGetProp(accObj, "EVENT_2011_5TH_DAILY_PLAY_TIME", 0)},
    }

    return table[type];
end

-- maxvalue가 0이면 제한 없다는 뜻
function GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_MAX_VALUE(type, accObj)
    local table = 
    {
        [1] = {1000, 10, 33, 10, 100},
        [2] = {GODDESS_ROULETTE_COIN_MAX_COUNT, GODDESS_ROULETTE_DAILY_PLAY_TIME_VALUE, GODDESS_ROULETTE_STAMP_TOUR_MAX_COUNT, GODDESS_ROULETTE_DAILY_CONTENTS_MAX_COIN_COUNT, GODDESS_ROULETTE_MAX_COUNT},
        [3] = {0, GET_EVENT_FLEX_BOX_DAILY_PLAY_TIME_MAX_CONSUME_COUNT(), 24, GET_EVENT_FLEX_BOX_DAILY_CONTENTS_MAX_CONSUME_COUNT(), GET_EVENT_FLEX_BOX_MAX_OPEN_COUNT()},
        [5] = {0, 0, 1, 3, 300},
        [6] = {0, GET_EVENT_2011_5TH_TOS_COIN_MAX_COUNT(), 0, GET_EVENT_2011_5TH_COIN_FIELD_MAX_COUNT(), GET_EVENT_2011_5TH_COIN_RAID_MAX_COUNT(), 0}
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_NPC(type)
    -- contectmanu name(ClMsg)/mapname/x/z;
    local table = 
    {
        [1] = {"None", "None", "Klapeda/c_Klaipe/-292/291;c_orsha/c_orsha/-985/415;", "None", "None"},
        [2] = {"None", "None", "Klapeda/c_Klaipe/-292/291;c_orsha/c_orsha/-985/415;", "None", "Klapeda/c_Klaipe/-664/576;c_fedimian/c_fedimian/-284/-346;c_orsha/c_orsha/184/246;"},
        [3] = {"None", "None", "Klapeda/c_Klaipe/-679/581;c_fedimian/c_fedimian/-532/-180;c_orsha/c_orsha/184/246;", "None", "Klapeda/c_Klaipe/-679/581;c_fedimian/c_fedimian/-532/-180;c_orsha/c_orsha/184/246;"},
        [5] = {"None", "None", "None", "None", "None"},
        [6] = {"None", "None", "None", "None", "None"},
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_ACQUIRE_STATE_CLEAR_TEXT(type)
    local table = 
    {
        [1] = {"None", "GoddessRouletteDailyPlayTimeClearText", "None", "GoddessRouletteDailyPlayTimeClearText", "Goddess_Roulette_Max_Rullet_count"},
        [2] = {"None", "GoddessRouletteDailyPlayTimeClearText", "None", "GoddessRouletteDailyPlayTimeClearText", "Goddess_Roulette_Max_Rullet_count"},
        [3] = {"None", "GoddessRouletteDailyPlayTimeClearText", "None", "GoddessRouletteDailyPlayTimeClearText", "Event_Flex_box_Open_Max_Count"},
        [5] = {"None", "None", "EVENT_2009_FULLMOON_ALREADY_GET_GIFT", "EVENT_2009_FULLMOON_ALREADY_MAKE_WISH", "GoddessRouletteDailyPlayTimeClearText"},
        [6] = {"None", "GoddessRouletteDailyPlayTimeClearText", "None", "GoddessRouletteDailyPlayTimeClearText", "None"},
    }

    return table[type];
end
function GET_EVENT_PROGRESS_DAILY_PLAY_TIME_INDEX(type)
    -- min = 접속 시간 분 표시, count = 일일 획득 주화 표시 
    local table = 
    {
        [1] = 2,
        [2] = 2,
        [3] = 2,
        [5] = 2,
        [6] = 6,
    }

    return table[type];
end

function GET_EVENT_PROGRESS_DAILY_PLAY_TIME_TYPE(type)
    -- min = 접속 시간 분 표시, count = 일일 획득 주화 표시 
    local table = 
    {
        [1] = "min",
        [2] = "min",
        [3] = "count",
        [5] = "count",
        [6] = "min",
    }

    return table[type];
end

------------------- 스탬프 투어 -------------------
function GET_EVENT_PROGRESS_CHECK_STAMP_GROUP(type)
    -- note_eventlist.xml Group 
    local table = 
    {
        [1] = "REGULAR_EVENT_STAMP_TOUR",
        [2] = "REGULAR_EVENT_STAMP_TOUR",
        [3] = "EVENT_STAMP_TOUR_SUMMER",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_CHECK_NOTE_NAME(type)
    local table = 
    {
        [1] = "Note",
        [2] = "Note",
        [3] = "TOS_VACANCE_EVNET",
    }

    return table[type];
end

function GET_EVENT_PROGRESS_STAMP_TOUR_CLEAR_COUNT()
	local accObj = GetMyAccountObj();
	local curCount = 0;
	for i = 1, GODDESS_ROULETTE_STAMP_TOUR_MAX_COUNT do
		local propname = "None";
		if i < 10 then
			propname = "REGULAR_EVENT_STAMP_TOUR_CHECK0"..i;
		else
			propname = "REGULAR_EVENT_STAMP_TOUR_CHECK"..i;
		end

		local curvalue = TryGetProp(accObj, propname);
		
		if curvalue == "true" then
			curCount = curCount + 1;
		end
	end

	return curCount;
end

------------------- 콘텐츠 -------------------
function GET_EVENT_PROGRESS_CONTENTS_MAX_CONSUME_COUNT(type)
    -- first : 첫 클리어 시에만 보상 제공, daily: 매일 획득 가능 수량 초기화
    local table = 
    {
        [1] = "daily",
        [2] = "daily",
        [3] = "daily",
    }

    return table[type];
end

function CREATE_EVENT_PROGRESS_CHECK_CONTENTS_MISSION_CLEAR_COUNT()
	local accObj = GetMyAccountObj();
	if accObj == nil then return 0;	end

	local curCount = 0;
	for i = 1, EVENT_NEW_SEASON_SERVER_CONTENT_MISSION_MAX_COUNT do
		local propname = "EVENT_NEW_SEASON_SERVER_CONTENT_FIRST_CLEAR_CHECK_"..i;
		local curvalue = TryGetProp(accObj, propname);
		
		if curvalue == 1 then
			curCount = curCount + 1;
		end
	end

	return curCount;
end

------------------- 당신의 마스터 -------------------
function GET_EVENT_YOUR_MASTER_VOTE_MATERIAL()
    return "Event_2008_Master_Vote_86";
end

function GET_EVENT_YOUR_MASTER_VOTE_COIN()
    return "Event_2008_Master_Badge";
end

function GET_EVENT_YOUR_MASTER_VOTE_COIN_PLAY_TIME_COUNT()
    return 20;
end

function GET_EVENT_YOUR_MASTER_ACCRUE_REWARD_TABLE()
    local table = 
    {
        -- 누적 보상 카운트/아이템 ClassName/제공 수량
        [1] = "5;Event_Ability_Point_Stone_10000_5/1;",
        [2] = "10;Event_Ability_Point_Stone_10000_5/1;",
        [3] = "15;Event_Ability_Point_Stone_10000_5/2;EVENT_2008_Master_Vote_86_BOX/1;",
        [4] = "20;Event_Ability_Point_Stone_10000_5/2;EVENT_2008_Master_Vote_86_BOX/1;",
        [5] = "25;Event_Ability_Point_Stone_10000_5/3;EVENT_2008_Master_Vote_86_BOX/2;Event_HiddenAbility_MasterPiece/1;",
        [6] = "30;Event_Ability_Point_Stone_10000_5/3;EVENT_2008_Master_Vote_86_BOX/2;Event_HiddenAbility_MasterPiece/1;",
        [7] = "35;Event_Ability_Point_Stone_10000_5/3;EVENT_2008_Master_Vote_86_BOX/2;Event_HiddenAbility_MasterPiece/1;",
        [8] = "40;Event_Ability_Point_Stone_10000_5/4;EVENT_2008_Master_Vote_86_BOX/3;Event_HiddenAbility_MasterPiece/1;",
        [9] = "45;Event_Ability_Point_Stone_10000_5/4;EVENT_2008_Master_Vote_86_BOX/3;Event_HiddenAbility_MasterPiece/1;",
        [10] = "50;Event_Ability_Point_Stone_10000_5/5;EVENT_2008_Master_Vote_86_BOX/5;EVENT_2008_costume/1;",
    }

    return table;
end

function GET_EVENT_YOUR_MASTER_VOTE_COUNT(accObj, npc)
    local ret_vote, ret_accvotr = 0, 0;
    local org_npc_list, cnt  = GetClassList("event_ranking_data");
    
    local curvotelistStr = TryGetProp(accObj, "EVENT_YOUR_MASTER_VOTE_LIST", 0);
    local votelist = StringSplit(curvotelistStr, "/");

    local accvotelistStr = TryGetProp(accObj, "EVENT_YOUR_MASTER_TOTAL_VOTE_LIST", 0);
    local accvotelist = StringSplit(accvotelistStr, "/");
    for i = 0, cnt - 1 do 
		local cls = GetClassByIndexFromList(org_npc_list, i);
        local npcClsName = TryGetProp(cls, "ClassName", "None");

        if npc ==  npcClsName then
            ret_vote = votelist[i+1];
            ret_accvotr = accvotelist[i+1];
        end
    end

    if ret_vote == nil then
        ret_vote = 0;
    end

    if ret_accvotr == nil then
        ret_accvotr = 0;
    end 

    return ret_vote, ret_accvotr;
end