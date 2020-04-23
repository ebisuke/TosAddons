--DEVELOPERCONSOLE
local acutil = require("acutil");

DEVELOPERCONSOLE_SETTINGSLOCATION = string.format('../addons/%s/settings.json', "developerconsole")
DEVELOPERCONSOLE_TEMPTEXTLOCATION = string.format('../addons/%s/temptext.txt', "developerconsole")
DEVELOPERCONSOLE_SETTINGS = DEVELOPERCONSOLE_SETTINGS or {}
DEVELOPERCONSOLE_DEBUG = false
DEVELOPERCONSOLE_CURSOR = 0
DEVELOPERCONSOLE_INTELLI = false
DEVELOPERCONSOLE_INTELLI_COUNT = 0
DEVELOPERCONSOLE_INTELLI_TABLE = nil
DEVELOPERCONSOLE_INTELLI_PREFIX = ""
DEVELOPERCONSOLE_INTELLI_STR = ""
DEVELOPERCONSOLE_INTELLI_ITERATOR = nil
DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY = nil
DEVELOPERCONSOLE_INTELLI_SELECT = 0
DEVELOPERCONSOLE_INTELLI_CHOOSEFIRST=false
local lstr = loadstring or load
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


function DEVELOPERCONSOLE_ON_INIT(addon, frame)
    acutil.slashCommand("/dev", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/console", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/devconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
    acutil.slashCommand("/developerconsole", DEVELOPERCONSOLE_TOGGLE_FRAME);
    
    acutil.setupHook(DEVELOPERCONSOLE_PRINT_TEXT, "print");
    acutil.addSysIcon('developerconsole', 'sysmenu_sys', 'developerconsole', 'DEVELOPERCONSOLE_TOGGLE_FRAME')
    if not DEVELOPERCONSOLE_SETTINGSLOADED then
        DEVELOPERCONSOLE_SETTINGS = {
            history = {}
        }
        local t, err = acutil.loadJSON(DEVELOPERCONSOLE_SETTINGSLOCATION, DEVELOPERCONSOLE_SETTINGS)
        if err then
            --設定ファイル読み込み失敗時処理
            CHAT_SYSTEM(string.format('[%s] cannot load setting files', "developerconsole"))
        else
            --設定ファイル読み込み成功時処理
            DEVELOPERCONSOLE_SETTINGS = t
        end
        DEVELOPERCONSOLE_SETTINGSLOADED = true
    end
    DEVELOPERCONSOLE_LOG = {}
    DEVELOPERCONSOLE_INIT()
    CLEAR_CONSOLE();
end
function DEVELOPERCONSOLE_SAVE_SETTINGS()
    
    acutil.saveJSON(DEVELOPERCONSOLE_SETTINGSLOCATION, DEVELOPERCONSOLE_SETTINGS)
end
function DEVELOPERCONSOLE_TOGGLE_FRAME()
    ui.ToggleFrame("developerconsole");
end

function DEVELOPERCONSOLE_OPEN()
    
    DEVELOPERCONSOLE_INIT()

end
function DEVELOPERCONSOLE_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsole");
            local textViewLog = frame:GetChild("textview_log");
            textViewLog:ShowWindow(1);
            textViewLog:SetEventScript(ui.RBUTTONUP, "DEVELOPERCONSOLE_LOG_ON_RCLICK")
            frame:ShowTitleBar(0);
            --devconsole:ShowTitleBarFrame(1);
            frame:SetSkinName("chat_window");
            frame:EnableMove(1);
            frame:SetEventScript(ui.RESIZE, "DEVELOPERCONSOLE_ON_RESIZE")
            frame:SetEventScript(ui.RBUTTONDOWN, "DEVELOPERCONSOLE_DEBUG_RELOAD")
            frame:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_SAVE_OFFSET")
            if DEVELOPERCONSOLE_SETTINGS.x ~= nil then
                frame:SetOffset(DEVELOPERCONSOLE_SETTINGS.x, DEVELOPERCONSOLE_SETTINGS.y)
                frame:Resize(DEVELOPERCONSOLE_SETTINGS.w, DEVELOPERCONSOLE_SETTINGS.h)
            
            end
            local textViewLog = frame:GetChild("textview_log");
            local input = frame:GetChild("input");
            AUTO_CAST(input)
            input:SetEnableEditTag(1)
            --trick
            input:SetFontName("white_16_ol")
            --input:SetFormat("{@st42b}{s16}{#FFFFFF}%s{/}")
            --input:SetFontName("")
            input:SetTypingScp('DEVELOPERCONSOLE_ON_TYPE');
            
            local execute = frame:GetChild("execute");
            execute:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_ENTER_KEY")
            execute:SetFontName("white_16_ol")

            local btnopt = frame:CreateOrGetControl("button", "btnopt", 0, 0, 0, 0)
            btnopt:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_CONTEXT")
            btnopt:SetText("...")
            btnopt:SetFontName("white_16_ol")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("DEVELOPERCONSOLE_UPDATE");
            timer:Start(0.01);
            DEVELOPERCONSOLE_RESIZE()
            local isf = ui.GetFrame("developerconsoleintellisense")
            isf:SetSkinName("None")
            isf:Resize(600, 230)
            local sig = isf:CreateOrGetControl("richtext", "signature", 0, 0, 0, 0)
            sig:EnableHitTest(0)
            sig:Resize(600, 30)
            sig:SetSkinName("editbox")
            local list = isf:GetChild("triggers");
            AUTO_CAST(list)
            list:SetOffset(0, 30)
            list:Resize(600, 200)
            list:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_ON_DETERMINE_INTELLI")
            list:SetFontName("white_16_ol")
            list:SetSkinName("listbox")
        --list:AddColumn("")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_DEBUG_RELOAD()
    if DEVELOPERCONSOLE_DEBUG then
        local ebi = "E:\\\\ToSProject\\\\TosAddons\\\\developerconsoleex\\\\src\\\\addon_d.ipf\\\\developerconsole\\\\developerconsole.lua"
        if DEVELOPERCONSOLE_DEBUG then
            local f = assert(lstr('dofile("' .. ebi .. '")'));
            local status, error = pcall(f);
            if not status then
                CHAT_SYSTEM(tostring(error));
            else
                CHAT_SYSTEM("RELOADED DC")
                DEVELOPERCONSOLE_INIT()
            end
        end
        ebi = "E:\\\\ToSProject\\\\TosAddons\\\\developerconsoleex\\\\src\\\\addon_d.ipf\\\\developerconsoleinspector\\\\developerconsoleinspector.lua"
   
        local f = assert(lstr('dofile("' .. ebi .. '")'));
        local status, error = pcall(f);
        if not status then
            CHAT_SYSTEM(tostring(error));
        else
            CHAT_SYSTEM("RELOADED DCI")
            DEVELOPERCONSOLEINSPECTOR_INIT()
        end
    end
end
function DEVELOPERCONSOLE_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsole");
            local textViewLog = frame:GetChild("textview_log");
            local input = frame:GetChild("input");
            local execute = frame:GetChild("execute");
            local btnopt = frame:GetChild("btnopt")
            local w = frame:GetWidth()
            local h = frame:GetHeight()
            local m = 10
            local nl = 0
            local nlmargin = 20 * nl
            local btm = 30
            textViewLog:SetOffset(m, m)
            textViewLog:Resize(w - m * 2, h - m * 2 - btm - nlmargin)
            
            input:SetOffset(m, h - m - btm - nlmargin)
            --trick
            input:Resize(w - m * 2 - 70, 40 + nlmargin)
            input:Invalidate()
            input:Resize(w - m * 2 - 70, 30 + nlmargin)
            input:Invalidate()
            
            execute:SetOffset(w - 70 - m, h - m - btm)
            execute:Resize(40, 30)
            
            btnopt:SetOffset(w - 30 - m, h - m - btm)
            btnopt:Resize(30, 30)
            frame:Invalidate()
        end,
        catch = function(error)
            --ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_LOG_ON_RCLICK()
    local frame = ui.GetFrame("developerconsole");
    local context = ui.CreateContextMenu("Context", "", 0, 0, 300, 100)
    ui.AddContextMenuItem(context, "Copy", "DEVELOPERCONSOLE_COPY()")
    context:Resize(100, context:GetHeight())
    ui.OpenContextMenu(context)

end
function DEVELOPERCONSOLE_COPY()
    local f
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("developerconsole");
            local textViewLog = frame:GetChild("textview_log");
            local text = ""
            -- f = io.open(DEVELOPERCONSOLE_TEMPTEXTLOCATION, "w")
            for _, v in ipairs(DEVELOPERCONSOLE_LOG) do
                text = text .. v .. "\n"
            --f:write(text .. "\n")
            end
            -- f:close()
            --local s = DEVELOPERCONSOLE_TEMPTEXTLOCATION:gsub("/", "\\")
            --debug.ShellExecute("notepad \"" .. s .. "\"")
            ui.WriteClipboardText(text)
        end,
        catch = function(error)
            ERROUT(error)
        -- f:close()
        end
    }
end
function DEVELOPERCONSOLE_ON_TYPE()
    local frame = ui.GetFrame("developerconsole");
    local input = frame:GetChild("input");
    local text = input:GetCursurLeftText();
    if ui.IsFrameVisible("developerconsoleintellisense") == 1 then
        if (text:match("([%w_%.%,%(%)])$") ~= nil) then
            DEVELOPERCONSOLE_INTELLISENSE()
        else
            DEVELOPERCONSOLE_INTELLI_CLOSE()
        end
    else
        if (text:match("([%w_%.%,%(%)])$") ~= nil) then
            DEVELOPERCONSOLE_INTELLISENSE()
        end
    end
end
function DEVELOPERCONSOLE_SAVE_OFFSET()
    local frame = ui.GetFrame("developerconsole");
    DEVELOPERCONSOLE_SETTINGS.x = frame:GetX()
    DEVELOPERCONSOLE_SETTINGS.y = frame:GetY()
    DEVELOPERCONSOLE_SETTINGS.w = frame:GetWidth()
    DEVELOPERCONSOLE_SETTINGS.h = frame:GetHeight()
    local frame = ui.GetFrame("developerconsoleinspector");
    DEVELOPERCONSOLE_SETTINGS.ix = frame:GetX()
    DEVELOPERCONSOLE_SETTINGS.iy = frame:GetY()
    DEVELOPERCONSOLE_SETTINGS.iw = frame:GetWidth()
    DEVELOPERCONSOLE_SETTINGS.ih = frame:GetHeight()
    DEVELOPERCONSOLE_SAVE_SETTINGS()
end
function DEVELOPERCONSOLE_ON_RESIZE()
    DEVELOPERCONSOLE_RESIZE()
    DEVELOPERCONSOLE_SAVE_OFFSET()
end
function DEVELOPERCONSOLE_TOGGLEINSPECTOR()
    if(keyboard.IsKeyPressed("LSHIFT")==1)then
        local frame=   ui.GetFrame('developerconsoleinspector')
        frame:Resize(500,800) 
        frame:SetOffset(0,0)
    end
    ui.ToggleFrame('developerconsoleinspector')
end
function DEVELOPERCONSOLE_CONTEXT()
    local frame = ui.GetFrame("developerconsole");
    local context = ui.CreateContextMenu("Context", "", 0, 0, 300, 100)
    ui.AddContextMenuItem(context, "Toggle Inspector", "DEVELOPERCONSOLE_TOGGLEINSPECTOR()")
    ui.AddContextMenuItem(context, "Clear Console", "CLEAR_CONSOLE()")
    if (DEVELOPERCONSOLE_SETTINGS.intellisense) then
        ui.AddContextMenuItem(context, "Disable AutoCompletion", "DEVELOPERCONSOLE_TOGGLEENABLE_INTELLISENSE()")
    else
        ui.AddContextMenuItem(context, "Enable AutoCompletion", "DEVELOPERCONSOLE_TOGGLEENABLE_INTELLISENSE()")
    end
    ui.AddContextMenuItem(context, "-> Add Tag Snippet{nl}   (Press ALT + ENTER to execute)", "DEVELOPERCONSOLE_CONTEXT_SUB_TAG()")
    ui.AddContextMenuItem(context, "Do File", "DEVELOPERCONSOLE_DOFILE_CHOOSE()")
    ui.AddContextMenuItem(context, "Debug Frame", "TOGGLE_UI_DEBUG()")
    ui.AddContextMenuItem(context, "{} to <>", "DEVELOPERCONSOLE_ESCAPEBRACKET()")
    ui.AddContextMenuItem(context, "<> to {}", "DEVELOPERCONSOLE_SURROUNDBRACKET()")
    ui.AddContextMenuItem(context, "Show Explorer", "DEVELOPERCONSOLE_EXPLORER()")
    ui.AddContextMenuItem(context, "-> Useful? Stuff Frames", "DEVELOPERCONSOLE_CONTEXT_SUB_FRAMES()")
    
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)

end
function DEVELOPERCONSOLE_CONTEXT_SUB_FRAMES()
    local context = ui.CreateContextMenu("Context_Sub", "", 0, 0, 300, 100)
    
    local frames = {
        "font_list"
    }
    
    for _, v in ipairs(frames) do
        ui.AddContextMenuItem(context, v, "ui.ToggleFrame('" .. v .. "');ui.GetFrame('" .. v .. "'):EnableMove(1)")
    end
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)
end
function DEVELOPERCONSOLE_CONTEXT_SUB_TAG()
    
    EBI_try_catch{
        try = function()
            
            local context = ui.CreateContextMenu("Context_Sub", "", 0, 0, 300, 100)
            local myPartyInfo = session.party.GetPartyInfo();
            local partyID="_"
            local name="_"
            if(myPartyInfo~=nil)then
                partyID = myPartyInfo.info:GetPartyID();	
                name=myPartyInfo.info.name
            end
            local list = {
                {n="Image",v= "\'{img _ 20 20}{/}\'"},
                {n="Current Location",v = "DEVELOPERCONSOLE_CONTECT_ADDLINKPOS"},
                {n="Current Party Link",v= "\'{a SLP "..tostring(partyID).."}{#0000FF}{img link_party 24 24}"..name.."{/}{/}{/}\'"},
            }
            for _, v in ipairs(list) do

                ui.AddContextMenuItem(context, v.n, "DEVELOPERCONSOLE_CONTEXT_SUB_TAG_EXEC(\"" .. tostring(v.v) .. "\")")
            end
            context:Resize(300, context:GetHeight())
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_CONTEXT_SUB_TAG_EXEC(v)
    EBI_try_catch{
        try = function()
            v = v:gsub("%{", "｛"):gsub("%}", "｝")
            local f = lstr("return " .. v .. "");
            local status, vv = pcall(f);
          
            if status then
                if type(vv) == 'function' then
                    DEVELOPERCONSOLE_CONTEXT_ADDEDIT(vv())
                else
                    DEVELOPERCONSOLE_CONTEXT_ADDEDIT(vv)
                end
            else
                print("ERR"..tostring(vv))
            end
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_CONTECT_ADDLINKPOS()

    local mapName = session.GetMapName()
    local actorPos = world.GetActorPos(session.GetMyHandle());	
    local mapprop = geMapTable.GetMapProp(mapName);
    local pos = mapprop:WorldPosToMinimapPos(actorPos.x, actorPos.z, m_mapWidth, m_mapHeight);	
    local worldPos = mapprop:MinimapPosToWorldPos(pos.x, pos.y, m_mapWidth, m_mapHeight);
    local text = MAKE_LINK_MAP_TEXT(mapName, worldPos.x, worldPos.y);
    return text
end
function DEVELOPERCONSOLE_CONTEXT_ADDEDIT(text)
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame("developerconsole");
            local input = frame:GetChild("input");
            AUTO_CAST(input)
            text = text:gsub("%{", "｛"):gsub("%}", "｝")
            text=dictionary.ReplaceDicIDInCompStr(text)
            input:SetText(input:GetCursurLeftText() .. text .. input:GetCursurRightText())
            input:Invalidate()
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_DOFILE_CHOOSE(frame)
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame("developerconsole");
            INPUT_STRING_BOX_CB(frame, "Input the path of lua script", "DEVELOPERCONSOLE_DOFILE", "", nil, nil, 260, false)
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_DOFILE(frame, argStr)
    EBI_try_catch{
        try = function()
            
            local s = string.gsub(argStr, "\\", "\\\\")
            local text
            if string.find(s, "\"") ~= nil then
                text = "dofile(" .. s .. ");"
            else
                text = "dofile(\"" .. s .. "\");"
            end
            
            local input = frame:GetChild("input");
            input:SetText(text)
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_EXPLORER(frame)
    debug.OpenDataDir("")
end
function DEVELOPERCONSOLE_ESCAPEBRACKET(frame)
    local textview_log = GET_CHILD(frame, "textview_log", "ui::CTextView")
    textview_log:Clear()
    local text = DEVELOPERCONSOLE_LOG or {}
    DEVELOPERCONSOLE_LOG = {}
    for i, k in ipairs(text) do
        local s = k;
        s = string.gsub(s, "{", "<")
        s = string.gsub(s, "}", ">")
        
        DEVELOPERCONSOLE_ADDTEXT(s)
    end
end
function DEVELOPERCONSOLE_SURROUNDBRACKET(frame)
    local input = frame:GetChild("input");
    local curtext = input:GetText()
    if (curtext == nil) then
        curtext = ""
    end
    INPUT_STRING_BOX_CB(frame, "<> will be replaced to {}{nl}(Immediate Execute)", "DEVELOPERCONSOLE_SURROUNDBRACKET_EXEC", curtext, nil, nil, 65536, false)
end
function DEVELOPERCONSOLE_SURROUNDBRACKET_EXEC(frame, argStr)
    
    
    local s = argStr;
    s = string.gsub(s, "<", "{")
    s = string.gsub(s, ">", "}")
    
    DEVELOPERCONSOLE_EXEC(nil, s, argStr)
end
function DEVELOPERCONSOLE_CLOSE()
    local frame = ui.GetFrame("developerconsole");
    if (frame ~= nil) then
        local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
        timer:Stop();
    end
end

function TOGGLE_UI_DEBUG()
    debug.ToggleUIDebug();
end

function CLEAR_CONSOLE()
    local frame = ui.GetFrame("developerconsole");
    
    if frame ~= nil then
        local textlog = frame:GetChild("textview_log");
        
        if textlog ~= nil then
            tolua.cast(textlog, "ui::CTextView");
            textlog:Clear();
            DEVELOPERCONSOLE_LOG = {}
        end
    end
end
function DEVELOPERCONSOLE_ADDTEXT(text)
    if (text) then
        local frame = ui.GetFrame("developerconsole");
        local textlog = frame:GetChild("textview_log");
        tolua.cast(textlog, "ui::CTextView");
        textlog:AddText(text, "white_16_ol");
        DEVELOPERCONSOLE_LOG[#DEVELOPERCONSOLE_LOG + 1] = text
        if(#DEVELOPERCONSOLE_LOG>1000)then
            table.remove(DEVELOPERCONSOLE_LOG,1)
        end
    end
end
function DEVELOPERCONSOLE_PRINT_TEXT(text)
    if text == nil or text == "" then
        return;
    end
    
    local frame = ui.GetFrame("developerconsole");
    local textlog = frame:GetChild("textview_log");
    
    if textlog ~= nil then
        tolua.cast(textlog, "ui::CTextView");
        DEVELOPERCONSOLE_ADDTEXT(text);
    end
end
function DEVELOPERCONSOLE_INTELLISENSE_PICK(nolower, noval)
    local frame = ui.GetFrame("developerconsole")
    local isf = ui.GetFrame("developerconsoleintellisense")
    local input = frame:GetChild("input");
    AUTO_CAST(input)
    local tex = input:GetCursurLeftText()
    if (not nolower) then
        tex = tex:lower()
    
    end
    
    
    local tbl3 = string.match(tex, "([%w_%.%:%s]*[%.%:%(%)%[%]\"%\'])[%w_%s]-$")
    local tbl
    if (noval) then
        local tbl0 = string.match(tex, "([%w_%.%:%s]*)$")
        tbl = tbl0 or tbl3 or "_G"
    else
        tbl =
            DEVELOPERCONSOLE_INTELLISENSE_VALIDATE(tbl3) or
            DEVELOPERCONSOLE_INTELLISENSE_VALIDATE(tbl1) or
            DEVELOPERCONSOLE_INTELLISENSE_VALIDATE(tbl2) or "_G"
    end
    
    return tbl
end
function DEVELOPERCONSOLE_INTELLISENSE_PICK_FN()
    local frame = ui.GetFrame("developerconsole")
    local isf = ui.GetFrame("developerconsoleintellisense")
    local input = frame:GetChild("input");
    AUTO_CAST(input)
    local tex = input:GetCursurLeftText()
    local lv = 1
    local pos = #tex
    while pos >= 1 do
        local c = tex:sub(pos, pos)
        if (c == "(") then
            lv = lv - 1
            if (lv == 0) then
                break
            end
        elseif (c == ")") then
            lv = lv + 1
        end
        pos = pos - 1
    end
    
    local tbl = string.match(tex:sub(1, pos), "([%w_%.%:%[%]%\"%\'%,]*)%([^%(]-$")
    
    return tbl
end
function DEVELOPERCONSOLE_INTELLISENSE_VALIDATE(code)
    if (code == nil) then
        return nil
    end
    code = code:gsub("[%.%(]$", "")
    
    local tbl = nil
    local codeg = string.gsub(code, "\"", "\\\"")
    local f = lstr("return (" .. codeg .. ")");
    local status, error = pcall(f);
    if (type(error) == "function") then
        tbl = code
    elseif (type(error) == "table") then
        tbl = code
    elseif (type(error) == "userdata" or error ~= nil) then
        tbl = code
    end
    
    return tbl
end
function DEVELOPERCONSOLE_INTELLISENSE(choosefirst)
    EBI_try_catch{
        try = function()
            if (not DEVELOPERCONSOLE_SETTINGS.intellisense) then
                return
            end
            local code
            if (code == nil) then
                code = DEVELOPERCONSOLE_INTELLISENSE_PICK(true)
            end
            local frame = ui.GetFrame("developerconsole")
            local isf = ui.GetFrame("developerconsoleintellisense")
            local input = frame:GetChild("input");
            local sig = isf:GetChild("signature")
            AUTO_CAST(input)
            isf:SetGravity(ui.LEFT, ui.BOTTOM)
            isf:ShowWindow(1)
            isf:SetOffset(frame:GetX() + input:GetX() + math.min(#input:GetCursurLeftText() * 8, frame:GetWidth()), frame:GetY() + input:GetY() + input:GetHeight())
            local list = isf:GetChild("triggers");
            AUTO_CAST(list)
            list:ClearItemAll()
            
            --絞り込み
            DEVELOPERCONSOLE_INTELLI = true
            
            --validate
            local tbl = nil
            local codeg = string.gsub(code, "\"", "\\\"")
            local f = lstr("return (" .. codeg .. ")");
            local status, error = pcall(f);
            if (not status or type(error) == "function") then
                tbl = _G
            elseif (type(error) == "table") then
                tbl = error or _G
            elseif (error == nil) then
                tbl = error or _G
            else
                tbl = _G
            end
            
            if (tbl and code ~= "_") then
                
                DEVELOPERCONSOLE_INTELLI_ITERATOR, DEVELOPERCONSOLE_INTELLI_TABLE, DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY = pairs_sorted(tbl)
                
                DEVELOPERCONSOLE_INTELLI_PREFIX = code
                DEVELOPERCONSOLE_INTELLI_STR = string.match(input:GetCursurLeftText():lower(), "[%w_]-$") or ""
                DEVELOPERCONSOLE_INTELLI_COUNT = 0
                DEVELOPERCONSOLE_INTELLI_SELECT = 0
                if(choosefirst==1)then
                    DEVELOPERCONSOLE_INTELLI_CHOOSEFIRST=true
                elseif(choosefirst==0) then
                    DEVELOPERCONSOLE_INTELLI_CHOOSEFIRST=false
                end
           
            end
            
            --signature
            local ins = DEVELOPERCONSOLE_INTELLISENSE_PICK_FN()
            if (ins) then
                local f = lstr("return " .. ins .. "");
                local status, err = pcall(f);
                if (not status or type(err) == "function") then
                    local t = DEVELOPERCONSOLE_GET_FN_SIGNATURE(err)
                    if t and t.spr then
                        sig:SetText("{@st43}{s16}{ol}{#FFFF22}" .. t.name .. "(" .. table.concat(t.spr, ",") .. ")")
                        sig:ShowWindow(1)
                    else
                        sig:SetText("{@st43}{s16}{ol}{#FF2222}" .. "??(...)")
                        sig:ShowWindow(1)
                    end
                else
                    sig:SetText("")
                    sig:ShowWindow(0)
                end
            else
                sig:SetText("")
                sig:ShowWindow(0)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_ON_DETERMINE_INTELLI()
    DEVELOPERCONSOLE_DETERMINE_INTELLI()
end
function DEVELOPERCONSOLE_DETERMINE_INTELLI(continue)
    EBI_try_catch{
        try = function()
            
            local frame = ui.GetFrame("developerconsole")
            local isf = ui.GetFrame("developerconsoleintellisense")
            local input = frame:GetChild("input");
            local s = string.match(input:GetCursurLeftText(), "(.-)[%w_]*$") or input:GetCursurLeftText()
            local list = isf:GetChild("triggers");
            
            
            AUTO_CAST(list)
            local sel = ""
            if (list:GetSelItemIndex() >= 0) then
                sel = list:GetSelItemText():match("^(.*)  ")
            else
                
                return
            end
            
            if (continue) then
                
                
                if (1 == keyboard.IsKeyPressed("PERIOD")) then
                    input:SetText(s .. sel .. input:GetCursurRightText())
                    ReserveScript("DEVELOPERCONSOLE_INTELLISENSE()", 0.02)
                else
                    local r = input:GetCursurRightText()
                    input:SetText(s .. sel .. r)
                    input:Invalidate()
                    local code = DEVELOPERCONSOLE_INTELLISENSE_PICK(true, true)
                    
                    local codeg = string.gsub(code, "\"", "\\\"")
                    local f = lstr("return (" .. codeg .. ")");
                    local status, error = pcall(f);
                    local tbl
                    if (not status) then
                        tbl = nil
                    else
                        tbl = error
                    end
                    
                    if (type(tbl) == "table") then
                        input:SetText(s .. sel .. "." .. r)
                        ReserveScript("DEVELOPERCONSOLE_INTELLISENSE(1)", 0.02)
                    elseif (type(tbl) == "function") then
                        input:SetText(s .. sel .. "(" .. r)
                        ReserveScript("DEVELOPERCONSOLE_INTELLISENSE(1)", 0.02)
                    else
                        input:SetText(s .. sel .. r)
                        ReserveScript('DEVELOPERCONSOLE_INTELLI_CLOSE()', 0.01)
                   
                    end
                end
            else
                
                input:SetText(s .. sel .. input:GetCursurRightText())
                ReserveScript('DEVELOPERCONSOLE_INTELLI_CLOSE()', 0.01)
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DEVELOPERCONSOLE_INTELLI_CLOSE()
    DEVELOPERCONSOLE_INTELLI_CHOOSEFIRST=false
    ui.CloseFrame("developerconsoleintellisense")
end
function DEVELOPERCONSOLE_GET_FN_SIGNATURE(func)
    return EBI_try_catch{
        try = function()
            local info = debug.getinfo(func)
            
            local src = info.source:split("\n")
            local name, sfn = src[info.linedefined]:match("function (.*)%((.-)%)")
            return {name = name, spr = sfn:split(",")}
        end,
        catch = function(error)
            return nil
        
        end
    }
end
function DEVELOPERCONSOLE_UPDATE(frame)
    EBI_try_catch{
        try = function()
            
            local doupdate = nil
            if ui.IsFrameVisible("developerconsoleintellisense") == 0 then
                if (DEVELOPERCONSOLE_KEYDOWNFLAG == false) then
                    if 1 == keyboard.IsKeyPressed("UP") then
                        --previous
                        if (DEVELOPERCONSOLE_CURSOR < (#DEVELOPERCONSOLE_SETTINGS.history - 1)) then
                            DEVELOPERCONSOLE_CURSOR = DEVELOPERCONSOLE_CURSOR + 1
                        end
                        
                        doupdate = DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history - DEVELOPERCONSOLE_CURSOR]
                        
                        DEVELOPERCONSOLE_KEYDOWNFLAG = true
                    elseif 1 == keyboard.IsKeyPressed("DOWN") then
                        
                        --new
                        if (DEVELOPERCONSOLE_CURSOR > 0) then
                            DEVELOPERCONSOLE_CURSOR = DEVELOPERCONSOLE_CURSOR - 1
                        elseif DEVELOPERCONSOLE_CURSOR < 0 then
                            DEVELOPERCONSOLE_CURSOR = 0
                        end
                        
                        doupdate = DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history - DEVELOPERCONSOLE_CURSOR]
                        DEVELOPERCONSOLE_KEYDOWNFLAG = true
                    end
                    if (doupdate ~= nil) then
                        
                        local textlog = frame:GetChild("textview_log");
                        local editbox = frame:GetChild("input");
                        tolua.cast(editbox, "ui::CEditControl");
                        editbox:SetText(doupdate)
                    
                    end
                else
                    if 1 == keyboard.IsKeyPressed("UP") then
                        
                        elseif 1 == keyboard.IsKeyPressed("DOWN") then
                        
                        else
                            DEVELOPERCONSOLE_KEYDOWNFLAG = false
                    end
                end
                
                
                if 1 == keyboard.IsKeyDown("LBRACKET") and (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    local editbox = frame:GetChild("input");
                    tolua.cast(editbox, "ui::CEditControl");
                    editbox:SetText(editbox:GetText() .. "｛")
                end
                if 1 == keyboard.IsKeyDown("RBRACKET") and (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    local editbox = frame:GetChild("input");
                    tolua.cast(editbox, "ui::CEditControl");
                    editbox:SetText(editbox:GetText() .. "｝")
                end
                if 1 == keyboard.IsKeyDown("ENTER") and (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    -- local editbox = frame:GetChild("input");
                    -- editbox:SetText(editbox:GetText() .. "{nl}")
                    -- editbox:Invalidate()
                    DEVELOPERCONSOLE_ENTER_KEY(frame)
                end
                if 1 == keyboard.IsKeyDown("SPACE") and (keyboard.IsKeyPressed("LCTRL") == 1 or keyboard.IsKeyPressed("RCTRL") == 1) then
                    local editbox = frame:GetChild("input");
                    tolua.cast(editbox, "ui::CEditControl");
                    --最後のスペースを消す
                    local tex = editbox:GetCursurLeftText()
                    if (tex:match(" $")) then
                        editbox:SetText(editbox:GetCursurLeftText():sub(1, -2) .. editbox:GetCursurRightText())
                    end
                    DEVELOPERCONSOLE_INTELLISENSE(true)
                end
            end
            if ui.IsFrameVisible("developerconsoleintellisense") == 1 then
                local editbox = frame:GetChild("input");
                tolua.cast(editbox, "ui::CEditControl");
                if (editbox:IsHaveFocus() == 0) then
                    DEVELOPERCONSOLE_INTELLI_CLOSE()
                end
                local isf = ui.GetFrame("developerconsoleintellisense")
                local list = isf:GetChild("triggers");
                AUTO_CAST(list)
                if 1 == keyboard.IsKeyPressed("LEFT") or 1 == keyboard.IsKeyPressed("RIGHT") then
                    DEVELOPERCONSOLE_ON_TYPE()
                end
                local cur = list:GetSelItemIndex()
                if 1 == keyboard.IsKeyDown("UP") then
                    
                    list:DeSelectItemAll()
                    list:SelectItem(math.max(0, cur - 1))
                    list:Invalidate()
                
                elseif 1 == keyboard.IsKeyDown("DOWN") then
                    
                    
                    list:DeSelectItemAll()
                    list:SelectItem(math.min(DEVELOPERCONSOLE_INTELLI_COUNT - 1, cur + 1))
                    list:Invalidate()
                
                elseif 1 == keyboard.IsKeyDown("NEXT") then
                    
                    list:DeSelectItemAll()
                    list:SelectItem(math.min(DEVELOPERCONSOLE_INTELLI_COUNT - 1, cur + 7))
                    list:Invalidate()
                
                elseif 1 == keyboard.IsKeyDown("PRIOR") then
                    
                    list:DeSelectItemAll()
                    list:SelectItem(math.max(0, cur - 7))
                    list:Invalidate()
                
                end
                if 1 == keyboard.IsKeyDown("ENTER") then
                    DEVELOPERCONSOLE_DETERMINE_INTELLI()
                end
                if 1 == keyboard.IsKeyDown("TAB")  then
                    if(list:GetSelItemIndex()<0)then
                        list:DeSelectItemAll()
                        list:SelectItem(0)
                    end
                    DEVELOPERCONSOLE_DETERMINE_INTELLI(1)
                
                end
                if  1 == keyboard.IsKeyDown("PERIOD") then
                    DEVELOPERCONSOLE_DETERMINE_INTELLI(1)
                
                end
                if 1 == keyboard.IsKeyDown("ESCAPE") then
                    DEVELOPERCONSOLE_INTELLI_CLOSE()
                end
                
                AUTO_CAST(list)
                if DEVELOPERCONSOLE_INTELLI and DEVELOPERCONSOLE_INTELLI_ITERATOR then
                    --イテレータを回す
                    local limit = 5000
                    
                    for i = 0, limit do
                        local k, v = DEVELOPERCONSOLE_INTELLI_ITERATOR(DEVELOPERCONSOLE_INTELLI_TABLE, DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY)
                        DEVELOPERCONSOLE_INTELLI_ITERATOR_KEY = k
                        
                        
                        if (k == nil) then
                            DEVELOPERCONSOLE_INTELLI = false
                            DEVELOPERCONSOLE_INTELLI_ITERATOR = nil
                            
                            break
                        end
                        if (DEVELOPERCONSOLE_INTELLI_STR == "" or v.k:lower():starts(DEVELOPERCONSOLE_INTELLI_STR)) then
                            
                            local f = lstr("return (" .. tostring(DEVELOPERCONSOLE_INTELLI_PREFIX or "") .. "." .. tostring(v.k) .. ")");
                            local status, error = pcall(f);
                            local tbl = error
                            if (tbl ~= nil) then
                                list:AddItem(tostring(v.k) .. "  {s15}{ol}{#999999}" .. type(tbl), DEVELOPERCONSOLE_INTELLI_COUNT)
                            else
                                list:AddItem(tostring(v.k) .. "  {s15}{ol}{#FF9999} ??", DEVELOPERCONSOLE_INTELLI_COUNT)
                            end
                            DEVELOPERCONSOLE_INTELLI_COUNT = DEVELOPERCONSOLE_INTELLI_COUNT + 1
                            if (list:GetSelItemIndex() < 0 and DEVELOPERCONSOLE_INTELLI_CHOOSEFIRST) then
                                list:SelectItem(0)
                            end
                            if (DEVELOPERCONSOLE_INTELLI_COUNT > 100) then
                                DEVELOPERCONSOLE_INTELLI = false
                                DEVELOPERCONSOLE_INTELLI_ITERATOR = nil
                                break
                            
                            end
                        
                        end
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function DEVELOPERCONSOLE_ENTER_KEY(frame, control, argStr, argNum)
    if ui.IsFrameVisible("developerconsoleintellisense") == 1 then
        DEVELOPERCONSOLE_DETERMINE_INTELLI()
        
        DEVELOPERCONSOLE_INTELLI_CLOSE()
    else
        
        local textlog = frame:GetChild("textview_log");
        
        if textlog ~= nil then
            tolua.cast(textlog, "ui::CTextView");
            
            local editbox = frame:GetChild("input");
            
            if editbox ~= nil then
                tolua.cast(editbox, "ui::CEditControl");
                local commandText = editbox:GetText();
                
                DEVELOPERCONSOLE_EXEC(frame, commandText)
            end
        end
    end
end

function DEVELOPERCONSOLE_EXEC(frame, commandText, originalstr)
    if (frame == nil) then
        frame = ui.GetFrame("developerconsole")
    end
    
    local textlog = frame:GetChild("textview_log");
    
    if textlog ~= nil then
        tolua.cast(textlog, "ui::CTextView");
        
        local editbox = frame:GetChild("input");
        
        if editbox ~= nil then
            tolua.cast(editbox, "ui::CEditControl");
            
            if commandText ~= nil and commandText ~= "" then
                if (keyboard.IsKeyPressed("LALT") == 1 or keyboard.IsKeyPressed("RALT") == 1) then
                    commandText = commandText:gsub("｛", "{"):gsub("｝", "}")
                end
                DEVELOPERCONSOLE_IGNORE_FLAG = false
                local s = "[Execute] " .. commandText;
                DEVELOPERCONSOLE_ADDTEXT(s);
                local f = assert(lstr(commandText));
                local status, error = pcall(f);
                
                if not status then
                    DEVELOPERCONSOLE_ADDTEXT(tostring(error));
                end
                if (DEVELOPERCONSOLE_IGNORE_FLAG == false) then
                    if (#DEVELOPERCONSOLE_SETTINGS.history == 0 or DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history] ~= (originalstr or commandText)) then
                        DEVELOPERCONSOLE_SETTINGS.history[#DEVELOPERCONSOLE_SETTINGS.history + 1] = originalstr or commandText
                    end
                    editbox:SetText("");
                end
                
                DEVELOPERCONSOLE_CURSOR = -1
                DEVELOPERCONSOLE_SAVE_SETTINGS()
            end
        end
    end

end
function DEVELOPERCONSOLE_TOGGLEENABLE_INTELLISENSE()
    DEVELOPERCONSOLE_SETTINGS.intellisense = not DEVELOPERCONSOLE_SETTINGS.intellisense
    DEVELOPERCONSOLE_SAVE_SETTINGS()
end
