--tekimuteki
local addonName = 'TEKIMUTEKI'
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
g.settings =
    g.settings or
    {
    }
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'tekimuteki'
g.debug = false

g.addon = g.addon
--ライブラリ読み込み
CHAT_SYSTEM('[TM]loaded')
local acutil = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == 'None' or val == 'nil'
end

local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, 'a')
                fd:write(msg .. '\n')
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
function TEKIMUTEKI_DEFAULTSETTINGS()
    return {
        version=g.version,
        --有効/無効
        enable = false,
        --フレーム表示場所
        position = {
            x = 736,
            y = 171
        },
        itemmanage={
            refills = {},
            refillenableaccountwarehouse=0,
            refillenablewarehouse=0,
            
        },
    }
end
function TEKIMUTEKI_DEFAULTPERSONALSETTINGS()
    return {
        version=g.version,

    }
end

function TEKIMUTEKI_LOAD_SETTINGS()
    DBGOUT('LOAD_SETTING')
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {foods = {}}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        end
    end
    
    TEKIMUTEKI_UPGRADE_SETTINGS()
    TEKIMUTEKI_SAVE_SETTINGS()
    TEKIMUTEKI_LOADFROMSTRUCTURE()
end
function TEKIMUTEKI_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
function TEKIMUTEKI_SAVE_SETTINGS()
    --TEKIMUTEKI_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function TEKIMUTEKI_SAVE_ALL()
    TEKIMUTEKI_SAVETOSTRUCTURE()
    TEKIMUTEKI_SAVE_SETTINGS()
    ui.SysMsg('保存しました')
end
function TEKIMUTEKI_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('tekimuteki')
end
function TEKIMUTEKI_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('tekimuteki')
end
--マップ読み込み時処理（1度だけ）
function TEKIMUTEKI_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame

            if not g.loaded then
                g.loaded = true
            end
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end