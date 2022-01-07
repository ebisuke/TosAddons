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
local acutil = require("acutil")
local cursorPos = {x = 0, y = 0}
local dragObjects = nil
local linemode = nil
local addnodemode = nil
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
    return x * (sw / ow), y * (sh / oh)
end
function METAADDON_EDITOR_ON_INIT(addon, frame)
    g.fn.trycatch {
        try = function()
            frame = ui.GetFrame("metaaddon_editor")
            g.frm.editor = {
                ["addon"] = addon,
                ["frame"] = frame
            }
            local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")
            AUTO_CAST(gbox)
            gbox:SetEventScript(ui.RBUTTONDOWN, "METAADDON_EDITOR_START_DRAG")
            gbox:SetEventScript(ui.RBUTTONUP, "METAADDON_EDITOR_END_DRAG")
            gbox:SetEventScript(ui.LBUTTONDOWN, "METAADDON_EDITOR_START_LDRAG")
            gbox:SetEventScript(ui.LBUTTONDBLCLICK, "METAADDON_EDITOR_LBUTTONDBLCLICK")
            gbox:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_END_LDRAG")
            local timer = frame:GetChild("addontimer")
            AUTO_CAST(timer)

            gbox:EnableScrollBar(0)

            local btn = frame:CreateOrGetControl("button", "menu_button", 20, 10, 100, 40)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_MENU_BUTTON")
            btn:SetText("...")

            local btn = frame:CreateOrGetControl("button", "menu_button_add", 120, 10, 100, 40)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_ADD_BUTTON")
            btn:SetText("Add")

            local btn = frame:CreateOrGetControl("button", "menu_button_start", 240, 10, 100, 40)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_START_BUTTON")
            btn:SetText("Start")

            local btn = frame:CreateOrGetControl("button", "menu_button_stop", 360, 10, 100, 40)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_STOP_BUTTON")
            btn:SetText("Stop")

            local gboxtab = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_tab")
            AUTO_CAST(gboxtab)
            local tab=gboxtab:CreateOrGetControl("tab","tab",0,0,gboxtag:GetWidth(),gboxtab:GetHeight())
            AUTO_CAST(tab)
            METAADDON_EDITOR_RECREATE_TAB()
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

            document.active:render(gbox, {x = 0, y = 0}, 1)
            if linemode then
                local sx = linemode:getPos().x * g.document.active.zoom + g.document.active.scrollOffset.x
                local sy = linemode:getPos().y * g.document.active.zoom + g.document.active.scrollOffset.y
                local dx, dy = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
                dx = dx - gbox:GetGlobalX()
                dy = dy - gbox:GetGlobalY()
                local stream = linemode:createCompatibleStream(nil)
                local color = stream:getColor()
                stream:release()
                for i = 0, 16 do
                    local x = (dx - sx) * i / 16 + sx
                    local y = (dy - sy) * i / 16 + sy
                    gbox:DrawBrushHorz(x, y, x, y, "brush_8", color)
                end
            end
            gbox:Invalidate()
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_START_LDRAG(frame, ctrl)
    g.fn.trycatch {
        try = function()
            mouse.ChangeCursorImg("BASIC", 1)
            cursorPos = {x = mouse.GetX(), y = mouse.GetY()}
            local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")

            local curposx, curposy = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
            local startcurposx, startcurposy = CalcPosScreenToClient(cursorPos.x, cursorPos.y)
            local basepos = {x = gbox:GetGlobalX(), y = gbox:GetGlobalY()}
            local x =
                (curposx - gbox:GetGlobalX()) / g.document.active.zoom -
                g.document.active.scrollOffset.x / g.document.active.zoom
            local y =
                (curposy - gbox:GetGlobalY()) / g.document.active.zoom -
                g.document.active.scrollOffset.y / g.document.active.zoom
            if addnodemode then
                addnodemode = nil

                METAADDON_EDITOR_RENDER()
                return
            end
            dragObjects = g.document.active:hitTestByBox(x, y, x, y)
            local addonlet = g.document.active

            if g.fn.len(dragObjects) > 0 then
                local len = g.fn.len(dragObjects)
                local node = g.fn.tableFirst(dragObjects)
                if keyboard.IsKeyPressed("LALT") == 1 and node:instanceOf(g.cls.MAGate()) then
                    for _, v in pairs(node:getStreams()) do
                        v:release()
                    end
                    METAADDON_EDITOR_RENDER()
                    return
                end
                if g.fn.len(g.document.active.selected) > 0 and g.document.active.selected[node:getID()] then
                    dragObjects = g.document.active.selected
                else
                    addonlet:selectByBox(x, y, x, y)
                end
                if len == 1 then
                    if keyboard.IsKeyPressed("LCTRL") == 1 and node:instanceOf(g.cls.MAGate()) then
                        g.fn.dbgout("METAADDON_EDITOR_START_LDRAG:"..node._className)
                        linemode = node
                       
                    end

                    dragObjects = dragObjects or {}
                    dragObjects[node:getID()] = node
                end
            else
                dragObjects = nil
            end
            frame:RunUpdateScript("METAADDON_EDITOR_LDRAGGING", 0.01, 0.0, 0, 1)
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
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
    left = math.min(startcurposx - gbox:GetGlobalX(), curposx - gbox:GetGlobalX())
    top = math.min(startcurposy - gbox:GetGlobalY(), curposy - gbox:GetGlobalY())
    right = math.max(startcurposx - gbox:GetGlobalX(), curposx - gbox:GetGlobalX())
    bottom = math.max(startcurposy - gbox:GetGlobalY(), curposy - gbox:GetGlobalY())
    local x =
        (curposx - gbox:GetGlobalX()) / g.document.active.zoom -
        g.document.active.scrollOffset.x / g.document.active.zoom
    local y =
        (curposy - gbox:GetGlobalY()) / g.document.active.zoom -
        g.document.active.scrollOffset.y / g.document.active.zoom
    --recalculate
    local addonlet = g.document.active
    if linemode then
        dragObjects = g.document.active:hitTestByBox(x, y, x, y)
        if g.fn.len(dragObjects) > 0 then
            if g.fn.len(dragObjects) == 1 then
                if g.fn.tableFirst(dragObjects):instanceOf(g.cls.MAGate()) then
                    --connect

                    local dest = g.fn.tableFirst(dragObjects)
                    local src = linemode
                    linemode = nil
                    METAADDON_EDITOR_RENDER()
                    if dest:hasSameStream(src) then
                        g.fn.errout("Cannot connect to same stream")
                        return
                    end
                    if src:hasSameStream(dest) then
                        g.fn.errout("Cannot connect to same stream")
                        return
                    end
                    if dest:isInlet() == src:isInlet() then
                        g.fn.errout("Cannot connect out to out or in to in")
                        return
                    end
                    local streamclass = src:createCompatibleStream(nil)
                    if not dest:isConnectableStream(streamclass) or not src:isConnectableStream(streamclass) then
                        g.fn.errout("Cannot connect to non-connectable stream")

                        return
                    end
                    local streamclass = src:createCompatibleStream(dest)

                    return
                end
            end
        end
        linemode = nil
        METAADDON_EDITOR_RENDER()
    else
        if addonlet then
            left = -addonlet.scrollOffset.x / addonlet.zoom + left / addonlet.zoom
            top = -addonlet.scrollOffset.y / addonlet.zoom + top / addonlet.zoom
            right = -addonlet.scrollOffset.x / addonlet.zoom + right / addonlet.zoom
            bottom = -addonlet.scrollOffset.y / addonlet.zoom + bottom / addonlet.zoom

            addonlet:selectByBox(left, top, right, bottom)
            METAADDON_EDITOR_RENDER()
        end
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
                if keyboard.IsKeyDown("DELETE") == 1 then
                    for k,v in pairs(addonlet.selected) do
                        if v:instanceOf(g.cls.MANode()) then
                           
                            v:release()
                            addonlet:removeNode(v)
                        end
   
                    end
                    METAADDON_EDITOR_RENDER()
                    return
                end
            end
            if addnodemode then
                if keyboard.IsKeyDown("ESCAPE") == 1 then
                    addonlet:removeNode(addnodemode)
                    addnodemode = nil
                else
                    local x, y = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
                    local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")

                    x=x-gbox:GetGlobalX()
                    y=y-gbox:GetGlobalY()
                    
                    x = (x - g.document.active.scrollOffset.x) / g.document.active.zoom
                    y = (y - g.document.active.scrollOffset.y) / g.document.active.zoom
                    addnodemode:setPos(x, y)
                end

                METAADDON_EDITOR_RENDER()
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

            if linemode then
                METAADDON_EDITOR_RENDER()
            elseif dragObjects then
                local addonlet = g.document.active
                local x = curposx - startcurposx
                local y = curposy - startcurposy
                for _, v in pairs(dragObjects) do
                    v:setPos(v:getPos().x + x / addonlet.zoom, v:getPos().y + y / addonlet.zoom)
                end

                cursorPos = {x = mouse.GetX(), y = mouse.GetY()}
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
function METAADDON_EDITOR_LBUTTONDBLCLICK()
    g.fn.trycatch {
        try = function()
            mouse.ChangeCursorImg("BASIC", 1)
            cursorPos = {x = mouse.GetX(), y = mouse.GetY()}
            local gbox = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_editor")

            local curposx, curposy = CalcPosScreenToClient(mouse.GetX(), mouse.GetY())
            local startcurposx, startcurposy = CalcPosScreenToClient(cursorPos.x, cursorPos.y)
            local basepos = {x = gbox:GetGlobalX(), y = gbox:GetGlobalY()}
            local x =
                (curposx - gbox:GetGlobalX()) / g.document.active.zoom -
                g.document.active.scrollOffset.x / g.document.active.zoom
            local y =
                (curposy - gbox:GetGlobalY()) / g.document.active.zoom -
                g.document.active.scrollOffset.y / g.document.active.zoom

            dragObjects = g.document.active:hitTestByBox(x, y, x, y)
            local addonlet = g.document.active

            if g.fn.len(dragObjects) > 0 then
                local len = g.fn.len(dragObjects)
                local node = g.fn.tableFirst(dragObjects)

                ui.GetFrame("metaaddon_node"):ShowWindow(1)
                METAADDON_NODE_SET(node)
            end
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_MENU_BUTTON()
    local context = ui.CreateContextMenu("CONTEXT_METAADDON_EDITOR", "Menu", 0, 0, 200, 200)
    ui.AddContextMenuItem(context, "New", "METAADDON_EDITOR_NEW()")
    ui.AddContextMenuItem(context, "Save", "METAADDON_EDITOR_SAVE()")
    ui.AddContextMenuItem(context, "Load", "METAADDON_EDITOR_LOAD()")
    ui.OpenContextMenu(context)
end
function METAADDON_EDITOR_NEW()
    ui.MsgBox("Would you like to clear current document?", "METAADDON_EDITOR_NEW_CONFIRM()", "None")
end
function METAADDON_EDITOR_NEW_CONFIRM()
    g.document.active = g.cls.MAAddonlet():init()
    METAADDON_EDITOR_RENDER()
end
function METAADDON_EDITOR_LOADROOTFILE()
    g.fn.trycatch {
        try = function()
            local obj = acutil.loadJSON(g.basepath.."\\_"..info.GetCID(session.GetMyHandle())..".json")
            
            g.document.active = g.fn.DeserializeObject(obj)
            g.document.opened[#g.document.opened+1] =  g.document.active 
            g.document.active.addonletName=g.document.active 
            METAADDON_EDITOR_RECREATE_TAB()
            METAADDON_EDITOR_RENDER()
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_LOADFILE(name)
    g.fn.trycatch {
        try = function()
            local obj = acutil.loadJSON(g.basepath.."\\"..name..".json")
            
            g.document.active = g.fn.DeserializeObject(obj)
            g.document.opened[#g.document.opened+1] =  g.document.active 
            g.document.active.addonletName=g.document.active 
            METAADDON_EDITOR_RECREATE_TAB()
            METAADDON_EDITOR_RENDER()
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_SAVEFILE(name)
    g.fn.trycatch {
        try = function()
            g.document.active.addonletName=name
            acutil.saveJSON(g.basepath.."\\"..name.."json", g.fn.SerializeObject(g.document.active))
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_CLOSEFILE()
    g.fn.trycatch {
        try = function()
            g.document.opened[g.document.active.addonletName] = nil
            g.document.active=g.fn.tableFirst(g.document.opened)
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_EDITOR_ADD_BUTTON()
    g.fn.trycatch {
        try = function()
            local context = ui.CreateContextMenu("CONTEXT_METAADDON_EDITOR_ADD", "Add Node", 0, 0, 200, 200)
            for k, v in pairs(g.fn.GetListOfNodeClasses()) do
                ui.AddContextMenuItem(context, v, "METAADDON_EDITOR_ADD_NODE('" ..v .. "')")
            end

            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end

function METAADDON_EDITOR_ADD_NODE(nodename)
    local node = g.cls[nodename]({x = 0, y = 0},{w=100,h=100}):init()
    g.document.active:addNode(node)
    addnodemode = node
end

function METAADDON_EDITOR_GET_NODE_BY_ID(id)
    for k, v in pairs(g.document.active.nodes) do
        if v:getID() == id then
            return v
        end
    end
end

function METAADDON_EDITOR_START_BUTTON()
    if METAADDON_COMPILE() then
        g.personalsettings.isrunning=true
    else
        ui.MsgBox("Compile Failed.", "None", "None")
        g.personalsettings.isrunning=false
    end
   

end

function METAADDON_EDITOR_STOP_BUTTON()
    g.personalsettings.isrunning=false
end

function METAADDON_EDITOR_RECREATE_TAB()
    local frame = ui.GetFrame("metaaddon_editor")
    local gboxtab = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_tab")
    local tab=gboxtab:CreateOrGetControl("tab","tab",0,0,gboxtab:GetWidth(),gboxtab:GetHeight())
    AUTO_CAST(tab)

    tab:SetSkinName("tab2")
    tab:SetEventScript(ui.LBUTTONUP, "METAADDON_EDITOR_TAB_CLICK")
    for k,v in pairs(g.document.opened) do
        tab:AddItem(v.title)

    end
end

function METAADDON_EDITOR_TAB_CLICK()
    local frame = ui.GetFrame("metaaddon_editor")
    local gboxtab = ui.GetFrame("metaaddon_editor"):GetChildRecursively("gbox_tab")
    local tab=gboxtab:CreateOrGetControl("tab","tab",0,0,gboxtab:GetWidth(),gboxtab:GetHeight())
    AUTO_CAST(tab)

    local index=tab:GetSelectItemIndex()
    
    g.document.active=g.document.opened[index]
    METAADDON_EDITOR_RENDER()
    
end