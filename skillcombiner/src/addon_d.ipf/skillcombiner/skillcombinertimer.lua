
function SKILLCOMBINERTIMER_ON_INIT(addon, frame)
   
    local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
    timer:SetUpdateScript("SKILLCOMBINER_ON_TIMER");
    timer:Start(0.1);
   
end