-- specifictargetskill
--アドオン名（大文字）
local addonName = 'specifictargetskill'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
--ライブラリ読み込み
CHAT_SYSTEM('[STS]loaded')
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

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch{
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
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end
--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'specifictargetskill'
g.debug = true
g.magic = "78912873940"
g.waitingskillid = nil
g.waitingconfig = nil

g.functype = {
    ['lowhp'] = {id = 1, name = 'lowhp', hidden = true, text = 'Low HP', num = 0, img = 'sts_lowhp', func =
        function(skillid, argStr)
            EBI_try_catch{
                try = function()
                    if g.debug then
                        
                        
                        -- party member
                        local myMapName = session.GetMapName();
                        local myMapCls = GetClass('Map', myMapName);
                        local partyList = session.party.GetPartyMemberList(PARTY_NORMAL);
                        local emphasizePic = nil;
                        local emphasizeValue = nil;
                        local lowparty = nil
                        local hp = 99999999999
                        if partyList ~= nil then
                            DBGOUT('herea' .. partyList:Count())
                            local count = partyList:Count();
                            local index = 1;
                            for i = 0, count - 1 do
                               
                                local partyMemberInfo = partyList:Element(i);
                                local stat
                                local hpp
                                if partyMemberInfo:GetAID() == session.loginInfo.GetAID() then
                                    stat = info.GetStat(session.GetMyHandle());
                                    hpp=stat.HP
                                else

                                    stat = partyMemberInfo:GetInst();
                                    hpp=stat.hp
                                end
                                
                                if stat and hpp < hp then
                                    lowparty = partyMemberInfo
                                    hp = hpp
                                end
                                DBGOUT('joo' .. partyMemberInfo:GetName())
                            end
                            geSkillControl.SetPartyMemberTarget(-1, lowparty:GetAID(), argStr);
                        
                        end
                    
                    end
                end,
                catch = function(error)
                    ERROUT(error)
                
                end
            }
        end},
    ['pt1'] = {id = 2, name = 'pt1', hidden = false, text = 'PT Member1(Self)', num = 0, img = 'sts_pt1'},
    ['pt2'] = {id = 3, name = 'pt2', hidden = false, text = 'PT Member2(Up)', num = 1, img = 'sts_pt2'},
    ['pt3'] = {id = 4, name = 'pt3', hidden = false, text = 'PT Member3(Left)', num = 2, img = 'sts_pt3'},
    ['pt4'] = {id = 5, name = 'pt4', hidden = false, text = 'PT Member4(Down)', num = 3, img = 'sts_pt4'},
    ['pt5'] = {id = 6, name = 'pt5', hidden = false, text = 'PT Member5(Right)', num = 4, img = 'sts_pt5'},
    ['roundrobin'] = {id = 7, name = 'roundrobin', hidden = false, text = 'RoundRobin', num = 0, img = 'sts_roundrobin'},
    ['debuff'] = {id = 8, name = 'debuff', hidden = false, text = 'Debuff', num = 0, img = 'sts_debuff'},

}
if not g.debug then
    g.functype['lowhp'] = {id = 1, name = 'lowhp', hidden = true, text = '(Disabled)', num = 0, img = 'sts_lowhp'}
end
g.roundrobin = {
    
    }


function SPECIFICTARGETSKILL_SAVE_SETTINGS()
    --SPECIFICTARGETSKILL_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(session.GetMySession():GetCID()))
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end
function SPECIFICTARGETSKILL_SAVE_ALL()
    SPECIFICTARGETSKILL_SAVETOSTRUCTURE()
    SPECIFICTARGETSKILL_SAVE_SETTINGS()
    ui.MsgBox('保存しました')
end
function SPECIFICTARGETSKILL_SAVETOSTRUCTURE()
    local frame = ui.GetFrame(g.framename)
end

function SPECIFICTARGETSKILL_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    g.personalsettings = {skills = {}}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings = {skills = {}}
    
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
    
    end
    SPECIFICTARGETSKILL_UPGRADE_SETTINGS()
    SPECIFICTARGETSKILL_SAVE_SETTINGS()
    SPECIFICTARGETSKILL_LOADFROMSTRUCTURE()
end

function SPECIFICTARGETSKILL_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame(g.framename)
end

function SPECIFICTARGETSKILL_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function SPECIFICTARGETSKILL_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(SPECIFICTARGETSKILL_GETCID()))
            frame:ShowWindow(0)
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            
            frame:ShowWindow(0)
            acutil.slashCommand("/sts", SPECIFICTARGETSKILL_PROCESS_COMMAND);
            acutil.setupHook(SPECIFICTARGETSKILL_SET_QUICK_SLOT, 'SET_QUICK_SLOT')
            --acutil.setupHook(SPECIFICTARGETSKILL_ICON_USE, 'ICON_USE')
            if ICON_USE ~= SPECIFICTARGETSKILL_ICON_USE then
                SPECIFICTARGETSKILL_ICON_USE_OLD = ICON_USE
                ICON_USE = SPECIFICTARGETSKILL_ICON_USE
            end
            
            
            acutil.setupHook(SPECIFICTARGETSKILL_OPEN_SELECT_TARGET_FROM_PARTY, 'OPEN_SELECT_TARGET_FROM_PARTY')
            --addon:RegisterMsg('OPEN_SELECT_TARGET', 'SPECIFICTARGETSKILL_OPEN_SELECT_TARGET_FROM_PARTY');
            SPECIFICTARGETSKILL_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SPECIFICTARGETSKILL_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local txtwarning = frame:CreateOrGetControl('richtext', 'txtwarning', 30, 50, 100, 100)
            txtwarning:SetText('{ol}{#FF0000}This addon cannot use in PVP area.')
            local txtdrophere = frame:CreateOrGetControl('richtext', 'txtdrophere', 100, 90, 100, 30)
            txtdrophere:SetText('{ol}Drop here')
            local slotsource = frame:CreateOrGetControl('slot', 'slotsource', 100, 120, 60, 60)
            AUTO_CAST(slotsource)
            slotsource:EnableDrag(0)
            slotsource:EnableDrop(1)
            slotsource:SetSkinName('invenslot2')
            slotsource:SetEventScript(ui.DROP, 'SPECIFICTARGETSKILL_ON_DROP')
            local txtdrag = frame:CreateOrGetControl('richtext', 'txtdrag', 400, 90, 100, 30)
            txtdrag:SetText('{ol}Drag to quickslot')
            local slotdest = frame:CreateOrGetControl('slot', 'slotdest', 400, 120, 60, 60)
            AUTO_CAST(slotdest)
            slotdest:EnableDrag(1)
            slotdest:EnableDrop(0)
            slotdest:SetSkinName('invenslot2')
            local cmbconf = frame:CreateOrGetControl('droplist', 'cmbconf', 210, 120, 180, 20)
            AUTO_CAST(cmbconf)
            cmbconf:SetSkinName("droplist_normal");
            local inc = 0
            cmbconf:ClearItems()
            for _, v in pairs(g.functype) do
                cmbconf:AddItem(inc, '')
                inc = inc + 1
            end
            
            for _, v in pairs(g.functype) do
                cmbconf:SetItemTextByKey(v.id - 1,
                    string.format('{ol}{img %s 20 20}%s',
                        v.img, v.text))
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SPECIFICTARGETSKILL_ON_DROP(frame, ctrl)
    EBI_try_catch{
        try = function()
            DBGOUT('dropped')
            local liftIcon = ui.GetLiftIcon();
            local liftIconiconInfo = liftIcon:GetInfo();
            local iconParentFrame = liftIcon:GetTopParentFrame();
            local iconCategory = liftIconiconInfo:GetCategory();
            local cmbconf = frame:GetChild('cmbconf')
            AUTO_CAST(cmbconf)
            if iconCategory == 'Skill' or iconCategory == g.category then
                local iconType = liftIconiconInfo.type;
                local skl = session.GetSkill(iconType);
                SPECIFICTARGETSKILL_UPDATE_SRC(skl)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SPECIFICTARGETSKILL_UPDATE_SRC(skill)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local slotdest = frame:GetChild('slotdest')
            AUTO_CAST(slotdest)
            local slotsource = frame:GetChild('slotsource')
            DBGOUT('AA' .. tostring(skill.type))
            AUTO_CAST(slotsource)
            slotsource:RemoveAllChild()
            local iesid = skill:GetIESID()
            local imageNamesrc = 'icon_' .. GetClassString('Skill', skill.type, 'Icon');
            local iconsrc = CreateIcon(slotsource)
            iconsrc:Set(imageNamesrc, 'skill', skill.type, 0, iesid);
            iconsrc:SetTooltipNumArg(skill.type);
            iconsrc:SetTooltipStrArg("quickslot");
            iconsrc:SetTooltipType('skill');
            iconsrc:SetTooltipIESID(iesid);
            SPECIFICTARGETSKILL_UPDATE_DEST()
        end,
        catch = function(error)
            ERROUT(error)
            local frame = ui.GetFrame(g.framename)
            local slotsrc = frame:GetChild('slotsource')
            AUTO_CAST(slotsrc)
            slotsrc:ClearIcon()
            slotsrc:RemoveAllChild()
            local slotdest = frame:GetChild('slotdest')
            AUTO_CAST(slotdest)
            slotdest:ClearIcon()
            slotdest:RemoveAllChild()
        end
    }
end
function SPECIFICTARGETSKILL_UPDATE_DEST()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local slotdest = frame:GetChild('slotdest')
            AUTO_CAST(slotdest)
            slotdest:RemoveAllChild()
            local slotsource = frame:GetChild('slotsource')
            AUTO_CAST(slotsource)
            local icon = slotsource:GetIcon();
            local iconinfo = icon:GetInfo();
            
            local iesid = iconinfo:GetIESID()
            local imageNamesrc = 'icon_' .. GetClassString('Skill', iconinfo.type, 'Icon');
            local iconsrc = CreateIcon(slotsource)
            local imageNamedest = 'icon_' .. GetClassString('Skill', iconinfo.type, 'Icon');
            local icondest = CreateIcon(slotdest)
            
            local cmbconf = frame:GetChild('cmbconf')
            AUTO_CAST(cmbconf)
            local idx = cmbconf:GetSelItemIndex()
            local cfg = nil
            for k, v in pairs(g.functype) do
                if v.id == idx + 1 then
                    cfg = v
                    break
                end
            end
            
            icondest:Set(imageNamedest, 'Skill', iconinfo.type, 0, g.magic .. cfg.id);
            icondest:SetTooltipNumArg(iconinfo.type);
            icondest:SetTooltipStrArg("quickslot");
            icondest:SetTooltipType('skill');
            icondest:SetTooltipIESID(iesid);
            
            SPECIFICTARGETSKILL_ADD_ICONDESC(slotdest)
        
        end,
        catch = function(error)
            ERROUT(error)
            local frame = ui.GetFrame(g.framename)
            local slotsrc = frame:GetChild('slotsource')
            AUTO_CAST(slotsrc)
            slotsrc:ClearIcon()
            slotsrc:RemoveAllChild()
            local slotdest = frame:GetChild('slotdest')
            AUTO_CAST(slotdest)
            slotdest:ClearIcon()
            slotdest:RemoveAllChild()
        end
    }
end
function SPECIFICTARGETSKILL_SET_QUICK_SLOT(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)
    EBI_try_catch{
        try = function()
            --DBGOUT('caall')
            if iesID:find(g.magic) == 1 then
                DBGOUT('caall')
                local icon = CreateIcon(slot);
                local imageName = "";
                local skl = session.GetSkill(type);
                if IS_NEED_CLEAR_SLOT(skl, type) == true then
                    if icon ~= nil then
                        tolua.cast(icon, "ui::CIcon");
                        icon:SetTooltipNumArg(0)
                    end
                    slot:ClearIcon();
                    QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
                    return;
                end
                imageName = 'icon_' .. GetClassString('Skill', type, 'Icon');
                icon:SetOnCoolTimeUpdateScp('ICON_UPDATE_SKILL_COOLDOWN');
                icon:SetEnableUpdateScp('ICON_UPDATE_SKILL_ENABLE');
                icon:SetColorTone("FFFFFFFF");
                icon:ClearText();
                quickslot.OnSetSkillIcon(slot, type);
                if iesID == nil then
                    iesID = ""
                end
                
                local category = category;
                local type = type;
                
                slot:SetPosTooltip(0, 0);
                
                icon:SetTooltipType('skill');
                
                icon:Set(imageName, category, type, 0, iesID);
                icon:SetTooltipNumArg(type);
                icon:SetTooltipStrArg("quickslot");
                icon:SetTooltipIESID(skl:GetIESID());
                
                
                local isLockState = quickslot.GetLockState();
                if isLockState == 1 then
                    slot:EnableDrag(0);
                else
                    slot:EnableDrag(1);
                end
                
                INIT_QUICKSLOT_SLOT(slot, icon);
                local sendPacket = 1;
                if false == sendSavePacket then
                    sendPacket = 0;
                end
                
                
                local icon = slot:GetIcon()
                if icon ~= nil then
                    DBGOUT('setinfo')
                    quickslot.SetInfo(slot:GetSlotIndex(), category, type, iesID);
                    icon:SetDumpArgNum(slot:GetSlotIndex());
                end
                
                
                
                SET_QUICKSLOT_OVERHEAT(slot);
                SET_QUICKSLOT_TOOLSKILL(slot);
                SPECIFICTARGETSKILL_ADD_ICONDESC(slot)
            else
                SET_QUICK_SLOT_OLD(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)
            end
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }
end
function SPECIFICTARGETSKILL_ICON_USE(object, reAction)
    EBI_try_catch{
        try = function()
            DBGOUT('here')
            local iconPt = object;
            if iconPt ~= nil then
                local icon = tolua.cast(iconPt, 'ui::CIcon');
                DBGOUT('here2')
                local iconInfo = icon:GetInfo();
                local pc = GetMyPCObject();
                if iconInfo:GetIESID():find(g.magic) == 1 then
                    if IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                        --disabled in pvp
                        ui.SysMsg('[STS]Cannot use in pvp area.')
                        return
                    else
                        
                        local typ = tonumber(iconInfo:GetIESID():match(g.magic .. '(.*)'))
                        DBGOUT('fire')
                        g.waitingskillid = iconInfo.type
                        local cfg = nil
                        for k, v in pairs(g.functype) do
                            if v.id == typ then
                                cfg = v
                                break
                            end
                        end
                        g.waitingconfig = cfg
                        control.Skill(iconInfo.type)
                        DebounceScript('SPECIFICTARGETSKILL_CANCEL_SKILL', 0.2)
                        return
                    end
                end
            end
            SPECIFICTARGETSKILL_ICON_USE_OLD(object, reAction)
        end,
        catch = function(error)
            ERROUT(error)
        
        end
    }

end
function SPECIFICTARGETSKILL_ADD_ICONDESC(slot)
    local icon = slot:GetIcon()
    local iconinfo = icon:GetInfo()
    
    
    if iconinfo:GetIESID():find(g.magic) == 1 then
        DBGOUT('hore')
        local id = tonumber(iconinfo:GetIESID():match(g.magic .. '(.*)'))
        if id then
            local config
            for k, v in pairs(g.functype) do
                if v.id == id then
                    config = v
                    break
                end
            end
            --local subicon=CreateIconByIndex(slot,1)
            slot:SetFrontImage(config.img);
        -- local desc = slot:CreateOrGetControl('picture', 'sts_icondesc', 0, 0, 20, 20)
        -- AUTO_CAST(desc)
        -- desc:SetImage(config.img)
        -- desc:SetGravity(ui.RIGHT, ui.TOP)
        -- desc:EnableHitTest(0)
        else
            ERROUT('fail' .. iconinfo:GetIESID())
        end
    end
end

function SPECIFICTARGETSKILL_PROCESS_COMMAND(command)
    local cmd = "";
    
    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = "usage{nl}/sts conf Configration{nl}/sts resetrr Reset Roundrobin"
        return ui.MsgBox(msg, "", "Nope")
    end
    
    if cmd == "conf" then
        ui.ToggleFrame(g.framename)
        if ui.GetFrame(g.framename):IsVisible() == 1 then
            SPECIFICTARGETSKILL_INITFRAME()
        end
    end
    if cmd == "resetrr" then
        g.roundrobin = {}
    end
end
function SPECIFICTARGETSKILL_OPEN_SELECT_TARGET_FROM_PARTY(frame, msg, argStr, showHPGauge)
    -- skill
    local skillID = geSkillControl.GetSelectTargetFromPartyListSkillID();
    
    
    
    if g.waitingskillid == skillID then
        --PARTY_RECOMMEND_DEFAULT_SETTING(frame, skillID)
        local err, result = pcall(g.waitingconfig.func, skillID, argStr)
        --ui.SysMsg('[STS]To cast,Repress hotkey.')
        config.InitHotKeyByCurrentUIMode('Battle');
        frame:ShowWindow(1);
        local txt = frame:CreateOrGetControl('richtext', 'txtnotify', 0, 0, 200, 40)
        txt:SetText('{ol}{s24}{#FF0000}[STS]To cast,Repress hotkey.')
        txt:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
        
        --OPEN_SELECT_TARGET_FROM_PARTY_OLD(frame, msg, argStr, showHPGauge)
        SPECIFICTARGETSKILL_CANCEL_SKILL()
    else
        frame:RemoveChild('txtnotify')
        OPEN_SELECT_TARGET_FROM_PARTY_OLD(frame, msg, argStr, showHPGauge)
    end
end
function SPECIFICTARGETSKILL_CANCEL_SKILL()
    g.waitingskillid = nil
    
    g.waitingconfig = nil
end
_G['ADDONS'][author][addonName] = g
