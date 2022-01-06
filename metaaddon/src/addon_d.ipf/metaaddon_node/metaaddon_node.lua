--metaaddon_node
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')



function METAADDON_NODE_ON_INIT(addon, frame)
    g.fn.trycatch{
        try = function()
            frame = ui.GetFrame(g.framename)
            g.frm.editor={
                ["addon"] = addon,
                ["frame"] = frame
            }
        end,
        catch = function(error)
            g.fn.errout(error)
        end
    }
end


