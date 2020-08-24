--ITEMBUFFMACHINE
local addonName = 'ITEMBUFFMACHINE'
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
        y = 300,
        style = 0
    }
g.configurepattern = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'itembuffmachine'
g.debug = false
g.retrylimit = 20
g.addon = g.addon
g.task = {}
g.checker = nil
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
            if(g.debug)then
                acutil.setupHook(ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN, 'ENCHANTAROR_STORE_OPEN')
            end
            --acutil.setupHook(ITEMBUFFMACHINE_ENCHANTAROR_STORE_OPEN, 'ENCHANTAROR_STORE_OPEN')
            acutil.setupHook(ITEMBUFFMACHINE_SQUIRE_ITEM_SUCCEED, 'SQUIRE_ITEM_SUCCEED')
            addon:RegisterMsg('INV_ITEM_ADD', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            addon:RegisterMsg('INV_ITEM_REMOVE', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            addon:RegisterMsg('EQUIP_ITEM_LIST_UPDATE', 'ITEMBUFFMACHINE_EQUIP_ITEM_LIST')
            addon:RegisterMsg('GAME_START_3SEC', 'ITEMBUFFMACHINE_ITEMBUFFOPEN_INIT')
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
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
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_ONBUTTON()
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
                    if (ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(obj) == 1) then
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
                ui.MsgBox('全装備にメンテナンスを適用しますか？{nl}{#FFFF00}{ol}費用:' .. tostring(price), string.format('ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT()'), 'None')
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
function ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(item)
    if item.GroupName == 'Weapon' then
        return 1
    end

    if item.GroupName == 'SubWeapon' and CHECK_ITEM_BASIC_TOOLTIP_PROP_EXIST(item, 'ATK') then
        return 1
    end

    if item.GroupName == 'Armor' then
        if item.ClassType == 'Shield' or item.ClassType == 'Shirt' or item.ClassType == 'Pants' or item.ClassType == 'Gloves' or item.ClassType == 'Boots' then
            return 1
        end
    end

    return 0
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
                    if (ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(obj) == 1) then
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
                    string.format('ITEMBUFFMACHINE_ENCHANTARMOR_DO_SELECT("%s",%d)', groupName, index),
                    'None'
                )
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ITEMBUFF_DO_SELECT()
    EBI_try_catch {
        try = function()
            ui.SetEscapeScp('ITEMBUFFMACHINE_CANCEL()')
            ui.SysMsg('開始します。キャンセルする場合はESCを押してください。')
            g.working = true
            g.task = {}
            --g.equipList={}

            local equiplist = session.GetEquipItemList()
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot);
		    	if  spotName  ~=  nil  then
                    local tempobj = equipItem:GetObject()
                    if tempobj ~= nil then
                        local obj = GetIES(tempobj)
                        if (  item.IsNoneItem(obj.ClassID)==0  and ITEMBUFFMACHINE_ITEMBUFF_CHECK_Squire_EquipmentTouchUp(obj) == 1) then
                            -- table.insert(g.equipList,{
                            --     item=equipItem,
                            --     obj=obj,
                            -- })
                            -- ITEMBUFFMACHINE_ADDTASK(
                            --     function()
                            --         ITEMBUFFMACHINE_UNWEAR(equipItem:GetIESID(), equipItem.equipSpot)
                            --     end
                            -- )

                            ITEMBUFFMACHINE_ADDTASK(
                                function()
                                    ITEMBUFFMACHINE_ITEMBUFF(equipItem:GetIESID())
                                end
                            )
                            -- ITEMBUFFMACHINE_ADDTASK(
                            --     function()
                            --         ITEMBUFFMACHINE_WEAR(equipItem:GetIESID(), equipItem.equipSpot)
                            --     end
                            -- )
                        end
                    end
                end
            end
            ITEMBUFFMACHINE_DOTASK()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANTARMOR_DO_SELECT(groupName, index)
    EBI_try_catch {
        try = function()
            ui.SetEscapeScp('ITEMBUFFMACHINE_CANCEL()')
            ui.SysMsg('開始します。キャンセルする場合はESCを押してください。')
            g.working = true
            g.task = {}
            --g.equipList={}
            local baseInfo = session.autoSeller.GetShopBaseInfo(AUTO_SELL_ENCHANTERARMOR)
            local optionList = GET_ENCHANTARMOR_OPTION(baseInfo.skillLevel)
            local equiplist = session.GetEquipItemList()
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot);
		    	if  spotName  ~=  nil  then
                    local tempobj = equipItem:GetObject()
                    if tempobj ~= nil then
                        local obj = GetIES(tempobj)
                        if ( item.IsNoneItem(obj.ClassID)==0  and  ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(obj) == 1) then
                            -- table.insert(g.equipList,{
                            --     item=equipItem,
                            --     obj=obj,
                            -- })
                            ITEMBUFFMACHINE_ADDTASK(
                                function()
                                    ITEMBUFFMACHINE_UNWEAR(equipItem:GetIESID(),equipItem, equipItem.equipSpot)
                                end
                            )

                            
                        end
                    end
                end
            end
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot);
		    	if  spotName  ~=  nil  then
                    local tempobj = equipItem:GetObject()
                    if tempobj ~= nil then
                        local obj = GetIES(tempobj)
                        if ( item.IsNoneItem(obj.ClassID)==0  and  ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(obj) == 1) then
                            -- table.insert(g.equipList,{
                            --     item=equipItem,
                            --     obj=obj,
                            -- })
                        

                            ITEMBUFFMACHINE_ADDTASK(
                                function()
                                    ITEMBUFFMACHINE_ENCHANT(equipItem:GetIESID(), optionList[index])
                                end
                            )
                          
                        end
                    end
                end
            end
            for i = 0, equiplist:Count() - 1 do
                local equipItem = equiplist:GetEquipItemByIndex(i)
                local spotName = item.GetEquipSpotName(equipItem.equipSpot);
		    	if  spotName  ~=  nil  then
                    local tempobj = equipItem:GetObject()
                    if tempobj ~= nil then
                        local obj = GetIES(tempobj)
                        if ( item.IsNoneItem(obj.ClassID)==0  and  ITEMBUFFMACHINE_ITEMBUFF_CHECK_Enchanter_EnchantArmor(obj) == 1) then
                            -- table.insert(g.equipList,{
                            --     item=equipItem,
                            --     obj=obj,
                            -- })
                        

                            ITEMBUFFMACHINE_ADDTASK(
                                function()
                                    ITEMBUFFMACHINE_WEAR(equipItem:GetIESID(),equipItem,equipItem.equipSpot)
                                end
                            )
                          
                        end
                    end
                end
            end
            ITEMBUFFMACHINE_DOTASK()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_CANCEL()
    g.task = {}
    g.working = false
    ui.SysMsg('キャンセルしました')
end
function ITEMBUFFMACHINE_ADDTASK(task)
    table.insert(g.task, task)
end
function ITEMBUFFMACHINE_DOTASK()
    EBI_try_catch {
        try = function()
            g.checker = nil
            if g.working == false then
            else
                if #g.task > 0 then
                    local top = table.remove(g.task, 1)
                    top()
                    DBGOUT("TOP")
                else
                    g.working = false
                    ui.SetEscapeScp('')
                    ui.SysMsg('おわりました')
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ITEMBUFFMACHINE_UNWEAR(equipItemIESID, invItem,equipSpot, attempt)
    EBI_try_catch {
        try = function()
            --session.ResetItemList()
            --imcAddOn.BroadMsg("EQUIP_ITEM_LIST_GET")
            --local equipItem = nil --session.GetEquipItemByGuid(equipItemIESID)
            local equipItem=nil
            local equiplist = session.GetEquipItemList()
            for i = 0, equiplist:Count() - 1 do
                local im = equiplist:GetEquipItemByIndex(i)
                local tempobj = im:GetObject()
                if tempobj ~= nil then
                    local obj = GetIES(tempobj)
                    if(im:GetIESID()==equipItemIESID) then
                        equipItem=im
                        break
                    end
                end
            end
            if equipItem==nil then
                attempt=attempt or 0
                attempt=attempt+1
                if attempt<g.retrylimit then
                    ReserveScript(string.format('ITEMBUFFMACHINE_UNWEAR("%s",%d,%d)',equipItemIESID,equipSpot,attempt),0.5)
                else
                    ui.SysMsg("問題が発生したのでキャンセルします：試行回数上限")
                    ITEMBUFFMACHINE_CANCEL()
                end
                return
            end
            
            --local equipItem = GET_PC_ITEM_BY_GUID(equipItemIESID) --session.GetInvItemByGuid(equipItemIESID)
   
            --imcSound.PlaySoundEvent('inven_unequip')
            local spot = equipItem.equipSpot
            item.UnEquip(spot)
            --ITEM_EQUIP_MSG(item.GetNoneItem(equipItem.equipSpot),equipItem,equipSpot)
            ReserveScript('ITEMBUFFMACHINE_DOTASK()', 1)
            g.checker = function()
                DBGOUT('CHK UNWEAR' .. tostring(session.GetInvItemByGuid(equipItemIESID)))
                return session.GetInvItemByGuid(equipItemIESID)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_ENCHANT(equipItemIESID, indexName, attempt)
    EBI_try_catch {
        try = function()
            imcAddOn.BroadMsg("INV_ITEM_LIST_GET")
            local frame = ui.GetFrame('enchantarmoropen')
            local handle = frame:GetUserIValue('HANDLE')
            local skillName = frame:GetUserValue('GroupName')
            --local equipItem = nil
            local equipItem = nil
            session.BuildInvItemSortedList();
            local invItemList = session.GetInvItemSortedList();
            local invItemCount = invItemList:size();

            for i = 0, invItemCount - 1 do
                local invItem = invItemList:at(i);

                if invItem ~= nil then
                    if equipItem==nil and invItem:GetIESID()==equipItemIESID then
                        equipItem=invItem

                    end
                end
            
                
            end


            if equipItem == nil then
                attempt = attempt or 0
                attempt = attempt + 1

                if attempt < g.retrylimit then
                    ReserveScript(string.format('ITEMBUFFMACHINE_ENCHANT("%s","%s",%d)', equipItemIESID, indexName, attempt), 0.5)
                else
                    ui.SysMsg('問題が発生したのでキャンセルします：試行回数上限')
                    ITEMBUFFMACHINE_CANCEL()
                end
                return
            end
            session.autoSeller.BuyEnchantBuff(handle, AUTO_SELL_ENCHANTERARMOR, indexName, skillName, equipItemIESID)
            DBGOUT('ENCHANT:' .. equipItemIESID)
            ReserveScript('ITEMBUFFMACHINE_DOTASK()', 7)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_SQUIRE_ITEM_SUCCEED()
    SQUIRE_ITEM_SUCCEED_OLD()
    if g.working then
        ReserveScript('ITEMBUFFMACHINE_DOTASK()', 1)
    end
end
function ITEMBUFFMACHINE_ITEMBUFF(equipItemIESID, attempt)
    EBI_try_catch {
        try = function()
            --imcAddOn.BroadMsg("INV_ITEM_LIST_GET")
            local frame = ui.GetFrame('itembuffopen')
            local skillName = frame:GetUserValue('SKILLNAME')
            local handle = frame:GetUserValue('HANDLE')
            local equipItem = nil
           --session.ResetItemList()
            -- local invItemList = session.GetInvItemSortedList();
            -- FOR_EACH_INVENTORY(invItemList,
            --     function(invItemList, invItem)
            --         if invItem ~= nil then
            --             if equipItem==nil and invItem:GetIESID()==equipItemIESID then
            --                 equipItem=invItem

            --             end
            --         end
            --     end
            -- )

            -- if equipItem==nil then
            --     attempt=attempt or 0
            --     attempt=attempt+1

            --     if attempt<g.retrylimit then
            --         ReserveScript(string.format('ITEMBUFFMACHINE_ITEMBUFF("%s",%d)',equipItemIESID,attempt),0.5)

            --     else
            --         ui.SysMsg("問題が発生したのでキャンセルします：試行回数上限")
            --         ITEMBUFFMACHINE_CANCEL()
            --     end
            --     return

            -- end
            session.autoSeller.BuySquireBuff(handle, AUTO_SELL_SQUIRE_BUFF, skillName, equipItemIESID)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ITEMBUFFMACHINE_EQUIP_ITEM_LIST()
    -- if(g.working)then
    --     DBGOUT("HOHGO")
    --     if g.checker and g.checker() then
    --         ReserveScript('ITEMBUFFMACHINE_DOTASK()',2)
    --         g.checker=nil
    --     end
    -- end
end
function ITEMBUFFMACHINE_WEAR(equipItemIESID, invItem, attempt)
    EBI_try_catch {
        try = function()
            local equipItem = session.GetInvItemByGuid(equipItemIESID)
            imcAddOn.BroadMsg("INV_ITEM_LIST_GET")
            --local equipItem=nil

            -- local idx=0
            -- while true do

            --     local invItem = session.GetInvItem(idx);

            --     if invItem ~= nil then
            --         if equipItem==nil and invItem:GetIESID()==equipItemIESID then
            --             equipItem=invItem

            --         end
            --     else
            --         break
            --     end
            
            --     idx=idx+1
                
            -- end

            -- if equipItem == nil then
            --     attempt = attempt or 0
            --     attempt = attempt + 1

            --     if attempt < g.retrylimit then
            --         ReserveScript(string.format('ITEMBUFFMACHINE_WEAR("%s","%s",%d)', equipItemIESID, equipSpot, attempt), 0.5)
            --     else
            --         ui.SysMsg('問題が発生したのでキャンセルします：試行回数上限')
            --         ITEMBUFFMACHINE_CANCEL()
            --     end
            --     return
            -- end
            --local spname = item.GetEquipSpotName(equipSpot)
            ITEM_EQUIP_MSG(equipItem)
            ReserveScript('ITEMBUFFMACHINE_DOTASK()', 1)
            
            g.checker = function()
                DBGOUT('CHK WEAR' .. tostring(session.GetEquipItemByGuid(equipItemIESID)))
                return session.GetEquipItemByGuid(equipItemIESID)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

------------------------------------------------------------------------
