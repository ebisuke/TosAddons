--アドオン名（大文字）
local addonName = "SKILLCOMBINER"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

g.version = 0
g.settings = {x = 300, y = 300, volume = 100, mute = false}
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc = ""
g.framename = "skillcombiner"
g.debug = false
g.logpath=string.format('../addons/%s/log.txt', addonNameLower)

g.referurlprefix = "http://10.8.0.40:8080/extract?left=%d&top=%d&areawidth=%d&areaheight=%d&url="
g.toswikiprefix="https://wikiwiki.jp/tosjp/"
--ライブラリ読み込み
CHAT_SYSTEM("[SKILLCOMBINER]loaded")
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



local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
  end
  
  local function urlencode(url)
    if url == nil then
      return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
  end
  
  local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
  end
  
  local urldecode = function(url)
    if url == nil then
      return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", hex_to_char)
    return url
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
function SKILLCOMBINER_SAVE_SETTINGS()
    --CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end


function SKILLCOMBINER_LOAD_SETTINGS()
    SKILLCOMBINER_DBGOUT("LOAD_SETTING")
    g.settings = {foods = {}}
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        --設定ファイル読み込み失敗時処理
        SKILLCOMBINER_DBGOUT(string.format('[%s] cannot load setting files', addonName))
        g.settings = {}
    else
        --設定ファイル読み込み成功時処理
        g.settings = t
        if (not g.settings.version) then
            g.settings.version = 0
        
        end
    end
    
    SKILLCOMBINER_UPGRADE_SETTINGS()
    SKILLCOMBINER_SAVE_SETTINGS()

end


function SKILLCOMBINER_UPGRADE_SETTINGS()
    local upgraded = false
    return upgraded
end
-- if OLD_ON_AOS_OBJ_ENTER==nil then
--     OLD_ON_AOS_OBJ_ENTER=ON_AOS_OBJ_ENTER
--     ON_AOS_OBJ_ENTER=SKILLCOMBINER_ON_AOS_OBJ_ENTER
-- end
--マップ読み込み時処理（1度だけ）
function SKILLCOMBINER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            --g.personalsettingsFileLoc = string.format('../addons/%s/settings_%s.json', addonNameLower,tostring(CAMPCHEF_GETCID()))
            acutil.addSysIcon('SKILLCOMBINER', 'sysmenu_sys', 'SKILLCOMBINER', 'SKILLCOMBINER_TOGGLE_FRAME')

            --addon:RegisterMsg('GAME_START_3SEC', 'SKILLCOMBINER_SHOW')
            --ccするたびに設定を読み込む
            if not g.loaded then
                
                g.loaded = true
            end

            local title = GET_CHILD_RECURSIVELY(frame, "NameText")
            title:SetText("{s24}{ol}SkillCombiner")
            --  --コンテキストメニュー
            -- frame:SetEventScript(ui.RBUTTONDOWN, "AFKMUTE_TOGGLE")
            -- --ドラッグ
            -- frame:SetEventScript(ui.LBUTTONUP, "AFKMUTE_END_DRAG")

            --SKILLCOMBINER_SHOW(g.frame)
            
            g.frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function SKILLCOMBINER_SHOW(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(1)
end
function SKILLCOMBINER_OPEN(frame)

end
function SKILLCOMBINER_CLOSE(frame)
    frame = ui.GetFrame(g.framename)
    frame:ShowWindow(0)
end
function SKILLCOMBINER_TOGGLE_FRAME(frame)
    ui.ToggleFrame(g.framename)

end


function SKILLCOMBINER_ON_TIMER(frame)
    EBI_try_catch{
        try = function()
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
