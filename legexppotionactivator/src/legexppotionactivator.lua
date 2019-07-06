--OLD_SHOP_ITEM_LIST_GET
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function startswith(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end
local acutil = require('acutil')
local blacklist={
    d_raidboss_velcoffer=true,
    guildhouse=true,
}
LEGEXPPOTIONACTIVATOR_RETRY_COUNT=0
LEGEXPPOTIONACTIVATOR_RETRY_COUNT_LIMIT= 10
-- ライブラリ読み込み
function LEGEXPPOTIONACTIVATOR_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            LEGEXPPOTIONACTIVATOR_RETRY_COUNT=0
            --addon:RegisterMsg('GAME_START', 'LEGEXPPOTIONACTIVATOR_UPDATE');
            addon:RegisterMsg('GAME_START_3SEC', 'LEGEXPPOTIONACTIVATOR_UPDATE');

        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function LEGEXPPOTIONACTIVATOR_UPDATE()
    if(world.IsPVPMap() or 
    startswith(session.GetMapName(),"c_") or 
    startswith(session.GetMapName(),"mission_") or 
    startswith(session.GetMapName(),"gid_") or 
    startswith(session.GetMapName(),"raid_") or 
    blacklist[session.GetMapName()]

    )then
        return
    end
    LEGEXPPOTIONACTIVATOR_UPDATE_FORKEYBOARD()
end
function LEGEXPPOTIONACTIVATOR_UPDATE_FORKEYBOARD()
    local frame = ui.GetFrame('quickslotnexpbar');
    local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quickSlotInfo = quickslot.GetInfoByIndex(i);
        
        if quickSlotInfo.type ~= 0 then
            local updateslot = true;
            if sklCnt > 0 then
                if quickSlotInfo.category == 'Skill' then
                    updateslot = false;
                end
                
                if i <= sklCnt then
                    updateslot = false;
                end
            end
            if true == updateslot and quickSlotInfo.category ~= 'NONE' and session.GetInvItemByGuid( quickSlotInfo:GetIESID())~=nil then
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                local invItem = session.GetInvItemByGuid( quickSlotInfo:GetIESID())
				local itemClass = GetClassByType('Item', invItem.type);
                if (itemClass.GroupName == "ExpOrb") then
                    local curexp, maxexp = GET_LEGENDEXPPOTION_EXP(GetIES(invItem:GetObject()))
                    if(curexp<maxexp)then
                        --activate this
                        local expOrb = frame:GetUserValue("EXP_ORB_EFFECT");
                        if expOrb == "None" then
                            INV_ICON_USE(invItem)
                            ReserveScript("LEGEXPPOTIONACTIVATOR_CHECKISENABLED()",0.25)
                        else
                        end
                       

                        break
                    end
                end
            end
        end
    end
end

function LEGEXPPOTIONACTIVATOR_CHECKISENABLED()
    local frame = ui.GetFrame('quickslotnexpbar');
    local expOrb = frame:GetUserValue("EXP_ORB_EFFECT");
    if expOrb == "None" then
        --retry
        LEGEXPPOTIONACTIVATOR_RETRY_COUNT = LEGEXPPOTIONACTIVATOR_RETRY_COUNT+1
        if(LEGEXPPOTIONACTIVATOR_RETRY_COUNT <= LEGEXPPOTIONACTIVATOR_RETRY_COUNT_LIMIT) then
            ReserveScript("LEGEXPPOTIONACTIVATOR_UPDATE_FORKEYBOARD()",1);
        end
    end
end