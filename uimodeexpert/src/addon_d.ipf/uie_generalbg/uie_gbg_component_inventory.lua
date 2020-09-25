--uie_gbg_component_inventory


local acutil = require('acutil')

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

local function inherit(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end
local inventory_filters = {
    --{name = "Fav", text = "★", tooltip = "Favorites", imagename = "uie_favorites", original = nil},
    --{name = 'All', text = 'All', tooltip = 'All', imagename = 'uie_all', original = 'All'},
    {rank=0,name = 'Prm', text = 'Prm', tooltip = 'Premium', imagename = 'uie_premium', original = 'Premium'},
    {rank=1,name = 'Equ', text = 'Equ', tooltip = 'Equip', imagename = 'uie_equip', original = 'Equip'},
    {rank=2,name = 'Spl', text = 'Spl', tooltip = 'Consume Item', imagename = 'uie_consume', original = 'Consume'},
    {rank=3,name = 'Crd', text = 'Crd', tooltip = 'Card', imagename = 'uie_card', original = 'Card'},
    {rank=4,name = 'Gem', text = 'Gem', tooltip = 'Gem', imagename = 'uie_gem', original = 'Gem'},
    {rank=5,name = 'Etc', text = 'Etc', tooltip = 'Etc', imagename = 'uie_etc', original = 'Etc'},
    {rank=6,name = 'Rcp', text = 'Rcp', tooltip = 'Recipe', imagename = 'uie_recipe', original = 'Recipe'},
    {rank=7,name = 'Hou', text = 'Hou', tooltip = 'Housing', imagename = 'uie_housing', original = 'Housing'},

}
UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT

g.gbg.uiegbgComponentInventory={
    new=function(tab,parent,name,enableaccess)
        local self=inherit(g.gbg.uiegbgComponentInventory,g.gbg.uiegbgComponentBase,tab,parent,name)
        self.enableaccess=enableaccess or true
        return self
    end,
    initializeImpl=function(self,gbox)
        local gboxin=gbox:CreateOrGetControl('groupbox','gboxin',0,0,gbox:GetWidth()-25,gbox:GetHeight())
        local gboxtab=gbox:CreateOrGetControl('groupbox','gboxtab',gbox:GetWidth()-25,0,25,gbox:GetHeight())
        AUTO_CAST(gboxin)
        AUTO_CAST(gboxtab)
        
        --create tabs
        for k,v in ipairs(inventory_filters) do
            local btn=gboxtab:CreateOrGetControl('button','btn'..v.name,0,35*(k-1),25,25)
            btn:SetSkinName('none')
        end
        --create inven)
        self:refreshInventory(gboxin)
    end,
    hookmsgImpl=function(self,frame,msg,argStr,argNum)
        if msg=='INV_ITEM_ADD' or msg=='INV_ITEM_CHANGE_COUNT' or msg=='INV_ITEM_REMOVE' or msg=='INV_ITEM_LIST_GET' then
            self:refreshInventory()
        end
    end,
    refreshInventory=function(self,gboxin)
        if not gboxin then
            gboxin=self.parent:GetChild('gboxin')
        end
        
        local iframe = ui.GetFrame('inventory')

        gboxin:RemoveAllChild()
        session.BuildInvItemSortedList()

        local sortedList = session.GetInvItemSortedList()
        local invItemCount = sortedList:size()
        local invItemList = {}
        local index_count = 1
        for i = 0, invItemCount - 1 do
            local invItem = sortedList:at(i);
            if invItem ~= nil then
 
                local itemCls = GetIES(invItem:GetObject())
                if itemCls ~= nil and item.IsNoneItem (itemCls.ClassID)==0 and itemCls.MarketCategory ~= "None" then
                    local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= 'NO' then
                        titleName = baseidcls.MergedTreeTitle
                    end
                    local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                    local rank=0
                    for _,v in ipairs(inventory_filters) do
                        if v.original==typeStr then
                            rank=v.rank
                        end
                    end
                    invItemList[index_count] = {
                        rank=rank,
                        item=invItem
                    }
    
                    index_count = index_count + 1
                end
              
            end
        end
        table.sort(invItemList,
        function(a,b) 
            if a.rank ~= b.rank then
                return a.rank<b.rank 
            else
                return a.item.type<b.item.type
            end
        end)
        -- slotset:SetColRow(9, math.ceil(invItemCount / 2))
        -- slotset:SetSpc(0, 0)
        -- local slotsize = 48
        
        -- slotset:SetSlotSize(slotwidth, slotsize)
        -- slotset:EnableDrag(1)
        -- slotset:EnableDrop(1)
        -- slotset:EnablePop(1)
        -- --slotset:SetSkinName('slot')
        -- slotset:CreateSlots()
        local treename=nil
        local slotidx = 0
        local oy=0
        local slotset=nil
        local slotsize = 48
        local cnt=0        
        local col=math.floor((gboxin:GetWidth()-20)/slotsize)   
        for _,v in ipairs(invItemList) do
            local invItem = v.item
            
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls ~= nil and item.IsNoneItem (itemCls.ClassID)==0 and itemCls.MarketCategory ~= "None" then
                    local baseidcls = GET_BASEID_CLS_BY_INVINDEX(invItem.invIndex)

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= 'NO' then
                        titleName = baseidcls.MergedTreeTitle
                    end
                    local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                    if treename ~= typeStr then
                        cnt=0
                        treename=typeStr
                        if slotset then
                            slotset:Invalidate()
                            slotset:EnableAutoResize(true,true)
                            oy=oy+slotset:GetHeight()+5
                        end
                        local rich=gboxin:CreateOrGetControl('richtext','category'..treename,0,oy,gboxin:GetWidth(),30)
                        rich:SetText('{@stb42}'..treename)
                        oy=oy+30+5
                        slotset=gboxin:CreateOrGetControl('slotset','slotset'..treename,0,oy,gboxin:GetWidth(),0)
                        AUTO_CAST(slotset)
                        slotset:SetColRow(col, 1)
                        slotset:SetSpc(0, 0)
                        
                        slotset:SetSlotSize(slotsize, slotsize)
                        slotset:EnableDrag(1)
                        slotset:EnableDrop(1)
                        slotset:EnablePop(1)
                        --slotset:SetSkinName('slot')
                        slotset:CreateSlots()
                        slotidx=0
                    end
                    cnt=cnt+1
                    if cnt==col then
                        slotset:ExpandRow()
                        cnt=0
                    end

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

                    INV_SLOT_UPDATE(ui.GetFrame('inventory'), invItem, parentslot)
                    
                    if not self.enableaccess then
                        slot:SetEventScript(ui.RBUTTONDOWN, '');

   
                        slot:SetEventScript(ui.RBUTTONDBLCLICK, '');
                    
                    
                        slot:SetEventScript(ui.LBUTTONDOWN, '');

                    end
                end
            end
        end

    end
    
}

UIMODEEXPERT = g

function UIE_GBG_INVENTORY_FILTER(invItem, filtername)
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