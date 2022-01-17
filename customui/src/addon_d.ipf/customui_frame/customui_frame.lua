-- customui
--アドオン名（大文字）
local addonName = "customui"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')



function CUSTOMUI_FRAME_ON_INIT(addon, frame)
    EBI_try_catch{
        try = function()
            
            frame:SetSkinName("chat_window")
   
            frame:ShowWindow(0)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end