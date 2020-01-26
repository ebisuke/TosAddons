-- EnhancedWeaponSwap
local addonName = "EnhancedWeaponSwap"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

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

local function startswith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

g.debug = true
g.settings = g.settings or {}
g.waitforswapskill = nil
g.casting = false
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.restore = nil
g.wait = false
local itemdefine = {
    {Name = "weapon_unused", Type = nil, Text = "{ol}{s16}No use"},
    {Name = "weapon_OHS", Type = "OneHandSword", Text = "{img weapon_OHS 20 20}"},
    {Name = "weapon_Tsword", Type = "TwoHandSword", Text = "{img weapon_Tsword 20 20}"},
    {Name = "weapon_spear", Type = "OneHandSpear", Text = "{img weapon_spear 20 20}"},
    {Name = "weapon_bow", Type = "BowAnd", Text = "{img weapon_bow 20 20}"},
    {Name = "weapon_Tbow", Type = "TwoHandBow", Text = "{img weapon_Tbow 20 20}"},
    {Name = "Weapon_Rapier", Type = "Rapier", Text = "{img weapon_rapier 20 20}"},
    {Name = "weapon_shield", Type = "Shield", Text = "{img weapon_shield 20 20}"},
    {Name = "weapon_gun", Type = "Pistol", Text = "{img weapon_gun 20 20}"},
    {Name = "weapon_dagger", Type = "Dagger", Text = "{img weapon_dagger 20 20}"},
    {Name = "weapon_mace", Type = "OneHandMace", Text = "{img weapon_mace 20 20}"},
    --{Name="weapon_rod",Type="Rod",Text="{img weapon_rod 20 20}"},
    --{Name="weapon_staff",Type="Weapon_Staff",Text="{img weapon_staff 20 20}"},
    --{Name="weapon_companion",Type="Weapon_Companion",Text="{img weapon_companion 20 20}"},
    {Name = "weapon_Tmace", Type = "TwoHandMace", Text = "{img weapon_Tmace 20 20}"}
}
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



function EWS_HOOK()
    
    acutil.setupHook(EWS_ICON_USE_JUMPER, "ICON_USE")

-- if (OLD_QUICKSLOTNEXPBAR_SLOT_USE == nil and QUICKSLOTNEXPBAR_SLOT_USE ~= EWS_QUICKSLOTNEXPBAR_SLOT_USE) then
--     OLD_QUICKSLOTNEXPBAR_SLOT_USE = QUICKSLOTNEXPBAR_SLOT_USE
--     QUICKSLOTNEXPBAR_SLOT_USE = EWS_QUICKSLOTNEXPBAR_SLOT_USE
-- end
end

function EWS_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function EWS_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {heuristic = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    EWS_UPGRADE_SETTINGS()
    EWS_SAVE_SETTINGS()

end


function EWS_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- ライブラリ読み込み
function ENHANCEDWEAPONSWAP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            local timer = GET_CHILD(ui.GetFrame("enhancedweaponswap"), "addontimer", "ui::CAddOnTimer");
            acutil.setupHook(EWS_SKL_KEY_PRESS, "SKL_KEY_PRESS")
            
            acutil.addSysIcon("enhancedweaponswap", "sysmenu_inv", "EWS", "EWSC_TOGGLE")
            timer:SetUpdateScript("EWS_UPDATE")
            addon:RegisterMsg('GAME_START_3SEC', 'EWS_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'EWS_SHOW');
            addon:RegisterMsg('WEAPONSWAP', 'EWS_WEAPONSWAP_SWAP_UPDATE');
            addon:RegisterMsg('WEAPONSWAP_FAIL', 'EWS_WEAPONSWAP_FAIL');
            addon:RegisterMsg('WEAPONSWAP_SUCCESS', 'EWS_WEAPONSWAP_SLOT_SUCCESS');
            -- 기본 캐스팅바 (스킬시전하면 총 케스팅시간만큼 게이지가 풀로 차야 스킬시전. 조작불가)
            addon:RegisterMsg('CAST_BEGIN', 'EWS_CASTINGBAR_ON_MSG');
            addon:RegisterMsg('CAST_ADD', 'EWS_CASTINGBAR_ON_MSG');
            addon:RegisterMsg('CAST_END', 'EWS_CASTINGBAR_ON_MSG');
            
            -- 다이나믹 캐스팅바 (스킬키 누르고있는 상태에서만 게이지증가. 스킬키때면 스킬시전)
            addon:RegisterMsg('DYNAMIC_CAST_BEGIN', 'EWS_DYNAMIC_CASTINGBAR_ON_MSG');
            addon:RegisterMsg('DYNAMIC_CAST_END', 'EWS_DYNAMIC_CASTINGBAR_ON_MSG');
            timer:SetUpdateScript("EWS_ON_TIMER")
            timer:Start(0.78);
            frame:ShowWindow(1)
            EWS_LOAD_SETTINGS()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end
function EWS_SHOW()
    ui.GetFrame("enhancedweaponswap"):ShowWindow(1)
end
function EWS_WEAPONSWAP_SWAP_UPDATE()
-- local actor = GetMyActor()
-- local skillId = actor:GetUseSkill()
-- if (skillId == 0 and actor:IsSkillState() == false and g.restore) then
--     if( g.waitforswapskill)then
--         if(not g.settings.heuristic[  g.waitforswapskill])then
--             g.settings.heuristic[  g.waitforswapskill]={}
--             g.settings.heuristic[  g.waitforswapskill].ischarge=false
--             EWS_SAVE_SETTINGS()
--         end
--     end
--     -- 重複なし遅延1.5秒
--     DebounceScript("EWS_SWAPTO1", 1.5, 0)
--     DBGOUT("RESTORE")
--     --g.restore = nil
-- end
end
function EWS_WEAPONSWAP_FAIL()
    g.swapping = -1;
end
function EWS_WEAPONSWAP_SLOT_SUCCESS()
    -- local actor = GetMyActor()
    -- local skillId = actor:GetUseSkill()
    -- if (g.waitforswapskill~=nil and EWS_GETSWAP() == 2 and skillId == 0 and actor:IsSkillState() == false) then
    if (g.waitforswapskill) then
   
        ReserveScript("EWS_SKILL()",0.01)

       else        
        g.restore = nil
    end
-- else
--     g.waitforswapskill=nil;
-- end
-- g.swapping = false;
end
function EWS_SKILL()
    if (g.waitforswapskill) then
        local num=tonumber(g.waitforswapskill:sub(2))
        control.Skill(num)
        g.restore=g.waitforswapskill
    end
end
function EWS_ON_TIMER()
    EBI_try_catch{
        try = function()
            
            local actor = GetMyActor()
            local skillId = actor:GetUseSkill()
            if (skillId == 0) then
                if (g.waitforswapskill) then
                    if (not g.settings.heuristic[g.waitforswapskill]) then
                        g.settings.heuristic[g.waitforswapskill] = {}
                        g.settings.heuristic[g.waitforswapskill].ischarge = false
                        DBGOUT(tostring(g.waitforswapskill).."is non charge skill.")
                        EWS_SAVE_SETTINGS()
                    end
                end
                if(g.restore)then
                    -- 重複なし遅延1.5秒
                    DebounceScript("EWS_SWAPTO1",0.5,0)
                    DBGOUT("RESTORE")
                end
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWSC_INIT()
    
    EBI_try_catch{
        try = function()
            local frame = ui.GetFrame("enhancedweaponswapconfig")
            frame:Resize(380, 300)
            local label = frame:CreateOrGetControl("richtext", "labelprimary", 30, 80, 100, 20)
            label:SetText("{s16}{ol}Primary Weapon Type:")
            local combo = frame:CreateOrGetControl("droplist", "comboprimary", 30, 110, 100, 24)
            AUTO_CAST(combo)
            combo:ClearItems()
            combo:SetSkinName("droplist_normal")
            combo:SetSelectedScp("EWS_CONFIG_SELECTEDITEM")
            --adding
            local selectidx = 0
            for k, v in ipairs(itemdefine) do
                if (v.Name == g.settings.primary) then
                    selectidx = k - 1
                end
                combo:AddItem(k - 1, v.Text)
            end
            combo:SelectItem(selectidx)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function EWS_3SEC()
    EWS_HOOK()
end
function EWS_SHOW()
    ui.GetFrame("enhancedweaponswap"):ShowWindow(1)
end
function EWSC_TOGGLE()
    ui.ToggleFrame("enhancedweaponswapconfig")
end
function EWS_SWAPTO1()
    EWS_SWAP(1)
end
function EWS_SWAPTO2()
    EWS_SWAP(2)

end
function EWS_SWAP(swap)
    EBI_try_catch{
        try = function()
            if (g.casting == true) then
                DBGOUT("CASTING")
            elseif (g.wait) then
                else
                local actor = GetMyActor()
                local skillId = actor:GetUseSkill()
                
                g.swapping = EWS_GETSWAP();
                if (skillId == 0 and (EWS_GETSWAP() ~= swap or EWS_GETSWAP() == 0) and quickslot.IsDoingWeaponSwap() == false) then
                    --DO_WEAPON_SWAP(frame, swap)
                    quickslot.SwapWeapon()
                    g.swappingto = swap;
                    g.restore=g.waitforswapskill
                    g.waitforswapskill=nil
                else
                    DBGOUT("FAIL")
                end
            
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWS_GETSWAP()
    local frame = ui.GetFrame("inventory");
    if frame:GetUserIValue('CURRENT_WEAPON_INDEX') == 0 then
        if (GET_WEAPON_SWAP_INDEX() == 0 or GET_WEAPON_SWAP_INDEX() == 1) then
            return 1
        else
            return 2
        end
    end
    return frame:GetUserIValue('CURRENT_WEAPON_INDEX')
end
function EWS_WAIT(mode)
    g.wait = mode
end
function EWS_CONFIG_SELECTEDITEM(parent, ctrl)
    
    EBI_try_catch{
        try = function()
            AUTO_CAST(ctrl)
            g.settings.primary = itemdefine[ctrl:GetSelItemIndex() + 1].Name
            DBGOUT("SELECTED")
            EWS_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWS_ICON_USE_JUMPER(object, reAction)
    if (not EWS_ICON_USE(object, reAction)) then
        ICON_USE_OLD(object, reAction)
    end
end
function EWS_SKL_KEY_PRESS(actor, obj, dik, startDelay, pressSpd, duration, hitCancel)
    geSkillControl.KeyPress(actor, obj.type, dik, startDelay, pressSpd, duration);
    if nil ~= hitCancel and hitCancel == 1 then
        actor:SetHitCancelCast(true)
    end
    return 0, 0;
end
function EWS_ICON_USE(object, reAction)
    return EBI_try_catch{
        try = function()
            local iconPt = object;
            if iconPt ~= nil and g.settings.primary then
                local icon = tolua.cast(iconPt, 'ui::CIcon');
                
                local iconInfo = icon:GetInfo();
                if iconInfo:GetCategory() == 'Skill' then
                    -- 使用可能種別取得
                    local obj = GetClassByType("Skill", iconInfo.type)
                    if (obj.ReqObject == "None" or obj.ReqObject:find(g.settings.primary)) then
                        --swap
                        local sklProp = geSkillTable.Get(obj.ClassName);
                        if (EWS_GETSWAP() == 2) then
                            DBGOUT("IMMEDIATE")
                            control.Skill(iconInfo.type);
                            EWS_WAIT(false)
                        
                        else
                            DBGOUT("SWAP")
                            g.settings.heuristic = g.settings.heuristic or {}
                            if (g.settings.heuristic["S"..tostring(iconInfo.type)]) then
                                if (g.settings.heuristic["S"..iconInfo.type].ischarge) then
                                    DBGOUT("heuristic is IMMIDIATE")
                                    control.Skill(iconInfo.type)
                                else
                                    EWS_SWAPTO2()
                                    DBGOUT("heuristic is WAIT")
                                    g.waitforswapskill = "S"..tostring(iconInfo.type)
                                end
                            else
                                DBGOUT("heuristic is not determined")
                                g.waitforswapskill = "S"..tostring(iconInfo.type)
                                --ReserveScript("EWS_SWAPTO2()",0.01)
                                control.Skill(iconInfo.type)
                            end
                        
                        end
                        
                        return true
                    else
                        --ign
                        DBGOUT("IGN " .. obj.ReqObject)
                        return false
                    end
                else
                    return false
                end
            end
            return false
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function EWS_CASTINGBAR_ON_MSG(frame, msg, argStr, argNum)
    if msg == 'CAST_BEGIN' then -- 시전 시작
        if (g.waitforswapskill) then
            if (not g.settings.heuristic[g.waitforswapskill]) then
                g.settings.heuristic[g.waitforswapskill] = {}
                g.settings.heuristic[g.waitforswapskill].ischarge = true
                DBGOUT(tostring(g.waitforswapskill).."is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
        
        g.casting = true;
    end
    
    if msg == 'CAST_ADD' then -- 지연 및 단축 되는 시전 시간
        g.casting = true;
        if (g.waitforswapskill) then
            if (not g.settings.heuristic[g.waitforswapskill]) then
                g.settings.heuristic[g.waitforswapskill] = {}
                g.settings.heuristic[g.waitforswapskill].ischarge = true
                DBGOUT(tostring(g.waitforswapskill).."is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
    end
    
    if msg == 'CAST_END' then -- 시전이 끝난경우 메시지 처리
        if (g.waitforswapskill) then
            if (not g.settings.heuristic[g.waitforswapskill]) then
                g.settings.heuristic[g.waitforswapskill] = {}
                g.settings.heuristic[g.waitforswapskill].ischarge = true
                DBGOUT(tostring(g.waitforswapskill).."is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
        g.casting = false;
    end

end

function EWS_DYNAMIC_CASTINGBAR_ON_MSG(frame, msg, argStr, maxTime, isVisivle)
    if msg == 'DYNAMIC_CAST_BEGIN' and maxTime > 0 then -- 시전 시작
        if (g.waitforswapskill) then
            if (not g.settings.heuristic[g.waitforswapskill]) then
                g.settings.heuristic[g.waitforswapskill] = {}
                g.settings.heuristic[g.waitforswapskill].ischarge = true
                DBGOUT(tostring(g.waitforswapskill).."is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
        g.casting = true;
    end
    
    if msg == 'DYNAMIC_CAST_END' then -- 시전이 끝난경우 메시지 처리
        if (g.waitforswapskill) then
            if (not g.settings.heuristic[g.waitforswapskill]) then
                g.settings.heuristic[g.waitforswapskill] = {}
                g.settings.heuristic[g.waitforswapskill].ischarge = true
                DBGOUT(tostring(g.waitforswapskill).."is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
        g.casting = false;
    end


end
