--DEVELOPERCONSOLESINSPECTOR
local acutil = require("acutil");

local lstr = loadstring or load
local g = g or {}
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
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

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end
local function pairs_sorted(tbl, fun)
    local sortkey = {}
    local n = 0
    for k, v in pairs(tbl) do
        n = n + 1
        sortkey[n] = {k = k, v = v}
    
    end
    fun = fun or function(a, b)
        return a.k < b.k
    end
    table.sort(sortkey, fun)
    
    return ipairs(sortkey)
end
local function iter_filter(iter, fun)
    
    return function(tbl, key)
        local nxt = key
        local val
        while true do
            
            nxt, val = iter(tbl, nxt)
            
            if (not nxt) then
                return
            end
            --filter
            if (fun(nxt, val)) then
                return nxt, val
            end
        end
        return
    end
end
local function iter_concat(iter, iter2, init1, init2)
    
    return coroutine.wrap(
        function(t, k)
            k = init1
            while true do
                local n, v = iter(t, k)
                if (n == nil) then
                    break
                end
                t, k = coroutine.yield(n, v)
            end
            k = init2
            while true do
                local n, v = iter2(t, k)
                if (n == nil) then
                    break
                end
                t, k = coroutine.yield(n, v)
            end
            
            return
        end
)
end


function DEVELOPERCONSOLEINSPECTOR_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsoleinspector")
            DEVELOPERCONSOLEINSPECTOR_INIT()
            if DEVELOPERCONSOLE_SETTINGS.ix ~= nil then
                frame:SetOffset(DEVELOPERCONSOLE_SETTINGS.ix, DEVELOPERCONSOLE_SETTINGS.iy)
                frame:Resize(DEVELOPERCONSOLE_SETTINGS.iw, DEVELOPERCONSOLE_SETTINGS.ih)
                if (DEVELOPERCONSOLE_SETTINGS.visible) then
                    frame:ShowWindow(1);
                else
                    frame:ShowWindow(0);
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_OPEN()
    EBI_try_catch{
        try = function()
            DEVELOPERCONSOLEINSPECTOR_INIT()
            DEVELOPERCONSOLE_SETTINGS.visible = true
            local frame = ui.GetFrame("developerconsoleinspector")
            local timer = frame:GetChild("deeptimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript("DEVELOPERCONSOLEINSPECTOR_ON_DEEPTIMER")
            timer:Start(0.01)
            DEVELOPERCONSOLEINSPECTOR_START_INSPECT()
            DEVELOPERCONSOLE_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_CLOSE()
    EBI_try_catch{
        try = function()
            DEVELOPERCONSOLE_SETTINGS.visible = false
            local frame = ui.GetFrame("developerconsoleinspector")
            local timer = frame:GetChild("deeptimer")
            AUTO_CAST(timer)
            timer:Stop()
            DEVELOPERCONSOLE_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsoleinspector")
            frame:ShowTitleBar(0);
            --devconsole:ShowTitleBarFrame(1);
            frame:SetSkinName("chat_window");
            frame:EnableMove(1);
            frame:SetEventScript(ui.RESIZE, "DEVELOPERCONSOLEINSPECTOR_ON_RESIZE")
            frame:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_SAVE_OFFSET")
            
            frame:SetEventScript(ui.RBUTTONUP, "DEVELOPERCONSOLEINSPECTOR_ON_RCLICK")
            
            
            local label = frame:CreateOrGetControl("richtext", "labeltitle", 0, 0, 100, 30)
            label:SetText("{@st43}{s16}{ol}{#FFFFFF}DeveloperConsole Inspector")
            label:EnableHitTest(0)
            local checkbox = frame:CreateOrGetControl("checkbox", "chkauto", 0, 20, 30, 30)
            checkbox:SetText("{s16}{ol}")
            checkbox:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLEINSPECTOR_ON_CHECK_CHANGED_REFRESH")
            checkbox:SetTextTooltip("Auto Refresh")
            local label = frame:CreateOrGetControl("richtext", "labelsearch", 30, 22, 100, 30)
            label:SetText("{s16}{ol}{#FFFFFF}Search:")
            label:EnableHitTest(0)
            local edit = frame:CreateOrGetControl("edit", "editsearch", 100, 20, 100, 27)
            AUTO_CAST(edit)
            edit:SetFontName("white_16_ol")
            edit:Invalidate()
            edit:SetTypingScp("DEVELOPERCONSOLEINSPECTOR_ON_CHANGED_CONDITION")
            local label = frame:CreateOrGetControl("richtext", "labeltable", 200, 22, 50, 30)
            label:SetText("{s16}{ol}{#FFFFFF}Table:")
            label:EnableHitTest(0)
            local edit = frame:CreateOrGetControl("edit", "edittable", 250, 20, 200, 27)
            AUTO_CAST(edit)
            edit:SetFontName("white_16_ol")
            edit:Invalidate()
            edit:SetTypingScp("DEVELOPERCONSOLEINSPECTOR_ON_CHANGED_CONDITION")
            local label = frame:CreateOrGetControl("richtext", "labelfail", 250, 0, 200, 27)
            local btn = frame:CreateOrGetControl("button", "btntableclear", 450, 20, 50, 27)
            btn:SetText("{ol}Clear")
            btn:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLEINSPECTOR_ON_CLICK_TABLECLEAR")
            local gbox = frame:GetChild("gbox")
            AUTO_CAST(gbox)
            gbox:EnableScrollBar(1)
            gbox:EnableAutoResize(false, false)
            gbox:SetSkinName("bg2")
            local adv = frame:GetChildRecursively("inspector")
            AUTO_CAST(adv)
            adv:SetSkinName("bg2")
            adv:SetStartRow(1);	
            adv:EnableAutoResize(false, true)
            adv:SetEventScript(ui.LBUTTONDBLCLICK, "DEVELOPERCONSOLEINSPECTOR_ADV_ON_LBUTTONDBLCLICK")
            adv:SetRowBgColor(0, "#4a443f");
            adv:SetEventScript(ui.RBUTTONUP, "DEVELOPERCONSOLEINSPECTOR_ADV_ON_RCLICK")
            DEVELOPERCONSOLEINSPECTOR_RESIZE()

            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_ADV_ON_LBUTTONDBLCLICK()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsoleinspector")
            local editsearch = frame:GetChild("editsearch")
            local edittable = frame:GetChild("edittable")
            local adv = frame:GetChildRecursively("inspector")
            AUTO_CAST(adv)
            AUTO_CAST(edittable)
            local key = adv:GetObjectXY(tonumber(adv:GetSelectedKey()), 0):GetText()
            if (key) then
                if (edittable:GetText() ~= "") then
                    edittable:SetText(edittable:GetText() .. "." .. key)
                else
                    edittable:SetText(key)
                end
                edittable:Focus()
                DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, true)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_COPY(mode)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsoleinspector")
            local editsearch = frame:GetChild("editsearch")
            local edittable = frame:GetChild("edittable")
            local adv = frame:GetChildRecursively("inspector")
            AUTO_CAST(adv)
            AUTO_CAST(edittable)
            local select = tonumber(adv:GetSelectedKey())
            local cpy
            if (mode == "FullName") then
                local key = adv:GetObjectXY(select, 0):GetText()
                cpy = edittable:GetText() .. "." .. key
            
            else
                local key = adv:GetObjectXY(select, mode):GetText()
                cpy = key
            end
            
            if (cpy ~= nil) then
                ui.WriteClipboardText(cpy)
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_ON_CLICK_TABLECLEAR()
    local frame = ui.GetFrame("developerconsoleinspector")
    local editsearch = frame:GetChild("editsearch")
    local edittable = frame:GetChild("edittable")
    local adv = frame:GetChildRecursively("inspector")
    AUTO_CAST(adv)
    edittable:SetText("")
    DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, true)

end
function DEVELOPERCONSOLEINSPECTOR_START_INSPECT(force, clear)
    if (not force and not g.ok) then
        return
    end
    local frame = ui.GetFrame("developerconsoleinspector")
    local editsearch = frame:GetChild("editsearch")
    local edittable = frame:GetChild("edittable")
    local gbox = frame:GetChild("gbox")
    local adv = frame:GetChildRecursively("inspector")
    local fail = frame:GetChild("labelfail")
    AUTO_CAST(adv)
    if (clear) then
        adv:ClearUserItems()
        --上にスクロール
        AUTO_CAST(gbox)
        gbox:UpdateData();
        gbox:SetCurLine(0);
        gbox:InvalidateScrollBar();
    
    end
    local code = edittable:GetText()
    local search = editsearch:GetText()
    if (code == "") then
        code = "_G"
    end
    local tbl
    local f = lstr("return (" .. code .. ")");
    local status, r = pcall(f);
    if (status and type(r) == "table") then
        tbl = r
    
    else
        if (DEVELOPERCONSOLE_SETTINGS.enableevalfunc) then
            f = lstr("return " .. code);
            local f2 = lstr(code);
            status, r = pcall(f);
            if (not status or type(r) == "function") then
                status, r = pcall(f2);
            end
            if (not status or r == nil) then
                adv:ClearUserItems()
                DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(false)
                fail:SetText("{ol}{s16}{#FF4444}FAILED")
                return
            end
        else
            adv:ClearUserItems()
            DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(false)
            fail:SetText("{ol}{s16}{#FF4444}INVALID")
            return
        end
    end
    if (type(tbl) ~= "table") then
        adv:ClearUserItems()
        DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(false)
        fail:SetText("{ol}{s16}{#FF4444}NOT A TABLE")
        return
    end
    --イテレータ作成
    g.iter, g.tbl, g.iterkey = pairs_sorted(tbl)
    local iter = iter_filter(g.iter, function(k, v)
        if (search == "") then
            return true
        end
        
        return v.k:lower():starts(search:lower())
    end)
    g.iter = iter
    g.ok = false
    g.pos = 0
    fail:SetText("")
    DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(true)
end
function DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(enable)
    local frame = ui.GetFrame("developerconsoleinspector")
    local timer = frame:GetChild("coarsetimer")
    AUTO_CAST(timer)
    if (enable) then
        timer:SetUpdateScript("DEVELOPERCONSOLEINSPECTOR_ON_TIMER");
        timer:Start(2)
    else
        timer:Stop()
    end
end
function DEVELOPERCONSOLEINSPECTOR_ON_RCLICK()
    local frame = ui.GetFrame("developerconsoleinspector");
    local context = ui.CreateContextMenu("Context", "", 0, 0, 300, 100)
    ui.AddContextMenuItem(context, "Close Inspector", "ui.CloseFrame('developerconsoleinspector')")
    if (not DEVELOPERCONSOLE_SETTINGS.enableevalfunc) then
        ui.AddContextMenuItem(context, "Enable Evaluation{nl}{s12}Warning! This feature is Dangerous.", "DEVELOPERCONSOLEINSPECTOR_TOGGLE_FUNCTION_EVAL()")
    else
        ui.AddContextMenuItem(context, "Disable Evaluation", "DEVELOPERCONSOLEINSPECTOR_TOGGLE_FUNCTION_EVAL()")
    end
    if (not DEVELOPERCONSOLE_SETTINGS.visiblefunc) then
        ui.AddContextMenuItem(context, "Show Function and userdata", "DEVELOPERCONSOLEINSPECTOR_TOGGLE_SHOWFUNCTION()")
    else
        ui.AddContextMenuItem(context, "Hide Function and userdata", "DEVELOPERCONSOLEINSPECTOR_TOGGLE_SHOWFUNCTION()")
    end
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)
end
function DEVELOPERCONSOLEINSPECTOR_ADV_ON_RCLICK()
    local frame = ui.GetFrame("developerconsoleinspector");
    local context = ui.CreateContextMenu("Context", "", 0, 0, 300, 100)
    ui.AddContextMenuItem(context, "Copy Name", "DEVELOPERCONSOLEINSPECTOR_COPY(0)")
    ui.AddContextMenuItem(context, "Copy FullName", "DEVELOPERCONSOLEINSPECTOR_COPY('FullName')")
    ui.AddContextMenuItem(context, "Copy Value", "DEVELOPERCONSOLEINSPECTOR_COPY(2)")
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)
end

function DEVELOPERCONSOLEINSPECTOR_TOGGLE_FUNCTION_EVAL()
    DEVELOPERCONSOLE_SETTINGS.enableevalfunc = not DEVELOPERCONSOLE_SETTINGS.enableevalfunc
    DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, true)
    DEVELOPERCONSOLE_SAVE_SETTINGS()
end
function DEVELOPERCONSOLEINSPECTOR_TOGGLE_SHOWFUNCTION()
    DEVELOPERCONSOLE_SETTINGS.visiblefunc = not DEVELOPERCONSOLE_SETTINGS.visiblefunc
    DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, true)
    DEVELOPERCONSOLE_SAVE_SETTINGS()
end
function DEVELOPERCONSOLEINSPECTOR_ON_CHECK_CHANGED_REFRESH()
    local frame = ui.GetFrame("developerconsoleinspector");
    local checkbox = frame:GetChild("chkauto")
    AUTO_CAST(checkbox)
    if (checkbox:IsChecked() == 1) then
        DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, false)
        DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(true)
    else
        DEVELOPERCONSOLEINSPECTOR_ENABLETIMER(false)
    end
end
function DEVELOPERCONSOLEINSPECTOR_ON_RESIZE()
    DEVELOPERCONSOLEINSPECTOR_RESIZE()
    DEVELOPERCONSOLE_SAVE_OFFSET()
end
function DEVELOPERCONSOLEINSPECTOR_ON_CHANGED_CONDITION()
    DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, true)
end
function DEVELOPERCONSOLEINSPECTOR_ON_TIMER()
    local frame = ui.GetFrame("developerconsoleinspector");
    DEVELOPERCONSOLEINSPECTOR_START_INSPECT(false, false)
end
function DEVELOPERCONSOLEINSPECTOR_ON_DEEPTIMER()
    EBI_try_catch{
        try = function()
            if (g.iter and g.iterkey) then
                local frame = ui.GetFrame("developerconsoleinspector");
                local adv = frame:GetChildRecursively("inspector")
                AUTO_CAST(adv)
                local limit = 75
                for i = 0, limit do
                    local v
                    g.iterkey, v = g.iter(g.tbl, g.iterkey)
                    if (g.iterkey == nil) then
                        g.iter = nil
                        g.ok = true
                        
                        break
                    end
                    if ((not DEVELOPERCONSOLE_SETTINGS.visiblefunc and (type(v.v) == "function" or type(v.v) == "userdata"))) then
                        -- do not show
                        else
                        --add or update
                        local item
                        local key = g.pos + 1
                        item = adv:SetItem(key, 0, v.k, "white_16_ol")
                        item:SetTextAlign("left", "top");
                        item:SetTextTooltip(v.k)
                        item:SetGravity(ui.LEFT, ui.TOP)
                        item:SetOffset(0, 20 * g.pos + 20)
                        item:Resize(adv:GetWidth() - 20, item:GetHeight());
                        
                        item = adv:SetItem(key, 1, type(v.v), "white_16_ol")
                        item:SetTextAlign("left", "top");
                        
                        item:SetGravity(ui.LEFT, ui.TOP)
                        item:SetOffset(adv:GetColWidth(0), 20 * g.pos + 20)
                        local width = adv:GetColWidth(1);
                        item:Resize(width, item:GetHeight());
                        if (type(v.v) == "table" or type(v.v) == "function") then
                            item = adv:SetItem(key, 2, "", "white_16_ol")
                        else
                            item = adv:SetItem(key, 2, " " .. tostring(v.v), "white_16_ol")
                        end
                        
                        item:SetTextAlign("left", "top");
                        
                        item:SetGravity(ui.LEFT, ui.TOP)
                        item:SetOffset(adv:GetColWidth(0) + adv:GetColWidth(1), 20 * g.pos + 20)
                        local width = adv:GetColWidth(2);
                        item:Resize(width, item:GetHeight());
                        g.pos = g.pos + 1
                        if (adv:GetHeight() < 20 * g.pos) then
                            adv:Resize(adv:GetWidth(), 20 * g.pos)
                        end
                        --adv:UpdateAdvBox();
                        if (g.pos > 10000) then
                            g.iter = nil
                            g.ok = true
                            
                            break
                        end
                    end
                --FIXWIDTH_ADVBOX_ITEM(adv, 2, item)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLEINSPECTOR_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsoleinspector");
            local gbox = frame:GetChild("gbox")
            local adv = frame:GetChildRecursively("inspector")
            AUTO_CAST(adv)
            gbox:SetGravity(ui.LEFT, ui.TOP)
            gbox:SetOffset(5, 50)
            
            gbox:Resize(frame:GetWidth() - 10, frame:GetHeight() - 55)
            adv:SetGravity(ui.LEFT, ui.TOP)
            adv:SetOffset(0, 0)
            adv:Resize(gbox:GetWidth(), gbox:GetHeight())
  
            DEVELOPERCONSOLEINSPECTOR_START_INSPECT(true, false)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
