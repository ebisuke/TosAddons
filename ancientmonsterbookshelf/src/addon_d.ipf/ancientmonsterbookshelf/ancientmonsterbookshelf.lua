--ancientmonsterbookshelf
local addonName = 'ANCIENTMONSTERBOOKSHELF'
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
g.wkcards = nil
g.wkcombine = nil
g.wkinit = nil
g.working = false
g.wkreuse = nil
g.wkcards_before = nil
g.configurepattern = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'ancientmonsterbookshelf'
g.debug = false
g.cardsize = {100, 140}
g.addon = g.addon
g.slotsetcards = g.slotsetcards
g.slotsetinvs = g.slotsetinvs
g.working = false
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
g.aam = {
        
        getSelectedSlotIndices = function(slotset)
            local selected = {}
            for i = 0, slotset:GetSlotCount() - 1 do
                local slot = slotset:GetSlotByIndex(i)
                if slot:GetIcon() ~= nil then
                    if slot:IsSelected() == 1 then
                        selected[#selected + 1] = true
                    else
                        selected[#selected + 1] = false
                    end
                end
            end
            return selected
        end,
        getSelectedCards = function(compactinvitem)
            local frame = g.frame
            local cards = g.aam.getSelectedSlotsAsCard(AUTO_CAST(frame:GetChildRecursively("slotcards")), compactinvitem)
            local cardsinv = g.aam.getSelectedSlotsAsCard(AUTO_CAST(frame:GetChildRecursively("slotcardsinv")), compactinvitem)
            for k, v in ipairs(cardsinv) do
                
                cards[#cards + 1] = v
            end
            return cards
        
        end,
        convertInvCardToBookCard = function(cards, nolocked)
            local frame = g.frame
            local cardsbook = g.aam.getAllCards(false, true, nolocked, false)
            local cards = deepcopy(cards)
            local out = {}
            for k, v in ipairs(cards) do
                if v.isinInventory then
                   
                else
                    for kk, vv in ipairs(cardsbook) do
                        if  cards[k].isinInventory==false and cards[k].count>0 and cardsbook[kk].count>0 and vv.guid == v.guid  then
                            out[#out + 1] = deepcopy(vv)
                            cardsbook[kk].count = cardsbook[kk].count - 1
                            cards[k].count = cards[k].count - 1
                            break
                        end
                    end
                end
            
            end
            for k, v in ipairs(cards) do
                if v.isinInventory then
                    for kk, vv in ipairs(cardsbook) do
                        if  cards[k].count>0 and cardsbook[kk].count>0  and vv.starrank == v.starrank and vv.lv == v.lv and vv.classname == v.classname then
                            out[#out + 1] = deepcopy(vv)
                            cardsbook[kk].count = cardsbook[kk].count - 1
                            cards[k].count = cards[k].count - 1
                            break
                        end
                    end
                else
                    
                end
            
            end
            
            return out
        
        end,
        getSelectedSlotsAsCard = function(slotset, compactinvitem)
            
            local aamcards = {}
            local ref = g.aam.getAllCards(nil, nil, nil, true)
            for i = 0, slotset:GetSlotCount() - 1 do
                local slot = slotset:GetSlotByIndex(i)
                local icon = slot:GetIcon()
                if icon and slot:IsSelected() == 1 then
                    local guid = icon:GetUserValue("ANCIENT_GUID")
                    if guid then
                        for k, v in ipairs(ref) do
                            if v.guid == guid then
                                if compactinvitem then
                                    aamcards[#aamcards + 1] = deepcopy(v)
                                    table.remove(ref, k)
                                    break
                                
                                else
                                    for i = 1, ref[k].count do
                                        aamcards[#aamcards + 1] = deepcopy(v)
                                        aamcards[#aamcards].count = 1
                                    end
                                    table.remove(ref, k)
                                    break
                                end
                            
                            
                            end
                        end
                    end
                end
            end
            return aamcards
        
        end,
        getSameStatCards = function(cards)
            local assisters = g.aam.getAllCards(true, true)
            local sames = {}
            for k, v in ipairs(cards) do
                
                for kk, vv in ipairs(assisters) do
                    if vv.islocked == false and vv.classname == v.classname and vv.lv == v.lv then
                        sames[#sames + 1] = vv
                        table.remove(assisters, kk)
                        break
                    end
                end
            end
            return sames
        end,
        getSameRarityCards = function(cards)
            local assisters = g.aam.getAllCards(true, true)
            local sames = {}
            for k, v in ipairs(cards) do
                
                for kk, vv in ipairs(assisters) do
                    if vv.islocked == false and vv.rarity == v.rarity then
                        sames[#sames + 1] = vv
                        table.remove(assisters, kk)
                        break
                    end
                end
            end
            return sames
        end,
        getCardsCount = function(cards, noinv)
            local count = 0
            for k, v in ipairs(cards) do
                if not noinv or not v.isinInventory then
                    count = count + v.count
                end
            end
            print("" .. count)
            return count
        end,
        getCardByGuid = function(guid)
            local cards = {}
            local cardraw = session.ancient.GetAncientCardByGuid(guid)
            if cardraw then
                local classname = cardraw:GetClassName()
                local ancientCls = GetClass("Ancient_Info", classname)
                local exp = cardraw:GetStrExp();
                local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                local level = xpInfo.level
                cards[#cards + 1] = {card = cardraw, cost = cardraw:GetCost(), rarity = ancientCls.Rarity, guid = cardraw:GetGuid(), invItem = nil, exp = exp, count = 1,
                isinSlot = false, isinInventory = false, name = ancientCls.Name, islocked = cardraw.isLock, classname = cardraw:GetClassName(), starrank = cardraw.starrank, lv = level}
                return cards
            end

            local card
            local cards = g.aam.getAllCards()
            for k, v in ipairs(cards) do
                if v.guid == guid then
                    
                    card = v
                    break
                end
            end
            if card == nil then
                
                return {}
            end
            local classname = card.card:GetClassName()
            local ancientCls = GetClass("Ancient_Info", classname)
            local exp = card.card:GetStrExp();
            local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
            local level = xpInfo.level
           
            cards[#cards + 1] = {card = card, cost = card.card:GetCost(), rarity = ancientCls.Rarity, guid = card.card:GetGuid(), invItem = nil, exp = exp, count = card.count,
                isinSlot = false, isinInventory = card.isinInventory, name = ancientCls.Name, islocked = card.isLock, classname = card.card:GetClassName(), starrank = card.starrank, lv = level}
            
            return cards
        end,
        getAllCards = function(nolive, noinventory, nolocked, compactinvitem)
            local cards = {}
            if not nolive then
                for i = 0, 3 do
                    local card = session.ancient.GetAncientCardBySlot(i)
                    if card then
                        local classname = card:GetClassName()
                        local ancientCls = GetClass("Ancient_Info", classname)
                        local exp = card:GetStrExp();
                        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                        local level = xpInfo.level
                        if not nolocked or not card.isLock then
                            cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp, count = 1,
                                isinSlot = true, isinInventory = false, name = ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level}
                        end
                    end
                
                end
                local cnt = session.ancient.GetAncientCardCount()
                
                local height = 0
                for i = 0, cnt - 1 do
                    local card = session.ancient.GetAncientCardByIndex(i)
                    if card and card.slot > 3 then
                        local classname = card:GetClassName()
                        local ancientCls = GetClass("Ancient_Info", classname)
                        local exp = card:GetStrExp();
                        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                        local level = xpInfo.level
                        if not nolocked or not card.isLock then
                            cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp, count = 1,
                                isinSlot = false, isinInventory = false, name = ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level}
                        end
                    end
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
                        if compactinvitem then
                            if not nolocked or not invItem.isLockState then
                                cards[#cards + 1] = {card = {
                                    GetStrExp = function(self)
                                        return "0"
                                    end,
                                    GetClassName = function(self)
                                        return classname
                                    end,
                                    GetCost = function(self)
                                        return  ancientCostCls.Cost
                                    end,
                                    GetGuid = function(self)
                                        return   invItem:GetIESID()
                                    end,
                                    level = 1,
                                    starrank = 1,
                                    rarity = ancientCls.Rarity,
                                    slot = 0,
                                }, cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = invItem, exp = 0, count = invItem.count,
                                isinSlot = false, isinInventory = true, name = ancientCls.Name, islocked = invItem.isLockState, classname = classname, starrank = 1, lv = 1}
                            end
                        else
                            for i = 1, invItem.count do
                                if not nolocked or not invItem.isLockState then
                                    cards[#cards + 1] = {card = {
                                        GetStrExp = function(self)
                                            return "0"
                                        end,
                                        GetClassName = function(self)
                                            return classname
                                        end,
                                        GetCost = function(self)
                                            return  ancientCostCls.Cost
                                        end,
                                        GetGuid = function(self)
                                            return   invItem:GetIESID()
                                        end,
                                        level = 1,
                                        starrank = 1,
                                        rarity = ancientCls.Rarity,
                                        slot = 0,
                                    }, cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = invItem, exp = 0, count = 1,
                                    isinSlot = false, isinInventory = true, name = ancientCls.Name, islocked = invItem.isLockState, classname = classname, starrank = 1, lv = 1}
                                end
                            end
                        
                        end
                    end
                
                end, false)
            end
            return cards
        end
        , actions = {
            {text = "Deselect All", action = function(cards)
                for i = 0, g.slotsetcards:GetSlotCount() - 1 do
                    local slot = g.slotsetcards:GetSlotByIndex(i)
                    slot:Select(0)
                end
                for i = 0, g.slotsetinvs:GetSlotCount() - 1 do
                    local slot = g.slotsetinvs:GetSlotByIndex(i)
                    slot:Select(0)
                end
            end, state = function() return true end},
            {text = "Lock", action = function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards, true) end, state = function() return true end},
            {text = "Unlock", action = function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards, false) end, state = function() return true end},
            
            {text = "{#00FF00}Evolve", action = function(cards)ANCIENTMONSTERBOOKSHELF_EVOLVE(cards) end, state = function() return g.aam.isUnsafe() and g.aam.isAllUnlocked() and g.aam.canEvolve() end},
            
            {text = "{#00FFFF}Auto Combine", action = function(cards)ANCIENTMONSTERBOOKSHELF_COMBINE(cards) end, state = function() return g.aam.isUnsafe() and g.aam.isAllUnlocked() and g.aam.canCombine() and (g.aam.getCardsCount(g.aam.getSelectedCards()) >= 3) end},
        
        },
        isUnsafe = function()
            local frame = g.frame
            local chk = frame:GetChildRecursively("chkmode")
            AUTO_CAST(chk)
            return chk:IsChecked() == 0
        end
        ,
        isAllUnlocked = function()
            local cards = g.aam.getSelectedCards()
            for _, v in ipairs(cards) do
                if v.islocked == true then
                    return false
                end
            
            end
            return true
        end,
        isAllInv = function()
            local cards = g.aam.getSelectedCards()
            if #cards == 0 then
                return false
            end
            for _, v in ipairs(cards) do
                if not v.isinInventory then
                    return false
                end
            
            end
            return true
        end,
        canEvolve = function()
            local cards = g.aam.getSelectedCards()
            if g.aam.getCardsCount(cards) < 3 then
                return false
            end
            local base = cards[1]
            for _, v in ipairs(cards) do
                if base.classname ~= v.classname or base.starrank ~= v.starrank then
                    return false
                end
            end
            return true
        end,
        canCombine = function()
            local cards = g.aam.getSelectedCards()
            if g.aam.getCardsCount(cards) < 3 then
                return false
            end
            local base = cards[1]
            for _, v in ipairs(cards) do
                if  base.rarity ~= v.rarity then
                    return false
                end
            end
            return true
        end,
}

--ライブラリ読み込み
CHAT_SYSTEM('[AMB]loaded')
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
            print(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function ANCIENTMONSTERBOOKSHELF_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            
            if not g.loaded then
                g.loaded = true
            end
            ANCIENTMONSTERBOOKSHELF_INITFRAME()
            addon:RegisterMsg('ANCIENT_CARD_COMBINE', 'ANCIENTMONSTERBOOKSHELF_ON_ANCIENT_CARD_UPDATE');
            addon:RegisterMsg('ANCIENT_CARD_EVOLVE', 'ANCIENTMONSTERBOOKSHELF_ON_ANCIENT_CARD_UPDATE');
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_INITFRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local origframe = ui.GetFrame("ancient_card_list")
            local btn = origframe:GetChildRecursively("topbg"):CreateOrGetControl("button", "btnopenamb", 0, 0, 90, 33)
            AUTO_CAST(btn)
            btn:SetGravity(ui.LEFT, ui.BOTTOM)
            btn:SetMargin(105, 0, 0, 0)
            btn:SetText("{ol}AMB")
            btn:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_TOGGLE")
            local btn = frame:CreateOrGetControl("button", "btnsort", 0, 0, 90, 33)
            AUTO_CAST(btn)
            btn:SetGravity(ui.TOP, ui.LEFT)
            btn:SetMargin(200, 60, 0, 0)
            btn:SetText("{ol}Sort")
            btn:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_ON_SORT")
            local chk = frame:CreateOrGetControl("checkbox", "chkmode", 0, 0, 90, 33)
            AUTO_CAST(chk)
            chk:SetGravity(ui.TOP, ui.LEFT)
            chk:SetMargin(60, 70, 0, 0)
            chk:SetSkinName("slide_btn_small")
            chk:SetText("{ol}Edit")
            chk:SetCheck(1)
            chk:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS")
            local chk = frame:CreateOrGetControl("richtext", "chkview", 0, 0, 90, 33)
            AUTO_CAST(chk)
            chk:SetGravity(ui.TOP, ui.LEFT)
            chk:SetMargin(16, 76, 0, 0)
            chk:SetText("{ol}{s16}View")
            local chk = frame:CreateOrGetControl("richtext", "chksafe", 0, 0, 90, 33)
            AUTO_CAST(chk)
            chk:SetGravity(ui.TOP, ui.LEFT)
            chk:SetMargin(50, 60, 0, 0)
            chk:SetText("{ol}{s12}Safety Switch")
            local txt = frame:CreateOrGetControl("richtext", "labelslot", 0, 0, 90, 33)
            AUTO_CAST(txt)
            txt:SetGravity(ui.TOP, ui.LEFT)
            txt:SetMargin(16, 120, 0, 0)
            txt:SetText("{ol}{s20}Assister Box")
            local txt = frame:CreateOrGetControl("richtext", "labelinventory", 0, 0, 90, 33)
            AUTO_CAST(txt)
            txt:SetGravity(ui.TOP, ui.LEFT)
            txt:SetMargin(566, 120, 0, 0)
            txt:SetText("{ol}{s20}Inventory")
            local txt = frame:CreateOrGetControl("richtext", "labelcardcount", 0, 0, 90, 33)
            AUTO_CAST(txt)
            txt:SetGravity(ui.LEFT, ui.BOTTOM)
            txt:SetMargin(40, 0, 0, 60)
            txt:SetText("{ol}{s20}Cards")
            local gauge = frame:CreateOrGetControl("gauge", "progresscardcount", 0, 0, 500, 16)
            AUTO_CAST(gauge)
            gauge:SetGravity(ui.LEFT, ui.BOTTOM)
            gauge:SetMargin(40, 0, 0, 30)
            gauge:SetDrawStyle(ui.GAUGE_DRAW_CELL);
            gauge:SetCellPoint(1)
            gauge:SetSkinName("dot_skillslot");
            local gbox = frame:CreateOrGetControl("groupbox", "gboxwk", 0, 0, 800, 220)
            AUTO_CAST(gbox)
            gbox:SetGravity(ui.RIGHT, ui.BOTTOM)
            gbox:SetMargin(0, 0, 20, 10)
            gbox:SetSkinName("bg2")
            local txt = gbox:CreateOrGetControl("richtext", "txtprogress", 0, 0, 66, 140)
            AUTO_CAST(txt)
            txt:SetGravity(ui.LEFT, ui.TOP)
            txt:SetMargin(20, 20, 0, 0)
            txt:SetText("{ol}Workbench")
            local btn = gbox:CreateOrGetControl("button", "btncancel", 0, 0, 120, 40)
            AUTO_CAST(btn)
            btn:SetGravity(ui.BOTTOM, ui.RIGHT)
            btn:SetMargin(0, 0, 40, 40)
            btn:SetText("{s20}{ol}Cancel")
            btn:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_ON_CANCEL")
            local slot = gbox:CreateOrGetControl("slot", "slotcombine1", 0, 0, g.cardsize[1], g.cardsize[2])
            AUTO_CAST(slot)
            slot:SetGravity(ui.LEFT, ui.CENTER_VERT)
            slot:SetMargin(20 + g.cardsize[1] * 0, 0, 0, 0)
            slot:SetSkinName('accountwarehouse_slot')
            local slot = gbox:CreateOrGetControl("slot", "slotcombine2", 0, 0, g.cardsize[1], g.cardsize[2])
            AUTO_CAST(slot)
            slot:SetGravity(ui.LEFT, ui.CENTER_VERT)
            slot:SetMargin(20 + g.cardsize[1] * 1, 0, 0, 0)
            slot:SetSkinName('accountwarehouse_slot')
            local slot = gbox:CreateOrGetControl("slot", "slotcombine3", 0, 0, g.cardsize[1], g.cardsize[2])
            AUTO_CAST(slot)
            slot:SetGravity(ui.LEFT, ui.CENTER_VERT)
            slot:SetMargin(20 + g.cardsize[1] * 2, 0, 0, 0)
            slot:SetSkinName('accountwarehouse_slot')
            local slot = gbox:CreateOrGetControl("slot", "slotcombineproduct", 0, 0, g.cardsize[1], g.cardsize[2])
            AUTO_CAST(slot)
            slot:SetGravity(ui.LEFT, ui.CENTER_VERT)
            slot:SetMargin(20 + g.cardsize[1] * 3 + 30, 0, 0, 0)
            slot:SetSkinName('accountwarehouse_slot')
            local gauge = gbox:CreateOrGetControl("gauge", "progresscombine", 0, 0, 600, 16)
            AUTO_CAST(gauge)
            gauge:SetGravity(ui.RIGHT, ui.TOP)
            gauge:SetMargin(0, 20, 40, 0)
            
            --AMB
            ANCIENTMONSTERBOOKSHELF_REFRESH_CARDSLOTS(false)
            ANCIENTMONSTERBOOKSHELF_REFRESH_CARDSLOTS(true)
            ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_UPDATE()
    ANCIENTMONSTERBOOKSHELF_REFRESH_CARDSLOTS(false)
    ANCIENTMONSTERBOOKSHELF_REFRESH_CARDSLOTS(true)
    ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS()

end
function ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local gbox = frame:CreateOrGetControl("groupbox", "gboxaction", 0, 0, 150, frame:GetHeight() - 300)
            gbox:SetGravity(ui.RIGHT, ui.TOP)
            gbox:SetMargin(0, 150, 20, 0)
            for k, v in ipairs(g.aam.actions) do
                local btn = gbox:CreateOrGetControl("button", 'btn' .. k, 0, 32 * (k - 1), 150, 30)
                btn:SetText(v.text)
                btn:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_DO_ACTION")
                btn:SetEventScriptArgNumber(ui.LBUTTONUP, k)
                if v.state and g.working == false then
                    
                    if v.state() then
                        btn:SetEnable(1)
                    
                    else
                        btn:SetEnable(0)
                    end
                else
                    btn:SetEnable(0)
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_DO_ACTION(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            frame = g.frame
            local cards = g.aam.getSelectedCards(false)
            g.aam.actions[argnum].action(cards)
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_LOCK(aamcards, lock)
    local delay = 0.0
    aamcards = g.aam.getSelectedCards(true)
    ANCIENTMONSTERBOOKSHELF_SET_WORKING(true)
    local sentguid = {}
    for _, v in ipairs(aamcards) do
        if not sentguid[v.guid] then
            if v.isinInventory then
                if v.islocked ~= lock then
                    
                    ReserveScript(string.format("session.inventory.SendLockItem('%s', %d)", v.guid, BoolToNumber(lock)), delay)
                    delay = delay + 0.8
                end
            else
                if v.islocked ~= lock then
                    print(v.guid)
                    ReserveScript(string.format("ReqLockAncientCard('%s')", v.guid), delay)
                    delay = delay + 0.8
                end
            end
            sentguid[v.guid] = true
        end
    end
    delay = delay + 0
    ReserveScript(string.format("   ANCIENTMONSTERBOOKSHELF_SET_WORKING(false)"), delay)
    
    return delay
end
function ANCIENTMONSTERBOOKSHELF_TOGGLE()
    ui.ToggleFrame(g.framename)
end
function ANCIENTNMONSTERBOOK_ON_OPEN()
    local frame = g.frame
    local chk = frame:GetChildRecursively("chkmode")
    AUTO_CAST(chk)
    chk:SetCheck(1)
    ANCIENTMONSTERBOOKSHELF_UPDATE()
end
function ANCIENTMONSTERBOOKSHELF_REFRESH_CARDSLOTS(isinv)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename)
            local slotset
            if not isinv then
                local gbox = frame:CreateOrGetControl("groupbox", "gboxcards", 20, 150, 540, 500);
                slotset = gbox:CreateOrGetControl("slotset", "slotcards", 0, 0, 540, 700);
                g.slotsetcards = slotset
            else
                local gbox = frame:CreateOrGetControl("groupbox", "gboxcardsinv", 560, 150, 540, 500);
                slotset = gbox:CreateOrGetControl("slotset", "slotcardsinv", 0, 0, 540, 700);
                g.slotsetinvs = slotset
            end
            AUTO_CAST(slotset)
            slotset:SetSkinName('accountwarehouse_slot')
            slotset:EnableDrag(0)
            slotset:EnableDrop(0)
            slotset:EnableSelection(0)
            slotset:SetSlotSize(g.cardsize[1], g.cardsize[2])
            slotset:SetSpc(3, 3)
            local cards = g.aam.getAllCards(isinv, not isinv, false, true)
            if g.aam.sort then
                
                table.sort(cards, g.aam.sort)
            end
            local columns = 5
            slotset:RemoveAllChild()
            slotset:SetColRow(columns, math.max(1, math.ceil(#cards / columns)))
            slotset:CreateSlots()
            
            slotset:SetUserValue('islockedselectable', 1)
            for i, v in ipairs(cards) do
                local slot = slotset:GetSlotByIndex(i - 1)
                if slot then
                    AUTO_CAST(slot)
                    
                    
                    slot:SetEventScript(ui.MOUSEMOVE, 'ANCIENTMONSTERBOOKSHELF_SLOTSET_ON_MOUSEMOVE')
                    ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot, v, false)
                    slot:Select(0)
                
                end
            end
            
            local gauge = frame:GetChild("progresscardcount")
            AUTO_CAST(gauge)
            gauge:SetStatFont(0, "yellow_14_b")
            local cnt = session.ancient.GetAncientCardCount()
            local max_cnt = GET_ANCIENT_CARD_SLOT_MAX()
            gauge:SetTextStat(0, cnt .. "/" .. max_cnt);
            gauge:SetMaxPoint(max_cnt)
            gauge:SetCurPoint(cnt)
            local txt = frame:CreateOrGetControl("richtext", "labelcardcountnum", 0, 0, 90, 33)
            AUTO_CAST(txt)
            txt:SetGravity(ui.LEFT, ui.BOTTOM)
            txt:SetMargin(140, 0, 0, 60)
            txt:SetText("{ol}{s20}" .. cnt .. "/" .. max_cnt)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot, v, nodesc, notooltip)
    slot:ClearIcon()
    slot:RemoveAllChild()
    local icon = CreateIcon(slot)
    local monCls = GetClass("Monster", v.classname);
    local iconName = TryGetProp(monCls, "Icon");
    slot:EnableDrag(0)
    slot:EnableDrop(0)
    
    slot:SetUserValue('islocked', BoolToNumber(v.islocked))
    if nodesc == nil then
        nodesc = false
    end
    
    local rarity = v.rarity
    --hide
    if rarity == 1 then
        icon:SetImage("normal_card")
    elseif rarity == 2 then
        icon:SetImage("rare_card")
    elseif rarity == 3 then
        icon:SetImage("unique_card")
    elseif rarity == 4 then
        icon:SetImage("legend_card")
    end
    local pic = slot:CreateOrGetControl('picture', 'pic', 0, 0, 44, 44)
    AUTO_CAST(pic)
    pic:SetGravity(ui.CENTER_HORZ, ui.TOP)
    pic:SetMargin(0, 23, 0, 0)
    pic:SetImage(iconName)
    pic:SetEnableStretch(1)
    pic:EnableHitTest(0)
    if nodesc == false then
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
        if v.isinInventory then
            local statetext = slot:CreateOrGetControl('richtext', 'count', 0, 0, 40, 20)
            statetext:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            statetext:SetMargin(0, 0, 0, 0)
            statetext:SetText('{s20}{ol}x' .. v.invItem.count .. "")
            statetext:EnableHitTest(0)
            statetext:SetSkinName("bg")
        end
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
        nametext:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
        nametext:SetMargin(0, 0, 0, 24)
        nametext:SetText(namestr)
        nametext:EnableHitTest(0)
        nametext:SetSkinName('none')
    end
    if not notooltip then
        icon:SetTooltipType("ancient_card")
        icon:SetTooltipStrArg(v.guid)
        icon:SetUserValue("ANCIENT_GUID", v.guid)
    end
end
function ANCIENTMONSTERBOOKSHELF_SLOTSET_ON_MOUSEMOVE(frame, slot)
    local parent = slot:GetParent()
    AUTO_CAST(slot)
    local state = tonumber(parent:GetUserValue("lbtnpressed"))
    if mouse.IsLBtnPressed() == 1 then
        if state == nil then
            if slot:IsSelected() == 1 then
                state = 0
            
            else
                state = 1
            end
            parent:SetUserValue('lbtnpressed', tostring(state))
        end
        if (slot:GetUserIValue('islocked') == 1 and parent:GetUserIValue('islockedselectable') ~= 1) then
            state = 0
        end
        if slot:IsSelected() ~= state then
            slot:Select(state)
            ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS()
        end
    else
        state = nil
        parent:SetUserValue('lbtnpressed', nil)
    end

end
function ANCIENTMONSTERBOOKSHELF_SET_SORT(_, _, _, type)
    
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
                if a.name == b.name then
                    return a.starrank > b.starrank
                end
                
                return a.name < b.name
            
            end
        end
    end
    ANCIENTMONSTERBOOKSHELF_INITFRAME()
end
function ANCIENTMONSTERBOOKSHELF_ON_SORT()
    local context = ui.CreateContextMenu('context_menusort', '', 0, 10, 200, 200)
    ui.AddContextMenuItem(context, 'No Sort', 'ANCIENTMONSTERBOOKSHELF_SET_SORT(nil,nil,nil,nil)')
    ui.AddContextMenuItem(context, 'Sort by Rarity', 'ANCIENTMONSTERBOOKSHELF_SET_SORT(nil,nil,nil,1)')
    ui.AddContextMenuItem(context, 'Sort by Rank', 'ANCIENTMONSTERBOOKSHELF_SET_SORT(nil,nil,nil,2)')
    ui.AddContextMenuItem(context, 'Sort by Level', 'ANCIENTMONSTERBOOKSHELF_SET_SORT(nil,nil,nil,3)')
    ui.AddContextMenuItem(context, 'Sort by Name', 'ANCIENTMONSTERBOOKSHELF_SET_SORT(nil,nil,nil,4)')
    ui.OpenContextMenu(context)
end
function ANCIENTMONSTERBOOKSHELF_EVOLVE(cards)
    if g.working then
        return
    end
    local basecard = cards[1]
    local delay = 0
    local adds = g.aam.getCardsCount(cards, true) + 1
    local cardsforfind = g.aam.getAllCards(true, false, true, false)
    local invcards = {}
    for i = adds, 3 do
        
        local found = false
        for k, v in ipairs(cardsforfind) do
            if v.starrank == basecard.starrank and v.classname == basecard.classname then
                cards[#cards + 1] = deepcopy(v)
                found = true
                invcards[#invcards + 1] = deepcopy(v)
                DBGOUT("OUT")
                table.remove(cardsforfind, k)
                break
            end
        end
        if found == false then
            ERROUT("[AMB]Card not found.")
            return
        end
    end
    
    if GET_ANCIENT_CARD_SLOT_MAX() - session.ancient.GetAncientCardCount() < #invcards then
        ui.SysMsg("[AMB]Insufficient Card Slot.")
        
        return
    end
    for k, v in ipairs(invcards) do
        ReserveScript(string.format("ANCIENT_CARD_REGISTER_C('%s')", v.guid), delay)
        delay = delay + 0.25
    end
    ANCIENTMONSTERBOOKSHELF_SET_WORKING(true)
    g.wkcards = cards
    ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_DO_EVOLVE()"), delay)
    delay = delay + 0.25
    ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_SET_WORKING(false)"), delay)
end
function ANCIENTMONSTERBOOKSHELF_SET_WORKING(wk)
    g.working = wk
    if wk == false then
        ANCIENTMONSTERBOOKSHELF_UPDATE()
        local frame = ui.GetFrame(g.framename)
        local gauge = frame:GetChildRecursively("progresscombine")
        AUTO_CAST(gauge)
        gauge:SetCurPoint(0)
        g.wkcards = nil
        g.wkcombine = nil
        g.wkinit = nil
    else
        ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS()
    end
end
function ANCIENTMONSTERBOOKSHELF_COMBINE(cards)
    if g.working then
        return
    end
    g.wkcards = cards
    ui.MsgBox('Do you want to combine?', string.format('ANCIENTMONSTERBOOKSHELF_DO_COMBINE()'), 'None')

end
function ANCIENTMONSTERBOOKSHELF_DO_COMBINE()
    g.wkinit = g.aam.getCardsCount(g.aam.getSelectedCards(false))
    ANCIENTMONSTERBOOKSHELF_SET_WORKING(true)
    ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_NEXT()

end
function ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_NEXT(reusecard)
    EBI_try_catch{
        try = function()
            local cards = g.wkcards
            
            local classnamelist = {}
            for k, v in ipairs(cards) do
                if not classnamelist[v.classname] then
                    classnamelist[v.classname] = v.count
                else
                    classnamelist[v.classname] = classnamelist[v.classname] + v.count
                end
            end
            -- reformat
            local list = {}
            for k, v in pairs(classnamelist) do
                list[#list + 1] = {classname = k, count = v}
            end
            
            --多い順から3つピックアップ
            local first = nil
            local same = true
            local cursor = 1
            local pick = {}
            local cd = 1
            
            --再利用
            if reusecard then
                DBGOUT("REUSE" .. reusecard.classname .. reusecard.count .. "/" .. reusecard.guid)
                pick[#pick + 1] = reusecard
                cd = 2
                first = reusecard
            end
            local wkcards = deepcopy(g.wkcards)
            local i
            for i = cd, 3 do
                --多い順にソート
                table.sort(list, function(a, b) return a.count > b.count end)
                
                local brk = false
                for k, v in ipairs(list) do
                    local pass = false
                    if v.count > 0 then
                        if i == 1 then
                            first = v
                        
                        end
                        
                        for kk, vv in ipairs(wkcards) do
                            if i == 1 then
                                else
                                if v.classname == first.classname then
                                    if i == 3 and same == true then
                                        --continue
                                        pass = true
                                    end
                                else
                                    same = false
                                end
                            end
                            
                            if not pass then
                                
                                if vv.classname == v.classname then
                                    pick[#pick + 1] = deepcopy(vv)
                                    DBGOUT("" .. i .. vv.classname .. v.count .. tostring(vv.isinInventory)..'/' .. vv.guid)
                                    table.remove(wkcards, kk)
                                    list[k].count = list[k].count - 1
                                    brk = true
                                    break
                                end
                            
                            end
                        end
                        if brk then
                            break
                        end
                    
                    end
                end
            end
            if #pick < 3 then
                ui.SysMsg("[AMB]Complete.")
                ANCIENTMONSTERBOOKSHELF_SET_WORKING(false)
                return
            end
            local invCardCount = 0
            for _, v in ipairs(pick) do
                if v.isinInventory then
                    invCardCount = invCardCount + 1
                end
            end
            if GET_ANCIENT_CARD_SLOT_MAX() - session.ancient.GetAncientCardCount() < invCardCount then
                ui.SysMsg("[AMB]Insufficient Card Slot.")
                ANCIENTMONSTERBOOKSHELF_SET_WORKING(false)
                return
            end
            g.wkreuse = reusecard
            g.wkcards_before = g.wkcards
            g.wkcards = wkcards
            local delay = 0.2
            g.wkcombine = pick
            --インベントリにあるなら引き出す
            for k, v in ipairs(pick) do
                if v.isinInventory then
                    ReserveScript(string.format("ANCIENT_CARD_REGISTER_C('%s')", v.guid), delay)
                    delay = delay + 0.25
                end
            end
            delay = delay + 0.8
            ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_DO()"), delay)
            delay = delay + 0.25
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_DO()
    EBI_try_catch{
        try = function()
            if g.wkcombine==nil then
                return
            end
            --Watchdog
            local frame = ui.GetFrame(g.framename)
    

            for k, v in ipairs(g.wkcombine) do
                if not g.aam.getCardByGuid(v.guid) then
                    --retry
                    DBGOUT("retrying...")
                    g.wkcards = g.wkcards_before
                    
                    frame:StopUpdateScript("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_WATCHDOG", 1);
                    ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_PREPARE_NEXT('%s')", g.wkreuse), 0.5)
                    return
                end
            end
            
     
            local cards = g.aam.convertInvCardToBookCard(g.wkcombine, true)
            if #cards <3 then
                DBGOUT("insufficient cards retrying...")
                g.wkcards = g.wkcards_before
                
                frame:StopUpdateScript("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_WATCHDOG", 1);
                ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_PREPARE_NEXT('%s')", g.wkreuse), 0.5)
                return
            end
            
            frame:RunUpdateScript("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_WATCHDOG", 1);
            imcSound.PlaySoundEvent("market_sell");
            ReqCombineAncientCard(cards[1].guid, cards[2].guid, cards[3].guid)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_WATCHDOG()
    local frame = ui.GetFrame(g.framename)
    
    frame:StopUpdateScript("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_WATCHDOG", 1);
    DBGOUT("retrying...")
    g.wkcards = g.wkcards_before
    ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_PREPARE_NEXT('%s')", g.wkreuse), 0.5)

end
function ANCIENTMONSTERBOOKSHELF_DO_EVOLVE()
    imcSound.PlaySoundEvent("market_sell");
    local cards = g.aam.convertInvCardToBookCard(g.wkcards, true)
    ReqEvolveAncientCard(cards[1].guid, cards[2].guid, cards[3].guid)
end
function ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_PREPARE_NEXT(guid)
    EBI_try_catch{
        try = function()
            if not  g.wkcombine then
                return
            end
            local getcards=g.aam.getCardByGuid(guid)
            if #getcards == 0 then
                DBGOUT("retrying")
                ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_PREPARE_NEXT('%s')", guid), 0.5)
                
                return
            end
            local card =getcards[1]
            
            local frame = ui.GetFrame(g.framename)
            
            if card and card.rarity == g.wkcombine[1].rarity and card.rarity < 4 then
                
            else
                card = nil
            end
            
            ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_NEXT(card)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ANCIENTMONSTERBOOKSHELF_ON_ANCIENT_CARD_UPDATE(frame, msg, guid, slot)
    EBI_try_catch{
        try = function()
            
            if g.working then
                
                if msg == "ANCIENT_CARD_COMBINE" and g.wkcombine then
                    DBGOUT('combined')
                    ANCIENTMONSTERBOOKSHELF_UPDATE()
                    local getcards = g.aam.getCardByGuid(guid)
                    
                    local frame = ui.GetFrame(g.framename)
                    
                    frame:StopUpdateScript("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_WATCHDOG", 1);
                    
                    local gauge = frame:GetChildRecursively("progresscombine")
                    AUTO_CAST(gauge)
                    gauge:SetCurPoint(g.wkinit - #g.wkcards)
                    gauge:SetMaxPoint(g.wkinit)
                    local slot = frame:GetChildRecursively("slotcombine1")
                    AUTO_CAST(slot)
                    ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot, g.wkcombine[1], false, true)
                    local slot = frame:GetChildRecursively("slotcombine2")
                    AUTO_CAST(slot)
                    ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot, g.wkcombine[2], false, true)
                    local slot = frame:GetChildRecursively("slotcombine3")
                    AUTO_CAST(slot)
                    ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot, g.wkcombine[3], false, true)
                    local slot = frame:GetChildRecursively("slotcombineproduct")
                    AUTO_CAST(slot)
                    if #getcards > 0 then
                        ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot,getcards[1], false, true)
                    end
                    ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_COMBINEPROCESS_PREPARE_NEXT('%s')", guid), 0.5)
                
                end
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ANCIENTMONSTERBOOKSHELF_ON_CANCEL()
    ANCIENTMONSTERBOOKSHELF_SET_WORKING(false)
end
