-- rppotion
local addonName = "RPPOTION"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")

g.version = 1
g.settings = g.settings or {}
g.framename = "rppotion"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[RPP]loaded")
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
local function AUTO_CAST(ctrl)
    if (ctrl == nil) then
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
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

function RPPOTION_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg("GAME_START_3SEC", "RPPOTION_3SEC")

            g.frame:ShowWindow(1)
            --RPPOTION_3SEC()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
local function RPPOTION_HOOK(hookstr)
    local new = "RPPOTION_" .. hookstr
    local old = "RPPOTION_OLD_" .. hookstr
    local replace = hookstr
    --if (_G[old] == nil) or (_G[new] ~= _G[replace]) then
    if (_G[old] == nil) then
        -- other addon detected
        local hookold = hookstr .. "_OLD"
        local oldhook = "OLD_"..hookstr 
        local hookolderd = 'EBIREMOVEDIALOG_'..hookstr .. "_OLD"
        if(_G[hookold]~=nil)then
            _G[old]=_G[hookold]
            _G[hookold]=_G[new]
        elseif(_G[oldhook]~=nil)then
            _G[old]=_G[oldhook]
            _G[oldhook]=_G[new]
        elseif(_G[hookolderd]~=nil)then
            _G[old]=_G[hookolderd]
            _G[hookolderd]=_G[new]
        else
            _G[old] = _G[replace]
            if (_G[new] ~= _G[replace]) then
                _G[replace] = _G[new]
            end
        end
        
    else
      
    end

    --end
end

function RPPOTION_3SEC()
    EBI_try_catch {
        try = function()
            --if g.hooked then
            --    return
            --end
            RPPOTION_HOOK("ICON_USE")
            RPPOTION_HOOK("JOYSTICK_QUICKSLOT_ON_DROP")
            RPPOTION_HOOK("QUICKSLOTNEXPBAR_ON_DROP")
            RPPOTION_HOOK("INV_ICON_USE")
            RPPOTION_HOOK("INVENTORY_RBDC_ITEMUSE")
            g.hooked = true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function RPPOTION_JOYSTICK_QUICKSLOT_ON_DROP(frame, control, argStr, argNum)
    local liftIcon = ui.GetLiftIcon()
    local liftIconiconInfo = liftIcon:GetInfo()
    local iconParentFrame = liftIcon:GetTopParentFrame()
    local slot = tolua.cast(control, "ui::CSlot")
    slot:SetEventScript(ui.RBUTTONUP, "QUICKSLOTNEXPBAR_SLOT_USE")
    local iconCategory = 0
    local iconType = 0
    local iconGUID = ""
    if nil ~= liftIconiconInfo then
        iconCategory = liftIconiconInfo:GetCategory()
        iconType = liftIconiconInfo.type
        iconGUID = liftIconiconInfo:GetIESID()
        if iconGUID ~= "0" then
            local invItem = GET_PC_ITEM_BY_GUID(iconGUID)
            if invItem ~= nil then
                local obj = GetIES(invItem:GetObject())
                if obj ~= nil then
                    local mat_class_name = TryGetProp(obj, "ClassName", "None")
                    local name_list = shared_item_relic.get_rp_material_name_list()
                    local mat_index = table.find(name_list, mat_class_name)
                    if mat_index <= 0 then
                        return RPPOTION_OLD_JOYSTICK_QUICKSLOT_ON_DROP(frame, control, argStr, argNum)
                    end
                    if iconParentFrame:GetName() == "joystickquickslot" then
                        -- NOTE : 퀵슬롯으로 부터 팝된 아이콘인 경우 기존 아이콘과 교환 합니다.
                        local popSlotObj = liftIcon:GetParent()
                        if popSlotObj:GetName() ~= slot:GetName() then
                            local popSlot = tolua.cast(popSlotObj, "ui::CSlot")
                            local oldIcon = slot:GetIcon()
                            if oldIcon ~= nil then
                                local iconInfo = oldIcon:GetInfo()
                                if iconInfo:GetImageName() == "None" then
                                    oldIcon = nil
                                end
                            end
                            QUICKSLOTNEXPBAR_SETICON(popSlot, oldIcon, 1, false)
                            local quickslotFrame = ui.GetFrame("quickslotnexpbar")
                            QUICKSLOT_REGISTER(quickslotFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                        end
                    elseif iconParentFrame:GetName() == "status" then
                        STATUS_EQUIP_SLOT_SET(iconParentFrame)
                        return
                    elseif iconParentFrame:GetName() == "skillability" then
                        local quickslotFrame = ui.GetFrame("quickslotnexpbar")
                        QUICKSLOT_REGISTER(quickslotFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                    else
                        local quickslotFrame = ui.GetFrame("quickslotnexpbar")
                        QUICKSLOT_REGISTER(quickslotFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                    end

                    --새거 등록
                    QUICKSLOTNEXPBAR_NEW_SETICON(frame, slot, iconCategory, iconType, iconGUID)
                    DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1)
                    return
                end
            end
        end
    end
    return RPPOTION_OLD_JOYSTICK_QUICKSLOT_ON_DROP(frame, control, argStr, argNum)
end

function RPPOTION_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)
    local liftIcon = ui.GetLiftIcon()
    local liftIconiconInfo = liftIcon:GetInfo()
    local iconParentFrame = liftIcon:GetTopParentFrame()
    local slot = tolua.cast(control, "ui::CSlot")
    slot:SetEventScript(ui.RBUTTONUP, "QUICKSLOTNEXPBAR_SLOT_USE")
    local iconCategory = 0
    local iconType = 0
    local iconGUID = ""
    if nil ~= liftIconiconInfo then
        iconCategory = liftIconiconInfo:GetCategory()
        iconType = liftIconiconInfo.type
        iconGUID = liftIconiconInfo:GetIESID()
        if iconGUID ~= "0" then
            local invItem = GET_PC_ITEM_BY_GUID(iconGUID)
            if invItem ~= nil then
                local obj = GetIES(invItem:GetObject())
                if obj ~= nil then
                    local mat_class_name = TryGetProp(obj, "ClassName", "None")
                    local name_list = shared_item_relic.get_rp_material_name_list()
                    local mat_index = table.find(name_list, mat_class_name)
                    if mat_index <= 0 then
                        return RPPOTION_OLD_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)
                    end
                    if iconParentFrame:GetName() == "quickslotnexpbar" then
                        local popSlotObj = liftIcon:GetParent()
                        if popSlotObj:GetName() ~= slot:GetName() then
                            local popSlot = tolua.cast(popSlotObj, "ui::CSlot")
                            local oldIcon = slot:GetIcon()
                            if oldIcon ~= nil then
                                local iconInfo = oldIcon:GetInfo()
                                if iconInfo:GetImageName() == "None" then
                                    oldIcon = nil
                                end
                            end
                            local sklCnt = frame:GetUserIValue("SKL_MAX_CNT")
                            if sklCnt > 0 and sklCnt >= slot:GetSlotIndex() then
                                return
                            end
                            --옛날거 등록
                            QUICKSLOTNEXPBAR_SETICON(popSlot, oldIcon, 1, false)
                            local joystickFrame = ui.GetFrame("joystickquickslot")
                            QUICKSLOT_REGISTER(joystickFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                        end
                    elseif iconParentFrame:GetName() == "status" then
                        STATUS_EQUIP_SLOT_SET(iconParentFrame)
                        return
                    elseif iconParentFrame:GetName() == "skillability" then
                        local joystickFrame = ui.GetFrame("joystickquickslot")
                        QUICKSLOT_REGISTER(joystickFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                    elseif iconParentFrame:GetName() == "companionlist" then
                        local joystickFrame = ui.GetFrame("joystickquickslot")
                        QUICKSLOT_REGISTER(joystickFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                    else
                        local joystickFrame = ui.GetFrame("joystickquickslot")
                        QUICKSLOT_REGISTER(joystickFrame, iconType, slot:GetSlotIndex() + 1, iconCategory, true)
                    end

                    --새거 등록
                    QUICKSLOTNEXPBAR_NEW_SETICON(frame, slot, iconCategory, iconType, iconGUID)
                    DebounceScript("JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT", 0.1)
                    return
                end
            end
        end
    end
    return RPPOTION_OLD_QUICKSLOTNEXPBAR_ON_DROP(frame, control, argStr, argNum)
end
function RPPOTION_ICON_USE(object, reAction)
    EBI_try_catch {
        try = function()
            local iconPt = object
            if iconPt ~= nil then
                local icon = tolua.cast(iconPt, "ui::CIcon")

                local iconInfo = icon:GetInfo()
                if iconInfo:GetCategory() == "Item" then
                    local invItem = GET_ICON_ITEM(iconInfo)
                    local item_obj = GetIES(invItem:GetObject())
                    if (not RPPOTION_USE(invItem)) then
                        return RPPOTION_OLD_ICON_USE(object, reAction)
                    end
                    return
                end
            end
            return RPPOTION_OLD_ICON_USE(object, reAction)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function RPPOTION_INV_ICON_USE(invItem)
    RPPOTION_OLD_INV_ICON_USE(invItem)
    RPPOTION_USE(invItem)
end

function RPPOTION_INVENTORY_RBDC_ITEMUSE(frame, object, argStr, argNum)
    RPPOTION_OLD_INVENTORY_RBDC_ITEMUSE(frame, object, argStr, argNum)

    local invitem = GET_SLOT_ITEM(object)
    if invitem == nil then
        return
    end
    if keyboard.IsKeyPressed("LCTRL") == 1 then
        local obj = GetIES(invitem:GetObject())
        IES_MAN_IESID(invitem:GetIESID())
        return
    end

    local itemobj = GetIES(invitem:GetObject())

    -- custom
    local customRBtnScp = frame:GetTopParentFrame():GetUserValue("CUSTOM_RBTN_SCP")
    if customRBtnScp == "None" then
        customRBtnScp = nil
    else
        customRBtnScp = _G[customRBtnScp]
    end

    if customRBtnScp ~= nil then
        customRBtnScp(itemobj, object, invitem:GetIESID())
        imcSound.PlaySoundEvent("icon_get_down")
        return
    end

    if INVENTORY_RBTN_LEGENDPREFIX(invitem) == true then
        return
    end

    if INVENTORY_RBTN_LEGENDDECOMPOSE(invitem) == true then
        return
    end

    if INVENTORY_RBTN_MARKET_SELL(invitem) == true then
        return
    end

    local invFrame = ui.GetFrame("inventory")
    invFrame:SetUserValue("INVITEM_GUID", invitem:GetIESID())

    -- shop
    local frame = ui.GetFrame("shop")
    local companionshop = ui.GetFrame("companionshop")
    local housingShopFrame = ui.GetFrame("housing_shop")
    if companionshop:IsVisible() == 1 then
        frame = companionshop:GetChild("foodBox")
    elseif housingShopFrame:IsVisible() == 1 then
        frame = GET_CHILD_RECURSIVELY(housingShopFrame, "gbox_bottom")
    end

    if frame:IsVisible() == 1 then
        local groupName = itemobj.GroupName
        if groupName == "Money" then
            return
        end

        local invFrame = ui.GetFrame("inventory")
        local invGbox = invFrame:GetChild("inventoryGbox")
        if true == IS_TEMP_LOCK(invFrame, invitem) then
            return
        end

        local Itemclass = GetClassByType("Item", invitem.type)
        local ItemType = Itemclass.ItemType

        local invIndex = invitem.invIndex
        local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invIndex)
        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)

        local tree_box = invGbox:GetChild("treeGbox_" .. typeStr)
        local tree = tree_box:GetChild("inventree_" .. typeStr)
        local slotsetname = GET_SLOTSET_NAME(argNum)
        local slotSet = GET_CHILD_RECURSIVELY(tree, slotsetname, "ui::CSlotSet")
        local itemProp = geItemTable.GetPropByName(Itemclass.ClassName)
        if itemProp:IsEnableShopTrade() == true then
            if IS_SHOP_SELL(invitem, Itemclass.MaxStack, frame) == 1 then
                if keyboard.IsKeyPressed("LSHIFT") == 1 then
                    local sellableCount = invitem.count
                    local titleText = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", sellableCount)
                    if housingShopFrame:IsVisible() == 1 then
                        INPUT_NUMBER_BOX(invFrame, titleText, "EXEC_HOUSING_SHOP_SELL", 1, 1, sellableCount)
                    else
                        INPUT_NUMBER_BOX(invFrame, titleText, "EXEC_SHOP_SELL", 1, 1, sellableCount)
                    end
                    invFrame:SetUserValue("SELL_ITEM_GUID", invitem:GetIESID())
                    return
                end

                -- 상점 Sell Slot으로 넘긴다.
                if housingShopFrame:IsVisible() == 1 then
                    HOUSING_SHOP_SELL(invitem, 1, frame)
                else
                    SHOP_SELL(invitem, 1, frame)
                end
                return
            else
                ui.SysMsg(ClMsg("CannotSellMore"))
            end
        end

        return
    end

    -- mixer
    local mixerFrame = ui.GetFrame("mixer")
    if mixerFrame:IsVisible() == 1 then
        local slotSet = INV_GET_SLOTSET_BY_INVINDEX(argNum - 1)
        local slot = slotSet:GetSlotByIndex(argNum - 1)
        MIXER_INVEN_RBOTTUNDOWN(itemobj, argNum)
        return
    end

    -- warp
    if TRY_TO_USE_WARP_ITEM(invitem, itemobj) == 1 then
        return
    end

    -- EVENT_2011_5TH
    if USE_ITEMTARGET_ICON_EVENT_2011_5TH_SCROLL(itemobj, argNum) == 1 then
        return
    end

    -- ReLabeling_Rewards_EP12
    -- Target Itme TRANSCEND
    if USE_ITEMTARGET_ICON_EP12_REWARD(itemobj, argNum) == 1 then
        return
    end

    -- ReLabeling_Rewards_EP12
    -- Target Itme Reinforce
    if USE_ITEMTARGET_ICON_EP12_REWARD_REINFORCE(itemobj, argNum) == 1 then
        return
    end

    RPPOTION_USE(invitem)
end

function RPPOTION_USE(invItem)
    return EBI_try_catch {
        try = function()
            local item_obj = GetIES(invItem:GetObject())
            if nil == invItem then
                return false
            end

            local mat_class_name = TryGetProp(item_obj, "ClassName", "None")
            local name_list = shared_item_relic.get_rp_material_name_list()
            local mat_index = table.find(name_list, mat_class_name)

            if mat_index <= 0 then
                return false
            end
            local mat_class = GetClass("Item", mat_class_name)
            local mat_class_id = TryGetProp(mat_class, "ClassID", 0)
            local mat_guid = invItem:GetIESID()
            local rp_per_list = shared_item_relic.get_rp_material_value_list()
            local rp_per = rp_per_list[mat_index]

            if true == invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"))
                return true
            end

            if true == RUN_CLIENT_SCP(invItem) then
                return true
            end

            local stat = info.GetStat(session.GetMyHandle())
            if stat.HP <= 0 then
                return true
            end
            local cur_rp, max_rp = shared_item_relic.get_rp(pc)
            local itemtype = invItem.type
            local curTime = item.GetCoolDown(itemtype)
            if curTime ~= 0 then
                imcSound.PlaySoundEvent("skill_cooltime")
                return true
            end

            if cur_rp == max_rp then
                ui.SysMsg("RP is full.")
                imcSound.PlaySoundEvent("skill_cooltime")
                return true
            end
            session.ResetItemList()
            session.AddItemID(invItem:GetIESID(), math.min(math.ceil(max_rp - cur_rp / rp_per), invItem.count))
            local result_list = session.GetItemIDList()

            item.DialogTransaction("RELIC_CHARGE_RP", result_list)
            return true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
