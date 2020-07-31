--アドオン名（大文字）
local addonName = 'ANOTHERONEOFPARTYINFO'
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
g.settings =
    g.settings or
    {
        x = 300,
        y = 300
    }
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'anotheroneofpartyinfo'
g.debug = false
g.tick = 0
g.casting = false
g.castanim = 0
g.trace = nil
g.run = g.run or false
--ライブラリ読み込み
CHAT_SYSTEM('[AOP]loaded')

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

function AOP_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function AOP_DEFAULT_SETTINGS()
    g.settings = {
        x = 300,
        y = 300,
        style = 0,
        lock = false,
        layerlevel = 90
    }
end
function AOP_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        AOP_DEFAULT_SETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end

    AOP_UPGRADE_SETTINGS()
    AOP_SAVE_SETTINGS()
end

function AOP_UPGRADE_SETTINGS()
    local upgraded = false

    return upgraded
end

--マップ読み込み時処理（1度だけ）
function ANOTHERONEOFPARTYINFO_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            --addon:RegisterMsg('GAME_START_3SEC', 'CHALLENGEMODESTUFF_SHOW')
            --ccするたびに設定を読み込む

            addon:RegisterMsg('STAT_UPDATE', 'AOP_HEADSUPDISPLAY_ON_MSG')
            addon:RegisterMsg('GAME_START_3SEC', 'AOP_HEADSUPDISPLAY_ON_MSG')
            addon:RegisterMsg('LEVEL_UPDATE', 'AOP_HEADSUPDISPLAY_ON_MSG')
            addon:RegisterMsg('FPS_UPDATE', 'AOP_ON_FPS_UPDATE')
            addon:RegisterMsg('PARTY_UPDATE', 'AOP_ON_PARTYINFO_UPDATE')
            addon:RegisterMsg('PARTY_BUFFLIST_UPDATE', 'AOP_ON_PARTYINFO_BUFFLIST_UPDATE')
            addon:RegisterMsg('PARTY_INST_UPDATE', 'AOP_ON_PARTYINFO_INST_UPDATE')
            addon:RegisterMsg('PARTY_OUT', 'AOP_ON_PARTYINFO_DESTROY')
            addon:RegisterMsg('PARTY_INVITE_CANCEL', 'AOP_ON_PARTY_INVITE_CANCEL')

            acutil.setupHook(AOP_CHECKDIST_SELECT_TARGET_FROM_PARTY, 'CHECKDIST_SELECT_TARGET_FROM_PARTY')
            if not g.loaded then
                g.loaded = true
            end

            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            --CHALLENGEMODESTUFF_SHOW(g.frame)
            DBGOUT('INIT')
            --CHALLENGEMODESTUFF_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_ON_PARTYINFO_INST_UPDATE()
    --AOP_INIT()
end
function AOP_ON_PARTYINFO_UPDATE()
    AOP_INIT()
end
function AOP_ON_PARTYINFO_DESTROY()
    AOP_INIT()
end
function AOP_ON_FPS_UPDATE()
    g.frame:ShowWindow(1)
end

function AOP_CASTING(mode)
    g.casting = mode
    if (mode == true) then
    -- local frame=ui.GetFrame("party_recommend")
    -- local MAX_SHOW_COUNT = 4;

    -- for index=1,MAX_SHOW_COUNT do

    --     local memberSet = GET_CHILD_RECURSIVELY(frame, 'memberSet_'..tostring(index));
    --     local nameText = GET_CHILD_RECURSIVELY(memberSet, 'nameText');
    --     nameText:SetTextByKey('name', "nil");

    -- end
    end
end
function AOP_INIT()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:RemoveAllChild()
            frame:Resize(800, 800)
            frame:SetLayerLevel(g.settings.layerlevel or 90)
            --下準備

            local bg = frame:CreateOrGetControl('picture', 'bg' .. 0, 0, 0, 150, 110)
            AUTO_CAST(bg)
            local bg = frame:CreateOrGetControl('picture', 'bg' .. 1, 0, 0, 150, 110)
            AUTO_CAST(bg)
            local bg = frame:CreateOrGetControl('picture', 'bg' .. 2, 0, 0, 150, 110)
            AUTO_CAST(bg)
            local bg = frame:CreateOrGetControl('picture', 'bg' .. 3, 0, 0, 150, 110)
            AUTO_CAST(bg)

            local pic = frame:CreateOrGetControl('picture', 'pic', 0, 0, frame:GetWidth(), frame:GetHeight())
            local touch = frame:CreateOrGetControl('picture', 'touchbar', 10, 22, 40, 40)

            tolua.cast(pic, 'ui::CPicture')
            tolua.cast(touch, 'ui::CPicture')

            pic:EnableHitTest(0)
            pic:CreateInstTexture()
            pic:FillClonePicture('00000000')

            touch:EnableHitTest(1)
            touch:SetEnableStretch(1)
            touch:SetEventScript(ui.MOUSEWHEEL, 'AOP_MOUSEWHEEL')
            touch:SetEventScript(ui.LBUTTONDOWN, 'AOP_LBTNDOWN')
            touch:SetEventScript(ui.LBUTTONUP, 'AOP_LBTNUP')
            touch:SetEventScript(ui.RBUTTONUP, 'AOP_RBTNUP')
            -- soulcrystal:ShowWindow(0)
            -- soulcrystal:EnableHitTest(0)
            local etc = GetMyEtcObject()
            local jobClassID = TryGetProp(etc, 'RepresentationClassID', 'None')
            if jobClassID == 'None' or tonumber(jobClassID) == 0 then
                local MySession = session.GetMyHandle()
                jobClassID = info.GetJob(MySession)
            end
            local jobCls = GetClassByType('Job', jobClassID)
            local jobIcon = TryGetProp(jobCls, 'Icon')
            if jobIcon ~= nil then
                touch:SetImage(jobIcon)
                touch:SetTextTooltip('To show AOP menu,Press LSHIFT + LALT + RBtn ')
            end

            AOP_RENDER()
            AOP_TIMER_BEGIN()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOP_HEADSUPDISPLAY_ON_MSG(frame, msg, argStr, argNum)
    if (msg == 'GAME_START_3SEC') then
        g.frame:ShowWindow(1)
        AOP_LOAD_SETTINGS()
        AOP_INIT()
        g.frame:SetOffset(g.settings.x, g.settings.y)
        g.run = true
        AOP_TIMER_BEGIN()
    end
    if (g.run == false) then
        return
    end
    if (msg == 'STAT_UPDATE') then
        AOP_RENDER()
    end
end
function AOP_TIMER_BEGIN()
    local frame = ui.GetFrame(g.framename)
    frame:CreateOrGetControl('timer', 'addontimer', 0, 0, 10, 10)
    local timer = GET_CHILD(frame, 'addontimer', 'ui::CAddOnTimer')
    timer:SetUpdateScript('AOP_ON_TIMER')
    timer:Start(0.01)
    timer:EnableHideUpdate(1)
    frame:CreateOrGetControl('timer', 'addontimer2', 0, 0, 10, 10)
    local timer = GET_CHILD(frame, 'addontimer2', 'ui::CAddOnTimer')
    timer:SetUpdateScript('AOP_ON_LONGTIMER')
    timer:Start(1)
    timer:EnableHideUpdate(1)
end

function AOP_CALC_POINT(actualval, minw, maxw, maxav)
    local valw = math.max(minw, math.min(maxw, actualval * maxw / maxav))
    return valw
end
function AOP_CALC_POINT_ANIMATED(widthval, remwidthval, actualval, actualmax, minw, maxw, maxav, speed)
    local amax = math.min(maxw, actualmax * maxw / maxav)
    local valw
    if (amax < minw) then
        valw = math.min(maxw, actualval * minw / amax)
    elseif (actualmax > maxav) then
        valw = math.min(maxw, actualval * maxw / actualmax)
    else
        valw = math.min(maxw, actualval * maxw / maxav)
    end

    if (widthval > valw) then
        --減少
        if (remwidthval < valw) then
            --remを増やす
            remwidthval = valw
        end
        --curhpを近づける
        widthval = math.max(valw, widthval - math.max((widthval - valw) * speed, 1))
    elseif (widthval < valw) then
        if (remwidthval < valw) then
            --remを近づける
            remwidthval = remwidthval + math.max((valw - remwidthval) * speed, 1)
        elseif (remwidthval > valw) then
            --remを減らす
            remwidthval = valw
        else
            --curhpを近づける
            widthval = math.min(valw, widthval + math.max((valw - widthval) * speed, 1))
        end
    else
        if (remwidthval > valw) then
            --remを近づける
            remwidthval = math.max(valw, remwidthval - math.max((remwidthval - valw) * speed, 1))
        end
    end
    return widthval, remwidthval
end
function AOP_CALC_POINT_SIMPLE_ANIMATED(widthval, actualval, actualmax, minw, maxw, maxav, speed)
    local amax = math.min(maxw, actualmax * maxw / maxav)
    local valw
    if (amax < minw) then
        valw = math.min(maxw, actualval * minw / actualmax)
    elseif (actualmax > maxav) then
        valw = math.min(maxw, actualval * maxw / actualmax)
    else
        valw = math.min(maxw, actualval * maxw / maxav)
    end

    if (widthval > valw) then
        --減少
        --curspを近づける
        widthval = math.max(valw, widthval - math.max((widthval - valw) * speed, 0.10))
    elseif (widthval < valw) then
        --curspを近づける
        widthval = math.min(valw, widthval + math.max((valw - widthval) * speed, 0.10))
    end

    return widthval
end
function AOP_ON_TIMER(frame)
    EBI_try_catch {
        try = function()
            g.tick = g.tick + 1

            if (g.tick >= 100) then
                g.tick = 0
            end
            local pframe = ui.GetFrame('party_recommend')
            local dx = (pframe:GetX() - 50) - g.settings.x
            local dy = (pframe:GetY() - 50) - g.settings.y
            g.settings.mode = g.settings.mode or 0x00
            if (g.settings.mode & 0x02 ~= 0) then
                g.castanim = 1
            elseif (g.casting) then
                g.castanim = g.castanim + (1 - g.castanim) / 2
                if (1 - g.castanim < 0.001) then
                    g.castanim = 1
                end
            else
                g.castanim = g.castanim - (g.castanim) / 2
                if (g.castanim < 0.001) then
                    g.castanim = 0
                end
            end
            if (g.castanim > 0) then
                g.frame:SetOffset(g.settings.x + dx * g.castanim, g.settings.y + dy * g.castanim)
            end
           
            if (ui.GetFrame('party_recommend'):IsVisible() == 1 and g.casting == false and ((g.settings.mode & 0x08) ~= 0)) then
                AOP_CASTING(true)
            end
            
            if (ui.GetFrame('party_recommend'):IsVisible() == 0 and g.casting == true) then
                AOP_CASTING(false)
            end
            if (keyboard.IsKeyPressed('LSHIFT') == 1 and keyboard.IsKeyPressed('LALT') == 1) then
                frame:GetChild('touchbar'):ShowWindow(1)
            else
                frame:GetChild('touchbar'):ShowWindow(0)
            end
            AOP_RENDER()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_RENDER()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            local pic = frame:GetChild('pic')
            if (pic) then
                AUTO_CAST(pic)
                pic:FillClonePicture('00000000')
                AOP_RENDER_PARTY(frame, pic)
                pic:Invalidate()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_RENDER_PARTY_MEMBER(frame, pic, partyMemberInfo, idx, inc, ox, oy)
    EBI_try_catch {
        try = function()
            local id = tostring(inc)
            local bg = frame:CreateOrGetControl('picture', 'bg' .. id, ox, oy, 150, 110)
            AUTO_CAST(bg)
            bg:EnableHitTest(0)
            bg:CreateInstTexture()

            bg:FillClonePicture('55000000')
            if (not g.casting or AOP_GET_MEMBER_STATE(inc + 1)) then
            else
                bg:DrawBrush(0, bg:GetHeight(), bg:GetWidth(), 0, 'spray_8', 'FFFF0000')
                bg:DrawBrush(0, 0, bg:GetWidth(), bg:GetHeight(), 'spray_8', 'FFFF0000')
            end
            bg:Invalidate()

            local box = ox + 10

            local sz = 130

            local hp = 0
            local mhp = 1
            local dhp = 0
            local sp = 0
            local msp = 1
            local dsp = 0
            local goy = oy + 30
            local redzone = false
            local handle = partyMemberInfo:GetHandle()
            local actor = world.GetActor(handle)
            local targetinfo = info.GetTargetInfo(handle)
            local myInfo = session.party.GetMyPartyObj()
            if partyMemberInfo:GetMapID() > 0 then
                local stat = partyMemberInfo:GetInst()
                --近くにキャラがいるならその情報を採用
                if (targetinfo) then
                    stat = targetinfo.stat
                    hp = stat.HP
                    mhp = stat.maxHP
                    sp = stat.SP
                    msp = stat.maxSP
                else
                    hp = stat.hp
                    mhp = stat.maxhp
                    sp = stat.sp
                    msp = stat.maxsp
                end
                dhp = hp / mhp

                dsp = sp / msp
            else
            end
            pic:DrawBrush(box + 2, goy, box + sz - 2, goy, 'aop_spray_large_bs', 'AA000000')
            pic:DrawBrush(box + 8, goy, box + sz - 8, goy, 'aop_spray_small_bs', 'AA000000')
            if (dhp > 0.3) then
                pic:DrawBrush(box, goy, box + sz * dhp, goy, 'aop_spray_large_bs', 'FF22FF77')
                pic:DrawBrush(box + 2, goy + 2, box + sz * dhp + 2, goy + 2, 'aop_spray_small_bs', 'FF11CC55')
            else
                pic:DrawBrush(box, goy, box + sz * dhp, goy, 'aop_spray_large_bs', string.format('FF%02X0000', math.abs(50 - g.tick) * 255 / 50))
                pic:DrawBrush(box + 2, goy + 2, box + sz * dhp + 2, goy + 2, 'aop_spray_small_bs', string.format('FF%02X0000', math.abs(50 - g.tick) * 128 / 50))
                redzone = true
            end
            pic:DrawBrush(box + 8, goy + 8, box + sz * dsp + 8, goy + 8, 'aop_spray_small_bs', 'FF44CCFF')

            pic:DrawBrush(ox, oy + 14, ox + sz + 20, oy + 14, 'aop_spray_vsmall_bar', '88000000')
            local iconinfo = partyMemberInfo:GetIconInfo()
            local jobCls = GetClassByType('Job', iconinfo.repre_job)
            if nil ~= jobCls then
                local job = frame:CreateOrGetControl('picture', 'job' .. id, ox - 2, oy - 2, 20, 20)
                AUTO_CAST(job)
                job:EnableHitTest(0)
                job:SetImage(jobCls.Icon)
                job:SetEnableStretch(1)
            end
            local iamLeader = false

            local pcparty = session.party.GetPartyInfo()
            if (pcparty) then
                if pcparty.info:GetLeaderAID() == partyMemberInfo:GetAID() then
                    iamLeader = true
                end
            end

            local color = ''
            if myInfo == nil then
                color = '{#999999}'
            elseif (iamLeader) then
                color = '{#FFFF00}'
            end

            if myInfo and (myInfo:GetMapID() ~= partyMemberInfo:GetMapID() or myInfo:GetChannel() ~= partyMemberInfo:GetChannel()) then
                local text =
                    AOP_GENERATE_TEXT(
                    frame,
                    'location' .. id,
                    '{ol}{s10}' .. geMapTable.GetMapName(partyMemberInfo:GetMapID()) .. ' ' .. tostring(partyMemberInfo:GetChannel() + 1) .. 'ch',
                    (ox + 75),
                    oy + 15,
                    75,
                    15
                )
                text:SetGravity(ui.RIGHT, ui.TOP)
                text:SetOffset(frame:GetWidth() - (ox + 150), text:GetY())
            else
                local text = AOP_GENERATE_TEXT(frame, 'location' .. id, '', ox + 20, oy, 80, 15)
                text:SetGravity(ui.LEFT, ui.TOP)
            end

            --local name=AOP_GENERATE_TEXT(frame, "name" .. id, "{@st43}{ol}{s14}" .. color .. "なまえ", ox + 20, oy, 80, 15)
            local name = AOP_GENERATE_TEXT(frame, 'name' .. id, '{@st43}{ol}{s14}' .. color .. partyMemberInfo:GetName(), ox + 20, oy, 80, 15)
            name:EnableHitTest(1)
            name:SetTextTooltip('LSHIFT+LCLICK Show Map')
            name:SetEventScript(ui.LBUTTONUP, 'AOP_SHOW_MAP')
            name:SetEventScript(ui.RBUTTONUP, 'AOP_MEMBER_CONTEXT')
            name:SetEventScriptArgNumber(ui.LBUTTONUP, idx)
            name:SetEventScriptArgNumber(ui.RBUTTONUP, idx)
            local rz = ''
            if (redzone) then
                rz = '{#FF0000}'
            end
            AOP_GENERATE_TEXT(frame, 'hp' .. id, '{@st43}{ol}{s16}' .. rz .. tostring(hp), ox + 20, oy + 12, 100, 15)

            --buffs
            local slotsbuff
            local slotsdebuff
            if (frame:GetChild('buffs' .. id)) then
                slotsbuff = frame:CreateOrGetControl('slotset', 'buffs' .. id, ox, oy + 50, 120, 15)
                slotsdebuff = frame:CreateOrGetControl('slotset', 'debuffs' .. id, ox, oy + 80 + 15, 120, 15)
                AUTO_CAST(slotsbuff)
                AUTO_CAST(slotsdebuff)
                if (slotsbuff:GetCol()~= 10) then
                    slotsbuff:SetSlotSize(15, 15)
                    slotsdebuff:SetSlotSize(15, 15)
                    slotsbuff:SetColRow(10, 3)
                    slotsdebuff:SetColRow(10, 1)
                    slotsdebuff:SetSpc(0, 0);
                    slotsbuff:SetSpc(0, 0);
                    slotsbuff:RemoveAllChild()
                    slotsdebuff:RemoveAllChild()
                    slotsbuff:CreateSlots()
                    slotsdebuff:CreateSlots()
                    slotsbuff:EnableDrag(0)
                    slotsdebuff:EnableDrag(0)
                    slotsbuff:EnableDrop(0)
                    slotsdebuff:EnableDrop(0)
                    slotsbuff:Invalidate()
                    slotsdebuff:Invalidate()
                    DBGOUT('HERE')
                end
              
            else
                slotsbuff = frame:CreateOrGetControl('slotset', 'buffs' .. id, ox, oy + 50, 120, 15)
                slotsdebuff = frame:CreateOrGetControl('slotset', 'debuffs' .. id, ox, oy + 80 + 15, 120, 15)
                AUTO_CAST(slotsbuff)
                AUTO_CAST(slotsdebuff)
                if (slotsbuff:GetCol()~= 10) then
                    slotsbuff:SetSlotSize(15, 15)
                    slotsdebuff:SetSlotSize(15, 15)
                    slotsbuff:SetColRow(10, 3)
                    slotsdebuff:SetColRow(10, 1)
                    slotsdebuff:SetSpc(0, 0);
                    slotsbuff:SetSpc(0, 0);
                    slotsbuff:RemoveAllChild()
                    slotsdebuff:RemoveAllChild()
                    slotsbuff:CreateSlots()
                    slotsdebuff:CreateSlots()
                    slotsbuff:EnableDrag(0)
                    slotsdebuff:EnableDrag(0)
                    slotsbuff:EnableDrop(0)
                    slotsdebuff:EnableDrop(0)
                    slotsbuff:Invalidate()
                    slotsdebuff:Invalidate()
                    DBGOUT('HERE')
                end

            end
            --cleanup
            for i = 0, slotsbuff:GetSlotCount() - 1 do
                slotsbuff:GetSlotByIndex(i):ShowWindow(0)
            end
            for i = 0, slotsdebuff:GetSlotCount() - 1 do
                slotsdebuff:GetSlotByIndex(i):ShowWindow(0)
            end
            if (targetinfo) then
                local buffCount = info.GetBuffCount(handle)
                if buffCount > 0 then
                    local buffIndex = 0
                    local debuffIndex = 0
                   
                    for j = 0, buffCount - 1 do
                        local buff = info.GetBuffIndexed(handle, j)
                        local cls = GetClassByType('Buff', buff.buffID)
                        local buffID = buff.buffID

                        if cls ~= nil and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= 'TeamLevel'  then
                            local slot
                            if cls.Group1 == 'Buff' then
                                slot = slotsbuff:GetSlotByIndex(buffIndex)
                                buffIndex = buffIndex + 1
                            elseif cls.Group1 == 'Debuff' then
                                slot = slotsdebuff:GetSlotByIndex(debuffIndex)
                                debuffIndex = debuffIndex + 1
                            end
                            if slot ~= nil then
                                local icon = slot:GetIcon()
                                if icon == nil then
                                    icon = CreateIcon(slot)
                                end

                                handle = tostring(handle)
                                if buff.over > 1 then
                                    slot:SetText('{s13}{ol}{b}' .. buff.over, 'count', ui.RIGHT, ui.BOTTOM, 1, 2)
                                else
                                    slot:SetText('')
                                end
                                icon:SetTooltipType('buff')
                                icon:SetTooltipArg(handle, buffID, '')

                                local imageName = 'icon_' .. cls.Icon
                                icon:Set(imageName, 'BUFF', buffID, 0)

                                slot:ShowWindow(1)
                                slot:EnableHitTest(1)
                            end
                        end
                    end
                    --cleanup
                    for i = buffIndex, slotsbuff:GetSlotCount() - 1 do
                        slotsbuff:GetSlotByIndex(i):ShowWindow(0)
                    end
                    for i = debuffIndex, slotsdebuff:GetSlotCount() - 1 do
                        slotsdebuff:GetSlotByIndex(i):ShowWindow(0)
                    end
                end
            else
                local buffCount = partyMemberInfo:GetBuffCount()
                -- 아이콘 셋팅
                if buffCount <= 0 then
                    partyMemberInfo:ResetBuff()
                    buffCount = partyMemberInfo:GetBuffCount()
                end
 
                if buffCount > 0 then
                    local buffIndex = 0
                    local debuffIndex = 0
                 
                    for j = 0, buffCount - 1 do
                        local buffID = partyMemberInfo:GetBuffIDByIndex(j)

                        local cls = GetClassByType('Buff', buffID)
                        if cls ~= nil and IS_PARTY_INFO_SHOWICON(cls.ShowIcon) == true and cls.ClassName ~= 'TeamLevel' then
                            local buffOver = partyMemberInfo:GetBuffOverByIndex(j)
                            local buffTime = partyMemberInfo:GetBuffTimeByIndex(j)
                            local slot
                           
                            if cls.Group1 == 'Buff' then
                                slot = slotsbuff:GetSlotByIndex(buffIndex)
                                buffIndex = buffIndex + 1
                            elseif cls.Group1 == 'Debuff' then
                                slot = slotsdebuff:GetSlotByIndex(debuffIndex)
                                debuffIndex = debuffIndex + 1
                            end
                            if slot ~= nil  then
                                
                                local icon = slot:GetIcon()
                                if icon == nil then
                                    icon = CreateIcon(slot)
                                end

                                local handle = 0
                                if myInfo ~= nil then
                                    if myInfo:GetMapID() == partyMemberInfo:GetMapID() and myInfo:GetChannel() == partyMemberInfo:GetChannel() then
                                        handle = partyMemberInfo:GetHandle()
                                    end
                                end
             
                                handle = tostring(handle)
                                icon:SetDrawCoolTimeText(math.floor(buffTime / 1000))
                                icon:SetTooltipType('buff')
                                icon:SetTooltipArg(handle, buffID, '')

                                local imageName = 'icon_' .. cls.Icon
                                icon:Set(imageName, 'BUFF', buffID, 0)
                                if buffOver > 1 then
                                    slot:SetText('{s13}{ol}{b}' .. buffOver, 'count', ui.RIGHT, ui.BOTTOM, 1, 2)
                                else
                                    slot:SetText('')
                                end
                                slot:ShowWindow(1)
                                slot:EnableHitTest(1)
                            end
                        end
                    end
                    --cleanup
                    for i = buffIndex, slotsbuff:GetSlotCount() - 1 do
                        slotsbuff:GetSlotByIndex(i):ShowWindow(0)
                    end
                    for i = debuffIndex, slotsdebuff:GetSlotCount() - 1 do
                        slotsdebuff:GetSlotByIndex(i):ShowWindow(0)
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_RENDER_PARTY(frame, pic)
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local count = list:Count()
    local inc = 0

    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i)
        if partyMemberInfo:GetAID() == session.loginInfo.GetAID() then
        else
            local ox = 10
            local oy = 0
            local d = g.castanim
            local rd = 1 - g.castanim
            local mode = g.settings.mode or 0
            local masked = mode & 0x03
            if (masked & 0x02 ~= 0) then
                --counterclockwise
                if (inc == 0) then
                    ox = 220
                    oy = 55
                elseif (inc == 1) then
                    ox = 5
                    oy = 245 * d
                elseif (inc == 2) then
                    ox = 220 * d
                    oy = 445 * d
                else
                    ox = 445 * d
                    oy = 245 * d
                end
            elseif masked & 0x01 == 0 then
                --horz
                if (inc == 0) then
                    ox = 50 * rd + 220 * d
                    oy = 0 * rd + 55 * d
                elseif (inc == 1) then
                    ox = (200 + 5) * rd + 5 * d
                    oy = 0 * rd + 245 * d
                elseif (inc == 2) then
                    ox = (350 + 10) * rd + 220 * d
                    oy = 0 * rd + 445 * d
                else
                    ox = (500 + 15) * rd + 445 * d
                    oy = 0 * rd + 245 * d
                end
            elseif masked & 0x01 == 1 then
                --vert
                if (inc == 0) then
                    ox = 50 * rd + 220 * d
                    oy = 0 * rd + 55 * d
                elseif (inc == 1) then
                    ox = 50 * rd + 5 * d
                    oy = 90 * rd + 245 * d
                elseif (inc == 2) then
                    ox = 50 * rd + 220 * d
                    oy = 180 * rd + 445 * d
                else
                    ox = 50 * rd + 445 * d
                    oy = 270 * rd + 245 * d
                end
            end

            AOP_RENDER_PARTY_MEMBER(frame, pic, partyMemberInfo, i, inc, ox, oy)

            inc = inc + 1
        end
    end
end
function AOP_GENERATE_TEXT(frame, name, text, x, y, w, h)
    local c = frame:CreateOrGetControl('richtext', name, x, y, w, h)
    AUTO_CAST(c)
    c:SetText(text)
    c:EnableHitTest(0)
    return c
end
function AOP_LBTNDOWN(parent, ctrl)
    if (not g.settings.lock) then
        if (g.casting == true) then
            return
        end
        local frame = parent:GetTopParentFrame()

        local x, y = GET_MOUSE_POS()

        g.x = x -- 드래그할 때, 클릭한 좌표를 기억한다.
        g.y = y

        ui.EnableToolTip(0)
        ctrl:RunUpdateScript('AOP_PROCESS_MOUSE')
    end
end

function AOP_LBTNUP(parent, ctrl)
    if (g.casting == true) then
        return
    end
    -- 워프 위치에서 마우스를 떼지 않았다면 클릭한 좌표를 리셋한다.
    g.x = nil
    g.y = nil
    AOP_SAVE_SETTINGS()
end
function AOP_RBTNUP(parent, ctrl)
    if (keyboard.IsKeyPressed('LSHIFT') == 1 and keyboard.IsKeyPressed('LALT') == 1) then
        local context = ui.CreateContextMenu('AOP', '', 0, 0, 170, 100)
        ui.AddContextMenuItem(context, 'LOCK/UNLOCK Position', 'AOP_LOCKUNLOCK(1)')
        ui.AddContextMenuItem(context, 'Mode:Horizontal', 'AOP_CHANGEMODE(0x00)')
        ui.AddContextMenuItem(context, 'Mode:Vertical', 'AOP_CHANGEMODE(0x01)')
        ui.AddContextMenuItem(context, 'Mode:Counterclockwise', 'AOP_CHANGEMODE(0x02)')
        ui.AddContextMenuItem(context, 'Mode:Horzontal{s12}(Counterclockwise when selecting target)', 'AOP_CHANGEMODE(0x08)')
        ui.AddContextMenuItem(context, 'Mode:Vertical{s12}(Counterclockwise when selecting target)', 'AOP_CHANGEMODE(0x09)')

        ui.OpenContextMenu(context)
    end
end
function AOP_CHANGEMODE(mode)
    g.settings.mode = mode
    AOP_SAVE_SETTINGS()
end
function AOP_LOCKUNLOCK()
    g.settings.lock = not g.settings.lock
end
function AOP_STYLE(style)
    g.frame:SetOffset(40, 40)
    g.settings.style = style
    g.settings.lock = false
    AOP_SAVE_SETTINGS()
end
function AOP_PROCESS_MOUSE(ctrl)
    return EBI_try_catch {
        try = function()
            if (g.casting == true) then
                return
            end
            local frame = ctrl:GetTopParentFrame()
            if mouse.IsLBtnPressed() == 0 then
                ui.EnableToolTip(1)
                AOP_SAVE_SETTINGS()
                return 0
            end
            local mx, my = GET_MOUSE_POS()
            local x = g.x
            local y = g.y
            local dx = mx - x
            local dy = my - y
            dx = dx
            dy = dy

            local cx = frame:GetX()
            local cy = frame:GetY()
            local curWidth = option.GetClientWidth()
            local curHeight = option.GetClientHeight()
            if (curWidth >= 3000) then
                cx = cx + dx / 2
                cy = cy + dy / 2
            else
                cx = cx + dx
                cy = cy + dy
            end
            g.x = mx
            g.y = my

            cx = math.max(-frame:GetWidth() / 2, math.min(cx, curWidth - 30))
            cy = math.max(-frame:GetHeight() / 2, math.min(cy, curHeight - 30))
            g.settings.x = cx
            g.settings.y = cy
            AOP_SAVE_SETTINGS()
            frame:SetOffset(cx, cy)

            return 1
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_CHECKDIST_SELECT_TARGET_FROM_PARTY(index, outRange, is_unrecoverState)
    CHECKDIST_SELECT_TARGET_FROM_PARTY_OLD(index, outRange, is_unrecoverState)
    g.memberstate = g.memberstate or {}
    g.memberstate[index] = outRange or is_unrecoverState
    DBGOUT('TT' .. tostring(index) .. ' ' .. tostring(outRange))
end
function AOP_GET_MEMBER_STATE(index)
    g.memberstate = g.memberstate or {}
    return not (g.memberstate[index] == true)
end

function AOP_SHOW_MAP(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            if (keyboard.IsKeyPressed('LSHIFT') == 1) then
                local list = session.party.GetPartyMemberList(PARTY_NORMAL)
                local count = list:Count()
                local partyinfo = list:Element(argnum)
                local mapCls = GetClassByType('Map', partyinfo:GetMapID())
                local stat = partyinfo:GetInst()
                local pos = stat:GetPos()
                if (mapCls) then
                    SCR_SHOW_LOCAL_MAP(mapCls.ClassName, true, pos.x, pos.z)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_MEMBER_CONTEXT(frame, ctrl, argstr, argnum)
    EBI_try_catch {
        try = function()
            local context = ui.CreateContextMenu('AOP', '', 0, 0, 170, 100)
            ui.AddContextMenuItem(context, 'TRACE', 'AOP_DOTRACE(' .. tostring(argnum) .. ')')
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_DOTRACE(idx)
    EBI_try_catch {
        try = function()
            local list = session.party.GetPartyMemberList(PARTY_NORMAL)
            local count = list:Count()
            local partyinfo = list:Element(idx)
            if (g.trace == partyinfo:GetAID()) then
                g.trace = nil
            else
                g.trace = partyinfo:GetAID()
                DBGOUT('AID:' .. tostring(g.trace))
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOP_ON_LONGTIMER(frame)
    EBI_try_catch {
        try = function()
            if (g.trace) then
                DBGOUT('TRACE')
                local list = session.party.GetPartyMemberList(PARTY_NORMAL)
                local count = list:Count()

                local myInfo = session.party.GetMyPartyObj()
                for i = 0, count - 1 do
                    local partyMemberInfo = list:Element(i)
                    local aid = partyMemberInfo:GetAID()

                    if (myInfo ~= nil) and (aid == g.trace) and myInfo:GetMapID() == partyMemberInfo:GetMapID() and myInfo:GetChannel() == partyMemberInfo:GetChannel() then
                        local actor = GetMyActor()
                        local pos = actor:GetPos()
                        local stat = partyMemberInfo:GetInst()
                        local targetpos = stat:GetPos()

                        local eff = 'F_sys_arrow_pc'
                        local dist = math.sqrt(math.pow((targetpos.x - pos.x), 2) + math.pow((targetpos.z - pos.z), 2))
                        local dirinitial = dist
                        DBGOUT('DIST' .. tostring(dirinitial))
                        while dist >= 1 do
                            local dir = math.atan(targetpos.x - pos.x, targetpos.z - pos.z)

                            local di = dist / dirinitial
                            local div
                            local xx = pos.x + math.sin(dir) * dirinitial * di
                            local zz = pos.z + math.cos(dir) * dirinitial * di

                            effect.PlayGroundEffect(GetMyActor(), eff, 1, xx, pos.y + 1, zz, 1, 'None', -dir + math.pi, 0)
                            dist = dist - 20
                        end

                        break
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
