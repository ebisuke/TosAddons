CHAT_SYSTEM("[DII]loaded")
function DISCORDINTEGRATIONCH_POPUP_OPEN(frame)
    DICHAT_ACQUIRE_NEWMESSAGE(frame)
end


function DISCORDINTEGRATIONCH_POPUP_CLOSE(frame)

	
end
function DISCORDINTEGRATIONCH_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            frame:ShowWindow(0)
            DISCORDINTEGRATION_DBGOUT("initfrm")
        end,
        catch = function(error)
            DISCORDINTEGRATION_ERROUT(error)
        end
    }
end
function DISCORDINTEGRATIONCH_DO_CLOSE_CHATPOPUP(frame)
	
	frame:ShowWindow(0)

end

function DISCORDINTEGRATIONCH_ACQUIRE_NEWMESSAGE(frame)
end