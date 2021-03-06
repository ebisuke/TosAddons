--uie_util
--アドオン名（大文字）
local addonName = 'uimodeexpert'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
local acutil = require('acutil')
local debug = true
--ライブラリ読み込み

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
g.util = g.util or {}
g.util.map = {
    ['ui::CButton'] = 'button',
    ['ui::CRichText'] = 'richtext',
    ['ui::CPicture'] = 'picture',
    ['ui::CGroupBox'] = 'groupbox',
    ['ui::CCheckBox'] = 'checkbox',
    ['ui::CTabControl'] = 'tab',
    ['ui::CSlot'] = 'slot',
    ['ui::CIcon'] = 'icon',
    ['ui::CDropList'] = 'droplist'
}
g.util._delayedCallbackStack={}
g.util.delayedCallback=function(callback)
    table.insert(g.util._delayedCallbackStack,callback)
    ReserveScript("UIE_UTIL_DELAYEDCALLBACK()",0.01)
end
g.util._namedReserveScript={}
g.util.namedReserveScript=function(name,callback,time)
    g.util._namedReserveScript[name]=callback
    ReserveScript(string.format("UIE_UTIL_NAMEDRESERVESCRIPT('%s')",name),time)
end
g.util.instanceof = function(subject, super)
    super = tostring(super)
    local mt = getmetatable(subject)

    while true do
        if mt == nil then
            return false
        end
        if tostring(mt) == super then
            return true
        end

        mt = getmetatable(mt)
    end
end
g.util.cloneControl = function(src, dest)
    for i = 0, src:GetChildCount() - 1 do
        local child = src:GetChildByIndex(i)
        AUTO_CAST(child)
        local cstr = child:GetClassString()
        if cstr == 'ui::CControlSet' then
            --print(child:GetStrcontrolset()..'/'..child:GetName()..'/'..child:GetText())
            local clone = dest:CreateOrGetControlSet(child:GetStrcontrolset(), child:GetName(), child:GetX(), child:GetY())
            if clone then
                AUTO_CAST(clone)
                clone:CloneFrom(child)

                g.util.cloneControl(child, clone)
            end
        else
            local clone = dest:CreateOrGetControl(child:GetClassName(), child:GetName(), child:GetX(), child:GetY(), child:GetWidth(), child:GetHeight())
            AUTO_CAST(clone)
            clone:CloneFrom(child)

            g.util.cloneControl(child, clone)
        end
    end
end
g.util.showItemToolTip = function(invItem, x, y)
    local obj = GetIES(invItem:GetObject())

    local noTradeCnt = TryGetProp(obj, 'BelongingCount')
    local itemFrame = ui.GetFrame('wholeitem')

    if not itemFrame then
        itemFrame = ui.GetNewToolTip('wholeitem', 'wholeitem')
    end
    UPDATE_ITEM_TOOLTIP(itemFrame, '', 0, 0, nil, obj, noTradeCnt)
    itemFrame:RefreshTooltip()
    itemFrame:ShowWindow(1)
    itemFrame:SetOffset(x, y)
    --ui.ToCenter(itemFrame);
end
g.util.isNilOrNoneOrWhitespace = function(str)
    if str == nil then
        return true
    else
        local mod = string.gsub(str, ' *', ''):lower()
        if mod == '' or mod == 'none' then
            return true
        end
    end
    return false
end
g.util.hideItemToolTip = function()
    local itemFrame = ui.GetFrame('wholeitem')

    if itemFrame then
        itemFrame:ShowWindow(0)
    end
end
g.util.inventory_filters = {
    --{name = "Fav", text = "★", tooltip = "Favorites", imagename = "uie_favorites", original = nil},
    --{name = 'All', text = 'All', tooltip = 'All', imagename = 'uie_all', original = 'All'},
    {rank = 0, name = 'Prm', text = 'Prm', tooltip = 'Premium', imagename = 'uie_premium', original = 'Premium'},
    {rank = 1, name = 'Equ', text = 'Equ', tooltip = 'Equip', imagename = 'uie_equip', original = 'Equip'},
    {rank = 2, name = 'Spl', text = 'Spl', tooltip = 'Consume Item', imagename = 'uie_consume', original = 'Consume'},
    {rank = 3, name = 'Crd', text = 'Crd', tooltip = 'Card', imagename = 'uie_card', original = 'Card'},
    {rank = 4, name = 'Gem', text = 'Gem', tooltip = 'Gem', imagename = 'uie_gem', original = 'Gem'},
    {rank = 5, name = 'Etc', text = 'Etc', tooltip = 'Etc', imagename = 'uie_etc', original = 'Etc'},
    {rank = 6, name = 'Rcp', text = 'Rcp', tooltip = 'Recipe', imagename = 'uie_recipe', original = 'Recipe'},
    {rank = 7, name = 'Hou', text = 'Hou', tooltip = 'Housing', imagename = 'uie_housing', original = 'Housing'}
}
g.util.getEquipItemList=function(filter)
    local equiplist = session.GetEquipItemList()
    local invItemList = {}
    local index_count = 1
    for i = 0, equiplist:Count() - 1 do
        local equipItem = equiplist:GetEquipItemByIndex(i)
        local tempobj = equipItem:GetObject()
        local obj = GetIES(tempobj)
        if tempobj ~= nil then
            local pass = true
            if filter then
                pass = filter(equipItem)
            end
            if pass then
                --local baseidcls = GET_BASEID_CLS_BY_INVINDEX(equipItem.invIndex)

                --local titleName = baseidcls.ClassName
                -- if baseidcls.MergedTreeTitle ~= 'NO' then
                --     titleName = baseidcls.MergedTreeTitle
                -- end
                --local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                local rank = 0
                for _, v in ipairs(g.util.inventory_filters) do
                   
                        rank = 1
                   
                end
                invItemList[index_count] = {
                    rank = rank,
                    item = equipItem,
                    iesid=equipItem:GetIESID()
                }

                index_count = index_count + 1
            end
        end

    end
    return invItemList
end
g.util.getInvItemList = function(filter)
    session.BuildInvItemSortedList()

    local sortedList = session.GetInvItemSortedList()
    local invItemCount = sortedList:size()
    local invItemList = {}
    local index_count = 1
    for i = 0, invItemCount - 1 do
        local invItem = sortedList:at(i)
        if invItem ~= nil then
            local itemCls = GetIES(invItem:GetObject())
            if itemCls ~= nil and item.IsNoneItem(itemCls.ClassID) == 0 and itemCls.MarketCategory ~= 'None' then
                local pass = true
                if filter then
                    pass = filter(invItem)
                end
              
                if pass then
                    local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

                    --local titleName = baseidcls.ClassName
                    -- if baseidcls.MergedTreeTitle ~= 'NO' then
                    --     titleName = baseidcls.MergedTreeTitle
                    -- end
                    local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                    local rank = 0
                    for _, v in ipairs(g.util.inventory_filters) do
                        if v.original == typeStr then
                            rank = v.rank
                        end
                    end
                    invItemList[index_count] = {
                        rank = rank,
                        item = invItem,
                        iesid=invItem:GetIESID()
                    }

                    index_count = index_count + 1
                end
            end
        end
    end
    return invItemList
end
g.util.generateSilverString = function(price, size)
    size = size or 20
    --print(string.format('{img icon_item_silver %d %d} {ol}{s%d} %s',size,size,size*3/4,tostring(price)))
    return string.format('{img icon_item_silver %d %d} {ol}{s%d} %s {/}{/}{/}', size, size, size * 3 / 4, tostring(price))
end
UIMODEEXPERT = g
function UIE_UTIL_DELAYEDCALLBACK()
    local top=table.remove(g.util._delayedCallbackStack)
    assert(pcall(top))
end

function UIE_UTIL_NAMEDRESERVESCRIPT(name)
    local cb= g.util._namedReserveScript[name]
    g.util._namedReserveScript[name]=nil
    if cb then
        assert(pcall(cb,name))
    end
end