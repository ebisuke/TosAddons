
-- EnhancedWeaponSwapConfig
local addonName = "EnhancedWeaponSwap"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

local function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
local function EBI_IsNoneOrNil(val)
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



-- ライブラリ読み込み
function ENHANCEDWEAPONSWAPCONFIG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            EWSC_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function EWSC_TOGGLE()
    ui.ToggleFrame("enhancedweaponswapconfig")
end

function EWSC_INIT()
    
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("enhancedweaponswapconfig")
            frame:Resize(840, 700)
            local gbox = frame:CreateOrGetControl("groupbox", "gbox", 50, 100, 730, 500)
            AUTO_CAST(gbox)
            gbox:EnableHittestGroupBox(true)
            gbox:EnableHitTest(1)
            gbox:EnableScrollBar(1)
            gbox:SetSkinName("None")
            
            local listtrigger = gbox:CreateOrGetControl("listbox", "triggers", 10, 40, 230, gbox:GetHeight() - 150)
            AUTO_CAST(listtrigger)
            local listcondition = gbox:CreateOrGetControl("listbox", "condition", 250, 40, 230, gbox:GetHeight() - 150)
            AUTO_CAST(listcondition)
            local listaction = gbox:CreateOrGetControl("listbox", "action", 490, 40, 230, gbox:GetHeight() - 150)
            AUTO_CAST(listaction)
            
            gbox:EnableHittestGroupBox(true)
            gbox:EnableHitTest(1)
            gbox:EnableScrollBar(1)
            gbox:SetSkinName("None")
            
            local gconfig = frame:CreateOrGetControl("groupbox", "gconfig", 50, gbox:GetHeight() - 230 + 230, 730, 180)
            
            AUTO_CAST(gconfig)
            gconfig:EnableHittestGroupBox(true)
            gconfig:EnableHitTest(1)
            gconfig:EnableScrollBar(1)
            gconfig:SetSkinName("bg2")
            listtrigger:SetEventScript(ui.LBUTTONUP, "EWSC_TRIGGER_ONSELECTED")
            
            listcondition:SetEventScript(ui.LBUTTONUP, "EWSC_CONDITION_ONSELECTED")
            listaction:SetEventScript(ui.LBUTTONUP, "EWSC_ACTION_ONSELECTED")
            -- listtrigger:SetSkinName("bg2")
            -- listtrigger:SetTextByKey("selectionimage","bar_selection")
            -- listtrigger:SetTextByKey("cursoronimage","bar_cursoron")
            -- listtrigger:SetClickSound("button_click")
            -- listtrigger:SetTextByKey("showtitle","false")
            -- listcondition:SetSkinName("bg2")
            -- listcondition:SetTextByKey("selectionimage","bar_selection")
            -- listcondition:SetTextByKey("cursoronimage","bar_cursoron")
            -- listcondition:SetClickSound("button_click")
            -- listcondition:SetTextByKey("showtitle","false")
            -- listaction:SetSkinName("bg2")
            -- listaction:SetTextByKey("selectionimage","bar_selection")
            -- listaction:SetTextByKey("cursoronimage","bar_cursoron")
            -- listaction:SetTextByKey("showtitle","false")
            -- listaction:SetClickSound("button_click")
            -- listtrigger:Invalidate()
            -- listcondition:Invalidate()
            -- listaction:Invalidate()
            local btnaddtrigger = gbox:CreateOrGetControl("button", "btnaddtrigger", 10, 0, 40, 40)
            AUTO_CAST(btnaddtrigger)
            btnaddtrigger:SetSkinName("test_pvp_btn")
            btnaddtrigger:SetText("{s24}{ol}+")
            btnaddtrigger:SetEventScript(ui.LBUTTONUP, "EWSC_ONBUTTON_ADDTRIGGER")
            btnaddtrigger:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
            local btndeltrigger = gbox:CreateOrGetControl("button", "btndeltrigger", 50, 0, 40, 40)
            AUTO_CAST(btndeltrigger)
            btndeltrigger:SetSkinName("test_pvp_btn")
            btndeltrigger:SetText("{s24}{ol}-")
            local btnaddcondition = gbox:CreateOrGetControl("button", "btnaddcondition", 260, 0, 40, 40)
            AUTO_CAST(btnaddcondition)
            btnaddcondition:SetSkinName("test_pvp_btn")
            btnaddcondition:SetText("{s24}{ol}+")
            btnaddcondition:SetEventScript(ui.LBUTTONUP, "EWSC_ONBUTTON_ADDCONDITION")
            btnaddcondition:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
            local btndelcondition = gbox:CreateOrGetControl("button", "btndelcondition", 300, 0, 40, 40)
            AUTO_CAST(btndelcondition)
            btndelcondition:SetSkinName("test_pvp_btn")
            btndelcondition:SetText("{s24}{ol}-")
            local btnaddaction = gbox:CreateOrGetControl("button", "btnaddaction", 500, 0, 40, 40)
            AUTO_CAST(btnaddaction)
            btnaddaction:SetSkinName("test_pvp_btn")
            btnaddaction:SetText("{s24}{ol}+")
            btnaddaction:SetEventScript(ui.LBUTTONUP, "EWSC_ONBUTTON_ADDACTION")
            btnaddaction:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
            local btndelaction = gbox:CreateOrGetControl("button", "btndelaction", 540, 0, 40, 40)
            AUTO_CAST(btndelaction)
            btndelaction:SetSkinName("test_pvp_btn")
            btndelaction:SetText("{s24}{ol}-")
            EWSC_INITTREE(frame, gbox, g.personalsettings.combos)
        
        --add button
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function EWSC_INITTREE(frame, gbox, combos)
    if frame == nil then
        frame = ui.GetFrame("enhancedweaponswapconfig")
    end
    if gbox == nil then
        gbox = frame:GetChild("gbox")
    end
    if combos == nil then
        combos = g.personalsettings.combos or {}
    end
    local listtrigger = gbox:GetChild("triggers")
    AUTO_CAST(listtrigger)
    local listcondition = gbox:GetChild("condition")
    AUTO_CAST(listcondition)
    local listaction = gbox:GetChild("action")
    AUTO_CAST(listaction)
    listtrigger:ClearItemAll();
    listaction:ClearItemAll();
    listcondition:ClearItemAll();
    
    
    local w = listtrigger:GetWidth()
    local padding = {0, 0, 0, 35}
    
    for k, v in ipairs(combos) do
        
        listtrigger:AddItem(g.getchain(v.trigger.name).text, k - 1);
        DBGOUT(v.trigger.name)
    end
end

function EWSC_CONFIG_SELECTEDITEM(parent, ctrl)
    
    EBI_try_catch{
        try = function()
            AUTO_CAST(ctrl)
            g.settings.primary = g.itemdefine[ctrl:GetSelItemIndex() + 1].Name
            DBGOUT("SELECTED")
            EWS_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function EWSC_GENERATECONFIGVIEW_SPECIFIEDSKILL(gconfig, data)
    local slotset = gconfig:CreateOrGetControl("slotset", "skillslot", 20, 20, 60 * 10, 60 + 2)
    AUTO_CAST(slotset)
    slotset:ShowWindow(1)
    slotset:SetSkinName("invenslot2")
    slotset:SetSlotSize(60, 60)
    slotset:SetColRow(11, 2)
    slotset:SetSpc(2, 2);
    slotset:RemoveAllChild()
    slotset:CreateSlots()
    slotset:EnableDrag(0)
    slotset:EnablePop(0)
    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        slot:SetEventScript(ui.DROP, "EWS_ON_DROP_SKILL")
       
        if(data.clsid[i+1])then

            
            EWS_SET_QUICK_SLOT(nil,slot,"Skill",data.clsid[i+1],"",nil,nil,nil)

        end

    end
end
function EWSC_SAVECONFIG_SPECIFIEDSKILL(gconfig, data)
    local slotset = gconfig:GetChild( "skillslot")
    AUTO_CAST(slotset)
    data.clsid={}
    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        local icon=slot:GetIcon()
        if(icon~=nil)then
            data.clsid[i+1]=icon:GetInfo().type

        else
            data.clsid[i+1]=nil
        end

    end
end
function EWSC_ON_DROP_SKILL(frame, slot)
    return EBI_try_catch{
        try = function()
            AUTO_CAST(slot)
                local liftIcon = ui.GetLiftIcon()
                local liftParent = liftIcon:GetParent()
                local iconInfo = liftIcon:GetInfo()
                local imageName = iconInfo.imageName
                local clsid = iconInfo.type
                local iesid = iconInfo:GetIESID()
                EWSC_SET_QUICK_SLOT(nil,slot, iconInfo:GetCategory(), clsid,iesid)
                EWSC_SAVECONFIG_SPECIFIEDSKILL(slot:GetParent():GetParent(),g.currentdata)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWSC_ON_DUMP(frame, control, argStr, argNum)
    return EBI_try_catch{
        try = function()
            local icon = AUTO_CAST(control);
            local slot = GET_PARENT(icon);
            AUTO_CAST(slot)
            DBGOUT("DUMP")
            slot:ReleaseBlink();
            slot:ClearIcon();
            g.getchain(g.currentdata.name).fnsaveconfig(slot:GetParent():GetParent(),g.currentdata)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWSC_SET_QUICK_SLOT(frame, slot, category, type, iesID, makeLog, sendSavePacket, isForeceRegister)


    local icon = CreateIcon(slot);
    local imageName = "";
    
    if category ~= 'Item' then
        icon:SetDrawLifeTimeText(0)
        slot:SetFrontImage('None')
    end
    
    if category == 'Action' then
        icon:SetColorTone("FFFFFFFF");
        icon:ClearText();
    elseif category == 'Skill' then
        local skl = session.GetSkill(type);
        if IS_NEED_CLEAR_SLOT(skl, type) == true then
            if icon ~= nil then
                tolua.cast(icon, "ui::CIcon");
                icon:SetTooltipNumArg(0)
            end
            slot:ClearIcon();
            return;
        end
        imageName = 'icon_' .. GetClassString('Skill', type, 'Icon');
        icon:SetColorTone("FFFFFFFF");
        icon:ClearText();
    
    elseif category == 'Ability' then

        local abilClass = GetClassByType("Ability", type)
        local abilIES = GetAbilityIESObject(GetMyPCObject(), abilClass.ClassName);
        if abilIES == nil or HAS_ABILITY_SKILL(abilClass.ClassName) == false then
            slot:ClearIcon();
            return
        end
        imageName = abilClass.Icon;
        icon:SetTooltipType("ability");
        icon:ClearText();
        SET_ABILITY_TOGGLE_COLOR(icon, type)
    elseif category == 'Item' then
          local itemIES = GetClassByType('Item', type);
        if itemIES ~= nil then
            imageName = itemIES.Icon;
            
            local invenItemInfo = nil
            
            if iesID == "" then
                invenItemInfo = session.GetInvItemByType(type);
            else
                invenItemInfo = session.GetInvItemByGuid(iesID);
            end
            
            --시모니 스크롤이 아니고 기간제가 아닌 아이템 재검색
            if invenItemInfo == nil and itemIES.LifeTime == 0 then
                if IS_SKILL_SCROLL_ITEM(itemIES) == 0 and IS_CLEAR_SLOT_ITEM(itemIES) ~= true then
                    invenItemInfo = session.GetInvItemByType(type);
                end
            end
            
            if invenItemInfo ~= nil and invenItemInfo.type == math.floor(type) then
                itemIES = GetIES(invenItemInfo:GetObject());
                imageName = GET_ITEM_ICON_IMAGE(itemIES);
                icon:SetEnableUpdateScp('None');
                
                if itemIES.MaxStack > 0 or itemIES.GroupName == "Material" then
                    if itemIES.MaxStack > 1 then -- 개수는 스택형 아이템만 표시해주자
                        icon:SetText(invenItemInfo.count, 'quickiconfont', ui.RIGHT, ui.BOTTOM, -2, 1);
                    else
                        icon:SetText(nil, 'quickiconfont', ui.RIGHT, ui.BOTTOM, -2, 1);
                    end
                    icon:SetColorTone("FFFFFFFF");
                end
                
                tolua.cast(icon, "ui::CIcon");
                local iconInfo = icon:GetInfo();
                iconInfo.count = invenItemInfo.count;
                
                if IS_SKILL_SCROLL_ITEM(itemIES) == 1 then
                    icon:SetUserValue("IS_SCROLL", "YES")
                else
                    icon:SetUserValue("IS_SCROLL", "NO")
                end
            else
                -- 해당 아이템이 인벤토리에 없을 경우
                if IS_CLEAR_SLOT_ITEM(itemIES) then
                    -- slot을 초기화할 아이템이면 slot clear
                    CLEAR_QUICKSLOT_SLOT(slot);
                    return;
                else
                    imageName = GET_ITEM_ICON_IMAGE(itemIES);
                    icon:SetColorTone("FFFF0000");
                    icon:SetText(0, 'quickiconfont', ui.RIGHT, ui.BOTTOM, -2, 1);
                    SET_SLOT_LIFETIME_IMAGE(invenItemInfo, icon, slot, false);
                    icon:SetEnableUpdateScp('None');
                end
            end
        
        end
    end
    
    if imageName ~= "" then
        if iesID == nil then
            iesID = ""
        end
        
        local category = category;
        local type = type;
        
        slot:SetPosTooltip(0, 0);
        if category == 'Item' then
            icon:SetTooltipType('wholeitem');
            
            local invItem = nil
            
            if iesID == '0' or iesID == "" then
                invItem = session.GetInvItemByType(type);
            else
                invItem = session.GetInvItemByGuid(iesID);
            end
            
            if invItem ~= nil and invItem.type == type then
                iesID = invItem:GetIESID();
            end
            
            if invItem ~= nil then
                icon:Set(imageName, 'Item', invItem.type, invItem.invIndex, invItem:GetIESID(), invItem.count);
                
                local result = CHECK_EQUIPABLE(invItem.type);
                icon:SetEnable(1);
                icon:SetEnableUpdateScp('None');
                if result ~= "NOEQUIP" then
                    if result == 'OK' then
                        icon:SetColorTone("FFFFFFFF");
                    else
                        icon:SetColorTone("FFFF0000");
                    end
                end
                
                SET_SLOT_LIFETIME_IMAGE(invItem, icon, slot);
                ICON_SET_INVENTORY_TOOLTIP(icon, invItem, "quickslot", GetIES(invItem:GetObject()));
            else
                icon:Set(imageName, category, type, 0, iesID);
                icon:SetTooltipNumArg(type);
                icon:SetTooltipIESID(iesID);
            end
            local icon = slot:GetIcon()
            if icon ~= nil then
                
                icon:SetDumpArgNum(slot:GetSlotIndex());
            end
        else
            if category == 'Skill' then
                icon:SetTooltipType('skill');
                local skl = session.GetSkill(type);
                if skl ~= nil then
                    iesID = skl:GetIESID();
                end
            end
            
            icon:Set(imageName, category, type, 0, iesID);
            icon:SetTooltipNumArg(type);
            icon:SetTooltipStrArg("quickslot");
            icon:SetTooltipIESID(iesID);
        end
      
        
        local icon = slot:GetIcon()
        icon:SetDumpScp("EWS_ON_DUMP")
    end


end
