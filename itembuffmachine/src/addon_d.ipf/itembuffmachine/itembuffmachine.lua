--ITEMBUFFMACHINE
local addonName = 'ITEMBUFFMACHINE'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local contributor = 'Kiicchan'

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
        y = 300,
        style = 0
    }
g.configurepattern = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'itembuffmachine'
g.debug = false

g.addon = g.addon
g.items={}
g.itemcursor=1
g.issquire=false
g.working=false
g.squirewaitfornext=false
g.enchantname=nil
--ライブラリ読み込み
CHAT_SYSTEM('[IBM]loaded')
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
function ITEMBUFFMACHINE_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            if not g.loaded then
                g.loaded = true
            end
            --if(g.debug)then
            acutil.setupHook(ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN, 'ENCHANTAROR_STORE_OPEN')
            --end
            local timer = frame:GetChild('addontimer')
            AUTO_CAST(timer)
            --timer:SetUpdateScript("ITEMBUFFMACHINE_CHECK")
            --timer:Start(1)
            --acutil.setupHook(ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN, 'ENCHANTAROR_STORE_OPEN')
            acutil.setupHook(ITEMBUFFMACHINE_SQUIRE_ITEM_SUCCEED, 'SQUIRE_ITEM_SUCCEED')
            addon:RegisterMsg('INV_ITEM_ADD', 'ITEMBUFFMACHINE_ITEM_ADD')
            --addon:RegisterMsg('INV_ITEM_REMOVE', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            --addon:RegisterOpenOnlyMsg('INV_ITEM_LIST_GET', 'ITEMBUFFMACHINE_ITEM_LIST');
            --addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            addon:RegisterMsg('EQUIP_ITEM_LIST_UPDATE', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            addon:RegisterMsg('GAME_START_3SEC', 'ITEMBUFFMACHINE_ITEMBUFFOPEN_INIT')
            addon:RegisterMsg('FPS_UPDATE', 'ITEMBUFFMACHINE_FPS_UPDATE')
            g.squirewaitfornext=false
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_FPS_UPDATE()
    local frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
--  enchant armor
function ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN(groupName, sellType, handle)
    EBI_try_catch {
        try = function()
            ENCHANTAROR_STORE_OPEN_OLD(groupName, sellType, handle)
            local frame = ui.GetFrame('enchantarmoropen')
            local btn = frame:CreateOrGetControl('button', 'ibmbuff', 20, 70, 100, 30)
            btn:SetText('{ol}Auto Buff')
            btn:SetEventScript(ui.LBUTTONUP, 'ITEMBUFFMACHINE_ENCHANTARMOR_ONBUTTON')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFFOPEN_INIT()
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame('itembuffopen')
            local btn = frame:CreateOrGetControl('button', 'ibmbuff', 20, 70, 100, 30)
            btn:SetText('{ol}Auto Buff')
            btn:SetEventScript(ui.LBUTTONUP, 'ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON')
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, 1);

            local btn = frame:CreateOrGetControl('button', 'ibmbuffweapon', 130, 70, 100, 30)
            btn:SetText('{ol}Weapon Only')
            btn:SetEventScript(ui.LBUTTONUP, 'ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON')
            btn:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON(frame, control, argStr, isAll)
    EBI_try_catch {
        try = function()
            local equiplist = session.GetEquipItemList()
            local price = 0
            local frame = ui.GetFrame('itembuffopen')
            local pc = GetMyPCObject()
            local imoney = frame:GetUserIValue('PRICE')
            local totalcnt = 0
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local tempobj = equipItem:GetObject()
                if tempobj ~= nil then
                    local obj = GetIES(tempobj)
                    if (item.IsNoneItem(obj.ClassID) == 0 and ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(obj, isAll) == 1) then
                        local checkFunc = _G['ITEMBUFF_NEEDITEM_' .. frame:GetUserValue('SKILLNAME')]
                        local name, cnt = checkFunc(pc, obj)
                        totalcnt = totalcnt + cnt
                    end
                end
            end
            local price = totalcnt * imoney
            if price == 0 then
                ui.SysMsg('適用できる装備がありません')
                return
            else
                ui.MsgBox('全装備にメンテナンスを適用しますか？{nl}{#FFFF00}{ol}費用:' .. tostring(price), string.format('ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT(%d)', isAll), 'None')
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANTARMOR_ONBUTTON(frame)
    EBI_try_catch {
        try = function()
            local aframe = ui.GetFrame('enchantarmoropen')
            local groupName = aframe:GetUserValue('GroupName')
            DBGOUT('HOGE')
            local context = ui.CreateContextMenu('CONTEXT_ITEMBUFFMACHINE_ENCHANT', '適用するバフを選択', 0, 0, 200, 200)
            ui.AddContextMenuItem(context, 'キャンセル', 'None')
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)
            for i = 1, #optionList do
                local msg = ScpArgMsg(optionList[i])
                ui.AddContextMenuItem(
                    context,
                    '「' .. msg .. '」' .. ScpArgMsg(optionList[i] .. '_DESC'),
                    string.format('ITEMBUFFMACHINE_ENCHANTARMOR_SELECT("%s",%d)', groupName, i)
                )
            end
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(item)
    if item.GroupName == 'Armor' then
        if item.ClassType == 'Shield' or item.ClassType == 'Shirt' or item.ClassType == 'Pants' then
            return 1
        end
        return 0
    end
    return 0
end
function ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(item, isAll)
    if item.GroupName == 'Weapon' then
        return 1
    end

    if item.GroupName == 'SubWeapon' and CHECK_ITEM_BASIC_TOOLTIP_PROP_EXIST(item, 'ATK') then
        return 1
    end

    if item.GroupName == 'Armor' and isAll == 1 then
        if item.ClassType == 'Shield' or item.ClassType == 'Shirt' or item.ClassType == 'Pants' or item.ClassType == 'Gloves' or item.ClassType == 'Boots' then
            return 1
        end
    end

    return 0
end
function ITEMBUFFMACHINE_ITEM_ADD()
    ReserveScript('ITEMBUFFMACHINE_CHECK()',0.2)
end
function ITEMBUFFMACHINE_ITEM_LIST()
    ITEMBUFFMACHINE_CHECK()
end
function ITEMBUFFMACHINE_ENCHANTARMOR_SELECT(groupName, index)
    EBI_try_catch {
        try = function()
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local groupInfo = session.autoSeller.GetByIndex(groupName, 0)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)
            local equiplist = session.GetEquipItemList()
            local price = 0
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local tempobj = equipItem:GetObject()
                if tempobj ~= nil then
                    local obj = GetIES(tempobj)
                    if (item.IsNoneItem(obj.ClassID) == 0 and ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(obj) == 1) then
                        price = price + groupInfo.price
                    end
                end
            end
            if price == 0 then
                ui.SysMsg('適用できる装備がありません')
                return
            else
                local msg = ScpArgMsg(optionList[index])
                ui.MsgBox(
                    '「' .. msg .. '」' .. ScpArgMsg(optionList[index] .. '_DESC') .. '{nl} を適用しますか？{nl}{#FFFF00}{ol}費用:' .. tostring(price),
                    string.format('ITEMBUFFMACHINE_ENCHANTARMOR_DO_SELECT(%d)', index),
                    'None'
                )
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end
function ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT(isAll)
    g.items={}
    local equiplist = session.GetEquipItemList()
    for i = 0, equiplist:Count() - 1 do
        local equipItem = equiplist:GetEquipItemByIndex(i)
        local spotName = item.GetEquipSpotName(equipItem.equipSpot)
        if spotName ~= nil then
            local tempobj = equipItem:GetObject()
            if tempobj ~= nil then
                local obj = GetIES(tempobj)
                local fn=ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp

                
                if (item.IsNoneItem(obj.ClassID) == 0 and fn(obj, isAll) == 1) then
                   g.items[#g.items+1] = equipItem:GetIESID()
                end
            end
        end
    end
    g.itemcursor=1
    g.squirewaitfornext=false
    g.working=true
    ui.SetEscapeScp("ITEMBUFFMACHINE_CANCEL()")
    ITEMBUFFMACHINE_UNWEAR(1)
end
function ITEMBUFFMACHINE_ENCHANTARMOR_DO_SELECT(index)
    g.items={}
    g.itemcursor=1
    local equiplist = session.GetEquipItemList()
    for i = 0, equiplist:Count() - 1 do
        local equipItem = equiplist:GetEquipItemByIndex(i)
        local spotName = item.GetEquipSpotName(equipItem.equipSpot)
        if spotName ~= nil then
            local tempobj = equipItem:GetObject()
            if tempobj ~= nil then
                local obj = GetIES(tempobj)
                local fn=ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor

                
                if (item.IsNoneItem(obj.ClassID) == 0 and fn(obj) == 1) then
                   g.items[#g.items+1] = equipItem:GetIESID()
                end
            end
        end
    end
    g.enchantname=index
    g.squirewaitfornext=false
    g.working=true
    ui.SetEscapeScp("ITEMBUFFMACHINE_CANCEL()")
    ITEMBUFFMACHINE_UNWEAR(0)
end



function ITEMBUFFMACHINE_UNWEAR(squire)
    EBI_try_catch {
        try = function()
            local equipItemIESID=g.items[g.itemcursor]
            local equipItem = session.GetEquipItemByGuid(equipItemIESID)


            local spot = equipItem.equipSpot
            item.UnEquip(spot)
            g.itemcursor=g.itemcursor+1
            if g.working then
                if g.itemcursor>#g.items then
                    g.itemcursor=1
                    if squire==1 then
                        ReserveScript('ITEMBUFFMACHINE_ITEMBUFF()',0.75)
                    else
                        ReserveScript('ITEMBUFFMACHINE_ENCHANT()',0.75)
                    end
                else
                    ReserveScript(string.format('ITEMBUFFMACHINE_UNWEAR(%d)',squire),0.75)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANT()
    EBI_try_catch {
        try = function()
            local equipItemIESID=g.items[g.itemcursor]
            local frame = ui.GetFrame('enchantarmoropen')
            local handle = frame:GetUserIValue('HANDLE')
            local skillName = frame:GetUserValue('GroupName')
            --local equipItem = nil
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)

            session.autoSeller.BuyEnchantBuff(handle, AUTO_SELL_ENCHANTERARMOR, optionList[g.enchantname], skillName, equipItemIESID)
            g.itemcursor=g.itemcursor+1
            if g.working then
                if g.itemcursor>#g.items then
                    g.itemcursor=1
    
                    ReserveScript('ITEMBUFFMACHINE_WEAR()',7)
                
                else
                    ReserveScript('ITEMBUFFMACHINE_ENCHANT()',7)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_SQUIRE_ITEM_SUCCEED()
    SQUIRE_ITEM_SUCCEED_OLD()
    if g.working then
        g.itemcursor=g.itemcursor+1
        if g.itemcursor>#g.items then
            g.itemcursor=1
            g.squirewaitfornext=false
            ReserveScript('ITEMBUFFMACHINE_WEAR()',1)
        
        else
            ReserveScript('ITEMBUFFMACHINE_ITEMBUFF()',1)
        end
    end
end
function ITEMBUFFMACHINE_ITEMBUFF()
    EBI_try_catch {
        try = function()
            local equipItemIESID=g.items[g.itemcursor]
            local frame = ui.GetFrame('itembuffopen')
            local skillName = frame:GetUserValue('SKILLNAME')
            local handle = frame:GetUserValue('HANDLE')
            local equipItem = nil
            equipItem = session.GetInvItemByGuid(equipItemIESID)


            session.autoSeller.BuySquireBuff(handle, AUTO_SELL_SQUIRE_BUFF, skillName, equipItemIESID)
            g.squirewaitfornext=true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_EQUIP_ITEM_LIST()
    ITEMBUFFMACHINE_CHECK()
end
function ITEMBUFFMACHINE_CANCEL(quiet)
    if not quiet then
        ui.SysMsg('Cancelled')
    end
    ui.SetEscapeScp('')
    g.working=false
end
function ITEMBUFFMACHINE_WEAR()
    EBI_try_catch {
        try = function()
            local equipItemIESID=g.items[g.itemcursor]
            local equipItem = session.GetInvItemByGuid(equipItemIESID)

            --local spname = item.GetEquipSpotName(equipSpot)
            ITEM_EQUIP_MSG(equipItem)
            if g.working then
                g.itemcursor=g.itemcursor+1
                if g.itemcursor>#g.items then
                    g.itemcursor=1
            
                    ReserveScript('ITEMBUFFMACHINE_CANCEL(true);ui.SysMsg("Completed")',0.75)
                
                else
                    ReserveScript('ITEMBUFFMACHINE_WEAR()',0.75)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

------------------------------------------------------------------------
