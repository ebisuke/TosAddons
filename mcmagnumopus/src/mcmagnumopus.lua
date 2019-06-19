function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
MCMAGNUMOPUS_LIFTICON=nil
MCMAGNUMOPUS_BUTTONPRESS=false
function MCMAGNUMOPUS_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            if (OLD_CHECK_INV_LBTN == nil) then
                OLD_CHECK_INV_LBTN = CHECK_INV_LBTN
                CHECK_INV_LBTN = MCMAGNUMOPUS_CHECK_INV_LBTN_JUMPER
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }


end

function MCMAGNUMOPUS_CHECK_INV_LBTN_JUMPER(frame, slot, invItem, customFunc, scriptArg, count)
    MCMAGNUMOPUS_CHECK_INV_LBTN(frame, slot, invItem, customFunc, scriptArg, count)
end
function MCMAGNUMOPUS_ISLARGEDISPLAY()
    if(option.GetClientWidth()>=3000)then
        return 1
    else
        return 0
    end
end
function MCMAGNUMOPUS_CHECK_INV_LBTN(frame, slot, invItem, customFunc, scriptArg, count)
    EBI_try_catch{
        try = function()
            if (OLD_CHECK_INV_LBTN ~= nil) then
                OLD_CHECK_INV_LBTN(frame, slot, invItem, customFunc, scriptArg, count)
            end
            if(ui.GetFrame("puzzlecraft"):IsVisible()==1 or true)then
                ui.CancelLiftIcon()
                MCMAGNUMOPUS_LIFTICON=slot:GetIcon()

                MCMAGNUMOPUS_CLEARMOUSESTATE()
                MCMAGNUMOPUS_BEGINMOUSEMOVE(MCMAGNUMOPUS_LIFTICON)

            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function MCMAGNUMOPUS_BEGINMOUSEMOVE(icon)
    local framemc=ui.GetFrame("mcmagnumopus")
    local mccursor=GET_CHILD(framemc,"item","ui::CSlot")
    mccursor:SetIcon(MCMAGNUMOPUS_LIFTICON)
    framemc:ShowWindow(1)
    mouse.SetHidable(0)
    local mctimer=GET_CHILD(framemc,"addontimer","ui::CAddOnTimer")
    mctimer:SetUpdateScript("MCMAGNUMOPUS_TRACING")
    mctimer:Start(0.01)
end
function MCMAGNUMOPUS_CLEARMOUSESTATE()
    MCMAGNUMOPUS_BUTTONPRESS=false
    local framemc=ui.GetFrame("mcmagnumopus")
    framemc:ShowWindow(0)
    mouse.SetHidable(1)
end
function MCMAGNUMOPUS_TRACING()
    EBI_try_catch{
        try = function()
    if mouse.IsLBtnDown() == 1 then
        MCMAGNUMOPUS_BUTTONPRESS=true
    else
        if(MCMAGNUMOPUS_BUTTONPRESS==true)then
            MCMAGNUMOPUS_CLEARMOUSESTATE()
        end
    end
end
