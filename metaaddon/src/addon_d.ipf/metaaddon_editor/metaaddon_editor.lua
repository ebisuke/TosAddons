--metaaddon_editor
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local cursorPos = {x = 0, y = 0}
local dragObjects=nil
local function CalcPosScreenToClient(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame("worldmap2_mainmap")
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (ow / sw), y * (oh / sh)
end
local function CalcPosClientToScreen(x, y)
    local sw = option.GetClientWidth()
    local sh = option.GetClientHeight()
    --representative fullscreen frame
    local frame = ui.GetFrame("worldmap2_mainmap")
    local ow = frame:GetWidth()
    local oh = frame:GetHeight()
    return x * (sw/ow), y * (sh/oh)
end
function METAADDON_EDITOR_ON_INIT(addon, frame)
    g.fn.trycatch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.frm.editor = {
                ["addon"] = addon,
                ["frame"] = frame
            }
            local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")
            AUTO_CAST(gbox)
            gbox:SetEventScript(ui.RBUTTONDOWN, "METAADDON_EDITOR_START_DRAG")
            gbox:SetEventScript(ui.RBUTTONUP, "METAADDON_EDITOR_END_DRAG")
            gbox:SetEventScript(ui.LBUTTONDOWN, "METAADDON_EDITOR_START_LDRAG")
            gbox:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_END_LDRAG")
            local timer = frame:GetChild("addontimer")
            AUTO_CAST(timer)
        
            gbox:EnableScrollBar(0)
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_ON_OPEN(frame)
    frame:RunUpdateScript("METAADDON_EDITOR_TIMER", 0.01)

end

function METAADDON_EDITOR_ON_CLOSE(frame)
    frame:StopUpdateScript("METAADDON_EDITOR_TIMER")

end


function METAADDON_EDITOR_TOGGLE_FRAME()
    ui.ToggleFrame("metaaddon_editor")
    METAADDON_EDITOR_RENDER()
end

function METAADDON_EDITOR_RENDER(document)
    g.fn.trycatch {
        try = function()
            document = document or g.document
            local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")
            gbox:RemoveAllChild()
            AUTO_CAST(gbox)
            gbox = g.lib.aodrawpic.inject(gbox)

            document.root:render(gbox, {x = 0, y = 0}, 1)
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_START_LDRAG(frame, ctrl)
    mouse.ChangeCursorImg("BASIC", 1)
    cursorPos = {x = mouse.GetX(), y = mouse.GetY()}
    local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")


    local curposx, curposy = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
    local startcurposx, startcurposy = CalcPosScreenToClient(cursorPos.x, cursorPos.y)
    local basepos = {x = gbox:GetGlobalX(), y = gbox:GetGlobalY()}
    local x=curposx-gbox:GetGlobalX()
    local y=curposy-gbox:GetGlobalY()

    dragObjects=g.document.active:hitTestByBox(x,y,x,y)
    if #dragObjects>0 then
        if #g.document.active.selected>0 then
            dragObjects=g.document.active.selected
        end

    else
        
        dragObjects=nil;

    end

    frame:RunUpdateScript("METAADDON_EDITOR_LDRAGGING", 0.01, 0.0, 0, 1)
end

function METAADDON_EDITOR_END_LDRAG(frame, ctrl)
    mouse.ChangeCursorImg("BASIC", 0)
    frame:StopUpdateScript("METAADDON_EDITOR_LDRAGGING")
    ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor"):RemoveChild("gbox_selection")

    local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")


    local curposx, curposy = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
    local startcurposx, startcurposy = CalcPosScreenToClient(cursorPos.x, cursorPos.y)
    local basepos = {x = gbox:GetGlobalX(), y = gbox:GetGlobalY()}

    local left, top, right, bottom
    left = math.min(startcurposx-gbox:GetGlobalX(), curposx-gbox:GetGlobalX())
    top = math.min(startcurposy-gbox:GetGlobalY(), curposy-gbox:GetGlobalY())
    right = math.max(startcurposx-gbox:GetGlobalX(), curposx-gbox:GetGlobalX())
    bottom = math.max(startcurposy-gbox:GetGlobalY(), curposy-gbox:GetGlobalY())

    --recalculate
    local addonlet = g.document.active
           
    if addonlet then
      
        left=-addonlet.scrollOffset.x/addonlet.zoom+left/addonlet.zoom
        top=-addonlet.scrollOffset.y/addonlet.zoom+top/addonlet.zoom
        right=-addonlet.scrollOffset.x/addonlet.zoom+right/addonlet.zoom
        bottom=-addonlet.scrollOffset.y/addonlet.zoom+bottom/addonlet.zoom
        g.fn.dbgout(string.format("%d,%d,%d,%d",left,top,right,bottom))
        addonlet:selectByBox(left, top, right, bottom)
        METAADDON_EDITOR_RENDER()
    end

end

function METAADDON_EDITOR_TIMER(frame)
    g.fn.trycatch {
        try = function()
            local addonlet = g.document.active
           
            if addonlet then
                if keyboard.IsKeyDown("LBRACKET") == 1 then
                    addonlet.zoom = math.max(0.2, addonlet.zoom - 0.2)

                    METAADDON_EDITOR_RENDER()
                end
                if keyboard.IsKeyDown("RBRACKET") == 1 then
                    addonlet.zoom = math.min(2, addonlet.zoom + 0.2)
                    
                    METAADDON_EDITOR_RENDER()
                end
            end
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
    frame:StopUpdateScript("METAADDON_EDITOR_TIMER")
    frame:RunUpdateScript("METAADDON_EDITOR_TIMER", 0.01)

end

function METAADDON_EDITOR_LDRAGGING()
    g.fn.trycatch {
        try = function()
            local frame = ui.GetFrame("metaaddon_editor")
            if mouse.IsLBtnPressed() == 0 then
                METAADDON_EDITOR_END_LDRAG(frame)
                return
            end
            frame:StopUpdateScript("METAADDON_EDITOR_LDRAGGING")
            frame:RunUpdateScript("METAADDON_EDITOR_LDRAGGING", 0.01, 0.0, 0, 1)
            --frame:RunUpdateScript("METAADDON_EDITOR_DRAGGING")
            local curposx, curposy = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
            local startcurposx, startcurposy = CalcPosScreenToClient(cursorPos.x, cursorPos.y)
            local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")
            local gboxc = gbox:CreateOrGetControl("groupbox", "gbox_selection", 0, 0, 0, 0)

            local basepos = {x = gbox:GetGlobalX(), y = gbox:GetGlobalY()}


            if dragObjects then
                local addonlet=g.document.active
                local x=curposx-startcurposx
                local y=curposy-startcurposy
                for _,v in pairs(dragObjects) do
                    v:setPos(v:getPos().x+x/addonlet.zoom,v:getPos().y+y/addonlet.zoom)
                    
                end
                
                cursorPos={x=mouse.GetX(), y=mouse.GetY()}
                METAADDON_EDITOR_RENDER()

            else
                AUTO_CAST(gboxc)
                gboxc:SetSkinName("bg2")
                local left, top, right, bottom
                left = math.min(startcurposx, curposx)
                top = math.min(startcurposy, curposy)
                right = math.max(startcurposx, curposx)
                bottom = math.max(startcurposy, curposy)
                gboxc:SetOffset(left - basepos.x, top - basepos.y)
                gboxc:Resize(right - left, bottom - top)
                gboxc:EnableHitTest(0)
                gboxc:EnableScrollBar(0)
            end
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_START_DRAG(frame, ctrl)
    mouse.ChangeCursorImg("CURSOR_CAMERA", 1)
    cursorPos = {x = mouse.GetX(), y = mouse.GetY()}
    frame:RunUpdateScript("METAADDON_EDITOR_DRAGGING", 0.01, 0.0, 0, 1)
end

function METAADDON_EDITOR_END_DRAG(frame, ctrl)
    mouse.ChangeCursorImg("BASIC", 0)
    frame:StopUpdateScript("METAADDON_EDITOR_DRAGGING")
end

function METAADDON_EDITOR_DRAGGING()
    g.fn.trycatch {
        try = function()
            local frame = ui.GetFrame("metaaddon_editor")
            if mouse.IsRBtnPressed() == 0 then
                METAADDON_EDITOR_END_DRAG(frame)

                return
            end
            frame:StopUpdateScript("METAADDON_EDITOR_DRAGGING")
            frame:RunUpdateScript("METAADDON_EDITOR_DRAGGING", 0.01, 0.0, 0, 1)
            --frame:RunUpdateScript("METAADDON_EDITOR_DRAGGING")
            local curpos = {x = mouse.GetX(), y = mouse.GetY()}
            local diffx = math.max(-10, math.min(10, (curpos.x - cursorPos.x) / 30))
            local diffy = math.max(-10, math.min(10, (curpos.y - cursorPos.y) / 30))

            local addonlet = g.document.active

            if addonlet then
                addonlet.scrollOffset.x = addonlet.scrollOffset.x + diffx
                addonlet.scrollOffset.y = addonlet.scrollOffset.y + diffy

                local bbox = addonlet:calculateBoundingBox()
                local zoom = addonlet.zoom
                local left = math.floor(bbox.left * zoom)
                local top = math.floor(bbox.top * zoom)
                local right = math.ceil(bbox.right * zoom)
                local bottom = math.ceil(bbox.bottom * zoom)

                addonlet.scrollOffset.x = math.max(left - 200, math.min(right + 200, addonlet.scrollOffset.x))
                addonlet.scrollOffset.y = math.max(top - 200, math.min(bottom + 200, addonlet.scrollOffset.y))

                METAADDON_EDITOR_RENDER()
            end
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_WHEEL()
end
