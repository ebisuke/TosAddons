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
local json = require "json_imc"

g.version = 0
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "yaaccountinventory"
g.debug = false
g.w = 650
g.h = 570
g.maxtabs = g.maxtabs or 1
g.countpertab = 70
g.limit=50
g.tree = g.tree or {}

g.automata=nil
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
local function AUTO_CAST(ctrl)
    if(ctrl==nil)then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
	return ctrl;
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
        if obj.ClassName ~= MONEY_NAME and invItem.invIndex < (g.countpertab * g.maxtabs) then
            itemCnt = itemCnt + 1;
        end
    end
    
    if slotCount <= itemCnt and index < (g.countpertab * g.maxtabs) then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        
        return false;
    end
    
    if slotCount <= index and index < (g.countpertab * g.maxtabs) then
        ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        
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
            addon:RegisterMsg("FPS_UPDATE", "YAI_SHOW");
            addon:RegisterMsg("GAME_START_3SEC", "YAI_3SEC");
            acutil.setupHook(YAI_ACCOUNTWAREHOUSE_OPEN, "ACCOUNTWAREHOUSE_OPEN")
            acutil.setupHook(YAI_ACCOUNTWAREHOUSE_CLOSE, "ACCOUNTWAREHOUSE_CLOSE")
            acutil.setupHook(YAI_ACCOUNT_WAREHOUSE_MAKE_TAB, "ACCOUNT_WAREHOUSE_MAKE_TAB")
            acutil.setupHook(YAI_ON_ACCOUNT_WAREHOUSE_ITEM_LIST, "ON_ACCOUNT_WAREHOUSE_ITEM_LIST")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("YAI_ON_TIMER");
            timer:Start(1.2);
            --TESTBOARD_SHOW(g.frame)
            YAI_INIT()
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_SHOW()
    ui.GetFrame(g.framename):ShowWindow(1)
end
function YAI_3SEC()
    if (true == session.loginInfo.IsPremiumState(ITEM_TOKEN)) then
        g.maxtabs = 5
       
    else
        g.maxtabs = 1
       
    end
end
function YAI_ON_TIMER()
    if(ui.GetFrame("accountwarehouse"):IsVisible()==1)then
        YAI_ACTIVATE_MOUSEBUTTON()
    end
end

function YAI_INIT(frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            frame:ShowWindow(1)
            if (true == session.loginInfo.IsPremiumState(ITEM_TOKEN)) then
                g.maxtabs = 5
               
            else
                g.maxtabs = 1
               
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ACTIVATE_MOUSEBUTTON()
    if(ui.GetFrame("accountwarehouse"):IsVisible()==1)then
        local invframe = ui.GetFrame("inventory")
        INVENTORY_SET_CUSTOM_RBTNDOWN("YAI_ACCOUNT_WAREHOUSE_INV_RBTN")
        SET_INV_LBTN_FUNC(invframe, "YAI_ACCOUNT_WAREHOUSE_INV_LBTN")
    end
end
function YAI_DEACTIVATE_MOUSEBUTTON()
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");
end

function YAI_ACCOUNTWAREHOUSE_CLOSE(frame)
    local overlap = ui.GetFrame("yaireplacement")
    overlap:ShowWindow(0)
    ACCOUNTWAREHOUSE_CLOSE_OLD(frame)

    YAI_DEACTIVATE_MOUSEBUTTON()
end
function YAI_COUNT()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt=0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        local invItem_obj = GetIES(invItem:GetObject());
        if invItem_obj.ClassName ~= MONEY_NAME then
            rcnt=rcnt+1
        end
    end
    return rcnt
end

function YAI_get_exist_item_index(insertItem)
    local ret1 = false
    local ret2 = -1
    
    if geItemTable.IsStack(insertItem.ClassID) == 1 then
        local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);    
        local sortedGuidList = itemList:GetGuidList();    
        local sortedCnt = sortedGuidList:Count();
        
        for i = 0, sortedCnt - 1 do
            local guid = sortedGuidList:Get(i);
            local invItem = itemList:GetItemByGuid(guid)
            local invItem_obj = GetIES(invItem:GetObject());
            if insertItem.ClassID == invItem_obj.ClassID then
                ret1 = true
                ret2 = invItem.invIndex 
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
    local sortedGuidList = itemList:GetGuidList();
    local sortedCnt = sortedGuidList:Count();
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    local start_index = 0
    local last_index = YAI_SLOT_LIMIT_FIRSTTAB() - 1
    local itemCnt = 0;
    local guidList = itemList:GetGuidList();
    local cnt = guidList:Count();
    local offset=0
    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = itemList:GetItemByGuid(guid);
    end
    local __set = {}
    local inc = 0
    local money_offset = 0
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject());
        
        if obj.ClassName ~= MONEY_NAME then
            __set[invItem.invIndex] = {item = invItem, obj = obj, mode = 1}

        
        else
            --__set[invItem.invIndex] = {item = invItem, obj = obj, mode = 2}
            money_offset=1
        end
    end
    local first=0
    for i=0,slotCount do
        if(__set[i]~=nil)then
            first=first+1

        end
    end
     -- -1 is preventaion tos bug
    DBGOUT(string.format("prevent %d/%d",first,slotCount-1))
    if(first>=(slotCount-1))then
        
        for i=0,g.countpertab do
            __set[i] ={mode=1}
        end
    end
    --prevent tos bug
    for i=1,g.maxtabs do
        local count=0
        for j=g.countpertab*i,g.countpertab*(i+1)-1  do
            if(__set[j]~=nil and __set[j].mode==1)then
                count=count+1
    
            end
        end
        if(count>=(g.countpertab-1))then
            for j=g.countpertab*i,g.countpertab*(i+1)-1 do
                __set[j] ={mode=1}
            end
        end
    end

    local index = start_index
    
    for k=start_index,last_index+1 do
        index = k
        if __set[k] == nil then
            offset=offset-1
            if(offset<=0)then
                break
            end
        end
    end
    
    DBGOUT("idx" .. index)
    return index
end
function YAI_ACCOUNT_WAREHOUSE_MAKE_TAB(frame)
    ACCOUNT_WAREHOUSE_MAKE_TAB_POST(true)
    GetAccountWarehouseTitle('YAI_callback_get_account_warehouse_title')
end
function YAI_callback_get_account_warehouse_title(code, ret_json)
    EBI_try_catch{
        try = function()
            EBI_try_catch{
                try = function()
                    callback_get_account_warehouse_title(code, ret_json)
                end,
                catch = function(error)
                    ERROUT(error)
                end
            }
            
            local parsed_json = json.decode(ret_json)
            local list = parsed_json['list']
            local count = 1
            for k, v in pairs(list) do
                count = count + 1
                if v['title'] ~= '' then
                    local index = tonumber(v['index'])
                
                end
            end
            DBGOUT("maxtabs")
            if (true == session.loginInfo.IsPremiumState(ITEM_TOKEN)) then
                g.maxtabs = 5
               
            else
                g.maxtabs = 1
               
            end
            YAI_UPDATE_STATUS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function YAI_ACCOUNTWAREHOUSE_OPEN(frame)
    EBI_try_catch{
        try = function()
            local invframe = ui.GetFrame("inventory")
            ACCOUNTWAREHOUSE_OPEN_OLD(frame)
            YAI_ACTIVATE_MOUSEBUTTON()
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
            if (ret == false) then
                idx = YAI_get_valid_index()
            end
            
            if (idx ~= nil) then
                local cnt = 10
                DBGOUT("index:"..idx)
                if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                    cnt = invItem.count
                end
                if (keyboard.IsKeyPressed("LCTRL") == 1) then
                    if (keyboard.IsKeyPressed("LALT") == 1) then
                        local baseid = GetInvenBaseID(obj.ClassID)
                        local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
                        local titleName = baseidcls.ClassName
                        if baseidcls.MergedTreeTitle ~= "NO" then
                            titleName = baseidcls.MergedTreeTitle
                        end
                        YAI_ACCOUNT_WAREHOUSE_INV_LBTN_CATEGORY(titleName)
                    else
                        YAI_ACCOUNT_WAREHOUSE_INV_LBTN_CTRL(obj.ClassID)
                    end
                end
                
                --10こ
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), tostring(math.min(cnt, invItem.count)), awframe:GetUserIValue("HANDLE"), idx)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function  YAI_ACCOUNT_WAREHOUSE_INV_LBTN_CATEGORY(category)
     EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            if(category==nil)then

                return

            end
            ui.SysMsg("分類名で搬入します:"..category.."{nl}動作中はほかの操作をしないでください")

            local delay=1
            local limit=g.limit

            local itemList = session.GetInvItemList();
            local guidList = itemList:GetGuidList();
            local invItemCount = guidList:Count();

            for i = 0, invItemCount - 1 do
                local invItem = session.GetInvItemByGuid(guidList:Get(i));
                if(invItem~=nil)then
                    local itemObj = GetIES(invItem:GetObject())
                    if(itemObj~=nil)then

                        local baseid = GetInvenBaseID(itemObj.ClassID)
                        local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
                        local titleName = baseidcls.ClassName
                        if baseidcls.MergedTreeTitle ~= "NO" then
                            titleName = baseidcls.MergedTreeTitle
                        end
                        if titleName == category then
                            delay=delay+0.8
                            limit=limit-1
                            ReserveScript('YAI_EXEC_ACCOUNT_WAREHOUSE_INV_LBTN("'..invItem:GetIESID()..'")',delay)
                            
                        end
                        if(limit==0)then
                            break    
                        end
                    end
                end
            end
            ReserveScript('ui.SysMsg("Completed")',delay)
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function YAI_ACCOUNT_WAREHOUSE_INV_LBTN_CTRL(clsid)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            if(clsid==nil)then

                return

            end

            ui.SysMsg("同一CLSIDで搬入します{nl}動作中はほかの操作をしないでください")

            local delay=1
            local limit=g.limit

            local itemList = session.GetInvItemList();
            local guidList = itemList:GetGuidList();
            local invItemCount = guidList:Count();

            for i = 0, invItemCount - 1 do
                   
                local invItem = session.GetInvItemByGuid(guidList:Get(i));
                if(invItem~=nil)then
                    local itemObj = GetIES(invItem:GetObject())
                    if(itemObj~=nil)then
                        DBGOUT("CC"..tostring(itemObj.ClassID))
                        if itemObj.ClassID == clsid then
                            delay=delay+0.8
                            limit=limit-1
                        
                            ReserveScript('YAI_EXEC_ACCOUNT_WAREHOUSE_INV_LBTN("'..invItem:GetIESID()..'")',delay)
                        end
                        if(limit==0)then
                            break
                        end
                    end
                end
            end
      
            ReserveScript('ui.SysMsg("Completed")',delay)
            
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_EXEC_ACCOUNT_WAREHOUSE_INV_LBTN(iesid)
    EBI_try_catch{
        try = function()
            
            local awframe = ui.GetFrame("accountwarehouse");
            local invItem = GET_PC_ITEM_BY_GUID(iesid);
            if(invItem==nil)then
                return

            end
            local obj = GetIES(invItem:GetObject())
            if (not YAI_CHECKITEM(invItem,true)) then
                return
            end
            local ret, idx = YAI_get_exist_item_index(obj)
            
            if (ret == false) then
                DBGOUT("YAIA")
                idx = YAI_get_valid_index()
            end
            if (idx ~= nil) then
                DBGOUT("OK")
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(),invItem.count, awframe:GetUserIValue("HANDLE"), idx)
            
            else
                DBGOUT("fail")
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
    item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, invItem:GetIESID(), numberString, awframe:GetUserIValue("HANDLE"), idx)

end

function YAI_ACCOUNT_WAREHOUSE_INV_RBTN(itemObj, slot)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = GET_PC_ITEM_BY_GUID(iconInfo:GetIESID());
            if nil == invItem then
                return;
            end
            
            local obj = GetIES(invItem:GetObject())
            if (keyboard.IsKeyPressed("LALT") == 1) then
                INV_ITEM_LOCK_LBTN_CLICK( ui.GetFrame("inventory"),invItem,slot)
                ReserveScript('imcAddOn.BroadMsg("ITEM_PROP_UPDATE","'..iconInfo:GetIESID()..'")',0.5);
                return
            end
            if (not YAI_CHECKITEM(invItem)) then
                return
            end
            local ret, idx = YAI_get_exist_item_index(obj)
            
            if (ret == false) then
                DBGOUT("YAI")
                idx = YAI_get_valid_index()
            end
            if (idx ~= nil) then
                
               
                if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                    INPUT_NUMBER_BOX(awframe, ScpArgMsg("InputCount"), "YAI_EXEC_ACCOUNT_WAREHOUSE_INV_RBTN", invItem.count, 1, invItem.count, idx, tostring(invItem:GetIESID()));
                else
                    DBGOUT("UI" .. tostring(idx))
                    
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


function YAI_CHECKITEM(invItem,silent)
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();    
    local sortedCnt = sortedGuidList:Count();  
    local frame = ui.GetFrame("accountwarehouse")
    local obj = GetIES(invItem:GetObject())
    if YAI_SLOT_LIMIT_FIRSTTAB() <= YAI_COUNT() then
        if(not silent)then
            ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        end
        return false;

    end
    if true == invItem.isLockState then
        if(not silent)then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
        end
        return;
    end
    
    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then
        if(not silent)then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        end
        return;
    end
    
    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        if(not silent)then
            ui.SysMsg(ClMsg("ItemIsNotTradable"));
        end
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
            if(g.debug)then
                overlap:SetOffset(10, 600)
                          --タブ非表示
                frame:GetChildRecursively("accountwarehouse_tab"):ShowWindow(1)
                frame:GetChildRecursively("slotgbox"):ShowWindow(1)
                 frame:GetChildRecursively("slotset"):ShowWindow(1)
            else
                overlap:SetOffset(10, 200)
                --タブ非表示
                frame:GetChildRecursively("accountwarehouse_tab"):ShowWindow(0)
                frame:GetChildRecursively("slotgbox"):ShowWindow(0)
                frame:GetChildRecursively("slotset"):ShowWindow(0)
            end
          
            overlap:EnableHitTest(1)
            overlap:EnableHittestFrame(1)
            
            local w = g.w
            local h = g.h
            overlap:Resize(w, h)
            frame:SetLayerLevel(94)
            overlap:SetLayerLevel(95)
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
    return EBI_try_catch{
        try = function()
            
            g.tree = {}
            
            local invenTypeStr = nil
            local overlap = ui.GetFrame("yaireplacement")
            local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
            AUTO_CAST(gbox2)
            
            
            
            local frame = ui.GetFrame("yaireplacement")
            local invframe = ui.GetFrame("inventory")
            local awframe = ui.GetFrame("accountwarehouse")
            local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
            local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
            
            local etree_box = YAI_FIND_ACTIVEGBOX()
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local isShowMap = {};
            local sortedCnt = sortedGuidList:Count();
            
            local invItemCount = sortedCnt;
            
            local invItemList = {}
            local index_count = 1
            local cls_inv_index = {}
            local i_cnt = 0
         
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
            
           
            local baseidclslist, baseidcnt  = GetClassList("inven_baseid");
            local invenTitleName = nil
            if invenTitleName == nil then
                invenTitleName = {}
                for i = 1, baseidcnt do
                    --local baseid = GetInvenBaseID(itemObj.ClassID)
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
            
            
            
            for i = 0, invItemCount - 1 do
                local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i));
                if invItem ~= nil then
                    invItemList[index_count] = invItem
                    index_count = index_count + 1
                end
            end
            local sortType = 3
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
            
            for i = 1, #invenTitleName do
                local category = invenTitleName[i]
                local lim = 30
                
                for j = 1, #invItemList do
                    lim = lim - 1
                    if (lim == 0) then
                        
                        lim = 30
                    end
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
                                        g.tree[typeStr] = g.tree[typeStr] or {}
                                        if invenTypeStr == nil or invenTypeStr == typeStr then
                                            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                                            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                                            YAI_INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls, typeStr);
                                        
                                        end
                                        
                                        local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                                        YAI_INSERT_ITEM_TO_TREE(frame, tree_all, invItem, itemCls, baseidcls, typeStr);
                                    
                                    end
                                end
                            end
                        end
                    end
                
                end
            
            end
            
            for typeNo = 1, #g_invenTypeStrList do
                local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
                tree_box:Resize(g.w - 48, g.h)
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
            for typeNo = 1, #g_invenTypeStrList do
                local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
                
                AUTO_CAST(tree)
                tree:Resize(g.w - 48, tree:GetHeight())
            end
            --スロット残数を表示
            YAI_UPDATE_STATUS()
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    
    }
end
function YAI_TREE_CONTEXT(frame, ctrl, typeStr, argnum)
    return EBI_try_catch{
        try = function()
            
            if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                
                local frame = ui.GetFrame("yaireplacement")
                local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
                local context = ui.CreateContextMenu("YAI_Context", "", 0, 0, 300, 100);
                local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                
                if (g.tree[typeStr]) then
                    ui.AddContextMenuItem(context, "このカテゴリをすべて引き出す", 'YAI_WITHDRAW_TREE("' .. typeStr .. '")')
                    for _, v in ipairs(g.tree[typeStr]) do
                        ui.AddContextMenuItem(context, v.treegroupcaption .. "をすべて引き出す", 'YAI_WITHDRAW_TREE("' .. v.treegroup .. '","' .. v.treegroupcaption .. '")')
                    end
                    
                    context:Resize(300, context:GetHeight())
                    ui.OpenContextMenu(context)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    
    }
end
function YAI_WITHDRAW_TREE(typeStr, treegroupcaption)
    EBI_try_catch{
        try = function()
            DBGOUT("HERE")
            local frame = ui.GetFrame("yaireplacement")
            local awframe = ui.GetFrame("accountwarehouse")
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local sortedCnt = sortedGuidList:Count();
            local cnt = 0
            session.ResetItemList();
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local itemObj = GetIES(invItem:GetObject());
                local baseid = GetInvenBaseID(itemObj.ClassID)
                local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
                --鑑別
                local slotsetname = YAI_GET_SLOTSET_NAME(baseidcls)
                local tree_box = GET_CHILD_RECURSIVELY(frame, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                if (treegroup == nil) then
                    local slotset = tree:GetChildRecursively(slotsetname)
                    if (not slotset) then
                        
                        else
                        AUTO_CAST(slotset)
                        DBGOUT(slotset:GetName())
                        if (slotset:GetName() == slotsetname) then
                            --一覧取得
                            DBGOUT("おｋ")
                            for i = 0, slotset:GetSlotCount() - 1 do
                                local slot = slotset:GetSlotByIndex(i)
                                local icon = slot:GetIcon();
                                if (icon) then
                                    local iconInfo = icon:GetInfo();
                                    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
                                    local itemObj = GetIES(invItem:GetObject());
                                    session.AddItemIDWithAmount(iconInfo:GetIESID(), tostring(invItem.count));
                                    cnt = cnt + 1
                                end
                            end
                            break
                        end
                    end
                else
                    if (baseidcls.TreeGroupCaption == treegroupcaption) then
                        
                        session.AddItemIDWithAmount(guid, tostring(invItem.count));
                        cnt = cnt + 1
                    end
                end
            
            end
            if (cnt > 0) then
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), frame:GetUserIValue("HANDLE"));
            end
        
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    
    }

end
function YAI_SLOT_LIMIT_FIRSTTAB()
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    
    return (slotCount-1) + (g.maxtabs - 1) * (g.countpertab-1)
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
function YAI_ON_MSG(frame, msg, argStr, argNum)
    
    if msg == 'ACCOUNT_WAREHOUSE_ITEM_LIST' then
        YAI_UPDATE()
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_IN' then
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_ADD' then
        DebounceScript("YAI_UPDATE", 1, 0, 0)
        YAI_UPDATE_STATUS(1)
        --YAI_ADD_TARGETED(argStr)
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_REMOVE' then
        
        YAI_REMOVE_TARGETED(argStr)
        DebounceScript("YAI_UPDATE", 3.0, 0)
        YAI_UPDATE_STATUS(-1)
    elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT' then
        YAI_UPDATE_TARGETED(argStr)
        DebounceScript("YAI_UPDATE", 3, 0, 0)
    else
        YAI_UPDATE()
    end

end
function YAI_ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, msg, argStr, argNum, tab_index)
    --disabled function for lightweight
    ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD(frame, msg, argStr, argNum, tab_index)
    if (ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OVERRIDE ~= nil) then
        ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OVERRIDE(frame, msg, argStr, argNum, tab_index)
    end
end
function YAI_GET_SLOTSET_NAME_BY_ITEMGUID(itemGUID)
    local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, itemGUID) or session.GetInvItemByGuid(itemGUID)
    local itemObj = GetIES(invItem:GetObject())
    local baseid = GetInvenBaseID(itemObj.ClassID)
    local cls = GetClassByNumProp("inven_baseid", "BaseID", baseid);
    
    local baseidcls = cls
    if baseidcls == nil then
        return nil;
    end
    
    local slotsetname = 'sset_' .. baseidcls.ClassName
    if baseidcls.MergedTreeTitle ~= "NO" then
        slotsetname = 'sset_' .. baseidcls.MergedTreeTitle
    end
    return slotsetname

end
function YAI_ADD_TARGETED(itemguid)
    EBI_try_catch{
        try = function()
            DBGOUT("ADD")
            local frame = ui.GetFrame("yaireplacement")
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, itemguid) or session.GetInvItemByGuid(itemguid)
            local slotsetname = YAI_GET_SLOTSET_NAME_BY_ITEMGUID(itemguid)
            DBGOUT("hgoe" .. slotsetname)
            local slotset = frame:GetChildRecursively(slotsetname)
            AUTO_CAST(slotset)
            slotset:SetSlotCount(slotset:GetSlotCount() + 1)
            slotset:CreateSlots()
            
            local slot = slotset:GetSlotByIndex(slotset:GetSlotCount() - 1);
            
            slot:ClearIcon()
            YAI_DRAW_ITEM(invItem, slot)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_UPDATE_TARGETED(itemguid)
    EBI_try_catch{
        try = function()
            
            DBGOUT("UPDATE")
            local frame = ui.GetFrame("yaireplacement")
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, itemguid);
            local slotsetname = YAI_GET_SLOTSET_NAME_BY_ITEMGUID(itemguid)
            DBGOUT(slotsetname)
            local slotset = frame:GetChildRecursively(slotsetname)
            AUTO_CAST(slotset)
            local slot = GET_SLOT_BY_ITEMID(slotset, itemguid);
            if(slot~=nil)then
                slot:ClearIcon()
                slot:SetSkinName("None")
                YAI_DRAW_ITEM(invItem, slot)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_REMOVE_TARGETED(itemguid)
    EBI_try_catch{
        try = function()
            
            DBGOUT("REMOVE")
            local frame = ui.GetFrame("yaireplacement")
            
            YAI_REMOVERECURSE_GUID(frame, itemguid)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_REMOVERECURSE_GUID(parent, guid)
    EBI_try_catch{
        try = function()
            
            for i = 0, parent:GetChildCount() - 1 do
                local child = parent:GetChildByIndex(i)
                
                if (string.find(child:GetClassString(), "CSlotSet")) then
                    AUTO_CAST(child)
                    for j = 0, child:GetSlotCount() - 1 do
                        local slot = child:GetSlotByIndex(j)
                        local icon = slot:GetIcon();
                        if (icon ~= nil) then
                            local iconInfo = icon:GetInfo();
                            
                            if (iconInfo:GetIESID() == guid) then
                                slot:ClearIcon()
                                slot:SetSkinName("invenslot2")
                                slot:SetText("")
                                slot:RemoveAllChild()
                                DBGOUT("removed")
                                break;
                            end
                        
                        end
                    end
                else
                    YAI_REMOVERECURSE_GUID(child, guid)
                end
            
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function YAI_DRAW_ITEM(invItem, slot)
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

function YAI_INSERT_ITEM_TO_TREE(frame, tree, invItem, itemCls, baseidcls, typeStr)
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
        local slotsettitle = 'ssettitle_' .. baseidcls.ClassName;
        if baseidcls.MergedTreeTitle ~= "NO" then
            slotsettitle = 'ssettitle_' .. baseidcls.MergedTreeTitle
        end
        
        
        local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)
        
        newSlotsname:SetEventScript(ui.RBUTTONUP, "YAI_TREE_CONTEXT")
        newSlotsname:SetEventScriptArgString(ui.RBUTTONUP, typeStr)
        
        g.tree[typeStr] = g.tree[typeStr] or {}
        g.tree[typeStr][#g.tree[typeStr] + 1] = {
            treegroup = treegroupname,
            treegroupcaption = newSlotsname:GetText():gsub("%(.*%)", ""),
            slotsetname = slotsetname,
        }
  
        MAKE_INVEN_SLOTSET_AND_TITLE(tree, treegroup, slotsetname, baseidcls);
        INVENTORY_CATEGORY_OPENOPTION_CHECK(tree:GetName(), baseidcls.ClassName);
    end
    local slotset = GET_CHILD_RECURSIVELY(tree, slotsetname, 'ui::CSlotSet');
    local slotCount = slotset:GetSlotCount();
    local slotindex = slotCount;
    
    --검색 기능
    local slot = nil;
    
    
    local cnt = GET_SLOTSET_COUNT(tree, baseidcls);
    -- 저장된 템의 최대 인덱스에 따라 자동으로 늘어나도록. 예를들어 해당 셋이 10000부터 시작하는데 10500 이 오면 500칸은 늘려야됨
    while slotCount <= cnt do
        slotset:ExpandRow()
        slotCount = slotset:GetSlotCount();
    end
    
    slot = slotset:GetSlotByIndex(cnt);
    cnt = cnt + 1;
    slotset:SetUserValue("SLOT_ITEM_COUNT", cnt)
    
    
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

function YAI_UPDATE_STATUS(inc)
    local awframe = ui.GetFrame("accountwarehouse")
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local isShowMap = {};
    local sortedCnt = sortedGuidList:Count();
    
    local invItemCount = YAI_COUNT();
    --スロット残数を表示
    local itemcnt = GET_CHILD_RECURSIVELY(awframe, "itemcnt");
    itemcnt:SetFormat("{@st42}%s/%s")
    
    if (inc) then
        local prevcnt = tonumber(itemcnt:GetTextByKey("cnt"))
        prevcnt = prevcnt + inc
        itemcnt:SetTextByKey('cnt', invItemCount);
    else
        itemcnt:SetTextByKey('cnt', invItemCount);
    end
    
    itemcnt:SetTextByKey('slotmax', YAI_SLOT_LIMIT_FIRSTTAB());
    itemcnt:UpdateFormat()
end
function YAI_EXEC_ON_RBUTTON(awframe, numberString, inputFrame)
    
    local itemID = inputFrame:GetUserValue("ArgString");
    
    
    session.ResetItemList();
    session.AddItemID(itemID, tonumber(numberString));
    item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
end
function YAI_ON_LBUTTON(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            local iconInfo = icon:GetInfo();
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
            local obj = GetIES(invItem:GetObject());
            DBGOUT("hire")
            session.ResetItemList();
            local cnt = math.min(10, invItem.count)
            if (keyboard.IsKeyPressed("LSHIFT") == 1) then
                cnt = invItem.count
            end
            if (keyboard.IsKeyPressed("LCTRL") == 1) then
                if (keyboard.IsKeyPressed("LALT") == 1) then
                    local baseid = GetInvenBaseID(obj.ClassID)
                    local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
                    local titleName = baseidcls.ClassName
					if baseidcls.MergedTreeTitle ~= "NO" then
						titleName = baseidcls.MergedTreeTitle
					end
                    YAI_ON_LBUTTON_CTRL_LALT(titleName)
                else
                    DBGOUT("INAA")
                    YAI_ON_LBUTTON_CTRL(obj.ClassID)
                end
                return
            end
            DBGOUT("TAKE")
            session.AddItemID(iconInfo:GetIESID(), cnt);
            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ON_LBUTTON_CTRL_LALT(titlename)
    EBI_try_catch{
        try = function()
          
            DBGOUT("INA")
            local awframe = ui.GetFrame("accountwarehouse");
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();    
            local sortedCnt = sortedGuidList:Count();    
   
            --同一CLSID搬出
            ui.SysMsg("分類で搬出します:"..titlename.."{nl}作業中はほかの操作をしないでください")
            local delay = 0
            session.ResetItemList();
            local itemmap={}
            local limit=g.limit
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local obj = GetIES(invItem:GetObject());
                local baseid = GetInvenBaseID(obj.ClassID)
                local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
                local titleName = baseidcls.ClassName
                if baseidcls.MergedTreeTitle ~= "NO" then
                    titleName = baseidcls.MergedTreeTitle
                end
                if invItem ~= nil then
                    if (titlename == titleName) and (not itemmap[invItem:GetIESID()]) then
                        --add
                        DBGOUT("GO "..tostring(clsid).."/"..tostring(invItem.type))
                        --ReserveScript(string.format('YAI_TAKE_ITEM("%s")', invItem:GetIESID()), delay)
                        session.AddItemID(invItem:GetIESID(), invItem.count);
                        itemmap[invItem:GetIESID()]=true
                        delay = delay + 0.1
                        limit=limit-1
                        if(limit==0)then
                            break
                        end
                    end
                end
            end

            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ON_LBUTTON_CTRL(clsid)
    EBI_try_catch{
        try = function()
          
            DBGOUT("INA")
            local awframe = ui.GetFrame("accountwarehouse");
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();    
            local sortedCnt = sortedGuidList:Count();    
  
            --同一CLSID搬出
            ui.SysMsg("同一CLSIDで搬出します{nl}作業中はほかの操作をしないでください")
            local delay = 0
            session.ResetItemList();
            local itemmap={}
            local limit=g.limit
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local obj = GetIES(invItem:GetObject());
            
                if invItem ~= nil then
                    if (clsid == obj.ClassID) and (not itemmap[invItem:GetIESID()]) then
                        --add
                        DBGOUT("GO "..tostring(clsid).."/"..tostring( obj.ClassID))
                        --ReserveScript(string.format('YAI_TAKE_ITEM("%s")', invItem:GetIESID()), delay)
                        session.AddItemID(invItem:GetIESID(), invItem.count);
                        itemmap[invItem:GetIESID()]=true
                        delay = delay + 0.1
                        limit=limit-1
                        if(limit==0)then
                            break
                        end
                    end
                end
            end

            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_TAKE_ITEM(iesid)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE,iesid)
            session.ResetItemList();
            session.AddItemID(iesid, invItem.count);
            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ON_RBUTTON(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            if (icon == nil) then
                return
            
            end
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

function YAI_TESTCOROUTINE()
    local colo = coroutine.create(
        function( init )
            if init == nil then init = 0 end
    
            local i = init
            while i < 10 do
                coroutine.yield(i)
                i = i+1
            end
            assert( false )
    
            return -1
        end
    )
    
    repeat
        local bStat, vRet = coroutine.resume( colo, 5 )
        if bStat then
            print("->", vRet )
        else
            print("assert! -> ", vRet)
        end
    until coroutine.status( colo ) == "dead"
end
