--hideweapon
--アドオン名（大文字）
local addonName = "hideweapon"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
g.version = 0
g.framename = "hideweapon"
g.debug = false

g.personalsettingsFileLoc = ""
g.personalsettings = {
    LHPic=true,RHPic=true
    }
--ライブラリ読み込み
CHAT_SYSTEM("[HW]loaded")
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



function HIDEWEAPON_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, tostring(session.GetMySession():GetCID()))
            addon:RegisterMsg('FPS_UPDATE', 'HIDEWEAPON_FPS_UPDATE');
            addon:RegisterMsg('GAME_START_3SEC', 'HIDEWEAPON_3SEC');
            addon:RegisterMsg('EQUIP_ITEM_LIST_UPDATE', 'HIDEWEAPON_UPDATE_EQUIP');
            local timer = frame:CreateOrGetControl("addontimer", "addontimer", 0, 0, 10, 10)
            AUTO_CAST(timer)
            HIDEWEAPON_LOAD()
            timer:SetUpdateScript("HIDEWEAPON_TIMER")
            timer:Start(0.01)
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function HIDEWEAPON_LOAD()
    g.personalsettings = {}
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower, session.GetMySession():GetCID())
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load personal setting files', addonName))
        g.personalsettings = {
            LHPic=true,RHPic=true
        }
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = 0
        
        end
    end
end
function HIDEWEAPON_SAVE()
    g.personalsettingsFileLoc = string.format(
        '../addons/%s/settings_%s.json',
        addonNameLower,
        tostring(
            session.GetMySession():GetCID()))
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end
function HIDEWEAPON_FPS_UPDATE()
    g.frame:ShowWindow(1)
end
function HIDEWEAPON_3SEC()
    EBI_try_catch{
        try = function()
            
            
            
            local frame = ui.GetFrame("inventory")
            
            local framec = ui.GetFrame("hideweapon")
            local slotRH = frame:GetChildRecursively("RH")
            local slotLH = frame:GetChildRecursively("LH")
            
            local btnRH = slotRH:CreateOrGetControl("picture", "RHPic", 0, 0, 20, 20)
            btnRH:SetEventScript(ui.LBUTTONUP, "HIDEWEAPONINV_VISIBLE_STATE_SET")
            local btnLH = slotLH:CreateOrGetControl("picture", "LHPic", 0, 0, 20, 20)
            btnLH:SetEventScript(ui.LBUTTONUP, "HIDEWEAPONINV_VISIBLE_STATE_SET")
            HIDEWEAPON_UPDATE_BUTTON()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }

end
function HIDEWEAPON_UPDATE_BUTTON()
    local frame = ui.GetFrame("inventory")
            
    local framec = ui.GetFrame("hideweapon")
    local slotRH = frame:GetChildRecursively("RH")
    local slotLH = frame:GetChildRecursively("LH")
    
    local btnRH = slotRH:CreateOrGetControl("picture", "RHPic", 0, 0, 20, 20)
    local btnLH = slotLH:CreateOrGetControl("picture", "LHPic", 0, 0, 20, 20)
    AUTO_CAST(btnRH)
    AUTO_CAST(btnLH)
    
    btnRH:SetGravity(ui.RIGHT, ui.TOP)
    btnRH:SetMargin(0, 0, 0, 0)
    btnLH:SetGravity(ui.RIGHT, ui.TOP)
    btnLH:SetMargin(0, 0, 0, 0)
    
    
    
    if not   g.personalsettings.LHPic then
        btnLH:SetImage("inventory_hat_layer_off")
    
    else
        btnLH:SetImage("inven_hat_layer_on")
    end
    
    if not  g.personalsettings.RHPic then
        btnRH:SetImage("inventory_hat_layer_off")
    
    else
        btnRH:SetImage("inven_hat_layer_on")
    
    end

end
function HIDEWEAPONINV_VISIBLE_STATE_SET(_, ctrl)
    if ctrl:GetName() == "LHPic" then
        if g.personalsettings.LHPic then
            g.personalsettings.LHPic = nil
        else
            g.personalsettings.LHPic = true
        end
    
    end
    if ctrl:GetName() == "RHPic" then
        if g.personalsettings.RHPic then
            g.personalsettings.RHPic = nil
        else
            g.personalsettings.RHPic = true
        end
    
    end
    HIDEWEAPON_UPDATE_BUTTON()
end

function HIDEWEAPON_UPDATE_EQUIP()
    HIDEWEAPON_HIDE_EQUIP()
end
function HIDEWEAPON_UPDATE_EQUIP()
    HIDEWEAPON_HIDE_EQUIP()
end
function HIDEWEAPON_TIMER()
    HIDEWEAPON_HIDE_EQUIP()
end
function HIDEWEAPON_HIDE_EQUIP()
    if not  g.personalsettings.LHPic then
        local actor = GetMyActor()
        actor:ChangeEquipNode(EmAttach.eLHand, "");

    else
        local actor = GetMyActor()
        actor:ChangeEquipNode(EmAttach.eLHand, "Dummy_L_HAND");

    end
    if not  g.personalsettings.RHPic then
        local actor = GetMyActor()
        actor:ChangeEquipNode(EmAttach.eRHand, "");

    else
        local actor = GetMyActor()
        actor:ChangeEquipNode(EmAttach.eRHand, "Dummy_Sword");

    end
end
