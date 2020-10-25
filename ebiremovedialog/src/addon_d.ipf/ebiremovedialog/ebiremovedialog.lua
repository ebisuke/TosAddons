--アドオン名（大文字）
local addonName = "ebiremovedialog"
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
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "アドオン名（大文字）"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[ERD]loaded")
local acutil = require('acutil')
local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
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


function EBIREMOVEDIALOG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --acutil:setupHook("QUICKSLOT_MAKE_GAUGE", SMALLUI_QUICKSLOT_MAKE_GAUGE)
            addon:RegisterMsg('GAME_START', 'EBIREMOVEDIALOG_GAME_START');


        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EBIREMOVEDIALOG_GAME_START()
   
    EBIREMOVEDIALOG_LOAD_SETTINGS()
    EBIREMOVEDIALOGCONFIG_INIT()
    EBIREMOVEDIALOG_APPLY()
end

function EBIREMOVEDIALOG_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function  EBIREMOVEDIALOG_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    EBIREMOVEDIALOGCONFIG_GENERATEDEFAULT(g.settings)
    EBIREMOVEDIALOG_UPGRADE_SETTINGS()
    EBIREMOVEDIALOG_SAVE_SETTINGS()

end

function  EBIREMOVEDIALOG_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function EBIREMOVEDIALOG_APPLY()
    EBI_try_catch{
        try = function()
            if g.settings.challengemodeenter then
                assert(pcall(function()
                    function DIALOG_ACCEPT_CHALLENGE_MODE(handle)
                        ACCEPT_CHALLENGE_MODE(handle,1)
                    end
                end))
            end
            if g.settings.challengehardmodeenter then
                assert(pcall(function()
                    function DIALOG_ACCEPT_CHALLENGE_MODE_HARD_MODE(handle)
                        ACCEPT_CHALLENGE_MODE(handle,1)
                    end
                end))
            end
            
            if g.settings.challengemodenextstep then
                assert(pcall(function()
                    function DIALOG_ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(handle)
                        ACCEPT_NEXT_LEVEL_CHALLENGE_MODE(handle)
                    end
                end))
            end
            if g.settings.challengemodeabort then
                assert(pcall(function()
                    function DIALOG_ACCEPT_STOP_LEVEL_CHALLENGE_MODE(handle)
                        ACCEPT_STOP_LEVEL_CHALLENGE_MODE(handle)
                    end
                end))
            end
            if g.settings.challengemodecomplete then
                assert(pcall(function()
                    function DIALOG_COMPLETE_CHALLENGE_MODE(handle)
                        ACCEPT_STOP_LEVEL_CHALLENGE_MODE(handle)
                    end
                end))
            end
            

            if g.settings.bookreading then
                assert(pcall(function()
                    function BEFORE_APPLIED_NON_EQUIP_ITEM_OPEN(invItem)	
                        if invItem == nil then
                            return;
                        end
                    
                        local invFrame = ui.GetFrame("inventory");	
                        local itemobj = GetIES(invItem:GetObject());
                        if itemobj == nil then
                            return;
                        end
                        
                        if SYSMENU_INVENTORY_WEIGHT_NOTICE == nil then
                            --older one
                            invFrame:SetUserValue("INVITEM_GUID", invItem:GetIESID());
                        else
                            --newer
                            invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
                        end
                        
                        if itemobj.Script == 'SCR_SUMMON_MONSTER_FROM_CARDBOOK' then
                            REQUEST_SUMMON_BOSS_TX()
                            return;
                        elseif itemobj.Script == 'SCR_QUEST_CLEAR_LEGEND_CARD_LIFT' then
                            local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("Use_Item_LegendCard_Slot_Open2"));
                            ui.MsgBox_NonNested(textmsg, itemobj.Name, "REQUEST_SUMMON_BOSS_TX", "None");
                            return;
                        end
                    end
                end))
            end
            if g.settings.timelimited then
                assert(pcall(function()
                    -- RWFTLI
local json = require "json_imc"

local max_slot_per_tab = account_warehouse.get_max_slot_per_tab()
local current_tab_index = 0
local custom_title_name = {}
local new_add_item = { }
local new_stack_add_item = { }
local ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD = ON_ACCOUNT_WAREHOUSE_ITEM_LIST

function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function get_valid_index()    
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();    
    local sortedCnt = sortedGuidList:Count();    
    
    local start_index = (current_tab_index * max_slot_per_tab)
    local last_index = (start_index + max_slot_per_tab) -1
    
    local __set = {}
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        if obj.ClassName ~= MONEY_NAME then
            if start_index <= invItem.invIndex and invItem.invIndex <= last_index and __set[invItem.invIndex] == nil then
                __set[invItem.invIndex] = 1
            end
        end
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


local function get_tab_index(item_inv_index)
    if item_inv_index < 0 then
        item_inv_index = 0
    end
    local index = math.floor(item_inv_index / max_slot_per_tab)
    return index
end

local function is_new_item(id)
    for k, v in pairs(new_add_item) do
        if v == id then
            return true
        end
    end
    return false
end

local function is_stack_new_item(class_id)
    for k, v in pairs(new_stack_add_item) do
        if v == class_id then
            return true
        end
    end
    return false
end
function ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, msg, argStr, argNum, tab_index)  
    ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD(frame, msg, argStr, argNum, tab_index)  
    if tab_index == nil then
        tab_index = current_tab_index
    end
	
    current_tab_index=tab_index
end
local function _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(insertItem)    
    local index = get_valid_index()    
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
        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < max_slot_per_tab then
            itemCnt = itemCnt + 1;
        end
    end

    if slotCount <= itemCnt and index < max_slot_per_tab then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        return false;
    end
    
    if slotCount <= index and index < max_slot_per_tab then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        return false;
    end
    return true;
end


function PUT_ACCOUNT_ITEM_TO_WAREHOUSE_BY_INVITEM(frame, invItem, slot, fromFrame)
    local obj = GetIES(invItem:GetObject())
    if _CHECK_ACCOUNT_WAREHOUSE_SLOT_COUNT_TO_PUT(obj) == false then
        return;
    end

    if CHECK_EMPTYSLOT(frame, obj) == 1 then
        return
    end

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

    if fromFrame:GetName() == "inventory" then
        local maxCnt = invItem.count;
        if TryGetProp(obj, "BelongingCount") ~= nil then
            maxCnt = invItem.count - obj.BelongingCount;
            if maxCnt <= 0 then
                maxCnt = 0;
            end
        end

        if invItem.count > 1 then
            INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_ACCOUNT_WAREHOUSE", maxCnt, 1, maxCnt, nil, tostring(invItem:GetIESID()));
        else
            if maxCnt <= 0 then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end

            local slotset = GET_CHILD_RECURSIVELY(frame, 'slotset');
            local goal_index = get_valid_index()                  
            if invItem.hasLifeTime == true then
                local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", "%s", %d, %d)', IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue('HANDLE'), goal_index);
                --ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                ReserveScript(yesscp,0.00)
                return;
            end

            -- 여기서 아이템 입고 요청
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"), goal_index)
            new_add_item[#new_add_item + 1] = invItem:GetIESID()

            --if geItemTable.IsStack(obj.ClassID) == 1 then
            --    new_stack_add_item[#new_stack_add_item + 1] = obj.ClassID
            --end
        end
    else
        if slot ~= nil then
            AUTO_CAST(slot);
            local iconSlot = liftIcon:GetParent();
            AUTO_CAST(iconSlot);
            item.SwapSlotIndex(IT_ACCOUNT_WAREHOUSE, slot:GetSlotIndex(), iconSlot:GetSlotIndex());
            ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame);
        end
    end
end

function WAREHOUSE_INV_RBTN(itemObj, slot)
	
	local frame = ui.GetFrame("warehouse");
	local icon = slot:GetIcon();
	local iconInfo = icon:GetInfo();
	local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
	
	local obj = GetIES(invItem:GetObject());
	if CHECK_EMPTYSLOT(frame, obj) == 1 then        
		return
	end

	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));        
		return;
	end
	
	local itemCls = GetClassByType("Item", invItem.type);
	if itemCls.ItemType == 'Quest' then
		ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
		return;
	end

	if tonumber(itemCls.LifeTime) > 0 and obj.ItemLifeTimeOver > 0 then
		ui.MsgBox(ScpArgMsg("WrongDropItem"));
		return;
	end

	if itemCls.MarketCategory == 'Housing_Furniture' or 
	    itemCls.MarketCategory == 'Housing_Laboratory' or 
	    itemCls.MarketCategory == 'Housing_Contract' then
		ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
		return;
	end
    	
	AUTO_CAST(slot);
	local fromFrame = slot:GetTopParentFrame();

	if fromFrame:GetName() == "inventory" then        
		if invItem.count > 1 then
			INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_PUT_ITEM_TO_WAREHOUSE", invItem.count, 1, invItem.count, nil, tostring(invItem:GetIESID()));
		else
			if invItem.hasLifeTime == true then
				local yesscp = string.format('item.PutItemToWarehouse(%d, "%s", %d, %d)', IT_WAREHOUSE, invItem:GetIESID(), invItem.count, frame:GetUserIValue("HANDLE"));
				--ui.MsgBox(ScpArgMsg('PutLifeTimeItemInWareHouse{NAME}', 'NAME', itemCls.Name), yesscp, 'None');
                ReserveScript(yesscp,0.00)
                return;
			end

			item.PutItemToWarehouse(IT_WAREHOUSE, invItem:GetIESID(), tostring(invItem.count), frame:GetUserIValue("HANDLE"));
		end
	end
end

                end))
            end

            if g.settings.dimension  then
                assert(pcall(function()
                    
                    function BEFORE_APPLIED_YESSCP_OPEN(invItem)
                        if invItem == nil then
                            return;
                        end
                        
                        local invFrame = ui.GetFrame("inventory");	
                        local itemobj = GetIES(invItem:GetObject());
                        if itemobj == nil then
                            return;
                        end
                        invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
                        if invItem.type==494233 then 
                            REQUEST_SUMMON_BOSS_TX()
                        else
                            local strLang = TryGetProp(itemobj , 'StringArg')
                            if strLang ~='None' then
                                local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg(strLang));
                                ui.MsgBox_NonNested(textmsg, itemobj.Name, 'REQUEST_SUMMON_BOSS_TX', "None");
                            end
                        end
                      
                        return;
                    end
                    
                end))

            end
            if g.settings.idticket  then
                assert(pcall(function()
                    function BEFORE_APPLIED_INDUNRESET_OPEN(invItem)
                        local frame = ui.GetFrame("token");
                        if invItem.isLockState then 
                            frame:ShowWindow(0)
                            return;
                        end
                    
                        local obj = GetIES(invItem:GetObject());
                        
                        if obj.ItemLifeTimeOver > 0 then
                            ui.SysMsg(ScpArgMsg('LessThanItemLifeTime'));
                            return;
                        end
                    
                        if 0 == frame:IsVisible() then
                            frame:ShowWindow(1)
                        end
                    
                        local token_middle = GET_CHILD(frame, "token_middle", "ui::CPicture");
                        token_middle:SetImage("indunFreeEnter_middle");
                    
                        local gBox = frame:GetChild("gBox");
                        gBox:RemoveAllChild();
                        
                        local ctrlSet = gBox:CreateControlSet("tokenDetail", "CTRLSET_INDUNFREE",  ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
                        local prop = ctrlSet:GetChild("prop");
                    
                        if obj.ClassName == 'Premium_indunReset_1add' or obj.ClassName == 'Premium_indunReset_1add_14d' or obj.ClassName == 'indunReset_1add_14d_NoStack' or obj.ClassName == 'Event_1704_Premium_indunReset_1add' or obj.ClassName == 'indunReset_1add_14d_NoStack_Team' then
                            prop:SetTextByKey("value", ClMsg('Indun1AddText'));
                        else
                            prop:SetTextByKey("value", ClMsg('IndunRestText'));
                        end
                        
                        local value = GET_CHILD_RECURSIVELY(ctrlSet, "value");
                        value:ShowWindow(0);
                        
                    
                        GBOX_AUTO_ALIGN(gBox, 0, 2, 0, true, false);
                        local itemobj = GetIES(invItem:GetObject());
                        local endTxt = frame:GetChild("endTime");
                        endTxt:ShowWindow(0);
                        
                        local strTxt = frame:GetChild("richtext_1");
                        strTxt:SetTextByKey("value", GetClassString('Item', itemobj.ClassName, 'Name')); 
                    
                        local bg2 = frame:GetChild("bg2");
                        local indunStr = bg2:GetChild("indunStr");
                        indunStr:SetTextByKey("value", GetClassString('Item', itemobj.ClassName, 'Name')..ScpArgMsg("Premium_itemEun")); 
                        indunStr:SetTextByKey("value2", ScpArgMsg("Premium_character")); 
                        indunStr:ShowWindow(1);
                    
                        local endTime2 = bg2:GetChild("endTime2");
                        endTime2:ShowWindow(0);
                    
                        local strTxt = bg2:GetChild("str");
                        strTxt:SetTextByKey("value", GetClassString('Item', itemobj.ClassName, 'Name')); 
                    
                        local forToken = bg2:GetChild("forToken");
                        forToken:ShowWindow(1);
                    
                        frame:SetUserValue("itemIES", invItem:GetIESID());
                        frame:SetUserValue("ClassName", itemobj.ClassName);
                        bg2:Resize(bg2:GetWidth(), 440);
                        frame:Resize(frame:GetWidth(), 500);
                        REQ_TOKEN_ITEM(frame)
                    end
                end))

            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end