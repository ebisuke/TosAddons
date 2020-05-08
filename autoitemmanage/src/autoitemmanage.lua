--アドオン名（大文字）
local addonName = "autoitemmanage"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]

--設定ファイル保存先
--nil=ALPHA1
--1=ALPHA1-2
--2=ALPHA3,0.0.1,ALPHA4,0.0.2
--3=ALPHA5,0.0.3,0.0.4,0.0.5
g.version=3
g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.personalsettingsFileLoc=""
g.editindex = 0
g.framename="autoitemmanage"
g.debug=false
g.slotsize={48,48}
g.logpath=string.format('../addons/%s/log.txt', addonNameLower)
g.isediting=false
g.editkeydown=false
--GAMESTARTでも取っておくこと
local LS=LIBSTORAGEHELPERV1_2
--ライブラリ読み込み
CHAT_SYSTEM("[AIM]loaded")
local acutil  = require('acutil')
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val=="nil"
end

local function L_(str)
    if(option.GetCurrentCountry()=="Japanese")then
        return translationtable[str].jp
    else
        return translationtable[str].eng
    end
end
