-- advancednumberinput_frame.lua
local addonName = "advancednumberinput"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
local json = require "json_imc"
local libsearch
libsearch=libsearch or LIBITEMSEARCHER_V1_0 --dummy

g.inputframe=g.inputframe or nil



function ADVANCEDNUMBERINPUT_FRAME_ON_INIT(addon, frame)
    g.inputframe=frame
end
