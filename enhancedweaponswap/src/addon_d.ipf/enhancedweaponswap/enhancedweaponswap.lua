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
g.settings=g.settings or {}
g.waitforswapskill=nil
g.settings.primary=nil
g.retain=nil
local itemdefine={
    {Name="weapon_unused",Type=nil,Text="{ol}{s16}No use"},
    {Name="weapon_OHS",Type="OneHandSword",Text="{img weapon_OHS 20 20}"},
    {Name="weapon_Tsword",Type="TwoHandSword",Text="{img weapon_Tsword 20 20}"},
    {Name="weapon_spear",Type="OneHandSpear",Text="{img weapon_spear 20 20}"},
    {Name="weapon_bow",Type="BowAnd",Text="{img weapon_bow 20 20}"},
    {Name="weapon_Tbow",Type="TwoHandBow",Text="{img weapon_Tbow 20 20}"},
    {Name="Weapon_Rapier",Type="Rapier",Text="{img weapon_rapier 20 20}"},
    {Name="weapon_shield",Type="Shield",Text="{img weapon_shield 20 20}"},
    {Name="weapon_gun",Type="Pistol",Text="{img weapon_gun 20 20}"},
    {Name="weapon_dagger",Type="Dagger",Text="{img weapon_dagger 20 20}"},
    {Name="weapon_mace",Type="OneHandMace",Text="{img weapon_mace 20 20}"},
    --{Name="weapon_rod",Type="Rod",Text="{img weapon_rod 20 20}"},
    --{Name="weapon_staff",Type="Weapon_Staff",Text="{img weapon_staff 20 20}"},
    --{Name="weapon_companion",Type="Weapon_Companion",Text="{img weapon_companion 20 20}"},
    {Name="weapon_Tmace",Type="TwoHandMace",Text="{img weapon_Tmace 20 20}"}
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


-- ライブラリ読み込み
function ENHANCEDWEAPONSWAP_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            local timer = GET_CHILD(ui.GetFrame("enhancedweaponswap"), "addontimer", "ui::CAddOnTimer");
            acutil.addSysIcon("enhancedweaponswap", "sysmenu_inv", "EWS", "EWSC_TOGGLE")  
            timer:SetUpdateScript("EWS_UPDATE")
            addon:RegisterMsg('GAME_START_3SEC', 'EWS_3SEC');
            addon:RegisterMsg('FPS_UPDATE', 'EWS_SHOW');
            addon:RegisterMsg('WEAPONSWAP', 'EWS_WEAPONSWAP_SWAP_UPDATE');
            addon:RegisterMsg('WEAPONSWAP_FAIL', 'EWS_WEAPONSWAP_FAIL');
            addon:RegisterMsg('WEAPONSWAP_SUCCESS', 'EWS_WEAPONSWAP_SLOT_SUCCESS');
            timer:SetUpdateScript("EWS_ON_TIMER")
            timer:Start(0.01);
            frame:ShowWindow(1)
        
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

end
function EWS_WEAPONSWAP_FAIL()
    g.waitforswapskill=nil
end
function EWS_WEAPONSWAP_SLOT_SUCCESS()
    if( g.waitforswapskill)then
        control.Skill( g.waitforswapskill);
        g.retain= g.waitforswapskill
        g.waitforswapskill=nil
        
    end
end
function EWS_ON_TIMER()
    EBI_try_catch{
        try = function()
            if(g.retain)then
                local actor=GetMyActor()
                local skillId =  actor:GetUseSkill()
                if(skillId~=g.retain)then
                    
                   --ReserveScript("quickslot.SwapWeapon()",0.01)
                    g.retain=nil
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
            local frame=ui.GetFrame("enhancedweaponswapconfig")
            frame:Resize(380,300)
            local label=frame:CreateOrGetControl("richtext","labelprimary",30,80,100,20)
            label:SetText("{s16}{ol}Primary Weapon Type:")
            local combo=frame:CreateOrGetControl("droplist","comboprimary",30,110,100,24)
            AUTO_CAST(combo)
            combo:ClearItems()
            combo:SetSkinName("droplist_normal")
            combo:SetSelectedScp("EWS_CONFIG_SELECTEDITEM")
            --adding 
            local selectidx=0
            for k,v in ipairs(itemdefine) do
                if(v.Name==g.settings.primary) then
                    selectidx=k-1
                end
                combo:AddItem(k-1,v.Text)
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

function EWS_CONFIG_SELECTEDITEM(parent,ctrl)
   
    EBI_try_catch{
        try = function()
            AUTO_CAST(ctrl)
            g.settings.primary=itemdefine[ctrl:GetSelItemIndex()+1].Name
            DBGOUT("SELECTED")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWS_ICON_USE_JUMPER(object, reAction)
    if(not EWS_ICON_USE(object,reAction))then
         ICON_USE_OLD(object, reAction)
    end
end

function EWS_ICON_USE(object, reAction)
    local iconPt = object;
    if iconPt  ~=  nil then
        local icon = tolua.cast(iconPt, 'ui::CIcon');
		
        local iconInfo = icon:GetInfo();
        if iconInfo:GetCategory() == 'Skill' then
            -- 使用可能種別取得
            local obj=GetClassByType("Skill",iconInfo.type)
            if(obj.ReqObject == "None" or  obj.ReqObject:find(g.settings.primary))then
                --swap
                --ReserveScript("quickslot.SwapWeapon()",0.01)
                g.waitforswapskill=iconInfo.type
                return true
            else
                --ign
                return false
            end
        else
            return false
        end
    end
    return false
end