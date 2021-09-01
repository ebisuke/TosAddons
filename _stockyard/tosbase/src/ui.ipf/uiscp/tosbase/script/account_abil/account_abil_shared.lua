
--사용가능 설정--

-- 이벤트시에 리셋 패널티를 없앨 경우 추가
function GET_EVENT_REFUND_PENALTY(pc, abil_name)
    local ret = 0.2
    local cls = GetClass('account_ability', abil_name)
    if cls ~= nil then
        ret = TryGetProp(cls, 'RefundPenalty', 0.2)
    end

    -- 여기서 이벤트 확인

    return ret
end