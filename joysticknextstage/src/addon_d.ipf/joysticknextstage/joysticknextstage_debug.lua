--joysticknextstage_debug
--アドオン名（大文字）
local addonName = "joysticknextstage"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
local acutil = require('acutil')

function JOYSTICKNEXTSTAGE_DEBUG_RELOAD()

    local prefix="\\\\theseventhbody_toadstool.mochisuke.jp\\E\\TosProject\\TosAddons\\joysticknextstage\\src"
    dofile(prefix.."\\addon_d.ipf\\joysticknextstage\\joysticknextstage_debug.lua")
    dofile(prefix.."\\addon_d.ipf\\joysticknextstage\\joysticknextstage.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsncomponent.lua")
    
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\_jsnobject.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsnframe.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsnframebase.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsncontainer.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsninterface.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsnmanager.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsnreplacer.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsncomponents.lua")

    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsncursor.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\jsncustomframe.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\overrides\\jsnframe_derives.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\overrides\\jsninventory.lua")

    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\overrides\\jsncommonslotset.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\interfaces\\jsnislot.lua")
    dofile(prefix.."\\addon_d.ipf\\jsncomponents\\interfaces\\jsnislotset.lua")

end
