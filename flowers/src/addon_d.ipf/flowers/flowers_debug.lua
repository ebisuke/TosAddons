function FLOWERS_LOAD_DEBUG()
    local basepath=[[\\theseventhbody.local\e\TosProject\TosAddons\flowers]]
    dofile(basepath..[[\src\addon_d.ipf\flowers\flowers_debug.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers\flowers.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers\flowers_class.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers\flowers_func.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers_config\flowers_config.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers\flowers_class_conf_prefab.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers\flowers_language.lua]])
    
    dofile(basepath..[[\src\addon_d.ipf\flowers_value\flowers_value.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers_iconpicker\flowers_iconpicker.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers_colorpicker\flowers_colorpicker.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers_frame\flowers_frame.lua]])
    dofile(basepath..[[\src\addon_d.ipf\flowers_condition\flowers_condition.lua]])
  
    FLOWERS_CONFIG_INITFRAME()
end