-- shared_field_dungeon.lua

function SCR_FIELD_DUNGEON_CONSUME_DECREASE(pc, name, value)
    local mapProp = nil
    if IsServerSection() == 1 then
        mapProp = GetMapProperty(pc)
    else
        local mapName = session.GetMapName()
        mapProp = GetClass('Map', mapName)
    end
    
    if mapProp ~= nil then
        local mapLv = TryGetProp(mapProp, 'QuestLevel')
        if mapLv > 420 then
            if name == 'Sta_Run' then
                return 0
            elseif name == 'SpendSP' then
                return value
            elseif name == 'CoolDown' then
                local reduceRate = 0
                
                if IsBuffApplied(pc, 'FIELD_COOLDOWNREDUCE_MIN_BUFF') == 'YES' then
                    reduceRate = 0.15
                end

                if IsBuffApplied(pc, 'FIELD_DEFAULTCOOLDOWN_BUFF') == 'YES' then
                    reduceRate = 0.3
                end

                if IsBuffApplied(pc, 'FIELD_COOLDOWNREDUCE_BUFF') == 'YES' then
                    reduceRate = 0.7
                end

                return value * (1 - reduceRate)
            end
        end
    end

    return value
end

-- 일단 섬 지형 좌표를 가지고 하드하게 예외처리...
function RIFT_DUNGEON_CHECK_ENABLE_POS(mapName, x, y, z)
    if mapName == 'd_dcapital_108' then
        if z >= 1400 or (x <= -1250 and z <= -2600) or (x >= 2400 and z <= -2600) then
            return false
        end
	end

	return true
end