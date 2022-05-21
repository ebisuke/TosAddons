
local g={}

function SILENTLOGIN_ISHIDELOGIN()

    ReserveScript("SILENTLOGIN_ISHIDELOGIN_DELAY()", 0.01)
    
    return SILENTLOGIN_ISHIDELOGIN_OLD()
end
function SILENTLOGIN_ISHIDELOGIN_DELAY()
    local frame = ui.GetFrame('barrack_gamestart')
    if frame:IsVisible() == 1 then
        local checkbtn=frame:GetChildRecursively("hidelogin")
        AUTO_CAST(checkbtn)
        -- auto silent
        checkbtn:SetCheck(1)
        barrack.SetHideLogin(1);
    end
end

if SILENTLOGIN_ISHIDELOGIN_OLD == nil and barrack.IsHideLogin ~= SILENTLOGIN_ISHIDELOGIN then
    SILENTLOGIN_ISHIDELOGIN_OLD = barrack.IsHideLogin
    barrack.IsHideLogin = SILENTLOGIN_ISHIDELOGIN
end
