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
        getSelectedSlotsAsCard = function(slotset)
            
            local aamcards = {}
            local ref = g.aam.getAllCards(nil,nil,nil,true)
            for i = 0, slotset:GetSlotCount() - 1 do
                local slot = slotset:GetSlotByIndex(i)
                local icon = slot:GetIcon()
                if icon and slot:IsSelected() == 1 then
                    local guid = icon:GetUserValue("ANCIENT_GUID")
                    if guid then
                        for _, v in ipairs(ref) do
                            if v.guid == guid then
                                aamcards[#aamcards + 1] = v
                                break
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
        getCardByGuid = function(guid)
            
            
            local card
            local cards = g.aam.getAllCards()
            for k, v in ipairs(cards) do
                if v.guid == guid then
                    
                    card = v
                    break
                end
            end
            if card == nil then
                
                return nil
            end
            local classname = card:GetClassName()
            local ancientCls = GetClass("Ancient_Info", classname)
            local exp = card:GetStrExp();
            local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
            local level = xpInfo.level
            local cards = {}
            cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp,
                isinSlot = false, isinInventory = false, name = ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level}
            
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
                            cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp,
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
                            cards[#cards + 1] = {card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp,
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
                                    level = 1,
                                    starrank = 1,
                                    rarity = ancientCls.Rarity,
                                    slot = 0,
                                }, cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = invItem,exp=0,
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
                                        level = 1,
                                        starrank = 1,
                                        rarity = ancientCls.Rarity,
                                        slot = 0,
                                    }, cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = invItem,exp=0,
                                    isinSlot = false, isinInventory = true, name = ancientCls.Name, islocked = invItem.isLockState, classname = classname, starrank = 1, lv = 1}
                                end
                            end
                        
                        end
                    end
                
                end, false)
            end
            return cards
        end
        ,actions={
            {text="Deselect All",action=function(cards)
                for i=0,g.slotsetcards:GetSlotCount()-1 do
                    local slot=g.slotsetcards:GetSlotByIndex(i)    
                    slot:Select(0)
                end
                for i=0,g.slotsetinvs:GetSlotCount()-1 do
                    local slot=g.slotsetinvs:GetSlotByIndex(i)    
                    slot:Select(0)
                end
            end,state=function()return true end},
            {text="Lock",action=function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards,true)end,state=function()return true end},
            {text="Unlock",action=function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards,false)end,state=function()return true end},
            {text="Insert",action=function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards,false)end,state=function()return g.aam.isSafety() end},
         
            {text="{#00FFFF}Auto Combine",action=function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards,false)end,state=function()return g.aam.isSafety() end},
            {text="{#FF0000}Delete",action=function(cards)ANCIENTMONSTERBOOKSHELF_LOCK(cards,false)end,state=function()return g.aam.isSafety() end},
           
        },
        isSafety=function()
            local frame=g.frame
            local chk=frame:GetChildRecursively("chkmode")
            AUTO_CAST(chk)
            return chk:IsChecked()==0
        end
}
g.configurepattern = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'ancientmonsterbookshelf'
g.debug = false
g.cardsize = {100, 140}
g.addon = g.addon
g.slotsetcards=g.slotsetcards
g.slotsetinvs=g.slotsetinvs
g.working=false
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
            chk:SetEventScript(ui.LBUTTONUP,"ANCIENTMONSTERBOOKSHELF_UPDATE_ACTIONS")
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
            local gbox = frame:CreateOrGetControl("groupbox", "gboxwk", 0, 0, 800, 120)
            AUTO_CAST(gbox)
            gbox:SetGravity(ui.RIGHT, ui.BOTTOM)
            gbox:SetMargin(0, 0, 20, 10)
            gbox:SetSkinName("bg2")
            local txt = frame:CreateOrGetControl("richtext", "txtprogress", 0, 0, 66, 140)
            AUTO_CAST(txt)
            txt:SetGravity(ui.RIGHT, ui.BOTTOM)
            txt:SetMargin(0,0, 736, 130)
            txt:SetText("{ol}Workbench")
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
    local frame = ui.GetFrame(g.framename)
    local gbox = frame:CreateOrGetControl("groupbox","gboxaction",0,0,150,frame:GetHeight()-200)
    gbox:SetGravity(ui.RIGHT,ui.TOP)
    gbox:SetMargin(0,150,20,0)
    for k,v in ipairs(g.aam.actions) do
        local btn=gbox:CreateOrGetControl("button",'btn'..k,0,32*(k-1),150,30)
        btn:SetText(v.text)
        btn:SetEventScript(ui.LBUTTONUP,"ANCIENTMONSTERBOOKSHELF_DO_ACTION")
        btn:SetEventScriptArgNumber(ui.LBUTTONUP,k)
        if v.state then
            
            if v.state() then
                btn:SetEnable(1) 
                
            else
                btn:SetEnable(0)
            end
        else
            btn:SetEnable(0)
        end
    end

end
function ANCIENTMONSTERBOOKSHELF_DO_ACTION(frame,ctrl,argstr,argnum)
    EBI_try_catch{
        try = function()
            frame=g.frame
        local cards=g.aam.getSelectedSlotsAsCard(AUTO_CAST(frame:GetChildRecursively("slotcards")))
        local cardsinv=g.aam.getSelectedSlotsAsCard(AUTO_CAST(frame:GetChildRecursively("slotcardsinv")))
        for k,v in ipairs(cardsinv) do
            
            cards[#cards+1] = v
        end
        g.aam.actions[argnum].action(cards)

        
    end,
    catch = function(error)
        ERROUT(error)
    end
    }
end
function ANCIENTMONSTERBOOKSHELF_LOCK(aamcards,lock)
    local delay=0
    for _,v in ipairs( aamcards) do
        
        if v.isinInventory then
            if v.islocked ~= lock then
              
                ReserveScript(string.format("session.inventory.SendLockItem('%s', %d)",v.guid,BoolToNumber(lock)),delay)
                delay=delay+0.1
            end
        else
            if v.islocked ~= lock then
                print(v.guid)
                ReserveScript(string.format("ReqLockAncientCard('%s')",v.guid),delay)
                delay=delay+0.1
            end
        end
    end
    ReserveScript(string.format("ANCIENTMONSTERBOOKSHELF_UPDATE()"),delay)
    delay=delay+0.1
    return delay
end
function ANCIENTMONSTERBOOKSHELF_TOGGLE()
    ui.ToggleFrame(g.framename)
end
function ANCIENTNMONSTERBOOK_ON_OPEN()
    local frame=g.frame
    local chk=frame:GetChildRecursively("chkmode")
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
                local gbox = frame:CreateOrGetControl("groupbox", "gboxcards", 20, 150, 540, 600);
                slotset = gbox:CreateOrGetControl("slotset", "slotcards", 0, 0, 540, 800);
                g.slotsetcards=slotset
            else
                local gbox = frame:CreateOrGetControl("groupbox", "gboxcardsinv", 560, 150, 540, 600);
                slotset = gbox:CreateOrGetControl("slotset", "slotcardsinv", 0, 0, 540, 800);
                g.slotsetinvs=slotset
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
                    -- if selectedindices then
                    --     if selectedindices[i] then
                    --         slot:Select(1)
                    --     else
                    --         slot:Select(0)
                    --     end
                    -- else
                    slot:Select(0)
                --end
                end
            end

            local gauge = frame:GetChild("progresscardcount")
            AUTO_CAST(gauge)
            gauge:SetStatFont(0, "yellow_14_b")
            local cnt = session.ancient.GetAncientCardCount()
	        local max_cnt = GET_ANCIENT_CARD_SLOT_MAX()
            gauge:SetTextStat(0, cnt.."/"..max_cnt);
            gauge:SetMaxPoint(max_cnt)
            gauge:SetCurPoint(cnt)
            local txt = frame:CreateOrGetControl("richtext", "labelcardcountnum", 0, 0, 90, 33)
            AUTO_CAST(txt)
            txt:SetGravity(ui.LEFT, ui.BOTTOM)
            txt:SetMargin(140, 0, 0, 60)
            txt:SetText("{ol}{s20}"..cnt.."/"..max_cnt)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function ANCIENTMONSTERBOOKSHELF_SET_SLOT(slot, v, nodesc)
    local icon = CreateIcon(slot)
    local monCls = GetClass("Monster", v.classname);
    local iconName = TryGetProp(monCls, "Icon");
    
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
    local pic=slot:CreateOrGetControl('picture','pic',0,0,44,44)
    AUTO_CAST(pic)
    pic:SetGravity(ui.CENTER_HORZ,ui.TOP)
    pic:SetMargin(0,23,0,0)
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
    icon:SetTooltipType("ancient_card")
    icon:SetTooltipStrArg(v.guid)
    icon:SetUserValue("ANCIENT_GUID", v.guid)
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
        slot:Select(state)
    
    else
        state = nil
        parent:SetUserValue('lbtnpressed', nil)
    end

end
function ADVANCEDASSISTERMANAGER_SET_SORT(_, _, _, type)
    
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
    ui.AddContextMenuItem(context, 'No Sort', 'ADVANCEDASSISTERMANAGER_SET_SORT(nil,nil,nil,nil)')
    ui.AddContextMenuItem(context, 'Sort by Rarity', 'ADVANCEDASSISTERMANAGER_SET_SORT(nil,nil,nil,1)')
    ui.AddContextMenuItem(context, 'Sort by Rank', 'ADVANCEDASSISTERMANAGER_SET_SORT(nil,nil,nil,2)')
    ui.AddContextMenuItem(context, 'Sort by Level', 'ADVANCEDASSISTERMANAGER_SET_SORT(nil,nil,nil,3)')
    ui.AddContextMenuItem(context, 'Sort by Name', 'ADVANCEDASSISTERMANAGER_SET_SORT(nil,nil,nil,4)')
    ui.OpenContextMenu(context)
end
