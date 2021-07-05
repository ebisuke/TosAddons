-- rppotion
local addonName = "RPPOTION"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
local json = require "json_imc"
local libsearch
libsearch = libsearch or LIBITEMSEARCHER_V1_0 --dummy

g.version = 1
g.settings = g.settings or {}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "rppotion"
g.debug = false
--ライブラリ読み込み
CHAT_SYSTEM("[RPP]loaded")
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
local function AUTO_CAST(ctrl)
    if (ctrl == nil) then
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
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

function RPPOTION_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            addon:RegisterMsg("GAME_START_3SEC","RPPOTION_3SEC")
            
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function RPPOTION_3SEC()
    if (RPPOTION_OLD_INV_ICON_USE == nil and RPPOTION_INV_ICON_USE ~= INV_ICON_USE) then
        RPPOTION_OLD_INV_ICON_USE = INV_ICON_USE
        INV_ICON_USE = RPPOTION_INV_ICON_USE
    end
end

function RPPOTION_INV_ICON_USE(invItem)
    EBI_try_catch {
        try = function()

            if nil == invItem then
                return;
            end
            
            local mat_class_name = TryGetProp(item_obj, 'ClassName', 'None')
            local name_list = shared_item_relic.get_rp_material_name_list()
            local mat_index = table.find(name_list, mat_class_name)
            if mat_index <= 0 then
                return RPPOTION_OLD_INV_ICON_USE(invItem)
            end

            if true == invItem.isLockState then
                ui.SysMsg(ClMsg("MaterialItemIsLock"));
                return;
            end
        
            if true == RUN_CLIENT_SCP(invItem) then
                return;
            end
            
            local stat = info.GetStat(session.GetMyHandle());		
            if stat.HP <= 0 then
                return;
            end
            
            local itemtype = invItem.type;
            local curTime = item.GetCoolDown(itemtype);
            if curTime ~= 0 then
                imcSound.PlaySoundEvent("skill_cooltime");
                return;
            end
            session.ResetItemList()
            session.AddItemID(invItem:GetIESID(), 1)
            local result_list = session.GetItemIDList()

	        item.DialogTransaction('RELIC_CHARGE_RP', result_list)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

