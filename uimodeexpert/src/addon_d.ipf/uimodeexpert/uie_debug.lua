UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT


UIMODEEXPERT = g

function UIE_DEBUG_RELOAD()
    local inv=g.inv.inventories
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_debug.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_handler.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uimodeexpert.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_overrider.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_tip/uie_tip.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_cursor/uie_cursor.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_inventory/uie_inventory.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_menu/uie_menu.lua]])
    
    g.inv.inventories=inv
    g.inv.frame=ui.GetFrame('uie_inventory')
end