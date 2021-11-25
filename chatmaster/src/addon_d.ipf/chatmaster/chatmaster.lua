--chatmaster
local addonName = "chatmaster"
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
g.settings = {x = 300, y = 300, isopen = false}
g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "chatmaster"
g.debug = false

--ライブラリ読み込み
CHAT_SYSTEM("[ChatMaster]loaded")
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

function CHATMASTER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            local addontimer = frame:GetChild("addontimer")
            g.frame:ShowWindow(1)
            g.frame:SetOffset(0, 0)
            --addon:RegisterMsg('GAME_START_3SEC', 'CHATMASTER_INITFRAME')
            --acutil.setupHook(CHATMASTER_REQ_PVP_MINE_SHOP_OPEN,"REQ_PVP_MINE_SHOP_OPEN")
            
            addon:RegisterMsg("GAME_START_3SEC", "CHATMASTER_3SEC")
            --addon:RegisterMsg("DO_SOLODUNGEON_RANKINGPAGE_OPEN", "CHATMASTER_INITFRAME");
            --soloDungeonClient.ReqSoloDungeonRankingPage()


            --addon:RegisterMsg("GAME_START", "CHATMASTER_REFRESH")
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function CHATMASTER_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function CHATMASTER_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format("[%s] cannot load setting files", addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    CHATMASTER_UPGRADE_SETTINGS()
    CHATMASTER_SAVE_SETTINGS()
end

function CHATMASTER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
