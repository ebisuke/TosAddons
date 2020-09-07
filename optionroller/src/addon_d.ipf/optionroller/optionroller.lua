-- optionroller
--アドオン名（大文字）
local addonName = 'optionroller'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'optionroller'
g.debug = false
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.invItem = nil
g.invItemIESID=nil
g.groupCount = nil
g.needs = nil
g.needscount = 0
g.attempts = -1
g.go=false
local OPTION_GROUP_PROP_LIST = {
    ItemRandomOptionGroupSTAT = {
        'STR',
        'DEX',
        'INT',
        'CON',
        'MNA'
    },
    ItemRandomOptionGroupUTIL = {
        'BLK',
        'BLK_BREAK',
        'ADD_HR',
        'ADD_DR',
        'CRTHR',
        'MHP',
        'MSP',
        'MSTA',
        'RHP',
        'RSP',
        'LootingChance'
    },
    ItemRandomOptionGroupDEF = {
        'ADD_DEF',
        'ADD_MDEF',
        'AriesDEF',
        'SlashDEF',
        'StrikeDEF',
        'RES_FIRE',
        'RES_ICE',
        'RES_POISON',
        'RES_LIGHTNING',
        'RES_EARTH',
        'RES_SOUL',
        'RES_HOLY',
        'RES_DARK',
        'CRTDR',
        'Cloth_Def',
        'Leather_Def',
        'Iron_Def',
        'MiddleSize_Def',
        'ResAdd_Damage'
    },
    ItemRandomOptionGroupATK = {
        'PATK',
        'ADD_MATK',
        'CRTATK',
        'CRTMATK',
        'ADD_CLOTH',
        'ADD_LEATHER',
        'ADD_IRON',
        'ADD_SMALLSIZE',
        'ADD_MIDDLESIZE',
        'ADD_LARGESIZE',
        'ADD_GHOST',
        'ADD_FORESTER',
        'ADD_WIDLING',
        'ADD_VELIAS',
        'ADD_PARAMUNE',
        'ADD_KLAIDA',
        'ADD_FIRE',
        'ADD_ICE',
        'ADD_POISON',
        'ADD_LIGHTNING',
        'ADD_EARTH',
        'ADD_SOUL',
        'ADD_HOLY',
        'ADD_DARK',
        'Add_Damage_Atk',
        'ADD_BOSS_ATK'
    }
}
--ライブラリ読み込み
CHAT_SYSTEM('[ER]loaded')
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
        end,
        catch = function(error)
        end
    }
end
function OPTIONROLLER_SAVE_SETTINGS()
    --OPTIONROLLER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function OPTIONROLLER_SAVE_ALL()
    OPTIONROLLER_SAVETOSTRUCTURE()
    OPTIONROLLER_SAVE_SETTINGS()
    ui.MsgBox('保存しました')
end
function OPTIONROLLER_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('optionroller')
end

function OPTIONROLLER_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {foods = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end

    OPTIONROLLER_UPGRADE_SETTINGS()
    OPTIONROLLER_SAVE_SETTINGS()
    OPTIONROLLER_LOADFROMSTRUCTURE()
end

function OPTIONROLLER_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('optionroller')
end

function OPTIONROLLER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function OPTIONROLLER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(OPTIONROLLER_GETCID()))
            frame:ShowWindow(0)

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            acutil.setupHook(OPTIONROLLER_ITEM_RANDOMRESET_REG_TARGETITEM, 'ITEM_RANDOMRESET_REG_TARGETITEM')
            acutil.setupHook(OPTIONROLLER_ITEMRANDOMRESET_OPEN, 'ITEMRANDOMRESET_OPEN')
            acutil.setupHook(OPTIONROLLER_ITEMRANDOMRESET_CLOSE, 'ITEMRANDOMRESET_CLOSE')
            acutil.setupHook(OPTIONROLLER_CLEAR_ITEMRANDOMRESET_UI, 'CLEAR_ITEMRANDOMRESET_UI')
            addon:RegisterMsg('MSG_SUCCESS_RESET_RANDOM_OPTION', 'OPTIONROLLER_SUCCESS_RESET_RANDOM_OPTION')

            frame:ShowWindow(0)
            --OPTIONROLLER_INITFRAME(frame)
            OPTIONROLLER_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OPTIONROLLER_ITEMRANDOMRESET_OPEN(frame)
    EBI_try_catch {
        try = function()
            ITEMRANDOMRESET_OPEN_OLD(frame)
            local frame = ui.GetFrame('itemrandomreset')
            local btn = frame:CreateOrGetControl('button', 'btnactivate', 20, 100, 120, 30)
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, 'OPTIONROLLER_TOGGLEFRAME')
            btn:SetText('{ol}Auto Reroll')
            btn:SetEnable(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OPTIONROLLER_CLEAR_ITEMRANDOMRESET_UI()
    CLEAR_ITEMRANDOMRESET_UI_OLD()
    local frame = ui.GetFrame('itemrandomreset')
    local btn = frame:GetChild('btnactivate')
    if btn then
        AUTO_CAST(btn)

        btn:SetEnable(0)
        
    end
    g.frame:ShowWindow(0)
end

function OPTIONROLLER_ITEMRANDOMRESET_CLOSE(frame)
    ITEMRANDOMRESET_CLOSE_OLD(frame)
    local frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function OPTIONROLLER_ITEM_RANDOMRESET_REG_TARGETITEM(frame, itemID)
    ITEM_RANDOMRESET_REG_TARGETITEM_OLD(frame, itemID)
    if ui.CheckHoldedUI() == true then
        return
    end
    local invItem = session.GetInvItemByGuid(itemID)
    if invItem == nil then
        return
    end

    local item = GetIES(invItem:GetObject())
    local itemCls = GetClassByType('Item', item.ClassID)

    if itemCls.NeedRandomOption ~= 1 then
        ui.SysMsg(ClMsg('NotAllowedRandomReset'))
        return
    end

    local pc = GetMyPCObject()
    if pc == nil then
        return
    end

    local obj = GetIES(invItem:GetObject())
    if IS_NEED_APPRAISED_ITEM(obj) == true or IS_NEED_RANDOM_OPTION_ITEM(obj) == true then
        ui.SysMsg(ClMsg('NeedAppraisd'))
        return
    end

    local invframe = ui.GetFrame('inventory')
    if true == invItem.isLockState or true == IS_TEMP_LOCK(invframe, invItem) then
        ui.SysMsg(ClMsg('MaterialItemIsLock'))
        return
    end
    local iframe = ui.GetFrame('itemrandomreset')
    local btn = iframe:GetChild('btnactivate')
    AUTO_CAST(btn)

    btn:SetEnable(1)
    OPTIONROLLER_ACTIVATE(invItem)
end
function OPTIONROLLER_ACTIVATE(invItem)
    EBI_try_catch {
        try = function()
            local frame = g.frame

            OPTIONROLLER_INITFRAME(frame, invItem)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function OPTIONROLLER_TOGGLEFRAME()
    ui.ToggleFrame(g.framename)
    local frame = ui.GetFrame(g.framename)
end
function OPTIONROLLER_INITFRAME(frame, invItem)
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            frame:EnableMove(0)
            frame:SetOffset(450, 300)
            frame:Resize(300, 450)
            local gbox = frame:CreateOrGetControl('groupbox', 'gbox', 10, 100, frame:GetWidth() - 20, 300)
            AUTO_CAST(gbox)
            gbox:RemoveAllChild()

            local obj = GetIES(invItem:GetObject())

            local groupCount = {
                ['ItemRandomOptionGroupATK'] = 0,
                ['ItemRandomOptionGroupDEF'] = 0,
                ['ItemRandomOptionGroupUTIL'] = 0,
                ['ItemRandomOptionGroupSTAT'] = 0
            }

            for i = 1, MAX_RANDOM_OPTION_COUNT do
                local propGroupName = 'RandomOptionGroup_' .. i
                local propName = 'RandomOption_' .. i
                local propValue = 'RandomOptionValue_' .. i
                local clientMessage = 'None'

                if obj[propGroupName] == 'ATK' then
                    clientMessage = 'ItemRandomOptionGroupATK'
                elseif obj[propGroupName] == 'DEF' then
                    clientMessage = 'ItemRandomOptionGroupDEF'
                elseif obj[propGroupName] == 'UTIL_WEAPON' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif obj[propGroupName] == 'UTIL_ARMOR' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif obj[propGroupName] == 'UTIL_SHILED' then
                    clientMessage = 'ItemRandomOptionGroupUTIL'
                elseif obj[propGroupName] == 'STAT' then
                    clientMessage = 'ItemRandomOptionGroupSTAT'
                end
                if obj[propValue] ~= 0 and obj[propName] ~= 'None' then
                    groupCount[clientMessage] = groupCount[clientMessage] + 1
                end
            end
            g.groupCount = groupCount
            local counttext = frame:CreateOrGetControl('richtext', 'txtcount', 20, 50, 200, 30)
            local txt = '{s20}{ol}Props:'
            for k, v in pairs(groupCount) do
                txt = txt .. ClMsg(k) .. ' ' .. v .. ' '
            end
            counttext:SetText(txt)
            local idx = 0
            for k, v in pairs(groupCount) do
                for i = 1, v do
                    local txt = gbox:CreateOrGetControl('richtext', 'txtcat' .. idx, 20, 10 + idx * 30, 50, 30)

                    txt:SetText('{ol}' .. ClMsg(k))
                    local droplist = gbox:CreateOrGetControl('droplist', 'droplist' .. idx, 50, 10 + idx * 30, 200, 30)
                    AUTO_CAST(droplist)
                    droplist:SetSkinName('droplist_normal')
                    droplist:AddItem(0, '{#777777}NoSelect')
                    for k, v in ipairs(OPTION_GROUP_PROP_LIST[k]) do
                        droplist:AddItem(k, '{ol}' .. ScpArgMsg(v))
                    end
                    idx = idx + 1
                end
            end
            local txtattempt = frame:CreateOrGetControl('richtext', 'txtattempt', 30, 325, 50, 30)
            txtattempt:SetText('{ol}Max Attempts:')
            local numattempts = frame:CreateOrGetControl('numupdown', 'numattempt', 150, 320, 80, 30)
            AUTO_CAST(numattempts)

            numattempts:MakeButtons('btn_numdown', 'btn_numup', 'editbox_s')
            numattempts:SetMinValue(1)
            numattempts:SetMaxValue(1000)
            numattempts:SetNumberValue(100)

            numattempts:SetIncrValue(10)
            numattempts:Invalidate()
            local btngo = frame:CreateOrGetControl('button', 'btngo', 0, 30, 100, 40)
            btngo:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            btngo:SetOffset(0, 20)
            btngo:SetSkinName('base_btn')
            btngo:SetText('{ol}EXECUTE')
            btngo:SetEventScript(ui.LBUTTONUP, 'OPTIONROLLER_CONFIRM')

            g.invItem = invItem
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OPTIONROLLER_CONFIRM()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame(g.framename)
            local gbox = frame:GetChild('gbox')
            AUTO_CAST(gbox)
            local invItem = g.invItem
            local obj = GetIES(invItem:GetObject())
            local needs = {}
            local groupCount = g.groupCount
            local idx = 0
            local txt = '{ol}'
            local dup = {}
            g.invItemIESID= invItem:GetIESID()
            g.needscount = 0
            for k, v in pairs(groupCount) do
                needs[k] = {}
                for i = 1, v do
                    local droplist = gbox:GetChild('droplist' .. idx)
                    AUTO_CAST(droplist)
                    local selidx = droplist:GetSelItemIndex()
                    if selidx ~= 0 then
                        g.needscount = g.needscount + 1
                        if dup[OPTION_GROUP_PROP_LIST[k][selidx]] then
                            ui.SysMsg('Duplicate option found.')
                            return
                        else
                            dup[OPTION_GROUP_PROP_LIST[k][selidx]] = true
                        end

                        needs[k][#needs[k] + 1] = OPTION_GROUP_PROP_LIST[k][selidx]
                        txt = txt .. ClMsg(k) .. '{#FFFFFF}' .. ScpArgMsg(OPTION_GROUP_PROP_LIST[k][selidx]) .. '{/}{nl}'
                    else
                        txt = txt .. ClMsg(k) .. '{#777777}No Select{/}' .. '{nl}'
                    end
                    idx = idx + 1
                end
            end

            local list, cnt = GetClassList('item_random_reset_material')
            local itemRandomResetMaterial = nil

            for i = 0, cnt - 1 do
                local cls = GetClassByIndexFromList(list, i)
                if cls == nil then
                    return
                end

                if obj.ClassType == cls.ItemType and obj.ItemGrade == cls.ItemGrade then
                    itemRandomResetMaterial = cls
                end
            end
            local isAbleExchange = 1
            if obj.MaxDur <= MAXDUR_DECREASE_POINT_PER_RANDOM_RESET or obj.Dur <= MAXDUR_DECREASE_POINT_PER_RANDOM_RESET then
                isAbleExchange = -2
            end
            local nucle = 0
            local sierra = 0
            local materialItemSlot = itemRandomResetMaterial.MaterialItemSlot
            for i = 1, materialItemSlot do
                local materialItemIndex = 'MaterialItem_' .. i
                local materialCls = GetClass('Item', itemRandomResetMaterial[materialItemIndex])
                local materialItemCount = 0
                local materialCountScp = itemRandomResetMaterial[materialItemIndex .. '_SCP']
                if materialCountScp ~= 'None' then
                    materialCountScp = _G[materialCountScp]
                    materialItemCount = materialCountScp(obj)
                else
                    ui.SysMsg('Invalid State.')
                end

                if materialItemCount == 0 then
                    break
                end
                local clsid = materialCls.ClassID
                if (clsid == 649026) then
                    sierra = sierra + materialItemCount
                elseif (clsid == 649025) then
                    nucle = nucle + materialItemCount
                end
            end
            g.needs = needs
            local numattempts = frame:GetChild('numattempt')
            AUTO_CAST(numattempts)
            local attempts = numattempts:GetNumber()
            nucle = nucle * attempts
            sierra = sierra * attempts
            g.attempts = attempts
            txt = txt .. '{#FFFFFF}'
            txt = txt .. 'Max Attempts:' .. attempts .. '{nl}'

            if IsBuffApplied(pc, 'Event_Reappraisal_Discount_50') == 'YES' then
                txt = txt .. 'Max Req Powders(DISCOUNT):{img icon_item_breakpowder_1 20 20}' .. nucle .. ' {img icon_item_breakpowder_2 20 20}' .. sierra .. '{nl}'
            else
                txt = txt .. 'Max Req Powders:{img icon_item_breakpowder_1 20 20}' .. nucle .. ' {img icon_item_breakpowder_2 20 20}' .. sierra .. '{nl}'
            end
            txt = txt .. '{nl}Do you want to do auto reroll?'
            ui.MsgBox(txt, 'OPTIONROLLER_EXECUTE()', 'None')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function OPTIONROLLER_EXECUTE()
    g.go=true
    ui.SetEscapeScp('OPTIONROLLER_CANCEL()')
    OPTIONROLLER_DO_EXECUTE()
end
function OPTIONROLLER_DO_EXECUTE()
    EBI_try_catch {
        try = function()
            local invItem = g.invItem
            local ppc = GetMyPCObject();
            local obj = GetIES(invItem:GetObject())
            local list, cnt = GetClassList('item_random_reset_material')
            local itemRandomResetMaterial = nil

            for i = 0, cnt - 1 do
                local cls = GetClassByIndexFromList(list, i)
                if cls == nil then
                    return
                end

                if obj.ClassType == cls.ItemType and obj.ItemGrade == cls.ItemGrade then
                    itemRandomResetMaterial = cls
                end
            end
            local isAbleExchange = 1
            if obj.MaxDur <= MAXDUR_DECREASE_POINT_PER_RANDOM_RESET or obj.Dur <= MAXDUR_DECREASE_POINT_PER_RANDOM_RESET then
                isAbleExchange = -2
            end

            local materialItemSlot = itemRandomResetMaterial.MaterialItemSlot
            for i = 1, materialItemSlot do
                local materialItemIndex = 'MaterialItem_' .. i
                local materialCls = GetClass('Item', itemRandomResetMaterial[materialItemIndex])
                local materialItemCount = 0
                local materialCountScp = itemRandomResetMaterial[materialItemIndex .. '_SCP']
                if materialCountScp ~= 'None' then
                    materialCountScp = _G[materialCountScp]
                    materialItemCount = materialCountScp(obj)
                else
                    ui.SysMsg('Invalid State.')
                end

                if materialItemCount == 0 then
                    break
                end
                local clsid = materialCls.ClassID
                local itemCount = GetInvItemCount(ppc, materialCls.ClassName)
                if(itemCount<materialItemCount)then
                    ui.SysMsg('Insufficient ingredients.')
                    OPTIONROLLER_CANCEL()
                    return;
                end
                --session.AddItemID(materialCls.ClassID, materialItemCount);
	
            end
            pc.ReqExecuteTx_Item('RESET_RANDOM_OPTION_ITEM', g.invItemIESID)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function OPTIONROLLER_CANCEL()
    g.attempts = -1
    g.go=false
    ui.SysMsg('Cancelled.')
    ui.SetEscapeScp('')
end
function OPTIONROLLER_SUCCESS_RESET_RANDOM_OPTION()
    EBI_try_catch {
        try = function()
            if g.go==false then
                return
            end
            if g.attempts == 0 then
                ui.SysMsg('Max attempt has reached.')
                ui.SetEscapeScp('')
            elseif g.attempts > 0 then
                --条件を満たしているか調べる\
                local invItemGUID = g.invItem:GetIESID()
              
                local resetInvItem = session.GetInvItemByGuid(invItemGUID)
                if resetInvItem == nil then
                    resetInvItem = session.GetEquipItemByGuid(invItemGUID)
                end
                local obj = GetIES(resetInvItem:GetObject())
                local count = 0
                for i = 1, MAX_RANDOM_OPTION_COUNT do
                    local propGroupName = 'RandomOptionGroup_' .. i
                    local propName = 'RandomOption_' .. i
                    local propValue = 'RandomOptionValue_' .. i
                    local clientMessage = 'None'

                    if obj[propGroupName] == 'ATK' then
                        clientMessage = 'ItemRandomOptionGroupATK'
                    elseif obj[propGroupName] == 'DEF' then
                        clientMessage = 'ItemRandomOptionGroupDEF'
                    elseif obj[propGroupName] == 'UTIL_WEAPON' then
                        clientMessage = 'ItemRandomOptionGroupUTIL'
                    elseif obj[propGroupName] == 'UTIL_ARMOR' then
                        clientMessage = 'ItemRandomOptionGroupUTIL'
                    elseif obj[propGroupName] == 'UTIL_SHILED' then
                        clientMessage = 'ItemRandomOptionGroupUTIL'
                    elseif obj[propGroupName] == 'STAT' then
                        clientMessage = 'ItemRandomOptionGroupSTAT'
                    end

                    if obj[propValue] ~= 0 and obj[propName] ~= 'None' then
                        local opName = string.format('%s %s', ClMsg(clientMessage), ScpArgMsg(obj[propName]))
                        for k, v in ipairs(g.needs[clientMessage]) do
                            if v == obj[propName] then
                                count = count + 1
                            end
                        end
                    end
                end
                if count >= g.needscount then
                    ui.SysMsg('Complete')
                    g.attempts = -1
                else
                    ui.SysMsg('Remain Attempt:' .. g.attempts)
                    g.attempts = g.attempts - 1
                    -- いくらでも早くできるが、まぁ
                    ReserveScript('OPTIONROLLER_DO_EXECUTE()', 1.5)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
