-- Anotheroneofinventory
local addonName = "ANOTHERONEOFINVENTORY"
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
g.settings = g.settings or {}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "anotheroneofinventory"
g.debug = false
g.resizing = nil
g.x = nil
g.y = nil
g.findstr = ""

g.filters = {
        
        --{name = "Fav", text = "★", tooltip = "Favorites", imagename = "aoi_favorites", original = nil},
        {name = "All", text = "All", tooltip = "All", imagename = "aoi_all", original = "All"},
        {name = "Equ", text = "Equ", tooltip = "Equip", imagename = "aoi_equip", original = "Equip"},
        {name = "Spl", text = "Spl", tooltip = "Consume Item", imagename = "aoi_consume", original = "Consume"},
        {name = "Rcp", text = "Rcp", tooltip = "Recipe", imagename = "aoi_recipe", original = "Recipe"},
        {name = "Crd", text = "Crd", tooltip = "Card", imagename = "aoi_card", original = "Card"},
        {name = "Etc", text = "Etc", tooltip = "Etc", imagename = "aoi_etc", original = "Etc"},
        {name = "Ing", text = "Ing", tooltip = "Material", imagename = "aoi_ingredients", original = nil},
        {name = "Que", text = "Que", tooltip = "Quest Item", imagename = "aoi_quest", original = nil},
        {name = "Gem", text = "Gem", tooltip = "Gem", imagename = "aoi_gem", original = "Gem"},
        {name = "Prm", text = "Prm", tooltip = "Premium", imagename = "aoi_premium", original = "Premium"},
        {name = "Lim", text = "Lim", tooltip = "Time Limited", imagename = "aoi_timelimited", original = nil},
        {name = "Fnd", text = "Fnd", tooltip = "Find", imagename = "aoi_find", original = nil},
}

g.filterbyname = {}
for _, v in ipairs(g.filters) do
    g.filterbyname[v.name] = v
end
g.settings.filter = "All"
g.invitems = {}
g.checkedframe = nil
local tabsize = 22
local slotsize = 32

--ライブラリ読み込み
CHAT_SYSTEM("[AOI]loaded")
local acutil = require('acutil')
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

local function AUTO_CAST(ctrl)
    if (ctrl == nil) then
        
        return
    end
    ctrl = tolua.cast(ctrl, ctrl:GetClassString());
    return ctrl;
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

function MGN_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function MGN_LOAD_SETTINGS()
    DBGOUT("LOAD_SETTING")
    g.settings = {}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        ERROUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {x = 300, y = 300, w = 300, h = 200}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    MGN_UPGRADE_SETTINGS()
    MGN_SAVE_SETTINGS()

end


function MGN_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end

--マップ読み込み時処理（1度だけ）
function MARJONG_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            g.initialized = false
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('MGN', 'sysmenu_inv', 'mahjong', 'MAHJONG_TOGGLE_FRAME')
            addon:RegisterMsg('GAME_START_3SEC', 'AOI_INIT')
            --ccするたびに設定を読み込む
            if not g.loaded then
                g.loaded = true
            end
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end


function MAHJONG_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end