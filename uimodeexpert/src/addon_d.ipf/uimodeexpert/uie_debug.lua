UIMODEEXPERT = UIMODEEXPERT or {}

local g = UIMODEEXPERT


UIMODEEXPERT = g

function UIE_DEBUG_RELOAD()
    local inv=g.inv.inventories
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_debug.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_handler.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uimodeexpert.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_overrider.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_util.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uimodeexpert/uie_translate.lua]])
    
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_tip/uie_tip.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_cursor/uie_cursor.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_inventory/uie_inventory.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_menu/uie_menu.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_generalbg.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_shop.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_shop.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_inventory.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_inventory.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_underbtn.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_fund.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_trade_result.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_market_buy.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_market_search.lua]])
    
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_group_me.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_dummy.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_status.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_component_status.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_fishing.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_portal.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_repair.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_spellbuffshop.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_market_buy.lua]])
    dofile([[E:/ToSProject/TosAddons/uimodeexpert/src/addon_d.ipf/uie_generalbg/uie_gbg_group_market.lua]])

    g.inv.inventories=inv
    g.inv.frame=ui.GetFrame('uie_inventory')
end