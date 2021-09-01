--flowers!
local addonName = "flowers"
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
g.basepath = string.format('../addons/%s/', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "classdump"
g.debug = true

g.garden={
    flowers={},
    
}
--ライブラリ読み込み
CHAT_SYSTEM("[FLOWERS!]loaded")
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


function FLOWERS_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            acutil.addSysIcon('flowers_config', 'sysmenu_sys', 'Flowers! Config', 'FLOWERS_CONFIG_TOGGLE_FRAME')
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function FLOWERS_SAVE_SETTINGS()
    DBGOUT("SAVE_SETTINGS")
    acutil.saveJSON(g.settingsFileLoc, g.settings)
    --for debug
     local mySession = session.GetMySession();
        local cid = mySession:GetCID();
    g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(cid))
    DBGOUT("psn"..g.personalsettingsFileLoc)
    acutil.saveJSON(g.personalsettingsFileLoc, g.personalsettings)
end

function FLOWERS_LOAD_SETTINGS()
    local mySession = session.GetMySession();
        local cid = mySession:GetCID();
    DBGOUT("LOAD_SETTINGS "..tostring(cid))
    g.settings={}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings =  FLOWERS_DEFAULTSETTINGS()
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if(not g.settings.version)then
            g.settings.version=FLOWERS_DEFAULTSETTINGS().version
        end
    end
    DBGOUT("LOAD_PSETTINGS "..g.personalsettingsFileLoc)
    g.personalsettings={}
    local t, err = acutil.loadJSON(g.personalsettingsFileLoc, g.personalsettings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.personalsettings= FLOWERS_DEFAULTPERSONALSETTINGS()
        
    else
        --設定ファイル読み込み成功時処理
        g.personalsettings = t
        if(not g.personalsettings.version)then
            g.personalsettings.version=FLOWERS_DEFAULTPERSONALSETTINGS().version
        end
    end
    local upc=FLOWERS_UPGRADE_SETTINGS()
    local upp=FLOWERS_UPGRADE_PERSONALSETTINGS()
    -- ショートサーキット評価を回避するため、いったん変数に入れる
    if upc or upp then
        FLOWERS_SAVE_SETTINGS()
    end
end
function FLOWERS_UPGRADE_SETTINGS()
    local upgraded=false

    return upgraded
end
function FLOWERS_UPGRADE_PERSONALSETTINGS()
    local upgraded=false

    return upgraded
end

function FLOWERS_DEFAULTSETTINGS()
    return {
        version=g.version,
        --有効/無効
        enable = false,
    }
end
function FLOWERS_DEFAULTPERSONALSETTINGS()
    return {
        version=g.version,

        enable=false,
        unusecommon=false,
    }
end