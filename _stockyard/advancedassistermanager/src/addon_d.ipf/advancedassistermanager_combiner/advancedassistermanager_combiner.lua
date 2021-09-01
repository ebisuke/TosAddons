-- advancedassistermanager_combiner
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

g.framename_combiner = 'advancedassistermanager_combiner'
g.aamcb = {
    combine = {
        isworking = false,
        iswait = false,
        ingredients = {},
        cardworking = {},
        product = {},
        rarity = 0
    },
    getTabIndex = function()
        local frame = ui.GetFrame(g.framename_combiner)
        local tab = frame:GetChild('tab')
        AUTO_CAST(tab)
        local tabidx = tab:GetSelectItemIndex()
        return tabidx
    
    end

}


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

--マップ読み込み時処理（1度だけ）
function ADVANCEDASSISTERMANAGER_COMBINER_ON_INIT(addon, frame)
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
            addon:RegisterMsg('ANCIENT_CARD_COMBINE', 'ADVANCEDASSISTERMANAGER_ON_ANCIENT_CARD_UPDATE');
            addon:RegisterMsg('ANCIENT_CARD_EVOLVE', 'ADVANCEDASSISTERMANAGER_ON_ANCIENT_CARD_UPDATE');
            frame:ShowWindow(0)
            ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSITERMANAGER_COMBINER_OPEN()
    ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
end
function ADVANCEDASSITERMANAGER_COMBINER_CLOSE()

end
function ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename_combiner)
            
            local timer = frame:CreateOrGetControl("timer", "addontimer");
            AUTO_CAST(timer)
            timer:SetUpdateScript("ADVANCEDASSISTERMANAGER_COMBINER_TICK");
            timer:Stop();
            timer:Start(0.01, 0);
            local gboxmain = frame:CreateOrGetControl('groupbox', 'gboxmain', 10, 120, frame:GetWidth() - 20, 280)
            local gboxcomb = frame:CreateOrGetControl('groupbox', 'gboxcomb', 10, 440, frame:GetWidth() - 20, frame:GetHeight() - 450)
            local tab = frame:CreateOrGetControl('tab', 'tab', 10, 90, frame:GetWidth(), 30)
            gboxmain:SetSkinName("bg2")
            gboxcomb:SetSkinName("bg2")
            
            local btnrefresh = frame:CreateOrGetControl('button', 'btnrefresh', 10, 60, 100, 30)
            btnrefresh:SetSkinName('test_pvp_btn')
            btnrefresh:SetText('{ol}Refresh/Stop')
            btnrefresh:SetEventScript(ui.LBUTTONUP, 'ADVANCEDASSISTERMANAGER_COMBINER_REFRESH')
            
            AUTO_CAST(tab)
            tab:ClearItemAll()
            tab:AddItem('{ol}Combine')
            --tab:AddItem('{ol}Evolve')
            ADVANCEDASSISTERMANAGER_COMBINER_INIT_WORKINGBOX()
            local slotsetinv = gboxcomb:CreateOrGetControl('slotset', 'slotsetinv', 5, 5, gboxcomb:GetWidth() - 20 - 10, gboxcomb:GetHeight() - 10)
            ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotsetinv, nil, nil, nil, 7)
            ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotsetinv, nil, g.aam.getAllCards(nil, true))
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_COMBINER_INIT_WORKINGBOX()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename_combiner)
            
            local gbox = frame:GetChild('gboxmain')
            
            gbox:RemoveAllChild()
            
            local tabindex = g.aamcb.getTabIndex()
            local btncombine = gbox:CreateOrGetControl('button', 'btncombine', 0, 0, 100, 30)
            btncombine:SetSkinName('test_pvp_btn')
            btncombine:SetText('{ol}{s20}Start')
            btncombine:SetEventScript(ui.LBUTTONUP, 'ADVANCEDASSISTERMANAGER_COMBINER_START_COMBINE')
            btncombine:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            btncombine:SetMargin(0, 0, 0, 20)
            
            --working slot
            local slotworking = gbox:CreateOrGetControl('slotset', 'slotworking', 50, 60, 309, 120)
            AUTO_CAST(slotworking)
            ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotworking, 80, 100, 0, 3, 1)
            ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotworking, nil, g.aamcb.combine.cardworking)
            slotworking:SetTextTooltip('Working Slot')
            --ingredients slot
            local slotingredients = gbox:CreateOrGetControl('slotset', 'slotingredients', 50, 180, 309, 80)
            AUTO_CAST(slotingredients)
            ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotingredients, 30, 40, 0, 7, 2)
            
            ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotingredients, nil, g.aamcb.combine.ingredients, true, true)
            
            slotingredients:SetTextTooltip('Ingredients Slot')
            --gauge
            local gauge = gbox:CreateOrGetControl('gauge', 'gauge', 360, 115, 150, 10)
            AUTO_CAST(gauge)
            gauge:SetMaxPoint(100)
            gauge:SetCurPoint(0)
            
            
            --product
            local slotproduct = gbox:CreateOrGetControl('slotset', 'slotproduct', 410 + 150, 60, 100, 120)
            AUTO_CAST(slotproduct)
            ADVANCEDASSISTERMANAGER_INIT_SLOTSET(slotproduct, nil, nil, 0, 1)
            ADVANCEDASSISTERMANAGER_UPDATE_CARDS(slotproduct, nil, g.aamcb.combine.product, false)
            slotproduct:SetTextTooltip('Product Slot')
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_COMBINER_REFRESH()
    -- local frame= ui.GetFrame(g.framename_combiner)
    -- local gbox=frame:GetChild('gboxmain')
    -- local gauge=gbox:GetChild('gauge')
    -- AUTO_CAST(gauge)
    ADVANCEDASSISTERMANAGER_COMBINER_STOP()
end
function ADVANCEDASSISTERMANAGER_COMBINER_STOP()
    local frame = ui.GetFrame(g.framename_combiner)
    
    local gbox = frame:GetChild('gboxmain')
    local gauge = gbox:GetChild('gauge')
    AUTO_CAST(gauge)
    gauge:SetCurPoint(0)
    g.aamcb.combine.ingredients = {}
    g.aamcb.combine.product = {}
    g.aamcb.combine.cardworking = {}
    g.aamcb.combine.isworking = false
    ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
end
function ADVANCEDASSISTERMANAGER_COMBINER_START_COMBINE()
    ui.MsgBox('If the combine results in a card of the same rarity,{nl} it will be automatically added to the combine candidate.{nl} Are you sure?', 'ADVANCEDASSISTERMANAGER_COMBINER_DO_START_COMBINE()')
end
function ADVANCEDASSISTERMANAGER_COMBINER_DO_START_COMBINE()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame(g.framename_combiner)
            local slotsetinv = frame:GetChildRecursively('slotsetinv')
            local zoneName = session.GetMapName();
            if IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName) == false then
                addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
                return
            end
            g.aamcb.combine.ingredients = ADVANCEDASSISTERMANAGER_GET_SELECTED_CARDS(slotsetinv)
            if #g.aamcb.combine.ingredients >= 3 then
                local rarity = g.aamcb.combine.ingredients[1].rarity
                for k, v in ipairs(g.aamcb.combine.ingredients) do
                    if v.rariry == rarity then
                        ui.MsgBox('Rarity is not match.', 'None')
                        g.aamcb.combine.ingredients = {}
                        return
                    end
                    if v.islocked then
                        ui.MsgBox('Card(s) is locked.', 'None')
                        g.aamcb.combine.ingredients = {}
                        return
                    end
                end
                local remain = ANCIENT_CARD_SLOT_MAX - session.pet.GetAncientCardCount()
                if remain < 3 then
                    ui.SysMsg('There are less than 3 empty slots.{nl} May be interrupted in the middle.')
                end
                
                
                ADVANCEDASSISTERMANAGER_COMBINER_COMBINE_NEXT()
                g.aamcb.combine.isworking = true
            else
                ui.SysMsg('Choose three or more cards')
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_COMBINER_PICKUP_WORK()
    if #g.aamcb.combine.ingredients >= 3 then
        local wk = {}
        local remain = {}
        local same = true
        
        for k, v in ipairs(g.aamcb.combine.ingredients) do

            if #wk == 3   then
                remain[#remain+1] = v
                
            elseif #wk > 0  then
                if #wk == 2 then
                    if  wk[1].classname ~=  wk[2].classname or wk[1].classname ~= v.classname and wk[2].classname ~= v.classname then
                        wk[#wk + 1] = v
                    else
                        remain[#remain+1] = v
                    end
                else
                    wk[#wk + 1] = v
                end
            
            else
                wk[#wk + 1] = v
            end
            
        end
       
        
        return wk, remain
    else
        return {},g.aamcb.combine.ingredients
    end
end
function ADVANCEDASSISTERMANAGER_COMBINER_TICK()
    local frame = ui.GetFrame(g.framename_combiner)
    local gauge = frame:GetChildRecursively('gauge')
    AUTO_CAST(gauge)
    if g.aamcb.combine.isworking and not g.aamcb.combine.iswait then
        if gauge:GetCurPoint() < gauge:GetMaxPoint() then
            gauge:SetCurPoint(gauge:GetCurPoint() + 1)
        else
            
            ADVANCEDASSISTERMANAGER_COMBINER_DO_COMBINE()
            gauge:SetCurPoint(0)
        end
    end
end
function ADVANCEDASSISTERMANAGER_COMBINER_COMBINE_NEXT()
    EBI_try_catch{
        try = function()
            imcSound.PlaySoundEvent("sys_jam_mix_whoosh");
            table.sort(g.aamcb.combine.ingredients, function(a, b)
                return BoolToNumber(a.isinInventory) < BoolToNumber(b.isinInventory)
            end)
            
            g.aamcb.combine.cardworking, g.aamcb.combine.ingredients = ADVANCEDASSISTERMANAGER_COMBINER_PICKUP_WORK()
            g.aamcb.combine.iswait = false
            ADVANCEDASSISTERMANAGER_COMBINER_INIT_FRAME()
     
            if #g.aamcb.combine.cardworking < 3 then
                g.aamcb.combine.isworking = false
                ui.SysMsg('Complete.')
            
            else
                --continue
                g.aamcb.combine.rarity = g.aamcb.combine.cardworking[1].rarity
                g.aamcb.combine.isworking = true
            end
        end,
        catch = function(error)
            g.aamcb.combine.isworking = false
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_COMBINER_DO_COMBINE()
    EBI_try_catch{
        try = function()
            imcSound.PlaySoundEvent("market_sell");
            local frame = ui.GetFrame(g.framename_combiner)
            
            local slotproduct = frame:GetChildRecursively('slotproduct')
            
            slotproduct:PlayUIEffect('UI_tkemon_001', 5, 'COMBINE')
            g.aamcb.combine.iswait = true
            if not ADVANCEDASSISTERMANAGER_ENSURECARDS(g.aamcb.combine.cardworking, true, function()
                EBI_try_catch{
                    try = function()
                        DBGOUT('combine do')
                       
                        local wk = g.aam.getSameStatCards(g.aamcb.combine.cardworking)
                        --Combine
                        ReqCombineAncientCard(
                            wk[1].guid,
                            wk[2].guid,
                            wk[3].guid)
                        
                        g.aamcb.combine.cardworking = {}
                        ADVANCEDASSISTERMANAGER_COMBINER_INIT_WORKINGBOX()
                    end,
                    catch = function(error)
                        g.aamcb.combine.isworking = false
                        ERROUT(error)
                    end
                }
            end) then
                g.aamcb.combine.isworking = false
            end
        
        
        end,
        catch = function(error)
            g.aamcb.combine.isworking = false
            ERROUT(error)
        end
    }
end
function ADVANCEDASSISTERMANAGER_ON_ANCIENT_CARD_UPDATE(frame, msg, guid, slot)
    EBI_try_catch{
        try = function()
            
            if g.aamcb.combine.isworking then
      
                if msg == "ANCIENT_CARD_COMBINE" and  g.aamcb.combine.iswait then
                    DBGOUT('combined')
                    local card = g.aam.getCardByGuid(guid)[1]
                    if card.rarity == g.aamcb.combine.rarity then
                        g.aamcb.combine.ingredients[#g.aamcb.combine.ingredients + 1] = card
                    
                    end
                    g.aamcb.combine.product = {card}
                    ADVANCEDASSISTERMANAGER_COMBINER_COMBINE_NEXT()
                end
            
            end
        end,
        catch = function(error)
            g.aamcb.combine.isworking = false
            ERROUT(error)
        end
    }
end
_G['ADDONS'][author][addonName] = g
