--TELHARSHASUPPORTER
local addonName = 'TELHARSHASUPPORTER'
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
g.framename = 'telharshasupporter'
g.debug = false

g.buffs = {}
g.chganim = 0
g.speed = 0.25
g.tick=0
local libaodrawpic=LIBAODRAWPICV1_1
--ライブラリ読み込み
CHAT_SYSTEM('[TS]loaded')
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

local clsid_water = 17076
local clsid_stop = 17070
local clsid_immune_water = 17077
local buffs={
    clsid_water=true,
    clsid_stop=true,
    clsid_immune_water=true,
}
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
function TELHARSHASUPPORTER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame


            addon:RegisterMsg('FPS_UPDATE', 'TELHARSHASUPPOTER_FPS_UPDATE')
            addon:RegisterMsg('GAME_START_3SEC', 'TELHARSHASUPPOTER_TIMER_BEGIN')
            acutil.slashCommand("/ts", TELHARSHASUPPOTER_PROCESS_COMMAND);
            acutil.slashCommand("/telharshasuppoter", TELHARSHASUPPOTER_PROCESS_COMMAND);
            acutil.setupHook("MON_PC_SKILL_BALLOON",TELHARSHASUPPORTER_MON_PC_SKILL_BALLOON)
            if not g.loaded then
                g.loaded = true
            end
            TELHARSHASUPPOTER_LOAD_SETTINGS()
            DBGOUT('INIT')
            --CHALLENGEMODESTUFF_INIT()
            TELHARSHASUPPOTER_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function TELHARSHASUPPOTER_FPS_UPDATE()
    g.frame:ShowWindow(1)
end
function TELHARSHASUPPOTER_BUFF_UPDATE(frame, msg, argStr, argNum)
    EBI_try_catch {
        try = function()
            local handle = session.GetMyHandle()

            if (msg == 'BUFF_ADD'  or msg == "RELOAD_BUFF_ADD" ) then
                if (buffs[argNum]) then
                    local buff = info.GetBuff(handle, argNum)
                    g.buffs[argNum] = {
                        buff = buff,
                        over = buff.over,
                        maxtime = buff.time
                    }
                    DBGOUT('BUFF')
                end
            elseif (msg == 'BUFF_UPDATE' or (msg == 'BUFF_UPDATE')) then
                if (buffs[argNum]) then
                    g.chganim = 1
                end
                DBGOUT('BUFF')
            elseif (msg == 'BUFF_REMOVE') then
                g.buffs[argNum] = nil
                DBGOUT('REMOVE')
            end
            TELHARSHASUPPOTER_RENDER()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TELHARSHASUPPOTER_INIT()
    EBI_try_catch {
        try = function()
            
            local frame = ui.GetFrame(g.framename)
            frame:RemoveAllChild()
            frame:Resize(300, 50)
            frame:SetLayerLevel(g.settings.layerlevel or 60)
            frame:SetEventScript(ui.LBUTTONUP, "TELHARSHASUPPOTER_END_DRAG")
            frame:SetEventScript(ui.RBUTTONUP, "TELHARSHASUPPOTER_SHOW_CONTEXTMENU")
            
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
                frame:StopUpdateScript("_FRAME_AUTOPOS_BY_FRAMEPOS")
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
            
            TELHARSHASUPPOTER_RENDER()
            TELHARSHASUPPOTER_TIMER_BEGIN()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TELHARSHASUPPOTER_END_DRAG()
    local frame = ui.GetFrame(g.framename)
    g.settings.x=frame:GetX()
    g.settings.y=frame:GetY()
    g.settings.style=1
    TELHARSHASUPPOTER_SAVE_SETTINGS()
    TELHARSHASUPPOTER_INIT()
end

function TELHARSHASUPPOTER_TIMER_BEGIN()
    libaodrawpic=LIBAODRAWPICV1_1
    local frame = ui.GetFrame(g.framename)
    frame:CreateOrGetControl('timer', 'addontimer', 0, 0, 10, 10)
    local timer = GET_CHILD(frame, 'addontimer', 'ui::CAddOnTimer')
    timer:SetUpdateScript('TELHARSHASUPPOTER_ON_TIMER')
    timer:Start(0.01)
end
function TELHARSHASUPPOTER_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function TELHARSHASUPPOTER_SHOW_CONTEXTMENU()
    local context = ui.CreateContextMenu('TELHARSHASUPPOTER', 'TELHARSHASUPPOTER Config', 0, 0, 200, 200)
    ui.AddContextMenuItem(context, 'Cancel', 'None')
    ui.AddContextMenuItem(context, 'Lock Frame', 'TELHARSHASUPPOTER_LOCKPOSITION(true)')
    ui.AddContextMenuItem(context, 'Mode:Floating', 'TELHARSHASUPPOTER_SETSTYLE(0)')
    ui.AddContextMenuItem(context, 'Mode:Fixed', 'TELHARSHASUPPOTER_SETSTYLE(1)')
    ui.OpenContextMenu(context)
end
function TELHARSHASUPPOTER_LOCKPOSITION(lock)
    g.settings.locked=lock
    TELHARSHASUPPOTER_SAVE_SETTINGS()
    TELHARSHASUPPOTER_INIT()
end
function TELHARSHASUPPOTER_SETSTYLE(style)
    g.settings.style=style
    TELHARSHASUPPOTER_SAVE_SETTINGS()
    TELHARSHASUPPOTER_INIT()
end
function TELHARSHASUPPOTER_DEFAULT_SETTINGS()
    g.settings = {
        x = 300,
        y = 300,
        style = 0,
        locked=true,
    }
    
end
function TELHARSHASUPPORTER_MON_PC_SKILL_BALLOON(title, handle, castTimeMS, showCastingBar, changeColor)
    MON_PC_SKILL_BALLOON_OLD(title, handle, castTimeMS, showCastingBar, changeColor)
    if(title==dictionary.ReplaceDicIDInCompStr("");
	local castTimeSec = castTimeMS * 0.001;
	local realTime=castTimeSec/100*55000
end
function TELHARSHASUPPOTER_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        TELHARSHASUPPOTER_DEFAULT_SETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    TELHARSHASUPPOTER_UPGRADE_SETTINGS()
    TELHARSHASUPPOTER_SAVE_SETTINGS()

end


function TELHARSHASUPPOTER_UPGRADE_SETTINGS()
    local upgraded = false
    
    return upgraded
end
function TELHARSHASUPPOTER_ON_TIMER()
    local pos=GetMyActor():GetPos()
	local list = SelectPad(GetMyActor(), 'ALL', pos.x, pos.y, pos.z, 400);
    TELHARSHASUPPOTER_RENDER()
end
function TELHARSHASUPPOTER_RENDER()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = frame:GetChild('pic')
            local over = frame:GetChild('over')
            libaodrawpic.inject(pic)
            AUTO_CAST(pic)
            over:SetText('')
            g.tick=(g.tick+1) % 100
            if (pic and libaodrawpic) then
              
                local w=300
                local h=30;
                if(g.buffs[clsid_water])then
                    -- water buffs
                    local buff=g.buffs[clsid_water]
                    local maxstack=4
                    local stack=buff.over;
                    for i=0,maxstack-1 do
                        
                        if i<stack then
                           pic:DrawBrushVert(i/maxstack*w,(h/2*(i/maxstack)+h/2),i/maxstack*w,h,"brush_8","AA4444FF") 
                        else
                            pic:DrawBrushVert(i/maxstack*w,(h/2*(i/maxstack)+h/2),i/maxstack*w,h,"brush_8","66444444") 
                        end
                       
                    end
                    over:SetText("{s16}{#8888FF}"..stack)
                end
                if(g.buffs[clsid_immune_water])then
                    -- water buffs
                    local buff=g.buffs[clsid_water]
                    pic:DrawBrushHorz(0,h/2,w,h/2,"brush_8","77888888")
                    pic:DrawBrushHorz(0,h/2,w*buff.time/buff.maxtime,h/2,"brush_8","FFFF4444") 
                    over:SetText("{s16}{#FF7777}"..math.ceil(buff.time))
                end
                if(g.buffs[clsid_stop])then
                    -- water buffs
                    local buff=g.buffs[clsid_water]
                    pic:DrawBrushHorz(0,h/2,w,h/2,"brush_8","77888888")
                    pic:DrawBrushHorz(0,h/2,w*buff.time/buff.maxtime,h/2,"brush_8","FF44FF44") 
                    over:SetText("{s16}{#77FF77}"..math.ceil(buff.time))
                end
                pic:Invalidate()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function TELHARSHASUPPOTER_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        CHAT_SYSTEM('[TS]Unrecognized command.')
    end
    
    if cmd == "lock" then
		TELHARSHASUPPOTER_LOCKPOSITION(true)
		CHAT_SYSTEM("[TS]Position locked.")
	end
    if cmd == "unlock" then
		TELHARSHASUPPOTER_LOCKPOSITION(false)
		CHAT_SYSTEM("[TS]Position unlocked.")
    end
    if cmd == "floating" then
		TELHARSHASUPPOTER_SETSTYLE(0)
		CHAT_SYSTEM("[TS]Changed to floating mode.")
    end
    if cmd == "fixed" then
		TELHARSHASUPPOTER_SETSTYLE(1)
		CHAT_SYSTEM("[OG]Changed to fixed mode.")
    end
    if cmd == "reset" then
		TELHARSHASUPPOTER_DEFAULT_SETTINGS()
        TELHARSHASUPPOTER_SAVE_SETTINGS()
        TELHARSHASUPPOTER_INIT()
		CHAT_SYSTEM("[TS]Reset settings.")
    end
end
