--joysticknextstage_debug
--アドオン名（大文字）
local addonName = "joysticknextstage"
local addonJSNCommonLibName = "jsn_commonlib"
local addonNameLower = string.lower(addonName)
--作者名
local author = 'ebisuke'

--アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
_G['ADDONS'][author][addonJSNCommonLibName] = _G['ADDONS'][author][addonJSNCommonLibName] or {}
local g = _G['ADDONS'][author][addonName]
local jsn = _G['ADDONS'][author][addonJSNCommonLibName]


local function dofile_roughly(path)
    local f, err =  pcall(dofile,path)
    if f then
       
    else
        print(err)
    end
end
function JOYSTICKNEXTSTAGE_DEBUG_RELOAD()
    if(jsn.jsnmanager)then
        local f,err = pcall(jsn.jsnmanager.release,jsn.jsnmanager)
        if(not f)then
            print(err)
        end
    end
    
    local prefix="\\\\theseventhbody_toadstool.mochisuke.jp\\E\\TosProject\\TosAddons\\joysticknextstage\\src"
    dofile_roughly(prefix.."\\addon_d.ipf\\joysticknextstage\\joysticknextstage_debug.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\joysticknextstage\\joysticknextstage.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsncomponent.lua")
    
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\_jsnobject.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsnframe.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsnframebase.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsninterface.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsnmanager.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsnreplacer.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsncomponents.lua")

    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsncursor.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\jsncustomframe.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\overrides\\jsnframe_derives.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\overrides\\jsninventory.lua")

    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\overrides\\jsncommonslotset.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\interfaces\\jsnislot.lua")
    dofile_roughly(prefix.."\\addon_d.ipf\\jsncomponents\\interfaces\\jsnislotset.lua")
    jsn.jsnmanager=jsn.classes.JSNManager()
    local f,err =pcall(jsn.jsnmanager.init,jsn.jsnmanager)
    if(not f)then
        print(err)
    end
end
