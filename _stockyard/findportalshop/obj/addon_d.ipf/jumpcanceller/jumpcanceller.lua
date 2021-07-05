
function JUMPCANCELLER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame=ui.GetFrame("jumpcanceller");
            frame:ShowWindow(1)
            
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
