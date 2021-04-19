function SCR_EP12_2_F_CASTLE_101_MQ03_02_REMAINS_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP12_2_F_CASTLE_101_MQ03_2')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end

function SCR_EP12_2_F_CASTLE_101_MQ03_3_BRANCH_PRE_DIALOG(self, pc)
    local result = SCR_QUEST_CHECK(pc, 'EP12_2_F_CASTLE_101_MQ03_3')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end


function SCR_EP12_2_D_DCAPITAL_108_MQ03_JANGCHI_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP12_2_D_DCAPITAL_108_MQ03')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end

function SCR_EP12_2_D_DCAPITAL_108_MQ08_02_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP12_2_D_DCAPITAL_108_MQ09')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end