-- dbjumper
local addonName = "DBJUMPER"
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
g.framename = "dbjumper"
g.debug = false
g.currentskill = nil
g.url_base = "https://handtos.mochisuke.jp"
g.marketurl_base = "https://tosmarket.mochisuke.jp"

--ライブラリ読み込み
CHAT_SYSTEM("[DBJ]loaded")
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
local function GetRegion()
    if config.GetServiceNation() == "GLOBAL" then
        return "itos/en"
    elseif config.GetServiceNation() == "JPN" or config.GetServiceNation() == "GLOBAL_JP" then
        return "jtos/ja"
    elseif config.GetServiceNation() == "TAIWAN" then
        return "twtos/zh"
    elseif config.GetServiceNation() == "KOR" then
        return "ktos/ko"
    end
    return "itos/en"
end
local function GetDBUrl(clsid)
    return g.url_base .. "/" .. GetRegion() .. "/" .. "database/universal/" .. tostring(clsid)
end

local function GetMarketUrl(clsid)
    return g.marketurl_base .. "/byclsid/" .. tostring(clsid)
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

function DBJUMPER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
            acutil.setupHook(DBJUMPER_SLI, "SLI")
            addon:RegisterMsg("GAME_START_3SEC","DBJUMPER_3SEC")
            
            g.frame:ShowWindow(1)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DBJUMPER_3SEC()
    if (DBJUMPER_OLD_CHECK_INV_LBTN == nil and DBJUMPER_CHECK_INV_LBTN ~= CHECK_INV_LBTN) then
        DBJUMPER_OLD_CHECK_INV_LBTN = CHECK_INV_LBTN
        CHECK_INV_LBTN = DBJUMPER_CHECK_INV_LBTN
    end
end

function DBJUMPER_CHECK_INV_LBTN(frame, object, argStr, argNum)
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame("inventory")
            local targetItem = item.HaveTargetItem()

            if targetItem == 1 then
                local useItemIndex = item.GetTargetItem()
                local useItem = session.GetInvItem(useItemIndex)

                if useItem ~= nil and DBJUMPER_DOJUMP(useItem.type) == true then
                    return
                end
            end

            DBJUMPER_OLD_CHECK_INV_LBTN(frame, object, argStr, argNum)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function DBJUMPER_SLI(props, clsid)
    if DBJUMPER_DOJUMP(clsid) == false then
        SLI_OLD(props, clsid)
    end
end
function DBJUMPER_DOJUMP(clsid)
    if keyboard.IsKeyPressed("LSHIFT") == 1 and keyboard.IsKeyPressed("LALT") == 1 then
        login.OpenURL(GetDBUrl(clsid))
        CHAT_SYSTEM("[DBJ]Jump to DB")
        return true
    elseif keyboard.IsKeyPressed("RSHIFT") == 1 and keyboard.IsKeyPressed("RALT") == 1 then
        login.OpenURL(GetMarketUrl(clsid))
        CHAT_SYSTEM("[DBJ]Jump to Market DB")
        return true
    else
        return false
    end
end
