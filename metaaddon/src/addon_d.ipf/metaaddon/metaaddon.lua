--metaaddon
local addonName = "metaaddon"
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
g.basepath = string.format("../addons/%s/", addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "classdump"
g.debug = true
g.frm = g.frm or {}
g.fn = g.fn or {}
g.fn.lazy(
    function()
        g.fn.trycatch {
            try = function()
                local addonlet = g.cls.MAAddonlet("testaddonlet", "testaddonlet")
                local addonlet2 = g.cls.MAAddonlet("temp", "temp")
                local node1=g.cls.MAComparatorNode({x = 0, y = 0}, {w = 100, h = 100}):init()
                local node2=g.cls.MAComparatorNode({x = 200, y = 0}, {w = 100, h = 100}):init()
                local stream=g.cls.MAPrimitiveStream(node1:getOutlets()[1],node2:getInlets()[1],"boolean"):init()
                addonlet:addNode(node1)
                addonlet:addNode(node2)
  
                g.document = {
                    root = addonlet,
                    active = addonlet,
                    temp=addonlet2,
                }
            end,
            catch = function(error)
                g.fn.errout(error)
            end
        }
    end
)
--ライブラリ読み込み
CHAT_SYSTEM("[METAADDON]loaded")
local acutil = require("acutil")

function METAADDON_ON_INIT(addon, frame)
    g.fn.trycatch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.frm.main = {
                ["addon"] = addon,
                ["frame"] = frame
            }
            acutil.addSysIcon("metaaddon_config", "sysmenu_sys", "Metaaddon Config", "METAADDON_EDITOR_TOGGLE_FRAME")
            acutil.addSysIcon(
                "metaaddon_debug_lua",
                "sysmenu_sys",
                "Metaaddon Debug LUA Reload",
                "METAADDON_DEBUG_RELOAD_LUA"
            )
            g.fn.lazyLoad()
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_SAVE_SETTINGS()
    g.fn.dbgout("SAVE_SETTINGS")
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
    local mySession = session.GetMySession()
    local cid = mySession:GetCID()
    g.personalsettingsFileLoc = string.format("../addons/%s/settings_%s.json", addonNameLower, tostring(cid))
    g.fn.dbgout("psn" .. g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

function METAADDON_LOAD_SETTINGS()
    local mySession = session.GetMySession()
    local cid = mySession:GetCID()
    g.fn.dbgout("LOAD_SETTINGS " .. tostring(cid))
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        g.fn.dbgout(string.format("[%s] cannot load setting files", addonName))
        g.settings = METAADDON_DEFAULTSETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = METAADDON_DEFAULTSETTINGS().version
        end
    end
    g.fn.dbgout("LOAD_PSETTINGS " .. g.personalsettingsFileLoc)
    g.personalsettings = {}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        g.fn.dbgout(string.format("[%s] cannot load setting files", addonName))
        g.personalsettings = METAADDON_DEFAULTPERSONALSETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if (not g.personalsettings.version) then
            g.personalsettings.version = METAADDON_DEFAULTPERSONALSETTINGS().version
        end
    end
    local upc = METAADDON_UPGRADE_SETTINGS()
    local upp = METAADDON_UPGRADE_PERSONALSETTINGS()
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc or upp then
        METAADDON_SAVE_SETTINGS()
    end
end
function METAADDON_UPGRADE_SETTINGS()
    local upgraded = false

    return upgraded
end
function METAADDON_UPGRADE_PERSONALSETTINGS()
    local upgraded = false

    return upgraded
end

function METAADDON_DEFAULTSETTINGS()
    return {
        version = g.version,
        --有効/無効
        enable = false
    }
end
function METAADDON_DEFAULTPERSONALSETTINGS()
    return {
        version = g.version,
        enable = false,
        unusecommon = false
    }
end
