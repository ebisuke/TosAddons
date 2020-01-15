function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function FINDPORTALSHOP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame("findportalshop");
            frame:ShowWindow(0)
            if OLD_MAP_OPEN == nil then
                OLD_MAP_OPEN = MAP_OPEN
                MAP_OPEN = FINDPORTALSHOP_MAP_OPEN_JUMPER
            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end

function FINDPORTALSHOP_MAP_OPEN_JUMPER(frame)
    if OLD_MAP_OPEN ~= nil then
        OLD_MAP_OPEN(frame)
    end
    FINDPORTALSHOP_MAP_OPEN(frame)
end

function FINDPORTALSHOP_MAP_OPEN(frame)
    EBI_try_catch{
        try = function()
            local btnopen = frame:CreateOfGetControl("button", "btnfindportal", 0, 0, 120, 40)
            btnopen:SetMargin(0, 18, 80 + 120 + 20, 0)
            btnopen:SetLayoutGravity(ui.Right, ui.Top)
            btnopen:SetSkinName("test_pvp_btn")
            btnopen:SetText("ポタ屋検索")
            btnopen:SetEventScript(ui.LBUTTONDOWN, "FINDPORTALSHOP_TOGGLE");
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }

end
function FINDPORTALSHOP_TOGGLE()
    local frame = ui.GetFrame("findportalshop");
    ui.ToggleFrame(frame)
end

function FINDPORTALSHOP_FIND(name)

end
