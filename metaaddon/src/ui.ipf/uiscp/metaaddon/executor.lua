
--metaaddon_executor
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = "ebisuke"

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
g.cls = g.cls or {}
g.fn=g.fn or {}


