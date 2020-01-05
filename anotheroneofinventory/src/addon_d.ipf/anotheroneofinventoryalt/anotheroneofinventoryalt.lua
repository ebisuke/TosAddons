-- Anotheroneofinventory
local addonName = "anotheroneofinventory"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

g.frame = nil
g.tick = 0
g.first = nil
g.second = nil
g.logpath = string.format('../addons/%s/log_alt.txt', addonName)
g.settingsFileLoc = string.format('../addons/%s/settings_alt.json',addonName)
g.debug = false
g.seltarget=0
g.settings=g.settings or {}
g.personalsettings = g.personalsettings or {}

g.personalsettingsFileLoc = ""
local function AUTO_CAST(ctrl)
    if(ctrl==nil)then
        trace=debug.traceback()
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
	return ctrl;
end


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
local function DrawPolyLine(pic, poly, brush, color)
    local prev = nil
    for _, v in ipairs(poly) do
        if (prev) then
            pic:DrawBrush(prev[1], prev[2], v[1], v[2], brush, color)
        end
        prev = v
    end
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

function AOI_ALT_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_alt_%s.json', addonNameLower,tostring( session.GetMySession():GetCID()))
    DBGOUT("psn"..g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end


function AOI_ALT_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {invokekey=nil}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    g.personalsettings={}
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_alt_%s.json', addonNameLower,tostring( session.GetMySession():GetCID()))
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load personal setting files', addonName))
        g.personalsettings = {}
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = 0
        end
    end
    AOI_ALT_UPGRADE_SETTINGS()
    AOI_ALT_SAVE_SETTINGS()

end


function AOI_ALT_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end



--マップ読み込み時処理（1度だけ）
function ANOTHERONEOFINVENTORYALT_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            g.frame = frame
            addon:RegisterMsg('OPEN_SELECT_TARGET', 'AOI_ALT_OPEN_SELECT_TARGET_FROM_PARTY');
            --frame:ShowWindow(0)
            g.personalsettings ={}
            AOI_ALT_LOAD_SETTINGS()
            AOI_ALT_INIT()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            g.tick = (g.tick + 1) % 100
            -- print("timer")
            if (frame:IsVisible() == 0) then
                if g.settings.invokekey~=nil and keyboard.IsKeyDown(g.settings.invokekey) == 1 and (ui.GetFocusObject() == nil or ui.GetFocusObject():GetClassString() ~= "ui::CEditControl") then
                    if (ui.IsFrameVisible("anotheroneofinventoryalt") == 0) then
                        DBGOUT("SHOW")
                        AOI_ALT_SHOW()
                    
                    end
                end
                return
            end
            if (g.seltarget ) then
                g.seltarget = g.seltarget - 1
            end
            if (mouse.IsLBtnPressed() == 0 and g.liftslot) then
                DBGOUT("LIFT END")
                
                g.liftslot = nil
            end
            if (  g.settings.invokekey~=nil and keyboard.IsKeyPressed(g.settings.invokekey) == 0 and frame:IsVisible() == 1) then
                AOI_ALT_DO()
                return
            end
            
            if (keyboard.IsKeyDown("LEFT") == 1) then
                
                if (g.first == nil) then
                    g.first = 2
                else
                    g.second = 2
                    AOI_ALT_DO()
                end
            
            end
            if (keyboard.IsKeyDown("RIGHT") == 1) then
                
                if (g.first == nil) then
                    g.first = 4
                else
                    g.second = 4
                    AOI_ALT_DO()
                end
            end
            if (keyboard.IsKeyDown("UP") == 1) then
                if (g.first == nil) then
                    g.first = 1
                else
                    g.second = 1
                    AOI_ALT_DO()
                end
            end
            if (keyboard.IsKeyDown("DOWN") == 1) then
                if (g.first == nil) then
                    g.first = 3
                else
                    g.second = 3
                    AOI_ALT_DO()
                end
            end
            local bg = frame:GetChild("bg")
            if (bg) then
                AUTO_CAST(bg)
                bg:FillClonePicture("00000000")
                local ox, oy
                local sx, sy
                
                local fx, fy
                local sx, sy
                local ox = 50 + 150
                local oy = 150 + 60
                local first, second
                first = g.first
                second = g.second
                if (first) then
                    
                    
                    if (first == 2) then
                        fx = 0 + 50
                    elseif (first == 4) then
                        fx = 450
                    else
                        fx = 200 + 50
                    end
                    if (first == 1) then
                        fy = 10
                    elseif (first == 3) then
                        fy = 210
                    else
                        fy = 110
                    end
                    if (second == 2) then
                        sx = 0 - 50
                    elseif (second == 4) then
                        sx = 150 + 50
                    else
                        sx = 75
                    end
                    if (second == 1) then
                        sy = 0 - 50
                    elseif (second == 3) then
                        sy = 70 + 50
                    else
                        sy = 35
                    end
                    DrawPolyLine(bg, {
                        {fx + ox, fy - sy + oy},
                        {fx - sx + ox, fy + oy},
                        {fx + ox, fy + sy + oy},
                        {fx + sx + ox, fy + oy},
                        {fx + ox, fy - sy + oy},
                    }, "spray_4", "FF00FF00")
                end
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function AOI_ALT_SHOW()
    EBI_try_catch{
        try = function()
            g.first = nil
            g.second = nil
            AOI_ALT_GENERATESLOTS()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            frame:ShowWindow(1)
            local edit = frame:GetChild("dummyedit")
            AUTO_CAST(edit)
            edit:Focus()
            frame:RemoveChild("bg")
            local bg = frame:CreateOrGetControl("picture", "bg", 0, 0, frame:GetWidth(), frame:GetHeight())
            AUTO_CAST(bg)
            bg:EnableHitTest(0)
            
            bg:CreateInstTexture()
            bg:FillClonePicture("00000000")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_DO()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            local slot = frame:GetChild("s" .. tostring(g.first) .. tostring(g.second))
            local edit = frame:GetChild("dummyedit")
            AUTO_CAST(edit)
            edit:ReleaseFocus()
            
            if (slot ~= nil) then
                
                AUTO_CAST(slot)
                local first, second
                local str = slot:GetName()
                first = tonumber(str:sub(2, 2))
                second = tonumber(str:sub(3, 3))
                
                local stik = AOI_STIK_LOAD(first, second)
                if (stik) then
                    if (stik.clsid and stik.clsid ~= 0) then
                        if (stik.mode == "Item") then
                            local invitem = session.GetInvItemByType(stik.clsid)
                            if (invitem == nil) then
                                invitem = session.GetInvItemByGuid(stik.iesid)
                            
                            end
                            DBGOUT("USE" .. tostring(stik.iesid))
                            if (invitem ~= nil) then
                                DBGOUT("USE" .. tostring(invitem.type))
                                INV_ICON_USE(invitem)
                            end
                        elseif (stik.mode == "Skill") then
                            local icon = slot:GetIcon()
                            local skillCls = GetClassByType("Skill", stik.clsid)
                            g.seltarget = 5
                            
                            QUICKSLOTNEXPBAR_SLOT_USE(nil, slot)
                        
                        elseif (stik.mode == "Ability") then
                            local icon = slot:GetIcon()
                            QUICKSLOTNEXPBAR_SLOT_USE(nil, slot)
                        end
                    end
                end
            end
            
            frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
            frame:ShowWindow(0)
        end
    }
end
function AOI_ALT_OPEN_SELECT_TARGET_FROM_PARTY(frame, msg, argStr, showHPGauge)
    EBI_try_catch{
        try = function()
            if (not g.seltarget or g.seltarget<=0) then
                print("BYE")
                geSkillControl.SetPartyMemberTarget(1, nil, argStr);
                geSkillControl.SetPartyMemberTarget(2, nil, argStr);
                geSkillControl.SetPartyMemberTarget(3, nil, argStr);
                geSkillControl.SetPartyMemberTarget(4, nil, argStr);
                geSkillControl.SetPartyMemberTarget(5, nil, argStr);
                return
            end
            print("ON")
            g.seltarget = 0
            frame=ui.GetFrame('party_recommend');   
            frame:ShowWindow(1);
            geSkillControl.SetPartyMemberTarget(1, session.loginInfo.GetAID(), argStr);
            geSkillControl.SetPartyMemberTarget(2, session.loginInfo.GetAID(), argStr);
            geSkillControl.SetPartyMemberTarget(3, session.loginInfo.GetAID(), argStr);
            geSkillControl.SetPartyMemberTarget(4, session.loginInfo.GetAID(), argStr);
            geSkillControl.SetPartyMemberTarget(5, session.loginInfo.GetAID(), argStr);
            geSkillControl.CheckDistancePartyMemberTarget();
          
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_INIT()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            local timer = GET_CHILD(frame, "aoi_addontimer", "ui::CAddOnTimer");
            AUTO_CAST(timer)
            timer:SetUpdateScript("AOI_ALT_ON_TIMER");
            timer:EnableHideUpdate(1)
            timer:Start(0.01);
            
            frame:EnableMove(0)
            frame:SetSkinName("None")
            frame:EnableHittestFrame(0)
            frame:EnableHideProcess(1);
            --frame:EnableDrawFrame(1)
            frame:SetOffset(1920 / 2 - 450, 1080 / 2 - 350)
            frame:Resize(900, 700)
            
            
            
            local edit = frame:CreateOrGetControl("edit", "dummyedit", 0, 0, 0, 0)
            AUTO_CAST(edit)
            edit:SetNumberMode(1)
        
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_GENERATESLOTS()
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")

            
            for first = 1, 4 do
                
                local fx, fy
                local sx, sy
                sx = 0
                sy = 0
                
                for second = 1, 4 do
                    local stik = AOI_STIK_LOAD(first, second)
                    
                    
                    if (first == 2) then
                        fx = 100
                    elseif (first == 4) then
                        fx = 500
                    else
                        fx = 300
                    end
                    if (first == 1) then
                        fy = 10
                    elseif (first == 3) then
                        fy = 210
                    else
                        fy = 110
                    end
                    if (second == 2) then
                        sx = 0
                    elseif (second == 4) then
                        sx = 150
                    else
                        sx = 75
                    end
                    if (second == 1) then
                        sy = 0
                    elseif (second == 3) then
                        sy = 70
                    else
                        sy = 35
                    end
                    local slot = frame:CreateOrGetControl("slot", "s" .. tostring(first) .. tostring(second),
                        fx + sx + 50, fy + sy + 150, 50, 50)
                    AUTO_CAST(slot)
                    
                    if (stik and stik.clsid) then
                        local type = stik.clsid
                        local iesID = stik.iesid
                        local icon = ui.CIcon:new()
                        local category = stik.category
                        local imageName = stik.imageName
                        icon:Set(imageName, category, type, 0, iesID);
                        QUICKSLOT_MAKE_GAUGE(slot)
                        AOI_SET_QUICK_SLOT(slot, icon, type, iesID)
                    
                    else
                        slot:RemoveAllChild()
                        slot:ClearIcon()
                        
                        slot:ReleaseBlink();
                        slot:SetText("")
                        slot:SetSkinName("invenslot2")
                    end
                    slot:EnableDrag(1)
                    slot:EnableDrop(1)
                    slot:EnablePop(1)
                    slot:SetSkinName("invenslot2")
                    slot:SetEventScript(ui.DROP, "AOI_ALT_ONDROP")
                    slot:SetEventScript(ui.LBUTTONDOWN, "AOI_ALT_ONLIFT")
                    slot:SetColorTone("99FFFFFF")
                end
            end
        
        
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_QUICKSLOTNEXPBAR_DUMPICON(frame, control, argStr, argNum)
    EBI_try_catch{
        try = function()
            local icon = AUTO_CAST(control);
            local slot = GET_PARENT(icon);
            slot:ReleaseBlink();
            slot:ClearIcon();
            QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
            
            
            --save
            local first, second
            
            first = slot:GetName():sub(2, 2)
            second = slot:GetName():sub(3, 3)
            if (slot:GetIcon()) then
                local info = slot:GetIcon():GetInfo()
                local category = info:GetCategory()
                AOI_STIK_SAVE(first, second,
                    {
                        mode = category,
                        clsid = info.type,
                        iesid = info:GetIESID(),
                        category=category,
                        imageName = info.imageName
                    })
            else
                AOI_STIK_SAVE(first, second,
                    {})
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_SET_QUICK_SLOT(slot, lifticon, type, iesID)
    if frame ~= nil and session.GetSkill(type) ~= nil and is_contain_skill_icon(frame, type) == true then
        return
    end
    local info = lifticon:GetInfo()
    local category = info:GetCategory()
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
            QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
            return;
        end
        imageName = 'icon_' .. GetClassString('Skill', type, 'Icon');
        icon:SetOnCoolTimeUpdateScp('ICON_UPDATE_SKILL_COOLDOWN');
        icon:SetEnableUpdateScp('ICON_UPDATE_SKILL_ENABLE');
        icon:SetColorTone("FFFFFFFF");
        icon:ClearText();
    
    elseif category == 'Ability' then
        QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
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
        QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0); --퀵슬롯에 놓는 것이 아이템이면 게이지를 무조건 안보이게 함
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
            
            ICON_SET_ITEM_COOLDOWN_OBJ(icon, itemIES);
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
        
        local isLockState = quickslot.GetLockState();
        if isLockState == 1 then
            slot:EnableDrag(0);
        else
            slot:EnableDrag(1);
        end
        
        icon:SetOnCoolTimeEndScp('ICON_ON_COOLTIMEEND');
        icon:SetDumpScp('AOI_ALT_QUICKSLOTNEXPBAR_DUMPICON');
        slot:SetEventScript(ui.RBUTTONUP, 'QUICKSLOTNEXPBAR_SLOT_USE');
        
        local icon = slot:GetIcon()
        if icon ~= nil then
            
            icon:SetDumpArgNum(slot:GetSlotIndex());
        end
    else
        slot:EnableDrag(0);
    end
    
    if category == 'Skill' then
        SET_QUICKSLOT_OVERHEAT(slot);
        SET_QUICKSLOT_TOOLSKILL(slot);
    end

    slot:SetEventScript(ui.DROP, "AOI_ALT_ONDROP")
    slot:SetEventScript(ui.LBUTTONDOWN, "AOI_ALT_ONLIFT")
end

function AOI_ALT_GENERATESLOT(slot, liftIcon)
    EBI_try_catch{
        try = function()
            DBGOUT("drop")
            local iconInfo = liftIcon:GetInfo()
            local imageName = iconInfo.imageName
            local clsid = iconInfo.type
            local iesid = iconInfo:GetIESID()
            QUICKSLOT_MAKE_GAUGE(slot)
            AOI_SET_QUICK_SLOT(slot, liftIcon, clsid, iesid)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_ONDROP(frame, slot, argstr, argnum)
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("anotheroneofinventoryalt")
            AUTO_CAST(slot)
            
    
            AOI_ALT_GENERATESLOT(slot, ui.GetLiftIcon())
            --save
            local first, second
            first = slot:GetName():sub(2, 2)
            second = slot:GetName():sub(3, 3)
            if (slot:GetIcon()) then
                local info = slot:GetIcon():GetInfo()
                local category = info:GetCategory()
                AOI_STIK_SAVE(first, second,
                    {
                        mode = category,
                        clsid = info.type,
                        iesid = info:GetIESID(),
                        category=category,
                        imageName = info.imageName
                    })
            end
            g.liftslot = nil
            
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function AOI_ALT_ONLIFT(frame, ctrl)
    g.liftslot = ctrl
end
function AOI_STIK_SAVE(first, second, tbl)
    g.personalsettings = g.personalsettings 
    
    g.personalsettings["L" .. tostring(first)] = g.personalsettings["L" .. tostring(first)] or {}
    g.personalsettings["L" .. tostring(first)]["L" .. tostring(second)] = tbl
    AOI_ALT_SAVE_SETTINGS()
end
function AOI_STIK_LOAD(first, second)
    g.personalsettings = g.personalsettings 
    if not g.personalsettings["L" .. tostring(first)] then
        return nil
    end
    return g.personalsettings["L" .. tostring(first)]["L" .. tostring(second)]
end

