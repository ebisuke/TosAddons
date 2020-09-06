-- awakenroller
--アドオン名（大文字）
local addonName = 'awakenroller'
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ''
g.framename = 'awakenroller'
g.debug = false
g.handle = nil
g.interlocked = false
g.currentIndex = 1
g.invItem = nil
g.invItemIESID=nil
g.groupCount = nil
g.needs = nil
g.needscount = 0
g.attempts = -1
local OPTION_GROUP_PROP_LIST = {
    ItemRandomOptionGroupSTAT = {
        'STR',
        'DEX',
        'INT',
        'CON',
        'MNA'
    },
    ItemRandomOptionGroupUTIL = {
        'BLK',
        'BLK_BREAK',
        'ADD_HR',
        'ADD_DR',
        'CRTHR',
        'MHP',
        'MSP',
        'MSTA',
        'RHP',
        'RSP',
        'LootingChance'
    },
    ItemRandomOptionGroupDEF = {
        'ADD_DEF',
        'ADD_MDEF',
        'AriesDEF',
        'SlashDEF',
        'StrikeDEF',
        'RES_FIRE',
        'RES_ICE',
        'RES_POISON',
        'RES_LIGHTNING',
        'RES_EARTH',
        'RES_SOUL',
        'RES_HOLY',
        'RES_DARK',
        'CRTDR',
        'Cloth_Def',
        'Leather_Def',
        'Iron_Def',
        'MiddleSize_Def',
        'ResAdd_Damage'
    },
    ItemRandomOptionGroupATK = {
        'PATK',
        'ADD_MATK',
        'CRTATK',
        'CRTMATK',
        'ADD_CLOTH',
        'ADD_LEATHER',
        'ADD_IRON',
        'ADD_SMALLSIZE',
        'ADD_MIDDLESIZE',
        'ADD_LARGESIZE',
        'ADD_GHOST',
        'ADD_FORESTER',
        'ADD_WIDLING',
        'ADD_VELIAS',
        'ADD_PARAMUNE',
        'ADD_KLAIDA',
        'ADD_FIRE',
        'ADD_ICE',
        'ADD_POISON',
        'ADD_LIGHTNING',
        'ADD_EARTH',
        'ADD_SOUL',
        'ADD_HOLY',
        'ADD_DARK',
        'Add_Damage_Atk',
        'ADD_BOSS_ATK'
    }
}
--ライブラリ読み込み
CHAT_SYSTEM('[ER]loaded')
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

local function AUTO_CAST(ctrl)
    ctrl = tolua.cast(ctrl, ctrl:GetClassString())
    return ctrl
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
        end,
        catch = function(error)
        end
    }
end
function AWAKENROLLER_SAVE_SETTINGS()
    --AWAKENROLLER_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function AWAKENROLLER_SAVE_ALL()
    AWAKENROLLER_SAVETOSTRUCTURE()
    AWAKENROLLER_SAVE_SETTINGS()
    ui.MsgBox('保存しました')
end
function AWAKENROLLER_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('awakenroller')
end

function AWAKENROLLER_LOAD_SETTINGS()
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

    AWAKENROLLER_UPGRADE_SETTINGS()
    AWAKENROLLER_SAVE_SETTINGS()
    AWAKENROLLER_LOADFROMSTRUCTURE()
end

function AWAKENROLLER_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('awakenroller')
end

function AWAKENROLLER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function AWAKENROLLER_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(AWAKENROLLER_GETCID()))
            frame:ShowWindow(0)

            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end

            frame:ShowWindow(0)
            --AWAKENROLLER_INITFRAME(frame)
            AWAKENROLLER_LOAD_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end