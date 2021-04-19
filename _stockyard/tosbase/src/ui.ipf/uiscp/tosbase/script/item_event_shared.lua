--Ev_EventType == String
--NoSetOpt : 세트옵션 이용 불가
--NoEnchant : 고정아이커 탈/부착 불가

function SHARED_IS_EVENT_ITEM_CHECK(itmeIES, Ev_EventType)
    local isEventType = TryGetProp(itmeIES, "Ev_EventType", "None")
    if isEventType == "None" or isEventType == nil then
        return false;
    end
    local str_TB = SCR_STRING_CUT(isEventType, "/")
    if #str_TB > 0 then
        for i = 1, #str_TB do
            if str_TB[i] == Ev_EventType then
                return true;
            end
        end
    end
    return false;
end


function SHARED_IS_EVENT_ITEM_CHECK_LIST(itemlist, Ev_EventType)
    for i = 1, #itemlist do
        local isEventType = TryGetProp(itemlist[i], "Ev_EventType", "None")
        local str_TB = SCR_STRING_CUT(isEventType, "/")
        if #str_TB > 0 then
            for j = 1, #str_TB do
                if str_TB[j] == Ev_EventType then
                    return true;
                end
            end
        end
    end

    return false;

end



function SHARED_IS_EVENT_ITEM_CHECK_SCROLL(itemObj, Ev_EventType)
    local isEventType = TryGetProp(itemObj, "Ev_EventType", "None")
    if isEventType == "None" or isEventType == nil then
        return 0;
    end
    local str_TB = SCR_STRING_CUT(isEventType, "/")
    if #str_TB > 0 then
        for i = 1, #str_TB do
            if str_TB[i] == Ev_EventType then
                return 1;
            end
        end
    end
    return 0;
end