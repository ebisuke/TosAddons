-- customobeyskill.lua
--アドオン名（大文字）
local addonName = "CUSTOMOBEYSKILL"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "customobeyskill"
g.debug = true
--g.lastobey=nil
CHAT_SYSTEM("[COS]loaded")
local acutil = require("acutil")
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

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
end

local function DBGOUT(msg)
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end
function CUSTOMOBEYSKILL_CLOSE()
    local frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
    CUSTOMOBEYSKILL_LOCK_SKILLS(false)
end
--マップ読み込み時処理（1度だけ）
function CUSTOMOBEYSKILL_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPEXTENDER_GETCID()))
            frame:ShowWindow(0)
            CUSTOMOBEYSKILL_LOAD_SETTINGS()
            --ccするたびに設定を読み込む
            acutil.setupHook(CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_MY_MONSTER_SKILL, "QUICKSLOTNEXPBAR_MY_MONSTER_SKILL")
            acutil.setupHook(CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL, "JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL")
            acutil.setupHook(CUSTOMOBEYSKILL_MONSTER_QUICKSLOT, "MONSTER_QUICKSLOT")
            acutil.setupHook(CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_ON_DROP, "JOYSTICK_QUICKSLOT_ON_DROP")
            acutil.setupHook(CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_ON_DROP, "QUICKSLOTNEXPBAR_ON_DROP")
            g.isOn = 0
            acutil.slashCommand("/cos", CUSTOMOBEYSKILL_PROCESS_COMMAND)
            acutil.slashCommand("/customobeyskill", CUSTOMOBEYSKILL_PROCESS_COMMAND)
            if not g.loaded then
                g.loaded = true
            end
            g.lastobey = nil
            CUSTOMOBEYSKILL_INITFRAME()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CUSTOMOBEYSKILL_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function CUSTOMOBEYSKILL_APPLYICONTOSLOT(slot, skillType)
    local skl = session.GetSkill(skillType)
    local sklClass = GetClassByType("Skill", skillType)
    local icon = CreateIcon(slot)
    AUTO_CAST(icon)
    local iconInfo = icon:GetInfo()
    slot:SetUserValue("ICON_CATEGORY", iconInfo:GetCategory())
    slot:SetUserValue("ICON_TYPE", iconInfo.type)

    local imageName = ""
    imageName = "icon_" .. GetClassString("Skill", skillType, "Icon")
    icon:SetOnCoolTimeUpdateScp("ICON_UPDATE_SKILL_COOLDOWN")
    icon:SetEnableUpdateScp("MONSTER_ICON_UPDATE_SKILL_ENABLE")
    icon:SetColorTone("FFFFFFFF")
    icon:ClearText()
    icon:SetTooltipStrArg(sklClass.ClassName)
    icon:SetTooltipNumArg(sklClass.ClassID)
    icon:SetTooltipIESID(GetIESGuid(skl))

    if imageName ~= "" then
        icon:Set(imageName, category, skillType, 0)

        local icon = slot:GetIcon()
        if icon ~= nil then
            icon:SetDumpArgNum(slot:GetSlotIndex())
        end
    end

    slot:EnableDrag(1)
    slot:EnableDrop(0)

    icon:SetTextTooltip("{@st41}{s18}" .. sklClass.Name .. "(" .. sklClass.ClassName .. ")")
end
function CUSTOMOBEYSKILL_REFRESH()
    CUSTOMOBEYSKILL_INITFRAME(g.lastobey)
end
function CUSTOMOBEYSKILL_INITFRAME(monName)
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:Resize(600, 360)
            local gbox =
                frame:CreateOrGetControl(
                "groupbox",
                "groupbox_customobeyskill",
                0,
                100,
                frame:GetWidth() - 20,
                frame:GetHeight() - 100
            )
            AUTO_CAST(gbox)
            gbox:SetSkinName("test_groupbox")
            gbox:EnableScrollBar(1)
            gbox:RemoveAllChild()
            local txt = gbox:CreateOrGetControl("richtext", "richtext_howtouse", 20, 0, gbox:GetWidth(), 30)
            txt:SetText("{ol}Drop icon to quick slot.{/}")
            local btnrefresh = gbox:CreateOrGetControl("button", "btn_refresh", gbox:GetWidth() - 100, 0, 100, 30)
            AUTO_CAST(btnrefresh)
            btnrefresh:SetText("Refresh")
            btnrefresh:SetEventScript(ui.LBUTTONUP, "CUSTOMOBEYSKILL_REFRESH")
            -- create slots for monster skills
            if monName == nil then
                local txt = gbox:CreateOrGetControl("richtext", "richtext_warn", 20, 50, gbox:GetWidth(), 30)
                txt:SetText("{ol}{#FFFF00}Must be obey before open this window.")
                ReserveScript("CUSTOMOBEYSKILL_LOCK_SKILLS(true)", 0.00)
            else
                local monCls = GetClass("Monster", monName)
                local slotCount = 0
                local slotWidth = 40
                local slotHeight = 40
                local slotMargin = 5
                local slotStartX = 10
                local slotStartY = 40
                local list = GetMonsterSkillList(monCls.ClassID)
                list:Add("Common_StateClear")

                local slotset =
                    gbox:CreateOrGetControl("slotset", "slotset_customobeyskill", 10, 20, gbox:GetWidth() - 20, 160)
                AUTO_CAST(slotset)
                slotset:SetColRow(7, math.ceil(list:Count() / 7))
                slotset:SetSlotSize(80, 80)
                slotset:CreateSlots()
                slotset:SetSkinName("invenslot2")
                for i = 0, list:Count() - 1 do
                    local sklName = list:Get(i)
                    local sklCls = GetClass("Skill", sklName)
                    local type = sklCls.ClassID
                    local slot = slotset:GetSlotByIndex(i)
                    AUTO_CAST(slot)
                    CUSTOMOBEYSKILL_APPLYICONTOSLOT(slot, type)
                end
                ReserveScript("CUSTOMOBEYSKILL_LOCK_SKILLS(false)", 0.00)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function CUSTOMOBEYSKILL_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format("[%s] cannot load setting files", addonName))
        g.settings = {
            monsters = {}
        }
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    CUSTOMOBEYSKILL_UPGRADE_SETTINGS()
    CUSTOMOBEYSKILL_SAVE_SETTINGS()
end

function CUSTOMOBEYSKILL_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_MY_MONSTER_SKILL(isOn, monName, buffType)
    CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_MY_MONSTER_SKILL_IMPL(isOn, monName, buffType)
end
function CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_MY_MONSTER_SKILL_IMPL(isOn, monName, buffType)
    local frame = ui.GetFrame("quickslotnexpbar")
    if isOn == 1 then
        CUSTOMOBEYSKILL_INITFRAME(monName)
        g.lastobey = monName
        local icon = nil
        local monCls = GetClass("Monster", monName)
        local list = GetMonsterSkillList(monCls.ClassID)
        if g.settings.monsters[monName] then
            --add
            for i = 0, MAX_QUICKSLOT_CNT - 1 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                tolua.cast(slot, "ui::CSlot")
                slot:EnableDrag(0)
                slot:EnableDrop(0)
                local icon = slot:GetIcon()
                if icon ~= nil and icon:GetInfo():GetCategory() == "Skill" then
                    icon:SetEnable(0)
                    icon:SetEnableUpdateScp("None")
                end
            end
            for k, v in pairs(g.settings.monsters[monName]["keyboard"]) do
                local sklType = tonumber(v)
                local sklClass = GetClass("Skill", sklType)
                local type = sklType
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. k + 1, "ui::CSlot")
                AUTO_CAST(slot)
                tolua.cast(slot, "ui::CSlot")
                quickslot.OnSetSkillIcon(slot, type)
                icon = slot:GetIcon()
                local sklCls = GetClass("Skill", sklName)
                local type = sklType
                SET_MON_QUICK_SLOT(frame, slot, "Skill", type)
                icon = slot:GetIcon()
                slot:SetEventScript(ui.RBUTTONUP, "None")
            end
        else
            list:Add("Common_StateClear")
            for i = 0, list:Count() - 1 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                tolua.cast(slot, "ui::CSlot")
                local sklName = list:Get(i)
                local sklCls = GetClass("Skill", sklName)
                local type = sklCls.ClassID
                SET_MON_QUICK_SLOT(frame, slot, "Skill", type)
                icon = slot:GetIcon()
                slot:SetEventScript(ui.RBUTTONUP, "None")
            end

            for i = list:Count(), MAX_QUICKSLOT_CNT - 1 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                tolua.cast(slot, "ui::CSlot")
                slot:EnableDrag(0)
                slot:EnableDrop(0)
                local icon = slot:GetIcon()
                if icon ~= nil and icon:GetInfo():GetCategory() == "Skill" then
                    icon:SetEnable(0)
                    icon:SetEnableUpdateScp("None")
                end
            end
        end
        if icon ~= nil and monName == "Colony_Siege_Tower" then
            icon:SetImage("Icon_common_get_off")
        end

        frame:SetUserValue("SKL_MAX_CNT", list:Count())
        frame:SetUserValue("MON_RESET_COOLDOWN", 0)
        return
    else
        QUICKSLOTNEXPBAR_MY_MONSTER_SKILL_OLD(isOn, monName, buffType)
    end
end
function CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL_IMPL(isOn, monName, buffType)
    local frame = ui.GetFrame("joystickquickslot")
    if isOn == 1 then
        g.lastobey = monName
        local icon = nil
        local monCls = GetClass("Monster", monName)
        local list = GetMonsterSkillList(monCls.ClassID)
        if g.settings.monsters[monName] then
            --add
            for i = 0, MAX_QUICKSLOT_CNT - 1 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                tolua.cast(slot, "ui::CSlot")
                slot:EnableDrag(0)
                slot:EnableDrop(0)
                local icon = slot:GetIcon()
                if icon ~= nil and icon:GetInfo():GetCategory() == "Skill" then
                    icon:SetEnable(0)
                    icon:SetEnableUpdateScp("None")
                end
            end
            for k, v in pairs(g.settings.monsters[monName]["joystick"]) do
                local sklType = tonumber(v)
                local sklClass = GetClass("Skill", sklType)
                local type = sklClass.ClassID
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. k + 1, "ui::CSlot")
                AUTO_CAST(slot)
                tolua.cast(slot, "ui::CSlot")
                icon = slot:GetIcon()

                quickslot.OnSetSkillIcon(slot, type)
                quickslot.SetInfo(slot:GetSlotIndex(), category, type, "")
                local sklCls = GetClass("Skill", sklName)
                local type = sklType
                SET_MON_QUICK_SLOT(frame, slot, "Skill", type)
                icon = slot:GetIcon()
                slot:SetEventScript(ui.RBUTTONUP, "None")
            end
        else
            --use defaulting
            list:Add("Common_StateClear")
            for i = 0, list:Count() - 1 do
                local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
                tolua.cast(slot, "ui::CSlot")
                icon = slot:GetIcon()
                local sklName = list:Get(i)
                local sklCls = GetClass("Skill", sklName)
                local type = sklCls.ClassID
                SET_MON_QUICK_SLOT(frame, slot, "Skill", type)
                icon = slot:GetIcon()
                slot:SetEventScript(ui.RBUTTONUP, "None")
            end
        end
        if icon ~= nil and monName == "Colony_Siege_Tower" then
            icon:SetImage("Icon_common_get_off")
        end

        frame:SetUserValue("SKL_MAX_CNT", list:Count())
        frame:SetUserValue("MON_RESET_COOLDOWN", 0)
        CUSTOMOBEYSKILL_INITFRAME(monName)
        return
    else
        JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL_OLD(isOn, monName, buffType)
    end
end

function CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL(isOn, monName, buffType)
    CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL_IMPL(isOn, monName, buffType)
end
function CUSTOMOBEYSKILL_MONSTER_QUICKSLOT(isOn, monName, buffType, ableToUseSkill)
    return CUSTOMOBEYSKILL_MONSTER_QUICKSLOT_IMPL(isOn, monName, buffType, ableToUseSkill)
end
function CUSTOMOBEYSKILL_MONSTER_QUICKSLOT_IMPL(isOn, monName, buffType, ableToUseSkill)
    g.isOn = isOn
    if (isOn == 1) then
        g.lastobey = monName
        DBGOUT("ON")
    else
        g.lastobey = nil
        DBGOUT("OFF")
    end

    MONSTER_QUICKSLOT_OLD(isOn, monName, buffType, ableToUseSkill)
    pcall(CUSTOMOBEYSKILL_INITFRAME, g.lastobey)
end

function CUSTOMOBEYSKILL_REPLACEICON(quickslotframe, slot, skillName)
    local flag = 0
    if slot:GetIcon() == nil then
        flag = 1
    end
    local category = "Skill"
    local sklClass = GetClass("Skill", skillName)
    local type = sklClass.ClassID
    local icon = CreateIcon(slot)
    local slotindex = slot:GetSlotIndex()

    if icon ~= nil then
        local iconInfo = icon:GetInfo()
        slot:SetUserValue("ICON_CATEGORY", iconInfo:GetCategory())
        slot:SetUserValue("ICON_TYPE", iconInfo.type)
        if (quickslotframe:GetUserValue("before_summon_skill_slot_" .. tostring(iconInfo.type)) == nil) then
            quickslotframe:SetUserValue("before_summon_skill_slot_" .. tostring(iconInfo.type), type)
        end
    end

    local skl = session.GetSkill(type)
    if IS_NEED_CLEAR_SLOT(skl, type) == true then
        if icon ~= nil then
            tolua.cast(icon, "ui::CIcon")
            icon:SetTooltipNumArg(0)
        end

        slot:ClearIcon()
        QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0)
        return
    end

    local imageName = ""
    imageName = "icon_" .. GetClassString("Skill", type, "Icon")
    icon:SetOnCoolTimeUpdateScp("ICON_UPDATE_SKILL_COOLDOWN")
    icon:SetEnableUpdateScp("MONSTER_ICON_UPDATE_SKILL_ENABLE")
    icon:SetColorTone("FFFFFFFF")
    icon:ClearText()
    quickslot.OnSetSkillIcon(slot, type)

    if imageName ~= "" then
        icon:Set(imageName, category, type, 0)
        INIT_QUICKSLOT_SLOT(slot, icon)
        local icon = slot:GetIcon()
        if icon ~= nil then
            if flag == 1 then
                quickslot.SetInfo(slot:GetSlotIndex(), category, type, "")
            end
            icon:SetDumpArgNum(slot:GetSlotIndex())
        end
    end

    slot:EnableDrag(0)
    slot:EnableDrop(0)
    icon:SetTooltipType("skill_summon")
    SET_QUICKSLOT_OVERHEAT(slot)
end
function CUSTOMOBEYSKILL_PROCESS_COMMAND(command)
    local cmd = ""

    if #command > 0 then
        cmd = table.remove(command, 1)
    else
        ui.ToggleFrame(g.framename)
        return
    end

    if (cmd == "setting") then
        ui.ToggleFrame(g.framename)
        return
    end
    if (cmd == "reset") then
        CHAT_SYSTEM("[COS]Reset this monster skill list")
        if g.lastobey then
            g.settings.monsters[g.lastobey] = nil
        end
        CUSTOMOBEYSKILL_SAVE_SETTINGS()
        WORKPANEL_INITFRAME(g.lastobey)
        return
    end
    if (cmd == "allreset") then
        CHAT_SYSTEM("[COS]Reset all monster skill list")
        g.settings.monsters = {}
        CUSTOMOBEYSKILL_SAVE_SETTINGS()
        WORKPANEL_INITFRAME(g.lastobey)
        return
    end
end
function CUSTOMOBEYSKILL_SHOW()
    local frame = ui.GetFrame(g.framename)

    frame:ShowWindow(1)
    CUSTOMOBEYSKILL_LOCK_SKILLS(false)
end

function CUSTOMOBEYSKILL_LOCK_SKILLS(lock)
    local frame = ui.GetFrame(g.framename)

    if (g.isOn == 1) then
        --unlock all
        local frame = ui.GetFrame("quickslotnexpbar")
        g.settings.monsters = g.settings.monsters or {}
        for i = 0, MAX_QUICKSLOT_CNT - 1 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
            tolua.cast(slot, "ui::CSlot")
            slot:EnableDrag(0)
            if (not lock) then
                slot:EnableDrop(1)
                local icon = slot:GetIcon()
                if icon ~= nil then
                    icon:SetEnable(1)
                    icon:SetEventScript(ui.RBUTTONDOWN, "CUSTOMOBEYSKILL_REMOVEICON_KEYBOARD")
                    icon:SetEnableUpdateScp("None")
                end
            else
                slot:EnableDrop(0)
                local icon = slot:GetIcon()

                if
                    g.settings.monsters[g.lastobey] and g.settings.monsters[g.lastobey]["joystick"] and
                        g.settings.monsters[g.lastobey]["joystick"]["" .. i] and
                        icon ~= nil and
                        icon:GetInfo():GetCategory() == "Skill"
                 then
                    icon:SetEnable(0)
                    icon:SetEventScript(ui.RBUTTONDOWN, "NONE")
                    icon:SetEnableUpdateScp("None")
                end
            end
        end
        frame = ui.GetFrame("joystickquickslot")

        for i = 0, MAX_QUICKSLOT_CNT - 1 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
            tolua.cast(slot, "ui::CSlot")
            slot:EnableDrag(0)
            if (not lock) then
                slot:EnableDrop(1)
                local icon = slot:GetIcon()
                if icon ~= nil then
                    icon:SetEnable(1)
                    icon:SetEventScript(ui.RBUTTONDOWN, "CUSTOMOBEYSKILL_REMOVEICON_JOYSTICK")
                    icon:SetEnableUpdateScp("None")
                end
            else
                slot:EnableDrop(0)
                local icon = slot:GetIcon()

                if
                    g.settings.monsters[g.lastobey] and g.settings.monsters[g.lastobey]["joystick"] and
                        g.settings.monsters[g.lastobey]["joystick"]["" .. i] and
                        icon ~= nil and
                        icon:GetInfo():GetCategory() == "Skill"
                 then
                    icon:SetEnable(0)
                    icon:SetEventScript(ui.RBUTTONDOWN, "NONE")
                    icon:SetEnableUpdateScp("None")
                end
            end
        end
    end
end

function CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)
    return CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_ON_DROP_IMPL(frame, control, argStr, argNum)
end

function CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_ON_DROP_IMPL(frame, control, argStr, argNum)
    EBI_try_catch {
        try = function()
            local sframe = ui.GetFrame(g.framename)

            if sframe then
                local slot = AUTO_CAST(control)
                local liftIcon = ui.GetLiftIcon()
                local liftIconiconInfo = liftIcon:GetInfo()
                local index = slot:GetSlotIndex()
                if (g.lastobey) then
                    DBGOUT("drpped on " .. g.lastobey)
                    g.settings.monsters = g.settings.monsters or {}
                    g.settings.monsters[g.lastobey] = g.settings.monsters[g.lastobey] or {}
                    g.settings.monsters[g.lastobey]["keyboard"] = g.settings.monsters[g.lastobey]["keyboard"] or {}
                    g.settings.monsters[g.lastobey]["keyboard"]["" .. index] = liftIconiconInfo.type
                    local sklCls = GetClass("Skill", liftIconiconInfo.type)
                    CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_MY_MONSTER_SKILL_IMPL(1, g.lastobey, liftIconiconInfo.type)

                    CUSTOMOBEYSKILL_SAVE_SETTINGS()
                end
            else
                return QUICKSLOTNEXPBAR_ON_DROP_OLD(frame, control, argStr, argNum)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_ON_DROP(frame, control, argStr, argNum)
    return CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_ON_DROP_IMPL(frame, control, argStr, argNum)
end

function CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_ON_DROP_IMPL(frame, control, argStr, argNum)
    local sframe = ui.GetFrame(g.framename)
    if sframe then
        local slot = AUTO_CAST(control)
        local liftIcon = ui.GetLiftIcon()
        local liftIconiconInfo = liftIcon:GetInfo()
        local index = slot:GetSlotIndex()
        if (g.lastobey) then
            DBGOUT("drpped on " .. g.lastobey)
            g.settings.monsters = g.settings.monsters or {}
            g.settings.monsters[g.lastobey] = g.settings.monsters[g.lastobey] or {}
            g.settings.monsters[g.lastobey]["joystick"] = g.settings.monsters[g.lastobey]["joystick"] or {}
            g.settings.monsters[g.lastobey]["joystick"]["" .. index] = liftIconiconInfo.type
            local sklCls = GetClass("Skill", liftIconiconInfo.type)
            CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL_IMPL(1, g.lastobey, liftIconiconInfo.type)

            CUSTOMOBEYSKILL_SAVE_SETTINGS()
        end
    else
        return JOYSTICK_QUICKSLOT_ON_DROP_OLD(frame, control, argStr, argNum)
    end
end

function CUSTOMOBEYSKILL_REMOVEICON_JOYSTICK(frame, control, argStr, argNum)
    local slot = AUTO_CAST(control)
    local sframe = ui.GetFrame(g.framename)
    if sframe then
        if (g.lastobey) then
            DBGOUT("drpped on " .. g.lastobey)
            g.settings.monsters = g.settings.monsters or {}
            g.settings.monsters[g.lastobey] = g.settings.monsters[g.lastobey] or {}
            g.settings.monsters[g.lastobey]["joystick"] = g.settings.monsters[g.lastobey]["joystick"] or {}
            local index = slot:GetSlotIndex()
            local type = g.settings.monsters[g.lastobey]["joystick"]["" .. index]
            g.settings.monsters[g.lastobey]["joystick"]["" .. index] = nil
            CUSTOMOBEYSKILL_JOYSTICK_QUICKSLOT_MY_MONSTER_SKILL_IMPL(1, g.lastobey, type)

            CUSTOMOBEYSKILL_SAVE_SETTINGS()
        end
    end
end

function CUSTOMOBEYSKILL_REMOVEICON_KEYBOARD(frame, control, argStr, argNum)
    EBI_try_catch {
        try = function()
            local slot = AUTO_CAST(control)
            local sframe = ui.GetFrame(g.framename)
            if sframe then
                if (g.lastobey) then
                    DBGOUT("drpped on " .. g.lastobey)
                    g.settings.monsters = g.settings.monsters or {}
                    g.settings.monsters[g.lastobey] = g.settings.monsters[g.lastobey] or {}
                    g.settings.monsters[g.lastobey]["keyboard"] = g.settings.monsters[g.lastobey]["keyboard"] or {}
                    local index = slot:GetSlotIndex()
                    local type = g.settings.monsters[g.lastobey]["keyboard"]["" .. index]
                    g.settings.monsters[g.lastobey]["keyboard"]["" .. index] = nil
                    CUSTOMOBEYSKILL_QUICKSLOTNEXPBAR_MY_MONSTER_SKILL_IMPL(1, g.lastobey, type)

                    CUSTOMOBEYSKILL_SAVE_SETTINGS()
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
