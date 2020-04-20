-- YAI
local addonName = "YAACCOUNTINVENTORY"
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
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "yaaccountinventory"
g.debug = true
g.w = 650
g.h = 570
g.maxtabs = 1
g.countpertab = 70
g.filters = {
        
        --{name = "Fav", text = "★", tooltip = "Favorites", imagename = "aoi_favorites", original = nil},
        {name = "All", text = "All", tooltip = "All", imagename = "aoi_all", original = "All"},
        {name = "Equ", text = "Equ", tooltip = "Equip", imagename = "aoi_equip", original = "Equip"},
        {name = "Spl", text = "Spl", tooltip = "Consume Item", imagename = "aoi_consume", original = "Consume"},
        {name = "Rcp", text = "Rcp", tooltip = "Recipe", imagename = "aoi_recipe", original = "Recipe"},
        {name = "Crd", text = "Crd", tooltip = "Card", imagename = "aoi_card", original = "Card"},
        {name = "Etc", text = "Etc", tooltip = "Etc", imagename = "aoi_etc", original = "Etc"},
        {name = "Ing", text = "Ing", tooltip = "Material", imagename = "aoi_ingredients", original = nil},
        {name = "Que", text = "Que", tooltip = "Quest Item", imagename = "aoi_quest", original = nil},
        {name = "Gem", text = "Gem", tooltip = "Gem", imagename = "aoi_gem", original = "Gem"},
        {name = "Prm", text = "Prm", tooltip = "Premium", imagename = "aoi_premium", original = "Premium"},
        {name = "Lim", text = "Lim", tooltip = "Time Limited", imagename = "aoi_timelimited", original = nil},
        {name = "Fnd", text = "Fnd", tooltip = "Find", imagename = "aoi_find", original = nil},
}

g.filterbyname = {}
g.settings.filter = "All"
for _, v in ipairs(g.filters) do
    g.filterbyname[v.name] = v
end
--ライブラリ読み込み
CHAT_SYSTEM("[YAI]loaded")
local acutil = require('acutil')
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
    
    EBI_try_catch{
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
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }

end
local function _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)    
    local index = YAI_get_valid_index()    
    DBGOUT(tostring(index))
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local itemCnt = 0;
    local guidList = itemList:GetGuidList();
    local cnt = guidList:Count();
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < (g.countpertab*g.maxtabs) then
            itemCnt = itemCnt + 1;
        end
    end

    if slotCount <= itemCnt and index < (g.countpertab*g.maxtabs) then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        DBGOUT(tostring("a"))
        return false;
    end
    
    if slotCount <= index and index <  (g.countpertab*g.maxtabs) then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        DBGOUT(tostring("b"))
        return false;
    end
    return true;
end
function YAACCOUNTINVENTORY_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            --addon:RegisterMsg('GAME_START_3SEC', 'TESTBOARD_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            --addon:RegisterMsg('BUFF_ADD', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_REMOVE', 'TESTBOARD_BUFF_ON_MSG');
            --addon:RegisterMsg('BUFF_UPDATE', 'TESTBOARD_BUFF_ON_MSG');
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "YAI_ON_MSG");
            addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "YAI_ON_OPEN_ACCOUNTWAREHOUSE");
            acutil.setupHook(YAI_ACCOUNTWAREHOUSE_OPEN, "ACCOUNTWAREHOUSE_OPEN")
            acutil.setupHook(YAI_ACCOUNTWAREHOUSE_CLOSE, "ACCOUNTWAREHOUSE_CLOSE")
            acutil.setupHook(YAI_callback_get_account_warehouse_title, "callback_get_account_warehouse_title")
            --local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            --timer:SetUpdateScript("YAI_ON_TIMER");
            --timer:Start(0.1);
            --TESTBOARD_SHOW(g.frame)
            YAI_INIT()
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function YAI_INIT(frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ACCOUNTWAREHOUSE_CLOSE(frame)
    local overlap = ui.GetFrame("yaireplacement")
    overlap:ShowWindow(0)
    ACCOUNTWAREHOUSE_CLOSE_OLD(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");
end
-- return bool, index
function YAI_get_exist_item_index(insertItem)
    local ret1 = false
    local ret2 = -1
    
    if geItemTable.IsStack(insertItem.ClassID) == 1 then
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
        local sortedGuidList = itemList:GetSortedGuidList();
        local sortedCnt = sortedGuidList:Count();
        
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if insertItem.ClassID == invItem_obj.ClassID then
                ret1 = true
                ret2 = i
                break
            end
        end
        return ret1, ret2
    else
        return false, -1
    end
end
function YAI_get_valid_index()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local start_index = 0
    local last_index = g.maxtabs * g.countpertab - 1
    
    local __set = {}
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        local page= math.floor(i / g.countpertab)

        if obj.ClassName ~= MONEY_NAME then
      

            if start_index <= invItem.invIndex and invItem.invIndex <= last_index and __set[invItem.invIndex] == nil then
                __set[invItem.invIndex] = 1
            end
        end
    end
    -- dont use slot
    for i=slotCount,g.countpertab do
        __set[i] = 1
    end
    
    local index = start_index

    for k, v in pairs(__set) do
        if __set[index] ~= 1 then
            break
        else
            index = index + 1
        end
    end
    
    return index
end
function YAI_callback_get_account_warehouse_title(code, ret_json)
    callback_get_account_warehouse_title(code, ret_json)
    local parsed_json = json.decode(ret_json)
    local list = parsed_json['list']
    local count = 0
    for k, v in pairs(list) do
        if v['title'] ~= '' then
            local index = tonumber(v['index'])
            count = count + 1
        end
    end
    
    g.maxtabs = count
end

function YAI_ACCOUNTWAREHOUSE_OPEN(frame)
    EBI_try_catch{
        try = function()
            local invframe = ui.GetFrame("inventory")
            ACCOUNTWAREHOUSE_OPEN_OLD(frame)
            
            INVENTORY_SET_CUSTOM_RBTNDOWN("YAI_ACCOUNT_WAREHOUSE_INV_RBTN")
            SET_INV_LBTN_FUNC(invframe, "YAI_ACCOUNT_WAREHOUSE_INV_LBTN")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function YAI_ACCOUNT_WAREHOUSE_INV_LBTN(frame, invItem, dumm)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            if (not YAI_CHECKITEM(invItem)) then
                return
            end
            local obj = GetIES(invItem:GetObject())
            local ret, idx = YAI_get_exist_item_index(obj)
            if (ret==false) then
                idx = YAI_get_valid_index()
            end
            
            if(idx~=nil)then
                local cnt=10

                if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                    cnt = invItem.count
                end
                
                --10こ
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(math.min(cnt,invItem.count)), awframe:GetUserIValue("HANDLE"), idx)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function YAI_EXEC_ACCOUNT_WAREHOUSE_INV_RBTN(awframe, numberString, inputFrame)
    
	local itemID = inputFrame:GetUserValue("ArgString");
	local idx = inputFrame:GetValue();

    local invItem = GET_PC_ITEM_BY_GUID(itemID);
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(),numberString, awframe:GetUserIValue("HANDLE"), idx)
end
function YAI_ACCOUNT_WAREHOUSE_INV_RBTN(itemObj, slot)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
            local obj = GetIES(invItem:GetObject())
            if (not YAI_CHECKITEM(invItem)) then
                return
            end
            local ret, idx = YAI_get_exist_item_index(obj)
            
            if (ret==false) then
                DBGOUT("not")
                idx = YAI_get_valid_index()
            end
            if(idx~=nil)then
                DBGOUT("put"..tostring(idx).."/"..tostring(1))

                if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                    INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "YAI_EXEC_ACCOUNT_WAREHOUSE_INV_RBTN", invItem.count, 1, invItem.count, idx, tostring(invItem:GetIESID()));
                else
               
                    --1こ
                    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(1), awframe:GetUserIValue("HANDLE"), idx)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function YAI_CHECKITEM(invItem)
    local frame = ui.GetFrame("accountwarehouse")
    local obj = GetIES(invItem:GetObject())
    --if _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then
    --    return;
    --end
    
    -- if CHECK_EMPTYSLOT(frame, obj) == 1 then
    --     return
    -- end
    
    if true == invItem.isLockState then
        ui.SysMsg(ClMsg("MaterialItemIsLock"));
        return;
    end
    
    local itemCls = GetClassByType("Item", invItem.type);
    if itemCls.ItemType == 'Quest' then
        ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        return;
    end
    
    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end
    return true
end 
function YAI_ON_OPEN_ACCOUNTWAREHOUSE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("accountwarehouse")
            local overlap = ui.GetFrame("yaireplacement")
            overlap:SetSkinName("None")
            overlap:ShowWindow(1)
            overlap:SetOffset(10, 200)
            overlap:EnableHitTest(1)
            overlap:EnableHittestFrame(1)

            local w = g.w
            local h = g.h
            overlap:Resize(w, h)
            overlap:SetLayerLevel(100)
            local gbox = overlap:GetChild("inventoryGbox")
            AUTO_CAST(gbox)
            local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
            AUTO_CAST(gbox2)
            gbox:EnableScrollBar(0)
            
            gbox:Resize(w, h)
            gbox2:Resize(w - 32, h - 2)
            
            YAI_UPDATE()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_FIND_ACTIVEGBOX()
    return EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("yaireplacement")
            
            
            for typeNo = 1, #g_invenTypeStrList do
                local tree_box = GET_CHILD_RECURSIVELY(frame, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
                if (tree_box:IsVisible() == 1) then
                    
                    return tree_box
                end
            end
            return nil
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_UPDATE()
    EBI_try_catch{
        try = function()
            local invenTypeStr = nil
            local overlap = ui.GetFrame("yaireplacement")
            local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
            AUTO_CAST(gbox2)
            
            
            
            local frame = ui.GetFrame("yaireplacement")
            local invframe = ui.GetFrame("inventory")
            local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
            local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
            
            local etree_box = YAI_FIND_ACTIVEGBOX()
            
            local curpos = etree_box:GetScrollCurPos();
            frame:SetUserValue("INVENTORY_CUR_SCROLL_POS", curpos);
            
            for typeNo = 1, #g_invenTypeStrList do
                if invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1 then
                    local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
                    local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')
                    
                    local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT");
                    local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH");
                    
                    tree:Clear();
                    tree:EnableDrawFrame(false)
                    tree:SetFitToChild(true, 60)
                    tree:SetFontName(groupfontname);
                    tree:SetTabWidth(tabwidth);
                    
                    local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
                    for i = 1, slotSetNameListCnt do
                        local slotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                        ui.inventory.RemoveInvenSlotSetName(slotSetName);
                    end
                    
                    local groupNameListCnt = ui.inventory.GetInvenGroupNameCount();
                    for i = 1, groupNameListCnt do
                        local groupName = ui.inventory.GetInvenGroupNameByIndex(i - 1);
                        ui.inventory.RemoveInvenGroupName(groupName);
                    end
                    
                    local customFunc = nil;
                    local scriptName = invframe:GetUserValue("CUSTOM_ICON_SCP");
                    local scriptArg = nil;
                    if scriptName ~= nil then
                        customFunc = _G[scriptName];
                        local getArgFunc = _G[invframe:GetUserValue("CUSTOM_ICON_ARG_SCP")];
                        if getArgFunc ~= nil then
                            scriptArg = getArgFunc();
                        end
                    end
                end
            end
            
            local baseidclslist, baseidcnt = GetClassList("inven_baseid");
            
            
            local invenTitleName = nil
            if invenTitleName == nil then
                invenTitleName = {}
                for i = 1, baseidcnt do
                    local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
                    local tempTitle = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= "NO" then
                        tempTitle = baseidcls.MergedTreeTitle
                    end
                    
                    if table.find(invenTitleName, tempTitle) == 0 then
                        invenTitleName[#invenTitleName + 1] = tempTitle
                    end
                end
            end
            
            
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local isShowMap = {};
            local sortedCnt = sortedGuidList:Count();
            
            local invItemCount = sortedCnt;
            
            local invItemList = {}
            local index_count = 1
            for i = 0, invItemCount - 1 do
                local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i));
                if invItem ~= nil then
                    invItemList[index_count] = invItem
                    index_count = index_count + 1
                end
            end
            --1 등급순 / 2 무게순 / 3 이름순 / 4 소지량순
            if sortType == 1 then
                table.sort(invItemList, INVENTORY_SORT_BY_GRADE)
            elseif sortType == 2 then
                table.sort(invItemList, INVENTORY_SORT_BY_WEIGHT)
            elseif sortType == 3 then
                table.sort(invItemList, INVENTORY_SORT_BY_NAME)
            elseif sortType == 4 then
                table.sort(invItemList, INVENTORY_SORT_BY_COUNT)
            else
                table.sort(invItemList, INVENTORY_SORT_BY_NAME)
            end
            
            local cls_inv_index = {}
            local i_cnt = 0
            for i = 1, #invenTitleName do
                local category = invenTitleName[i]
                for j = 1, #invItemList do
                    local invItem = invItemList[j];
                    if invItem ~= nil then
                        local itemCls = GetIES(invItem:GetObject())
                        if itemCls.MarketCategory ~= "None" then
                            local baseidcls = nil
                            baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(invItem:GetIESID())
                            cls_inv_index[invItem.invIndex] = baseidcls
                            
                            
                            local titleName = baseidcls.ClassName
                            if baseidcls.MergedTreeTitle ~= "NO" then
                                titleName = baseidcls.MergedTreeTitle
                            end
                            
                            if category == titleName then
                                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                                if itemCls ~= nil then
                                    local makeSlot = true;
                                    
                                    local viewOptionCheck = 1
                                    if typeStr == "Equip" then
                                        viewOptionCheck = CHECK_INVENTORY_OPTION_EQUIP(itemCls)
                                    elseif typeStr == "Card" then
                                        viewOptionCheck = CHECK_INVENTORY_OPTION_CARD(itemCls)
                                    elseif typeStr == "Etc" then
                                        viewOptionCheck = CHECK_INVENTORY_OPTION_ETC(itemCls)
                                    elseif typeStr == "Gem" then
                                        viewOptionCheck = CHECK_INVENTORY_OPTION_GEM(itemCls)
                                    end
                                    
                                    
                                    if invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then -- Unused로 설정된 것은 안보임
                                        if invenTypeStr == nil or invenTypeStr == typeStr then
                                            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                                            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                                            YAI_INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls);
                                        end
                                        
                                        local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                                        YAI_INSERT_ITEM_TO_TREE(frame, tree_all, invItem, itemCls, baseidcls);
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- for i = 0, sortedCnt - 1 do
            --     local guid = sortedGuidList:Get(i);
            --     local invItem = itemList:GetItemByGuid(guid);
            --     local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
            --     for i = 1, slotSetNameListCnt do
            --         local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
            --         local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            --         if invenTypeStr == nil then
            --             for typeNo = 1, #g_invenTypeStrList do
            --                 local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_'.. g_invenTypeStrList[typeNo],'ui::CGroupBox')
            --                 local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_'.. g_invenTypeStrList[typeNo],'ui::CTreeControl')
            --                 local slotSet = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
            --                 if slotSet ~= nil then
            --                     if slotSetName ~= nil then
            --                         if string.find(slotSet:GetName(), slotSetName) then
            --                             local func = _G[funcStr];
            --                             APPLY_TO_ALL_ITEM_SLOT(slotSet, func);
            --                         end
            --                     else
            --                         local func = _G[funcStr];
            --                         APPLY_TO_ALL_ITEM_SLOT(slotSet, func);
            --                     end
            --                 end
            --             end
            --         else
            --             local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_'.. invenTypeStr,'ui::CGroupBox')
            --             local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_'.. invenTypeStr,'ui::CTreeControl')
            --             local slotSet = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
            --             local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All','ui::CGroupBox')
            --             local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All','ui::CTreeControl')
            --             local slotSet_all = GET_CHILD_RECURSIVELY(tree_all, getSlotSetName, 'ui::CSlotSet');
            --             if slotSet ~= nil and slotSet_all ~= nil then
            --                 if slotSetName ~= nil then
            --                     if string.find(slotSet:GetName(), slotSetName) then
            --                         local func = _G[funcStr];
            --                         APPLY_TO_ALL_ITEM_SLOT(slotSet, func);
            --                         APPLY_TO_ALL_ITEM_SLOT(slotSet_all, func);
            --                     end
            --                 else
            --                     local func = _G[funcStr];
            --                     APPLY_TO_ALL_ITEM_SLOT(slotSet, func);
            --                     APPLY_TO_ALL_ITEM_SLOT(slotSet_all, func);
            --                 end
            --             end
            --         end
            --     end
            -- end
            local trees = {
                "treeGbox_All",
                "treeGbox_Equip",
                "treeGbox_Consume",
                "treeGbox_Recipe",
                "treeGbox_Card",
                "treeGbox_Etc",
                "treeGbox_Gem",
                "treeGbox_Premium",
                "treeGbox_Housing",
            }
            local inventrees = {
                "inventree_All",
                "inventree_Equip",
                "inventree_Consume",
                "inventree_Recipe",
                "inventree_Card",
                "inventree_Etc",
                "inventree_Gem",
                "inventree_Premium",
                "inventree_Housing",
            }
            for _, v in ipairs(trees) do
                overlap:GetChildRecursively(v):Resize(g.w - 48, g.h)
            end
            for typeNo = 1, #g_invenTypeStrList do
                local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
                local slotset
                
                --아이템 없는 빈 슬롯은 숨겨라
                local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
                for i = 1, slotSetNameListCnt do
                    local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                    slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                    if slotset ~= nil then
                        ui.InventoryHideEmptySlotBySlotSet(slotset);
                    end
                end
                
                ADD_GROUP_BOTTOM_MARGIN(frame, tree)
                tree:OpenNodeAll();
                tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
                INVENTORY_CATEGORY_OPENCHECK(frame, tree);
                
                --검색결과 스크롤 세팅은 여기서 하자. 트리 업데이트 후에 위치가 고정된 다음에.
                for i = 1, slotSetNameListCnt do
                    local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                    slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                    
                    local slotsetnode = tree:FindByValue(getSlotSetName);
                    --if setpos == 'setpos' then
                    local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
                    if savedPos == 'None' then
                        savedPos = 0
                    end
                    
                    tree_box:SetScrollPos(tonumber(savedPos))
                
                --end
                end
            end
            for _, v in ipairs(inventrees) do
                local tree = overlap:GetChildRecursively(v)
                AUTO_CAST(tree)
                tree:Resize(g.w - 48, tree:GetHeight())
            
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_GET_SLOTSET_NAME(baseidcls)
    local cls = baseidcls
    if cls == nil then
        return 'error'
    else
        local className = cls.ClassName
        if cls.MergedTreeTitle ~= "NO" then
            className = cls.MergedTreeTitle
        end
        return 'sset_' .. className
    end
end
function YAI_ON_MSG()
    YAI_UPDATE()
end
function YAI_INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls)
    --그룹 없으면 만들기
    local treegroupname = baseidcls.TreeGroup
    local treegroup = tree:FindByValue(treegroupname);
    if tree:IsExist(treegroup) == 0 then
        treegroup = tree:Add(baseidcls.TreeGroupCaption, baseidcls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(treegroup);
        treeNode:SetUserValue("BASE_CAPTION", baseidcls.TreeGroupCaption);
    
    --ui.inventory.AddInvenGroupName(treegroupname);
    end
    
    --슬롯셋 없으면 만들기
    local slotsetname = YAI_GET_SLOTSET_NAME(baseidcls)
    local slotsetnode = tree:FindByValue(treegroup, slotsetname);
    if tree:IsExist(slotsetnode) == 0 then
        MAKE_INVEN_SLOTSET_AND_TITLE(tree, treegroup, slotsetname, baseidcls);
        INVENTORY_CATEGORY_OPENOPTION_CHECK(tree:GetName(), baseidcls.ClassName);
    end
    slotset = GET_CHILD_RECURSIVELY(tree, slotsetname, 'ui::CSlotSet');
    local slotCount = slotset:GetSlotCount();
    local slotindex = slotCount;
    
    --검색 기능
    local slot = nil;
    if cap == "" then
        slot = slotset:GetSlotByIndex(slotindex);
    else
        
        local cnt = GET_SLOTSET_COUNT(tree, baseidcls);
        -- 저장된 템의 최대 인덱스에 따라 자동으로 늘어나도록. 예를들어 해당 셋이 10000부터 시작하는데 10500 이 오면 500칸은 늘려야됨
        while slotCount <= cnt do
            slotset:ExpandRow()
            slotCount = slotset:GetSlotCount();
        end
        
        slot = slotset:GetSlotByIndex(cnt);
        cnt = cnt + 1;
        slotset:SetUserValue("SLOT_ITEM_COUNT", cnt)
    end
    
    slot:ShowWindow(1);
    UPDATE_INVENTORY_SLOT(slot, invItem, itemCls);
    
    local function _DRAW_ITEM(invItem, slot)
        local obj = GetIES(invItem:GetObject());
        
        
        
        
        slot:SetSkinName('invenslot2')
        local itemCls = GetIES(invItem:GetObject());
        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);
        
        slot:SetHeaderImage('None')
        
        
        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, invItem.count)
        
        SET_SLOT_STYLESET(slot, itemCls)
        SET_SLOT_IESID(slot, invItem:GetIESID())
        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, obj, nil)
        slot:SetMaxSelectCount(invItem.count);
        local icon = slot:GetIcon();
        icon:SetTooltipArg("accountwarehouse", invItem.type, invItem:GetIESID());
        SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
        
        if invItem.hasLifeTime == true then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
            slot:SetFrontImage('clock_inven');
        else
            CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
        end
    
    end
    --INV_ICON_SETINFO(frame, slot, invItem, nil, nil, nil);
    _DRAW_ITEM(invItem, slot, nil)
    SET_SLOTSETTITLE_COUNT(tree, baseidcls, 1)
    slot:EnableDrag(0)
    slot:SetEventScript(ui.LBUTTONUP, "YAI_ON_LBUTTON")
    slot:SetEventScript(ui.RBUTTONUP, "YAI_ON_RBUTTON")
    slotset:MakeSelectionList();
--slotset:EnableSelection(1)
end
function YAI_ON_LBUTTON(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
            local obj = GetIES(invItem:GetObject());
            
            session.ResetItemList();
            local cnt = math.min(10, invItem.count)
            if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                cnt = invItem.count
            end
            
            session.AddItemID(iconInfo:GetIESID(), cnt);
            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function YAI_EXEC_ON_RBUTTON(awframe, numberString, inputFrame)
    
	local itemID = inputFrame:GetUserValue("ArgString");

     
    session.ResetItemList();
    session.AddItemID(itemID, tonumber(numberString));
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
end

function YAI_ON_RBUTTON(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
            local obj = GetIES(invItem:GetObject());
            
            session.ResetItemList();
            local cnt = math.min(1, invItem.count)
            if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                
                INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "YAI_EXEC_ON_RBUTTON", invItem.count, 1, invItem.count, nil, tostring(invItem:GetIESID()));
               
            else
            
                session.AddItemID(iconInfo:GetIESID(), cnt);
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
