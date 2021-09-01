--flowers! config
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

function FLOWERS_COLORPICKER_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
         
        
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end

function FLOWERS_COLORPICKER_TOGGLE_FRAME()
    ui.ToggleFrame("flowers_colorpicker")
end