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
g.compiled = nil
g.settiings = g.settiings or {}
g.settingsFileLoc = g.basepath.."\\settings.json"
g.personalsettings=g.personalsettings or {}
METAADDON_FLAGS = {}
MF_GAME_START_3SEC = 0x0001
MF_FPS_UPDATE = 0x0002
MF_FIRST_TOUCH = 0x0004
METAADDON_CONTEXT=METAADDON_CONTEXT or {}
g.fn.lazy(
    function()
        g.fn.trycatch {
            try = function()
                g.document={
                    active=nil,
                    opened={},
                    root=nil,
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
            acutil.addSysIcon("metaaddon_config", "sysmenu_sys", "Metaaddon Editor", "METAADDON_EDITOR_TOGGLE_FRAME")
            acutil.addSysIcon("metaaddon_compile", "sysmenu_sys", "Metaaddon Compile", "METAADDON_COMPILE")
            acutil.addSysIcon(
                "metaaddon_debug_lua",
                "sysmenu_sys",
                "Metaaddon Debug LUA Reload",
                "METAADDON_DEBUG_RELOAD_LUA"
            )
            addon:RegisterMsg("FPS_UPDATE", "METAADDON_FPS_UPDATE")
            addon:RegisterMsg("GAME_START", "METAADDON_GAME_START")
            addon:RegisterMsg("GAME_START_3SEC", "METAADDON_GAME_START_3SEC")
            g.fn.lazyLoad()

            local timer = frame:GetChild("addontimer")
            AUTO_CAST(timer)
            timer:SetUpdateScript("METAADDON_TIMER_UPDATE")
            timer:Start(0.01)
            
            METAADDON_LOAD_SETTINGS()
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_GAME_START()
    METAADDON_EDITOR_LOADROOTFILE()
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
        isrunning = false,
        fileList={}
    }
end
function METAADDON_DEFAULTPERSONALSETTINGS()
    return {
        version = g.version,
        isrunning = false
    }
end
function METAADDON_TIMER_UPDATE()
    g.fn.trycatch {
        try = function()
            if g.compiled and g.personalsettings.isrunning then
                for k,v in pairs(g.compiled) do
                    local ok, err = pcall(v)
                    if not ok then
                        g.fn.errout(err)
                    end
                end
            end
            METAADDON_FLAGS = {}
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_FPS_UPDATE()
    g.fn.trycatch {
        try = function()
            g.frm.main.frame:ShowWindow(1)
            METAADDON_FLAGS[MF_FPS_UPDATE] = true

        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end
function METAADDON_GAME_START_3SEC()
    METAADDON_FLAGS[MF_GAME_START_3SEC] = true
end
function METAADDON_GET_FLAGS(flag)
    return METAADDON_FLAGS[flag]
end
function METAADDON_COMPILE()
    return g.fn.trycatch {
        try = function()
            local tocompile={g.document.root}
            g.compiled ={}
            METAADDON_CONTEXT={}
            
            while #tocompile > 0 do
                local addonlet=tocompile[1]
                table.remove(tocompile,1)

                METAADDON_CONTEXT[addonlet.addonletName]=METAADDON_CONTEXT[addonlet.addonletName] or {
                    definition={},
                    datatable={},
                    context={},
                    funcs={},
                    topmost={},
                    indata=nil,
                    outdata=nil,
                }
                local str = addonlet:compile()
                if g.debug then
                    local f = io.open("c:\\temp\\"..addonlet.addonletName..".lua", "w")
                    f:write(str)
                    f:flush()
                    f:close()
                end
                local fn, err = load(str, nil, "t", _G)
                if err then
                    g.fn.errout(err)
                end
                local ok, p = pcall(fn)
                if ok then
                    g.compiled[addonlet.addonletName]=p
                else
                    g.fn.errout(p)
                    return false
                end
                
                --load dependencies
                local depends=addonlet:getDependencies()
                for i,v in ipairs(depends) do
                    local obj=g.fn.lualoadfromfile(g.basepath.."\\"..v..".s.lua")
                    if obj then
                        table.insert(tocompile,1,g.fn.DeserializeObject(obj))
                    else
                        g.fn.errout("dependency not found or cannot load:"..v)
                    end
                end
            end
            METAADDON_FLAGS[MF_FIRST_TOUCH] = true
            return true
        end,
        catch = function(error)
            g.compiled = nil
            g.fn.errout(error)
        end
    }
end
