--metaaddon_debug
local addonName = "metaaddon"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G['ADDONS'][author][addonName]
function METAADDON_DEBUG_RELOAD_LUA()
    local basepath=[[\\theseventhbody_toadstool.mochisuke.jp\e\ToSProject\ToSAddons\metaaddon\src\addon_d.ipf\]]
    local basepathui=[[\\theseventhbody_toadstool.mochisuke.jp\e\ToSProject\ToSAddons\metaaddon\src\ui.ipf\uiscp\metaaddon\]]

    dofile(basepath.."metaaddon\\metaaddon_debug.lua")

    dofile(basepathui.."_common.lua")
    dofile(basepathui.."addonlet.lua")
    dofile(basepathui.."gate.lua")
    dofile(basepathui.."_node.lua")
    dofile(basepathui.."node_generic.lua")
    dofile(basepathui.."node_tos.lua")
    dofile(basepathui.."executor.lua")
    dofile(basepathui.."serializer.lua")
    
    dofile(basepathui.."stream.lua")
    dofile(basepathui.."streamline.lua")
    dofile(basepathui.."node_ui.lua")
    dofile(basepath.."metaaddon\\metaaddon.lua")
    dofile(basepath.."metaaddon\\libstoragehelper.lua")
    dofile(basepath.."metaaddon\\libitemsearcher.lua")
    dofile(basepath.."libaodrawpic\\libaodrawpicv1_3.lua")
    dofile(basepath.."metaaddon_editor\\metaaddon_editor.lua")
    dofile(basepath.."metaaddon_node\\metaaddon_node.lua")
    

    g.fn.lazyLoad()
    g.fn._lazyFuncs={}

    METAADDON_EDITOR_RECREATE_TAB()
end