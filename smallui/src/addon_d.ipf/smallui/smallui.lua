--アドオン名（大文字）
local addonName = "smallui"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "smallui"
g.debug = false
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.x = nil
g.y = nil
g.buffs = {}
--ライブラリ読み込み
CHAT_SYSTEM("[SU]loaded")
local acutil = require('acutil')
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

function SMALLUI_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('GAME_START_3SEC', 'SMALLUI_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'SMALLUI_EVERY');
            local addontimer = frame:GetChild("addontimer")
            AUTO_CAST(addontimer)
            addontimer:SetUpdateScript("SMALLUI_ON_TIMER")
            addontimer:Start(0.01)
            addontimer:EnableHideUpdate(1)
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0,0)
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function SMALLUI_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function  SMALLUI_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    SMALLUICONFIG_GENERATEDEFAULT(g.settings)
    SMALLUI_UPGRADE_SETTINGS()
    SMALLUI_SAVE_SETTINGS()

end


function  SMALLUI_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

function SMALLUI_3SEC()
    EBI_try_catch{
        try = function()
            
            --SMALLUI_REPLACE("quickslotnexpbar")
            SMALLUI_LOAD_SETTINGS()
            SMALLUICONFIG_INIT()
            if(g.settings.resizeminimap)then
                SMALLUI_SMALLIFY_MINIMAP()
            end
            if(g.settings.repositionbuttons)then
                SMALLUI_SMALLIFY_MINIMIZED_BUTTON()
            end
            if(g.settings.resizequickslot)then
                SMALLUI_SMALLIFY_QUICKSLOT()
            end
            if(g.settings.resizechat)then
                SMALLUI_SMALLIFY_CHATFRAME()
            end

        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function SMALLUI_SMALLIFY_QUICKSLOT()
    local frame = ui.GetFrame("quickslotnexpbar")
    local sz = g.settings.quickslotsize
    local slsz = g.settings.quickslotsize
    local line = 280
    local x
    x = -100
    for i = 1, 10 do
        local slot = frame:GetChild("slot" .. tostring(i))
        slot:SetMargin(x, line, 0, 0)
        slot:Resize(slsz, slsz)
        x = x + sz
    end
    line = line - sz
    x = -100 - g.settings.quickslotsize / 2
    for i = 11, 20 do
        local slot = frame:GetChild("slot" .. tostring(i))
        slot:SetMargin(x, line, 0, 0)
        slot:Resize(slsz, slsz)
        x = x + sz
    end
    line = line - sz
    x = -100 - g.settings.quickslotsize
    for i = 21, 30 do
        local slot = frame:GetChild("slot" .. tostring(i))
        slot:SetMargin(x, line, 0, 0)
        slot:Resize(slsz, slsz)
        x = x + sz
    end
    line = line - sz
    x = -100 - g.settings.quickslotsize / 2
    for i = 31, 40 do
        local slot = frame:GetChild("slot" .. tostring(i))
        slot:SetMargin(x, line, 0, 0)
        slot:Resize(slsz, slsz)
        x = x + sz
    end
    for i = 1, 40 do
        local slot = frame:GetChild("slot" .. tostring(i))
        AUTO_CAST(slot)

        slot:SetFontName("white_10_ol")
        slot:SetSubBoxFont("white_10_ol")
        
        slot:Invalidate()
        SMALLUI_QUICKSLOT_MOVE_GAUGE(slot)
    end
    QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT()

end
function SMALLUI_QUICKSLOT_MOVE_GAUGE(slot)
    EBI_try_catch{
        try = function()
            local x = 2;
            local y = slot:GetHeight() - 11;
            local width = 32;
            local height = 10;
            local gauge = slot:GetSlotGauge();
            if (gauge) then
                gauge:SetOffset(0, slot:GetHeight() - 11)
                gauge:Resize(width, height)
                --gauge:SetDrawStyle(ui.GAUGE_DRAW_CELL);
                gauge:SetSkinName("smallui_dot_skillslot");
                --slot:InvalidateGauge();
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SMALLUI_QUICKSLOT_MAKE_GAUGE(slot)
    EBI_try_catch{
        try = function()
            QUICKSLOT_MAKE_GAUGE_OLD(slot)
            SMALLUI_QUICKSLOT_MOVE_GAUGE(slot)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SMALLUI_SMALLIFY_MINIMAP()
    local frame = ui.GetFrame("minimap")
    local minimap = ui.GetFrame("minimap")
    local diffx=200-310
    local diffy=200-230

    frame:Resize(200, 200)
    frame:SetMargin(0, 70, 35, 0)
    local gbox = frame:GetChild("mbg")
    gbox:Resize(200, 200)
    local map = frame:GetChild("map")
    map:SetOffset(0, 0)
    local map = frame:GetChild("map_bg")
    map:SetOffset(0,0)
    
    frame = ui.GetFrame("mapareatext")
    frame:Resize(200, 20)
    frame:GetChild("mapName"):Resize(200, 24)
    frame:GetChild("areaName"):SetMargin(0, 10, 0, 0)
    frame:GetChild("areaName"):Resize(200, 24)
    frame:SetFontName("wh_12_ol")
    local frame = ui.GetFrame("channel")
    frame:Resize(200, 30)
    frame:SetMargin(0, 40, 35, 0)
    frame:GetChild("curchannel"):Resize(80, 24)
    frame:GetChild("curchannel"):SetTextAlign("left", "center")
    frame = ui.GetFrame("minimapname")
    frame:ShowWindow(0)
    frame:SetMargin(0, 250, -0, 0)
    frame:Resize(200, 120)
    frame:GetChild("title"):Resize(200, 20)
    frame = ui.GetFrame("minimap_outsidebutton")
    frame:Resize(200, 60)
    frame:SetMargin(0, 230, 40, 0)
    frame:GetChild("BGM_PLAYER"):Resize(20, 20)
    frame:GetChild("BGM_PLAYER"):SetMargin(65, 0, 0, 5)
    frame:GetChild("ZOOM_IN"):Resize(20, 20)
    frame:GetChild("ZOOM_IN"):SetMargin(90, 0, 0, 5)
    frame:GetChild("ZOOM_OUT"):Resize(20, 20)
    frame:GetChild("ZOOM_OUT"):SetMargin(115, 0, 0, 5)
    frame:GetChild("open_map"):Resize(20, 20)
    frame:GetChild("open_map"):SetMargin(140, 0, 0, 5)
    frame:GetChild("ZOOM_INFO"):ShowWindow(0)

    if(obde)then
        DBGOUT("OBDE Supported")
        obde.CalculateMinimapAxis  = function(self, parent, actor)
            local cursize = GET_MINIMAPSIZE();
            local pictureui = GET_CHILD(parent, "map", "ui::CPicture");
            local mmw = pictureui:GetImageWidth() * (100 + cursize) / 100;
            local mmh = pictureui:GetImageHeight() * (100 + cursize) / 100;
        
            local mypos = info.GetPositionInMap(session.GetMyHandle(), mmw, mmh);
        
            local pos = actor:GetPos();
            local mapprop = session.GetCurrentMapProp();
            local mmpos = mapprop:WorldPosToMinimapPos(pos, mmw, mmh);
            if(g.settings.resizeminimap)then
                return {
                x = mmpos.x - (mypos.x - mini_frame_hw)+diffx/2,
                y = mmpos.y - (mypos.y - mini_frame_hh)+diffy/2
                };
            else
                return {
                    x = mmpos.x - (mypos.x - mini_frame_hw),
                    y = mmpos.y - (mypos.y - mini_frame_hh)
                    };
            end
          end
    end

end
function SMALLUI_SMALLIFY_MINIMIZED_BUTTON()
    local frame
    frame = ui.GetFrame("openingameshopbtn")
    frame:SetMargin(0, 160, 0, 0)
    SMALLUI_DO_SMALL_BUTTON(frame)
    frame = ui.GetFrame("minimizedalarm")
    frame:SetMargin(0, 190, 0, 0)
    SMALLUI_DO_SMALL_BANNER(frame)
    frame = ui.GetFrame("minimized_tp_button")
    frame:SetMargin(0, 220, 0, 0)
    SMALLUI_DO_SMALL_BUTTON(frame)
    
    frame = ui.GetFrame("minimized_guild_housing")
    frame:SetMargin(0, 220, 0, 0)
    SMALLUI_DO_SMALL_BUTTON(frame)
    frame = ui.GetFrame("minimizedeventbanner")
    frame:SetMargin(0, 250,0 , 0)
    SMALLUI_DO_SMALL_BANNER(frame)
    frame = ui.GetFrame("minimized_godprotection_button")
    frame:SetMargin(0, 270,0, 0)
    --SMALLUI_DO_SMALL_BUTTON(frame)

end
function SMALLUI_DO_SMALL_BUTTON(frame)
    for i = 0, frame:GetChildCount() - 1 do
        local g = frame:GetChildByIndex(i)
        if (g:GetClassString() == "ui::CButton") then
            AUTO_CAST(g)
            g:EnableImageStretch(true)
        elseif (g:GetClassString() == "ui::CPicture") then
            AUTO_CAST(g)
            g:SetEnableStretch(1)
        end
        g:SetGravity(ui.RIGHT,ui.TOP)
        if (g:GetUserValue("su_resized") == nil or g:GetUserValue("su_resized") == "None") then
            local margin = g:GetMargin()
            g:Resize(g:GetWidth() / 2, g:GetHeight() / 2)
            g:SetUserValue("su_resized", "true")
        --print("resized")
        else
            --print("already resized "..g:GetUserValue("su_resized"))
            end
    end
    frame:Resize(30,30)
end
function SMALLUI_DO_SMALL_BANNER(frame)
    local gbox = frame:GetChild("gbox")
    gbox:Resize(30,30)
    AUTO_CAST(gbox)
    gbox:EnableHittestGroupBox(true)
    local g = gbox:GetChild("pic")
    g:SetOffset(0,0)
    if (g:GetClassString() == "ui::CButton") then
        AUTO_CAST(g)
        g:EnableImageStretch(true)
    elseif (g:GetClassString() == "ui::CPicture") then
        AUTO_CAST(g)
        g:SetEnableStretch(1)
    end
    g:SetGravity(ui.RIGHT,ui.TOP)
    g:EnableHitTest(1)
    if (g:GetUserValue("su_resized") == nil or g:GetUserValue("su_resized") == "None") then
        local margin = g:GetMargin()
        g:Resize(g:GetWidth() / 2, g:GetHeight() / 2)
        g:SetUserValue("su_resized", "true")
    --print("resized")
    else
        --print("already resized "..g:GetUserValue("su_resized"))
    end
    frame:Resize(30,30)
end
function SMALLUI_ON_TIMER()
    if(g.settings.resizequestlist)then
        local frame = ui.GetFrame("questinfoset_2")
        frame:Resize(300, 550)
        frame:SetMargin(0, 400, 0, 0)
        
        frame:GetChild("member"):Resize(300, 450)
        frame:GetChild("member"):SetMargin(100, 100, 0, 0)
        --frame:GetChild("QUEST_SHARE"):Resize(200,frame:GetChild("QUEST_SHARE"):GetHeight())
        for i = 0, frame:GetChildCount() - 1 do
            local g = frame:GetChildByIndex(i)
            if (g:GetWidth() > 200) then
                g:Resize(300, g:GetHeight())
            end
            local m = g:GetMargin()
            if (m.right > 300) then
                g:SetMargin(m.left, m.top, 300, m.bottom)
            end
        end
        local frame = ui.GetFrame("minimap")
        local mini_pos = frame:GetChild("my")
        AUTO_CAST(mini_pos)
        mini_pos:SetOffset(frame:GetWidth() / 2 - mini_pos:GetImageWidth() / 2, frame:GetHeight() / 2 - mini_pos:GetImageHeight() / 2);
    end
end
function SMALLUI_EVERY()
    ui.GetFrame(g.framename):ShowWindow(1)
    if(g.settings.resizechat)then

        SMALLUI_SMALLIFY_CHATFRAME()
    end
end
function SMALLUI_SMALLIFY_CHATFRAME()
    local frame = ui.GetFrame("chatframe")
    local gbox = frame:GetChild("tabgbox")
    AUTO_CAST(gbox)
    gbox:SetGravity(ui.LEFT, ui.BOTTOM)
    for i = 0, frame:GetChildCount() - 1 do
        local obj = frame:GetChildByIndex(i)
        if (obj:GetName():match("^chatgbox_")) then
            local gbox = obj
            
            AUTO_CAST(gbox)
            local gboxleftmargin = frame:GetUserConfig("GBOX_LEFT_MARGIN")
            local gboxrightmargin = frame:GetUserConfig("GBOX_RIGHT_MARGIN")
            local gboxtopmargin = frame:GetUserConfig("GBOX_TOP_MARGIN")
            local gboxbottommargin = frame:GetUserConfig("GBOX_BOTTOM_MARGIN")
            gbox:SetOffset(0, gboxtopmargin - 10)
            gbox:Resize(frame:GetWidth(), frame:GetHeight() - 60)
            gbox:InvalidateScrollBar()
        
        end
    end
end
