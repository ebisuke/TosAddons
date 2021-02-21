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
        style = 0
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

            if not g.loaded then
                g.loaded = true
            end

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
            frame:Resize(300, 300)
            frame:SetLayerLevel(g.settings.layerlevel or 60)
            local pic = frame:CreateOrGetControl('groupbox', 'pic', 0, 0, frame:GetWidth(), frame:GetHeight())
            local over = frame:CreateOrGetControl('richtext', 'over', 0, 0, frame:GetWidth(), 30)
            over:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            over:SetMargin(0,0,0,20)
            AUTO_CAST(pic)
            AUTO_CAST(over)

            FRAME_AUTO_POS_TO_OBJ(frame, session.GetMyHandle(), -150, -150, 1, 1, 1)
            pic:EnableHitTest(0)
            over:EnableHitTest(0)
            --pic:CreateInstTexture()
            --pic:FillClonePicture('00000000')

            OUTRAGEGAUGE_RENDER()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function OUTRAGEGAUGE_TIMER_BEGIN()
    libaodrawpic=LIBAODRAWPICV1_1
    local frame = ui.GetFrame(g.framename)
    frame:CreateOrGetControl('timer', 'addontimer', 0, 0, 10, 10)
    local timer = GET_CHILD(frame, 'addontimer', 'ui::CAddOnTimer')
    timer:SetUpdateScript('OUTRAGEGAUGE_ON_TIMER')
    timer:Start(0.01)
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
                    local maxtime = g.buffs[clsid_oh].maxtime
                    local time = buff.time

                    local least = 4
                    local maxammo = 40
                    local color = 'CCFFFF00'
                    local colorshade = 'CC777700'
                   
                    local wh=300
                    local h = 30
                    
                    local oy = wh -h- 40
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
                    pic:DrawBrushHorz(ox + w/2- w/2 * time / maxtime, oy + h-3+10, ox + w/2+ w/2*time / maxtime, oy + h-3+10, brush, '887777FF')
                    pic:DrawBrushHorz(ox + w/2- w/2 * time / maxtime, oy + h+10, ox + w/2+ w/2*time / maxtime, oy + h+10, brush, '884444FF')
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
                        pic:DrawBrushHorz(i*sz+25,260,i*sz+sz-int+25,260,'brush_8',ccol)
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
