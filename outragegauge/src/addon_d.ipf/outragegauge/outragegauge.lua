local addonName = 'OUTRAGEGAUGE'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g= _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.settings =
    g.settings or
    {
        x = 300,
        y = 300,
        style = 0,
        locked=true
    }
g.configurepattern = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'outragegauge'
g.debug = false

g.buffs = {}
g.chganim = 0
g.speed = 0.25
g.tick=0
local libaodrawpic=LIBAODRAWPICV1_1
--ライブラリ読み込み
CHAT_SYSTEM('[OG]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
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

local function DrawPseudoArc(pic, cx, cy, radius, arcbegin, arcend, brush, color)
    local detail = 5*math.pi/180
    local arc = arcbegin
    while arc <= arcend do
        pic:DrawBrush(math.cos(arc) * radius + cx, -math.sin(arc) * radius + cy, math.cos(arc + detail) * radius + cx, -math.sin(arc + detail) * radius + cy, brush, color)
        arc = arc + detail
    end
end
local clsid_oh = 1109
local clsid_release = 2197

local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
                fd:flush()
                fd:close()
            end
        end,
        catch = function(error)
        end
    }
end

local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function OUTRAGEGAUGE_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            addon:RegisterMsg('BUFF_ADD', 'OUTRAGEGAUGE_BUFF_UPDATE')
            addon:RegisterMsg('RELOAD_BUFF_ADD', 'OUTRAGEGAUGE_BUFF_UPDATE')
            addon:RegisterMsg('BUFF_REMOVE', 'OUTRAGEGAUGE_BUFF_UPDATE')
            addon:RegisterMsg('BUFF_UPDATE', 'OUTRAGEGAUGE_BUFF_UPDATE')
            addon:RegisterMsg('FPS_UPDATE', 'OUTRAGEGAUGE_FPS_UPDATE')
            addon:RegisterMsg('GAME_START_3SEC', 'OUTRAGEGAUGE_TIMER_BEGIN')
            acutil.slashCommand("/og", OUTRAGEGAUGE_PROCESS_COMMAND);
            acutil.slashCommand("/outragegauge", OUTRAGEGAUGE_PROCESS_COMMAND);
            
            if not g.loaded then
                g.loaded = true
            end
            OUTRAGEGAUGE_LOAD_SETTINGS()
            DBGOUT('INIT')
            --CHALLENGEMODESTUFF_INIT()
            OUTRAGEGAUGE_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function OUTRAGEGAUGE_FPS_UPDATE()
    g.frame:ShowWindow(1)
end
function OUTRAGEGAUGE_BUFF_UPDATE(frame, msg, argStr, argNum)
    EBI_try_catch {
        try = function()
            local handle = session.GetMyHandle()

            if (msg == 'BUFF_ADD'  or msg == "RELOAD_BUFF_ADD" ) then
                if (argNum == clsid_oh) then
                    local buff = info.GetBuff(handle, argNum)
                    g.buffs[argNum] = {
                        buff = buff,
                        over = buff.over,
                        maxtime = buff.time
                    }
                    DBGOUT('BUFF')
                elseif (argNum == clsid_release) then
                    local buff = info.GetBuff(handle, argNum)
                    g.buffs[argNum] = {
                        buff = buff,
                        over = buff.over,
                        maxtime = buff.time
                    }
                    DBGOUT('BUFF')
                end
            elseif (msg == 'BUFF_UPDATE' or (msg == 'BUFF_UPDATE')) then
                if (argNum == clsid_oh) then
                    g.chganim = 1
                elseif (argNum == clsid_release) then
                    g.chganim = 1
                end
                DBGOUT('BUFF')
            elseif (msg == 'BUFF_REMOVE') then
                g.buffs[argNum] = nil
                DBGOUT('REMOVE')
            end
            OUTRAGEGAUGE_RENDER()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OUTRAGEGAUGE_INIT()
    EBI_try_catch {
        try = function()
            
            local frame = ui.GetFrame(g.framename)
            frame:RemoveAllChild()
            frame:Resize(300, 50)
            frame:SetLayerLevel(g.settings.layerlevel or 60)
            frame:SetEventScript(ui.LBUTTONUP, "OUTRAGEGAUGE_END_DRAG")
            frame:SetEventScript(ui.RBUTTONUP, "OUTRAGEGAUGE_SHOW_CONTEXTMENU")
            
            local pic = frame:CreateOrGetControl('groupbox', 'pic', 0, 0, frame:GetWidth(), frame:GetHeight())
            local over = frame:CreateOrGetControl('richtext', 'over', 0, 0, frame:GetWidth(), 30)
            over:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            over:SetMargin(0,0,0,10)
            AUTO_CAST(pic)
            AUTO_CAST(over)
            pic:EnableScrollBar(0)
            pic:EnableHitTest(0)
            over:EnableHitTest(0)
            --pic:CreateInstTexture()
            --pic:FillClonePicture('00000000')

            if g.settings.style==0 then
                FRAME_AUTO_POS_TO_OBJ(frame, session.GetMyHandle(), -150, 50, 1, 1, 1)
            else
                frame:StopUpdateScript()
                frame:SetOffset(g.settings.x,g.settings.y)
            end
            if g.settings.locked then
                frame:SetSkinName('None')
                frame:EnableHitTest(0)
                frame:EnableHittestFrame(0)
                frame:EnableMove(0)
            else
                frame:SetSkinName('bg2')
                frame:EnableHitTest(1)
                frame:EnableHittestFrame(1)
                frame:EnableMove(1)
            end
            
            OUTRAGEGAUGE_RENDER()
            OUTRAGEGAUGE_TIMER_BEGIN()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OUTRAGEGAUGE_END_DRAG()
    local frame = ui.GetFrame(g.framename)
    g.settings.x=frame:GetX()
    g.settings.y=frame:GetY()
    g.settings.style=1
    OUTRAGEGAUGE_SAVE_SETTINGS()
    OUTRAGEGAUGE_INIT()
end

function OUTRAGEGAUGE_TIMER_BEGIN()
    libaodrawpic=LIBAODRAWPICV1_1
    local frame = ui.GetFrame(g.framename)
    frame:CreateOrGetControl('timer', 'addontimer', 0, 0, 10, 10)
    local timer = GET_CHILD(frame, 'addontimer', 'ui::CAddOnTimer')
    timer:SetUpdateScript('OUTRAGEGAUGE_ON_TIMER')
    timer:Start(0.01)
end
function OUTRAGEGAUGE_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function OUTRAGEGAUGE_SHOW_CONTEXTMENU()
    local context = ui.CreateContextMenu('OUTRAGEGAUGE', 'OutrageGauge Config', 0, 0, 200, 200)
    ui.AddContextMenuItem(context, 'Cancel', 'None')
    ui.AddContextMenuItem(context, 'Lock Frame', 'OUTRAGEGAUGE_LOCKPOSITION(true)')
    ui.AddContextMenuItem(context, 'Mode:Floating', 'OUTRAGEGAUGE_SETSTYLE(0)')
    ui.AddContextMenuItem(context, 'Mode:Fixed', 'OUTRAGEGAUGE_SETSTYLE(1)')
    ui.OpenContextMenu(context)
end
function OUTRAGEGAUGE_LOCKPOSITION(lock)
    g.settings.locked=lock
    OUTRAGEGAUGE_SAVE_SETTINGS()
    OUTRAGEGAUGE_INIT()
end
function OUTRAGEGAUGE_SETSTYLE(style)
    g.settings.style=style
    OUTRAGEGAUGE_SAVE_SETTINGS()
    OUTRAGEGAUGE_INIT()
end
function OUTRAGEGAUGE_DEFAULT_SETTINGS()
    g.settings = {
        x = 300,
        y = 300,
        style = 0,
        locked=true,
    }
    
end
function OUTRAGEGAUGE_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        OUTRAGEGAUGE_DEFAULT_SETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    OUTRAGEGAUGE_UPGRADE_SETTINGS()
    OUTRAGEGAUGE_SAVE_SETTINGS()

end


function OUTRAGEGAUGE_UPGRADE_SETTINGS()
    local upgraded = false
    
    return upgraded
end
function OUTRAGEGAUGE_ON_TIMER()

    OUTRAGEGAUGE_RENDER()
end
function OUTRAGEGAUGE_RENDER()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = frame:GetChild('pic')
            local over = frame:GetChild('over')
            AUTO_CAST(pic)
            over:SetText('')
            g.tick=(g.tick+1) % 100
            if (pic and libaodrawpic) then
                DBGOUT('here2')
                local handle = session.GetMyHandle()
                pic=libaodrawpic.inject(pic)
                pic:RemoveAllChild()
                --pic:FillClonePicture('00000000')
                local brush = 'brush_4'
                local brushshade = 'brush_2'

                if g.buffs[clsid_oh] then
                    DBGOUT('here')
                    local buff = info.GetBuff(handle, clsid_oh)
                    local ammo = buff.over
                    local maxtime =  g.buffs[clsid_oh].maxtime
                    local time = buff.time

                    local least = 4
                    local maxammo = 40
                    local color = 'CCFFFF00'
                    local colorshade = 'CC777700'
                   
                    local wh=40
                    local h = 30
                    
                    
                    local oy = wh -h
                    local int = 5
                    local ox = (300-maxammo*int)/2
                    local w = maxammo*int
                    for i = 0, maxammo - 1 do
                        if i >= ammo then
                            color = 'AA333333'
                            colorshade = 'AA222222'
                        else
                            color = 'DDFFFF00'
                            colorshade = 'DD777700'
                           
                            if ammo < least then
                                color = 'AA0000AA'
                                colorshade = 'AA000099'
                            elseif ammo >= maxammo then
                                
                                color = 'AAFF2222'
                                colorshade = 'AAAA2222'
                            
                            end
                        end
                        
                        pic:DrawBrushVert(ox + i * int, oy+math.min(20,20-(i-least)/(maxammo-least)*20), ox + i * int, oy + h, brush, color)
                        pic:DrawBrushVert(ox + i * int+2, oy+math.min(20,20-(i-least)/(maxammo-least)*20)+2, ox + i * int+2, oy + h+2, brushshade, colorshade)
                        
                        
                    end
                
                    over:SetText('{s24}{ol}' .. tostring(ammo))
                    pic:DrawBrushHorz(ox + w/2- (w/2 * time) / maxtime, oy + h-3+10, ox + w/2+ (w/2*time) / maxtime, oy + h-3+10, brush, 'CC2222FF')
                    pic:DrawBrushHorz(ox + w/2- (w/2 * time) / maxtime, oy + h+10, ox + w/2+ (w/2*time) / maxtime, oy + h+10, brush, 'CC2222FF')
                elseif g.buffs[clsid_release] then
                    -- circular mode
                     local buff = info.GetBuff(handle, clsid_release)
                     local ammo = buff.over
                     local max = g.buffs[clsid_release].over
                     local cur = ammo
                     local int = 10
                     local sz = (250) / max
                    -- if sz<= (10 * math.pi/180) then
                    --     int = 2
                    --     sz = (360 - (max ) * int) * math.pi / 180 /  (max) 
                    -- end
                    -- local curpos = math.pi/2
                    local color = 'CCFF7700'
                    for i = 0, cur - 1 do
                       
                    --     if i== cur-1 then
                    --         local t=math.abs(g.tick-50)/50
                    --         DrawPseudoArc(pic, 150, 150, 140, curpos, curpos + sz, brush,
                    --         string.format("CC%02X%02X%02X",
                    --         math.floor(0xFF/2*t)+0xFF/2, 
                    --         math.floor(0x77/2*t)+0x77/2,
                    --         math.floor(0x00/2*t)+0x00/2
                    --     ))
                    --     else
                    --         DrawPseudoArc(pic, 150, 150, 140, curpos, curpos + sz, brush, color)
                    --     end
                                      
                    --     curpos = curpos + sz+int * math.pi / 180
                        local ccol=color
                        if i==cur-1 then
                            local t=math.abs(g.tick-50)/50
                            ccol=string.format("CC%02X%02X%02X",
                             math.floor(0xFF/2*t)+0xFF/2, 
                             math.floor(0x77/2*t)+0x77/2,
                             math.floor(0x00/2*t)+0x00/2)
                        end
                        pic:DrawBrushHorz(i*sz+25,20,i*sz+sz-int+25,20,'brush_8',ccol)
                    end
                    over:SetText('{s32}{ol}{#FFAA66} ' .. tostring(cur) .. ' ')
                end

                if (g.chganim > 0) then
                    g.chganim = math.max(0, g.chganim - g.speed)
                end

                pic:Invalidate()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OUTRAGEGAUGE_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        CHAT_SYSTEM('[OG]Unrecognized command.')
    end
    
    if cmd == "lock" then
		OUTRAGEGAUGE_LOCKPOSITION(true)
		CHAT_SYSTEM("[OG]Position locked.")
	end
    if cmd == "unlock" then
		OUTRAGEGAUGE_LOCKPOSITION(false)
		CHAT_SYSTEM("[OG]Position unlocked.")
    end
    if cmd == "floating" then
		OUTRAGEGAUGE_SETSTYLE(0)
		CHAT_SYSTEM("[OG]Changed to floating mode.")
    end
    if cmd == "fixed" then
		OUTRAGEGAUGE_SETSTYLE(1)
		CHAT_SYSTEM("[OG]Changed to fixed mode.")
    end
    if cmd == "reset" then
		OUTRAGEGAUGE_DEFAULT_SETTINGS()
        OUTRAGEGAUGE_SAVE_SETTINGS()
        OUTRAGEGAUGE_INIT()
		CHAT_SYSTEM("[OG]Reset settings.")
    end
end
