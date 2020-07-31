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
local libsearch
libsearch=libsearch or LIBITEMSEARCHER_V1_0 --dummy


g.version = 1
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "yaaccountinventory"
g.debug = false
g.w = 650
g.h = 570
g.maxtabs = g.maxtabs or 1
g.countpertab = 70
g.limit = 50
g.tree = g.tree or {}

g.automata = nil
local function IsJpn()
    if (option.GetCurrentCountry() == "Japanese") then
        return true
    else
        return false
    end
end
local function L_(str)
    if (g.notrans) then
        return str
    end
    if (IsJpn() and YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str]) then
        return YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].jpn
    elseif (YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str] and YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].eng) then
        return YETANOTHERACCOUNTINVENTORY_LANGUAGE_DATA[str].eng
    else
        return str
    end
end
local LS = LIBSTORAGEHELPERV1_3
--定数
local c = {}

c.action = {
    {name = "NONE", text = L_("(None)"), needvalue = false, depositfunc = nil, withdrawfunc = nil},
    {name = "DWCOUNT", text = L_("Take/Put number of VALUE"), needvalue = true,
        depositfunc = function(invItem, value)
            LS.target = IT_ACCOUNT_WAREHOUSE
            LS.putitem(invItem:GetIESID(), value)
        end,
        withdrawfunc = function(invItem, value)
            LS.target = IT_ACCOUNT_WAREHOUSE
            LS.takeitem(invItem:GetIESID(), value)
        end},
    {name = "DWSTACK", text = L_("Take/Put whole stack"), needvalue = false, depositfunc = function(invItem, value)
        LS.target = IT_ACCOUNT_WAREHOUSE
        LS.putitem(invItem:GetIESID())
    end,
    withdrawfunc = function(invItem, value)
        LS.target = IT_ACCOUNT_WAREHOUSE
        LS.takeitem(invItem:GetIESID())
    end},
    {name = "DWCLSID", text = L_("Take/Put same CLSID"), needvalue = false,
        depositfunc = function(invItem, value)
            
            YAI_DEPOSIT_BY_CLSID(invItem.type)
        end,
        withdrawfunc = function(invItem, value)
            YAI_WITHDRAW_BY_CLSID(invItem.type)
        end
    },
    {name = "DWCATEGORY", text = L_("Take/Put same category"), needvalue = false,
        depositfunc = function(invItem, value)
            local obj = GetIES(invItem:GetObject());
            local baseid = GetInvenBaseID(obj.ClassID)
            local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
            local titleName = baseidcls.ClassName
            if baseidcls.MergedTreeTitle ~= "NO" then
                titleName = baseidcls.MergedTreeTitle
            end
            YAI_DEPOSIT_BY_CATEGORY(titleName)
        end,
        withdrawfunc = function(invItem, value)
            local obj = GetIES(invItem:GetObject());
            local baseid = GetInvenBaseID(obj.ClassID)
            local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
            local titleName = baseidcls.ClassName
            if baseidcls.MergedTreeTitle ~= "NO" then
                titleName = baseidcls.MergedTreeTitle
            end
            YAI_WITHDRAW_BY_CATEGORY(titleName)
        end
    },
    {name = "DWDIALOG", text = L_("Ask how many Take/Put"),
        needvalue = false
        , depositfunc = function(invItem, value)
            INPUT_NUMBER_BOX(ui.GetFrame(g.framename), L_('How many put items?'),
                'YAI_EXEC_PUTITEM', invItem.count, 1, invItem.count, nil,  invItem:GetIESID(), 1)
        end,
        withdrawfunc = function(invItem, value)
            INPUT_NUMBER_BOX(ui.GetFrame(g.framename), L_('How many take items?'),
                'YAI_EXEC_TAKEITEM', invItem.count, 1, invItem.count, nil,  invItem:GetIESID(), 1)
        end},
    {name = "LOCK", text = L_("Lock/Unlock"), needvalue = false, depositfunc = function(invItem, value)
        local state = 1
        if true == invItem.isLockState then
            state = 0;
        end
        
        session.inventory.SendLockItem(invItem:GetIESID(), state);
        ReserveScript('imcAddOn.BroadMsg("ITEM_PROP_UPDATE","' .. invItem:GetIESID() .. '")', 0.5);
    end, withdrawfunc = function() end},
}

g.constants = c

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
local function YAI_FINDACTION(name)
    for k, v in ipairs(c.action) do
        if (v.name == name) then
            return v
        
        end
    end
    return nil
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
    if (ctrl == nil) then
        
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

function YAACCOUNTINVENTORY_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_LIST", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_ADD", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_REMOVE", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT", "YAI_ON_MSG");
            addon:RegisterMsg("ACCOUNT_WAREHOUSE_ITEM_IN", "YAI_ON_MSG");
            addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "YAI_ON_OPEN_ACCOUNTWAREHOUSE");
            addon:RegisterMsg("FPS_UPDATE", "YAI_SHOW");
            addon:RegisterMsg("GAME_START", "YAI_GAME_START");
            addon:RegisterMsg("GAME_START_3SEC", "YAI_3SEC");
            addon:RegisterMsg("YAI_UPDATED_CONFIG", "YAI_ON_MSG");
            addon:RegisterOpenOnlyMsg('INV_ITEM_LIST_GET', 'YAI_INVENTORY_ON_MSG');
            acutil.setupHook(YAI_ACCOUNTWAREHOUSE_OPEN, "ACCOUNTWAREHOUSE_OPEN")
            acutil.setupHook(YAI_ACCOUNTWAREHOUSE_CLOSE, "ACCOUNTWAREHOUSE_CLOSE")
            acutil.setupHook(YAI_ACCOUNT_WAREHOUSE_MAKE_TAB, "ACCOUNT_WAREHOUSE_MAKE_TAB")
            acutil.setupHook(YAI_ON_ACCOUNT_WAREHOUSE_ITEM_LIST, "ON_ACCOUNT_WAREHOUSE_ITEM_LIST")
            local timer = GET_CHILD(frame, "addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("YAI_ON_TIMER");
            timer:Start(1.2);
           
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
function YAI_GAME_START()
    LS = LIBSTORAGEHELPERV1_3
    libsearch=LIBITEMSEARCHER_V1_0
end
function YAI_3SEC()
    if (true == session.loginInfo.IsPremiumState(ITEM_TOKEN)) then
        g.maxtabs = 5
    
    else
        g.maxtabs = 1
    
    end
end
function YAI_ON_TIMER()
    if (ui.GetFrame("accountwarehouse"):IsVisible() == 1) then
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
            YAI_LOAD_SETTINGS()
          
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ACTIVATE_MOUSEBUTTON()
    if (ui.GetFrame("accountwarehouse"):IsVisible() == 1) then
        local invframe = ui.GetFrame("inventory")
        INVENTORY_SET_CUSTOM_RBTNDOWN("YAI_ACCOUNT_WAREHOUSE_INV_RBTN")
        
        if (g.settings.enabledrag==false) then
            SET_INV_LBTN_FUNC(invframe, "YAI_ACCOUNT_WAREHOUSE_INV_LBTN")
        
        else
            SET_INV_LBTN_FUNC(invframe, "None")
        
        end
      
    end
end
function YAI_DEACTIVATE_MOUSEBUTTON()
    INVENTORY_SET_CUSTOM_RBTNDOWN("None")
    SET_INV_LBTN_FUNC(ui.GetFrame("inventory"), "None");
end

function YAI_ACCOUNTWAREHOUSE_CLOSE(frame)
    local overlap = ui.GetFrame("yaireplacement")
    overlap:ShowWindow(0)
    --g.suggester:closeSearch()
    ACCOUNTWAREHOUSE_CLOSE_OLD(frame)
    
    YAI_DEACTIVATE_MOUSEBUTTON()
end
function YAI_DEFAULTSETTINGS()
    return {
        version = g.version,
        --有効/無効
        enable = false,
        --フレーム表示場所
        position = {
            x = 436,
            y = 171
        },
        speed = 0.8,
        stacklimit = 50,
        enabledrag = false,
        keybinds = {
            {trigger = "L", modifiers = {}, action = "DWCOUNT", value = 10},
            {trigger = "L", modifiers = {"LSHIFT"}, action = "DWSTACK", value = 0},
            {trigger = "L", modifiers = {"LCTRL"}, action = "DWCLSID", value = 0},
            {trigger = "L", modifiers = {"LCTRL", "LALT"}, action = "DWCATEGORY", value = 0},
            {trigger = "R", modifiers = {}, action = "DWCOUNT", value = 1},
            {trigger = "R", modifiers = {"LSHIFT"}, action = "DWDIALOG", value = 0},
            {trigger = "R", modifiers = {"LALT"}, action = "LOCK", value = 0},
        }
    }
end
function YAI_DEFAULTPERSONALSETTINGS()
    return {
        version = g.version
    }
end
function YAI_SAVE_SETTINGS()
    DBGOUT("SAVE_SETTINGS")

    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(session.GetMySession():GetCID()))
    DBGOUT("psn" .. g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

function YAI_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTINGS " .. tostring(session.GetMySession():GetCID()))
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = YAI_DEFAULTSETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = YAI_DEFAULTSETTINGS().version
        end
    end
    DBGOUT("LOAD_PSETTINGS " .. g.personalsettingsFileLoc)
    g.personalsettings = {}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings = YAI_DEFAULTPERSONALSETTINGS()
    
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = YAI_DEFAULTPERSONALSETTINGS().version
        end
    end
    local upc = YAI_UPGRADE_SETTINGS()
    local upp = YAI_UPGRADE_PERSONALSETTINGS()
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc or upp then
        YAI_SAVE_SETTINGS()
    end
end
function YAI_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function YAI_UPGRADE_PERSONALSETTINGS()
    local upgraded = false
    return upgraded
end

function YAI_COUNT()
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidlist = itemList:GetSortedGuidList();
    local cnt = itemList:Count();
    local rcnt = 0
    for i = 0, cnt - 1 do
        local guid = guidlist:Get(i);
        local invItem = itemList:GetItemByGuid(guid)
        local invItem_obj = GetIES(invItem:GetObject());
        if invItem_obj.ClassName ~= MONEY_NAME then
            rcnt = rcnt + 1
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
    local offset = 0
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
            money_offset = 1
        end
    end
    local first = 0
    for i = 0, slotCount do
        if (__set[i] ~= nil) then
            first = first + 1
        
        end
    end
    -- -1 is preventaion tos bug
    DBGOUT(string.format("prevent %d/%d", first, slotCount - 1))
    if (first >= (slotCount - 1)) then
        
        for i = 0, g.countpertab do
            __set[i] = {mode = 1}
        end
    end
    --prevent tos bug
    for i = 1, g.maxtabs do
        local count = 0
        for j = g.countpertab * i, g.countpertab * (i + 1) - 1 do
            if (__set[j] ~= nil and __set[j].mode == 1) then
                count = count + 1
            
            end
        end
        if (count >= (g.countpertab - 1)) then
            for j = g.countpertab * i, g.countpertab * (i + 1) - 1 do
                __set[j] = {mode = 1}
            end
        end
    end
    
    local index = start_index
    
    for k = start_index, last_index + 1 do
        index = k
        if __set[k] == nil then
            offset = offset - 1
            if (offset <= 0) then
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
function YAI_HANDLE_ACTION(invItem, btntype, towarehouse)
    
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            local frame = ui.GetFrame(g.framename);
            local detaillevel = -1
            local keybind = nil
            for k, v in ipairs(g.settings.keybinds) do
                if (v.trigger == btntype) then
                    local succ = true
                    for _, vv in ipairs(v.modifiers) do
                        DBGOUT("MODIFIER:"..vv)
                        if (vv~="" and keyboard.IsKeyPressed(vv) ~= 1) then
                            succ = false
                            break
                        end
                    end
                    if (succ and detaillevel <= #v.modifiers) then
                        
                        --OK
                        keybind = v
                        detaillevel = #v.modifiers
                    end
                end
            end
            if (keybind ~= nil) then
                -- do
                local action = YAI_FINDACTION(keybind.action)
                if (towarehouse) then
                    DBGOUT("towarehouse")
                    if (action.depositfunc) then
                        action.depositfunc(invItem, keybind.value)
                    else
                        DBGOUT("No function")
                    end
                else
                    DBGOUT("toinventory")
                    if (action.withdrawfunc) then
                        action.withdrawfunc(invItem, keybind.value)
                    else
                        DBGOUT("No function")
                    end
                end
            else
                DBGOUT("Not assigned.")
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function YAI_DEPOSIT_BY_CATEGORY(category)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            if (category == nil) then
                
                return
            
            end
            ui.SysMsg(string.format(L_("Put by Category:%s.{nl}Do not perform any other operations while in progress."), category))
            
            local delay = 1
            local limit =g.settings.stacklimit
            
            local itemList = session.GetInvItemList();
            local guidList = itemList:GetGuidList();
            local invItemCount = guidList:Count();
            
            for i = 0, invItemCount - 1 do
                local invItem = session.GetInvItemByGuid(guidList:Get(i));
                if (invItem ~= nil) then
                    local itemObj = GetIES(invItem:GetObject())
                    if (itemObj ~= nil) then
                        
                        local baseid = GetInvenBaseID(itemObj.ClassID)
                        local baseidcls = GetClassByNumProp("inven_baseid", "BaseID", baseid)
                        local titleName = baseidcls.ClassName
                        if baseidcls.MergedTreeTitle ~= "NO" then
                            titleName = baseidcls.MergedTreeTitle
                        end
                        if titleName == category then
                            
                            limit = limit - 1
                            ReserveScript('YAI_EXEC_ACCOUNT_WAREHOUSE_INV_LBTN("' .. invItem:GetIESID() .. '")', delay)
                            delay = delay + g.settings.speed
                        end
                        if (limit == 0) then
                            break
                        end
                    end
                end
            end
            ReserveScript('ui.SysMsg("'..L_("Complete.")..'")', delay)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function YAI_DEPOSIT_BY_CLSID(clsid)
    EBI_try_catch{
        try = function()
            local awframe = ui.GetFrame("accountwarehouse");
            if (clsid == nil) then
                
                return
            
            end
            
            ui.SysMsg(string.format(L_("Put by CLSID.{nl}Do not perform any other operations while in progress.")))
            
            local delay = 1
            local limit = g.settings.stacklimit
            
            local itemList = session.GetInvItemList();
            local guidList = itemList:GetGuidList();
            local invItemCount = guidList:Count();
            
            for i = 0, invItemCount - 1 do
                
                local invItem = session.GetInvItemByGuid(guidList:Get(i));
                if (invItem ~= nil) then
                    local itemObj = GetIES(invItem:GetObject())
                    if (itemObj ~= nil) then
                        DBGOUT("CC" .. tostring(itemObj.ClassID))
                        if itemObj.ClassID == clsid then
                            
                            limit = limit - 1
                            
                            ReserveScript('YAI_EXEC_ACCOUNT_WAREHOUSE_INV_LBTN("' .. invItem:GetIESID() .. '")', delay)
                            delay = delay + g.settings.speed
                        end
                        if (limit == 0) then
                            break
                        end
                    end
                end
            end
            
            ReserveScript('ui.SysMsg("' .. L_("Complete.") .. '")', delay)
        
        
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
            if (invItem == nil) then
                return
            
            end
            local obj = GetIES(invItem:GetObject())
            if (not YAI_CHECKITEM(invItem, true)) then
                return
            end
            LS.target = IT_ACCOUNT_WAREHOUSE
            LS.putitem(iesid)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_EXEC_ACCOUNT_WAREHOUSE_INV_RBTN(awframe, numberString, inputFrame)
    
    local itemID = inputFrame:GetUserValue("ArgString");
    
    LS.target = IT_ACCOUNT_WAREHOUSE
    LS.putitem(itemID, tonumber(numberString))

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
            
            YAI_HANDLE_ACTION(invItem, "R", true)
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

            YAI_HANDLE_ACTION(invItem, "L", true)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end

function YAI_EXEC_TAKEITEM(awframe, numberString, inputFrame)
    local itemID = inputFrame:GetUserValue("ArgString");
    LS.target = IT_ACCOUNT_WAREHOUSE
    LS.takeitem(itemID, tonumber(numberString))
end

function YAI_EXEC_PUTITEM(awframe, numberString, inputFrame)
    local itemID = inputFrame:GetUserValue("ArgString");
    LS.target = IT_ACCOUNT_WAREHOUSE
    LS.putitem(itemID, tonumber(numberString))
end
function YAI_CHECKITEM(invItem, silent)
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    local sortedCnt = sortedGuidList:Count();
    local frame = ui.GetFrame("accountwarehouse")
    local obj = GetIES(invItem:GetObject())
    if YAI_SLOT_LIMIT_FIRSTTAB() <= YAI_COUNT() then
        if (not silent) then
            ui.SysMsg(ClMsg('CannotPutBecauseMasSlot'));
        end
        return false;
    
    end
    if true == invItem.isLockState then
        if (not silent) then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
        end
        return;
    end
    
    local itemCls = GetClassByType("Item", obj.ClassID);
    if itemCls.ItemType == 'Quest' then
        if (not silent) then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
        end
        return;
    end
    
    local enableTeamTrade = TryGetProp(itemCls, "TeamTrade");
    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        if (not silent) then
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
            if (g.debug) then
                overlap:SetOffset(10, 600)
                --タブ非表示
                frame:GetChildRecursively("accountwarehouse_tab"):ShowWindow(1)
                frame:GetChildRecursively("slotgbox"):ShowWindow(1)
                frame:GetChildRecursively("slotset"):ShowWindow(1)
                frame:GetChildRecursively("receiveitem"):ShowWindow(1)
            else
                overlap:SetOffset(10, 200)
                --タブ非表示
                frame:GetChildRecursively("accountwarehouse_tab"):ShowWindow(0)
                frame:GetChildRecursively("slotgbox"):ShowWindow(0)
                frame:GetChildRecursively("slotset"):ShowWindow(0)
                frame:GetChildRecursively("receiveitem"):ShowWindow(0)
            end
            
            overlap:EnableHitTest(1)
            overlap:EnableHittestFrame(1)
            --fix height
            g.h=frame:GetHeight()-1080+570
            local w = g.w
            local h = g.h
            overlap:Resize(w, h+300)
            frame:SetLayerLevel(94)
            overlap:EnableHittestFrame(false)

            overlap:SetLayerLevel(95)
            local gbox = overlap:GetChild("inventoryGbox")
            AUTO_CAST(gbox)
            local gbox2 = overlap:GetChildRecursively("inventoryitemGbox")
            AUTO_CAST(gbox2)
           
            gbox:Resize(w, h-30)
            gbox2:Resize(w - 32, h - 2-35)
       
            
            --search gbox
            --[[
                <groupbox name="searchSkin" parent="searchGbox" rect="0 0 350 30" margin="5 0 0 5" layout_gravity="right bottom" draw="true" hittestbox="true" resizebyparent="false" scrollbar="false" skin="test_edit_skin"/>
                <edit name="ItemSearch" parent="searchSkin" rect="0 0 270 26" margin="2 0 0 0" layout_gravity="left center" OffsetForDraw="0 -1" clicksound="button_click_big" drawbackground="false" fontname="white_18_ol" maxlen="40" oversound="button_over" skin="None" textalign="left top" typingscp="SEARCH_ITEM_INVENTORY_KEY" typingsound="chat_typing"/>
                <button name="inventory_serch" parent="searchSkin" rect="0 0 60 38" margin="0 0 0 0" layout_gravity="right center" LBtnUpArgNum="" LBtnUpScp="SEARCH_ITEM_INVENTORY" MouseOffAnim="btn_mouseoff" MouseOnAnim="btn_mouseover" clicksound="button_click_big" image="inven_s" oversound="button_over" stretch="true" texttooltip="{@st59}입력한 이름으로 검색합니다{/}"/>
                
                
            ]]
            local searchgbox= overlap:CreateOrGetControl("groupbox", "searchGbox", 10, h-35,w, 35)
            
            local searchSkin= searchgbox:CreateOrGetControl("groupbox", "searchSkin", 0, 5,w, 30)
            AUTO_CAST(searchgbox)
            AUTO_CAST(searchSkin)
            searchSkin:SetSkinName("test_edit_skin")
            local ItemSearch= searchSkin:CreateOrGetControl("edit", "ItemSearch", 0, 0,w-60, 30)
            AUTO_CAST(ItemSearch)
            ItemSearch:SetFontName("white_18_ol")
            ItemSearch:SetTypingSound("chat_typing")
            ItemSearch:SetOverSound("button_over")
            ItemSearch:SetSkinName("None")
            ItemSearch:SetEventScript(ui.ENTERKEY,"YAI_ON_ENTER_SEARCH")
            local inventory_serch= searchSkin:CreateOrGetControl("button", "inventory_serch", w-58, -2,60, 30)
            AUTO_CAST(inventory_serch)
            inventory_serch:SetOverSound("button_over")
            inventory_serch:SetClickSound("button_click_big")
            inventory_serch:SetImage("inven_s")
            inventory_serch:EnableImageStretch(true)
            inventory_serch:SetEventScript(ui.LBUTTONUP,"YAI_ON_SEARCH")
            --YAI config
            local btn = frame:CreateOrGetControl("button", "yaiconfig", 400, 80 + 40, 100, 30)
            AUTO_CAST(btn)
            btn:SetText("{ol}" .. L_("YAI Config"))
            btn:SetEventScript(ui.LBUTTONUP, "YAI_OPEN_CONFIG")
            g.searcher=libsearch.Searcher()
            g.suggester=libsearch.SuggestLister():init(g.searcher,ItemSearch,"yaisearch")

            YAI_UPDATE()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ON_ENTER_SEARCH()
    if g.suggester:isShown() then
        g.suggester:determine()
    else
        --一定時間遅延させる
        DebounceScript("YAI_ON_SEARCH",1)
    end
end
function YAI_ON_SEARCH()
    local overlap = ui.GetFrame("yaireplacement")
    local edit=overlap:GetChildRecursively("ItemSearch")
    local text=edit

    YAI_UPDATE()
end
function YAI_OPEN_CONFIG()
    ui.ToggleFrame("yaiconfig")
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
            
            
            local baseidclslist, baseidcnt = GetClassList("inven_baseid");
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
            
            
            local filter=g.suggester:getFilter()
            g.searcher:clearItems()

            for i = 0, invItemCount - 1 do
                local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i));
                if invItem ~= nil then
                    local pass=true
                    local obj = GetIES(invItem:GetObject())
                    local class = GetClassByType("Item", obj.ClassID)
                    local realname = dictionary.ReplaceDicIDInCompStr(class.Name)
                    if #filter>0 then
                      
                        for _,v in ipairs(filter) do
                            if not libsearch.utf8lib.find(realname,v) then
                                pass=false
                            end
                        end
                    end
                    g.searcher:addItem(realname,invItem)
                    if pass then
                        invItem.index=index_count
                        invItemList[index_count] = invItem
                        index_count = index_count + 1
                    end
                end
            end


            local sortType = 3

            --@TODO ソート処理をここに

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

function YAI_SLOT_LIMIT_FIRSTTAB()
    local account = session.barrack.GetMyAccount();
    local slotCount = account:GetAccountWarehouseSlotCount();
    
    return (slotCount - 1) + (g.maxtabs - 1) * (g.countpertab - 1)
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
        --no op
        elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_ADD' then
        DebounceScript("YAI_UPDATE", 1.0, 0)
        YAI_UPDATE_STATUS(1)
        --YAI_ADD_TARGETED(argStr)
        elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_REMOVE' then
            
            YAI_REMOVE_TARGETED(argStr)
            DebounceScript("YAI_UPDATE", 3.0, 0)
            YAI_UPDATE_STATUS(-1)
        elseif msg == 'ACCOUNT_WAREHOUSE_ITEM_CHANGE_COUNT' then
            YAI_UPDATE_TARGETED(argStr)
            DebounceScript("YAI_UPDATE", 3.0, 0)
        elseif msg == 'YAI_UPDATED_CONFIG' then
            YAI_UPDATE()
        else
            YAI_UPDATE()
    end

end
function YAI_INVENTORY_ON_MSG()
    if(ui.GetFrame("accountwarehouse"):IsVisible()==1)then
        YAI_UPDATE()
    end
end
function YAI_ON_ACCOUNT_WAREHOUSE_ITEM_LIST(frame, msg, argStr, argNum, tab_index)
    --disabled function for lightweight
    if(g.debug==true)then
        ON_ACCOUNT_WAREHOUSE_ITEM_LIST_OLD(frame, msg, argStr, argNum, tab_index)
    end
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
            if (slot ~= nil) then
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
    if (g.settings.enabledrag) then
        slot:EnableDrag(1)
    else
        slot:EnableDrag(0)
    end
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


function YAI_WITHDRAW_BY_CATEGORY(titlename)
    EBI_try_catch{
        try = function()
            
            DBGOUT("INA")
            local awframe = ui.GetFrame("accountwarehouse");
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local sortedCnt = sortedGuidList:Count();
            
            --同一CLSID搬出
            ui.SysMsg(string.format(L_("Take items by category:%s"), titlename))
            local delay = 0
            session.ResetItemList();
            local itemmap = {}
            local limit = g.settings.stacklimit
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
                        DBGOUT("GO " .. tostring(clsid) .. "/" .. tostring(invItem.type))
                        --ReserveScript(string.format('YAI_TAKE_ITEM("%s")', invItem:GetIESID()), delay)
                        session.AddItemID(invItem:GetIESID(), invItem.count);
                        itemmap[invItem:GetIESID()] = true
                        delay = delay + 0.1
                        limit = limit - 1
                        if (limit == 0) then
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
function YAI_WITHDRAW_BY_CLSID(clsid)
    EBI_try_catch{
        try = function()
            
            DBGOUT("INA")
            local awframe = ui.GetFrame("accountwarehouse");
            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local sortedCnt = sortedGuidList:Count();
            
            --同一CLSID搬出
            ui.SysMsg(L_("Take items by CLSID."))
            local delay = 0
            session.ResetItemList();
            local itemmap = {}
            local limit = g.settings.stacklimit
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local obj = GetIES(invItem:GetObject());
                
                if invItem ~= nil then
                    if (clsid == obj.ClassID) and (not itemmap[invItem:GetIESID()]) then
                        --add
                        DBGOUT("GO " .. tostring(clsid) .. "/" .. tostring(obj.ClassID))
                        --ReserveScript(string.format('YAI_TAKE_ITEM("%s")', invItem:GetIESID()), delay)
                        session.AddItemID(invItem:GetIESID(), invItem.count);
                        itemmap[invItem:GetIESID()] = true
                        delay = delay + 0.1
                        limit = limit - 1
                        if (limit == 0) then
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
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
            session.ResetItemList();
            session.AddItemID(iesid, invItem.count);
            item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(), awframe:GetUserIValue("HANDLE"));
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function YAI_ON_LBUTTON(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            local awframe = ui.GetFrame("accountwarehouse");
            local icon = slot:GetIcon();
            if (icon == nil) then
                return
            
            end
            local iconInfo = icon:GetInfo();
            if (iconInfo == nil) then
                return
            end
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
            YAI_HANDLE_ACTION(invItem, "L", false)
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
            if (iconInfo == nil) then
                return
            end
            local invItem = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
            
            YAI_HANDLE_ACTION(invItem, "R", false)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
