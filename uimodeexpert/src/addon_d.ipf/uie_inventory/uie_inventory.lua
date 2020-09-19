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
        new = function(base)
            local self = {}
            setmetatable(self, {__index = g.inv.uieInventoryBase})
            self.base = base
            self:initialize()
            return self
        end,
        initialize = function(self)
            local base = self.base
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
            local slotset = gbox:CreateOrGetControl('slotset', 'slotset', 0, 0,0, 0)
            AUTO_CAST(slotset)
            slotset:SetOffset(0, 0)
            slotset:Resize(gbox:GetWidth() - 20, gbox:GetHeight())
            -- local ox = 20
            -- local oy = 0
            -- local tabsizew =32
            -- local tabsizeh =22
            -- local sx = tabsize
            -- local sy = tabsize
            -- local prefix = "{ol}{s12}"
            -- --generate tabs
            -- for k,v in ipairs(g.inv.filters) do
            --     local  btn = gboxtab:CreateOrGetControl("button", "uie_btn" .. v.name, ox, oy, sx, sy)
            --     AUTO_CAST(btn)

            --     btn:SetEventScript(ui.LBUTTONUP, "UIE_TAB_ON_CLICK")
            --     btn:SetEventScriptArgString(ui.LBUTTONUP, v.name)
            --     btn:SetTextTooltip(v.tooltip)
            --     btn:SetSkinName('textbutton_nomal_joo')
            --     --btn:SetSkinName("None")
            --     if (v.imagename) then
            --         btn:SetImage(v.imagename)

            --     else
            --         btn:SetText(prefix .. v.text)
            --     end
            --     ox = ox + sx + 1
            -- end
            self:resize()
            self:generateList()
        end,
        generateList = function(self)
            local base = self.base
            local iframe = ui.GetFrame('inventory')
            local slotset = base:GetChildRecursively('slotset')

            AUTO_CAST(slotset)
            slotset:RemoveAllChild()
            session.BuildInvItemSortedList()

            local sortedList = session.GetInvItemSortedList()
            local invItemCount = sortedList:size()
            slotset:SetColRow(2, math.ceil(invItemCount/2))
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
                if invItem ~= nil then
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
            --ui.InventoryHideEmptySlotBySlotSet(slotset)
        end,
        resize = function(self)
            local base = self.base
            --tab
            local gboxtab = base:GetChild('gboxtab')
            AUTO_CAST(gboxtab)
            gboxtab:SetOffset(20, 70)
            gboxtab:Resize(base:GetWidth() - 30, base:GetHeight() - 100)
            local tab = gboxtab:GetChild('tab')
            tab:SetOffset(0, 0)
            tab:Resize(gboxtab:GetWidth(), gboxtab:GetHeight())

            local gbox = base:GetChild('gbox')
            AUTO_CAST(gbox)
            gbox:SetOffset(20, 120)
            gbox:Resize(base:GetWidth() - 20, base:GetHeight() - 180)
            local slotset = gbox:GetChild('slotset')
            slotset:SetOffset(0, 0)
            slotset:Resize(gbox:GetWidth() - 20, gbox:GetHeight())
        end
    },
    registerInventory=function(inv)
        g.inv.inventories[# g.inv.inventories+1]=inv
    end,
    inventories = {}
}

UIMODEEXPERT = g

--マップ読み込み時処理（1度だけ）
function UIE_INVENTORY_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(framename)
            frame:ShowWindow(1)
            addon:RegisterMsg('GAME_START','UIE_INVENTORY_GAME_START')
            local gbox=frame:CreateOrGetControl("groupbox","inventory",5,100,frame:GetWidth()-10,frame:GetHeight()-120)
            AUTO_CAST(gbox)
            g.inv.registerInventory(g.inv.uieInventoryBase.new(gbox))
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function UIE_INVENTORY_GAME_START()
    g.inv.inventories={}
end
function UIE_INVENTORY_CLOSE(frame)
    for k, v in ipairs(g.inv.inventories) do
        if v.frame == frame then
            g.inv.inventories[k]=nil
            break
        end
    end
    frame:ShowWindow(0)
end
function UIE_INVENTORY_OPEN(frame)
    EBI_try_catch {
        try = function()

 
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
