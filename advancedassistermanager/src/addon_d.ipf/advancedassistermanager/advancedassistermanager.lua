-- advancedassistermanager
--アドオン名（大文字）
local addonName = 'advancedassistermanager'
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
g.framename = 'advancedassistermanager'
g.debug = false

g.aam = {
    sort = nil,
    
    watchingcards={},
    watchingcallback=nil,
    menus = {
        {name = 'menufile', text = 'File', callback = function()
            local context = ui.CreateContextMenu('context_menufile', '', 0, 10, 200, 200)
            --ui.AddContextMenuItem(context, 'キャンセル', 'None')
            ui.AddContextMenuItem(context, 'Close', 'ui.CloseFrame("advancedassistermanager")')
            ui.OpenContextMenu(context)
        end},
        {name = 'menuedit', text = 'Edit', callback = function()
            local context = ui.CreateContextMenu('context_menuedit', '', 0, 10, 200, 200)
            
            ui.AddContextMenuItem(context, 'Lock Card(s)', 'ADVANCEDASSISTERMANAGER_MENU_LOCK(true)')
            ui.AddContextMenuItem(context, 'Unlock Card(s)', 'ADVANCEDASSISTERMANAGER_MENU_LOCK(false)')
            ui.AddContextMenuItem(context, 'Delete Card(s)', 'None')
            ui.OpenContextMenu(context)
        end},
        {name = 'menuequip', text = 'Equip', callback = function()
            local context = ui.CreateContextMenu('context_menuequip', '', 0, 10, 200, 200)
            --ui.AddContextMenuItem(context, 'キャンセル', 'None')
            ui.AddContextMenuItem(context, 'Equip Cards by Passive Skills', 'ui.ToggleFrame("advancedassistermanager_combo")')
            ui.OpenContextMenu(context)
        end},
        {name = 'menucard', text = 'Card', callback = function()
            local context = ui.CreateContextMenu('context_menucard', '', 0, 10, 200, 200)
            
            ui.AddContextMenuItem(context, 'Auto Combine Cards', 'ADVANCEDASSISTERMANAGER_SHOW_COMBINER()')
            ui.OpenContextMenu(context)
        end},
        {name = 'menusort', text = 'Sort', callback = function()
            local context = ui.CreateContextMenu('context_menusort', '', 0, 10, 200, 200)
            ui.AddContextMenuItem(context, 'No Sort', 'ADVANCEDASSISTERMANAGER_SET_SORT(nil)')
            ui.AddContextMenuItem(context, 'Sort by Rarity', 'ADVANCEDASSISTERMANAGER_SET_SORT(1)')
            ui.AddContextMenuItem(context, 'Sort by Rank', 'ADVANCEDASSISTERMANAGER_SET_SORT(2)')
            ui.AddContextMenuItem(context, 'Sort by Level', 'ADVANCEDASSISTERMANAGER_SET_SORT(3)')
            ui.AddContextMenuItem(context, 'Sort by Name', 'ADVANCEDASSISTERMANAGER_SET_SORT(4)')
            ui.OpenContextMenu(context)
        end}
    },
    getSelectedSlotIndices=function(slotset)
        local selected={}
        for i=0,slotset:GetSlotCount()-1 do
            local slot=slotset:GetSlotByIndex(i)
            if slot:GetIcon()~= nil then
                if slot:IsSelected()==1 then
                    selected[#selected+1] = true
                else
                    selected[#selected+1] = false
                end
            end
        end
        return selected
    end,
    getAllCards = function(noinventory)
        local cards = {}
        for i = 0, 3 do
            local card = session.pet.GetAncientCardBySlot(i)
            if card then
                local classname = card:GetClassName()
                local ancientCls = GetClass("Ancient_Info", classname)
                local exp = card:GetStrExp();
                local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                local level = xpInfo.level
                cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil,
                    isinSlot = true, isinInventory = false,name=ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level}
            end
        
        end
        local cnt = session.pet.GetAncientCardCount()
        
        local height = 0
        for i = 0, cnt - 1 do
            local card = session.pet.GetAncientCardByIndex(i)
            if card and card.slot > 3 then
                local classname = card:GetClassName()
                local ancientCls = GetClass("Ancient_Info", classname)
                local exp = card:GetStrExp();
                local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                local level = xpInfo.level
                cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil,
                    isinSlot = false, isinInventory = false,name=ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level}
            end
        end
        if not noinventory then
            local invItemList = session.GetInvItemList();
            FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem)
                local class = GetClassByType('Item', invItem.type);
                if class.ClassName:find('Ancient_Card_') then
                    local classname = TryGetProp(GetIES(invItem:GetObject()), 'StringArg')
                    local ancientCls = GetClass("Ancient_Info", classname)
                    local ancientCostCls = GetClassByType("Ancient_Rarity", ancientCls.Rarity)
                    for i = 1, invItem.count do
                        cards[#cards + 1] = {card = {
                            GetStrExp=function(self)
                                return "0"
                            end,
                            GetClassName=function(self)
                                return classname
                            end,
                            level=1,
                            starrank=1,
                            rarity=ancientCls.Rarity,
                            slot=0,
                        }, cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = nil,
                            isinSlot = false, isinInventory = true,name=ancientCls.Name, islocked = invItem.isLockState, classname = classname, starrank = 1, lv = 1}
                    end
                end
            
            end, false)
        end
        return cards
    end

}

--ライブラリ読み込み
CHAT_SYSTEM('[AAM]loaded')
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
    EBI_try_catch{
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
    EBI_try_catch{
        try = function()
            CHAT_SYSTEM(msg)
        end,
        catch = function(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_SAVE_SETTINGS()
    --ADVANCEDASSISTERMANAGER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function ADVANCEDASSISTERMANAGER_SAVE_ALL()
    ADVANCEDASSISTERMANAGER_SAVETOSTRUCTURE()
    ADVANCEDASSISTERMANAGER_SAVE_SETTINGS()
    ui.MsgBox('保存しました')
end
function ADVANCEDASSISTERMANAGER_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('advancedassistermanager')
end

function ADVANCEDASSISTERMANAGER_LOAD_SETTINGS()
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
    
    ADVANCEDASSISTERMANAGER_UPGRADE_SETTINGS()
    ADVANCEDASSISTERMANAGER_SAVE_SETTINGS()
    ADVANCEDASSISTERMANAGER_LOADFROMSTRUCTURE()
end

function ADVANCEDASSISTERMANAGER_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('advancedassistermanager')
end

function ADVANCEDASSISTERMANAGER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function ADVANCEDASSISTERMANAGER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(ADVANCEDASSISTERMANAGER_GETCID()))
            frame:ShowWindow(0)
            
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg('ANCIENT_CARD_ADD', 'ADVANCEDASSISTERMANAGER_ON_ANCIENT_CARD_ADD');
            addon:RegisterMsg('INV_ITEM_ADD', 'ADVANCEDASSISTERMANAGER_ON_ANCIENT_CARD_ADD');
            acutil.setupHook(ADVANCEDASSISTERMANAGER_ANCIENT_CARD_LIST_OPEN, 'ANCIENT_CARD_LIST_OPEN')
            acutil.setupHook(UPDATE_AAM_ANCIENT_CARD_TOOLTIP, 'UPDATE_ANCIENT_CARD_TOOLTIP')
            
            frame:ShowWindow(0)
            
            ADVANCEDASSISTERMANAGER_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_SET_SORT(type)
    
    if type == nil then
        g.aam.sort = nil
    else
        if type == 1 then
            --by rarity
            g.aam.sort = function(a, b)
                    
                    if a.rarity == b.rarity then
                        if a.starrank == b.starrank then
                            return a.name < b.name
                        end
                        return a.starrank > b.starrank
                    end
                    return a.rarity > b.rarity
            end
        elseif type == 2 then
            --by rank
            g.aam.sort = function(a, b)
                    
                    if a.starrank == b.starrank then
                        if a.rarity == b.rarity then
                            return a.name < b.name
                        end
                        return a.rarity > b.rarity
                    end
                    return a.starrank > b.starrank
            end
        elseif type == 3 then
            --by level
            g.aam.sort = function(a, b)
                    
                    if a.lv == b.lv then
                        
                        return a.name < b.name
                    
                    end
                    return a.lv > b.lv
            end
        elseif type == 4 then
            --by name
            g.aam.sort = function(a, b)
                    if  a.name == b.name then
                        return a.starrank > b.starrank
                    end
                    
                    return a.name < b.name
            
            end
        end
    end
    ADVANCEDASSISTERMANAGER_INIT_FRAME()
end
function ADVANCEDASSISTERMANAGER_ANCIENT_CARD_LIST_OPEN(rframe)
    ANCIENT_CARD_LIST_OPEN_OLD(rframe)
    local frame = ui.GetFrame('ancient_card_list')
    local adv = frame:CreateOrGetControl('button', 'btnadv', 0, 0, 99, 33)
    AUTO_CAST(adv)
    adv:SetGravity(ui.LEFT, ui.BOTTOM)
    adv:SetMargin(90 + 35, 0, 0, 9)
    adv:SetText("{@st41}Adv")
    adv:SetSkinName('test_pvp_btn')
    adv:SetEventScript(ui.LBUTTONUP, 'ADVANCEDASSISTERMANAGER_TOGGLEFRAME')

    ADVANCEDASSISTERMANAGER_INIT_FRAME()
end
function ADVANCEDASSISTERMANAGER_TOGGLEFRAME()
    ui.ToggleFrame(g.framename)
end
function ADVANCEDASSISTERMANAGER_INIT_FRAME()
    local frame = ui.GetFrame(g.framename)
    local gbox = frame:CreateOrGetControl('groupbox', 'gbox', 5, 100, frame:GetWidth() - 10, frame:GetHeight() - 140)
    gbox:RemoveAllChild()
    gbox:SetSkinName('bg2')
    local slotset = gbox:CreateOrGetControl('slotset', 'cards', 5, 5, gbox:GetWidth() - 25, gbox:GetHeight()-10)
    AUTO_CAST(slotset)
    

    ui.EnableSlotMultiSelect(0)

    ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotset)
    --menus
    local x = 10
    for _, v in ipairs(g.aam.menus) do
        local btn = frame:CreateOrGetControl('button', v.name, x, 60, 80, 30);
        btn:SetSkinName('test_pvp_btn')
        btn:SetText("{@st41}" .. v.text)
        btn:SetEventScript(ui.LBUTTONUP, 'ADVANCEDASSISTERMANAGER_ON_MENU_BTN')
        
        x = x + btn:GetWidth() + 5
    end

    ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotset)
end
function ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotset,w,h,pop,c,r)
    AUTO_CAST(slotset)
    slotset:SetSkinName('accountwarehouse_slot')
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:EnablePop(pop or 1)
    slotset:EnableSelection(0)
    slotset:SetSlotSize(w or 100, h or 120)
    slotset:SetSpc(3, 3)

    if r then
        slotset:SetColRow(c,r) 
           
        slotset:CreateSlots()
    end
end

function ADVANCEDASSISTERMANAGER_SLOTSET_ON_MOUSEMOVE(frame, slot)
    local parent=slot:GetParent()
    AUTO_CAST(slot)
    local state=tonumber(parent:GetUserValue("lbtnpressed"))
    if mouse.IsLBtnPressed() == 1 then
        if state == nil  then
            if slot:IsSelected() == 1 then
                state = 0
               
            else
                state = 1
            end
            parent:SetUserValue('lbtnpressed',tostring(state))
        end
        if (slot:GetUserIValue('islocked')==1 and parent:GetUserIValue('islockedselectable')~=1) then
            state=0
        end
        slot:Select(state)
        
    else
        state = nil
        parent:SetUserValue('lbtnpressed',nil)
    end
  
end
function ADVANCEDASSISTERMANAGER_ON_ANCIENT_CARD_ADD()
    if ui.GetFrame(g.framename):IsVisible()==1 then
        ADVANCEDASSISTERMANAGER_INIT_FRAME()
    end
end
function ADVANCEDASSISTERMANAGER_SET_SLOT(slot,v,nodesc)
    local icon = CreateIcon(slot)
    local monCls = GetClass("Monster", v.classname);
    local iconName = TryGetProp(monCls, "Icon");
    icon:SetImage(iconName)
    slot:SetUserValue('islocked',BoolToNumber(v.islocked))
    if nodesc == nil then
        nodesc=false

    end
    if nodesc==false then
        local starStr = ''
        for ii = 1, v.starrank do
            starStr = starStr .. string.format("{img monster_card_starmark %d %d}", 15, 15)
        end
        local starr = slot:CreateOrGetControl("richtext", 'rank', 0, 0, 60, 20)
        
        starr:SetGravity(ui.LEFT, ui.BOTTOM)
        starr:SetMargin(0, 0, 0, 0)
        starr:SetText(starStr)
        starr:EnableHitTest(0)
        starr:SetSkinName('bg2')

        
        local statetext = slot:CreateOrGetControl('richtext', 'state', 0, 0, 40, 20)
        local stateStr = ''
        if v.isinSlot then
            stateStr = stateStr .. '{img icon_item_ancient_card 20 20}'
        end
        if v.isinInventory then
            stateStr = stateStr .. '{img icon_item_farm47_sack_01 20 20}'
        end
        if v.islocked then
            stateStr = stateStr .. '{img inven_lock2 15 20}'
        end
        
        statetext:SetGravity(ui.RIGHT, ui.BOTTOM)
        statetext:SetMargin(0, 0, 0, 0)
        statetext:SetText(stateStr)
        statetext:EnableHitTest(0)
        statetext:SetSkinName('bg')
        local costtext = slot:CreateOrGetControl('richtext', 'cost', 0, 0, 30, 30)
        costtext:SetGravity(ui.RIGHT, ui.TOP)
        costtext:SetMargin(3, 3, 3, 3)
        costtext:SetText('{#44FFFF}{@st41}{s18}' .. tostring(v.cost))
        costtext:EnableHitTest(0)
        costtext:SetSkinName('none')
        local ancientCls = GetClass("Ancient_Info", monCls.ClassName)
        local rarity = ancientCls.Rarity
        local raritycolor = ''
        if rarity == 1 then
            raritycolor = '{#ffffff}'
        elseif rarity == 2 then
            raritycolor = '{#0e7fe8}'
        elseif rarity == 3 then
            raritycolor = '{#d92400}'
        --raritycolor ='{#d94822}'
        elseif rarity == 4 then
            raritycolor = '{#ffa800}'
        end
        local lvstr = raritycolor .. '{ol}{@st41}{s18}' .. raritycolor .. 'Lv' .. v.lv
        local lvtext = slot:CreateOrGetControl('richtext', 'lv', 0, 0, 30, 30)
        lvtext:SetGravity(ui.LEFT, ui.TOP)
        lvtext:SetMargin(3, 3, 3, 3)
        lvtext:SetText(lvstr)
        lvtext:EnableHitTest(0)
        lvtext:SetSkinName('none')
        local namestr = '{ol}{s14}' .. raritycolor .. monCls.Name
        local nametext = slot:CreateOrGetControl('richtext', 'name', 0, 0, 30, 30)
        nametext:SetGravity(ui.LEFT, ui.TOP)
        nametext:SetMargin(3, 28, 3, 3)
        nametext:SetText(namestr)
        nametext:EnableHitTest(0)
        nametext:SetSkinName('none')
    end
    icon:SetTooltipType("ancient_card")
    icon:SetTooltipStrArg(v.guid)
    icon:SetUserValue("ANCIENT_GUID", v.guid)
end
function ADVANCEDASSISTERMANAGER_GET_SELECTED_CARDS()
    local frame = ui.GetFrame(g.framename)
    local cards = AUTO_CAST(frame:GetChildRecursively('cards'))
    local aamcards={}
    local ref=g.aam.getAllCards()
    for i=0,cards:GetSlotCount()-1 do
        local slot = cards:GetSlotByIndex(i)
        local icon=slot:GetIcon()
        if icon and slot:IsSelected()==1 then
            local guid= icon:GetUserValue("ANCIENT_GUID")
            if guid then
                for _,v in ipairs(ref) do
                    if v.guid==guid then
                        aamcards[#aamcards+1] = v
                        break
                    end
                end
            end
        end
    end
    return aamcards
end

function ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotset,selectedindices,cards,nodesc)
    EBI_try_catch{
        try = function()

            slotset:RemoveAllChild()
            
            local cardlist = cards or g.aam.getAllCards()
            if g.aam.sort then
                
                table.sort(cardlist, g.aam.sort)
            end
            slotset:SetColRow(7, math.ceil(#cardlist / 7))

   
            slotset:CreateSlots()
            for i, v in ipairs(cardlist) do
                local slot = slotset:GetSlotByIndex(i - 1)
                AUTO_CAST(slot)
                
                slot:SetUserValue('islockedselectable',1)
                slot:SetEventScript(ui.MOUSEMOVE, 'ADVANCEDASSISTERMANAGER_SLOTSET_ON_MOUSEMOVE')
                ADVANCEDASSISTERMANAGER_SET_SLOT(slot,v,nodesc)
                if selectedindices then
                    if selectedindices[i] then

                        slot:Select(1)
                    else
                        slot:Select(0)
                    end
                end
            end
              
         
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end
function ADVANCEDASSISTERMANAGER_ON_MENU_BTN(frame, ctrl)
    EBI_try_catch{
        try = function()
            for _, v in ipairs(g.aam.menus) do
                
                if ctrl:GetName() == v.name then
                    
                    assert(pcall(v.callback))
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_ENSURECARDS(aamcards,needunlock,callback)
    local needtounlock=0
    local needtoadd=0

    for _,v in ipairs(aamcards) do
        if v.isinInventory then
            if v.islocked then
                needtounlock=needtounlock+1
            
            else
                
            end
            needtoadd=needtoadd+1
        else
            -- nothing to do
            if v.islocked and needunlock then
                needtounlock=needtounlock+1
            end
        end
    end
    if needtounlock > 0 or needtoadd > 0 then
        if needtoadd>(ANCIENT_CARD_SLOT_MAX-session.pet.GetAncientCardCount()) then
            ui.SysMsg('Insufficient empty slots.')
            return false
        end
        g.aam.watchingcards=aamcards
        g.aam.watchingcallback=callback
        ui.MsgBox(
            string.format('To unlock cards:%d{nl}To add cards as assister:%d{nl}Proceed?',
        string.format("ADVANCEDASSISTERMANAGER_DO_ENSURECARDS('%s')",tostring(needunlock)),'None'))
        return true
    else
        pcall(callback)
    end
    return false
end

function ADVANCEDASSISTERMANAGER_DO_ENSURECARDS(needunlock)
    local needtounlock=0
    local needtoadd=0
    local delay=0
    for _,v in ipairs( g.aam.watchingcards) do
        if v.isinInventory then
            if v.islocked then
                needtounlock=needtounlock+1
                ReserveScript(string.format("session.inventory.SendLockItem('%s', %d)",v.guid,0),delay)
                delay=delay+0.1
            else
                
            end
            ReserveScript(string.format("ANCIENT_CARD_REGISTER_C('%s')",v.guid),delay)
            delay=delay+0.1
            needtoadd=needtoadd+1
        else
            -- nothing to do
            if v.islocked and needunlock then
                ReserveScript(string.format("ReqLockAncientCard('guid')",v.guid),delay)
                delay=delay+0.1
                needtounlock=needtounlock+1
                
            end
        end
    end
    return delay
end
function ADVANCEDASSISTERMANAGER_LOCK(aamcards,lock)
    local delay=0
    for _,v in ipairs( aamcards) do
        if v.isinInventory then
            if v.islocked ~= lock then
                ReserveScript(string.format("session.inventory.SendLockItem('%s', %d)",v.guid,BoolToNumber(lock)),delay)
                delay=delay+0.1
            end
        else
            if v.islocked ~= lock then
                ReserveScript(string.format("ReqLockAncientCard('%s')",v.guid),delay)
                delay=delay+0.1
            end
        end
    end
    return delay
end
function ADVANCEDASSISTERMANAGER_MENU_LOCK(lock)
       EBI_try_catch{
        try = function()
        local aamcards=ADVANCEDASSISTERMANAGER_GET_SELECTED_CARDS()
        local delay=ADVANCEDASSISTERMANAGER_LOCK(aamcards,lock)
        ReserveScript('ADVANCEDASSISTERMANAGER_INIT_FRAME()',delay+0.8)
       end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UPDATE_AAM_ANCIENT_CARD_TOOLTIP(frame, guid)
    EBI_try_catch{
        try = function()
            UPDATE_ANCIENT_CARD_TOOLTIP_OLD(frame, guid)
            local card = session.pet.GetAncientCardByGuid(guid);
            if card then
                
                return;
            end
            local invItem = session.GetInvItemByGuid(guid);
            if invItem == nil then
                return;
            end
            local itemObj = GetIES(invItem:GetObject())
            local class = GetClassByType('Item', invItem.type);
            local classname = TryGetProp(GetIES(invItem:GetObject()), 'StringArg')
            local monCls = GetClass("Monster", classname)
            if monCls == nil then
                return;
            end
            
            local exp = 0;
            local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
            local level = xpInfo.level
            --set rarity
            local infoCls = GetClass("Ancient_Info", monCls.ClassName)
            local nameBox = frame:GetChild("name_box")
            local rarityText = nameBox:GetChild("rarity")
            local rarity = infoCls.Rarity
            
            if rarity == 1 then
                rarityText:SetText(frame:GetUserConfig("NORMAL_GRADE_TEXT"))
            elseif rarity == 2 then
                rarityText:SetText(frame:GetUserConfig("MAGIC_GRADE_TEXT"))
            elseif rarity == 3 then
                rarityText:SetText(frame:GetUserConfig("UNIQUE_GRADE_TEXT"))
            elseif rarity == 4 then
                rarityText:SetText(frame:GetUserConfig("LEGEND_GRADE_TEXT"))
            end
            card={
                GetStrExp=function(self)
                    return "0"
                end,
                starrank=1,

            }
            --set name
            local name = nameBox:GetChild("name")
            name:SetText('{@st42b}{s16}[Lv.' .. level .. '] ' .. monCls.Name .. '{/}')
            
            --set image
            local monsterInfo = frame:GetChild("monster_info")
            local monsterImg = monsterInfo:GetChild("img")
            local iconName = TryGetProp(monCls, "Icon");
            AUTO_CAST(monsterImg)
            monsterImg:SetImage(iconName)
            --set star
            local starrankText = monsterImg:GetChild("starrank")
            local starrank = 1
            local starStr = ""
            for i = 1, starrank do
                starStr = starStr .. string.format("{img monster_card_starmark %d %d}", 21, 20)
            end
            starrankText:SetText(starStr)
            --exp gauge
            local expGauge = monsterInfo:GetChild("exp")
            AUTO_CAST(expGauge)
            local totalExp = xpInfo.totalExp - xpInfo.startExp;
            local curExp = exp - xpInfo.startExp;
            expGauge:SetPoint(curExp, totalExp);
            
            --stat load
            local mon1obj = CreateGCIES('Monster', monCls.ClassName);
            mon1obj.Lv = level;
            SetExProp(mon1obj, 'STARRANK', 1)
            local statList = {'MHP', 'PATK', 'MATK', 'DEF', 'MDEF', 'HR', 'DR'}
            local monsterStat = frame:GetChild("monster_stat")
            monsterStat:RemoveAllChild()
            
            local statBaseText = monsterStat:CreateControl("richtext", "monster_stat_1", 100, 31, ui.LEFT, ui.TOP, 10, 0, 0, 0);
            local font = "{@st66b}{s16}"
            statBaseText:SetText(font .. ScpArgMsg("DetailInfo") .. "{/}")
            statBaseText:SetFontName("brown_16")
            
            local height = 31
            for i = 1, #statList do
                local statName = statList[i]
                local statNameCtrl = monsterStat:CreateControl("richtext", statName .. "_name", 100, 30, ui.LEFT, ui.TOP, 10, height, 0, 0);
                statNameCtrl:SetFontName("brown_18")
                statNameCtrl:SetText(ScpArgMsg(statName))
                local statValueCtrl = monsterStat:CreateControl("richtext", statName .. "_val", 100, 30, ui.RIGHT, ui.TOP, 0, height, 10, 0)
                statValueCtrl:SetFontName("brown_18")
                if statName == "MATK" or statName == "PATK" then
                    local statMinFunc = _G["SCR_Get_MON_MIN" .. statName]
                    local statMaxFunc = _G["SCR_Get_MON_MAX" .. statName]
                    local statMin = statMinFunc(mon1obj)
                    local statMax = statMaxFunc(mon1obj)
                    statValueCtrl:SetText(font .. statMin .. '~' .. statMax .. "{/}")
                else
                    local statFunc = _G["SCR_Get_MON_" .. statName]
                    local statVal = statFunc(mon1obj);
                    statValueCtrl:SetText(font .. statVal .. "{/}")
                end
                height = height + 25
            end
            
            local exStatList = {"RaceType", "Attribute"}
            for i = 1, #exStatList do
                local exStat = exStatList[i]
                local exstatNameCtrl = monsterStat:CreateControl("richtext", exStat .. "_name", 100, 30, ui.LEFT, ui.TOP, 10, height, 0, 0);
                exstatNameCtrl:SetText(font .. ClMsg(exStat) .. "{/}")
                local exstatValueCtrl = monsterStat:CreateControl("richtext", exStat .. "_val", 100, 30, ui.RIGHT, ui.TOP, 0, height, 10, 0)
                exstatValueCtrl:SetText(font .. ScpArgMsg("MonInfo_" .. exStat .. "_" .. TryGetProp(monCls, exStat)) .. "{/}")
                height = height + 25
            end
            local ancientCostCls = GetClassByType("Ancient_Rarity", rarity)
            local monster_cost = frame:GetChild("monster_cost")
            local costValueCtrl = monster_cost:GetChild("cost_val")
            costValueCtrl:SetText(font .. ancientCostCls.Cost .. "{/}")
            local caption, parsed = TRY_PARSE_ANCIENT_PROPERTY(infoCls, infoCls.Tooltop, card);
            local monster_passive = frame:GetChild("monster_passive")
            local passiveValueCtrl = monster_passive:GetChild("passive_val")
            passiveValueCtrl:SetText(caption)
            
            do
                local costName = monster_cost:GetChild("cost_name")
                costName:Invalidate()
                local passive_name = monster_passive:GetChild("passive_name")
                passive_name:Invalidate()
            end
            
            monster_passive:Resize(monster_passive:GetWidth(), 30 + passiveValueCtrl:GetHeight())
            
            frame:Resize(frame:GetWidth(), 500 + monster_passive:GetHeight())
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_SHOW_COMBINER()
    ui.GetFrame('advancedassistermanager_combiner'):ShowWindow(1)
end


_G['ADDONS'][author][addonName] = g
