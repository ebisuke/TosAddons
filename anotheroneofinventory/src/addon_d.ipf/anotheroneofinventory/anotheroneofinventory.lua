-- Anotheroneofinventory
local addonName = "ANOTHERONEOFINVENTORY"
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
g.framename = "anotheroneofinventory"
g.debug = false
g.resizing = nil
g.x = nil
g.y = nil
g.findstr = ""

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
for _, v in ipairs(g.filters) do
    g.filterbyname[v.name] = v
end
g.settings.filter = "All"
g.invitems = {}
g.checkedframe = nil
local tabsize = 22
local slotsize = 32

--ライブラリ読み込み
CHAT_SYSTEM("[AOI]loaded")
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

local function AUTO_CAST(ctrl)
    if(ctrl==nil)then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
	return ctrl;
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

local function _GET_SOCKET_ADD_VALUE(item, invItem, i)    
	
    if invItem:IsAvailableSocket(i) == false then
        return;
	end
	
	local gem = invItem:GetEquipGemID(i);
    if gem == 0 then
        return;
    end
    
	local gemExp = invItem:GetEquipGemExp(i);
	local roastingLv = invItem:GetEquipGemRoastingLv(i);
    local props = {};
    local gemclass = GetClassByType("Item", gem);
    local lv = GET_ITEM_LEVEL_EXP(gemclass, gemExp);
    local prop = geItemTable.GetProp(gem);
    local socketProp = prop:GetSocketPropertyByLevel(lv);
    local type = item.ClassID;
    local benefitCnt = socketProp:GetPropCountByType(type);
    for i = 0 , benefitCnt - 1 do
        local benefitProp = socketProp:GetPropAddByType(type, i);
        props[#props + 1] = {benefitProp:GetPropName(), benefitProp.value}
    end
    
    local penaltyCnt = socketProp:GetPropPenaltyCountByType(type);
    local penaltyLv = lv - roastingLv;
    if 0 > penaltyLv then
        penaltyLv = 0;
    end
    local socketPenaltyProp = prop:GetSocketPropertyByLevel(penaltyLv);
    for i = 0 , penaltyCnt - 1 do
        local penaltyProp = socketPenaltyProp:GetPropPenaltyAddByType(type, i);
        local value = penaltyProp.value
        penaltyProp:GetPropName()
        props[#props + 1] = {penaltyProp:GetPropName(), penaltyProp.value}
    end
    return props;
end

local function _GET_ITEM_SOCKET_ADD_VALUE(targetPropName, item)
	local invItem, where = GET_INV_ITEM_BY_ITEM_OBJ(item);
	if invItem == nil then
		return 0;
	end

    local value = 0;
    local sockets = {};
    if item.MaxSocket > 100 then item.MaxSocket = 0 end
    for i=0, item.MaxSocket - 1 do
        sockets[#sockets + 1] = _GET_SOCKET_ADD_VALUE(item, invItem, i);
    end

    for i = 1, #sockets do
        local props = sockets[i];
        for j = 1, #props do
            local prop = props[j]
            if prop[1] == targetPropName or ( (prop[1] == "PATK") and (targetPropName == "ATK")) then                
                value = value + prop[2];
            end
        end
    end
    return value;
end

function ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function ANOTHERONEOFINVENTORY_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {x = 300, y = 300, w = 300, h = 200}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    ANOTHERONEOFINVENTORY_UPGRADE_SETTINGS()
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()

end


function ANOTHERONEOFINVENTORY_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function ANOTHERONEOFINVENTORY_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            g.initialized = false
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('AOI', 'sysmenu_inv', 'another one of inventory', 'ANOTHERONEOFINVENTORY_TOGGLE_FRAME')
            addon:RegisterMsg('GAME_START_3SEC', 'AOI_INIT')
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            
            acutil.setupHook(AOI_UPDATE_INVENTORY_TOGGLE_ITEM, "TOGGLE_ITEM_SLOT_INVEN_ON_MSG")
            acutil.setupHook(AOI_INVENTORY_UPDATE_ICONS,"INVENTORY_UPDATE_ICONS")
            addon:RegisterMsg('INV_ITEM_ADD', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('INV_ITEM_REMOVE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('INV_DRAW_MONEY_TEXT', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_ITEM_REPAIR', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_ITEM_APPRAISAL', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('SWITCH_GENDER_SUCCEED', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('RESET_ABILITY_UP', 'AOI_INVENTORY_ON_MSG');
            --addon:RegisterMsg('ACCOUNT_UPDATE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterOpenOnlyMsg('INV_ITEM_LIST_GET', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterOpenOnlyMsg('INV_ITEM_CHANGE_COUNT', 'AOI_INVENTORY_ON_MSG');
            --addon:RegisterOpenOnlyMsg('ITEM_PROP_UPDATE', 'AOI_INVENTORY_ON_MSG');
            --addon:RegisterMsg('GAME_START', 'AOI_INVENTORY_ON_MSG');
            --addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'AOI_INVENTORY_ON_MSG');
            --addon:RegisterMsg('EQUIP_ITEM_LIST_UPDATE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_LOCK_STATE', 'AOI_INVENTORY_ON_MSG');
            --addon:RegisterMsg('UPDATE_TRUST_POINT', 'AOI_INVENTORY_ON_MSG');
            --  --コンテキストメニュー
            frame:SetEventScript(ui.RBUTTONDOWN, "AOI_ON_RCLICK")
            -- --ドラッグ
            frame:SetEventScript(ui.LBUTTONUP, "AOI_SAVE_POSITION")
            
            
            ANOTHERONEOFINVENTORY_LOAD_SETTINGS()
            
           
            --ui.GetFrame("anotheroneofinventory"):SetSkinName("None")

            if(not g.settings.noshow)then
                ui.GetFrame("anotheroneofinventory"):ShowWindow(1)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANOTHERONEOFINVENTORY_OPEN(frame)
    -- 開いてほしくないときは開かない
    if(g.settings.noshow)then
        frame = ui.GetFrame(g.framename)
        frame:ShowWindow(0)
    end

end
-- function ANOTHERONEOFINVENTORY_DO_SHOW(frame)
--     frame = ui.GetFrame(g.framename)
--     frame:ShowWindow(1)
--     g.settings.noshow=false
--     ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
-- end
-- function ANOTHERONEOFINVENTORY_DO_CLOSE(frame)
--     frame = ui.GetFrame(g.framename)
--     frame:ShowWindow(0)
--     g.settings.noshow=true
--     ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
-- end
function ANOTHERONEOFINVENTORY_TOGGLE_FRAME(frame)
    g.settings.noshow=not (not (ui.IsFrameVisible(g.framename)==1))
    ui.ToggleFrame(g.framename)
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
end
function AOI_ISINITIALIZED()
    return g.initialized and ui.GetFrame(g.framename) and ui.GetFrame(g.framename):GetChildRecursively("aoi_slt")
end
function AOI_UPDATE_INVENTORY_TOGGLE_ITEM(frame)
    local ret = UPDATE_INVENTORY_TOGGLE_ITEM_OLD(frame)
    frame = ui.GetFrame(g.framename)
    if (not AOI_ISINITIALIZED()) then
        return
    end
    if ui.GetFrame("anotheroneofinventory"):IsVisible() == 0 or not g.initialized then
        return;
    end
    
    local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
    AUTO_CAST(slt)
    for i = 0, slt:GetSlotCount() - 1 do
        local slot = slt:GetSlotByIndex(i)
        if slot ~= nil and slot:IsVisible() == 1 then
            if slt:GetHeight() == 0 then
                return 1;
            end
            
            if slot:IsVisibleRecursively() == true then
                slot:PlayUIEffect("I_sys_item_slot", 2.2, "Inventory_TOGGLE_ITEM", true);
            end
        end
    end
    return ret
end

function AOI_INVENTORY_UPDATE_ICONS(frame)
    INVENTORY_UPDATE_ICONS_OLD(frame)
    if (not AOI_ISINITIALIZED()) then
        return
    end
    AOI_INV_REFRESH()
end

function AOI_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory") or ui.GetFrame(g.framename)
            frame:Resize(g.settings.w, g.settings.h)
            frame:SetOffset(g.settings.x, g.settings.y)

            --frame:SetGravity(ui.LEFT, ui.BOTTOM)

            frame:SetLayerLevel(80)
            local slotgbox = frame:CreateOrGetControl("groupbox", "aoi_gboxslt", tabsize + 10, 25, 0, 0)
            tolua.cast(slotgbox, "ui::CGroupBox")
            local slt = slotgbox:CreateOrGetControl("slotset", "aoi_slt", 0, 0, 0, 0)
            tolua.cast(slt, "ui::CSlotSet")
            local gbox = frame:CreateOrGetControl("groupbox", "aoi_gboxtab", 3, 3, 0, 0)
            tolua.cast(gbox, "ui::CGroupBox")
            local resizer = frame:GetChild("aoi_resize")
            local labelfind = frame:CreateOrGetControl("richtext", "aoi_finderlabel", 3, 5, 50, 24)
            AUTO_CAST(labelfind)
            labelfind:SetMargin(0, 0, 30 + 100 + 5, 5)
            labelfind:SetGravity(ui.RIGHT, ui.TOP)
            labelfind:SetText("{ol}{s14}Search:")
            labelfind:EnableHitTest(0)
            local editfind = frame:CreateOrGetControl("edit", "aoi_finder", 3, 5, 100, 24)
            AUTO_CAST(editfind)
            editfind:SetMargin(0, 0, 30, 5)
            editfind:SetGravity(ui.RIGHT, ui.TOP)
            editfind:SetTextTooltip("Pattern matching supported.(ignore case)")
            --editfind:SetSkinName("test_weight_skin")
            editfind:SetFontName("white_12_ol")
            editfind:SetEventScript(ui.ENTERKEY, "AOI_INV_FIND")
            editfind:EnableHitTest(1)
            frame:SetEventScript(ui.RESIZE, "AOI_ON_RESIZE")
            --scrollbar hiding trick
            gbox:EnableScrollBar(0)
            gbox:EnableScrollBar(1)
            gbox:EnableHittestGroupBox(true)
            gbox:EnableResizeByParent(0)
            slotgbox:EnableScrollBar(1)
            slotgbox:EnableResizeByParent(0)
            
            --generate buttons
            local btn
            local ox = 0
            local oy = 0
            local sx = tabsize
            local sy = tabsize
            local my = 1
            local prefix = "{ol}{s12}"
            
            for _, v in ipairs(g.filters) do
                btn = gbox:CreateOrGetControl("picture", "aoi_btn" .. v.name, ox, oy, sx, sy)
                AUTO_CAST(btn)
                
                btn:SetEventScript(ui.LBUTTONUP, "AOI_TAB_ON_CLICK")
                btn:SetEventScriptArgString(ui.LBUTTONUP, v.name)
                btn:SetTextTooltip(v.tooltip)
                btn:SetSkinName("None")
                if (v.imagename) then
                    btn:SetImage(v.imagename)
                
                else
                    btn:SetText(prefix .. v.text)
                end
                oy = oy + sy + my
            end
            local timer = GET_CHILD(frame, "aoi_addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("AOI_ON_TIMER");
            timer:Start(0.01);
            
            frame:SetOffset(g.settings.x, g.settings.y)
            frame:Resize(g.settings.w, g.settings.h)
            
            AOI_TAB_HIGHLIGHT()
            AOI_RESIZE()
            AOI_INV_REFRESH()
            AOI_INIT_FIND()
           
            g.initialized = true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_CLEARANDINIT_SLOT(slot)
    slot:RemoveAllChild()
    slot:ClearIcon()
    
    slot:ReleaseBlink();
    slot:SetText("")
    slot:SetSkinName("aoi_invenslot_none")
    INIT_INVEN_SLOT(slot)

end
function AOI_TAB_HIGHLIGHT()
    local frame = ui.GetFrame("anotheroneofinventory")
    for _, v in ipairs(g.filters) do
        local gbox = frame:GetChild("aoi_gboxtab")
        AUTO_CAST(gbox)
        local btn = gbox:GetChild("aoi_btn" .. v.name)
        AUTO_CAST(btn)
        
        
        
        if (v.imagename) then
            btn:SetText("")
            btn:SetImage(v.imagename)
            
            if (v.name == g.settings.filter) then
                btn:SetColorTone("FFFF4444")
            else
                btn:SetColorTone("FFFFFFFF")
            end
        else
            local prefix = "{ol}{s12}"
            if (v.name == g.settings.filter) then
                prefix = "{b}{ol}{s12}{#FF4444}"
            end
            btn:SetText(prefix .. v.text)
        end
    end
end
function AOI_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory")
            local gboxslot = GET_CHILD_RECURSIVELY(frame, "aoi_gboxslt")
            AUTO_CAST(gboxslot)
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            AUTO_CAST(slt)
            local gbox = frame:GetChild("aoi_gboxtab")
            AUTO_CAST(gbox)
            
            
            
            gboxslot:Resize(frame:GetWidth() - tabsize - 8, frame:GetHeight() - 30)
            slt:Resize(gboxslot:GetWidth() - 15, frame:GetHeight() - 30)
            --lt:SetSlotCount(math.floor(slt:GetWidth() / slotsize) * math.floor(slt:GetHeight() / slotsize))--currently
            gbox:Resize(tabsize + 2, frame:GetHeight() - 0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function AOI_TAB_ON_CLICK(frame, msg, argStr, argNum)
    g.settings.filter = argStr
    local frame = ui.GetFrame("anotheroneofinventory")
    local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
    local gbox = GET_CHILD_RECURSIVELY(frame, "aoi_gboxslt")
    AUTO_CAST(gbox)
    gbox:SetScrollPos(0)
    AOI_INIT_FIND()
    AOI_INV_REFRESH()
    AOI_TAB_HIGHLIGHT()
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
end
function AOI_INIT_FIND()
    EBI_try_catch{
        try = function()
            if g.settings.filter == "Fnd" then
                local frame = ui.GetFrame("anotheroneofinventory")
                frame:GetChild("aoi_finderlabel"):ShowWindow(1)
                frame:GetChild("aoi_finder"):ShowWindow(1)
            
            else
                local frame = ui.GetFrame("anotheroneofinventory")
                frame:GetChild("aoi_finderlabel"):ShowWindow(0)
                frame:GetChild("aoi_finder"):ShowWindow(0)
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_INV_FIND(frame, ctrl, argStr, argNum)
    EBI_try_catch{
        try = function()
            local findstr = ctrl:GetText()
            if (not findstr or findstr == "") then
                return
            end
            g.findstr = string.lower(findstr)
            AOI_TAB_ON_CLICK(nil, nil, "Fnd", nil)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end
--MSGS
function AOI_INVENTORY_ON_MSG(frame, msg, argStr, argNum)
    EBI_try_catch{
        try = function()
            if (g.initialized ~= true) then
                return
            end
            DBGOUT(msg)
            if msg == "INV_ITEM_ADD" then
                local invItem = session.GetInvItem(argNum);
                AOI_INV_ADD(invItem:GetIESID())
            elseif msg == 'INV_ITEM_REMOVE' then
                AOI_INV_REMOVE(argStr)
            --ReserveScript("AOI_INV_REFRESH()",0.15)
            elseif msg == 'ITEM_PROP_UPDATE' or msg == "INV_ITEM_CHANGE_COUNT" or msg=="UPDATE_LOCK_STATE" then
                AOI_INV_ITEM_UPDATE(argStr)
                --if (not AOI_INV_ITEM_UPDATE(argStr)) then
                    --AOI_INV_REFRESH()
                --end
            elseif msg == "INV_ITEM_LIST_GET" then
                AOI_INV_REFRESH()
            elseif msg ~= "INV_DRAW_MONEY_TEXT" then
                AOI_INV_REFRESH()
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end

function AOI_INV_ITEM_UPDATE(argStr)
    return EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory")
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            if (slt) then
                AUTO_CAST(slt)
                --find
                for i = 0, slt:GetSlotCount() - 1 do
                    local slot = slt:GetSlotByIndex(i)
                    local icon = slot:GetIcon();
                    if (icon == nil) then
                        
                        else
                        local iconInfo = icon:GetInfo();
                        local slotItem = session.GetInvItemByGuid(iconInfo:GetIESID())
                        if (slotItem == nil) then
                            
                            else
                            if (slotItem.type ~= 900011) then
                                local itemCls = GetIES(slotItem:GetObject())
                                if (itemCls == nil) then
                                    return false
                                end
                                
                                if slotItem and slotItem:GetIESID() == argStr and session.GetInvItemByGuid(slotItem:GetIESID()) then
 
                                    local invItem = slotItem
                                    AOI_INV_SLOT_SETITEM(slot,invItem,itemCls)

                                    return true
                                
                                end
                            end
                        end
                    end
                end
            end
            return true
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_INV_FILTER(invItem)
    return EBI_try_catch{
        try = function()
            local filter = g.settings.filter or "All"
            if (filter == "All") then
                return true
            end
            if (filter == "Lim") then
                --時間制限付きか判定
                if (invItem.hasLifeTime == true) then
                    return true
                else
                    return false
                end
            end
            if (filter == "Ing") then
                --材料か
                local itemObj = GetIES(invItem:GetObject())
                if (itemObj.GroupName == 'Material') then
                    return true
                else
                    return false
                end
            end
            if (filter == "Que") then
                --クエストアイテムか
                local itemObj = GetIES(invItem:GetObject())
                if (itemObj.GroupName == 'Quest') then
                    return true
                else
                    return false
                end
            end
            if (filter == "Fnd") then
                --検索
                local itemCls = GetIES(invItem:GetObject())
                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name));
                if (itemname:find(g.findstr)) then
                    return true
                else
                    return false
                end
            end
            --オリジナルソート
            local filterdata = g.filterbyname[filter]
            if (filterdata.original) then
                local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)
                
                local titleName = baseidcls.ClassName
                if baseidcls.MergedTreeTitle ~= "NO" then
                    titleName = baseidcls.MergedTreeTitle
                end
                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                if filterdata.original == typeStr then
                    return true
                else
                    return false
                end
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_INV_ADD(guid)
    return EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory")
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            local invItem = session.GetInvItemByGuid(guid)
            if (slt and invItem and AOI_INV_FILTER(invItem)) then
                AUTO_CAST(slt)
                --find
                for i = 0, slt:GetSlotCount() - 1 do
                    local slot = slt:GetSlotByIndex(i)
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon();
                    if (icon == nil) then
                        
                        AOI_CLEARANDINIT_SLOT(slot)
                        AOI_INV_SLOT_SETITEM(slot, invItem)
                        DBGOUT("ADD INSERT")
                        return
                    end
                end
                --行を増やす
                slt:ExpandRow()
                for i = 0, slt:GetSlotCount() - 1 do
                    local slot = slt:GetSlotByIndex(i)
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon();
                    if (icon == nil) then
                        
                        AOI_CLEARANDINIT_SLOT(slot)
                        AOI_INV_SLOT_SETITEM(slot, invItem)
                        DBGOUT("ADD APPEND")
                        return
                    end
                end
            
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOI_INV_REMOVE(guid)
    return EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory")
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            if (slt) then
                AUTO_CAST(slt)
                --find
                for i = 0, slt:GetSlotCount() - 1 do
                    --DBGOUT("HEA")
                    local slot = slt:GetSlotByIndex(i)
                    AUTO_CAST(slot)
                    local icon = slot:GetIcon();
                    if (icon == nil) then
                        DBGOUT("REMOVED1")
                        AOI_CLEARANDINIT_SLOT(slot)
                    else
                        local iconInfo = icon:GetInfo();
                        local slotItem = session.GetInvItemByGuid(iconInfo:GetIESID())
                        if (slotItem == nil) then
                            DBGOUT("REMOVED2")
                            AOI_CLEARANDINIT_SLOT(slot)
                        else
                            local itemCls = GetIES(slotItem:GetObject())
                            if (itemCls == nil) then
                                DBGOUT("REMOVED3")
                                AOI_CLEARANDINIT_SLOT(slot)
                            else
                                
                                if slotItem:GetIESID() == guid then
                                    
                                    AOI_CLEARANDINIT_SLOT(slot)
                                    DBGOUT("REMOVED4")
                                    return
                                end
                            end
                        end
                    end
                end
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_INV_REFRESH()
    return EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory")
       
                
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            AUTO_CAST(slt)
            local gboxslot = GET_CHILD_RECURSIVELY(frame, "aoi_gboxslt")
            AUTO_CAST(gboxslot)
            slt:RemoveAllChild()
            
            
            session.BuildInvItemSortedList();
            local sortedList = session.GetInvItemSortedList();
            local invItemCount = sortedList:size();
            local slotidx = 0

            g.invitems = {}
            for i = 0, invItemCount - 1 do
                
                local invItem = sortedList:at(i);
                if invItem ~= nil and AOI_INV_FILTER(invItem) and (invItem.type ~= 900011) then --ignore silver
                    
                    local itemObj = GetIES(invItem:GetObject())
                    if (itemObj ~= nil) then
                        local itemCls = GetClassByType("Item", invItem.type);
                        local useLv = TryGetProp(itemCls, "UseLv") or 1;
                        local rarity = TryGetProp(itemCls, "ItemGrade");
                        local itemLv = TryGetProp(itemCls, "ItemLv") or 1;
                        local gemLv = 0
                        EBI_try_catch{
                            try=function()
                                gemLv=itemObj.ItemExp or 0
                            end,
                            catch=function(e)
                            end
                        }
                        g.invitems[#g.invitems + 1] = {
                            item = invItem,
                            iesid=invItem:GetIESID(),
                            name = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name)),
                            amount = invItem.count,
                            level = math.max(useLv, itemLv, gemLv or 1),
                            rarity = rarity
                        }
                    end
                end
            end
            --ソート
            if (g.settings.sortby) then
                
                if (g.settings.sortorder == 0) then
                    table.sort(g.invitems, function(a, b)
                            
                            local compareresult
                            for _, v in ipairs(g.settings.sortby) do
                                local eq = false
                                
                                compareresult = a[v] < b[v]
                                eq = a[v] == b[v]
                                
                                if (not eq) then
                                    return compareresult
                                end
                            end
                            return compareresult
                    end)
                else
                    table.sort(g.invitems, function(a, b)
                        local compareresult = 0
                        for _, v in ipairs(g.settings.sortby) do
                            local eq = false
                            
                            compareresult = a[v] > b[v]
                            eq = a[v] == b[v]
                            
                            if (not eq) then
                                return compareresult
                            end
                        end
                        return compareresult
                    end)
                end
            end
            local count = #g.invitems
            local wlimit = math.floor((gboxslot:GetWidth()-18) / slotsize)
            slt:SetSlotSize(slotsize, slotsize)
            if (g.settings.view == 1) then
                slt:SetSlotSize(gboxslot:GetWidth()-18, slotsize)
                wlimit = 1
            end
            
            slt:SetSpc(0, 0)
            
            slt:SetColRow(wlimit, math.max(1, math.ceil(count / wlimit)))
            
            
            slt:CreateSlots()
            slt:EnableDrag(1)
            slt:EnableDrop(1)
            slt:EnablePop(1)

            g.invrefresher = 1
            g.invrefresh = true
            g.invrefresheridx = 0
            g.invrefreshcooldown = 10
            g.invrefreshercount = 0
            return 0
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_INV_REFRESHENER()
    local frame = ui.GetFrame("anotheroneofinventory")
    --session.BuildInvItemSortedList()
    local sortedList = session.GetInvItemSortedList();
    local invItemCount = #g.invitems
    local slotidx = g.invrefresheridx or 0
    local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
    
    local cancel = false
    local limit = 30
    if(g.settings.view==1)then
        limit=20
    end
    for i = g.invrefresher, #g.invitems do
        local slot = slt:GetSlotByIndex(slotidx)
        
        local invItem = g.invitems[i].item
        if (slotidx >= #g.invitems) then
            cancel = true
            break
        end
        if(session.GetInvItemByGuid( g.invitems[i].iesid)==nil)then
            --ignore
        else

            
            local itemCls = GetIES(invItem:GetObject())
            
            
            if (itemCls ~= nil) then
                AOI_INV_SLOT_SETITEM(slot, invItem, itemCls)
                slotidx = slotidx + 1
                g.invrefresheridx = slotidx
                g.invrefreshercount = g.invrefreshercount + 1
                limit = limit - 1
            
            end
        end
        g.invrefresher = i+1
        if (limit == 0) then
            break
        end
    
    end
    if (g.invrefresher >= (invItemCount) or cancel) then
        g.invrefresh = false
    
    end
end
function AOI_INV_SLOT_SETITEM(slot, invItem, itemCls)
    local frame = ui.GetFrame("inventory")
    if (itemCls == nil) then
        itemCls = GetIES(invItem:GetObject())
    end
    local parentslot = slot
    if (g.settings.view == 1) then
        slot = parentslot:CreateOrGetControl("slot", "dummyslot", 0, 0, slotsize, slotsize)
        AUTO_CAST(slot)
        local icon = CreateIcon(parentslot);
        local itemobj = GetIES(invItem:GetObject());	
        local imageName = GET_EQUIP_ITEM_IMAGE_NAME(itemobj, 'Icon');
        local iconImgName  = GET_ITEM_ICON_IMAGE(itemobj);
        local itemType = invItem.type;
        icon:Set("aoi_transparent", 'Item', itemType, invItem.invIndex, invItem:GetIESID(), invItem.count);
        icon:Resize(0,0)
        parentslot:EnableDrag(0)
        parentslot:EnableDrop(0)
        parentslot:EnablePop(0)
        parentslot:SetColorTone("00000000")
    end
    --local remainInvItemCount = GET_REMAIN_INVITEM_COUNT(invItem);
    UPDATE_INVENTORY_SLOT(slot, invItem, itemCls);
    
    INV_SLOT_UPDATE(ui.GetFrame("inventory"), invItem, slot);
    local slotFont = frame:GetUserConfig("TREE_SLOT_TEXT_FONT")
    
    --if ui.GetFrame("oblation_sell"):IsVisible() == 1 then
    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemCls, invItem.count, "{s14}{ol}{#FFFFFF}");
    --else
    --    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemCls, invItem.count, "{s14}{ol}{#FFFFFF}");
    --end

    --CUSTOM_RBUTTON
    slot:SetEventScript(ui.RBUTTONDOWN,"AOI_SLOT_ON_RBUTTONDOWN")
    slot:SetEventScript(ui.RBUTTONDBLCLICK,"AOI_SLOT_ON_RBUTTONDBLCLICK")
    slot:SetEventScript(ui.LBUTTONDOWN, "AOI_SLOT_ON_LBUTTTONDOWN");
    --minify itemlock
    local lock = GET_CHILD(slot, "itemlock")
    if (lock) then
        local img = GET_CHILD(lock, "image", "ui::CPicture")
        img:Resize(img:GetWidth() / 2, img:GetHeight() / 2)
        img:SetEnableStretch(1)
        img:SetGravity(ui.RIGHT, ui.TOP)
    end
    --minify itemtext
    local text = slot:GetText()
    if (text and text:find("LV")) then
        text = text:gsub("{s.*}LV.(%d*)", "{s14}{ol}{#FFFFFF}{b}L%1")
        slot:SetText(text)
    end

    slot:EnableDrag(1)
    
    if (g.settings.view == 1) then
        
        local text = parentslot:CreateOrGetControl("richtext", "aoi_name", slotsize + 5, 2, slot:GetWidth() - 5 - slotsize, slot:GetHeight())
        text:SetText("{s14}{ol}" .. itemCls.Name)
        text:EnableHitTest(0)
        local offsetbase=250
        local offset=math.max(offsetbase,text:GetWidth())
        if(itemCls.GroupName=="Card")then
            
            local textdesc = parentslot:CreateOrGetControl("richtext", "aoi_desc", slotsize + 5+offset+20, 2, slot:GetWidth() - 5-offset-20 - slotsize, slot:GetHeight())
            textdesc:SetText("{#AAAAAA}{s12}{ol}"..itemCls.Desc)
            textdesc:EnableHitTest(0)
        elseif (itemCls.GroupName=="Weapon" or itemCls.GroupName=="SubWeapon" or itemCls.GroupName=="Armor")then
            local desc=""
            local basicTooltipProp = 'None';
            
            if itemCls.BasicTooltipProp~=nil and itemCls.BasicTooltipProp ~= 'None' then
                local basicTooltipPropList = string.split(itemCls.BasicTooltipProp, ';');
                for i = 1, #basicTooltipPropList do
                    basicTooltipProp = basicTooltipPropList[i];
                    local pc = GetMyPCObject();
                    local ignoreReinf = TryGetProp(pc, 'IgnoreReinforce', 0);
                    local bonusReinf = TryGetProp(pc, 'BonusReinforce', 0);
                    local overReinf = TryGetProp(pc, 'OverReinforce', 0);
                    local reinforceaddvalue = 0
                    local socketaddvalue = 0
                    local typeiconname = nil
                    local typestring = nil
                    local arg1 = nil
                    local arg2 = nil
                    if TryGetProp(itemCls, 'EquipGroup') ~= 'SubWeapon' then
                        overReinf = 0;
                    end
                    if TryGetProp(itemCls, 'GroupName') ~= 'Weapon' then
                        bonusReinf = 0; 
                    end
                    if basicTooltipProp == 'ATK' then
                        typeiconname = 'test_sword_icon'
                        typestring = ScpArgMsg("Melee_Atk")
                        if TryGetProp(itemCls, 'EquipGroup') == "SubWeapon" then
                            typestring = ScpArgMsg("PATK_SUB")
                        end
                        reinforceaddvalue = math.floor( GET_REINFORCE_ADD_VALUE_ATK(itemCls, ignoreReinf, bonusReinf + overReinf, basicTooltipProp) )
                        socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, itemCls);		
                        arg1 = itemCls.MINATK - reinforceaddvalue + socketaddvalue;
                        arg2 = itemCls.MAXATK - reinforceaddvalue + socketaddvalue;
                        desc=desc.."ATK:"..tostring(arg1+reinforceaddvalue).."-"..tostring(arg2+reinforceaddvalue).." "
                    elseif basicTooltipProp == 'MATK' then
                        typeiconname = 'test_sword_icon'
                        typestring = ScpArgMsg("Magic_Atk")
                        reinforceaddvalue = math.floor( GET_REINFORCE_ADD_VALUE_ATK(itemCls, ignoreReinf, bonusReinf + overReinf, basicTooltipProp) )
                        socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, itemCls)
                        arg1 = itemCls.MATK - reinforceaddvalue;
                        arg2 = itemCls.MATK - reinforceaddvalue;
                        desc=desc.."MATK:"..tostring(arg1+reinforceaddvalue+socketaddvalue).." "
                    else
                        typeiconname = 'test_shield_icon'
                        typestring = ScpArgMsg(basicTooltipProp);
                        --print(basicTooltipProp)
                        if itemCls.RefreshScp ~= 'None' then
                            local scp = _G[itemCls.RefreshScp];
                            if scp ~= nil then
                                scp(itemCls);
                            end
                        end
                        reinforceaddvalue = GET_REINFORCE_ADD_VALUE(basicTooltipProp, itemCls, ignoreReinf, bonusReinf + overReinf);
                        socketaddvalue =  _GET_ITEM_SOCKET_ADD_VALUE(basicTooltipProp, itemCls)
                        arg1 = TryGetProp(itemCls, basicTooltipProp) - reinforceaddvalue - socketaddvalue;
                        arg2 = TryGetProp(itemCls, basicTooltipProp) - reinforceaddvalue - socketaddvalue;
                        desc=desc..basicTooltipProp..":"..tostring(arg1+reinforceaddvalue+socketaddvalue).." "
                    end
                    
                end
            end
            local textdesc = parentslot:CreateOrGetControl("richtext", "aoi_desc", slotsize + 5+offset+20, 2, slot:GetWidth() - 5-offset-20 - slotsize, slot:GetHeight())
            textdesc:SetText("{#AAAAAA}{s12}{ol}".."LV:"..tostring(itemCls.UseLv).." "..desc)
            textdesc:EnableHitTest(0)
        end
        parentslot:SetEventScript(ui.LBUTTONDOWN, "AOI_SLOT_ON_LBUTTTONDOWN");
    
    end

end
function AOI_ON_TIMER()
    EBI_try_catch{
        try = function()
            if(g.initialized==false)then
                return
            end
            if (g.invrefresh) then
                if (g.invrefreshcooldown > 0) then
                    g.invrefreshcooldown = g.invrefreshcooldown - 1
                else
                    AOI_INV_REFRESHENER()
                end
            end
            if (g.resizing == 1) then
                if mouse.IsLBtnPressed() == 0 then
                    AOI_RESIZE()
                    AOI_INV_REFRESH()
                    g.resizing = 0
                end
            end
            if mouse.IsLBtnPressed() ~= 0 then
                g.liftdelay = 3
            else
                --recover
                if (g.lifticon) then
                    
                    if (g.liftdelay and g.liftdelay > 0) then
                        
                        g.liftdelay = g.liftdelay - 1
                    else
                        
                        g.lifticon = false
                        --g.liftslot:EnableDrag(1)
                        g.liftdelay = nil
                        ui.GetFrame("anotheroneofinventory"):SetName(g.framename)
                        g.invenframe = ui.GetFrame("inventory")
                        local original = ui.GetFrame("inventory")
                        original:SetName("inventory")
                    end
                end
            end
            if AOI_ISINITIALIZED() then
                local frame = ui.GetFrame("anotheroneofinventory")
                local framecheck = AOI_CHECK_FRAME()
                if ( framecheck) then
                    
                    if (not g.checkedframe) then
                        g.checkedframe = framecheck
                        if (frame:GetX() < 700) then
                            g.checkframeneedtoreturn = frame:GetX()
                            g.checkframeneedtoreturnh=frame:GetHeight()
                            g.checkframeneedtoreturnw=frame:GetWidth()
                            
                            frame:SetOffset(700, frame:GetY())
                        end
                    end
                else
                    if (g.checkedframe) then
                        if (g.checkframeneedtoreturn) then
                            frame:SetOffset(g.checkframeneedtoreturn, frame:GetY())
                            frame:Resize( g.checkframeneedtoreturnw,g.checkframeneedtoreturnh)
                        end
                        g.checkframeneedtoreturn = nil
                        g.checkedframe = nil
                    end
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOI_SLOT_ON_LBUTTTONDOWN(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            --AUTO_CAST(ctrl)
            -- pretend frame trick
            g.lifticon = true
            g.liftslot = ctrl
            if(keyboard.IsKeyPressed("LALT")==1 or keyboard.IsKeyPressed("RALT")==1)then
                local icon=ctrl:GetIcon()
                local iconInfo=icon:GetInfo()
                local invItem=session.GetInvItemByGuid(iconInfo:GetIESID())
                local itemObj=GetIES(invItem:GetObject())
                g.liftslot:EnableDrag(0)
                INV_ITEM_LOCK_LBTN_CLICK( ui.GetFrame("inventory"),invItem,ctrl)
                g.liftslot:EnableDrag(1)
            else
                CHECK_INV_LBTN(g.invenframe, ctrl, argstr, argnum)
                ReserveScript("AOI_SLOT_STARTDRAG()", 0.01)
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_SLOT_ON_RBUTTONDBLCLICK(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            

            -- pretend frame trick
            g.lifticon = true
            g.liftslot = ctrl
            local invenframe = ui.GetFrame("inventory")
           
            ui.GetFrame("anotheroneofinventory"):SetName("inventory")
            INVENTORY_RBDOUBLE_ITEMUSE(invenframe, ctrl, argstr, argnum)
            ui.GetFrame("anotheroneofinventory"):SetName(g.framename)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
    frame:SetName(g.framename)
end
function AOI_SLOT_ON_RBUTTONDOWN(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            
            -- pretend frame trick
          
           
                local invenframe = ui.GetFrame("inventory")
                ui.GetFrame("anotheroneofinventory"):SetName("inventory")
                INVENTORY_RBDC_ITEMUSE(invenframe, ctrl, argstr, argnum)
                ui.GetFrame("anotheroneofinventory"):SetName(g.framename)
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
    frame:SetName(g.framename)
end
function AOI_SLOT_STARTDRAG()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventory")
            local original = ui.GetFrame("inventory")
            ui.GetFrame("anotheroneofinventory"):SetName("inventory")
            original:SetName("inventory")
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_CHECK_FRAME()
    local frames = {
        "warehouse",
        "accountwarehouse",
        "itemcraft",
        "reinforce_by_mix",
        "reinforce_by_mix_certificate",
        "shop",
        "oblation_sell",
        "legendcardupgrade",
        "itemrandomreset",
        "enchantarmoropen",
        "puzzlecraft",
        "itemcraft_alchemist",
        "hiddenability_make",
        "legendprefix",
        "itemdungeon",
        "guildgrowth",
        "ark_composition",
        "ark_relocation",
        "itemoptionadd",
        "itemoptionextract",
        "itemoptionlegendextract",
        "itemoptionrelease",
        "itemoptionrelease_random",
        "itemrullet",
    }
    for _, v in ipairs(frames) do
        if ui.IsFrameVisible(v) == 1 then
            
            return ui.GetFrame(v)
        end
    end
    return nil
end
function AOI_ON_RESIZE()
    g.resizing = 1
    AOI_SAVE_POSITION()
end
function AOI_SAVE_POSITION()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            
            g.settings.x = frame:GetX()
            g.settings.y = frame:GetY()
            g.settings.w = frame:GetWidth()
            g.settings.h = frame:GetHeight()
            ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_CHANGE_VIEW(view)
    g.settings.view = view
    
    AOI_INV_REFRESH()
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
end
function AOI_CHANGE_SORT_DESCENDING(dsc)
    g.settings.sortorder = dsc
    g.settings.sortby = g.settings.sortby or {"name"}
    AOI_INV_REFRESH()
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
end
function AOI_CHANGE_SORT_BY(names)
    g.settings.sortby = names
    g.settings.sortorder = g.settings.sortorder or 0
    AOI_INV_REFRESH()
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
end
function AOI_CHANGE_NOSORT()
    g.settings.sortby = nil
    g.settings.sortorder = nil
    AOI_INV_REFRESH()
    ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
end
function AOI_ON_RCLICK()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local context = ui.CreateContextMenu("aoi_contextmenu", "", 0, 0, 300, 100);
            
            ui.AddContextMenuItem(context, "Grid View", "AOI_CHANGE_VIEW(0)");
            ui.AddContextMenuItem(context, "List View", "AOI_CHANGE_VIEW(1)");
            ui.AddContextMenuItem(context, "No Sort", "AOI_CHANGE_NOSORT()");
            ui.AddContextMenuItem(context, "Sort Ascending", "AOI_CHANGE_SORT_DESCENDING(0)");
            ui.AddContextMenuItem(context, "Sort Descending", "AOI_CHANGE_SORT_DESCENDING(1)");
            ui.AddContextMenuItem(context, "Sort by Name", "AOI_CHANGE_SORT_BY({'name'})");
            ui.AddContextMenuItem(context, "Sort by Level", "AOI_CHANGE_SORT_BY({'level','name'})");
            ui.AddContextMenuItem(context, "Sort by Rarity", "AOI_CHANGE_SORT_BY({'rarity','name'})");
            ui.AddContextMenuItem(context, "Sort by Level-Rarity", "AOI_CHANGE_SORT_BY({'level','rarity','name'})");
            
            context:Resize(200, context:GetHeight());
            ui.OpenContextMenu(context);
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
