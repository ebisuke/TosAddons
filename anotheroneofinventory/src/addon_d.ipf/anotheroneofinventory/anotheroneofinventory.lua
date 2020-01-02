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
g.settings = {x = 300, y = 300, w = 300, h = 200}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "anotheroneofinventory"
g.debug = true
g.resizing = nil
g.x = nil
g.y = nil
g.frames = {}
g.filters={
    {name="Fav",text="★"},
    {name="All",text="All"},
    {name="Equ",text="Equ"},
    {name="Spl",text="Spl"},
    {name="Rcp",text="Rcp"},
    {name="Crd",text="Crd"},
    {name="Etc",text="Etc"},
    {name="Gem",text="Gem"},
    {name="Prm",text="Prm"},
    {name="Lim",text="Lim"}, 
}
g.filter="All"
local tabsize = 20
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
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
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
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('AOI', 'sysmenu_inv', 'another one of inventory', 'ANOTHERONEOFINVENTORY_TOGGLE_FRAME')
            --addon:RegisterMsg('GAME_START_3SEC', 'ANOTHERONEOFINVENTORY_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end
            
            acutil.setupHook(AOI_UPDATE_INVENTORY_EXP_ORB, "UPDATE_INVENTORY_EXP_ORB")
            acutil.setupHook(AOI_UPDATE_INVENTORY_TOGGLE_ITEM, "TOGGLE_ITEM_SLOT_INVEN_ON_MSG")
            addon:RegisterMsg('INV_ITEM_ADD', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('INV_ITEM_REMOVE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('INV_DRAW_MONEY_TEXT', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_ITEM_REPAIR', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_ITEM_APPRAISAL', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('SWITCH_GENDER_SUCCEED', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('RESET_ABILITY_UP', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('ACCOUNT_UPDATE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterOpenOnlyMsg('INV_ITEM_LIST_GET', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('GAME_START', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('EQUIP_ITEM_LIST_GET', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('EQUIP_ITEM_LIST_UPDATE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_LOCK_STATE', 'AOI_INVENTORY_ON_MSG');
            addon:RegisterMsg('UPDATE_TRUST_POINT', 'AOI_INVENTORY_ON_MSG');
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")
            local timer = GET_CHILD(frame, "aoi_addontimer", "ui::CAddOnTimer");
            timer:SetUpdateScript("AOI_ON_TIMER");
            timer:Start(0.01);
            ANOTHERONEOFINVENTORY_SHOW(g.frame)
            
            ANOTHERONEOFINVENTORY_LOAD_SETTINGS()
            frame:SetOffset(g.settings.x or 300, g.settings.y or 300)
            frame:Resize(g.settings.w or 300, g.settings.h or 200)
            AOI_INIT()
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANOTHERONEOFINVENTORY_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function ANOTHERONEOFINVENTORY_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function ANOTHERONEOFINVENTORY_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end

function AOI_UPDATE_INVENTORY_TOGGLE_ITEM(frame)
    local ret = UPDATE_INVENTORY_TOGGLE_ITEM_OLD(frame)
    frame = ui.GetFrame(g.framename)
    if frame:IsVisible() == 0 then
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
function AOI_UPDATE_INVENTORY_EXP_ORB(frame, ctrl, num, str, time)
    local ret = UPDATE_INVENTORY_EXP_OLD(frame, ctrl, num, str, time)
    if frame:IsVisible() == 0 then
        return;
    end
    local invenframe = ui.GetFrame("inventory")
    frame = ui.GetFrame(g.framename)
    local itemGuid = invenframe:GetUserValue("EXP_ORB_EFFECT");
    if itemGuid == "None" then
        return;
    end
    
    local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
    AUTO_CAST(slt)
    local gboxslot = GET_CHILD_RECURSIVELY(frame, "aoi_gboxslt")
    AUTO_CAST(gboxslot)
    if slt:GetHeight() == 0 then
        return;
    end
    local iesid = nil
    local slot
    for i = 0, slt:GetSlotCount() - 1 do
        slot = slt:GetSlotByIndex(i)
        if slot ~= nil and slot:IsVisible() == 1 then
            iesid = slt:GetIcon():GetInfo():GetIESID()
            break
        end
    end
    if (not iesid) then
        return ret
    end
    
    local offset = invenframe:GetUserConfig("EFFECT_DRAW_OFFSET");
    -- if slot:GetDrawY() <= gboxslot:GetDrawY() or gboxslot:GetDrawY() + gboxslot:GetHeight() - offset <= slot:GetDrawY() then
    -- 	return;
    -- end
    if slot:IsVisibleRecursively() == true then
        slot:PlayUIEffect("I_sys_item_slot", 2.2, "Inventory_Exp_ORB", true);
    end
    return ret
end


function AOI_INIT()
    EBI_try_catch{
        try = function()
            local frame = g.frame
            frame:EnableMove(1)
            frame:SetSkinName("chat_window")
            frame:EnableHittestFrame(1)
            frame:SetGravity(ui.LEFT, ui.BOTTOM)
            frame:EnableResize(1)
            local slotgbox = frame:CreateOrGetControl("groupbox", "aoi_gboxslt", tabsize + 10, 25, 0, 0)
            tolua.cast(slotgbox, "ui::CGroupBox")
            local slt = slotgbox:CreateOrGetControl("slotset", "aoi_slt", 0, 0, 0, 0)
            tolua.cast(slt, "ui::CSlotSet")
            local gbox = frame:CreateOrGetControl("groupbox", "aoi_gboxtab", 5, 5, 0, 0)
            tolua.cast(gbox, "ui::CGroupBox")
            local resizer = frame:GetChild("aoi_resize")
            
            frame:SetEventScript(ui.RESIZE, "AOI_SAVE_POSITION")
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
            local my = 5
            local prefix = "{ol}{s12}"
            
            for _,v in ipairs(g.filters) do
                btn = gbox:CreateOrGetControl("button", "aoi_btn"..v.name, ox, oy, sx, sy)
                AUTO_CAST(btn)
                btn:SetText(prefix .. v.text)
                btn:SetEventScript(ui.LBUTTONUP,"AOI_TAB_ON_CLICK")
                btn:SetEventScriptArgString(ui.LBUTTONUP,v.name)
                
                btn:SetSkinName("None")
                oy = oy + sy + my
            end
            AOI_ALT_INIT()
            
            AOI_RESIZE()
            AOI_INV_REFRESH()
        
  
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOI_RESIZE()
    EBI_try_catch{
        try = function()
            local frame = g.frame
            local gboxslot = GET_CHILD_RECURSIVELY(frame, "aoi_gboxslt")
            AUTO_CAST(gboxslot)
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            AUTO_CAST(slt)
            local gbox = frame:GetChild("aoi_gboxtab")
            AUTO_CAST(gbox)
            
            
            
            gboxslot:Resize(frame:GetWidth() - tabsize - 20, frame:GetHeight() - 30)
            slt:Resize(gboxslot:GetWidth() - 20, frame:GetHeight())
            --lt:SetSlotCount(math.floor(slt:GetWidth() / slotsize) * math.floor(slt:GetHeight() / slotsize))--currently
            gbox:Resize(tabsize, frame:GetHeight() - 30)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANOTHERONEOFINVENTORY_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOI_TAB_ON_CLICK(frame, msg, argStr, argNum)
    g.filter=argStr
    AOI_INV_REFRESH()
end
--MSGS
function AOI_INVENTORY_ON_MSG(frame, msg, argStr, argNum)
    EBI_try_catch{
        try = function()
            
            AOI_INV_REFRESH()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end

function AOI_INV_REFRESH()
    return EBI_try_catch{
        try = function()
            local frame = g.frame
            local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
            AUTO_CAST(slt)
            local gboxslot = GET_CHILD_RECURSIVELY(frame, "aoi_gboxslt")
            AUTO_CAST(gboxslot)
            slt:RemoveAllChild()
            frame:SetLayerLevel(100)
            
            session.BuildInvItemSortedList();
            local sortedList = session.GetInvItemSortedList();
            local invItemCount = sortedList:size();
            local slotidx = 0
            local count = invItemCount
            local baseidclslist, baseidcnt = GetClassList("inven_baseid");
            local wlimit = math.floor(slt:GetWidth() / slotsize)
            slt:SetSlotSize(slotsize, slotsize)
            slt:SetSpc(0, 0)
            
            slt:SetColRow(math.min(wlimit, count), math.max(1, math.ceil(count / wlimit)))
            
            slt:CreateSlots()
            slt:EnableDrag(1)
            slt:EnableDrop(1)
            slt:EnablePop(1)

            g.invrefresher = 0
            g.invrefresh = true
            g.invrefresheridx=0
            return 0
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_INV_REFRESHENER()
    local frame = g.frame
    local sortedList = session.GetInvItemSortedList();
    local invItemCount = sortedList:size();
    local slotidx = g.invrefresheridx or 0
    local slt = GET_CHILD_RECURSIVELY(frame, "aoi_slt")
  
    local cancel=false
    for i = g.invrefresher, math.min(g.invrefresher + 30, invItemCount - 1) do
        local slot = slt:GetSlotByIndex(slotidx)
        local invItem = sortedList:at(i);
        if(slotidx >= slt:GetSlotCount()-1)then
            cancel=true
            break
        end
        if invItem ~= nil then
            local itemCls = GetIES(invItem:GetObject())
            
            if (invItem.type ~= 900011) then --ignore silver
                
                --local remainInvItemCount = GET_REMAIN_INVITEM_COUNT(invItem);
                UPDATE_INVENTORY_SLOT(slot, invItem, itemCls);
                
                INV_SLOT_UPDATE(ui.GetFrame("inventory"), invItem, slot);
                local slotFont = frame:GetUserConfig("TREE_SLOT_TEXT_FONT")
                
                if ui.GetFrame("oblation_sell"):IsVisible() == 1 then
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemCls, invItem.count, "{s14}{ol}{#FFFFFF}");
                else
                    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemCls, invItem.count, "{s14}{ol}{#FFFFFF}");
                end
                
                --minify itemlock
                local lock = GET_CHILD(slot, "itemlock")
                if (lock) then
                    local img = GET_CHILD(lock, "image", "ui::CPicture")
                    img:Resize(img:GetWidth() / 2, img:GetHeight() / 2)
                    img:SetEnableStretch(1)
                    img:SetGravity(ui.RIGHT, ui.TOP)
                end
                g.originalfunc = slot:GetEventScript(ui.LBUTTONDOWN)
                slot:SetEventScript(ui.LBUTTONDOWN, "AOI_SLOT_ON_LBUTTTONDOWN");
                slot:EnableDrag(1)

                slotidx = slotidx + 1
                g.invrefresheridx=slotidx
            end
        end
        g.invrefresher = i

    end
    if (g.invrefresher >= (invItemCount - 1) or cancel) then
        g.invrefresh = false
    end
end
function AOI_ON_TIMER()
    EBI_try_catch{
        try = function()
            if(g.invrefresh)then
                AOI_INV_REFRESHENER()
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
                    
                    if (g.liftdelay > 0) then
                        
                        g.liftdelay = g.liftdelay - 1
                    else
                        
                        g.lifticon = false
                        g.liftslot:EnableDrag(0)
                        g.liftdelay = nil
                        g.frame:SetName(g.framename)
                        local original = ui.GetFrame("inventory")
                        original:SetName("inventory")
                    end
                end
            end
            if keyboard.IsKeyDown("V") == 1 then
                ui.GetFrame("anotheroneofinventoryalt"):ShowWindow(1)
            else
                ui.GetFrame("anotheroneofinventoryalt"):ShowWindow(0)
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
            DBGOUT("LCLICK")
            AUTO_CAST(ctrl)

            -- pretend frame trick
            
            g.lifticon = true
            g.liftslot = ctrl
            
            _G[g.originalfunc](original, ctrl, argstr, argnum)
            ReserveScript("AOI_SLOT_STARTDRAG()", 0.01)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_SLOT_STARTDRAG()
    EBI_try_catch{
        try = function()
            local frame = g.frame
            local original = ui.GetFrame("inventory")
            g.frame:SetName("inventory")
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
        "reinforce_by_mix_certific",
        "shop",
        "oblation_sell",
        "legendcardupgrade",
    
    }
    for _, v in ipairs(frames) do
        if ui.IsFrameVisible(v) then
            return ui.GetFrame(v)
        end
    end
    return nil
end
function AOI_SAVE_POSITION()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            if (AOI_CHECK_FRAME()) then
                else
                g.settings.x = frame:GetX()
                g.settings.y = frame:GetY()
                g.settings.w = frame:GetWidth()
                g.settings.h = frame:GetHeight()
                ANOTHERONEOFINVENTORY_SAVE_SETTINGS()
            end
            g.resizing = 1
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
