--companionchanger
local addonName = "COMPANIONCHANGER"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
g.version = 0
g.settings =
    g.settings or
    {
        x = 300,
        y = 300,
        style = 0,
        locked = true
    }
g.configurepattern = {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "companionchanger"
g.debug = false
g.nextfunc = nil
--ライブラリ読み込み
CHAT_SYSTEM("[CC]loaded")
local acutil = require("acutil")
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

local function DBGOUT(msg)
    EBI_try_catch {
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
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end
--マップ読み込み時処理（1度だけ）
function COMPANIONCHANGER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            acutil.setupHook(COMPANIONCHANGER_UI_TOGGLE_PETLIST, "UI_TOGGLE_PETLIST")
            acutil.setupHook(COMPANIONCHANGER_USE_COMPANION_ICON, "USE_COMPANION_ICON")

            local frame = ui.GetFrame("companionlist")
            local btn = frame:CreateOrGetControl("button", "petinfo_button", 4, 4, 60, 30)
            
            btn:SetText("Info")
            AUTO_CAST(btn)
            btn:SetEventScript(ui.LBUTTONUP, "COMPANIONCHANGER_ON_SHOW_PETINFO")
            local btnu = frame:CreateOrGetControl("button", "btnunsummon", 68, 4, 60, 30)
            
            btnu:SetText("Unsummon")
            AUTO_CAST(btnu)
            btnu:SetEventScript(ui.LBUTTONUP, "COMPANIONCHANGER_ON_UNSUMMON")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function COMPANIONCHANGER_ON_SHOW_PETINFO()
    local pet = GET_SUMMONED_PET()
    local hawk = GET_SUMMONED_PET_HAWK()
    local frame = ui.GetFrame("pet_info")
    if frame:IsVisible() == 1 then
        frame:ShowWindow(0)
        return
    end
    if pet == nil and hawk == nil then
        ui.SysMsg("No pet summoned.")
    else
        SETUP_PET_INFO(pet, hawk)
    end
end
function COMPANIONCHANGER_UI_TOGGLE_PETLIST()
    if app.IsBarrackMode() == true then
        return
    end

    if ui.CheckHoldedUI() == true then
        return
    end

    local frame = ui.GetFrame("pet_info")
    if frame:IsVisible() == 1 then
        frame:ShowWindow(0)
        local companionlist_frame = ui.GetFrame("companionlist")
        companionlist_frame:ShowWindow(0)
        local petlist_frame = ui.GetFrame("petlist")
        petlist_frame:ShowWindow(0)
        return
    end

    local pet = GET_SUMMONED_PET()
    local hawk = GET_SUMMONED_PET_HAWK()

    -- 소환된 컴패니언이 없다면 컴패니언 리스트를 연다.
    local companionlist_frame = ui.GetFrame("companionlist")
    local petlist_frame = ui.GetFrame("petlist")
    if companionlist_frame:IsVisible() == 0 or petlist_frame:IsVisible() == 0 then
        ON_OPEN_COMPANIONLIST()
        ON_OPEN_PETLIST()
    else
        -- 펫 목록이 열려있는데 한번 더 누르는 경우
        companionlist_frame:ShowWindow(0)
        petlist_frame:ShowWindow(0)
    end

 
end
function COMPANIONCHANGER_DELAY_USE_COMPANION_ICON()
    if g.nextfunc then
        local func=g.nextfunc
        g.nextfunc = nil
        func()
        
    end
end
function COMPANIONCHANGER_USE_COMPANION_ICON(parent, ctrl, argStr, argNum)
     return COMPANIONCHANGER_USE_COMPANION_ICON2(parent, ctrl, argStr, argNum)
end
function COMPANIONCHANGER_USE_COMPANION_ICON2(parent, ctrl, argStr, argNum)
    EBI_try_catch {
        try = function()
            local slot = ctrl
            tolua.cast(slot, "ui::CSlot")
            local icon = slot:GetIcon()
            if icon == nil then
                return
            end

            ui.DisableForTime(parent, 4)
            local iconInfo = icon:GetInfo()
            
            
            local petGuidStr = iconInfo:GetIESID()
            local selectedPet= session.pet.GetPetByGUID(petGuidStr );
            local coolDown = selectedPet:GetCurrentCoolDownTime()
            if(coolDown > 0) then
                ui.SysMsg("Currently cooldown.")
                return
            end
            -- 컴패니언 목록에서는 클릭으로 소환/역소환 가능.
            local summonedPet = session.pet.GetSummonedPet()
            local delay=0
            if summonedPet ~= nil then
                if summonedPet:GetStrGuid() == petGuidStr then
                    -- 소환되어 있는 컴패니언을 다시 우클릭한 컴패니언이라면 역소환한다
                    ui.SysMsg("Same pet summoned.")
                    return;
                end
               
                -- disactivate pet
                local myHandle = session.GetMyHandle();
                local haingBuff = info.GetBuffByName(myHandle, "HangingShot");
                local petInfo = session.pet.GetPetByGUID(summonedPet:GetStrGuid() );
                local obj = petInfo:GetObject();
                obj = GetIES(obj);
                local isActivated = TryGet(obj, "IsActivated");
        
                if isActivated == 1 and haingBuff == nil then
                  
                    control.SummonPet(0,0,0);  
                    delay=delay+1
                    
                end

   
            end

            -- use icon
            local type=iconInfo.type
            local iesid=iconInfo:GetIESID()
            g.nextfunc=function ()
                HOTKEY_SUMMON_COMPANION(type, iesid)
                ReserveScript("COMPANIONCHANGER_DELAY_USE_COMPANION_ICON()",1)
                g.nextfunc=function ()
                    local summonedPet = session.pet.GetSummonedPet()
                    local myHandle = session.GetMyHandle();
                    local haingBuff = info.GetBuffByName(myHandle, "HangingShot");
                    local petInfo = session.pet.GetPetByGUID(summonedPet:GetStrGuid() );
                    local obj = petInfo:GetObject();
                    obj = GetIES(obj);
                    local isActivated = TryGet(obj, "IsActivated");
                    if isActivated == 0 and haingBuff == nil then
                        control.CustomCommand("PET_ACTIVATE", 0, summonedPet:GetNeedJobID());
                    
                    end
                    local frame = ui.GetFrame("petlist");
                    UPDATE_RIDE_PETLIST(frame)
                end
            end
            ReserveScript("COMPANIONCHANGER_DELAY_USE_COMPANION_ICON()",delay)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function COMPANIONCHANGER_ON_UNSUMMON()
  
    control.SummonPet(0,0,0);  
end

