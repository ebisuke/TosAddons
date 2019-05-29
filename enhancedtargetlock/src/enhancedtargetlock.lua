function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local acutil = require('acutil');
ENHANCEDTARGETLOCK_ENABLE = false
ENHANCEDTARGETLOCK_CT = nil
ENHANCEDTARGETLOCK_LOOPER = false

function ENHANCEDTARGETLOCK_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            acutil.setupHook(ENHANCEDTARGETLOCK_ENABLE, 'CTRLTARGETUI_OPEN');
            acutil.setupHook(ENHANCEDTARGETLOCK_DISABLE, 'CTRLTARGETUI_CLOSE');
            addon:RegisterMsg('TARGET_SET', 'ENHANCEDTARGETLOCK_ON_TARGET');
            addon:RegisterMsg('TARGET_UPDATE', 'ENHANCEDTARGETLOCK_ON_TARGET_UPDATE');
            addon:RegisterMsg('TARGET_CLEAR', 'ENHANCEDTARGETLOCK_ON_TARGET_CLEAR');
            CHAT_SYSTEM("INIT")
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function ENHANCEDTARGETLOCK_ENABLE()
    CHAT_SYSTEM("CHG1")
    ENHANCEDTARGETLOCK_CT = session.GetTargetHandle()
    local frame = ui.GetFrame("enhancedtargetlock")
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
    timer:SetUpdateScript("ENHANCEDTARGETLOCK_TARGETTING");
    timer:Start(0.01);
--return CTRLTARGETUI_OPEN_OLD()
end
function ENHANCEDTARGETLOCK_DISABLE()
    CHAT_SYSTEM("CHG2")
    ENHANCEDTARGETLOCK_CT = nil
    local frame = ui.GetFrame("enhancedtargetlock")
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
    timer:Stop();
--return CTRLTARGETUI_CLOSE_OLD()
end
function ENHANCEDTARGETLOCK_TARGETTING()
    ReserveScript("ENHANCEDTARGETLOCK_TARGETTING_ON()",0.01)
    --ReserveScript("ENHANCEDTARGETLOCK_TARGETTING()",0.01)
end
function ENHANCEDTARGETLOCK_TARGETTING_ON()
    EBI_try_catch{
        try = function()
            if (ENHANCEDTARGETLOCK_CT == nil) then
                ENHANCEDTARGETLOCK_DISABLE()
                print("neaz")
                return
            end

            local targetactor = world.GetActor(ENHANCEDTARGETLOCK_CT)
            local myactor = GetMyActor()
            if (targetactor == nil) then
                ENHANCEDTARGETLOCK_DISABLE()
                print("ned")
                return
            end
            --print("ch")
            --その方向を向く
            if(session.GetTargetHandle()~=ENHANCEDTARGETLOCK_CT)then
                --DRT_ATTACH_TO_TARGET_C(myactor,nil,ENHANCEDTARGETLOCK_CT,nil,"")
                local cls=GetClassByType("env", 1);
                CHAT_SYSTEM(tostring(cls.TargetFixed));

                --ReserveScript("cls:SetPropIValue(\"TargetFixed\",1)",0.01);
            
            end            
            DRT_LOOKAT_C(myactor, nil, ENHANCEDTARGETLOCK_CT)
        end,
        catch = function(error)
            print(error)
        end
    }
end
function ENHANCEDTARGETLOCK_ON_TARGET()
    ENHANCEDTARGETLOCK_TARGETTING_ON()
-- EBI_try_catch{
--     try = function()
--         CHAT_SYSTEM("CHG")
--         --if (ENHANCEDTARGETLOCK_ENABLE == false) then
--         --    return
--         --end
--         local target = session.GetTargetHandle()
--         if (target ~= ENHANCEDTARGETLOCK_CT) then
--             ENHANCEDTARGETLOCK_NEXTTARGET()
--         end
--     end,
--     catch = function(error)
--         CHAT_SYSTEM(error)
--     end
-- }
end
function ENHANCEDTARGETLOCK_NEXTTARGET()
    --if (ENHANCEDTARGETLOCK_ENABLE == false) then
    --    return
    --end
    ReserveScript("ENHANCEDTARGETLOCK_VALIDATE()", 0.01)
end
function ENHANCEDTARGETLOCK_VALIDATE()
-- EBI_try_catch{
--     try = function()
--         CHAT_SYSTEM("look")
--         --LookAt(ENHANCEDTARGETLOCK_CT,GetMyPCObject())
--         local target = session.GetTargetHandle()
--         --if(target~=ENHANCEDTARGETLOCK_CT)then
--         CHAT_SYSTEM("next")
--         ReserveScript("ENHANCEDTARGETLOCK_VALIDATE()", 0.01)
--     --end
--     end,
--     catch = function(error)
--         CHAT_SYSTEM(error)
--     end
-- }
end

function ENHANCEDTARGETLOCK_ON_TARGET_UPDATE()

end
function ENHANCEDTARGETLOCK_ON_TARGET_CLEAR()
-- if (ENHANCEDTARGETLOCK_ENABLE == false) then
--     return
-- end
-- local target = session.GetTargetHandle()
-- if (target ~= ENHANCEDTARGETLOCK_CT) then
--     ENHANCEDTARGETLOCK_NEXTTARGET()
-- end
end
