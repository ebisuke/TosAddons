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
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
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

-----------------------------------------------------------------------------------------------
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

local special = {
    [1000001] = {text = "purple1", category = "Special", icon = "ews_purple_1", clsid = 1000001},
    [2000001] = {text = "yellow1", category = "Special", icon = "ews_yellow_1", clsid = 2000001},
    [3000001] = {text = "red1", category = "Special", icon = "ews_red_1", clsid = 3000001},
    [4000001] = {text = "blue1", category = "Special", icon = "ews_blue_1", clsid = 4000001},
    [5000001] = {text = "green1", category = "Special", icon = "ews_green_1", clsid = 5000001},
}
local iconcategorylist = {"Skill", "Item", "Ability", "Special"}
local chain = {
        
        --templateには暗黙的にname,viewnameがつきます
        trigger = {
            -- any percel(skill)
            any = {text = "Any", icon = nil, fnconfig = EWS_GENERATECONFIGVIEW_SKILL, template = {}, fntostring = function(data) return "Any:" + data.category + ":" + data.clsid end,
                category = "",
            },
            
            -- Specified percel(skill)
            skill = {text = "Specified Skill", icon = nil, fnconfig = EWS_GENERATECONFIGVIEW_SPECIFIEDSKILL, fntostring = function(data) return "SpecialSkill:" + tostring(data.clsid) end, template = {
                clsid = {},
            }
            },
            -- Specified percel(skill)
            special = {text = "Special Icon", icon = nil, fnconfig = EWS_GENERATECONFIGVIEW_SPECIAL, fntostring = function(data) return "Skill:" + tostring(data.clsid) end, template = {
                clsid = {},
            }
            },
            -- keyboard percel(key)
            keyboard = {text = "Keyboard", icon = nil, fnconfig = EWS_GENERATECONFIGVIEW_KEYBOARD, fntostring = function(data) return "Keyboard:" + tostring(data.key) end, template = {
                key = ""
            }},
            -- joystick percel(key)
            joystick = {text = "Joystick", icon = nil, fnconfig = EWS_GENERATECONFIGVIEW_JOYSTICK, fntostring = function(data) return "Joystick:" + tostring(data.key) end, template = {
                key = ""
            }},
        
        },
        condition = {
            always = {text = "Always True", icon = nil, fncondition = function() return true end, fnconfig = nil, template = {
                
                }},
            exactweapontype = {text = "Skill's weapontype is...", icon = nil, fncondition = EWS_CONDITION_EXACTWEAPONTYPE, fnconfig = EWS_GENERATECONFIGVIEW_WEAPONTYPE, template = {
                weapontype = ""
            }},
            canuseweapontype = {text = "Skill can use ...", icon = nil, fncondition = EWS_CONDITION_CANUSEWEAPONTYPE, fnconfig = EWS_GENERATECONFIGVIEW_WEAPONTYPE, template = {
                weapontype = ""
            }},
            lua = {text = "Lua", icon = nil, fncondition = EWS_CONDITION_LUA, fnconfig = EWS_GENERATECONFIGVIEW_LUA, template = {
                code = ""
            }},
        
        },
        action = {
            nop = {text = "No op", icon = nil, fnaction = function() return true end, fnconfig = nil, color = "FFFFFF", template = {
                }},
            doperformedskill = {text = "Do performed skill", icon = nil, fnaction = EWS_ACTION_DOPERFORMEDSKILL, fnconfig = nil, color = "FFFFFF", template = {
                heuristicswap = false,
                clsid = 0
            }},
            doskill = {text = "Do skill", icon = nil, fnaction = EWS_ACTION_DOSKILL, fnconfig = EWS_GENERATECONFIGVIEW_DOSKILL, color = "FFFFFF", template = {
                heuristicswap = false,
                clsid = 0
            }},
            say = {text = "Say", icon = nil, fnaction = EWS_ACTION_SAY, fnconfig = EWS_GENERATECONFIGVIEW_SAY, color = "FFFFFF", template = {
                text = ""
            }},
            use = {text = "Use Item", icon = nil, fnaction = EWS_ACTION_USE, fnconfig = EWS_GENERATECONFIGVIEW_USE, color = "FFFFFF", template = {
                clsid = {},
            }},
            swap = {text = "Swap Weapon", icon = nil, fnaction = EWS_ACTION_SWAPWEAPON, fnconfig = EWS_GENERATECONFIGVIEW_SWAPWEAPON, color = "FFFFFF", template = {
                text = ""
            }},
            wait = {text = "Wait", icon = nil, fnaction = EWS_ACTION_WAIT, fnconfig = EWS_GENERATECONFIGVIEW_WAIT, color = "FFFFFF", template = {
                
                }},
            lua = {text = "Lua", icon = nil, fnaction = EWS_ACTION_LUA, fnconfig = EWS_GENERATECONFIGVIEW_LUA, color = "FFFFFF", template = {
                code = ""
            }},
        
        },
}
local function getchain(name) 
    for k,v in pairs(chain.trigger)do
        if k==name then
            return v
        end
    end
    for k,v in pairs(chain.condition)do
        if k==name then
            return v
        end
    end    
    for k,v in pairs(chain.action)do
        if k==name then
            return v
        end
    end
    return {}
end

-----------------------------------------------------------------------------------------------
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

end

function EWS_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, session.GetMySession():GetCID())
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
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
    g.personalsettings = {}
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, session.GetMySession():GetCID())
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load personal setting files', addonName))
        g.personalsettings = {
            combos = {}
        }
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = 0
        
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
            timer:Start(0.01);
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

end
function EWS_WEAPONSWAP_FAIL()
    g.swapping = -1;
end
function EWS_WEAPONSWAP_SLOT_SUCCESS()
    
    if (g.waitforswapskill) then
        
        ReserveScript("EWS_SKILL()", 0.01)
    
    else
        g.restore = nil
    end

end
function EWS_SKILL()
    if (g.waitforswapskill) then
        local num = tonumber(g.waitforswapskill:sub(2))
        control.Skill(num)
        g.restore = g.waitforswapskill
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
                        DBGOUT(tostring(g.waitforswapskill) .. "is non charge skill.")
                        EWS_SAVE_SETTINGS()
                    end
                end
                if (g.restore) then
                    -- 重複なし遅延2秒
                    EWS_SWAPTO1()
                    
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
            local listaction = gbox:CreateOrGetControl("listbox", "action", 490, 40, 230,  gbox:GetHeight() - 150)
            AUTO_CAST(listaction)

            gbox:EnableHittestGroupBox(true)
            gbox:EnableHitTest(1)
            gbox:EnableScrollBar(1)
            gbox:SetSkinName("None")

            local gconfig = frame:CreateOrGetControl("groupbox", "gconfig", 50, gbox:GetHeight() - 230+230, 730, 180)

            AUTO_CAST(gconfig)
            gconfig:EnableHittestGroupBox(true)
            gconfig:EnableHitTest(1)
            gconfig:EnableScrollBar(1)
            gconfig:SetSkinName("bg2")
            listtrigger:SetEventScript(ui.LBUTTONUP,"EWS_TRIGGER_ONSELECTED")

            listcondition:SetEventScript(ui.LBUTTONUP,"EWS_CONDITION_ONSELECTED")
            listaction:SetEventScript(ui.LBUTTONUP,"EWS_ACTION_ONSELECTED")
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
            btnaddtrigger:SetEventScript(ui.LBUTTONUP, "EWS_ONBUTTON_ADDTRIGGER")
            btnaddtrigger:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
            local btndeltrigger = gbox:CreateOrGetControl("button", "btndeltrigger", 50, 0, 40, 40)
            AUTO_CAST(btndeltrigger)
            btndeltrigger:SetSkinName("test_pvp_btn")
            btndeltrigger:SetText("{s24}{ol}-")
            local btnaddcondition = gbox:CreateOrGetControl("button", "btnaddcondition", 260, 0, 40, 40)
            AUTO_CAST(btnaddcondition)
            btnaddcondition:SetSkinName("test_pvp_btn")
            btnaddcondition:SetText("{s24}{ol}+")
            btnaddcondition:SetEventScript(ui.LBUTTONUP, "EWS_ONBUTTON_ADDCONDITION")
            btnaddcondition:SetEventScriptArgNumber(ui.LBUTTONUP, 0);
            local btndelcondition = gbox:CreateOrGetControl("button", "btndelcondition", 300, 0, 40, 40)
            AUTO_CAST(btndelcondition)
            btndelcondition:SetSkinName("test_pvp_btn")
            btndelcondition:SetText("{s24}{ol}-")
            local btnaddaction = gbox:CreateOrGetControl("button", "btnaddaction", 500, 0, 40, 40)
            AUTO_CAST(btnaddaction)
            btnaddaction:SetSkinName("test_pvp_btn")
            btnaddaction:SetText("{s24}{ol}+")
            btnaddaction:SetEventScript(ui.LBUTTONUP, "EWS_ONBUTTON_ADDACTION")
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
function EWS_ONBUTTON_ADDTRIGGER(frame, ctrl, argstr, argnum)
    EBI_try_catch{
        try = function()
            local context = ui.CreateContextMenu("EWS_CONTEXT", "Triggers", 0, 0, 300,
                100)
            for k, v in pairs(chain.trigger) do
                
                ui.AddContextMenuItem(context, v.text, "EWS_ADDTRIGGER('" .. tostring(k) .. "')")
            end
            
            context:Resize(300, context:GetHeight())
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function EWS_ONBUTTON_ADDCONDITION(frame, ctrl, argstr, argnum)
    local context = ui.CreateContextMenu("EWS_CONTEXT", "Conditions", 0, 0, 300,
        100)
    for k, v in pairs(chain.condition) do
        
        ui.AddContextMenuItem(context, v.text, "EWS_ADDCONDITION('" .. tostring(k) .. "')")
    end
    
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)
end
function EWS_ONBUTTON_ADDACTION(frame, ctrl, argstr, argnum)
    local context = ui.CreateContextMenu("EWS_CONTEXT", "Actions", 0, 0, 300,
        100)
    for k, v in pairs(chain.action) do
        
        ui.AddContextMenuItem(context, v.text, "EWS_ADDACTION('" .. tostring(k) .. "')")
    end
    
    context:Resize(300, context:GetHeight())
    ui.OpenContextMenu(context)
end
function EWS_TRIGGER_ONSELECTED(frame,ctrl)
    AUTO_CAST(ctrl)
    local idx=ctrl:GetSelItemIndex()
    if(idx==-1) then
        return
    end
    idx=idx+1
 
    EWS_INITCONFIG(g.personalsettings.combos[idx].trigger)
end
function EWS_INITCONFIG(data)
    local frame=ui.GetFrame("enhancedweaponswapconfig")
    local gconfig=frame:GetChild("gconfig")
    AUTO_CAST(gconfig)
    if( getchain(data.name).fnconfig~=nil)then
        getchain(data.name).fnconfig(gconfig,data)
    end
end
function EWS_ADDTRIGGER(txt)
    EBI_try_catch{
        try = function()
            print(txt)
            g.personalsettings.combos[#g.personalsettings.combos + 1].trigger = deepcopy(chain.trigger[txt].template) or {}
            g.personalsettings.combos[#g.personalsettings.combos].trigger.name = txt
            EWSC_INITTREE()
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

 
        listtrigger:AddItem(getchain(v.name).text,k-1 );
        DBGOUT(v.name)
    end
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
                    g.restore = g.waitforswapskill
                    g.waitforswapskill = nil
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
                            if (g.settings.heuristic["S" .. tostring(iconInfo.type)]) then
                                if (g.settings.heuristic["S" .. iconInfo.type].ischarge) then
                                    DBGOUT("heuristic is IMMIDIATE")
                                    control.Skill(iconInfo.type)
                                else
                                    EWS_SWAPTO2()
                                    DBGOUT("heuristic is WAIT")
                                    g.waitforswapskill = "S" .. tostring(iconInfo.type)
                                end
                            else
                                DBGOUT("heuristic is not determined")
                                g.waitforswapskill = "S" .. tostring(iconInfo.type)
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
                DBGOUT(tostring(g.waitforswapskill) .. "is charge skill.")
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
                DBGOUT(tostring(g.waitforswapskill) .. "is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
    end
    
    if msg == 'CAST_END' then -- 시전이 끝난경우 메시지 처리
        if (g.waitforswapskill) then
            if (not g.settings.heuristic[g.waitforswapskill]) then
                g.settings.heuristic[g.waitforswapskill] = {}
                g.settings.heuristic[g.waitforswapskill].ischarge = true
                DBGOUT(tostring(g.waitforswapskill) .. "is charge skill.")
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
                DBGOUT(tostring(g.waitforswapskill) .. "is charge skill.")
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
                DBGOUT(tostring(g.waitforswapskill) .. "is charge skill.")
                EWS_SAVE_SETTINGS()
            end
        end
        g.casting = false;
    end


end
function EWS_GENERATECONFIGVIEW_SPECIFIEDSKILL(gconfig,data)
    local slot=gconfig:CreateOrGetControl("slot","skillslot",20,20,60,60)

end
