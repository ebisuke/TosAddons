--jsnobject.lua
--アドオン名（大文字）
local addonName = "jsn_commonlib"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'
--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

g.sounds={
    CURSOR_MOVE="button_over",
    DETERMINE="button_click_3",
    CANCEL="button_v_click",
    POPUP="UI_card_move"
}
g.fn={
    CalcPosVirtualToReal=function (x, y)
        local sw = option.GetClientWidth()
        local sh = option.GetClientHeight()
        --representative fullscreen frame
        local frame = ui.GetFrame("worldmap2_mainmap")
        local ow = frame:GetWidth()
        local oh = frame:GetHeight()
        return x * (ow/sw), y * ( oh/sh)
    end,
    CalcPosRealToVirtual=function (x, y)
        local sw = option.GetClientWidth()
        local sh = option.GetClientHeight()
        --representative fullscreen frame
        local frame = ui.GetFrame("worldmap2_mainmap")
        local ow = frame:GetWidth()
        local oh = frame:GetHeight()
        return x * (sw/ow), y * ( sh/oh)
    end
}
