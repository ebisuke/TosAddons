function SCR_EP13_F_SIAULIAI_3_MQ_06_CRACK_1_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP13_F_SIAULIAI_3_MQ_06')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end
function SCR_EP13_F_SIAULIAI_3_MQ_06_CRACK_2_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP13_F_SIAULIAI_3_MQ_06')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end
function SCR_EP13_F_SIAULIAI_3_MQ_06_CRACK_3_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP13_F_SIAULIAI_3_MQ_06')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end
function SCR_EP13_F_SIAULIAI_3_MQ_06_CRACK_4_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP13_F_SIAULIAI_3_MQ_06')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end
function SCR_EP13_F_SIAULIAI_3_MQ_06_CRACK_5_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP13_F_SIAULIAI_3_MQ_06')
    if result == 'PROGRESS' then
        return 'YES'
    end
    return 'NO'
end
function SCR_EP13_F_SIAULIAI_3_MQ_07_CRACK_1_PRE_DIALOG(pc, dialog, handle)
    local result = SCR_QUEST_CHECK(pc, 'EP13_F_SIAULIAI_3_MQ_07')
    local layer = GetLayer(pc)
    if result == 'PROGRESS' and layer == 0 then
        return 'YES'
    end
    return 'NO'
end