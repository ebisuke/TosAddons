--uie_inventory

local acutil = require('acutil')
local framename = 'uie_inventory'
--ライブラリ読み込み
local debug = false
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
    EBI_try_catch {
        try = function()
            if (debug == true) then
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end

UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

g.inv = {
    filters = {
        --{name = "Fav", text = "★", tooltip = "Favorites", imagename = "uie_favorites", original = nil},
        {name = 'All', text = 'All', tooltip = 'All', imagename = 'uie_all', original = 'All'},
        {name = 'Equ', text = 'Equ', tooltip = 'Equip', imagename = 'uie_equip', original = 'Equip'},
        {name = 'Spl', text = 'Spl', tooltip = 'Consume Item', imagename = 'uie_consume', original = 'Consume'},
        {name = 'Rcp', text = 'Rcp', tooltip = 'Recipe', imagename = 'uie_recipe', original = 'Recipe'},
        {name = 'Crd', text = 'Crd', tooltip = 'Card', imagename = 'uie_card', original = 'Card'},
        {name = 'Etc', text = 'Etc', tooltip = 'Etc', imagename = 'uie_etc', original = 'Etc'},
        {name = 'Ing', text = 'Ing', tooltip = 'Material', imagename = 'uie_ingredients', original = nil},
        {name = 'Que', text = 'Que', tooltip = 'Quest Item', imagename = 'uie_quest', original = nil},
        {name = 'Gem', text = 'Gem', tooltip = 'Gem', imagename = 'uie_gem', original = 'Gem'},
        {name = 'Prm', text = 'Prm', tooltip = 'Premium', imagename = 'uie_premium', original = 'Premium'},
        {name = 'Lim', text = 'Lim', tooltip = 'Time Limited', imagename = 'uie_timelimited', original = nil},
        {name = 'Fnd', text = 'Fnd', tooltip = 'Find', imagename = 'uie_find', original = nil}
    },
    uieInventoryBase = {
        new = function(base, enabletooltip)
            local self = {}
            setmetatable(self, {__index = g.inv.uieInventoryBase})
            self.base = base
            self.itemcount = 0
            self.enabletooltip = enabletooltip
            self:initialize()
            return self
        end,
        initialize = function(self)
            local base = self.base
            base:RemoveAllChild()
            base:SetSkinName('test_frame_low')

            local gboxtab = base:CreateOrGetControl('groupbox', 'gboxtab', 0, 0, 0, 0)

            AUTO_CAST(gboxtab)
            gboxtab:SetMargin(0, 0, 0, 0)
            local tab = gboxtab:CreateOrGetControl('tab', 'tab', 0, 0, 0, 0)
            gboxtab:SetOffset(20, 5)
            gboxtab:Resize(base:GetWidth() - 30, base:GetHeight() - 100)
            tab:SetMargin(0, 0, 0, 0)
            tab:SetSkinName('tab2')
            AUTO_CAST(tab)
            for k, v in ipairs(g.inv.filters) do
                tab:AddItem('{img ' .. v.imagename .. ' 20 20}', v.name)
            end
            tab:SetItemsFixWidth(38)
            tab:SetOffset(0, 0)
            tab:Resize(gboxtab:GetWidth(), gboxtab:GetHeight())
            local gbox = base:CreateOrGetControl('groupbox', 'gbox', 0, 0, 0, 0)

            AUTO_CAST(gbox)
            gbox:SetMargin(0, 0, 0, 0)
            gbox:SetOffset(20, 35)
            gbox:Resize(base:GetWidth() - 20, base:GetHeight() - 180)
            local slotset = gbox:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
            AUTO_CAST(slotset)
            slotset:SetOffset(0, 0)
            slotset:Resize(gbox:GetWidth() - 20, gbox:GetHeight())

            self:resize()
            self:generateList()
        end,
        generateList = function(self)
            local base = self.base
            local iframe = ui.GetFrame('inventory')
            local slotset = base:GetChildRecursively('slotset')
            local gbox = base:GetChild('gbox')
            AUTO_CAST(gbox)
            gbox:InvalidateScrollBar()
            gbox:SetScrollBar(0)
            self:generateListImpl(slotset)
        end,
        generateListImpl = function(self, slotset)
            --nothing to do
        end,
        resize = function(self)
            local base = self.base
            --tab
            local gboxtab = base:GetChild('gboxtab')
            AUTO_CAST(gboxtab)
            gboxtab:SetOffset(20, 70)
            gboxtab:Resize(base:GetWidth() - 30, base:GetHeight() - 100)
            local tab = gboxtab:GetChild('tab')
            tab:SetOffset(5, 5)
            tab:Resize(gboxtab:GetWidth(), gboxtab:GetHeight())

            local gbox = base:GetChild('gbox')
            AUTO_CAST(gbox)
            local gboxtooltip = base:GetChild('gboxtooltip')

            if gboxtooltip then
                AUTO_CAST(gboxtooltip)
                gbox:SetOffset(20, 120)
                gbox:Resize(base:GetWidth() - 20, base:GetHeight() - 480)
                gboxtooltip:SetOffset(20,  base:GetHeight() - 470)
                gboxtooltip:Resize(base:GetWidth() - 30, 450)
            else
                gbox:SetOffset(20, 120)
                gbox:Resize(base:GetWidth() - 20, base:GetHeight() - 180)
            end
            local slotset = gbox:GetChild('slotset')
            slotset:SetOffset(5,5)
            slotset:Resize(gbox:GetWidth()-10, gbox:GetHeight()-10)
        end,
        showToolTip = function(self, invItem)
            if not self.enabletooltip then
                return
            end
            local base = self.base


            local obj = GetIES(invItem:GetObject())

            local noTradeCnt = TryGetProp(obj, 'BelongingCount')
            local itemFrame = ui.GetFrame("wholeitem");
            
            if not itemFrame then
                 itemFrame = ui.GetNewToolTip("wholeitem", "wholeitem");
            end
            UPDATE_ITEM_TOOLTIP(itemFrame, '', 0, 0, nil, obj, noTradeCnt)
            itemFrame:RefreshTooltip();
            itemFrame:ShowWindow(1);
            itemFrame:SetOffset(0,0)
            ui.ToCenter(itemFrame);
        end,
        hideToolTip=function(self)
            local itemFrame = ui.GetFrame("wholeitem");
            
            if not itemFrame then
                return
            end
            itemFrame:ShowWindow(0)
        end
    },
    uieInventory = {
        new = function(base, enabletooltip)
            local self = inherit(g.inv.uieInventory, g.inv.uieInventoryBase, base, enabletooltip)

            self:initialize()
            return self
        end,
        generateListImpl = function(self,slotset)
            local base = self.base
            local iframe = ui.GetFrame('inventory')
            local slotset = base:GetChildRecursively('slotset')

            AUTO_CAST(slotset)
            slotset:RemoveAllChild()
            session.BuildInvItemSortedList()
            local tab = base:GetChildRecursively('tab')
            local tabidx = tab:GetSelectItemIndex() + 1
            AUTO_CAST(tab)
            local sortedList = session.GetInvItemSortedList()
            local invItemCount = sortedList:size()
            slotset:SetColRow(2, math.ceil(invItemCount / 2))
            slotset:SetSpc(0, 0)
            local slotsize = 48
            local slotwidth = slotset:GetWidth() / 2
            slotset:SetSlotSize(slotwidth, slotsize)
            slotset:EnableDrag(1)
            slotset:EnableDrop(1)
            slotset:EnablePop(1)
            --slotset:SetSkinName('slot')
            slotset:CreateSlots()

            local slotidx = 0
            for i = 0, invItemCount - 1 do
                local invItem = sortedList:at(i)
                if invItem ~= nil and UIE_INVENTORY_FILTER(invItem, g.inv.filters[tabidx].name) then
                    local itemCls = GetIES(invItem:GetObject())
                    if itemCls ~= nil then
                        local parentslot = slotset:GetSlotByIndex(slotidx)
                        AUTO_CAST(parentslot)
                        slotidx = slotidx + 1
                        local customFunc = nil
                        local scriptName = iframe:GetUserValue('CUSTOM_ICON_SCP')
                        local scriptArg = nil
                        if scriptName ~= nil then
                            customFunc = _G[scriptName]
                            local getArgFunc = _G[iframe:GetUserValue('CUSTOM_ICON_ARG_SCP')]
                            if getArgFunc ~= nil then
                                scriptArg = getArgFunc()
                            end
                        end
                        --parentslot:Resize(slotwidth / 2, slotsize)
                        local childslot = parentslot:CreateOrGetControl('slot', 'childslot', 0, 0, slotsize, slotsize)
                        AUTO_CAST(childslot)

                        local icon = CreateIcon(parentslot)
                        local itemobj = GetIES(invItem:GetObject())
                        local imageName = GET_EQUIP_ITEM_IMAGE_NAME(itemobj, 'Icon')
                        local iconImgName = GET_ITEM_ICON_IMAGE(itemobj)
                        local itemType = invItem.type
                        icon:Set('uie_transparent', 'Item', itemType, invItem.invIndex, invItem:GetIESID(), invItem.count)
                        icon:Resize(0, 0)
                        parentslot:EnableDrag(0)
                        parentslot:EnableDrop(0)
                        parentslot:EnablePop(0)
                        parentslot:SetColorTone('FFFFFFFF')

                        INV_SLOT_UPDATE(ui.GetFrame('inventory'), invItem, childslot)

                        --if ui.GetFrame("oblation_sell"):IsVisible() == 1 then
                        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(childslot, invItem, itemCls, invItem.count, '{s14}{ol}{#FFFFFF}')
                        local text = parentslot:CreateOrGetControl('richtext', 'text', slotsize + 10, 5, slotwidth - slotsize - 10, slotsize - 10)
                        -- text:SetGravity(ui.LEFT, ui.CENTER_VERT)
                        text:SetText('{s14}{ol}' .. itemCls.Name)
                    end
                end
            end
            self.itemcount = slotidx
            --ui.InventoryHideEmptySlotBySlotSet(slotset)
        end
    },
    registerInventory = function(inv)
        g.inv.inventories[#g.inv.inventories + 1] = inv
    end,
    getUIEInventoryByFrameName = function(name)
        for _, v in ipairs(g.inv.inventories) do
            local frame = v.base:GetTopParentFrame()
            if frame:GetName() == name then
                return v
            end
        end
        return nil
    end,
    inventories = {}
}
g.inv.filterbyname = {}
for _, v in ipairs(g.inv.filters) do
    g.inv.filterbyname[v.name] = v
end
UIMODEEXPERT = g

--マップ読み込み時処理（1度だけ）
function UIE_INVENTORY_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(framename)
            --frame:ShowWindow(0)
            addon:RegisterMsg('GAME_START', 'UIE_INVENTORY_GAME_START')
            local gbox = frame:CreateOrGetControl('groupbox', 'inventory', 5, 70, frame:GetWidth() - 10, frame:GetHeight() - 120)
            AUTO_CAST(gbox)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_INVENTORY_UPDATE_TOOLTIP(tooltipframe, strarg, numarg1, numarg2, userdata, tooltipobj, noTradeCnt)
    AUTO_CAST(tooltipframe)

    local itemObj, isReadObj = nil
    if tooltipobj ~= nil then
        itemObj = tooltipobj
        isReadObj = 0
    else
        itemObj, isReadObj = GET_TOOLTIP_ITEM_OBJECT(strarg, numarg2, numarg1)
    end

    if itemObj == nil then
        return
    end

    if nil ~= itemObj and itemObj.GroupName == 'Unused' then
        tooltipframe:Resize(1, 1)
        return
    end

    local isForgeryItem = false
    if strarg == 'forgery' then
        isForgeryItem = true
    elseif string.find(strarg, 'pcbang_rental') ~= nil and itemObj ~= nil then
        local strList = StringSplit(strarg, '#')
        itemObj.Reinforce_2 = strList[2]
        itemObj.Transcend = strList[3]
    end
    tooltipframe:SetUserValue('TOOLTIP_ITEM_GUID', numarg2)

    local recipeitemobj = nil

    local recipeid = IS_RECIPE_ITEM(itemObj)
    -- 레시피 아이템 쪽

    if recipeid ~= 0 then
        local recipeIES = CreateIESByID('Item', recipeid)

        if recipeIES ~= nil then
            recipeitemobj = recipeIES
            local refreshScp = recipeitemobj.RefreshScp

            if refreshScp ~= 'None' then
                refreshScp = _G[refreshScp]
                refreshScp(recipeitemobj)
            end
        end
    end

    --Main Info
    tooltipframe:Resize(tooltipframe:GetOriginalWidth(), tooltipframe:GetOriginalHeight())
    --tooltipframe:CheckSize()
    INIT_ITEMTOOLTIPFRAME_CHILDS(tooltipframe)

    if isReadObj == 0 then
        if 1 == IS_DRAG_RECIPE_ITEM(itemObj) then
            local tabTxt = ''
            tabTxt, numarg1 = GET_DRAG_RECIPE_INFO(itemObj)
            isReadObj = 1

            local tabCtrl = GET_CHILD(tooltipframe, 'tabText', 'ui::CTabControl')
            tabCtrl:ChangeCaption(0, tabText)
            tabCtrl:ShowWindow(1)
        end
    end

    local recipeclass = recipeitemobj

    -- 컬렉션에서 툴팁을 띄울때는 제작서는 제작서만 보여준다.
    if recipeclass ~= nil and strarg ~= 'collection' then
        local ToolTipScp = _G['ITEM_TOOLTIP_' .. recipeclass.ToolTipScp]
        ToolTipScp(tooltipframe, recipeclass, strarg, 'usesubframe_recipe')
        DestroyIES(recipeitemobj)
    end

    if itemObj == nil then
        return
    end

    local needAppraisal = TryGetProp(itemObj, 'NeedAppraisal')
    local needRandomOption = TryGetProp(itemObj, 'NeedRandomOption')
    local drawCompare = true
    local showAppraisalPic = false
    if needAppraisal ~= nil or needRandomOption ~= nil then
        if needAppraisal == 1 or needRandomOption == 1 then
            DRAW_APPRAISAL_PICTURE(tooltipframe)
            drawCompare = false
            showAppraisalPic = true
        end
    end
    -- 비교툴팁
    -- 툴팁 비교는 무기와 장비에만 해당된다. (미감정 제외)

    if
        drawCompare == true and
            ((itemObj.ToolTipScp == 'WEAPON' or itemObj.ToolTipScp == 'ARMOR') and (strarg == 'inven' or strarg == 'sell' or strarg == 'guildwarehouse' or isForgeryItem == true) and
                (string.find(itemObj.GroupName, 'Pet') == nil))
     then
        local CompItemToolTipScp = _G['ITEM_TOOLTIP_' .. itemObj.ToolTipScp]
        local ChangeValueToolTipScp = _G['ITEM_TOOLTIP_' .. itemObj.ToolTipScp .. '_CHANGEVALUE']
        -- 한손 무기 / 방패 일 경우

        local isVisble = nil

        if itemObj.EqpType == 'SH' then
            -- 양손 무기 일 경우
            if itemObj.DefaultEqpSlot == 'RH' or itemObj.DefaultEqpSlot == 'RH LH' then
                local item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RH'))
                if nil ~= item then
                    local equipItem = GetIES(item:GetObject())

                    local classtype = TryGetProp(equipItem, 'ClassType') -- 코스튬은 안뜨도록

                    if IS_NO_EQUIPITEM(equipItem) == 0 and classtype ~= 'Outer' then
                        CompItemToolTipScp(tooltipframe, equipItem, strarg, 'usesubframe')
                        isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg)
                    end
                end
            elseif itemObj.DefaultEqpSlot == 'LH' then
                local item = session.GetEquipItemBySpot(item.GetEquipSpotNum('LH'))
                if nil ~= item then
                    local equipItem = GetIES(item:GetObject())

                    if IS_NO_EQUIPITEM(equipItem) == 0 then
                        CompItemToolTipScp(tooltipframe, equipItem, strarg, 'usesubframe')
                        isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg)
                    end
                end
            end
        elseif itemObj.EqpType == 'DH' then
            local item = session.GetEquipItemBySpot(item.GetEquipSpotNum('RH'))
            if nil ~= item then
                local equipItem = GetIES(item:GetObject())

                if IS_NO_EQUIPITEM(equipItem) == 0 then
                    CompItemToolTipScp(tooltipframe, equipItem, strarg, 'usesubframe')
                    isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg)
                end
            end
        else
            local equiptype = itemObj.EqpType

            if equiptype == 'RING' then
                if keyboard.IsKeyPressed('LALT') == 1 then
                    equiptype = 'RING2'
                else
                    equiptype = 'RING1'
                end
            end

            local equitSpot = item.GetEquipSpotNum(equiptype)
            local item = session.GetEquipItemBySpot(equitSpot)
            if item ~= nil then
                local equipItem = GetIES(item:GetObject())

                if IS_NO_EQUIPITEM(equipItem) == 0 then
                    CompItemToolTipScp(tooltipframe, equipItem, strarg, 'usesubframe')
                    isVisble = ChangeValueToolTipScp(tooltipframe, itemObj, equipItem, strarg)
                end
            end
        end
    end

    -- 메인 프레임. 즉 주된 툴팁 표시.
    if isReadObj == 1 then -- IES가 없는 아이템. 가령 제작서의 완성 아이템 표시 등
        local class = itemObj
        if class ~= nil then
            local ToolTipScp = _G['ITEM_TOOLTIP_' .. class.ToolTipScp]
            ToolTipScp(tooltipframe, class, strarg, 'mainframe', isForgeryItem)
        end
    else
        local ToolTipScp = _G['ITEM_TOOLTIP_' .. itemObj.ToolTipScp]
        if nil == noTradeCnt then
            noTradeCnt = 0
        end
        SetExProp_Str(itemObj, 'where', strarg) -- scp 호출전에 ex prop 설정.
        ToolTipScp(tooltipframe, itemObj, strarg, 'mainframe', noTradeCnt)
    end

    if isReadObj == 1 then
        DestroyIES(itemObj)
    end

    ITEMTOOLTIPFRAME_ARRANGE_CHILDS(tooltipframe, showAppraisalPic)
    ITEMTOOLTIPFRAME_RESIZE(tooltipframe)
end

function UIE_INVENTORY_FILTER(invItem, filtername)
    return EBI_try_catch {
        try = function()
            local filter = filtername or 'All'
            if (filter == 'All') then
                return true
            end
            if (filter == 'Lim') then
                --時間制限付きか判定
                if (invItem.hasLifeTime == true) then
                    return true
                else
                    return false
                end
            end
            if (filter == 'Ing') then
                --材料か
                local itemObj = GetIES(invItem:GetObject())
                if (itemObj.GroupName == 'Material') then
                    return true
                else
                    return false
                end
            end
            if (filter == 'Que') then
                --クエストアイテムか
                local itemObj = GetIES(invItem:GetObject())
                if (itemObj.GroupName == 'Quest') then
                    return true
                else
                    return false
                end
            end
            if (filter == 'Fnd') then
                --検索
                local findstr = g.inv.findstr or '.*'
                local itemCls = GetIES(invItem:GetObject())
                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name))
                if (itemname:find(findstr)) then
                    return true
                else
                    return false
                end
            end
            --オリジナルソート
            local filterdata = g.inv.filterbyname[filter]
            if (filterdata.original) then
                local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

                local titleName = baseidcls.ClassName
                if baseidcls.MergedTreeTitle ~= 'NO' then
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
function UIE_INVENTORY_GAME_START()
    EBI_try_catch {
        try = function()
            g.inv.inventories = {}

            --register default window
            local frame = ui.GetFrame(framename)
            local gbox = frame:CreateOrGetControl('groupbox', 'inventory', 5, 100, frame:GetWidth() - 10, frame:GetHeight() - 120)
            AUTO_CAST(gbox)
            g.inv.registerInventory(g.inv.uieInventory.new(gbox, true))
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_INVENTORY_CLOSE(frame)
    -- for k, v in ipairs(g.inv.inventories) do
    --     if v.frame == frame then
    --         g.inv.inventories[k]=nil
    --         break
    --     end
    -- end
    frame:ShowWindow(0)
end
function UIE_INVENTORY_OPEN(frame)
    EBI_try_catch {
        try = function()
            --frame:SetMargin(0,0,0,0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_INVENTORY_REINIT()
    EBI_try_catch {
        try = function()
            for _, v in ipairs(g.inv.inventories) do
                v:initialize()
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
