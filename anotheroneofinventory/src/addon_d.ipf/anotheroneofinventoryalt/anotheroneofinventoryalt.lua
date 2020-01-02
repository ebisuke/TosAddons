local acutil = require('acutil')

local g = {}
g.frame = nil
g.tick = 0
g.focus = 0
g.debug=true

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end
local function DrawPolyLine(pic, poly, brush, color)
    local prev = nil
    for _, v in ipairs(poly) do
        if (prev) then
            pic:DrawBrush(prev[1], prev[2], v[1], v[2], brush, color)
        end
        prev = v
    end
end
local function DBGOUT(msg)
    
    EBI_try_catch{
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)
                
                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            
            end
        end,
        catch = function(error)
        end
    }

end
local function ERROUT(msg)
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end




--マップ読み込み時処理（1度だけ）
function ANOTHERONEOFINVENTORYALT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            g.frame = frame
        
        --frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            g.tick = (g.tick + 1) % 100
            
            if (frame:IsVisible() == 0) then
                return
            end
            
            if (keyboard.IsKeyPressed("V") == 0) then
                AOI_ALT_DO()
                return
            end
            if (keyboard.IsKeyDown("LEFT") == 1) then
                
                if (g.focus - 1 >= 3) then
                    g.focus = g.focus - 3
                end
                
            end
            if (keyboard.IsKeyDown("RIGHT") == 1) then
              
                if (g.focus - 1 < 18) then
                    g.focus = g.focus + 3
                end
                
            end
            if (keyboard.IsKeyDown("UP") == 1) then
                if (g.focus > 1) then
                    
                    g.focus = g.focus - 1
                
                end
            end
            if (keyboard.IsKeyDown("DOWN") == 1) then
                if g.focus < 21 then
                    
                    g.focus = g.focus + 1
                
                end
            end
            local bg = frame:GetChild("bg")
            AUTO_CAST(bg)
            bg:FillClonePicture("00000000")
            local ox, oy
            local sx, sy
            sx = 50
            sy = 50
            ox = 50 + 800 / 7 * math.floor((g.focus - 1) / 3.0)
            oy = 200 + 400 / 3 * ((g.focus - 1) % 3)
            DrawPolyLine(bg, {
                {ox, oy},
                {ox + sx, oy},
                {ox + sx, oy + sy},
                {ox, oy + sy},
                {ox, oy},
            }, "spray_4", "FF00FF00")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOI_ALT_SHOW()
    g.focus = 11
    ui.GetFrame("anotheroneofinventoryalt"):ShowWindow(1)
end
function AOI_ALT_DO()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            local slot=frame:GetChild("slot"..tostring(g.focus))
            local clsid=slot:GetUserIValue("clsid")
            if(clsid and clsid ~= 0)then
                local invitem = session.GetInvItemByType(clsid)
                INV_ICON_USE(invitem)
            else
                DBGOUT("Cancel")
            end
            frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            local timer = GET_CHILD(frame, "aoi_addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("AOI_ALT_ON_TIMER");
            timer:Start(0.01);
            frame:EnableMove(0)
            frame:SetSkinName("None")
            frame:EnableHittestFrame(0)
            --frame:EnableDrawFrame(1)
            frame:SetOffset(1920 / 2 - 450, 1080 / 2 - 350)
            frame:Resize(900, 700)
            
            AOI_ALT_GENERATESLOTS()
            local bg = frame:CreateOrGetControl("picture", "bg", 0, 0, frame:GetWidth(), frame:GetHeight())
            AUTO_CAST(bg)
            bg:EnableHitTest(0)
            bg:CreateInstTexture()
            bg:FillClonePicture("00000000")
        
        
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_GENERATESLOTS()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            
            local stik = AOI_VALUES.stik or {}
            
            for i = 1, 21 do
                local slot = frame:CreateOrGetControl("slot", "slot" .. tostring(i), 50 + 800 / 7 * math.floor((i - 1) / 3.0), 200 + 400 / 3 * ((i - 1) % 3), 50, 50)
                AUTO_CAST(slot)


                slot:EnableDrag(1)
                slot:EnableDrop(1)
                slot:EnablePop(1)
                slot:SetSkinName("slot")
                slot:SetEventScript(ui.DROP, "AOI_ALT_ONDROP")
                slot:SetEventScriptArgNumber(ui.DROP, i)
            end
        
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_ONDROP(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            AUTO_CAST(slot)
            local liftIcon = ui.GetLiftIcon()
            local iconInfo = liftIcon:GetInfo()
            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())
            local itemCls = GetIES(invitem:GetObject())
            
            invitem = session.GetInvItemByType(invitem.type)
            --ISOK?
            if (not invitem) then
                return
            end
            DBGOUT("register")
            slot:ClearIcon();
            slot:RemoveAllChild()
            slot:SetUserValue("clsid", invitem.type)
            UPDATE_INVENTORY_SLOT(slot, invitem, itemCls);
            INV_SLOT_UPDATE(ui.GetFrame("inventory"), invitem, slot);
            slot:EnableDrop(1)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
